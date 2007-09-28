From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/3] sky2: fix VLAN receive processing
Date: Fri, 28 Sep 2007 09:48:13 -0700
Message-ID: <20070928164858.539587428@linux-foundation.org>
References: <20070928164811.387831540@linux-foundation.org>
Cc: stable@kernel.org, netdev@vger.kernel.org,
	Pierre-Yves Ritschard <pyr@spootnik.org>
To: Krzysztof Oledzki <olel@ans.pl>, Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:46427 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752689AbXI1QwL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 12:52:11 -0400
Content-Disposition: inline; filename=sky2-vlan-len.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The length check for truncated frames was not correctly handling
the case where VLAN acceleration had already read the tag.
Also, the Yukon EX has some features that use high bit of status
as security tag.

Signed-off-by: Pierre-Yves Ritschard <pyr@spootnik.org>
Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/net/sky2.c	2007-09-28 09:13:38.000000000 -0700
+++ b/drivers/net/sky2.c	2007-09-28 09:21:26.000000000 -0700
@@ -2049,6 +2049,7 @@ static struct sk_buff *sky2_receive(stru
  	struct sky2_port *sky2 = netdev_priv(dev);
 	struct rx_ring_info *re = sky2->rx_ring + sky2->rx_next;
 	struct sk_buff *skb = NULL;
+	u16 count;
 
 	if (unlikely(netif_msg_rx_status(sky2)))
 		printk(KERN_DEBUG PFX "%s: rx slot %u status 0x%x len %d\n",
@@ -2063,7 +2064,13 @@ static struct sk_buff *sky2_receive(stru
 	if (!(status & GMR_FS_RX_OK))
 		goto resubmit;
 
-	if (status >> 16 != length)
+	count = (status & GMR_FS_LEN) >> 16;
+#ifdef SKY2_VLAN_TAG_USED
+	/* Account for vlan tag */
+	if (sky2->vlgrp && (status & GMR_FS_VLAN))
+		count -= VLAN_HLEN;
+#endif
+	if (count != length)
 		goto len_mismatch;
 
 	if (length < copybreak)

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

