From: roopa@cumulusnetworks.com
Subject: [PATCH net-next] rocker: check for BRIDGE_FLAGS_SELF in bridge setlink handler
Date: Tue,  3 Mar 2015 16:15:29 -0800
Message-ID: <1425428129-48365-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: sfeldma@gmail.com, jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33786 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756006AbbCDAPd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 19:15:33 -0500
Received: by padet14 with SMTP id et14so31881587pad.0
        for <netdev@vger.kernel.org>; Tue, 03 Mar 2015 16:15:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

With the recent addition of the NETIF_F_HW_SWITCH_OFFLOAD flag
on rocker ports, the second command (bridge link set) below will turn off
learning in the rocker hw (Scott/Jiri, need some confirmation from
you that this is indeed a problem and if the below patch is ok).

ip link set dev swp1 master br0
bridge link set dev swp1 learning off master
bridge link set dev swp1 learning_sync on self

This patch fixes rocker to ignore learning setting when 'master'
is set. This makes it possible to set/unset learning in kernel and bridge
driver independently.

The below command will continue to set learning on in both kernel and rocker
hw:
bridge link set dev swp1 learning on

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 drivers/net/ethernet/rocker/rocker.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index e5a15a4..d7c31d2 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -3769,6 +3769,9 @@ static int rocker_port_bridge_setlink(struct net_device *dev,
 	struct nlattr *attr;
 	int err;
 
+	if (flags && !(flags & BRIDGE_FLAGS_SELF))
+		return 0;
+
 	protinfo = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg),
 				   IFLA_PROTINFO);
 	if (protinfo) {
-- 
1.7.10.4
