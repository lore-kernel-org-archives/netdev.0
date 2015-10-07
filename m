From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH net] ppp: don't override sk->sk_state in pppoe_flush_dev()
Date: Wed, 7 Oct 2015 12:32:51 +0200
Message-ID: <20151007103251.GE2882@alphalink.fr>
References: <b7fbf103cd589741e3938550e7cf0f3684d8951c.1443605079.git.g.nault@alphalink.fr>
 <7045c1dad4647944f61c958511d45fcd@visp.net.lb>
 <20151002175426.GE2911@alphalink.fr>
 <356ca8b8094bb2460c0182c00e120378@visp.net.lb>
 <1444018131.14634.6.camel@mattb-dl>
 <20151005122459.GG2911@alphalink.fr>
 <1444091180.1468.17.camel@mattb-dl>
 <1444106764.1468.33.camel@mattb-dl>
 <20151006094654.GD2882@alphalink.fr>
 <1444165938.1468.48.camel@mattb-dl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "core@irc.lg.ua" <core@irc.lg.ua>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"paulus@samba.org" <paulus@samba.org>,
	"nuclearcat@nuclearcat.com" <nuclearcat@nuclearcat.com>
To: Matt Bennett <Matt.Bennett@alliedtelesis.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:49429 "EHLO
	mail-2-cbv2.admin.alphalink.fr" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751039AbbJGKcy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 06:32:54 -0400
Content-Disposition: inline
In-Reply-To: <1444165938.1468.48.camel@mattb-dl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 06, 2015 at 09:12:18PM +0000, Matt Bennett wrote:
> On Tue, 2015-10-06 at 11:46 +0200, Guillaume Nault wrote:
> > On Tue, Oct 06, 2015 at 04:46:04AM +0000, Matt Bennett wrote:
> > > I don't know why the code isn't like the following anyway.
> > > 
> > > -if (sk->sk_state & (PPPOX_CONNECTED | PPPOX_BOUND | PPPOX_ZOMBIE)) {
> > > +if (po->pppoe_dev) {
> > > 	dev_put(po->pppoe_dev);
> > > 	po->pppoe_dev = NULL;
> > > }
> > I was thinking about that same approach. pppoe_release() is the only
> > function making that assumption. Other parts of the code seem to only
> > require that PPPOX_CONNECTED => pppoe_dev != NULL.
> > 
> > But I think the original condition was valid. Adding PPPOX_ZOMBIE into
> > the test and resetting pppoe_dev upon reception of PADT have changed the
> > relationship between sk_state and pppoe_dev, which is where the problem
> > stands.
> Yes originally the condition was valid. But I think the issue is plain
> to see when you look at the comment beside PPPOX_ZOMBIE declared in the
> enum.
> 
>  PPPOX_ZOMBIE	= 8,  /* dead, but still bound to ppp device */
> 
> We have seen in the situation we have described previously that we can
> be in this state without being bound to the ppp device.
> 
> In my opinion the entire logic around
> pppoe_disc_rcv()/pppoe_unbind_sock_work() looks wrong and I agree we
> should do what you suggested a few emails back.
> 
> i.e in pppoe_disc_rcv():
> 
> if (po) {
> 		struct sock *sk = sk_pppox(po);
> 
> -		bh_lock_sock(sk);
> -
> -		/* If the user has locked the socket, just ignore
> -		 * the packet.  With the way two rcv protocols hook into
> -		 * one socket family type, we cannot (easily) distinguish
> -		 * what kind of SKB it is during backlog rcv.
> -		 */
> -		if (sock_owned_by_user(sk) == 0) {
> -			/* We're no longer connect at the PPPOE layer,
> -			 * and must wait for ppp channel to disconnect us.
> -			 */
> -			sk->sk_state = PPPOX_ZOMBIE;
> -		}
> -
> -		bh_unlock_sock(sk);
> 		if (!schedule_work(&po->proto.pppoe.padt_work))
> 			sock_put(sk);
> 	}
> 
Yes, with the introduction of pppoe_unbind_sock_work(), setting
PPPOX_ZOMBIE shouldn't be required anymore.

> Subsequently the PPPOX_ZOMBIE state can be completely removed?
> 
Yes, this is the last place where PPPOX_ZOMBIE can be set.
