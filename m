From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH net-next v1] bonding: Fix another case of LACPDU not sent on slave
Date: Mon, 30 Mar 2015 14:31:16 -0700
Message-ID: <1427751076-4512-1-git-send-email-maheshb@google.com>
Cc: Mahesh Bandewar <maheshb@google.com>,
	Maciej Zenczykowski <maze@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f201.google.com ([209.85.213.201]:33227 "EHLO
	mail-ig0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752752AbbC3VbU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 17:31:20 -0400
Received: by igdh15 with SMTP id h15so217484igd.0
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 14:31:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When mii-mon discovers that the link is up, it will call
bond_3ad_handle_link_change() but we forget to add the LACP_ENABLED
flag when we discover the speed and duplex for the slave link are
normal.

Change-Id: Ie8b268ecfeea0f99bf9fdcd72706c0653f9d9e49
Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/bonding/bond_3ad.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 4309b5a76708..30e8d118664b 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2436,12 +2436,15 @@ void bond_3ad_handle_link_change(struct slave *slave, char link)
 		port->actor_admin_port_key &= ~AD_SPEED_KEY_MASKS;
 		port->actor_oper_port_key = port->actor_admin_port_key |=
 			(__get_link_speed(port) << 1);
+		if (port->actor_oper_port_key & AD_DUPLEX_KEY_MASKS)
+			port->sm_vars |= AD_PORT_LACP_ENABLED;
 	} else {
 		/* link has failed */
 		port->is_enabled = false;
 		port->actor_admin_port_key &= ~AD_DUPLEX_KEY_MASKS;
 		port->actor_oper_port_key = (port->actor_admin_port_key &=
 					     ~AD_SPEED_KEY_MASKS);
+		port->sm_vars &= ~AD_PORT_LACP_ENABLED;
 	}
 	netdev_dbg(slave->bond->dev, "Port %d changed link status to %s\n",
 		   port->actor_port_number,
-- 
2.2.0.rc0.207.ga3a616c
