From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net v2] e1000e: keep vlan interfaces functional after rxvlan off
Date: Thu,  9 Jun 2016 19:50:13 -0400
Message-ID: <1465516213-18176-1-git-send-email-jarod@redhat.com>
References: <1463511831-13684-1-git-send-email-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463511831-13684-1-git-send-email-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've got a bug report about an e1000e interface, where a vlan interface is
set up on top of it:

$ ip link add link ens1f0 name ens1f0.99 type vlan id 99
$ ip link set ens1f0 up
$ ip link set ens1f0.99 up
$ ip addr add 192.168.99.92 dev ens1f0.99

At this point, I can ping another host on vlan 99, ip 192.168.99.91.
However, if I do the following:

$ ethtool -K ens1f0 rxvlan off

Then no traffic passes on ens1f0.99. It comes back if I toggle rxvlan on
again. Upon discussion with folks here, and closer inspection, it appears
that the software *receive* fallback is working correctly, but outbound
traffic is broken. Upon glancing at the e1000 driver, I saw a note about
having to keep RX and TX accel flags in sync, because there's no
(hardware?) support for separate vlan accel toggle. Swipe the same hack
from the e1000 driver, and things start to behave again with rxvlan off.

After patch:

$ ping 192.168.99.91
PING 192.168.99.91 (192.168.99.91) 56(84) bytes of data.
64 bytes from 192.168.99.91: icmp_seq=1 ttl=64 time=0.591 ms
64 bytes from 192.168.99.91: icmp_seq=2 ttl=64 time=0.335 ms
64 bytes from 192.168.99.91: icmp_seq=3 ttl=64 time=0.417 ms
^C
--- 192.168.99.91 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2000ms
rtt min/avg/max/mdev = 0.335/0.447/0.591/0.109 ms

$ sudo ethtool -K ens1f0 rxvlan off
Actual changes:
rx-vlan-offload: off
tx-vlan-offload: off [requested on]

$ ping 192.168.99.91
PING 192.168.99.91 (192.168.99.91) 56(84) bytes of data.
64 bytes from 192.168.99.91: icmp_seq=1 ttl=64 time=0.327 ms
64 bytes from 192.168.99.91: icmp_seq=2 ttl=64 time=0.393 ms
64 bytes from 192.168.99.91: icmp_seq=3 ttl=64 time=0.424 ms
^C
--- 192.168.99.91 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 1999ms
rtt min/avg/max/mdev = 0.327/0.381/0.424/0.043 ms

Also slipped a related-ish fix to the kerneldoc text for
e1000e_vlan_strip_disable here...

CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: intel-wired-lan@lists.osuosl.org
CC: netdev@vger.kernel.org
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 75e6089..2b2e2f8 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -2789,7 +2789,7 @@ static void e1000e_vlan_filter_enable(struct e1000_adapter *adapter)
 }
 
 /**
- * e1000e_vlan_strip_enable - helper to disable HW VLAN stripping
+ * e1000e_vlan_strip_disable - helper to disable HW VLAN stripping
  * @adapter: board private structure to initialize
  **/
 static void e1000e_vlan_strip_disable(struct e1000_adapter *adapter)
@@ -6915,6 +6915,14 @@ static netdev_features_t e1000_fix_features(struct net_device *netdev,
 	if ((hw->mac.type >= e1000_pch2lan) && (netdev->mtu > ETH_DATA_LEN))
 		features &= ~NETIF_F_RXFCS;
 
+	/* Since there is no support for separate Rx/Tx vlan accel
+	 * enable/disable make sure Tx flag is always in same state as Rx.
+	 */
+	if (features & NETIF_F_HW_VLAN_CTAG_RX)
+		features |= NETIF_F_HW_VLAN_CTAG_TX;
+	else
+		features &= ~NETIF_F_HW_VLAN_CTAG_TX;
+
 	return features;
 }
 
-- 
1.8.3.1
