From: Florian Zumbiehl <florz@florz.de>
Subject: small packets sent through ne2k-pci delayed
Date: Sun, 4 Apr 2010 16:18:33 +0200
Message-ID: <20100404141833.GH32613@florz.florz.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: p_gortmaker@yahoo.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rain.florz.de ([62.216.164.86]:54722 "EHLO
	rain.florz.dyndns.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754386Ab0DDOrk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Apr 2010 10:47:40 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I noticed today that a 2.6.33 kernel with an ne2k-pci card of mine
transmits small packets (those that result in frames < 61 bytes)
only with some major delay - or more exactly, it seems that they are
being transmitted only when the next packet to be transmitted comes along.

Now, this patch seems to fix it for me, but I am not that sure that that's
how it should be fixed:

diff --git a/drivers/net/lib8390.c b/drivers/net/lib8390.c
index 57f2584..ccef77c 100644
--- a/drivers/net/lib8390.c
+++ b/drivers/net/lib8390.c
@@ -306,13 +306,13 @@ static netdev_tx_t __ei_start_xmit(struct sk_buff *skb,
 	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
 	int send_length = skb->len, output_page;
 	unsigned long flags;
-	char buf[ETH_ZLEN];
+	char buf[ETH_ZLEN+1];
 	char *data = skb->data;
 
-	if (skb->len < ETH_ZLEN) {
-		memset(buf, 0, ETH_ZLEN);	/* more efficient than doing just the needed bits */
+	if (skb->len < ETH_ZLEN+1) {
+		memset(buf, 0, ETH_ZLEN+1);	/* more efficient than doing just the needed bits */
 		memcpy(buf, data, skb->len);
-		send_length = ETH_ZLEN;
+		send_length = ETH_ZLEN+1;
 		data = buf;
 	}

I _think_ that this problem did not exist with 2.6.22-rc4 - but I didn't
have a chance to (re-)test that yet, I just think that I did things in the
past (when that kernel was still running on that machine) that would imply
that the problem did not exist at the time ...

So, any suggestions what I should try, other than re-testing with
2.6.22-rc4 (some time soon, I can do that, too, just not now)?

What might be interesting to know: those 61-byte frames do actually arrive
at the recipient as 61-byte frames ...

Florian
