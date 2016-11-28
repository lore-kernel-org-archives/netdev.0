From: Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH net 16/16] net: dsa: slave: fix fixed-link phydev leaks
Date: Mon, 28 Nov 2016 19:25:09 +0100
Message-ID: <1480357509-28074-17-git-send-email-johan@kernel.org>
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

Make sure to deregister and free any fixed-link PHY registered using
of_phy_register_fixed_link() on slave-setup errors and on slave destroy.

Fixes: 0d8bcdd383b8 ("net: dsa: allow for more complex PHY setups")
Signed-off-by: Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 net/dsa/slave.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 2a5c20a13fe4..30e2e21d7619 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -1177,6 +1177,8 @@ static int dsa_slave_phy_setup(struct dsa_slave_priv *p,
 		ret = dsa_slave_phy_connect(p, slave_dev, p->port);
 		if (ret) {
 			netdev_err(slave_dev, "failed to connect to port %d: %d\n", p->port, ret);
+			if (phy_is_fixed)
+				of_phy_deregister_fixed_link(port_dn);
 			return ret;
 		}
 	}
@@ -1292,10 +1294,18 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 void dsa_slave_destroy(struct net_device *slave_dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(slave_dev);
+	struct dsa_switch *ds = p->parent;
+	struct device_node *port_dn;
+
+	port_dn = ds->ports[p->port].dn;
 
 	netif_carrier_off(slave_dev);
-	if (p->phy)
+	if (p->phy) {
 		phy_disconnect(p->phy);
+
+		if (of_phy_is_fixed_link(port_dn))
+			of_phy_deregister_fixed_link(port_dn);
+	}
 	unregister_netdev(slave_dev);
 	free_netdev(slave_dev);
 }
-- 
2.7.3

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
