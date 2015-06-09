From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v3 2/2] sctp: fix ASCONF list handling
Date: Tue, 9 Jun 2015 13:04:34 -0400
Message-ID: <20150609170434.GB27870@hmsreliant.think-freely.org>
References: <20150604142710.GD24585@hmsreliant.think-freely.org>
 <b319ab74178e7f186081db90cc24c229127e42ad.1433524062.git.marcelo.leitner@gmail.com>
 <1433794190.4616.8.camel@stressinduktion.org>
 <20150609153721.GF4049@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Michio Honda <micchie@sfc.wide.ad.jp>
To: Marcelo Ricardo Leitner <mleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:54504 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752649AbbFIREw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2015 13:04:52 -0400
Content-Disposition: inline
In-Reply-To: <20150609153721.GF4049@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 09, 2015 at 12:37:21PM -0300, Marcelo Ricardo Leitner wrote:
> On Mon, Jun 08, 2015 at 10:09:50PM +0200, Hannes Frederic Sowa wrote:
> > On Fr, 2015-06-05 at 14:08 -0300, mleitner@redhat.com wrote:
> > >       if (sp->do_auto_asconf) {
> > > +             spin_lock_bh(&sock_net(sk)->sctp.addr_wq_lock);
> > >               sp->do_auto_asconf = 0;
> > > -             list_del(&sp->auto_asconf_list);
> > > +             list_del_rcu(&sp->auto_asconf_list);
> > > +             spin_unlock_bh(&sock_net(sk)->sctp.addr_wq_lock);
> > >       }
> > 
> > This also looks a bit unsafe to me:
> > 
> > My proposal would be to sock_hold/sock_put the sockets when pushing them
> > onto the auto_asconf_list and defer the modifications on the list until
>                                 ^^^^^^^^^^^^--- you lost me here
> 
> > we don't need to hold socket lock anymore (in syscalls we do have a reference
> > anyway).
> 
> Yup.. seems we have a use-after-free with this rcu usage on
> auto_asconf_splist, because if the socket was destroyed by the time the
> timeout handler is running, it may still see that socket and thus we
> would need two additional procedures a) to take a sock_hold() when it is
> inserted on that list, and release it via call_rcu() and b) to know how
> to identify such dead sockets, most likely just by checking
> sp->do_auto_asconf, and skip from acting on them.
> 
> Neil, WDYT?
> 
That seems like a reasonable approach.

> > addr_wq_lock then is only used either without lock_sock at all or only
> > in order addr_wq_lock -> lock_sock, which does not cause any locking
> > ordering issues.
> 
> No because we have to update this list on sctp_destroy_sock(), which is
> called with lock_sock() held. If we add the precautions above, I think
> it will be fine.
> 
Agreed.

> Thanks,
> Marcelo
> 
> 
