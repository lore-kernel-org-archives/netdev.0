From: Denis Kirjanov <dkirjanov@kernel.org>
Subject: Re: [PATCH -next] sundance: Add initial ethtool stats support
Date: Wed, 13 Oct 2010 14:28:02 +0400
Message-ID: <4CB589B2.50907@kernel.org>
References: <20101009095346.GA12951@hera.kernel.org>	 <20101009132749.GA15074@solarflare.com>	<4CB0C56C.2000106@kernel.org>	 <20101012.115138.112614145.davem@davemloft.net>	 <4CB4C6E6.9090805@kernel.org> <1286917039.1117.101.camel@Joe-Laptop>	 <4CB54C4F.5070205@kernel.org> <1286951637.2703.141.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jeff Garzik <jgarzik@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:46708 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751078Ab0JMK2O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Oct 2010 06:28:14 -0400
In-Reply-To: <1286951637.2703.141.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/13/2010 10:33 AM, Eric Dumazet wrote:
> Le mercredi 13 octobre 2010 =C3=A0 10:06 +0400, Denis Kirjanov a =C3=A9=
crit :
>=20
>> @@ -1494,13 +1506,23 @@ static struct net_device_stats *get_stats(st=
ruct net_device *dev)
>>  	dev->stats.rx_missed_errors	+=3D ioread8(ioaddr + RxMissed);
>>  	dev->stats.tx_packets +=3D ioread16(ioaddr + TxFramesOK);
>>  	dev->stats.rx_packets +=3D ioread16(ioaddr + RxFramesOK);
>> -	dev->stats.collisions +=3D ioread8(ioaddr + StatsLateColl);
>> -	dev->stats.collisions +=3D ioread8(ioaddr + StatsMultiColl);
>> -	dev->stats.collisions +=3D ioread8(ioaddr + StatsOneColl);
>>  	dev->stats.tx_carrier_errors +=3D ioread8(ioaddr + StatsCarrierErr=
or);
>> -	ioread8(ioaddr + StatsTxDefer);
>> -	for (i =3D StatsTxDefer; i <=3D StatsMcastRx; i++)
>> -		ioread8(ioaddr + i);
>> +
>> +	np->xstats.tx_multiple_collisions +=3D ioread8(ioaddr + StatsMulti=
Coll);
>> +	np->xstats.tx_single_collisions +=3D ioread8(ioaddr + StatsOneColl=
);
>> +	np->xstats.tx_late_collisions +=3D ioread8(ioaddr + StatsLateColl)=
;
>> +	dev->stats.collisions +=3D np->xstats.tx_multiple_collisions
>> +		+ np->xstats.tx_single_collisions
>> +		+ np->xstats.tx_late_collisions;
>=20
>=20
> Oh well..., really ?
>=20
> Each time we are calling get_stats(), you do
>=20
> dev->stats.collisions +=3D (number of accumulated collisions since de=
vice
> is up)
>=20
> instead of
>=20
> dev->stats.collisions +=3D (number of accumulated collisions since la=
st
> time we read counters)

Ok, this is a fixed patch.
Thanks.

Subject: [PATCH -next V5] sundance: Add ethtool stats support

Add ethtool stats support

Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
---
V2:
 check for the ETH_SS_STATS in get_string()
 use xstats struct for ethtool stats
V3:
 make counters 64-bits wide
V4:
 fixed some misspellings
V5:
 fixed issue with collisions counting

 drivers/net/sundance.c |   94 ++++++++++++++++++++++++++++++++++++++++=
++++----
 1 files changed, 87 insertions(+), 7 deletions(-)

diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index 4283cc5..bfa2a01 100644
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -363,6 +363,19 @@ struct netdev_private {
         dma_addr_t tx_ring_dma;
         dma_addr_t rx_ring_dma;
 	struct timer_list timer;		/* Media monitoring timer. */
+	/* ethtool extra stats */
+	struct {
+		u64 tx_multiple_collisions;
+		u64 tx_single_collisions;
+		u64 tx_late_collisions;
+		u64 tx_defered;
+		u64 tx_defered_excessive;
+		u64 tx_aborted;
+		u64 tx_bcasts;
+		u64 rx_bcasts;
+		u64 tx_mcasts;
+		u64 rx_mcasts;
+	} xstats;
 	/* Frequently used values: keep some adjacent for cache effect. */
 	spinlock_t lock;
 	int msg_enable;
@@ -1486,21 +1499,34 @@ static struct net_device_stats *get_stats(struc=
t net_device *dev)
 {
 	struct netdev_private *np =3D netdev_priv(dev);
 	void __iomem *ioaddr =3D np->base;
-	int i;
 	unsigned long flags;
+	u8 late_coll, single_coll, mult_coll;
=20
 	spin_lock_irqsave(&np->statlock, flags);
 	/* The chip only need report frame silently dropped. */
 	dev->stats.rx_missed_errors	+=3D ioread8(ioaddr + RxMissed);
 	dev->stats.tx_packets +=3D ioread16(ioaddr + TxFramesOK);
 	dev->stats.rx_packets +=3D ioread16(ioaddr + RxFramesOK);
-	dev->stats.collisions +=3D ioread8(ioaddr + StatsLateColl);
-	dev->stats.collisions +=3D ioread8(ioaddr + StatsMultiColl);
-	dev->stats.collisions +=3D ioread8(ioaddr + StatsOneColl);
 	dev->stats.tx_carrier_errors +=3D ioread8(ioaddr + StatsCarrierError)=
;
-	ioread8(ioaddr + StatsTxDefer);
-	for (i =3D StatsTxDefer; i <=3D StatsMcastRx; i++)
-		ioread8(ioaddr + i);
+
+	mult_coll =3D ioread8(ioaddr + StatsMultiColl);
+	np->xstats.tx_multiple_collisions +=3D mult_coll;
+	single_coll =3D ioread8(ioaddr + StatsOneColl);
+	np->xstats.tx_single_collisions +=3D single_coll;
+	late_coll =3D ioread8(ioaddr + StatsLateColl);
+	np->xstats.tx_late_collisions +=3D late_coll;
+	dev->stats.collisions +=3D mult_coll
+		+ single_coll
+		+ late_coll;
+
+	np->xstats.tx_defered +=3D ioread8(ioaddr + StatsTxDefer);
+	np->xstats.tx_defered_excessive +=3D ioread8(ioaddr + StatsTxXSDefer)=
;
+	np->xstats.tx_aborted +=3D ioread8(ioaddr + StatsTxAbort);
+	np->xstats.tx_bcasts +=3D ioread8(ioaddr + StatsBcastTx);
+	np->xstats.rx_bcasts +=3D ioread8(ioaddr + StatsBcastRx);
+	np->xstats.tx_mcasts +=3D ioread8(ioaddr + StatsMcastTx);
+	np->xstats.rx_mcasts +=3D ioread8(ioaddr + StatsMcastRx);
+
 	dev->stats.tx_bytes +=3D ioread16(ioaddr + TxOctetsLow);
 	dev->stats.tx_bytes +=3D ioread16(ioaddr + TxOctetsHigh) << 16;
 	dev->stats.rx_bytes +=3D ioread16(ioaddr + RxOctetsLow);
@@ -1566,6 +1592,21 @@ static int __set_mac_addr(struct net_device *dev=
)
 	return 0;
 }
=20
+static const struct {
+	const char name[ETH_GSTRING_LEN];
+} sundance_stats[] =3D {
+	{ "tx_multiple_collisions" },
+	{ "tx_single_collisions" },
+	{ "tx_late_collisions" },
+	{ "tx_defered" },
+	{ "tx_defered_excessive" },
+	{ "tx_aborted" },
+	{ "tx_bcasts" },
+	{ "rx_bcasts" },
+	{ "tx_mcasts" },
+	{ "rx_mcasts" },
+};
+
 static int check_if_running(struct net_device *dev)
 {
 	if (!netif_running(dev))
@@ -1624,6 +1665,42 @@ static void set_msglevel(struct net_device *dev,=
 u32 val)
 	np->msg_enable =3D val;
 }
=20
+static void get_strings(struct net_device *dev, u32 stringset,
+		u8 *data)
+{
+	if (stringset =3D=3D ETH_SS_STATS)
+		memcpy(data, sundance_stats, sizeof(sundance_stats));
+}
+
+static int get_sset_count(struct net_device *dev, int sset)
+{
+	switch (sset) {
+	case ETH_SS_STATS:
+		return ARRAY_SIZE(sundance_stats);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static void get_ethtool_stats(struct net_device *dev,
+		struct ethtool_stats *stats, u64 *data)
+{
+	struct netdev_private *np =3D netdev_priv(dev);
+	int i =3D 0;
+
+	get_stats(dev);
+	data[i++] =3D np->xstats.tx_multiple_collisions;
+	data[i++] =3D np->xstats.tx_single_collisions;
+	data[i++] =3D np->xstats.tx_late_collisions;
+	data[i++] =3D np->xstats.tx_defered;
+	data[i++] =3D np->xstats.tx_defered_excessive;
+	data[i++] =3D np->xstats.tx_aborted;
+	data[i++] =3D np->xstats.tx_bcasts;
+	data[i++] =3D np->xstats.rx_bcasts;
+	data[i++] =3D np->xstats.tx_mcasts;
+	data[i++] =3D np->xstats.rx_mcasts;
+}
+
 static const struct ethtool_ops ethtool_ops =3D {
 	.begin =3D check_if_running,
 	.get_drvinfo =3D get_drvinfo,
@@ -1633,6 +1710,9 @@ static const struct ethtool_ops ethtool_ops =3D {
 	.get_link =3D get_link,
 	.get_msglevel =3D get_msglevel,
 	.set_msglevel =3D set_msglevel,
+	.get_strings =3D get_strings,
+	.get_sset_count =3D get_sset_count,
+	.get_ethtool_stats =3D get_ethtool_stats,
 };
=20
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int =
cmd)
--=20
1.7.0


