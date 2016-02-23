From: Mike Manning <mmanning@brocade.com>
Subject: [PATCH net] Propagate MAC address changes to VLANs
Date: Tue, 23 Feb 2016 20:56:31 +0000
Message-ID: <56CCC77F.5050401@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:38292 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755162AbcBWU5T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 15:57:19 -0500
Received: from pps.filterd (m0000542.ppops.net [127.0.0.1])
	by mx0a-000f0801.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u1NKhgrO030586
	for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 12:57:18 -0800
Received: from brmwp-exmb12.corp.brocade.com ([208.47.132.227])
	by mx0a-000f0801.pphosted.com with ESMTP id 216re60x6f-8
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 12:57:18 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MAC address of the physical interface is only copied to the VLAN
when it is first created, resulting in an inconsistency after MAC
address changes of only newly created VLANs having an up-to-date MAC.

Continuing to inherit the MAC address unless explicitly changed for
the VLAN allows IPv6 EUI64 addresses for the VLAN to reflect the change
and thus for DAD to behave as expected for the given MAC.

Signed-off-by: Mike Manning <mmanning@brocade.com>
---
  net/8021q/vlan.c |   17 ++++++-----------
  1 file changed, 6 insertions(+), 11 deletions(-)

--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -293,15 +293,15 @@ static void vlan_sync_address(struct net

      /* vlan address was different from the old address and is equal to
       * the new address */
-    if (!ether_addr_equal(vlandev->dev_addr, vlan->real_dev_addr) &&
+    if ((vlandev->flags & IFF_UP) &&
+        !ether_addr_equal(vlandev->dev_addr, vlan->real_dev_addr) &&
          ether_addr_equal(vlandev->dev_addr, dev->dev_addr))
          dev_uc_del(dev, vlandev->dev_addr);

-    /* vlan address was equal to the old address and is different from
+    /* vlan address was equal to the old address so now also inherit
       * the new address */
-    if (ether_addr_equal(vlandev->dev_addr, vlan->real_dev_addr) &&
-        !ether_addr_equal(vlandev->dev_addr, dev->dev_addr))
-        dev_uc_add(dev, vlandev->dev_addr);
+    if (ether_addr_equal(vlandev->dev_addr, vlan->real_dev_addr))
+        ether_addr_copy(vlandev->dev_addr, dev->dev_addr);

      ether_addr_copy(vlan->real_dev_addr, dev->dev_addr);
  }
@@ -389,13 +389,8 @@ static int vlan_device_event(struct noti

      case NETDEV_CHANGEADDR:
          /* Adjust unicast filters on underlying device */
-        vlan_group_for_each_dev(grp, i, vlandev) {
-            flgs = vlandev->flags;
-            if (!(flgs & IFF_UP))
-                continue;
-
+        vlan_group_for_each_dev(grp, i, vlandev)
              vlan_sync_address(dev, vlandev);
-        }
          break;

      case NETDEV_CHANGEMTU:
