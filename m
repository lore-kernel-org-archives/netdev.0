From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: 4.1.0, kernel panic, pppoe_release
Date: Thu, 10 Sep 2015 17:56:57 +0200
Message-ID: <20150910155657.GC3661@alphalink.fr>
References: <677da51dbac367fcb7a456de2789334b@visp.net.lb>
 <c6e2cb4002bf11ad7a25be8eeded2dc1@visp.net.lb>
 <1437147400.5437.4.camel@redhat.com>
 <de4b28603ef7bcaea7aeca73dab80079@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dcbw@redhat.com>, Netdev <netdev@vger.kernel.org>,
	ebiederm@xmission.com, davem@davemloft.net, simon@farnz.org.uk,
	develop@kristov.de
To: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:41515 "EHLO
	mail-2-cbv2.admin.alphalink.fr" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751489AbbIJP5A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2015 11:57:00 -0400
Content-Disposition: inline
In-Reply-To: <de4b28603ef7bcaea7aeca73dab80079@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 17, 2015 at 09:16:14PM +0300, Denys Fedoryshchenko wrote:
> Probably my knowledge of kernel is not sufficient, but i will try few
> approaches.
> One of them to add to pppoe_unbind_sock_work:
> 
>         pppox_unbind_sock(sk);
>         +/* Signal the death of the socket. */
>         +sk->sk_state = PPPOX_DEAD;
>
I don't believe this will fix anything. pppox_unbind_sock() already
sets sk->sk_state when necessary.

> I will wait first, to make sure this patch was causing kernel panic (it
> needs 24h testing cycle), then i will try this fix.
> 
I suspect the problem goes with actions performed on the underlying
interface (MAC address, MTU or link state update). This triggers
pppoe_flush_dev(), which cleans up the device without announcing it
in sk->sk_state.

Can you pleas try the following patch?

---
diff --git a/drivers/net/ppp/pppoe.c b/drivers/net/ppp/pppoe.c
index 3837ae3..2ed7506 100644
--- a/drivers/net/ppp/pppoe.c
+++ b/drivers/net/ppp/pppoe.c
@@ -313,7 +313,6 @@ static void pppoe_flush_dev(struct net_device *dev)
 			if (po->pppoe_dev == dev &&
 			    sk->sk_state & (PPPOX_CONNECTED | PPPOX_BOUND | PPPOX_ZOMBIE)) {
 				pppox_unbind_sock(sk);
-				sk->sk_state = PPPOX_ZOMBIE;
 				sk->sk_state_change(sk);
 				po->pppoe_dev = NULL;
 				dev_put(dev);
