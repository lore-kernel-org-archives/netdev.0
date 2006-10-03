From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: [PATCH 2.6] Fix WE-21 Orinoco overflow issue...
Date: Mon, 2 Oct 2006 17:54:05 -0700
Message-ID: <20061003005405.GA15997@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from gundega.hpl.hp.com ([192.6.19.190]:11219 "EHLO
	gundega.hpl.hp.com") by vger.kernel.org with ESMTP id S1030199AbWJCA6X
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Oct 2006 20:58:23 -0400
To: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

	Hi John,

	This patch fixes the Orinoco driver overflow issue with
WE-21. This was discussed on the mailing list, the reporter confirmed
that it fixes the issue and Andrew has already added this patch in
tree.
	Regards,

	Jean

------------------------------------------------------------

diff -u -p linux/drivers/net/wireless/orinoco.j1.c linux/drivers/net/wireless/orinoco.c
--- linux/drivers/net/wireless/orinoco.j1.c	2006-10-02 10:15:41.000000000 -0700
+++ linux/drivers/net/wireless/orinoco.c	2006-10-02 10:39:20.000000000 -0700
@@ -2456,6 +2456,7 @@ void free_orinocodev(struct net_device *
 /* Wireless extensions                                              */
 /********************************************************************/
 
+/* Return : < 0 -> error code ; >= 0 -> length */
 static int orinoco_hw_get_essid(struct orinoco_private *priv, int *active,
 				char buf[IW_ESSID_MAX_SIZE+1])
 {
@@ -2500,9 +2501,9 @@ static int orinoco_hw_get_essid(struct o
 	len = le16_to_cpu(essidbuf.len);
 	BUG_ON(len > IW_ESSID_MAX_SIZE);
 
-	memset(buf, 0, IW_ESSID_MAX_SIZE+1);
+	memset(buf, 0, IW_ESSID_MAX_SIZE);
 	memcpy(buf, p, len);
-	buf[len] = '\0';
+	err = len;
 
  fail_unlock:
 	orinoco_unlock(priv, &flags);
@@ -3026,17 +3027,18 @@ static int orinoco_ioctl_getessid(struct
 
 	if (netif_running(dev)) {
 		err = orinoco_hw_get_essid(priv, &active, essidbuf);
-		if (err)
+		if (err < 0)
 			return err;
+		erq->length = err;
 	} else {
 		if (orinoco_lock(priv, &flags) != 0)
 			return -EBUSY;
-		memcpy(essidbuf, priv->desired_essid, IW_ESSID_MAX_SIZE + 1);
+		memcpy(essidbuf, priv->desired_essid, IW_ESSID_MAX_SIZE);
+		erq->length = strlen(priv->desired_essid);
 		orinoco_unlock(priv, &flags);
 	}
 
 	erq->flags = 1;
-	erq->length = strlen(essidbuf);
 
 	return 0;
 }
@@ -3074,10 +3076,10 @@ static int orinoco_ioctl_getnick(struct 
 	if (orinoco_lock(priv, &flags) != 0)
 		return -EBUSY;
 
-	memcpy(nickbuf, priv->nick, IW_ESSID_MAX_SIZE+1);
+	memcpy(nickbuf, priv->nick, IW_ESSID_MAX_SIZE);
 	orinoco_unlock(priv, &flags);
 
-	nrq->length = strlen(nickbuf);
+	nrq->length = strlen(priv->nick);
 
 	return 0;
 }

