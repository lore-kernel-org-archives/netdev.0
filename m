From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next] dsa: mv88e6xxx: Fix unsigned/signed issue
Date: Tue, 29 Sep 2015 01:53:48 +0200
Message-ID: <1443484428-29075-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:36543 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752887AbbI2ACI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Sep 2015 20:02:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit dea870242a9c ("dsa: mv88e6xxx: Allow speed/duplex of port to be
configured") leads to the following static checker warning:

        drivers/net/dsa/mv88e6xxx.c:585 mv88e6xxx_adjust_link()
        warn: unsigned 'ret' is never less than zero.

drivers/net/dsa/mv88e6xxx.c
   573  void mv88e6xxx_adjust_link(struct dsa_switch *ds, int port,
   574                             struct phy_device *phydev)
   575  {
   576          struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
   577          u32 ret, reg;
   578
   579          if (!phy_is_pseudo_fixed_link(phydev))
   580                  return;
   581
   582          mutex_lock(&ps->smi_mutex);
   583
   584          ret = _mv88e6xxx_reg_read(ds, REG_PORT(port), PORT_PCS_CTRL);
   585          if (ret < 0)

Make ret an int, which is the return type for _mv88e6xxx_reg_read()

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 30227ca2d5db..05c0938da8c3 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -574,7 +574,8 @@ void mv88e6xxx_adjust_link(struct dsa_switch *ds, int port,
 			   struct phy_device *phydev)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	u32 ret, reg;
+	u32 reg;
+	int ret;
 
 	if (!phy_is_pseudo_fixed_link(phydev))
 		return;
-- 
2.5.1
