From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH] vlan: fix potential race in vlan_cleanup_module vs vlan_ioctl_handler
Date: Tue, 11 Dec 2007 13:25:11 +0300
Message-ID: <475E6587.1090306@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:37682 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751837AbXLKKZ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Dec 2007 05:25:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The vlan module cleanup function starts with

	vlan_netlink_fini();
	vlan_ioctl_set(NULL);

The first call removes all the vlan devices and
the second one closes the vlan ioctl.

AFAIS there's a tiny race window between these two
calls - after rtnl unregistered all the vlans, but 
the ioctl handler isn't set to NULL yet, user can 
manage to call this ioctl and create one vlan device, 
and that this function will later BUG_ON seeing 
non-emply hashes.

I think, that we must first close the vlan ioctl
and only after this remove all the vlans with the
vlan_netlink_fini() call.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 5b18315..4add9bd 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -124,8 +124,8 @@ static void __exit vlan_cleanup_module(void)
 {
 	int i;
 
-	vlan_netlink_fini();
 	vlan_ioctl_set(NULL);
+	vlan_netlink_fini();
 
 	/* Un-register us from receiving netdevice events */
 	unregister_netdevice_notifier(&vlan_notifier_block);
