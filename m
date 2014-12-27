From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] l2tp : multicast notification to the registered
 listeners
Date: Sat, 27 Dec 2014 10:12:39 -0800
Message-ID: <20141227101239.3ea24d70@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	Guillaume Nault <g.nault@alphalink.fr>,
	linux-api@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:47008 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750795AbaL0SMv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Dec 2014 13:12:51 -0500
Received: by mail-pa0-f54.google.com with SMTP id fb1so14870524pad.27
        for <netdev@vger.kernel.org>; Sat, 27 Dec 2014 10:12:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bill Hong <bhong@brocade.com>

Previously l2tp module did not provide any means for the user space to
get notified when tunnels/sessions are added/modified/deleted.
This change contains the following
- create a multicast group for the listeners to register.
- notify the registered listeners when the tunnels/sessions are
  created/modified/deleted.

Signed-off-by: Bill Hong <bhong@brocade.com>
Reviewed-by: Stephen Hemminger <stephen@networkplumber.org>
Reviewed-by: Sven-Thorsten Dietrich <sven@brocade.com>


--- a/include/uapi/linux/l2tp.h	2014-12-27 09:58:06.650962294 -0800
+++ b/include/uapi/linux/l2tp.h	2014-12-27 09:58:06.646962270 -0800
@@ -178,5 +178,6 @@ enum l2tp_seqmode {
  */
 #define L2TP_GENL_NAME		"l2tp"
 #define L2TP_GENL_VERSION	0x1
+#define L2TP_GENL_MCGROUP       "l2tp"
 
 #endif /* _UAPI_LINUX_L2TP_H_ */
--- a/net/l2tp/l2tp_netlink.c	2014-12-27 09:58:06.650962294 -0800
+++ b/net/l2tp/l2tp_netlink.c	2014-12-27 10:08:42.058892710 -0800
@@ -40,6 +40,18 @@ static struct genl_family l2tp_nl_family
 	.netnsok	= true,
 };
 
+static const struct genl_multicast_group l2tp_multicast_group[] = {
+	{
+		.name = L2TP_GENL_MCGROUP,
+	},
+};
+
+static int l2tp_nl_tunnel_send(struct sk_buff *skb, u32 portid, u32 seq,
+			       int flags, struct l2tp_tunnel *tunnel, u8 cmd);
+static int l2tp_nl_session_send(struct sk_buff *skb, u32 portid, u32 seq,
+				int flags, struct l2tp_session *session,
+				u8 cmd);
+
 /* Accessed under genl lock */
 static const struct l2tp_nl_cmd_ops *l2tp_nl_cmd_ops[__L2TP_PWTYPE_MAX];
 
@@ -97,6 +109,52 @@ out:
 	return ret;
 }
 
+static int l2tp_tunnel_notify(struct genl_family *family,
+			      struct genl_info *info,
+			      struct l2tp_tunnel *tunnel,
+			      u8 cmd)
+{
+	struct sk_buff *msg;
+	int ret;
+
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!msg)
+		return -ENOMEM;
+
+	ret = l2tp_nl_tunnel_send(msg, info->snd_portid, info->snd_seq,
+				  NLM_F_ACK, tunnel, cmd);
+
+	if (ret >= 0)
+		return genlmsg_multicast_allns(family, msg, 0,	0, GFP_ATOMIC);
+
+	nlmsg_free(msg);
+
+	return ret;
+}
+
+static int l2tp_session_notify(struct genl_family *family,
+			       struct genl_info *info,
+			       struct l2tp_session *session,
+			       u8 cmd)
+{
+	struct sk_buff *msg;
+	int ret;
+
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!msg)
+		return -ENOMEM;
+
+	ret = l2tp_nl_session_send(msg, info->snd_portid, info->snd_seq,
+				   NLM_F_ACK, session, cmd);
+
+	if (ret >= 0)
+		return genlmsg_multicast_allns(family, msg, 0,	0, GFP_ATOMIC);
+
+	nlmsg_free(msg);
+
+	return ret;
+}
+
 static int l2tp_nl_cmd_tunnel_create(struct sk_buff *skb, struct genl_info *info)
 {
 	u32 tunnel_id;
@@ -188,6 +246,9 @@ static int l2tp_nl_cmd_tunnel_create(str
 		break;
 	}
 
+	if (ret >= 0)
+		ret = l2tp_tunnel_notify(&l2tp_nl_family, info,
+					 tunnel, L2TP_CMD_TUNNEL_CREATE);
 out:
 	return ret;
 }
@@ -211,6 +272,9 @@ static int l2tp_nl_cmd_tunnel_delete(str
 		goto out;
 	}
 
+	l2tp_tunnel_notify(&l2tp_nl_family, info,
+			   tunnel, L2TP_CMD_TUNNEL_DELETE);
+
 	(void) l2tp_tunnel_delete(tunnel);
 
 out:
