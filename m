From: David Miller <davem@davemloft.net>
Subject: Re: + oops-in-drivers-net-shaperc.patch added to -mm tree
Date: Thu, 25 Jan 2007 19:31:28 -0800 (PST)
Message-ID: <20070125.193128.39155864.davem@davemloft.net>
References: <200701250354.l0P3spES005128@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: deweerdt@free.fr, netdev@vger.kernel.org,
	frederik.deweerdt@gmail.com, shemminger@osdl.org
To: linux-kernel@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48727
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030720AbXAZDba (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jan 2007 22:31:30 -0500
In-Reply-To: <200701250354.l0P3spES005128@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@osdl.org
Date: Wed, 24 Jan 2007 19:54:51 -0800

> Hi,
> 
> The following code:
> [...]
> 
> Causes the following oops:
> 
 ...
> [   66.355188]  [<c0396c74>] error_code+0x7c/0x84
> [   66.355192]  [<f8adaf03>] packet_sendmsg+0x147/0x201 [af_packet]
> [   66.355199]  [<c030e1c5>] sock_sendmsg+0xf9/0x116
> [   66.355204]  [<c030eb54>] sys_sendto+0xbf/0xe0
> [   66.355208]  [<c030f494>] sys_socketcall+0x1aa/0x277
> [   66.355212]  [<c01041ea>] sysenter_past_esp+0x5f/0x99
> [   66.355216]  =======================
> [   66.355218] Code:  Bad EIP value.
> [   66.355223] EIP: [<00000000>] 0x0 SS:ESP 0068:f6261d70
> 
> shaper_header() should check for shaper->dev not being NULL (ie. the
> shaper was actually attached) as in the following patch.
> This happens in mainline too (tested 2.6.19.2).
> 
> Signed-off-by: Frederik Deweerdt <frederik.deweerdt@gmail.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Stephen Hemminger <shemminger@osdl.org>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Shaper is actually OK.  None of these hardware header callbacks
should be invoked if the device is down.  Yet, this is what is
accidently being allowed in the AF_PACKET socket layer.

Shaper makes sure to fail ->open() if shaper->dev is NULL, in order
to prevent this.

But AF_PACKET does it's check of device state too late, after the
dev->header() call.  That's the bug.

I'll fix it like this:

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 594c078..6dc01bd 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -359,6 +359,10 @@ static int packet_sendmsg_spkt(struct kiocb *iocb, struct socket *sock,
 	if (dev == NULL)
 		goto out_unlock;
 	
+	err = -ENETDOWN;
+	if (!(dev->flags & IFF_UP))
+		goto out_unlock;
+
 	/*
 	 *	You may not queue a frame bigger than the mtu. This is the lowest level
 	 *	raw protocol and you must do your own fragmentation at this level.
@@ -407,10 +411,6 @@ static int packet_sendmsg_spkt(struct kiocb *iocb, struct socket *sock,
 	if (err)
 		goto out_free;
 
-	err = -ENETDOWN;
-	if (!(dev->flags & IFF_UP))
-		goto out_free;
-
 	/*
 	 *	Now send it
 	 */
@@ -738,6 +738,10 @@ static int packet_sendmsg(struct kiocb *iocb, struct socket *sock,
 	if (sock->type == SOCK_RAW)
 		reserve = dev->hard_header_len;
 
+	err = -ENETDOWN;
+	if (!(dev->flags & IFF_UP))
+		goto out_unlock;
+
 	err = -EMSGSIZE;
 	if (len > dev->mtu+reserve)
 		goto out_unlock;
@@ -770,10 +774,6 @@ static int packet_sendmsg(struct kiocb *iocb, struct socket *sock,
 	skb->dev = dev;
 	skb->priority = sk->sk_priority;
 
-	err = -ENETDOWN;
-	if (!(dev->flags & IFF_UP))
-		goto out_free;
-
 	/*
 	 *	Now send it
 	 */
