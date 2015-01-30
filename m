From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net] netlink: fix wrong subscription bitmask to group
 mapping in
Date: Fri, 30 Jan 2015 20:26:37 +0100
Message-ID: <20150130192637.GA23375@salvia>
References: <1422525113-5698-1-git-send-email-pablo@netfilter.org>
 <20150129222701.GP17877@ycc.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, andre@tomt.net
To: Ivan Delalande <colona@arista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49990 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753005AbbA3TXm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jan 2015 14:23:42 -0500
Content-Disposition: inline
In-Reply-To: <20150129222701.GP17877@ycc.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 29, 2015 at 11:27:01PM +0100, Ivan Delalande wrote:
> On Thu, Jan 29, 2015 at 10:51:53AM +0100, Pablo Neira Ayuso wrote:
> > The subscription bitmask passed via struct sockaddr_nl is converted to
> > the group number when calling the netlink_bind() and netlink_unbind()
> > callbacks.
> >
> > The conversion is however incorrect since bitmask (1 << 0) needs to be
> > mapped to group number 1. Note that you cannot specify the group number 0
> > (usually known as _NONE) from setsockopt() using NETLINK_ADD_MEMBERSHIP
> > since this is rejected through -EINVAL.
> >
> > This problem became noticeable since 97840cb ("netfilter: nfnetlink:
> > fix insufficient validation in nfnetlink_bind") when binding to bitmask
> > (1 << 0) in ctnetlink.
> >
> > Reported-by: Andre Tomt <andre@tomt.net>
> > Reported-by: Ivan Delalande <colona@arista.com>
> > Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
>
> Thanks a lot for this fix!
>
> > ---
> > v2: Rebased upon current net tree. Previous patch:
> >
> > http://patchwork.ozlabs.org/patch/426205/
> >
> > did not apply cleanly.
> >
> >  net/netlink/af_netlink.c |    4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> >
> > diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> > index 02fdde2..75532ef 100644
> > --- a/net/netlink/af_netlink.c
> > +++ b/net/netlink/af_netlink.c
> > @@ -1438,7 +1438,7 @@ static void netlink_undo_bind(int group, long unsigned int groups,
> >
> >  	for (undo = 0; undo < group; undo++)
> >  		if (test_bit(undo, &groups))
> > -			nlk->netlink_unbind(sock_net(sk), undo);
> > +			nlk->netlink_unbind(sock_net(sk), undo + 1);
> >  }
> >
> >  static int netlink_bind(struct socket *sock, struct sockaddr *addr,
> > @@ -1476,7 +1476,7 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
> >  		for (group = 0; group < nlk->ngroups; group++) {
> >  			if (!test_bit(group, &groups))
> >  				continue;
> > -			err = nlk->netlink_bind(net, group);
> > +			err = nlk->netlink_bind(net, group + 1);
> >  			if (!err)
> >  				continue;
> >  			netlink_undo_bind(group, groups, sk);
>
> I guess this should also be group + 1 there:
>
> 	netlink_undo_bind(group + 1, groups, sk);

We don't need that change you suggest.

Asumming nlk->netlink_bind(...) fails when 'group' is 0, then we have
nothing to undo.

See netlink_undo_bind():

     for (undo = 0; undo < group; undo++)
             if (test_bit(undo, &groups))
                   nlk->netlink_unbind(sock_net(sk), undo + 1);

'undo' and 'group' will be both 0, so nothing is undone as expected.

So my patch seems good to me after second look. Let me know if you
have more concerns, thanks.
