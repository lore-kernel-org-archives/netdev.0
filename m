From: prasad padiyar <prasad.padiyar@gmail.com>
Subject: Regarding patch: vlan: avoid a synchronize_net when parent device
 goes down
Date: Mon, 24 Apr 2017 10:40:12 +0530
Message-ID: <CALSMR3VYVN-R3dmp57GbcdGBDScvC+vECnkSAGA-F_PdQfu6bg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f170.google.com ([209.85.161.170]:34371 "EHLO
        mail-yw0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1046129AbdDXFKN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 01:10:13 -0400
Received: by mail-yw0-f170.google.com with SMTP id k11so25862800ywb.1
        for <netdev@vger.kernel.org>; Sun, 23 Apr 2017 22:10:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I had a query regarding the patch in the subject line.


>From the patch pasted below

             vlan = vlan_dev_priv(vlandev);
             if (!(vlan->flags & VLAN_FLAG_LOOSE_BINDING))
-                dev_change_flags(vlandev, flgs & ~IFF_UP);
+                list_add(&vlandev->close_list, &close_list);
+        }
+
+        dev_close_many(&close_list, false);
+
+        list_for_each_entry_safe(vlandev, tmp, &close_list, close_list) {
             netif_stacked_transfer_operstate(dev, vlandev);
+            list_del_init(&vlandev->close_list);
         }
+        list_del(&close_list);

"

             if (!(vlan->flags & VLAN_FLAG_LOOSE_BINDING))
-                dev_change_flags(vlandev, flgs & ~IFF_UP);
+                list_add(&vlandev->close_list, &close_list);
+        }
+
+        dev_close_many(&close_list, false);
+
+        list_for_each_entry_safe(vlandev, tmp, &close_list, close_list) {
             netif_stacked_transfer_operstate(dev, vlandev);
+            list_del_init(&vlandev->close_list);
         }
+        list_del(&close_list);.


i can see that dev_change_flags which was setting the vlan device to
down state in case VLAN_FLAG_LOOSE_BINDING was not enabled.
But setting the operstate when the VLAN real device goes admin down
was quite independent of VLAN_FLAG_LOOSE_BINDING.

Operstate was always getting transferred irrespective of LOOSE_BINDING flag.


But now with this patch, we see that control of transferring the
operstate is based of VLAN_FLAG_LOOSE_BINDING. If
VLAN_FLAG_LOOSE_BINDING is set then oper state is not changed as per
its real iface.


Is this the expected behavior. Does VLAN_FLAG_LOOSE_BINDING with this
patch has to control the operstate as well which was not
the case earlier without this patch. ?

Can someone share your views about this.

Kernel version: 4.4.20

patch link:
https://patchwork.ozlabs.org/patch/447837/

-- 
Regards,
Prasad
