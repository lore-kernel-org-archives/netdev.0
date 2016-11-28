From: Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH net 01/16] net: dsa: slave: fix of-node leak and phy priority
Date: Mon, 28 Nov 2016 19:24:54 +0100
Message-ID: <1480357509-28074-2-git-send-email-johan@kernel.org>
References: <1480357509-28074-1-git-send-email-johan@kernel.org>
Cc: Vince Bridgers <vbridger-yzvPICuk2ABMcg4IHK0kFoH6Mc4MB0Vx@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Fugang Duan <fugang.duan-3arQi8VN3Tc@public.gmane.org>,
        Pantelis Antoniou <pantelis.antoniou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Vitaly Bordug <vbordug-hkdhdckH98+B+jHODAdFcQ@public.gmane.org>,
        Claudiu Manoil <claudiu.manoil-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
        Li Yang <leoli-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
        Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
        John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
        Matthias Brugger <matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
        Lars Persson <lars.persson-VrBV9hrLPhE@public.gmane.org>,
        Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>,
        Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Frank Rowand <frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Vivien Didelot <
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1480357509-28074-1-git-send-email-johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Make sure to drop the reference taken by of_parse_phandle() before
returning from dsa_slave_phy_setup().

Note that this also modifies the PHY priority so that any fixed-link
node is only parsed when no phy-handle is given, which is in accordance
with the common scheme for this.

Fixes: 0d8bcdd383b8 ("net: dsa: allow for more complex PHY setups")
Signed-off-by: Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 net/dsa/slave.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 6b1282c006b1..2a5c20a13fe4 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -1125,7 +1125,7 @@ static int dsa_slave_phy_setup(struct dsa_slave_priv *p,
 	p->phy_interface = mode;
 
 	phy_dn = of_parse_phandle(port_dn, "phy-handle", 0);
-	if (of_phy_is_fixed_link(port_dn)) {
+	if (!phy_dn && of_phy_is_fixed_link(port_dn)) {
 		/* In the case of a fixed PHY, the DT node associated
 		 * to the fixed PHY is the Port DT node
 		 */
@@ -1135,7 +1135,7 @@ static int dsa_slave_phy_setup(struct dsa_slave_priv *p,
 			return ret;
 		}
 		phy_is_fixed = true;
-		phy_dn = port_dn;
+		phy_dn = of_node_get(port_dn);
 	}
 
 	if (ds->ops->get_phy_flags)
@@ -1154,6 +1154,7 @@ static int dsa_slave_phy_setup(struct dsa_slave_priv *p,
 			ret = dsa_slave_phy_connect(p, slave_dev, phy_id);
 			if (ret) {
 				netdev_err(slave_dev, "failed to connect to phy%d: %d\n", phy_id, ret);
+				of_node_put(phy_dn);
 				return ret;
 			}
 		} else {
@@ -1162,6 +1163,8 @@ static int dsa_slave_phy_setup(struct dsa_slave_priv *p,
 						phy_flags,
 						p->phy_interface);
 		}
+
+		of_node_put(phy_dn);
 	}
 
 	if (p->phy && phy_is_fixed)
-- 
2.7.3

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
