From: =?ISO-8859-1?Q?Alex_Villac=ED=ADs_Lasso?=
	<avillaci@ceibo.fiec.espol.edu.ec>
Subject: [1/3] IRDA: Create new field tx_extra in skbuff
Date: Mon, 10 Nov 2008 11:09:33 -0500
Message-ID: <49185CBD.2040601@ceibo.fiec.espol.edu.ec>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050802030305090406010507"
To: irda-users@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from host-200-93-199-98.telconet.net ([200.93.199.98]:58354 "EHLO
	elastix.palosanto.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751347AbYKJQKX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2008 11:10:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050802030305090406010507
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit

For background, see regression report at 
http://bugzilla.kernel.org/show_bug.cgi?id=11795

This patchset attempts to fix a regression that broke the irda stack as 
a result of the qdisc patches merged in 2.6.27.

The previous patchsets attempt to fix the clobbering of the irda 
information by storing it within the data payload itself, as an 
additional header. For this, space has been allocated via skb_pull (?!) 
and later, skb_reserve(). The problem with this approach is that  we do 
not have a guarantee that all skbuffs that are processed in the irda 
stack are actually allocated with functions that reserve the required 
space for the irda metadata, especially in the tx route. In addition, 
this approach mixes the payload data with metadata that should not be 
transmitted at all, which is a bit disorganized.

This is the first of 3 patches that try a different approach. Instead of 
allocating an additional "header" within the data buffer itself, it 
introduces a new field within the skbuff, named tx_extra. This field 
should be used for passing data from the higher layers that is required 
for the drivers to transmit the packet correctly, and formalizes the 
previous usage of the cb field by the irda stack. The only issue I see 
is that every single skbuff carries an additional 32 bytes which are not 
put to any use in other stacks (for now). I was thinking about a pointer 
field to on-the-fly allocated data, but that means messing around with 
the skbuff allocation functions, the cloning functions (involving 
deciding how to behave on cloning), etc. This way is simpler to understand.

This patch and the other two that follow fix the issue for me under 
2.6.28-rc3. Please comment on this, as I am messing around with the 
skbuff structure, which potentially affects all network stacks.

Signed-off-by: Alex Villacís Lasso <a_villacis@palosanto.com>

-- 
perl -e '$x=2.4;print sprintf("%.0f + %.0f = %.0f\n",$x,$x,$x+$x);'


--------------050802030305090406010507
Content-Type: text/x-patch;
 name="0001-irda-Introduce_skbuff_tx_extra.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="0001-irda-Introduce_skbuff_tx_extra.patch"

diff -ur linux-2.6.28-rc3-git-orig/include/linux/skbuff.h linux-2.6.28-rc3-git/include/linux/skbuff.h
--- linux-2.6.28-rc3-git-orig/include/linux/skbuff.h	2008-11-06 19:44:23.000000000 -0500
+++ linux-2.6.28-rc3-git/include/linux/skbuff.h	2008-11-08 11:47:46.000000000 -0500
@@ -279,6 +279,14 @@
 	 */
 	char			cb[48];
 
+	/*
+	 * Additional space for layer-specific variables that need to
+	 * survive past dev_queue_xmit(), which clobbers cb above.
+	 * Intended for use by drivers that need additional layer-specific
+	 * parameters in order to transmit a packet properly.
+	 */
+	char			tx_extra[32];
+
 	unsigned int		len,
 				data_len;
 	__u16			mac_len,
diff -ur linux-2.6.28-rc3-git-orig/include/net/irda/irda_device.h linux-2.6.28-rc3-git/include/net/irda/irda_device.h
--- linux-2.6.28-rc3-git-orig/include/net/irda/irda_device.h	2008-11-06 19:44:23.000000000 -0500
+++ linux-2.6.28-rc3-git/include/net/irda/irda_device.h	2008-11-08 11:55:00.000000000 -0500
@@ -230,6 +230,12 @@
 
 void irda_setup_dma(int channel, dma_addr_t buffer, int count, int mode);
 
+
+static inline struct irda_skb_cb *irda_get_skb_cb(struct sk_buff *skb)
+{
+	return (struct irda_skb_cb *)skb->tx_extra;
+}
+
 /*
  * Function irda_get_mtt (skb)
  *

--------------050802030305090406010507--
