From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net 3/7] bridge: Change local fdb entries whenever mac address of bridge device changes
Date: Mon,  2 Dec 2013 15:40:34 +0900
Message-ID: <1385966439-26526-4-git-send-email-makita.toshiaki@lab.ntt.co.jp>
References: <1385966439-26526-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: "David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:33626 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752861Ab3LBGl7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 01:41:59 -0500
In-Reply-To: <1385966439-26526-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vlan code may need fdb change when changing mac address of bridge device
even if it is caused by the mac address changing of a bridge port.

Example configuration:
  ip link set eth0 address 12:34:56:78:90:ab
  ip link set eth1 address aa:bb:cc:dd:ee:ff
  brctl addif br0 eth0
  brctl addif br0 eth1 # br0 will have mac address 12:34:56:78:90:ab
  bridge vlan add dev br0 vid 10 self
  bridge vlan add dev eth0 vid 10
We will have fdb entry such that f->dst == NULL, f->vlan_id == 10 and
f->addr == 12:34:56:78:90:ab at this time.
Next, change the mac address of eth0 to greater value.
  ip link set eth0 address ee:ff:12:34:56:78
Then, mac address of br0 will be recalculated and set to aa:bb:cc:dd:ee:ff.
However, an entry aa:bb:cc:dd:ee:ff will not be created and we will be not
able to communicate using br0 on vlan 10.

Address this issue by deleting and adding local entries whenever
changing the mac address of the bridge device.

If there already exists an entry that has the same address, for example,
in case that br_fdb_changeaddr() has already inserted it,
br_fdb_change_mac_address() will simply fail to insert it and no
duplicated entry will be made, as it was.

Note that br_add_if() calls br_stp_recalculate_bridge_id() before
br_fdb_insert() and an entry whose dst == NULL will be created in this case.
Though such an entry wouldn't be created in this function without this
patch, I think this behavior will not be harmful because we already have
such entries with vlan_filtering enabled or setting mac address of the
bridge device manually.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
It seems to be not difficult to change the code not to create an entry whose
dst == NULL at br_add_if().  It can be acheived by calling br_fdb_insert()
before br_stp_recalculate_bridge_id() (and actually br_device_event() changes
a fdb entry in such a way).
If it is desirable, I will do that change.

 net/bridge/br_device.c | 1 -
 net/bridge/br_stp_if.c | 2 ++
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index d967773..1cbdbf1 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -187,7 +187,6 @@ static int br_set_mac_address(struct net_device *dev, void *p)
 
 	spin_lock_bh(&br->lock);
 	if (!ether_addr_equal(dev->dev_addr, addr->sa_data)) {
-		br_fdb_change_mac_address(br, addr->sa_data);
 		/* Mac address will be changed in br_stp_change_bridge_id(). */
 		br_stp_change_bridge_id(br, addr->sa_data);
 	}
diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
index 656a6f3..189ba1e 100644
--- a/net/bridge/br_stp_if.c
+++ b/net/bridge/br_stp_if.c
@@ -194,6 +194,8 @@ void br_stp_change_bridge_id(struct net_bridge *br, const unsigned char *addr)
 
 	wasroot = br_is_root_bridge(br);
 
+	br_fdb_change_mac_address(br, addr);
+
 	memcpy(oldaddr, br->bridge_id.addr, ETH_ALEN);
 	memcpy(br->bridge_id.addr, addr, ETH_ALEN);
 	memcpy(br->dev->dev_addr, addr, ETH_ALEN);
-- 
1.8.1.2
