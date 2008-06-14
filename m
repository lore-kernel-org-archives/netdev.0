From: "Laurent Chavey" <chavey@google.com>
Subject: [PATCH] bonding: Added Net Poll Support
Date: Fri, 13 Jun 2008 18:08:40 -0700
Message-ID: <97949e3e0806131808k345d62f6idd9c1d3916a93e16@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: ubar@us.ibm.com, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:58604 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754990AbYFNBIs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jun 2008 21:08:48 -0400
Received: from zps36.corp.google.com (zps36.corp.google.com [172.25.146.36])
	by smtp-out.google.com with ESMTP id m5E18g53006781
	for <netdev@vger.kernel.org>; Sat, 14 Jun 2008 02:08:43 +0100
Received: from wf-out-1314.google.com (wff28.prod.google.com [10.142.6.28])
	by zps36.corp.google.com with ESMTP id m5E18fps024377
	for <netdev@vger.kernel.org>; Fri, 13 Jun 2008 18:08:42 -0700
Received: by wf-out-1314.google.com with SMTP id 28so4388548wff.16
        for <netdev@vger.kernel.org>; Fri, 13 Jun 2008 18:08:41 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding poll_controller support to bonding driver. Need by netdump.

Signed-off-by: Laurent Chavey <chavey@google.com>

--- linux-2.6.25.org/drivers/net/bonding/bond_main.c    2008-04-16
19:49:44.000000000 -0700
+++ linux-2.6.25/drivers/net/bonding/bond_main.c        2008-06-13
18:00:08.000000000 -0700
@@ -5030,4 +5030,3 @@
  *  tab-width: 8
  * End:
  */
-
[chavey@chavey]%diff -Naur
linux-2.6.25.org/drivers/net/bonding/bond_main.c
linux-2.6.25/drivers/net/bonding/bond_main.c
--- linux-2.6.25.org/drivers/net/bonding/bond_main.c    2008-04-16
19:49:44.000000000 -0700
+++ linux-2.6.25/drivers/net/bonding/bond_main.c        2008-06-13
18:03:48.000000000 -0700
@@ -3659,6 +3659,26 @@

 /*-------------------------- Device entry points ----------------------------*/

+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void bond_poll_controller(struct net_device *dev)
+{
+       struct bonding *bond = netdev_priv(dev);
+       struct slave *curr = NULL;
+       int i = 0;
+
+       read_lock(&bond->lock);
+       bond_for_each_slave(bond, curr, i) {
+               if ( IS_UP(curr->dev) ) {
+                       if (curr->dev->poll_controller) {
+                               curr->dev->poll_controller(curr->dev);
+                       }
+                       break;
+               }
+       }
+       read_unlock(&bond->lock);
+}
+#endif
+
 static int bond_open(struct net_device *bond_dev)
 {
        struct bonding *bond = bond_dev->priv;
@@ -4435,6 +4455,9 @@
        bond_dev->change_mtu = bond_change_mtu;
        bond_dev->set_mac_address = bond_set_mac_address;
        bond_dev->validate_addr = NULL;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+       bond_dev->poll_controller = bond_poll_controller;
+#endif

        bond_set_mode_ops(bond, bond->params.mode);
