From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next] bonding: handle link transition from FAIL to UP correctly
Date: Tue, 11 Apr 2017 22:36:00 -0700
Message-ID: <20170412053600.35646-1-mahesh@bandewar.net>
Cc: netdev <netdev@vger.kernel.org>,
        Mahesh Bandewar <mahesh@bandewar.net>,
        Mahesh Bandewar <maheshb@google.com>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        Veaceslav Falico <vfalico@gmail.com>,
        Nikolay Aleksandrov <nikolay@redhat.com>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33080 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750915AbdDLFg2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 01:36:28 -0400
Received: by mail-pf0-f193.google.com with SMTP id c198so3023015pfc.0
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 22:36:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

When link transitions from LINK_FAIL to LINK_UP, the commit phase is
not called. This leads to an erroneous state causing slave-link state to
get stuck in "going down" state while its speed and duplex are perfectly
fine. This issue is a side-effect of splitting link-set into propose and
commit phases introduced by de77ecd4ef02 ("bonding: improve link-status
update in mii-monitoring")

This patch fixes these issues by calling commit phase whenever link
state change is proposed.

Fixes: de77ecd4ef02 ("bonding: improve link-status update in mii-monitoring")
Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/bonding/bond_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index aba7352906a5..01e4a69af421 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2064,6 +2064,7 @@ static int bond_miimon_inspect(struct bonding *bond)
 					    (bond->params.downdelay - slave->delay) *
 					    bond->params.miimon,
 					    slave->dev->name);
+				commit++;
 				continue;
 			}
 
@@ -2098,7 +2099,7 @@ static int bond_miimon_inspect(struct bonding *bond)
 					    (bond->params.updelay - slave->delay) *
 					    bond->params.miimon,
 					    slave->dev->name);
-
+				commit++;
 				continue;
 			}
 
-- 
2.12.2.715.g7642488e1d-goog
