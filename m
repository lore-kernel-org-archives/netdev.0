From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH net] ppp: don't override sk->sk_state in pppoe_flush_dev()
Date: Tue, 6 Oct 2015 11:46:54 +0200
Message-ID: <20151006094654.GD2882@alphalink.fr>
References: <b7fbf103cd589741e3938550e7cf0f3684d8951c.1443605079.git.g.nault@alphalink.fr>
 <7045c1dad4647944f61c958511d45fcd@visp.net.lb>
 <20151002175426.GE2911@alphalink.fr>
 <356ca8b8094bb2460c0182c00e120378@visp.net.lb>
 <1444018131.14634.6.camel@mattb-dl>
 <20151005122459.GG2911@alphalink.fr>
 <1444091180.1468.17.camel@mattb-dl>
 <1444106764.1468.33.camel@mattb-dl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "core@irc.lg.ua" <core@irc.lg.ua>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"paulus@samba.org" <paulus@samba.org>,
	"nuclearcat@nuclearcat.com" <nuclearcat@nuclearcat.com>
To: Matt Bennett <Matt.Bennett@alliedtelesis.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:42858 "EHLO
	mail-2-cbv2.admin.alphalink.fr" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752134AbbJFJq5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 05:46:57 -0400
Content-Disposition: inline
In-Reply-To: <1444106764.1468.33.camel@mattb-dl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 06, 2015 at 04:46:04AM +0000, Matt Bennett wrote:
> > > The second one seems to be trickier. It looks like a race wrt. PADT
> > > message reception. Reproducing the bug will probably require to
> > > generate some PADT flooding to a host that creates and releases PPPoE
> > > connections.
> 
> Ok I think I can see the potential race here, specifically the PADT
> frame is received while the pppoe interface is being deleted. (I will
> have a go inducing this with msleep() in the code tomorrow)
> 
> 1. pppoe_flush_dev() - sk->sk_state = PPPOX_DEAD, po->pppoe_dev = NULL
> 
> 2. pppoe_connect() - sk->sk_state = PPPOX_NONE, po->pppoe_dev = NULL
> 
> 3. pppoe_disc_rcv() - sk->sk_state = PPPOX_ZOMBIE po->pppoe_dev = NULL
> 
> 4. pppoe_release() - dev_put(po->pppoe_dev) ----> Oops
> 
Again, I don't know why you introduce pppoe_connect() into the mix.
But anyway, you got the point. Note that pppoe_flush_dev() could be
replaced by other calls since we just need to reset po->pppoe_dev
(another pppoe_unbind_sock_work() call, due to duplicated PADT, would
also trigger the bug). Note also that pppoe_release() needs to be run
before pppoe_unbind_sock_work() gets scheduled (or at least before it
locks the socket).

> Either in pppoe_disc_rcv() we add the condition:
> 
> @@ -496,7 +499,8 @@ static int pppoe_disc_rcv(struct sk_buff *skb,
> struct net_device *dev,
>                         /* We're no longer connect at the PPPOE layer,
>                          * and must wait for ppp channel to disconnect
> us.
>                          */
> -                       sk->sk_state = PPPOX_ZOMBIE;
> +                       if (sk->sk_state & PPPOX_CONNECTED)
> +                               sk->sk_state = PPPOX_ZOMBIE;
>                 }
> 
> Or perhaps we remove the assumption that the state PPPOX_ZOMBIE has a
> non-null pppoe_dev on it.
> 
I don't think adding complexity in the socket state management would be
a good think. Actually I event think about dropping the PPPOX_ZOMBIE
state altogether. But that's probably something for net-next.

> I don't know why the code isn't like the following anyway.
> 
> -if (sk->sk_state & (PPPOX_CONNECTED | PPPOX_BOUND | PPPOX_ZOMBIE)) {
> +if (po->pppoe_dev) {
> 	dev_put(po->pppoe_dev);
> 	po->pppoe_dev = NULL;
> }
I was thinking about that same approach. pppoe_release() is the only
function making that assumption. Other parts of the code seem to only
require that PPPOX_CONNECTED => pppoe_dev != NULL.

But I think the original condition was valid. Adding PPPOX_ZOMBIE into
the test and resetting pppoe_dev upon reception of PADT have changed the
relationship between sk_state and pppoe_dev, which is where the problem
stands.