@@ -239,12 +303,15 @@ static int l2tp_nl_cmd_tunnel_modify(str
 	if (info->attrs[L2TP_ATTR_DEBUG])
 		tunnel->debug = nla_get_u32(info->attrs[L2TP_ATTR_DEBUG]);
 
+	ret = l2tp_tunnel_notify(&l2tp_nl_family, info,
+				 tunnel, L2TP_CMD_TUNNEL_MODIFY);
+
 out:
 	return ret;
 }
 
 static int l2tp_nl_tunnel_send(struct sk_buff *skb, u32 portid, u32 seq, int flags,
-			       struct l2tp_tunnel *tunnel)
+			       struct l2tp_tunnel *tunnel, u8 cmd)
 {
 	void *hdr;
 	struct nlattr *nest;
@@ -254,8 +321,7 @@ static int l2tp_nl_tunnel_send(struct sk
 	struct ipv6_pinfo *np = NULL;
 #endif
 
-	hdr = genlmsg_put(skb, portid, seq, &l2tp_nl_family, flags,
-			  L2TP_CMD_TUNNEL_GET);
+	hdr = genlmsg_put(skb, portid, seq, &l2tp_nl_family, flags, cmd);
 	if (!hdr)
 		return -EMSGSIZE;
 
@@ -359,7 +425,7 @@ static int l2tp_nl_cmd_tunnel_get(struct
 	}
 
 	ret = l2tp_nl_tunnel_send(msg, info->snd_portid, info->snd_seq,
-				  NLM_F_ACK, tunnel);
+				  NLM_F_ACK, tunnel, L2TP_CMD_TUNNEL_GET);
 	if (ret < 0)
 		goto err_out;
 
@@ -385,7 +451,7 @@ static int l2tp_nl_cmd_tunnel_dump(struc
 
 		if (l2tp_nl_tunnel_send(skb, NETLINK_CB(cb->skb).portid,
 					cb->nlh->nlmsg_seq, NLM_F_MULTI,
-					tunnel) <= 0)
+					tunnel, L2TP_CMD_TUNNEL_GET) <= 0)
 			goto out;
 
 		ti++;
@@ -539,6 +605,13 @@ static int l2tp_nl_cmd_session_create(st
 		ret = (*l2tp_nl_cmd_ops[cfg.pw_type]->session_create)(net, tunnel_id,
 			session_id, peer_session_id, &cfg);
 
+	if (ret >= 0) {
+		session = l2tp_session_find(net, tunnel, session_id);
+		if (session)
+			ret = l2tp_session_notify(&l2tp_nl_family, info, session,
+						  L2TP_CMD_SESSION_CREATE);
+	}
+
 out:
 	return ret;
 }
@@ -555,6 +628,9 @@ static int l2tp_nl_cmd_session_delete(st
 		goto out;
 	}
 
+	l2tp_session_notify(&l2tp_nl_family, info,
+			    session, L2TP_CMD_SESSION_DELETE);
+
 	pw_type = session->pwtype;
 	if (pw_type < __L2TP_PWTYPE_MAX)
 		if (l2tp_nl_cmd_ops[pw_type] && l2tp_nl_cmd_ops[pw_type]->session_delete)
@@ -601,12 +677,15 @@ static int l2tp_nl_cmd_session_modify(st
 	if (info->attrs[L2TP_ATTR_MRU])
 		session->mru = nla_get_u16(info->attrs[L2TP_ATTR_MRU]);
 
+	ret = l2tp_session_notify(&l2tp_nl_family, info,
+				  session, L2TP_CMD_SESSION_MODIFY);
+
 out:
 	return ret;
 }
 
 static int l2tp_nl_session_send(struct sk_buff *skb, u32 portid, u32 seq, int flags,
-				struct l2tp_session *session)
+				struct l2tp_session *session, u8 cmd)
 {
 	void *hdr;
 	struct nlattr *nest;
@@ -615,7 +694,7 @@ static int l2tp_nl_session_send(struct s
 
 	sk = tunnel->sock;
 
-	hdr = genlmsg_put(skb, portid, seq, &l2tp_nl_family, flags, L2TP_CMD_SESSION_GET);
+	hdr = genlmsg_put(skb, portid, seq, &l2tp_nl_family, flags, cmd);
 	if (!hdr)
 		return -EMSGSIZE;
 
@@ -699,7 +778,7 @@ static int l2tp_nl_cmd_session_get(struc
 	}
 
 	ret = l2tp_nl_session_send(msg, info->snd_portid, info->snd_seq,
-				   0, session);
+				   0, session, L2TP_CMD_SESSION_GET);
 	if (ret < 0)
 		goto err_out;
 
@@ -737,7 +816,7 @@ static int l2tp_nl_cmd_session_dump(stru
 
 		if (l2tp_nl_session_send(skb, NETLINK_CB(cb->skb).portid,
 					 cb->nlh->nlmsg_seq, NLM_F_MULTI,
-					 session) <= 0)
+					 session, L2TP_CMD_SESSION_GET) <= 0)
 			break;
 
 		si++;
@@ -896,7 +975,9 @@ EXPORT_SYMBOL_GPL(l2tp_nl_unregister_ops
 static int l2tp_nl_init(void)
 {
 	pr_info("L2TP netlink interface\n");
-	return genl_register_family_with_ops(&l2tp_nl_family, l2tp_nl_ops);
+	return genl_register_family_with_ops_groups(&l2tp_nl_family,
+						    l2tp_nl_ops,
+						    l2tp_multicast_group);
 }
 
 static void l2tp_nl_cleanup(void)
