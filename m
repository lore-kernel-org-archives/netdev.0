From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: Introduce u64_stats_sync infrastructure
Date: Tue, 15 Jun 2010 12:14:16 +0200
Message-ID: <1276596856.2541.84.camel@edumazet-laptop>
References: <1276531162.2478.121.camel@edumazet-laptop>
	 <20100614.231412.39191304.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	Nick Piggin <npiggin@suse.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:43329 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757045Ab0FOKOX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 06:14:23 -0400
Received: by wyb40 with SMTP id 40so4632417wyb.19
        for <netdev@vger.kernel.org>; Tue, 15 Jun 2010 03:14:19 -0700 (PDT)
In-Reply-To: <20100614.231412.39191304.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 14 juin 2010 =C3=A0 23:14 -0700, David Miller a =C3=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 14 Jun 2010 17:59:22 +0200
>=20
> > Uses a seqcount_t to synchronize stat producer and consumer, for pa=
ckets
> > and bytes counter, now u64 types.
> >=20
> > (dropped counter being rarely used, stay a native "unsigned long" t=
ype)
> >=20
> > No noticeable performance impact on x86, as it only adds two increm=
ents
> > per frame. It might be more expensive on arches where smp_wmb() is =
not
> > free.
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Applied, but I suspect we might end up eventually needing to
> abstract this kind of technique in a common place so other
> spots can use it.

Here is the followup patch to abstract things a bit, before upcoming
conversions.

Thanks !

[PATCH net-next-2.6] net: Introduce u64_stats_sync infrastructure

To properly implement 64bits network statistics on 32bit or 64bit hosts=
,
we provide one new type and four methods, to ease conversions.

Stats producer should use following template granted it already got an
exclusive access to counters (a previous lock is taken, or per cpu
data [used in a non preemptable context])

Let me repeat : stats producers must be serialized by other means befor=
e
using this template. Preemption must be disabled too.

u64_stats_update_begin(&stats->syncp);
stats->bytes +=3D len;
stats->packets++;
u64_stats_update_end(&stats->syncp);

While a consumer should use following template to get consistent
snapshot :

u64 tbytes, tpackets;
unsigned int start;

do {
	start =3D u64_stats_fetch_begin(&stats->syncp);
	tbytes =3D stats->bytes;
	tpackets =3D stats->packets;
} while (u64_stats_fetch_retry(&stats->lock, syncp));

This patch uses this infrastructure in net loopback driver, instead of
specific one added in commit 6b10de38f0ef (loopback: Implement 64bit
stats on 32bit arches)

Suggested by David Miller

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Nick Piggin <npiggin@suse.de>
---
 drivers/net/loopback.c    |   61 ++++++++----------------------------
 include/linux/netdevice.h |   50 +++++++++++++++++++++++++++++
 2 files changed, 65 insertions(+), 46 deletions(-)

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 09334f8..f20b156 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -60,51 +60,12 @@
 #include <net/net_namespace.h>
=20
 struct pcpu_lstats {
-	u64 packets;
-	u64 bytes;
-#if BITS_PER_LONG=3D=3D32 && defined(CONFIG_SMP)
-	seqcount_t seq;
-#endif
-	unsigned long drops;
+	u64			packets;
+	u64			bytes;
+	struct u64_stats_sync	syncp;
+	unsigned long		drops;
 };
