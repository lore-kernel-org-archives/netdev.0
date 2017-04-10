From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net-next 2/3] ipv4: Fix route handling when using l3mdev set to main table
Date: Mon, 10 Apr 2017 15:22:01 +0100
Message-ID: <1491834122-26252-3-git-send-email-rshearma@brocade.com>
References: <1491834122-26252-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, David Ahern <dsa@cumulusnetworks.com>,
        "Robert Shearman" <rshearma@brocade.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:54177 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753711AbdDJOWf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 10:22:35 -0400
In-Reply-To: <1491834122-26252-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If an l3mdev is set to use the main table then the use of the local
table is overridden. This means that when split local/main table is in
effect then local routes aren't added to the local table and so don't
respect the order of ip rules.

Fix this by assuming that no if no l3mdev is present then defaulting
to RT_TABLE_MAIN and then subsequently doing a translation from
RT_TABLE_MAIN to RT_TABLE_LOCAL.

Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
 net/ipv4/af_inet.c      |  4 +++-
 net/ipv4/fib_frontend.c | 14 +++++++++-----
 net/ipv4/raw.c          |  5 ++++-
 3 files changed, 16 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index d1a11707a126..83d54fab03f0 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -436,7 +436,7 @@ int inet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	struct net *net = sock_net(sk);
 	unsigned short snum;
 	int chk_addr_ret;
-	u32 tb_id = RT_TABLE_LOCAL;
+	u32 tb_id = RT_TABLE_MAIN;
 	int err;
 
 	/* If the socket has its own bind function then use it. (RAW) */
@@ -459,6 +459,8 @@ int inet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	}
 
 	tb_id = l3mdev_fib_table_by_index(net, sk->sk_bound_dev_if) ? : tb_id;
+	if (tb_id == RT_TABLE_MAIN)
+		tb_id = RT_TABLE_LOCAL;
 	chk_addr_ret = inet_addr_type_table(net, addr->sin_addr.s_addr, tb_id);
 
 	/* Not specified by any standard per-se, however it breaks too
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 8f2133ffc2ff..1782c35dbac0 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -248,8 +248,10 @@ EXPORT_SYMBOL(inet_addr_type);
 unsigned int inet_dev_addr_type(struct net *net, const struct net_device *dev,
 				__be32 addr)
 {
-	u32 rt_table = l3mdev_fib_table(dev) ? : RT_TABLE_LOCAL;
+	u32 rt_table = l3mdev_fib_table(dev) ? : RT_TABLE_MAIN;
 
+	if (rt_table == RT_TABLE_MAIN)
+		rt_table = RT_TABLE_LOCAL;
 	return __inet_dev_addr_type(net, dev, addr, rt_table);
 }
 EXPORT_SYMBOL(inet_dev_addr_type);
@@ -261,8 +263,10 @@ unsigned int inet_addr_type_dev_table(struct net *net,
 				      const struct net_device *dev,
 				      __be32 addr)
 {
-	u32 rt_table = l3mdev_fib_table(dev) ? : RT_TABLE_LOCAL;
+	u32 rt_table = l3mdev_fib_table(dev) ? : RT_TABLE_MAIN;
 
+	if (rt_table == RT_TABLE_MAIN)
+		rt_table = RT_TABLE_LOCAL;
 	return __inet_dev_addr_type(net, NULL, addr, rt_table);
 }
 EXPORT_SYMBOL(inet_addr_type_dev_table);
@@ -805,7 +809,7 @@ static int inet_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
 static void fib_magic(int cmd, int type, __be32 dst, int dst_len, struct in_ifaddr *ifa)
 {
 	struct net *net = dev_net(ifa->ifa_dev->dev);
-	u32 tb_id = l3mdev_fib_table(ifa->ifa_dev->dev);
+	u32 tb_id = l3mdev_fib_table(ifa->ifa_dev->dev) ? : RT_TABLE_MAIN;
 	struct fib_table *tb;
 	struct fib_config cfg = {
 		.fc_protocol = RTPROT_KERNEL,
@@ -820,8 +824,8 @@ static void fib_magic(int cmd, int type, __be32 dst, int dst_len, struct in_ifad
 		},
 	};
 
-	if (!tb_id)
-		tb_id = (type == RTN_UNICAST) ? RT_TABLE_MAIN : RT_TABLE_LOCAL;
+	if (tb_id == RT_TABLE_MAIN && type != RTN_UNICAST)
+		tb_id = RT_TABLE_LOCAL;
 
 	tb = fib_new_table(net, tb_id);
 	if (!tb)
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 8119e1f66e03..2dd7022681e6 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -699,7 +699,7 @@ static int raw_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct sockaddr_in *addr = (struct sockaddr_in *) uaddr;
-	u32 tb_id = RT_TABLE_LOCAL;
+	u32 tb_id = RT_TABLE_MAIN;
 	int ret = -EINVAL;
 	int chk_addr_ret;
 
@@ -710,6 +710,9 @@ static int raw_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 		tb_id = l3mdev_fib_table_by_index(sock_net(sk),
 						 sk->sk_bound_dev_if) ? : tb_id;
 
+	if (tb_id == RT_TABLE_MAIN)
+		tb_id = RT_TABLE_LOCAL;
+
 	chk_addr_ret = inet_addr_type_table(sock_net(sk), addr->sin_addr.s_addr,
 					    tb_id);
 
-- 
2.1.4
