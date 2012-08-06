From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 1/5] net: Don't use ifindices in hash fns
Date: Mon, 06 Aug 2012 14:30:50 +0400
Message-ID: <501F9CDA.6040403@parallels.com>
References: <501F9CAF.3030605@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:29137 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751316Ab2HFKa4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Aug 2012 06:30:56 -0400
In-Reply-To: <501F9CAF.3030605@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric noticed, that when there will be devices with equal indices, some
hash functions that use them will become less effective as they could.

Fix this in advance by taking the net_device address into calculations
instead of the device index. Since the net_device is always aligned in
memory, shift the pointer to eliminate always zero bits (like we do it
in net_hash_mix).

This is true for arp and ndisc hash fns. The netlabel, can and llc ones
are also ifindex-based, but that three are init_net-only, thus will not
be affected.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/linux/netdevice.h |    6 ++++++
 include/net/arp.h         |    2 +-
 include/net/ndisc.h       |    2 +-
 3 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a9db4f3..6010b37 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1330,6 +1330,12 @@ struct net_device {
 
 #define	NETDEV_ALIGN		32
 
+static inline unsigned int netdev_hash_mix(const struct net_device *dev)
+{
+	return (unsigned int)(((unsigned long)dev) >>
+			max(L1_CACHE_BYTES, NETDEV_ALIGN));
+}
+
 static inline
 int netdev_get_prio_tc_map(const struct net_device *dev, u32 prio)
 {
diff --git a/include/net/arp.h b/include/net/arp.h
index 7f7df93..0305a38 100644
--- a/include/net/arp.h
+++ b/include/net/arp.h
@@ -10,7 +10,7 @@ extern struct neigh_table arp_tbl;
 
 static inline u32 arp_hashfn(u32 key, const struct net_device *dev, u32 hash_rnd)
 {
-	u32 val = key ^ dev->ifindex;
+	u32 val = key ^ netdev_hash_mix(dev);
 
 	return val * hash_rnd;
 }
diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index 96a3b5c..ae7c1fd 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -134,7 +134,7 @@ static inline u32 ndisc_hashfn(const void *pkey, const struct net_device *dev, _
 {
 	const u32 *p32 = pkey;
 
-	return (((p32[0] ^ dev->ifindex) * hash_rnd[0]) +
+	return (((p32[0] ^ netdev_hash_mix(dev)) * hash_rnd[0]) +
 		(p32[1] * hash_rnd[1]) +
 		(p32[2] * hash_rnd[2]) +
 		(p32[3] * hash_rnd[3]));
-- 
1.7.6.5
