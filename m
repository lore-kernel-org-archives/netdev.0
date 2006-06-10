From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: netif_tx_disable vs netif_stop_queue (possible races?)
Date: Sat, 10 Jun 2006 21:15:40 +0400
Message-ID: <20060610171540.GA16820@2ka.mipt.ru>
References: <E1FoYoi-0001gg-00@gondolin.me.apana.org.au> <448993C9.8040400@gentoo.org> <20060609233531.GA15756@gondor.apana.org.au> <448ABE2D.8040401@gentoo.org> <20060610125940.GA2983@2ka.mipt.ru> <448AF607.8000603@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	david-b@pacbell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:24985 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1750842AbWFJRP6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2006 13:15:58 -0400
To: Daniel Drake <dsd@gentoo.org>
Content-Disposition: inline
In-Reply-To: <448AF607.8000603@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 10, 2006 at 05:40:39PM +0100, Daniel Drake (dsd@gentoo.org) wrote:
> Evgeniy Polyakov wrote:
> >On Sat, Jun 10, 2006 at 01:42:21PM +0100, Daniel Drake (dsd@gentoo.org) 
> >wrote:
> >>Herbert Xu wrote:
> >>>Correct.  All callers of hard_start_xmit do so under RCU or equivalent
> >>>locks so they must be complete by the time synchronize_net() returns.
> >>Does this hold for other operations? Such as:
> >>
> >>- The netdev->set_mac_address function
> >>- The wireless ioctl's (SIOCSIWESSID, etc)
> >>
> >>Are these also guaranteed to have returned after synchronize_net()?
> >
> >None of above calls is protected with RCU (except set_mac_address()
> >called through ioctl, which is performed under read_lock which disables
> >preemtption), so they still can run after synchronize_net().
> >
> >But if you are talking about synchronize_net() inside
> >unregister_netdevice(), which is called from 
> >usbnet_disconnect()->unregister_netdev(), than it is safe.
> 
> Are you referring to set_mac_address in the above statement, or both 
> set_mac_address *and* the wireless ioctls?

oth calls have the same nature actually, and both calls are not
protected by RCU.

> I'm basically just looking to clarify that after unregister_netdev has 
> completed, none of the following can be still in progress on any CPU, 
> and none of the following can be triggered again:
> 
> 1. hard_start_xmit handler
> 2. set_mac_address handler
> 3. WX ioctls
> 
> It's logical that this is the case, but the code doesn't make that very 
> clear (and would certainly result in many potential ZD1211 races if this 
> was not the case).

set_mac_address() and wireless ioctls are protected by rtnl.
unregister_netdevice()  is called under rtnl protection too.
But hard_start_xmit() is not protected (and can not be protected in all
situations) by sleeping semaphore (like rtnl), 
so instead it runs under RCU, which is synchronized in synchronize_net()
inside unregister_netdevice().

> Daniel

-- 
	Evgeniy Polyakov
