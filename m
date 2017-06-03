From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: dsa: Fix stale cpu_switch reference after unbind then bind
Date: Fri,  2 Jun 2017 22:05:23 -0700
Message-ID: <20170603050523.27014-1-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 9520ed8fb841 ("net: dsa: use cpu_switch instead of ds[0]")
replaced the use of dst->ds[0] with dst->cpu_switch since that is
functionally equivalent, however, we can now run into an use after free
scenario after unbinding then rebinding the switch driver.

The use after free happens because we do correctly initialize
dst->cpu_switch the first time we probe in dsa_cpu_parse(), then we
unbind the driver: dsa_dst_unapply() is called, and we rebind again.
dst->cpu_switch now points to a freed "ds" structure, and so when we
finally dereference it in dsa_cpu_port_ethtool_setup(), we oops.

To fix this, simply set dst->cpu_switch to NULL in dsa_dst_unapply()
which guarantees that we always correctly re-assign dst->cpu_switch in
dsa_cpu_parse().

Fixes: 9520ed8fb841 ("net: dsa: use cpu_switch instead of ds[0]")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
David, please queue this up for 4.11-stable as well, thanks!

 net/dsa/dsa2.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 033b3bfb63dc..7796580e99ee 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -484,8 +484,10 @@ static void dsa_dst_unapply(struct dsa_switch_tree *dst)
 		dsa_ds_unapply(dst, ds);
 	}
 
-	if (dst->cpu_switch)
+	if (dst->cpu_switch) {
 		dsa_cpu_port_ethtool_restore(dst->cpu_switch);
+		dst->cpu_switch = NULL;
+	}
 
 	pr_info("DSA: tree %d unapplied\n", dst->tree);
 	dst->applied = false;
-- 
2.9.3
