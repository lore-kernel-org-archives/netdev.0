From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 4/5] fou: add network namespace support
Date: Mon,  6 Apr 2015 16:41:29 -0700
Message-ID: <1428363690-16288-5-git-send-email-xiyou.wangcong@gmail.com>
References: <1428363690-16288-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Tom Herbert <therbert@google.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:35150 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753010AbbDFXlp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2015 19:41:45 -0400
Received: by pddn5 with SMTP id n5so59386262pdd.2
        for <netdev@vger.kernel.org>; Mon, 06 Apr 2015 16:41:45 -0700 (PDT)
In-Reply-To: <1428363690-16288-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also convert the spinlock to a mutex.

Cc: Tom Herbert <therbert@google.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv4/fou.c | 106 ++++++++++++++++++++++++++++++++++++---------------------
 1 file changed, 67 insertions(+), 39 deletions(-)

diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index cf606fc..61ce417 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -16,9 +16,6 @@
 #include <uapi/linux/fou.h>
 #include <uapi/linux/genetlink.h>
 
-static DEFINE_SPINLOCK(fou_lock);
-static LIST_HEAD(fou_list);
-
 struct fou {
 	struct socket *sock;
 	u8 protocol;
@@ -37,6 +34,13 @@ struct fou_cfg {
 	struct udp_port_cfg udp_config;
 };
 
+static unsigned int fou_net_id;
+
+struct fou_net {
+	struct list_head fou_list;
+	struct mutex fou_lock;
+};
+
 static inline struct fou *fou_from_sock(struct sock *sk)
 {
 	return sk->sk_user_data;
@@ -387,20 +391,21 @@ static int gue_gro_complete(struct sk_buff *skb, int nhoff,
 	return err;
 }
 
-static int fou_add_to_port_list(struct fou *fou)
+static int fou_add_to_port_list(struct net *net, struct fou *fou)
 {
+	struct fou_net *fn = net_generic(net, fou_net_id);
 	struct fou *fout;
 
-	spin_lock(&fou_lock);
-	list_for_each_entry(fout, &fou_list, list) {
+	mutex_lock(&fn->fou_lock);
+	list_for_each_entry(fout, &fn->fou_list, list) {
 		if (fou->port == fout->port) {
-			spin_unlock(&fou_lock);
+			mutex_unlock(&fn->fou_lock);
 			return -EALREADY;
 		}
 	}
 
-	list_add(&fou->list, &fou_list);
-	spin_unlock(&fou_lock);
+	list_add(&fou->list, &fn->fou_list);
+	mutex_unlock(&fn->fou_lock);
 
 	return 0;
 }
@@ -412,13 +417,8 @@ static void fou_release(struct fou *fou)
 
 	if (sk->sk_family == AF_INET)
 		udp_del_offload(&fou->udp_offloads);
-
 	list_del(&fou->list);
-
-	/* Remove hooks into tunnel socket */
-	sk->sk_user_data = NULL;
-
-	sock_release(sock);
+	udp_tunnel_sock_release(sock);
 
 	kfree(fou);
 }
@@ -448,10 +448,10 @@ static int gue_encap_init(struct sock *sk, struct fou *fou, struct fou_cfg *cfg)
 static int fou_create(struct net *net, struct fou_cfg *cfg,
 		      struct socket **sockp)
 {
-	struct fou *fou = NULL;
-	int err;
 	struct socket *sock = NULL;
+	struct fou *fou = NULL;
 	struct sock *sk;
+	int err;
 
 	/* Open UDP socket */
 	err = udp_sock_create(net, &cfg->udp_config, &sock);
@@ -503,7 +503,7 @@ static int fou_create(struct net *net, struct fou_cfg *cfg,
 			goto error;
 	}
 
-	err = fou_add_to_port_list(fou);
+	err = fou_add_to_port_list(net, fou);
 	if (err)
 		goto error;
 
@@ -515,26 +515,27 @@ static int fou_create(struct net *net, struct fou_cfg *cfg,
 error:
 	kfree(fou);
 	if (sock)
-		sock_release(sock);
+		udp_tunnel_sock_release(sock);
 
 	return err;
 }
 
 static int fou_destroy(struct net *net, struct fou_cfg *cfg)
 {
-	struct fou *fou;
+	struct fou_net *fn = net_generic(net, fou_net_id);
 	u16 port = ntohs(cfg->udp_config.local_udp_port);
 	int err = -EINVAL;
+	struct fou *fou;
 
-	spin_lock(&fou_lock);
-	list_for_each_entry(fou, &fou_list, list) {
+	mutex_lock(&fn->fou_lock);
+	list_for_each_entry(fou, &fn->fou_list, list) {
 		if (fou->port == port) {
 			fou_release(fou);
 			err = 0;
 			break;
 		}
 	}
-	spin_unlock(&fou_lock);
+	mutex_unlock(&fn->fou_lock);
 
 	return err;
 }
@@ -592,6 +593,7 @@ static int parse_nl_config(struct genl_info *info,
 
 static int fou_nl_cmd_add_port(struct sk_buff *skb, struct genl_info *info)
 {
+	struct net *net = genl_info_net(info);
 	struct fou_cfg cfg;
 	int err;
 
@@ -599,11 +601,12 @@ static int fou_nl_cmd_add_port(struct sk_buff *skb, struct genl_info *info)
 	if (err)
 		return err;
 
-	return fou_create(&init_net, &cfg, NULL);
+	return fou_create(net, &cfg, NULL);
 }
 
 static int fou_nl_cmd_rm_port(struct sk_buff *skb, struct genl_info *info)
 {
+	struct net *net = genl_info_net(info);
 	struct fou_cfg cfg;
 	int err;
 
@@ -611,7 +614,7 @@ static int fou_nl_cmd_rm_port(struct sk_buff *skb, struct genl_info *info)
 	if (err)
 		return err;
 
-	return fou_destroy(&init_net, &cfg);
+	return fou_destroy(net, &cfg);
 }
 
 static const struct genl_ops fou_nl_ops[] = {
@@ -823,38 +826,63 @@ static void ip_tunnel_encap_del_fou_ops(void)
 
 #endif
 
+static __net_init int fou_init_net(struct net *net)
+{
+	struct fou_net *fn = net_generic(net, fou_net_id);
+
+	INIT_LIST_HEAD(&fn->fou_list);
+	mutex_init(&fn->fou_lock);
+	return 0;
+}
+
+static __net_exit void fou_exit_net(struct net *net)
+{
+	struct fou_net *fn = net_generic(net, fou_net_id);
+	struct fou *fou, *next;
+
+	/* Close all the FOU sockets */
+	mutex_lock(&fn->fou_lock);
+	list_for_each_entry_safe(fou, next, &fn->fou_list, list)
+		fou_release(fou);
+	mutex_unlock(&fn->fou_lock);
+}
+
+static struct pernet_operations fou_net_ops = {
+	.init = fou_init_net,
+	.exit = fou_exit_net,
+	.id   = &fou_net_id,
+	.size = sizeof(struct fou_net),
+};
+
 static int __init fou_init(void)
 {
 	int ret;
 
+	ret = register_pernet_device(&fou_net_ops);
+	if (ret)
+		goto exit;
+
 	ret = genl_register_family_with_ops(&fou_nl_family,
 					    fou_nl_ops);
-
 	if (ret < 0)
-		goto exit;
+		goto unregister;
 
 	ret = ip_tunnel_encap_add_fou_ops();
-	if (ret < 0)
-		genl_unregister_family(&fou_nl_family);
+	if (ret == 0)
+		return 0;
 
+	genl_unregister_family(&fou_nl_family);
+unregister:
+	unregister_pernet_device(&fou_net_ops);
 exit:
 	return ret;
 }
 
 static void __exit fou_fini(void)
 {
-	struct fou *fou, *next;
-
 	ip_tunnel_encap_del_fou_ops();
-
 	genl_unregister_family(&fou_nl_family);
-
-	/* Close all the FOU sockets */
-
-	spin_lock(&fou_lock);
-	list_for_each_entry_safe(fou, next, &fou_list, list)
-		fou_release(fou);
-	spin_unlock(&fou_lock);
+	unregister_pernet_device(&fou_net_ops);
 }
 
 module_init(fou_init);
-- 
1.8.3.1
