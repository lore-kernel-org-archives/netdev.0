From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 1/3] net/mlx4_core: Fix lockdep warning in handling of mac/vlan tables
Date: Wed,  2 Mar 2016 17:47:44 +0200
Message-ID: <1456933666-28949-2-git-send-email-ogerlitz@mellanox.com>
References: <1456933666-28949-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Majd Dibbiny <majd@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:48318 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753508AbcCBPsS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2016 10:48:18 -0500
In-Reply-To: <1456933666-28949-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

In the mac and vlan register/unregister/replace functions, the driver locks
the mac table mutex (or vlan table mutex) on both ports.

We move to use mutex_lock_nested() to prevent warnings, such as the one below.

[ 101.828445] =============================================
[ 101.834820] [ INFO: possible recursive locking detected ]
[ 101.841199] 4.5.0-rc2+  #49 Not tainted
[ 101.850251] ---------------------------------------------
[ 101.856621] modprobe/3054 is trying to acquire lock:
[ 101.862514] (&table->mutex#2){+.+.+.}, at: [<ffffffffa079c10e>] __mlx4_register_mac+0x87e/0xa90 [mlx4_core]
[ 101.874598]
[ 101.874598] but task is already holding lock:
[ 101.881703] (&table->mutex#2){+.+.+.}, at: [<ffffffffa079c0f0>] __mlx4_register_mac+0x860/0xa90 [mlx4_core]
[ 101.893776]
[ 101.893776] other info that might help us debug this:
[ 101.901658] Possible unsafe locking scenario:
[ 101.901658]
[ 101.908859] CPU0
[ 101.911923] ----
[ 101.914985] lock(&table->mutex#2);
[ 101.919595] lock(&table->mutex#2);
[ 101.924199]
[ 101.924199] * DEADLOCK *
[ 101.924199]
[ 101.931643] May be due to missing lock nesting notation

Fixes: 5f61385d2ebc ('net/mlx4_core: Keep VLAN/MAC tables mirrored in multifunc HA mode')
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Suggested-by: Doron Tsur <doront@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/port.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/port.c b/drivers/net/ethernet/mellanox/mlx4/port.c
index 787b7bb..211c650 100644
--- a/drivers/net/ethernet/mellanox/mlx4/port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/port.c
@@ -193,10 +193,10 @@ int __mlx4_register_mac(struct mlx4_dev *dev, u8 port, u64 mac)
 	if (need_mf_bond) {
 		if (port == 1) {
 			mutex_lock(&table->mutex);
-			mutex_lock(&dup_table->mutex);
+			mutex_lock_nested(&dup_table->mutex, SINGLE_DEPTH_NESTING);
 		} else {
 			mutex_lock(&dup_table->mutex);
-			mutex_lock(&table->mutex);
+			mutex_lock_nested(&table->mutex, SINGLE_DEPTH_NESTING);
 		}
 	} else {
 		mutex_lock(&table->mutex);
@@ -389,10 +389,10 @@ void __mlx4_unregister_mac(struct mlx4_dev *dev, u8 port, u64 mac)
 	if (dup) {
 		if (port == 1) {
 			mutex_lock(&table->mutex);
-			mutex_lock(&dup_table->mutex);
+			mutex_lock_nested(&dup_table->mutex, SINGLE_DEPTH_NESTING);
 		} else {
 			mutex_lock(&dup_table->mutex);
-			mutex_lock(&table->mutex);
+			mutex_lock_nested(&table->mutex, SINGLE_DEPTH_NESTING);
 		}
 	} else {
 		mutex_lock(&table->mutex);
@@ -479,10 +479,10 @@ int __mlx4_replace_mac(struct mlx4_dev *dev, u8 port, int qpn, u64 new_mac)
 	if (dup) {
 		if (port == 1) {
 			mutex_lock(&table->mutex);
-			mutex_lock(&dup_table->mutex);
+			mutex_lock_nested(&dup_table->mutex, SINGLE_DEPTH_NESTING);
 		} else {
 			mutex_lock(&dup_table->mutex);
-			mutex_lock(&table->mutex);
+			mutex_lock_nested(&table->mutex, SINGLE_DEPTH_NESTING);
 		}
 	} else {
 		mutex_lock(&table->mutex);
@@ -588,10 +588,10 @@ int __mlx4_register_vlan(struct mlx4_dev *dev, u8 port, u16 vlan,
 	if (need_mf_bond) {
 		if (port == 1) {
 			mutex_lock(&table->mutex);
-			mutex_lock(&dup_table->mutex);
+			mutex_lock_nested(&dup_table->mutex, SINGLE_DEPTH_NESTING);
 		} else {
 			mutex_lock(&dup_table->mutex);
-			mutex_lock(&table->mutex);
+			mutex_lock_nested(&table->mutex, SINGLE_DEPTH_NESTING);
 		}
 	} else {
 		mutex_lock(&table->mutex);
@@ -764,10 +764,10 @@ void __mlx4_unregister_vlan(struct mlx4_dev *dev, u8 port, u16 vlan)
 	if (dup) {
 		if (port == 1) {
 			mutex_lock(&table->mutex);
-			mutex_lock(&dup_table->mutex);
+			mutex_lock_nested(&dup_table->mutex, SINGLE_DEPTH_NESTING);
 		} else {
 			mutex_lock(&dup_table->mutex);
-			mutex_lock(&table->mutex);
+			mutex_lock_nested(&table->mutex, SINGLE_DEPTH_NESTING);
 		}
 	} else {
 		mutex_lock(&table->mutex);
-- 
2.3.7
