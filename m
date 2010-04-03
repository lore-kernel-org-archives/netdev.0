From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: [PATCH  kernel 2.6.34-rc3] smc91c92_cs: fix the problem of
 "Unable to find hardware address"
Date: Sun, 4 Apr 2010 06:14:34 +0900
Message-ID: <20100404061434.eb98ef3e.ken_kawasaki@spring.nifty.jp>
References: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
	<20090419084444.4ee7ddee.ken_kawasaki@spring.nifty.jp>
	<20090426162929.3d036f26.ken_kawasaki@spring.nifty.jp>
	<20090913172257.6c1976ec.ken_kawasaki@spring.nifty.jp>
	<20091004073257.52a6624b.ken_kawasaki@spring.nifty.jp>
	<20091221205849.dae4e929.ken_kawasaki@spring.nifty.jp>
	<20091223171004.77316fa5.ken_kawasaki@spring.nifty.jp>
	<20100123065625.db751a12.ken_kawasaki@spring.nifty.jp>
	<20100228083420.9ca8e285.ken_kawasaki@spring.nifty.jp>
	<20100328055537.13ef6c01.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ken_kawasaki@spring.nifty.jp
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userg506.nifty.com ([202.248.238.86]:52784 "EHLO
	userg506.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755970Ab0DCVOx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Apr 2010 17:14:53 -0400
In-Reply-To: <20100328055537.13ef6c01.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


smc91c92_cs:
 *cvt_ascii_address returns 0, if success.
 *call free_netdev, if we can't find hardware address.

Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

---

--- linux-2.6.34-rc3/drivers/net/pcmcia/smc91c92_cs.c.orig	2010-04-03 09:41:20.000000000 +0900
+++ linux-2.6.34-rc3/drivers/net/pcmcia/smc91c92_cs.c	2010-04-03 20:34:06.000000000 +0900
@@ -493,13 +493,14 @@ static int pcmcia_get_versmac(struct pcm
 {
 	struct net_device *dev = priv;
 	cisparse_t parse;
+	u8 *buf;
 
 	if (pcmcia_parse_tuple(tuple, &parse))
 		return -EINVAL;
 
-	if ((parse.version_1.ns > 3) &&
-	    (cvt_ascii_address(dev,
-			       (parse.version_1.str + parse.version_1.ofs[3]))))
+	buf = parse.version_1.str + parse.version_1.ofs[3];
+
+	if ((parse.version_1.ns > 3) && (cvt_ascii_address(dev, buf) == 0))
 		return 0;
 
 	return -EINVAL;
@@ -528,7 +529,7 @@ static int mhz_setup(struct pcmcia_devic
     len = pcmcia_get_tuple(link, 0x81, &buf);
     if (buf && len >= 13) {
 	    buf[12] = '\0';
-	    if (cvt_ascii_address(dev, buf))
+	    if (cvt_ascii_address(dev, buf) == 0)
 		    rc = 0;
     }
     kfree(buf);
@@ -910,7 +911,7 @@ static int smc91c92_config(struct pcmcia
 
     if (i != 0) {
 	printk(KERN_NOTICE "smc91c92_cs: Unable to find hardware address.\n");
-	goto config_undo;
+	goto config_failed;
     }
 
     smc->duplex = 0;
@@ -998,6 +999,7 @@ config_undo:
     unregister_netdev(dev);
 config_failed:
     smc91c92_release(link);
+    free_netdev(dev);
     return -ENODEV;
 } /* smc91c92_config */
 
