From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: [PATCH] Caif: Ref counting
Date: Wed, 7 Apr 2010 14:13:19 +0100
Message-ID: <20100407141319.318ebb6f@lxorguk.ukuu.org.uk>
References: <20100401160916.2a2574f4@lxorguk.ukuu.org.uk>
	<81C3A93C17462B4BBD7E272753C105791696B5DCF0@EXDCVYMBSTM005.EQ1STM.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Sjur BRENDELAND <sjur.brandeland@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:55212 "EHLO
	www.etchedpixels.co.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756470Ab0DGNJK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 09:09:10 -0400
In-Reply-To: <81C3A93C17462B4BBD7E272753C105791696B5DCF0@EXDCVYMBSTM005.EQ1STM.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

caif: tty's are kref objects so take a reference

From: Alan Cox <alan@linux.intel.com>

I don't think this can be abused in this case but do things properly.

Signed-off-by: Alan Cox <alan@linux.intel.com>
---

 drivers/net/caif/caif_serial.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)


diff --git a/drivers/net/caif/caif_serial.c b/drivers/net/caif/caif_serial.c
index 3502f60..b271aa0 100644
--- a/drivers/net/caif/caif_serial.c
+++ b/drivers/net/caif/caif_serial.c
@@ -315,7 +315,7 @@ static int ldisc_open(struct tty_struct *tty)
 	sprintf(name, "cf%s", tty->name);
 	dev = alloc_netdev(sizeof(*ser), name, caifdev_setup);
 	ser = netdev_priv(dev);
-	ser->tty = tty;
+	ser->tty = tty_kref_get(tty);
 	ser->dev = dev;
 	debugfs_init(ser, tty);
 	tty->receive_room = N_TTY_BUF_SIZE;
@@ -348,6 +348,7 @@ static void ldisc_close(struct tty_struct *tty)
 	unregister_netdevice(ser->dev);
 	list_del(&ser->node);
 	debugfs_deinit(ser);
+	tty_kref_put(ser->tty);
 	if (!islocked)
 		rtnl_unlock();
 }
