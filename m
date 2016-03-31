From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH net] tun, bpf: fix suspicious RCU usage in
 tun_{attach,detach}_filter
Date: Thu, 31 Mar 2016 07:22:32 +0200
Message-ID: <20160331052232.GB21665@unicorn.suse.cz>
References: <755ee9ec1f6d2229be41806964b372548e4b7586.1459382574.git.daniel@iogearbox.net>
 <20160331011840.GA50846@ast-mbp.thefacebook.com>
 <20160331050115.GA21665@unicorn.suse.cz>
 <20160331050808.GA56499@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net,
	sasha.levin@oracle.com, jslaby@suse.cz, eric.dumazet@gmail.com,
	mst@redhat.com, netdev@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:59802 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750769AbcCaFWf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Mar 2016 01:22:35 -0400
Content-Disposition: inline
In-Reply-To: <20160331050808.GA56499@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 30, 2016 at 10:08:10PM -0700, Alexei Starovoitov wrote:
> On Thu, Mar 31, 2016 at 07:01:15AM +0200, Michal Kubecek wrote:
> > On Wed, Mar 30, 2016 at 06:18:42PM -0700, Alexei Starovoitov wrote:
> > > 
> > > kinda heavy patch to shut up lockdep.
> > > Can we do
> > > old_fp = rcu_dereference_protected(sk->sk_filter,
> > >                                 sock_owned_by_user(sk) || lockdep_rtnl_is_held());
> > > and it always be correct?
> > > I think right now tun is the only such user, but if it's correct
> > > for tun, it's correct for future users too. If not correct then
> > > not correct for tun either.
> > > Or I'm missing something?
> > 
> > Already discussed here:
> > 
> >   http://thread.gmane.org/gmane.linux.kernel/2158069/focus=405853
> 
> I saw that. My point above was challenging 'less accurate' part.
> 
Daniel's point was that lockdep_rtnl_is_held() does not mean "we hold
RTNL" but "someone holds RTNL" so that some other task holding RTNL at
the moment could make the check happy even when called by someone
supposed to own the socket.

So I guess the key question is if avoiding this type of false negative
is important enough to justify the extra complexity (taking into account
this race would have to happen every time the check is performed to
really hide a locking issue).

                                                          Michal Kubecek
