From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH 2/2] net: dsa: mv88e6xxx: call _mv88e6xxx_stats_wait with SMI lock held
Date: Fri, 10 Jul 2015 12:57:29 -0400
Message-ID: <1436547449-26927-2-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1436547449-26927-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Guenter Roeck <linux@roeck-us.net>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:64467 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754395AbbGJQ5f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 12:57:35 -0400
In-Reply-To: <1436547449-26927-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At switch setup, _mv88e6xxx_stats_wait was called without holding the
SMI mutex. Fix this by requesting the lock for this call.

Also, return the _mv88e6xxx_stats_wait code, since it may fail.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 7753db1..cbbc33a 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1961,6 +1961,7 @@ int mv88e6xxx_setup_common(struct dsa_switch *ds)
 int mv88e6xxx_setup_global(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int ret;
 	int i;
 
 	/* Set the default address aging time to 5 minutes, and
@@ -2059,9 +2060,11 @@ int mv88e6xxx_setup_global(struct dsa_switch *ds)
 	REG_WRITE(REG_GLOBAL, GLOBAL_STATS_OP, GLOBAL_STATS_OP_FLUSH_ALL);
 
 	/* Wait for the flush to complete. */
-	_mv88e6xxx_stats_wait(ds);
+	mutex_lock(&ps->smi_mutex);
+	ret = _mv88e6xxx_stats_wait(ds);
+	mutex_unlock(&ps->smi_mutex);
 
-	return 0;
+	return ret;
 }
 
 int mv88e6xxx_switch_reset(struct dsa_switch *ds, bool ppu_active)
-- 
2.4.5
