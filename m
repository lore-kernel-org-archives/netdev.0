From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: [PATCH v4] stmmac: fix check for phydev being open
Date: Wed,  9 Sep 2015 18:01:08 +0300
Message-ID: <1441810868-7212-1-git-send-email-abrodkin@synopsys.com>
Cc: Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Current check of phydev with IS_ERR(phydev) may make not much sense
because of_phy_connect() returns NULL on failure instead of error value.

Still for checking result of phy_connect() IS_ERR() makes perfect sense.

So let's use combined check IS_ERR_OR_NULL() that covers both cases.

Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: linux-kernel@vger.kernel.org
Cc: stable@vger.kernel.org
Cc: David Miller <davem@davemloft.net>
Signed-off-by: Alexey Brodkin <abrodkin@synopsys.com>
---

Changes compared to v3:
 * Remove "else" branch after "return" as suggested by Sergei.

Changes compared to v2:
 * Updated commit message with mention of of_phy_connect() instead of
   of_phy_attach().
 * Return ENODEV in case of of_phy_connect() failure

Changes compared to v1:
 * Use IS_ERR_OR_NULL() instead of discrete checks for null and err

 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 864b476..925f2f8 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -837,8 +837,11 @@ static int stmmac_init_phy(struct net_device *dev)
 				     interface);
 	}
 
-	if (IS_ERR(phydev)) {
+	if (IS_ERR_OR_NULL(phydev)) {
 		pr_err("%s: Could not attach to PHY\n", dev->name);
+		if (!phydev)
+			return -ENODEV;
+
 		return PTR_ERR(phydev);
 	}
 
-- 
2.4.3
