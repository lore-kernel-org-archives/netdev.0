From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ipv6: use RCU to walk list of network devices
Date: Thu, 12 Nov 2009 04:34:30 +0100
Message-ID: <4AFB8246.6060804@gmail.com>
References: <20091110175446.280423729@vyatta.com> <20091110175647.683253741@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:52188 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750997AbZKLDeb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 22:34:31 -0500
In-Reply-To: <20091110175647.683253741@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> No longer need read_lock(&dev_base_lock), use RCU instead.
> This also needs to be optimized for large number of devices.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

I gave a look at your patch Stephen and found we need a new
next_net_device_rcu(struct net_device *dev) as well,
as next_net_device() is not RCU safe.

(followup patch is probably needed to use it in net/ipv4/igmp.c,
after commit 61fbab77a843d2e77232 : IPV4: use rcu to walk list of devic=
es in IGMP)

We also can avoid taking references on inet6_dev structs.

[PATCH net-next-2.6] ipv6: use RCU to walk list of network devices

No longer need read_lock(&dev_base_lock), use RCU instead.
We also can avoid taking references on inet6_dev structs.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/netdevice.h |   10 +++++++
 net/ipv6/anycast.c        |   29 +++++++++-----------
 net/ipv6/mcast.c          |   51 ++++++++++++++++--------------------
 3 files changed, 47 insertions(+), 43 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 083b598..2734a67 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1093,6 +1093,16 @@ static inline struct net_device *next_net_device=
(struct net_device *dev)
 	return lh =3D=3D &net->dev_base_head ? NULL : net_device_entry(lh);
 }
=20
+static inline struct net_device *next_net_device_rcu(struct net_device=
 *dev)
+{
+	struct list_head *lh;
+	struct net *net;
+
+	net =3D dev_net(dev);
+	lh =3D rcu_dereference(dev->dev_list.next);
+	return lh =3D=3D &net->dev_base_head ? NULL : net_device_entry(lh);
+}
+
 static inline struct net_device *first_net_device(struct net *net)
 {
 	return list_empty(&net->dev_base_head) ? NULL :
diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
index 2f00ca8..f1c74c8 100644
--- a/net/ipv6/anycast.c
+++ b/net/ipv6/anycast.c
@@ -431,9 +431,9 @@ static inline struct ifacaddr6 *ac6_get_first(struc=
t seq_file *seq)
 	struct net *net =3D seq_file_net(seq);
=20
 	state->idev =3D NULL;
-	for_each_netdev(net, state->dev) {
+	for_each_netdev_rcu(net, state->dev) {
 		struct inet6_dev *idev;
-		idev =3D in6_dev_get(state->dev);
+		idev =3D __in6_dev_get(state->dev);
 		if (!idev)
 			continue;
 		read_lock_bh(&idev->lock);
@@ -443,7 +443,6 @@ static inline struct ifacaddr6 *ac6_get_first(struc=
t seq_file *seq)
 			break;
 		}
 		read_unlock_bh(&idev->lock);
-		in6_dev_put(idev);
 	}
 	return im;
 }
@@ -454,16 +453,15 @@ static struct ifacaddr6 *ac6_get_next(struct seq_=
file *seq, struct ifacaddr6 *im
=20
 	im =3D im->aca_next;
 	while (!im) {
-		if (likely(state->idev !=3D NULL)) {
+		if (likely(state->idev !=3D NULL))
 			read_unlock_bh(&state->idev->lock);
-			in6_dev_put(state->idev);
-		}
-		state->dev =3D next_net_device(state->dev);
+
+		state->dev =3D next_net_device_rcu(state->dev);
 		if (!state->dev) {
 			state->idev =3D NULL;
 			break;
 		}
-		state->idev =3D in6_dev_get(state->dev);
+		state->idev =3D __in6_dev_get(state->dev);
 		if (!state->idev)
 			continue;
 		read_lock_bh(&state->idev->lock);
@@ -482,29 +480,30 @@ static struct ifacaddr6 *ac6_get_idx(struct seq_f=
ile *seq, loff_t pos)
 }
=20
 static void *ac6_seq_start(struct seq_file *seq, loff_t *pos)
-	__acquires(dev_base_lock)
+	__acquires(RCU)
 {
-	read_lock(&dev_base_lock);
+	rcu_read_lock();
 	return ac6_get_idx(seq, *pos);
 }
=20
 static void *ac6_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
-	struct ifacaddr6 *im;
-	im =3D ac6_get_next(seq, v);
+	struct ifacaddr6 *im =3D ac6_get_next(seq, v);
+
 	++*pos;
 	return im;
 }
