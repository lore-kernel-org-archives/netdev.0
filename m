From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] sctp: fix ASCONF list handling
Date: Fri, 29 May 2015 09:17:26 -0400
Message-ID: <20150529131726.GA29575@hmsreliant.think-freely.org>
References: <d78e23c156981e761086f4e37517e441c84d6f90.1432769183.git.marcelo.leitner@gmail.com>
 <20150528101511.GA14938@hmsreliant.think-freely.org>
 <20150528111727.GB3387@localhost.localdomain>
 <20150528132732.GC3387@localhost.localdomain>
 <20150528144629.GD3387@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Michio Honda <micchie@sfc.wide.ad.jp>
To: Marcelo Ricardo Leitner <mleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49646 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754917AbbE2NRo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 09:17:44 -0400
Content-Disposition: inline
In-Reply-To: <20150528144629.GD3387@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 28, 2015 at 11:46:29AM -0300, Marcelo Ricardo Leitner wrote:
> On Thu, May 28, 2015 at 10:27:32AM -0300, Marcelo Ricardo Leitner wrote:
> > On Thu, May 28, 2015 at 08:17:27AM -0300, Marcelo Ricardo Leitner wrote:
> > > On Thu, May 28, 2015 at 06:15:11AM -0400, Neil Horman wrote:
> > > > On Wed, May 27, 2015 at 09:52:17PM -0300, mleitner@redhat.com wrote:
> > > > > From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> > > > > 
> > > > > ->auto_asconf_splist is per namespace and mangled by functions like
> > > > > sctp_setsockopt_auto_asconf() which doesn't guarantee any serialization.
> > > > > 
> > > > > Also, the call to inet_sk_copy_descendant() was backuping
> > > > > ->auto_asconf_list through the copy but was not honoring
> > > > > ->do_auto_asconf, which could lead to list corruption if it was
> > > > > different between both sockets.
> > > > > 
> > > > > This commit thus fixes the list handling by adding a spinlock to protect
> > > > > against multiple writers and converts the list to be protected by RCU
> > > > > too, so that we don't have a lock inverstion issue at
> > > > > sctp_addr_wq_timeout_handler().
> > > > > 
> > > > > And as this list now uses RCU, we cannot do such backup and restore
> > > > > while copying descendant data anymore as readers may be traversing the
> > > > > list meanwhile. We fix this by simply ignoring/not copying those fields,
> > > > > placed at the end of struct sctp_sock, so we can just ignore it together
> > > > > with struct ipv6_pinfo data. For that we create sctp_copy_descendant()
> > > > > so we don't clutter inet_sk_copy_descendant() with SCTP info.
> > > > > 
> > > > > Issue was found with a test application that kept flipping sysctl
> > > > > default_auto_asconf on and off.
> > > > > 
> > > > > Fixes: 9f7d653b67ae ("sctp: Add Auto-ASCONF support (core).")
> > > > > Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> > > > > ---
> > > > >  include/net/netns/sctp.h   |  6 +++++-
> > > > >  include/net/sctp/structs.h |  2 ++
> > > > >  net/sctp/protocol.c        |  6 +++++-
> > > > >  net/sctp/socket.c          | 39 ++++++++++++++++++++++++++-------------
> > > > >  4 files changed, 38 insertions(+), 15 deletions(-)
> > > > > 
> > > > > diff --git a/include/net/netns/sctp.h b/include/net/netns/sctp.h
> > > > > index 3573a81815ad9e0efb6ceb721eb066d3726419f0..e080bebb3147af39c8275261f57018eb01e917b0 100644
> > > > > --- a/include/net/netns/sctp.h
> > > > > +++ b/include/net/netns/sctp.h
> > > > > @@ -30,12 +30,15 @@ struct netns_sctp {
> > > > >  	struct list_head local_addr_list;
> > > > >  	struct list_head addr_waitq;
> > > > >  	struct timer_list addr_wq_timer;
> > > > > -	struct list_head auto_asconf_splist;
> > > > > +	struct list_head __rcu auto_asconf_splist;
> > > > You should use the addr_wq_lock here instead of creating a new lock, as thats
> > > > already used to protect most accesses to the list you are concerned about.
> > > 
> > > Ok, that works too.
> > > 
> > > > Though truthfully, that shouldn't be necessecary.  The list in question is only
> > > > read in one location and only written in one location.  You can likely just
> > > > rcu-ify, as the write side is in process context and protected by lock_sock.
> > > 
> > > It should, it's not protected by lock_sock as this list resides in
> > > netns_sctp structure, which lock_sock doesn't cover. Write side is in
> > > process context yes, but this list is written in sctp_init_sock(),
> > > sctp_destroy_sock() and sctp_setsockopt_auto_asconf(), so one could
> > > trigger this by either creating/destroying sockets if
> > > default_auto_asconf=1 or just by creating a bunch of sockets and
> > > flipping asconf via setsockopt (or a combination of these operations).
> > > (I'll point this out in the changelog)
> > 
> > Hmm.. by reusing addr_wq_lock we don't need to rcu-ify the list, as the
> > reader is inside that lock too, so I can just protect auto_asconf_splist
> > writers with addr_wq_lock.
> > 
> > Nice, thanks Neil.
> 
> Cannot really do that.. as that creates a lock inversion between
> sctp_destroy_sock() (which already holds lock_sock) and
> sctp_addr_wq_timeout_handler(), which first grabs addr_wq_lock and then
> locks socket by socket.
> 
> Due to that, I'm afraid reusing this lock is not possible, and we should
> stick with the patch.. what do you think? (though I have to fix the nits
> in there)
> 
I don't think thats accurate.  You are correct in that the the locks are taken
in opposing order, which would imply a lock inversion that could result in
deadlock, but we can avoid that by deferring the asconf list removal until after
sk_common_release and unlock_sock_bh is called in sctp_close.  That will make
the lock ordering consistent.  Alternatively, we can pre-emptively take the
asconf_lock in sctp_close before locking the socket.

I'd really rather avoid creating an additional lock here if we don't have to
Neil

>   Marcelo
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
