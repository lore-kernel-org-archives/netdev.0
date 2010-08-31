From: David Miller <davem@davemloft.net>
Subject: Re: PF_NETLINK, SOCK_DGRAM, 2 => EPROTONOSUPPORT
Date: Mon, 30 Aug 2010 19:06:19 -0700 (PDT)
Message-ID: <20100830.190619.91328359.davem@davemloft.net>
References: <alpine.LNX.2.00.1008301158360.28658@er-systems.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tv@lio96.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54494
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756187Ab0HaCGD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Aug 2010 22:06:03 -0400
In-Reply-To: <alpine.LNX.2.00.1008301158360.28658@er-systems.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Voegtle <tv@lio96.de>
Date: Mon, 30 Aug 2010 12:02:51 +0200 (CEST)

> Was this intended, that this code snippet doesn't work this way
> anymore or is this just a bug?

It's an unintended regression.

But nobody noticed it, because almost no-one uses NETLINK_USER.

This might fix it, give it a test:

netlink: Make NETLINK_USERSOCK work again.

Once we started enforcing the a nl_table[] entry exist for
a protocol, NETLINK_USERSOCK stopped working.  Add a dummy
table entry so that it works again.

Reported-by: Thomas Voegtle <tv@lio96.de>
Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 980fe4a..cd96ed3 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2102,6 +2102,26 @@ static void __net_exit netlink_net_exit(struct net *net)
 #endif
 }
 
+static void __init netlink_add_usersock_entry(void)
+{
+	unsigned long *listeners;
+	int groups = 32;
+
+	listeners = kzalloc(NLGRPSZ(groups) + sizeof(struct listeners_rcu_head),
+			    GFP_KERNEL);
+	if (!listeners)
+		panic("netlink_add_usersock_entry: Cannot allocate listneres\n");
+
+	netlink_table_grab();
+
+	nl_table[NETLINK_USERSOCK].groups = groups;
+	nl_table[NETLINK_USERSOCK].listeners = listeners;
+	nl_table[NETLINK_USERSOCK].module = THIS_MODULE;
+	nl_table[NETLINK_USERSOCK].registered = 1;
+
+	netlink_table_ungrab();
+}
+
 static struct pernet_operations __net_initdata netlink_net_ops = {
 	.init = netlink_net_init,
 	.exit = netlink_net_exit,
@@ -2150,6 +2170,8 @@ static int __init netlink_proto_init(void)
 		hash->rehash_time = jiffies;
 	}
 
+	netlink_add_usersock_entry();
+
 	sock_register(&netlink_family_ops);
 	register_pernet_subsys(&netlink_net_ops);
 	/* The netlink device handler may be needed early. */