=20
 static void ac6_seq_stop(struct seq_file *seq, void *v)
-	__releases(dev_base_lock)
+	__releases(RCU)
 {
 	struct ac6_iter_state *state =3D ac6_seq_private(seq);
+
 	if (likely(state->idev !=3D NULL)) {
 		read_unlock_bh(&state->idev->lock);
-		in6_dev_put(state->idev);
+		state->idev =3D NULL;
 	}
-	read_unlock(&dev_base_lock);
+	rcu_read_unlock();
 }
=20
 static int ac6_seq_show(struct seq_file *seq, void *v)
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index f9fcf69..1f9c444 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -2375,9 +2375,9 @@ static inline struct ifmcaddr6 *igmp6_mc_get_firs=
t(struct seq_file *seq)
 	struct net *net =3D seq_file_net(seq);
=20
 	state->idev =3D NULL;
-	for_each_netdev(net, state->dev) {
+	for_each_netdev_rcu(net, state->dev) {
 		struct inet6_dev *idev;
-		idev =3D in6_dev_get(state->dev);
+		idev =3D __in6_dev_get(state->dev);
 		if (!idev)
 			continue;
 		read_lock_bh(&idev->lock);
@@ -2387,7 +2387,6 @@ static inline struct ifmcaddr6 *igmp6_mc_get_firs=
t(struct seq_file *seq)
 			break;
 		}
 		read_unlock_bh(&idev->lock);
-		in6_dev_put(idev);
 	}
 	return im;
 }
@@ -2398,16 +2397,15 @@ static struct ifmcaddr6 *igmp6_mc_get_next(stru=
ct seq_file *seq, struct ifmcaddr
=20
 	im =3D im->next;
 	while (!im) {
-		if (likely(state->idev !=3D NULL)) {
+		if (likely(state->idev !=3D NULL))
 			read_unlock_bh(&state->idev->lock);
-			in6_dev_put(state->idev);
-		}
-		state->dev =3D next_net_device(state->dev);
+
+		state->dev =3D next_net_device_rcu(state->dev);
 		if (!state->dev) {
 			state->idev =3D NULL;
 			break;
 		}
-		state->idev =3D in6_dev_get(state->dev);
+		state->idev =3D __in6_dev_get(state->dev);
 		if (!state->idev)
 			continue;
 		read_lock_bh(&state->idev->lock);
@@ -2426,31 +2424,31 @@ static struct ifmcaddr6 *igmp6_mc_get_idx(struc=
t seq_file *seq, loff_t pos)
 }
=20
 static void *igmp6_mc_seq_start(struct seq_file *seq, loff_t *pos)
-	__acquires(dev_base_lock)
+	__acquires(RCU)
 {
-	read_lock(&dev_base_lock);
+	rcu_read_lock();
 	return igmp6_mc_get_idx(seq, *pos);
 }
=20
 static void *igmp6_mc_seq_next(struct seq_file *seq, void *v, loff_t *=
pos)
 {
-	struct ifmcaddr6 *im;
-	im =3D igmp6_mc_get_next(seq, v);
+	struct ifmcaddr6 *im =3D igmp6_mc_get_next(seq, v);
+
 	++*pos;
 	return im;
 }
=20
 static void igmp6_mc_seq_stop(struct seq_file *seq, void *v)
-	__releases(dev_base_lock)
+	__releases(RCU)
 {
 	struct igmp6_mc_iter_state *state =3D igmp6_mc_seq_private(seq);
+
 	if (likely(state->idev !=3D NULL)) {
 		read_unlock_bh(&state->idev->lock);
-		in6_dev_put(state->idev);
 		state->idev =3D NULL;
 	}
 	state->dev =3D NULL;
-	read_unlock(&dev_base_lock);
+	rcu_read_unlock();
 }
=20
 static int igmp6_mc_seq_show(struct seq_file *seq, void *v)
@@ -2507,9 +2505,9 @@ static inline struct ip6_sf_list *igmp6_mcf_get_f=
irst(struct seq_file *seq)
=20
 	state->idev =3D NULL;
 	state->im =3D NULL;
-	for_each_netdev(net, state->dev) {
+	for_each_netdev_rcu(net, state->dev) {
 		struct inet6_dev *idev;
-		idev =3D in6_dev_get(state->dev);
+		idev =3D __in6_dev_get(state->dev);
 		if (unlikely(idev =3D=3D NULL))
 			continue;
 		read_lock_bh(&idev->lock);
@@ -2525,7 +2523,6 @@ static inline struct ip6_sf_list *igmp6_mcf_get_f=
irst(struct seq_file *seq)
 			spin_unlock_bh(&im->mca_lock);
 		}
 		read_unlock_bh(&idev->lock);
-		in6_dev_put(idev);
 	}
 	return psf;
 }
