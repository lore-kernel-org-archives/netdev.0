From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 1/7] caif: Ldisc add permission check and
 mem-alloc error check
Date: Wed, 28 Apr 2010 20:54:34 +0200
Message-ID: <1272480880-30672-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: marcel@holtmann.org, daniel.martensson@stericsson.com,
	sjurbr@gmail.com, linus.walleij@stericsson.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eterpe-smout.broadpark.no ([80.202.8.16]:35420 "EHLO
	eterpe-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756460Ab0D1SzY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 14:55:24 -0400
Received: from ignis-smin.broadpark.no ([unknown] [80.202.8.11])
 by eterpe-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L1L00K21OK5DG80@eterpe-smout.broadpark.no> for
 netdev@vger.kernel.org; Wed, 28 Apr 2010 20:55:17 +0200 (CEST)
Received: from localhost.localdomain ([unknown] [84.49.77.207])
 by ignis-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L1L00MYUOK4Q560@ignis-smin.broadpark.no> for
 netdev@vger.kernel.org; Wed, 28 Apr 2010 20:55:17 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Changes:
   o Added permission checks for installing. CAP_SYS_ADMIN and
     CAP_SYS_TTY_CONFIG can install the ldisc.
   o Check if allocation of skb was successful.

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 drivers/net/caif/caif_serial.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/caif/caif_serial.c b/drivers/net/caif/caif_serial.c
index 38c0186..09257ca 100644
--- a/drivers/net/caif/caif_serial.c
+++ b/drivers/net/caif/caif_serial.c
@@ -197,7 +197,8 @@ static void ldisc_receive(struct tty_struct *tty, const u8 *data,
 
 	/* Get a suitable caif packet and copy in data. */
 	skb = netdev_alloc_skb(ser->dev, count+1);
-	BUG_ON(skb == NULL);
+	if (skb == NULL)
+		return;
 	p = skb_put(skb, count);
 	memcpy(p, data, count);
 
@@ -315,6 +316,8 @@ static int ldisc_open(struct tty_struct *tty)
 	/* No write no play */
 	if (tty->ops->write == NULL)
 		return -EOPNOTSUPP;
+	if (!capable(CAP_SYS_ADMIN) && !capable(CAP_SYS_TTY_CONFIG))
+		return -EPERM;
 
 	sprintf(name, "cf%s", tty->name);
 	dev = alloc_netdev(sizeof(*ser), name, caifdev_setup);
-- 
1.6.3.3

