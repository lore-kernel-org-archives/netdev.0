From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net 3/3] macsec: fix negative refcnt on parent link
Date: Fri, 29 Jul 2016 15:37:55 +0200
Message-ID: <e65f6e4f407f8e1a6b2fa197cf9ea3bd3ef6d888.1469782905.git.sd@queasysnail.net>
References: <cover.1469782905.git.sd@queasysnail.net>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37310 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752834AbcG2NiJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jul 2016 09:38:09 -0400
In-Reply-To: <cover.1469782905.git.sd@queasysnail.net>
In-Reply-To: <cover.1469782905.git.sd@queasysnail.net>
References: <cover.1469782905.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When creation of a macsec device fails because an identical device
already exists on this link, the current code decrements the refcnt on
the parent link (in ->destructor for the macsec device), but it had not
been incremented yet.

Move the dev_hold(parent_link) call earlier during macsec device
creation.

Fixes: c09440f7dcb3 ("macsec: introduce IEEE 802.1AE driver")
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 drivers/net/macsec.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index 7f5c5e0f9cf9..d13e6e15d7b5 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -3179,6 +3179,8 @@ static int macsec_newlink(struct net *net, struct net_device *dev,
 	if (err < 0)
 		return err;
 
+	dev_hold(real_dev);
+
 	/* need to be already registered so that ->init has run and
 	 * the MAC addr is set
 	 */
@@ -3207,8 +3209,6 @@ static int macsec_newlink(struct net *net, struct net_device *dev,
 
 	macsec_generation++;
 
-	dev_hold(real_dev);
-
 	return 0;
 
 del_dev:
-- 
2.9.0