@@ -2539,16 +2536,15 @@ static struct ip6_sf_list *igmp6_mcf_get_next(s=
truct seq_file *seq, struct ip6_s
 		spin_unlock_bh(&state->im->mca_lock);
 		state->im =3D state->im->next;
 		while (!state->im) {
-			if (likely(state->idev !=3D NULL)) {
+			if (likely(state->idev !=3D NULL))
 				read_unlock_bh(&state->idev->lock);
-				in6_dev_put(state->idev);
-			}
-			state->dev =3D next_net_device(state->dev);
+
+			state->dev =3D next_net_device_rcu(state->dev);
 			if (!state->dev) {
 				state->idev =3D NULL;
 				goto out;
 			}
-			state->idev =3D in6_dev_get(state->dev);
+			state->idev =3D __in6_dev_get(state->dev);
 			if (!state->idev)
 				continue;
 			read_lock_bh(&state->idev->lock);
@@ -2573,9 +2569,9 @@ static struct ip6_sf_list *igmp6_mcf_get_idx(stru=
ct seq_file *seq, loff_t pos)
 }
=20
 static void *igmp6_mcf_seq_start(struct seq_file *seq, loff_t *pos)
-	__acquires(dev_base_lock)
+	__acquires(RCU)
 {
-	read_lock(&dev_base_lock);
+	rcu_read_lock();
 	return *pos ? igmp6_mcf_get_idx(seq, *pos - 1) : SEQ_START_TOKEN;
 }
=20
@@ -2591,7 +2587,7 @@ static void *igmp6_mcf_seq_next(struct seq_file *=
seq, void *v, loff_t *pos)
 }
=20
 static void igmp6_mcf_seq_stop(struct seq_file *seq, void *v)
-	__releases(dev_base_lock)
+	__releases(RCU)
 {
 	struct igmp6_mcf_iter_state *state =3D igmp6_mcf_seq_private(seq);
 	if (likely(state->im !=3D NULL)) {
@@ -2600,11 +2596,10 @@ static void igmp6_mcf_seq_stop(struct seq_file =
*seq, void *v)
 	}
 	if (likely(state->idev !=3D NULL)) {
 		read_unlock_bh(&state->idev->lock);
-		in6_dev_put(state->idev);
 		state->idev =3D NULL;
 	}
 	state->dev =3D NULL;
-	read_unlock(&dev_base_lock);
+	rcu_read_unlock();
 }
=20
 static int igmp6_mcf_seq_show(struct seq_file *seq, void *v)
