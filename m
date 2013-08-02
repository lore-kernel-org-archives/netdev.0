From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 2/2] bonding: modify only neigh_parms owned by us
Date: Fri,  2 Aug 2013 19:07:39 +0200
Message-ID: <1375463259-12033-3-git-send-email-vfalico@redhat.com>
References: <1375463259-12033-1-git-send-email-vfalico@redhat.com>
Cc: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net,
	ebiederm@xmission.com, joe@perches.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28325 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754161Ab3HBRHO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Aug 2013 13:07:14 -0400
In-Reply-To: <1375463259-12033-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Otherwise, on neighbour creation, bond_neigh_init() will be called with a
foreign netdev.

Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_main.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 1d37a96..476df7d 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3630,11 +3630,17 @@ static int bond_neigh_init(struct neighbour *n)
  * The bonding ndo_neigh_setup is called at init time beofre any
  * slave exists. So we must declare proxy setup function which will
  * be used at run time to resolve the actual slave neigh param setup.
+ *
+ * It's also called by master devices (such as vlans) to setup their
+ * underlying devices. In that case - do nothing, we're already set up from
+ * our init.
  */
 static int bond_neigh_setup(struct net_device *dev,
 			    struct neigh_parms *parms)
 {
-	parms->neigh_setup   = bond_neigh_init;
+	/* modify only our neigh_parms */
+	if (parms->dev == dev)
+		parms->neigh_setup = bond_neigh_init;
 
 	return 0;
 }
-- 
1.7.1