=20
-#if BITS_PER_LONG=3D=3D32 && defined(CONFIG_SMP)
-static void inline lstats_update_begin(struct pcpu_lstats *lstats)
-{
-	write_seqcount_begin(&lstats->seq);
-}
-static void inline lstats_update_end(struct pcpu_lstats *lstats)
-{
-	write_seqcount_end(&lstats->seq);
-}
-static void inline lstats_fetch_and_add(u64 *packets, u64 *bytes, cons=
t struct pcpu_lstats *lstats)
-{
-	u64 tpackets, tbytes;
-	unsigned int seq;
-
-	do {
-		seq =3D read_seqcount_begin(&lstats->seq);
-		tpackets =3D lstats->packets;
-		tbytes =3D lstats->bytes;
-	} while (read_seqcount_retry(&lstats->seq, seq));
-
-	*packets +=3D tpackets;
-	*bytes +=3D tbytes;
-}
-#else
-static void inline lstats_update_begin(struct pcpu_lstats *lstats)
-{
-}
-static void inline lstats_update_end(struct pcpu_lstats *lstats)
-{
-}
-static void inline lstats_fetch_and_add(u64 *packets, u64 *bytes, cons=
t struct pcpu_lstats *lstats)
-{
-	*packets +=3D lstats->packets;
-	*bytes +=3D lstats->bytes;
-}
-#endif
-
 /*
  * The higher levels take care of making this non-reentrant (it's
  * called with bh's disabled).
@@ -126,10 +87,10 @@ static netdev_tx_t loopback_xmit(struct sk_buff *s=
kb,
=20
 	len =3D skb->len;
 	if (likely(netif_rx(skb) =3D=3D NET_RX_SUCCESS)) {
-		lstats_update_begin(lb_stats);
+		u64_stats_update_begin(&lb_stats->syncp);
 		lb_stats->bytes +=3D len;
 		lb_stats->packets++;
-		lstats_update_end(lb_stats);
+		u64_stats_update_end(&lb_stats->syncp);
 	} else
 		lb_stats->drops++;
=20
@@ -148,10 +109,18 @@ static struct rtnl_link_stats64 *loopback_get_sta=
ts64(struct net_device *dev)
 	pcpu_lstats =3D (void __percpu __force *)dev->ml_priv;
 	for_each_possible_cpu(i) {
 		const struct pcpu_lstats *lb_stats;
+		u64 tbytes, tpackets;
+		unsigned int start;
=20
 		lb_stats =3D per_cpu_ptr(pcpu_lstats, i);
-		lstats_fetch_and_add(&packets, &bytes, lb_stats);
+		do {
+			start =3D u64_stats_fetch_begin(&lb_stats->syncp);
+			tbytes =3D lb_stats->bytes;
+			tpackets =3D lb_stats->packets;
+		} while (u64_stats_fetch_retry(&lb_stats->syncp, start));
 		drops   +=3D lb_stats->drops;
+		bytes   +=3D tbytes;
+		packets +=3D tpackets;
 	}
 	stats->rx_packets =3D packets;
 	stats->tx_packets =3D packets;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4fbccc5..dd1d93d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -174,6 +174,56 @@ static inline bool dev_xmit_complete(int rc)
 #define NET_DEVICE_STATS_DEFINE(name)	unsigned long pad_ ## name, name
 #endif
=20
+#if BITS_PER_LONG=3D=3D32 && defined(CONFIG_SMP)
+struct u64_stats_sync {
+	seqcount_t	seq;
+};
+
+static void inline u64_stats_update_begin(struct u64_stats_sync *syncp=
)
+{
+	write_seqcount_begin(&syncp->seq);
+}
+
+static void inline u64_stats_update_end(struct u64_stats_sync *syncp)
+{
+	write_seqcount_end(&syncp->seq);
+}
+
+static unsigned int inline u64_stats_fetch_begin(const struct u64_stat=
s_sync *syncp)
+{
+	return read_seqcount_begin(&syncp->seq);
+}
+
+static bool inline u64_stats_fetch_retry(const struct u64_stats_sync *=
syncp,
+					 unsigned int start)
+{
+	return read_seqcount_retry(&syncp->seq, start);
+}
+
+#else
+struct u64_stats_sync {
+};
+
+static void inline u64_stats_update_begin(struct u64_stats_sync *syncp=
)
+{
+}
+
+static void inline u64_stats_update_end(struct u64_stats_sync *syncp)
+{
+}
+
+static unsigned int inline u64_stats_fetch_begin(const struct u64_stat=
s_sync *syncp)
+{
+	return 0;
+}
+
+static bool inline u64_stats_fetch_retry(const struct u64_stats_sync *=
syncp,
+					 unsigned int start)
+{
+	return false;
+}
+#endif
+
 struct net_device_stats {
 	NET_DEVICE_STATS_DEFINE(rx_packets);
 	NET_DEVICE_STATS_DEFINE(tx_packets);


