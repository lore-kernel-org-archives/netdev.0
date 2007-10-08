From: Greg KH <gregkh@suse.de>
Subject: [patch 03/12] sky2: fix VLAN receive processing
Date: Mon, 8 Oct 2007 11:06:11 -0700
Message-ID: <20071008180611.GD7627@kroah.com>
References: <20071008180406.052382073@mini.kroah.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Justin Forbes <jmforbes@linuxtx.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	Theodore Ts'o <tytso@mit.edu>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Dave Jones <davej@redhat.com>,
	Chuck Wolber <chuckw@quantumlinux.com>,
	Chris Wedgwood <reviews@ml.cw.f00f.org>,
	Michael Krufky <mkrufky@linuxtv.org>,
	Chuck Ebbert <cebbert@redhat.com>,
	Domenico Andreoli <cavokz@gmail.com>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	Pierre-Yves Ritschard <pyr@spootnik.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: linux-kernel@vger.kernel.org, stable@kernel.org,
	Krzysztof Oledzki <olel@ans.pl>, Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:51776 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752654AbXJHSLC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 14:11:02 -0400
Content-Disposition: inline; filename="sky2-vlan-len.patch"
In-Reply-To: <20071008180551.GA7627@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>

Already upstream.

The length check for truncated frames was not correctly handling
the case where VLAN acceleration had already read the tag.
Also, the Yukon EX has some features that use high bit of status
as security tag.

Signed-off-by: Pierre-Yves Ritschard <pyr@spootnik.org>
Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 drivers/net/sky2.c |    9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
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
