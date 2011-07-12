From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: Add documentation for netdev features handling
Date: Tue, 12 Jul 2011 21:01:30 +0200 (CEST)
Message-ID: <f95d92bfa1d8760db6ae0dbff67bb0e85eb77a2d.1310496866.git.mirq-linux@rere.qmqm.pl>
References: <1310487816.2732.13.camel@bwh-desktop>
	<20110712090000.29c17c20@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Donald Skidmore <donald.c.skidmore@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:33047 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751220Ab1GLTBc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jul 2011 15:01:32 -0400
In-Reply-To: <1310487816.2732.13.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---

Please comment if something is unclear!
Apply otherwise. ;)

---
 Documentation/networking/netdev-features.txt |  155 ++++++++++++++++++=
++++++++
 1 files changed, 155 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/netdev-features.txt b/Documentati=
on/networking/netdev-features.txt
new file mode 100644
index 0000000..9c209e6
--- /dev/null
+++ b/Documentation/networking/netdev-features.txt
@@ -0,0 +1,155 @@
+Netdev features mess and how to get out from it alive
+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
+
+Author:
+	Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
+
+
+
+ Part I: Feature sets
+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
+
+Long gone are days, when a network card would just take and give packe=
ts
+verbatim.  Todays devices add multiple features and bugs (read: offloa=
ds)
+that relieves OS of various tasks like generating and checking checksu=
ms,
+splitting packets, classifying them.  Those capabilities and their sta=
te
+is commonly referred to as netdev features in Linux kernel world.
+
+There are currently three sets of features relevant to the driver, and
+one used internally by network core:
+
+ 1. netdev->hw_features set contains features whose state may possibly
+    be changed (enabled or disabled) for a particular device by user's
+    request.  This set should be initialized in ndo_init callback and =
not
+    changed later.
+
+ 2. netdev->features set contains features which are currently enabled
+    for a device.  This should be changed only by network core or in
+    error paths of ndo_set_features callback.
+
+ 3. netdev->vlan_features set contains features whose state is inherit=
ed
+    by child VLAN devices (limits netdev->features set).  This is curr=
ently
+    used for all VLAN devices whether tags are stripped or inserted in
+    hardware or software.
+
+ 4. netdev->wanted_features set contains feature set requested by user=
=2E
+    This set is filtered by ndo_fix_features callback whenever it or
+    some device-specific conditions change. This set is internal to
+    networking core and should not be referenced in drivers.
+
+
+
+ Part II: Controlling enabled features
+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
+
+When current feature set (netdev->features) is to be changed, new set
+is calculated and filtered by calling ndo_fix_features callback
+and netdev_fix_features(). If the resulting set differs from current
+set, it is passed to ndo_set_features callback and (if the callback
+returns success) replaces value stored in netdev->features.
+NETDEV_FEAT_CHANGE notification is issued after that whenever current
+set might have changed.
+
+Following events trigger recalculation:
+ 1. device's registration, after ndo_init returned success
+ 2. user requested changes in features state
+ 3. netdev_update_features() is called
+
+ndo_*_features callbacks are called with rtnl_lock held. Missing callb=
acks
+are treated as always returning success.
+
+Driver wanting to trigger recalculation must do so by calling
+netdev_update_features() while holding rtnl_lock. This should not be d=
one
+from ndo_*_features callbacks. netdev->features should not be modified=
 by
+driver except by means of ndo_fix_features callback.
+
+
+
+ Part III: Implementation hints
+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
+
+ * ndo_fix_features:
+
+All dependencies between features should be resolved here. The resulti=
ng
+set can be reduced further by networking core imposed limitations (as =
coded
+in netdev_fix_features()). For this reason its safer to disable a feat=
ure
+when its dependencies are not met instead of forcing the dependency on=
=2E
+
+This callback should not modify hardware nor driver state (should be
+stateless).  It can be called multiple times between successive
+ndo_set_features calls.
+
+Callback must not alter features contained in NETIF_F_SOFT_FEATURES or
+NETIF_F_NEVER_CHANGE sets. The exception is NETIF_F_VLAN_CHALLENGED bu=
t
+care must be taken as the change won't affect already configured VLANs=
=2E
+
+ * ndo_set_features:
+
+Hardware should be reconfigured to match passed feature set. The shoul=
d not
+be altered unless some error condition happens that can't be reliably
+detected in ndo_fix_features. In this case, the callback should update
+netdev->features to match resulting hardware state. Errors returned ar=
e
+not (and cannot be) propagated anywhere except dmesg. (Note: successfu=
l
+return is zero, >0 is silent error.)=20
+
+
+
+ Part IV: Features
+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
+
+For current list of features, see include/linux/netdev_features.h.
+This section describes semantics of some of them.
+
+ * Transmit checksumming
+
+For complete description, see comments near the top of include/linux/s=
kbuff.h.
+
+Note: NETIF_F_HW_CSUM is a superset of NETIF_F_IP_CSUM + NETIF_F_IPV6_=
CSUM.
+It means that device can fill TCP/UDP-like checksum anywhere in the pa=
ckets
+whatever headers there might be.
+
+ * Transmit TCP segmentation offload
+
+NETIF_F_TSO_ECN means that hardware can properly split packets with CW=
R bit
+set, be it TCPv4 (when NETIF_F_TSO is enabled) or TCPv6 (NETIF_F_TSO6)=
=2E
+
+ * Transmit DMA from high memory
+
+On platforms where this is relevant, NETIF_F_HIGHDMA signals that
+ndo_start_xmit can handle skbs with frags in high memory.
+
+ * Transmit scatter-gather
+
+Those features say that ndo_start_xmit can handle fragmented skbs:
+NETIF_F_SG --- paged skbs (skb_shinfo()->frags), NETIF_F_FRAGLIST ---
+chained skbs (skb->next/prev list).
+
+ * Software features
+
+Features contained in NETIF_F_SOFT_FEATURES are a features of networki=
ng
+stack. Driver should not change behaviour based on them.
+
+ * LLTX driver (deprecated for hardware drivers)
+
+NETIF_F_LLTX should be set in drivers that implement their own locking=
 in
+transmit path or don't need locking at all (e.g. software tunnels).
+In ndo_start_xmit, it is recommended to use a try_lock and return
+NETDEV_TX_LOCKED when the spin lock fails.  The locking should also pr=
operly
+protect against other callbacks (the rules you need to find out).
+
+Don't use it for new drivers.
+
+ * netns-local device
+
+NETIF_F_NETNS_LOCAL is set for devices that are not allowed to move be=
tween
+network namespaces (e.g. loopback).
+
+Don't use it in drivers.
+
+ * VLAN challenged
+
+NETIF_F_VLAN_CHALLENGED should be set for devices which can't cope wit=
h VLAN
+headers. Some drivers set this because the cards can't handle the bigg=
er MTU.
+[FIXME: Those cases could be fixed in VLAN code by allowing only reduc=
ed-MTU
+VLANs. This may be not usefull, though.]
+
--=20
1.7.5.4

