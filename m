From: David Kimdon <david.kimdon@devicescape.com>
Subject: [patch] d80211: fix WEP on big endian cpus
Date: Sun, 10 Sep 2006 10:36:49 -0700
Message-ID: <20060910173649.GA6324@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-85.dex002.intermedia.net ([64.78.20.223]:53158 "EHLO
	dhost002-85.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S932316AbWIJRgw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Sep 2006 13:36:52 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename="wep-big-endian.patch"
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ICV is transmitted on the network as a 4 byte little endian
quantity.  WEP encryption needs to swap the bytes before transmission
and decryption needs to swap bytes before ICV verification.


Index: wireless-dev/net/d80211/wep.c
===================================================================
--- wireless-dev.orig/net/d80211/wep.c	2006-09-10 14:50:52.073583400 +0000
+++ wireless-dev/net/d80211/wep.c	2006-09-10 14:51:10.146835848 +0000
@@ -121,9 +121,11 @@
 {
 	struct scatterlist sg;
 	u32 *icv;
+	u32 crc;
 
 	icv = (u32 *)(data + data_len);
-	*icv = ~crc32_le(~0, data, data_len);
+	crc = ~crc32_le(~0, data, data_len);
+	*icv = cpu_to_le32(crc);
 
 	crypto_cipher_setkey(tfm, rc4key, klen);
 	sg.page = virt_to_page(data);
@@ -196,6 +198,7 @@
 	crypto_cipher_decrypt(tfm, &sg, &sg, sg.length);
 
 	crc = ~crc32_le(~0, data, data_len);
+	crc = cpu_to_le32(crc);
 	if (memcmp(&crc, data + data_len, WEP_ICV_LEN) != 0)
 		/* ICV mismatch */
 		return -1;

--
