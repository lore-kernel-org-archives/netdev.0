From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 5/5] fou: implement FOU_CMD_GET
Date: Mon,  6 Apr 2015 16:41:30 -0700
Message-ID: <1428363690-16288-6-git-send-email-xiyou.wangcong@gmail.com>
References: <1428363690-16288-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Tom Herbert <therbert@google.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34808 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753131AbbDFXlr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2015 19:41:47 -0400
Received: by pacyx8 with SMTP id yx8so58704808pac.1
        for <netdev@vger.kernel.org>; Mon, 06 Apr 2015 16:41:46 -0700 (PDT)
In-Reply-To: <1428363690-16288-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Tom Herbert <therbert@google.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/uapi/linux/fou.h |   1 +
 net/ipv4/fou.c           | 109 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 110 insertions(+)

diff --git a/include/uapi/linux/fou.h b/include/uapi/linux/fou.h
index c303588..d2947c5 100644
--- a/include/uapi/linux/fou.h
+++ b/include/uapi/linux/fou.h
@@ -25,6 +25,7 @@ enum {
 	FOU_CMD_UNSPEC,
 	FOU_CMD_ADD,
 	FOU_CMD_DEL,
+	FOU_CMD_GET,
 
 	__FOU_CMD_MAX,
 };
diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index 61ce417..23dfb3b 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -21,6 +21,7 @@ struct fou {
 	u8 protocol;
 	u8 flags;
 	u16 port;
+	u16 type;
 	struct udp_offload udp_offloads;
 	struct list_head list;
 };
@@ -487,6 +488,8 @@ static int fou_create(struct net *net, struct fou_cfg *cfg,
 		goto error;
 	}
 
+	fou->type = cfg->type;
+
 	udp_sk(sk)->encap_type = 1;
 	udp_encap_enable();
 
@@ -617,6 +620,106 @@ static int fou_nl_cmd_rm_port(struct sk_buff *skb, struct genl_info *info)
 	return fou_destroy(net, &cfg);
 }
 
+static int fou_fill_info(struct fou *fou, struct sk_buff *msg)
+{
+	if (nla_put_u8(msg, FOU_ATTR_AF, fou->sock->sk->sk_family) ||
+	    nla_put_be16(msg, FOU_ATTR_PORT, htons(fou->port)) ||
+	    nla_put_u8(msg, FOU_ATTR_IPPROTO, fou->protocol) ||
+	    nla_put_u8(msg, FOU_ATTR_TYPE, fou->type))
+		return -1;
+
+	if (fou->flags & FOU_F_REMCSUM_NOPARTIAL)
+		if (nla_put_flag(msg, FOU_ATTR_REMCSUM_NOPARTIAL))
+			return -1;
+	return 0;
+}
+
+static int fou_dump_info(struct fou *fou, u32 portid, u32 seq,
+			 u32 flags, struct sk_buff *skb, u8 cmd)
+{
+	void *hdr;
+
+	hdr = genlmsg_put(skb, portid, seq, &fou_nl_family, flags, cmd);
+	if (!hdr)
+		return -ENOMEM;
+
+	if (fou_fill_info(fou, skb) < 0)
+		goto nla_put_failure;
+
+	genlmsg_end(skb, hdr);
+	return 0;
+
+nla_put_failure:
+	genlmsg_cancel(skb, hdr);
+	return -EMSGSIZE;
+}
+
+static int fou_nl_cmd_get_port(struct sk_buff *skb, struct genl_info *info)
+{
+	struct net *net = genl_info_net(info);
+	struct fou_net *fn = net_generic(net, fou_net_id);
+	struct sk_buff *msg;
+	struct fou_cfg cfg;
+	struct fou *fout;
+	u16 port;
+	int ret;
+
+	ret = parse_nl_config(info, &cfg);
+	if (ret)
+		return ret;
+	port = ntohs(cfg.udp_config.local_udp_port);
+	if (port == 0)
+		return -EINVAL;
+
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!msg)
+		return -ENOMEM;
+
+	ret = -ESRCH;
+	mutex_lock(&fn->fou_lock);
+	list_for_each_entry(fout, &fn->fou_list, list) {
+		if (port == fout->port) {
+			ret = fou_dump_info(fout, info->snd_portid,
+					    info->snd_seq, 0, msg,
+					    info->genlhdr->cmd);
+			break;
+		}
+	}
+	mutex_unlock(&fn->fou_lock);
+	if (ret < 0)
+		goto out_free;
+
+	return genlmsg_reply(msg, info);
+
+out_free:
+	nlmsg_free(msg);
+	return ret;
+}
+
+static int fou_nl_dump(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct net *net = sock_net(skb->sk);
+	struct fou_net *fn = net_generic(net, fou_net_id);
+	struct fou *fout;
+	int idx = 0, ret;
+
+	mutex_lock(&fn->fou_lock);
+	list_for_each_entry(fout, &fn->fou_list, list) {
+		if (idx++ < cb->args[0])
+			continue;
+		ret = fou_dump_info(fout, NETLINK_CB(cb->skb).portid,
+				    cb->nlh->nlmsg_seq, NLM_F_MULTI,
+				    skb, FOU_CMD_GET);
+		if (ret)
+			goto done;
+	}
+	mutex_unlock(&fn->fou_lock);
+
+done:
+	cb->args[0] = idx;
+	return skb->len;
+}
+
 static const struct genl_ops fou_nl_ops[] = {
 	{
 		.cmd = FOU_CMD_ADD,
@@ -630,6 +733,12 @@ static const struct genl_ops fou_nl_ops[] = {
 		.policy = fou_nl_policy,
 		.flags = GENL_ADMIN_PERM,
 	},
+	{
+		.cmd = FOU_CMD_GET,
+		.doit = fou_nl_cmd_get_port,
+		.dumpit = fou_nl_dump,
+		.policy = fou_nl_policy,
+	},
 };
 
 size_t fou_encap_hlen(struct ip_tunnel_encap *e)
-- 
1.8.3.1
