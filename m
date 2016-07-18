From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v2 net-next v2 12/12] net: dsa: mv88e6xxx: add support for DSA ageing time
Date: Mon, 18 Jul 2016 16:40:03 -0400
Message-ID: <87k2gibrz0.fsf@ketchup.mtl.sfl>
References: <20160718184628.13103-1-vivien.didelot@savoirfairelinux.com> <20160718184628.13103-13-vivien.didelot@savoirfairelinux.com> <20160718191644.GG31103@lunn.ch> <87d1malpcd.fsf@ketchup.mtl.sfl> <20160718193253.GJ31103@lunn.ch> <87eg6q3efp.fsf@ketchup.mtl.sfl> <20160718201334.GS31103@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160718201334.GS31103@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> On Mon, Jul 18, 2016 at 03:59:38PM -0400, Vivien Didelot wrote:
>> Andrew Lunn <andrew@lunn.ch> writes:
>> 
>> >> Nope, the bridge ageing time is not per-port, even though switchdev ops
>> >> are per-port by design. This is a switch-wide attribute.
>> >
>> > So you are saying the core is doing all the reference counting, etc,
>> > when swapping between fast and slow ageing?
>> 
>> I don't see how checking for the fastest ageing time would fix support
>> for multiple bridges...
>
> The bridge should switch to fast ageing after a topology change to
> flush out entries which are now wrong. Using the short age time for
> too long results in a bit more inefficiency, in that entries time out
> faster than they need to. But if we go back to slow ageing too
> quickly, e.g. because of another bridge, we get wrong operation, in
> that bad entries can get stuck in the table for up to 5 minutes.
>
> So either we need to keep fast ageing as long as there is one bridge
> fast ageing, or we need to flush the whole MAC cache for a bridge on
> topology change and don't bother with fast ageing at all.
>
>> Maybe we can keep it simple for the moment with this switch-wide
>> set_ageing_time operation, and later add a patch for the DSA layer to
>> cache and elect the ageing time per-port or per-bridge.
>
> I don't think it can be done at the DSA layer. It does not have the
> information needed.

OK. I think caching per-port (and thus per-bridge) ageing time would do
the trick and keep DSA drivers simple. What about the following patch?

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 238fad9..2217a3f 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -141,6 +141,7 @@ struct dsa_switch_tree {
 struct dsa_port {
 	struct net_device	*netdev;
 	struct device_node	*dn;
+	unsigned int		ageing_time;
 };
 
 struct dsa_switch {
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 1074cb6..fc91967 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -333,6 +333,21 @@ static int dsa_slave_vlan_filtering(struct net_device *dev,
 	return 0;
 }
 
+static int dsa_fastest_ageing_time(struct dsa_switch *ds,
+				   unsigned int ageing_time)
+{
+	int i;
+
+	for (i = 0; i < DSA_MAX_PORTS; ++i) {
+		struct dsa_port *dp = &ds->ports[i];
+
+		if (dp && dp->ageing_time && dp->ageing_time < ageing_time)
+			ageing_time = dp->ageing_time;
+	}
+
+	return ageing_time;
+}
+
 static int dsa_slave_ageing_time(struct net_device *dev,
 				 const struct switchdev_attr *attr,
 				 struct switchdev_trans *trans)
@@ -346,6 +361,10 @@ static int dsa_slave_ageing_time(struct net_device *dev,
 	if (switchdev_trans_ph_prepare(trans))
 		return 0;
 
+	/* Keep the fastest ageing time in case of multiple bridges */
+	ds->ports[p->port].ageing_time = ageing_time;
+	ageing_time = dsa_fastest_ageing_time(ds, ageing_time);
+
 	if (ds->drv->set_ageing_time)
 		return ds->drv->set_ageing_time(ds, ageing_time);
 

Thanks,

        Vivien
