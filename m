From: David Miller <davem@davemloft.net>
Subject: Re: oops / null deref in __inet6_check_established(), kernel
 2.6.29-rc6
Date: Sun, 01 Mar 2009 21:33:28 -0800 (PST)
Message-ID: <20090301.213328.103151098.davem@davemloft.net>
References: <20090224.152704.210992553.davem@davemloft.net>
	<20090224183554.330eb308@dhcp-100-2-144.bos.redhat.com>
	<20090228031618.GB28503@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cebbert@redhat.com, netdev@vger.kernel.org
To: kyle@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36551
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750730AbZCBFdq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 00:33:46 -0500
In-Reply-To: <20090228031618.GB28503@bombadil.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kyle McMartin <kyle@infradead.org>
Date: Fri, 27 Feb 2009 22:16:18 -0500

> From: Kyle McMartin <kyle@redhat.com>
> 
> This only seems to show up when CONFIG_NET_NS is enabled. (Reproduced on
> git HEAD with that option on, doesn't occur with the option off.)
> 
> I will confess complete ignorance to the network stack, but this patch
> fixes things... ipv4 seems to have the same namespace support, but
> increments the sock_net, not the twsk_net.
> 
> I'll probably put this patch into Fedora, if only to prevent this from
> being used as a local DoS by an unprivileged user.
> 
> Signed-off-by: Kyle McMartin <kyle@redhat.com>

Pavel already submitted a fix for this and it's in my net-2.6
tree and therefore will be sent to Linus soon.

And thanks so much for your amazing patience.

commit 3f53a38131a4e7a053c0aa060aba0411242fb6b9
Author: Pavel Emelyanov <xemul@openvz.org>
Date:   Thu Feb 26 03:35:13 2009 -0800

    ipv6: don't use tw net when accounting for recycled tw
    
    We already have a valid net in that place, but this is not just a
    cleanup - the tw pointer can be NULL there sometimes, thus causing
    an oops in NET_NS=y case.
    
    The same place in ipv4 code already works correctly using existing
    net, rather than tw's one.
    
    The bug exists since 2.6.27.
    
    Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 8fe267f..1bcc343 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -258,11 +258,11 @@ unique:
 
 	if (twp != NULL) {
 		*twp = tw;
-		NET_INC_STATS_BH(twsk_net(tw), LINUX_MIB_TIMEWAITRECYCLED);
+		NET_INC_STATS_BH(net, LINUX_MIB_TIMEWAITRECYCLED);
 	} else if (tw != NULL) {
 		/* Silly. Should hash-dance instead... */
 		inet_twsk_deschedule(tw, death_row);
-		NET_INC_STATS_BH(twsk_net(tw), LINUX_MIB_TIMEWAITRECYCLED);
+		NET_INC_STATS_BH(net, LINUX_MIB_TIMEWAITRECYCLED);
 
 		inet_twsk_put(tw);
 	}
