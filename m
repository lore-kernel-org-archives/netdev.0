From: James Chapman <jchapman@katalix.com>
Subject: [RFC PATCH 7/8] l2tp: add netlink APIs for L2TPv3
Date: Sun, 22 Feb 2009 17:52:20 GMT
Message-ID: <200902221752.n1MHqK7E006552@bert.katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:48304 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751472AbZBVRqf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Feb 2009 12:46:35 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.katalix.com (Postfix) with ESMTP id 1D359A620A0
	for <netdev@vger.kernel.org>; Sun, 22 Feb 2009 17:52:30 +0000 (GMT)
Received: from mail.katalix.com ([127.0.0.1])
	by localhost (mail.katalix.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id liHArZFUGBa1 for <netdev@vger.kernel.org>;
	Sun, 22 Feb 2009 17:52:21 +0000 (GMT)
Received: from bert.katalix.com (localhost.localdomain [127.0.0.1])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.katalix.com (Postfix) with ESMTPS id 3FA21A62087
	for <netdev@vger.kernel.org>; Sun, 22 Feb 2009 17:52:21 +0000 (GMT)
Received: (from james@localhost)
	by bert.katalix.com (8.14.2/8.14.2/Submit) id n1MHqK7E006552
	for netdev@vger.kernel.org; Sun, 22 Feb 2009 17:52:20 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add netlink control API for L2TP.

In L2TPv3, we need to create/delete/modify/query L2TP tunnel and
session contexts. The number of parameters is significant. So let's
use netlink. Userspace uses this API to control L2TP tunnel/session
contexts in the kernel.

Index: net-next-2.6-l2tpv3-2/net/l2tp/l2tp_netlink.c
===================================================================
--- /dev/null
+++ net-next-2.6-l2tpv3-2/net/l2tp/l2tp_netlink.c
@@ -0,0 +1,877 @@
+/*
+ * L2TP netlink layer, for management
+ *
+ * Copyright (c) 2008,2009 Katalix Systems Ltd
+ *
+ * Partly based on the IrDA nelink implementation
+ * (see net/irda/irnetlink.c) which is:
+ * Copyright (c) 2007 Samuel Ortiz <samuel@sortiz.org>
+ * which is in turn partly based on the wireless netlink code:
+ * Copyright 2006 Johannes Berg <johannes@sipsolutions.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <net/sock.h>
+#include <net/genetlink.h>
+#include <net/udp.h>
+#include <linux/in.h>
+#include <linux/udp.h>
+#include <linux/socket.h>
+#include <linux/module.h>
+#include <linux/list.h>
+#include <linux/l2tp.h>
+
+#include "l2tp_core.h"
+
+
+static struct genl_family l2tp_nl_family = {
+	.id		= GENL_ID_GENERATE,
+	.name		= L2TP_GENL_NAME,
+	.version	= L2TP_GENL_VERSION,
+	.hdrsize	= 0,
+	.maxattr	= L2TP_ATTR_MAX,
+};
+
+/* Accessed under genl lock */
+static const struct l2tp_nl_cmd_ops *l2tp_nl_cmd_ops[__L2TP_PWTYPE_MAX];
+
+static struct l2tp_session *l2tp_nl_session_find(struct genl_info *info)
+{
+	u32 tunnel_id;
+	u32 session_id;
+	char *ifname;
+	struct l2tp_tunnel *tunnel;
+	struct l2tp_session *session = NULL;
+
+	if (info->attrs[L2TP_ATTR_IFNAME]) {
+		ifname = nla_data(info->attrs[L2TP_ATTR_IFNAME]);
+		session = l2tp_session_find_by_ifname(ifname);
+	} else if ((info->attrs[L2TP_ATTR_SESSION_ID]) &&
+		   (info->attrs[L2TP_ATTR_CONN_ID])) {
+		tunnel_id = nla_get_u32(info->attrs[L2TP_ATTR_CONN_ID]);
+		session_id = nla_get_u32(info->attrs[L2TP_ATTR_SESSION_ID]);
+		tunnel = l2tp_tunnel_find(tunnel_id);
+		if (tunnel)
+			session = l2tp_session_find(tunnel, session_id);
+	}
+
+	return session;
+}
+
+static int l2tp_nl_cmd_noop(struct sk_buff *skb, struct genl_info *info)
+{
+	struct sk_buff *msg;
+	void *hdr;
+	int ret = -ENOBUFS;
+
+	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	if (!msg) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	hdr = genlmsg_put(msg, info->snd_pid, info->snd_seq,
+			  &l2tp_nl_family, 0, L2TP_CMD_NOOP);
+	if (IS_ERR(hdr)) {
+		ret = PTR_ERR(hdr);
+		goto err_out;
+	}
+
+	genlmsg_end(msg, hdr);
+
+	return genlmsg_unicast(msg, info->snd_pid);
+
+err_out:
+	nlmsg_free(msg);
+
+out:
+	return ret;
+}
+
+static int l2tp_nl_cmd_tunnel_create(struct sk_buff *skb, struct genl_info *info)
+{
+	u32 tunnel_id;
+	u32 peer_tunnel_id;
+	int proto_version;
+	int fd;
+	int ret = 0;
+	struct l2tp_tunnel_cfg cfg = { 0, };
+	struct l2tp_tunnel *tunnel;
+
+	if (!info->attrs[L2TP_ATTR_CONN_ID]) {
+		ret = -EINVAL;
+		goto out;
+	}
+	tunnel_id = nla_get_u32(info->attrs[L2TP_ATTR_CONN_ID]);
+
+	if (!info->attrs[L2TP_ATTR_PEER_CONN_ID]) {
+		ret = -EINVAL;
+		goto out;
+	}
+	peer_tunnel_id = nla_get_u32(info->attrs[L2TP_ATTR_PEER_CONN_ID]);
+
+	if (!info->attrs[L2TP_ATTR_PROTO_VERSION]) {
+		ret = -EINVAL;
+		goto out;
+	}
+	proto_version = nla_get_u8(info->attrs[L2TP_ATTR_PROTO_VERSION]);
+
+	if (!info->attrs[L2TP_ATTR_ENCAP_TYPE]) {
+		ret = -EINVAL;
+		goto out;
+	}
+	cfg.encap = nla_get_u16(info->attrs[L2TP_ATTR_ENCAP_TYPE]);
+
+	if (!info->attrs[L2TP_ATTR_FD]) {
+		ret = -EINVAL;
+		goto out;
+	}
+	fd = nla_get_u32(info->attrs[L2TP_ATTR_FD]);
+
+	if (info->attrs[L2TP_ATTR_DEBUG])
+		cfg.debug = nla_get_u32(info->attrs[L2TP_ATTR_DEBUG]);
+
+	tunnel = l2tp_tunnel_find(tunnel_id);
+	if (tunnel != NULL) {
+		ret = -EEXIST;
+		goto out;
+	}
+
+	ret = -EINVAL;
+	switch (cfg.encap) {
+	case L2TP_ENCAPTYPE_UDP:
+	case L2TP_ENCAPTYPE_IP:
+		ret = l2tp_tunnel_create(fd, proto_version, tunnel_id,
+					 peer_tunnel_id, &cfg, &tunnel);
+		break;
+	}
+
+	if (ret == 0) {
+		tunnel->nl_pid = info->snd_pid;
+		l2tp_tunnel_inc_refcount(tunnel);
+	}
+
+out:
+	return ret;
+}
+
+static int l2tp_nl_cmd_tunnel_delete(struct sk_buff *skb, struct genl_info *info)
+{
+	struct l2tp_tunnel *tunnel;
+	u32 tunnel_id;
+	int ret = 0;
+
+	if (!info->attrs[L2TP_ATTR_CONN_ID]) {
+		ret = -EINVAL;
+		goto out;
+	}
+	tunnel_id = nla_get_u32(info->attrs[L2TP_ATTR_CONN_ID]);
+
+	tunnel = l2tp_tunnel_find(tunnel_id);
+	if (tunnel == NULL) {
+		ret = -ENODEV;
+		goto out;
+	}
+
+	if (tunnel->nl_pid) {
+		tunnel->nl_pid = 0;
+		(void) l2tp_tunnel_delete(tunnel);
+	}
+
+out:
+	return ret;
+}
+
+static int l2tp_nl_cmd_tunnel_modify(struct sk_buff *skb, struct genl_info *info)
+{
+	struct l2tp_tunnel *tunnel;
+	u32 tunnel_id;
+	int ret = 0;
+
+	if (!info->attrs[L2TP_ATTR_CONN_ID]) {
+		ret = -EINVAL;
+		goto out;
+	}
+	tunnel_id = nla_get_u32(info->attrs[L2TP_ATTR_CONN_ID]);
+
+	tunnel = l2tp_tunnel_find(tunnel_id);
+	if (tunnel == NULL) {
+		ret = -ENODEV;
+		goto out;
+	}
+
+	if (info->attrs[L2TP_ATTR_DEBUG])
+		tunnel->debug = nla_get_u32(info->attrs[L2TP_ATTR_DEBUG]);
+
+out:
+	return ret;
+}
+
+static int l2tp_nl_tunnel_send(struct sk_buff *skb, u32 pid, u32 seq, int flags,
+			       struct l2tp_tunnel *tunnel)
+{
+	void *hdr;
+	struct nlattr *nest;
+	struct sock *sk = NULL;
+	struct inet_sock *inet;
+
+	hdr = genlmsg_put(skb, pid, seq, &l2tp_nl_family, flags,
+			  L2TP_CMD_TUNNEL_GET);
+	if (IS_ERR(hdr))
+		return PTR_ERR(hdr);
+
+	NLA_PUT_U8(skb, L2TP_ATTR_PROTO_VERSION, tunnel->version);
+	NLA_PUT_U32(skb, L2TP_ATTR_CONN_ID, tunnel->tunnel_id);
+	NLA_PUT_U32(skb, L2TP_ATTR_PEER_CONN_ID, tunnel->peer_tunnel_id);
+	NLA_PUT_U32(skb, L2TP_ATTR_DEBUG, tunnel->debug);
+	NLA_PUT_U16(skb, L2TP_ATTR_ENCAP_TYPE, tunnel->encap);
+
+	nest = nla_nest_start(skb, L2TP_ATTR_STATS);
+	if (nest == NULL)
+		goto nla_put_failure;
+
+	NLA_PUT_U64(skb, L2TP_ATTR_TX_PACKETS, tunnel->stats.tx_packets);
+	NLA_PUT_U64(skb, L2TP_ATTR_TX_BYTES, tunnel->stats.tx_bytes);
+	NLA_PUT_U64(skb, L2TP_ATTR_TX_ERRORS, tunnel->stats.tx_errors);
+	NLA_PUT_U64(skb, L2TP_ATTR_RX_PACKETS, tunnel->stats.rx_packets);
+	NLA_PUT_U64(skb, L2TP_ATTR_RX_BYTES, tunnel->stats.rx_bytes);
+	NLA_PUT_U64(skb, L2TP_ATTR_RX_SEQ_DISCARDS, tunnel->stats.rx_seq_discards);
+	NLA_PUT_U64(skb, L2TP_ATTR_RX_OOS_PACKETS, tunnel->stats.rx_oos_packets);
+	NLA_PUT_U64(skb, L2TP_ATTR_RX_ERRORS, tunnel->stats.rx_errors);
+	nla_nest_end(skb, nest);
+
+	sk = tunnel->sock;
+	if (!sk)
+		goto out;
+
+	inet = inet_sk(sk);
+
+	switch (tunnel->encap) {
+	case L2TP_ENCAPTYPE_UDP:
+		NLA_PUT_U16(skb, L2TP_ATTR_UDP_SPORT, inet->sport);
+		NLA_PUT_U16(skb, L2TP_ATTR_UDP_DPORT, inet->dport);
+		if (sk->sk_no_check != UDP_CSUM_NOXMIT)
+			NLA_PUT_FLAG(skb, L2TP_ATTR_UDP_CSUM);
+		/* NOBREAK */
+	case L2TP_ENCAPTYPE_IP:
+		NLA_PUT_U32(skb, L2TP_ATTR_IP_SADDR, inet->saddr);
+		NLA_PUT_U32(skb, L2TP_ATTR_IP_DADDR, inet->daddr);
+		break;
+	}
+
+out:
+	return genlmsg_end(skb, hdr);
+
+nla_put_failure:
+	genlmsg_cancel(skb, hdr);
+	return -1;
+}
+
+static int l2tp_nl_cmd_tunnel_get(struct sk_buff *skb, struct genl_info *info)
+{
+	struct l2tp_tunnel *tunnel;
+	struct sk_buff *msg;
+	u32 tunnel_id;
+	int ret = -ENOBUFS;
+
+	if (!info->attrs[L2TP_ATTR_CONN_ID]) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	tunnel_id = nla_get_u32(info->attrs[L2TP_ATTR_CONN_ID]);
+
+	tunnel = l2tp_tunnel_find(tunnel_id);
+	if (tunnel == NULL) {
+		ret = -ENODEV;
+		goto out;
+	}
+
+	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	if (!msg) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	ret = l2tp_nl_tunnel_send(msg, info->snd_pid, info->snd_seq,
+				  NLM_F_ACK, tunnel);
+	if (ret < 0)
+		goto err_out;
+
+	return genlmsg_unicast(msg, info->snd_pid);
+
+err_out:
+	nlmsg_free(msg);
+
+out:
+	return ret;
+}
+
+static int l2tp_nl_cmd_tunnel_dump(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	int tunnels_to_skip = cb->args[0];
+	struct l2tp_tunnel *tunnel;
+
+	tunnel = l2tp_tunnel_find_nth(tunnels_to_skip);
+	if (tunnel == NULL)
+		goto out;
+
+	l2tp_nl_tunnel_send(skb, NETLINK_CB(cb->skb).pid,
+			    cb->nlh->nlmsg_seq, NLM_F_MULTI,
+			    tunnel);
+
+out:
+	cb->args[0]++;
+
+	return skb->len;
+}
+
+static int l2tp_nl_cmd_session_create(struct sk_buff *skb, struct genl_info *info)
+{
+	u32 tunnel_id = 0;
+	u32 session_id;
+	u32 peer_session_id;
+	int ret = 0;
+	struct l2tp_tunnel *tunnel;
+	struct l2tp_session *session;
+	struct l2tp_session_cfg cfg = { 0, };
+
+	if (!info->attrs[L2TP_ATTR_CONN_ID]) {
+		ret = -EINVAL;
+		goto out;
+	}
+	tunnel_id = nla_get_u32(info->attrs[L2TP_ATTR_CONN_ID]);
+	tunnel = l2tp_tunnel_find(tunnel_id);
+	if (!tunnel) {
+		ret = -ENODEV;
+		goto out;
+	}
+
+	if (!info->attrs[L2TP_ATTR_SESSION_ID]) {
+		ret = -EINVAL;
+		goto out;
+	}
+	session_id = nla_get_u32(info->attrs[L2TP_ATTR_SESSION_ID]);
+	session = l2tp_session_find(tunnel, session_id);
+	if (session) {
+		ret = -EEXIST;
+		goto out;
+	}
+
+	if (!info->attrs[L2TP_ATTR_PEER_SESSION_ID]) {
+		ret = -EINVAL;
+		goto out;
+	}
+	peer_session_id = nla_get_u32(info->attrs[L2TP_ATTR_PEER_SESSION_ID]);
+
+	if (!info->attrs[L2TP_ATTR_PW_TYPE]) {
+		ret = -EINVAL;
+		goto out;
+	}
+	cfg.pw_type = nla_get_u16(info->attrs[L2TP_ATTR_PW_TYPE]);
+	if (cfg.pw_type >= __L2TP_PWTYPE_MAX) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	if (tunnel->version > 2) {
+		if (info->attrs[L2TP_ATTR_OFFSET])
+			cfg.offset = nla_get_u16(info->attrs[L2TP_ATTR_OFFSET]);
+
+		if (info->attrs[L2TP_ATTR_DATA_SEQ])
+			cfg.data_seq = nla_get_u8(info->attrs[L2TP_ATTR_DATA_SEQ]);
+
+		cfg.l2specific_type = L2TP_L2SPECTYPE_DEFAULT;
+		if (info->attrs[L2TP_ATTR_L2SPEC_TYPE])
+			cfg.l2specific_type = nla_get_u8(info->attrs[L2TP_ATTR_L2SPEC_TYPE]);
+
+		cfg.l2specific_len = 4;
+		if (info->attrs[L2TP_ATTR_L2SPEC_LEN])
+			cfg.l2specific_len = nla_get_u8(info->attrs[L2TP_ATTR_L2SPEC_LEN]);
+
+		if (info->attrs[L2TP_ATTR_COOKIE]) {
+			u16 len = nla_len(info->attrs[L2TP_ATTR_COOKIE]);
+			if (len > 8) {
+				ret = -EINVAL;
+				goto out;
+			}
+			cfg.cookie_len = len;
+			memcpy(&cfg.cookie[0], nla_data(info->attrs[L2TP_ATTR_COOKIE]), len);
+		}
+		if (info->attrs[L2TP_ATTR_PEER_COOKIE]) {
+			u16 len = nla_len(info->attrs[L2TP_ATTR_PEER_COOKIE]);
+			if (len > 8) {
+				ret = -EINVAL;
+				goto out;
+			}
+			cfg.peer_cookie_len = len;
+			memcpy(&cfg.peer_cookie[0], nla_data(info->attrs[L2TP_ATTR_PEER_COOKIE]), len);
+		}
+		if (info->attrs[L2TP_ATTR_IFNAME])
+			cfg.ifname = nla_data(info->attrs[L2TP_ATTR_IFNAME]);
+
+		if (info->attrs[L2TP_ATTR_VLAN_ID])
+			cfg.vlan_id = nla_get_u16(info->attrs[L2TP_ATTR_VLAN_ID]);
+	}
+
+	if (info->attrs[L2TP_ATTR_DEBUG])
+		cfg.debug = nla_get_u32(info->attrs[L2TP_ATTR_DEBUG]);
+
+	if (info->attrs[L2TP_ATTR_RECV_SEQ])
+		cfg.recv_seq = nla_get_flag(info->attrs[L2TP_ATTR_RECV_SEQ]);
+
+	if (info->attrs[L2TP_ATTR_SEND_SEQ])
+		cfg.send_seq = nla_get_flag(info->attrs[L2TP_ATTR_SEND_SEQ]);
+
+	if (info->attrs[L2TP_ATTR_LNS_MODE])
+		cfg.lns_mode = nla_get_flag(info->attrs[L2TP_ATTR_LNS_MODE]);
+
+	if (info->attrs[L2TP_ATTR_RECV_TIMEOUT])
+		cfg.reorder_timeout = nla_get_msecs(info->attrs[L2TP_ATTR_RECV_TIMEOUT]);
+
+	if (info->attrs[L2TP_ATTR_MTU])
+		cfg.mtu = nla_get_u16(info->attrs[L2TP_ATTR_MTU]);
+
+	if (info->attrs[L2TP_ATTR_MRU])
+		cfg.mru = nla_get_u16(info->attrs[L2TP_ATTR_MRU]);
+
+	if ((l2tp_nl_cmd_ops[cfg.pw_type] == NULL) ||
+	    (l2tp_nl_cmd_ops[cfg.pw_type]->session_create == NULL)) {
+		ret = -EPROTONOSUPPORT;
+		goto out;
+	}
+
+	/* Check that pseudowire-specific params are present */
+	switch (cfg.pw_type) {
+	case L2TP_PWTYPE_NONE:
+		break;
+	case L2TP_PWTYPE_ETH_VLAN:
+		if (!info->attrs[L2TP_ATTR_VLAN_ID]) {
+			ret = -EINVAL;
+			goto out;
+		}
+		break;
+	case L2TP_PWTYPE_ETH:
+		break;
+	case L2TP_PWTYPE_PPP:
+	case L2TP_PWTYPE_PPP_AC:
+		break;
+	case L2TP_PWTYPE_IP:
+	default:
+		ret = -EPROTONOSUPPORT;
+		break;
+	}
+
+	ret = -EPROTONOSUPPORT;
+	if (l2tp_nl_cmd_ops[cfg.pw_type]->session_create)
+		ret = (*l2tp_nl_cmd_ops[cfg.pw_type]->session_create)(tunnel_id, session_id, peer_session_id, &cfg);
+
+	session = l2tp_session_find(tunnel, session_id);
+	if ((ret == 0) && (session)) {
+		session->nl_pid = info->snd_pid;
+		l2tp_session_inc_refcount(session);
+	}
+
+out:
+	return ret;
+}
+
+static int l2tp_nl_cmd_session_delete(struct sk_buff *skb, struct genl_info *info)
+{
+	int ret = 0;
+	struct l2tp_session *session;
+	u16 pw_type;
+
+	session = l2tp_nl_session_find(info);
+	if (session == NULL) {
+		ret = -ENODEV;
+		goto out;
+	}
+
+	if (session->nl_pid) {
+		session->nl_pid = 0;
+		pw_type = session->pwtype;
+		if (pw_type < __L2TP_PWTYPE_MAX)
+			if (l2tp_nl_cmd_ops[pw_type] && l2tp_nl_cmd_ops[pw_type]->session_delete)
+				ret = (*l2tp_nl_cmd_ops[pw_type]->session_delete)(session);
+
+		l2tp_session_dec_refcount(session);
+	}
+
+out:
+	return ret;
+}
+
+static int l2tp_nl_cmd_session_modify(struct sk_buff *skb, struct genl_info *info)
+{
+	int ret = 0;
+	struct l2tp_session *session;
+
+	session = l2tp_nl_session_find(info);
+	if (session == NULL) {
+		ret = -ENODEV;
+		goto out;
+	}
+
+	if (info->attrs[L2TP_ATTR_DEBUG])
+		session->debug = nla_get_u32(info->attrs[L2TP_ATTR_DEBUG]);
+
+	if (info->attrs[L2TP_ATTR_DATA_SEQ])
+		session->data_seq = nla_get_flag(info->attrs[L2TP_ATTR_DATA_SEQ]);
+
+	if (info->attrs[L2TP_ATTR_RECV_SEQ])
+		session->recv_seq = nla_get_flag(info->attrs[L2TP_ATTR_RECV_SEQ]);
+
+	if (info->attrs[L2TP_ATTR_SEND_SEQ])
+		session->send_seq = nla_get_flag(info->attrs[L2TP_ATTR_SEND_SEQ]);
+
+	if (info->attrs[L2TP_ATTR_LNS_MODE])
+		session->lns_mode = nla_get_flag(info->attrs[L2TP_ATTR_LNS_MODE]);
+
+	if (info->attrs[L2TP_ATTR_RECV_TIMEOUT])
+		session->reorder_timeout = nla_get_msecs(info->attrs[L2TP_ATTR_RECV_TIMEOUT]);
+
+	if (info->attrs[L2TP_ATTR_MTU])
+		session->mtu = nla_get_u16(info->attrs[L2TP_ATTR_MTU]);
+
+	if (info->attrs[L2TP_ATTR_MRU])
+		session->mru = nla_get_u16(info->attrs[L2TP_ATTR_MRU]);
+
+out:
+	return ret;
+}
+
+static int l2tp_nl_session_send(struct sk_buff *skb, u32 pid, u32 seq, int flags,
+				struct l2tp_session *session)
+{
+	void *hdr;
+	struct nlattr *nest;
+	struct l2tp_tunnel *tunnel = session->tunnel;
+	char *ifname = NULL;
+	struct sock *sk = NULL;
+
+	if (session->get_info)
+		session->get_info(&ifname);
+
+	sk = tunnel->sock;
+
+	hdr = genlmsg_put(skb, pid, seq, &l2tp_nl_family, flags, L2TP_CMD_SESSION_GET);
+	if (IS_ERR(hdr))
+		return PTR_ERR(hdr);
+
+	NLA_PUT_U32(skb, L2TP_ATTR_CONN_ID, tunnel->tunnel_id);
+	NLA_PUT_U32(skb, L2TP_ATTR_SESSION_ID, session->session_id);
+	NLA_PUT_U32(skb, L2TP_ATTR_PEER_CONN_ID, tunnel->peer_tunnel_id);
+	NLA_PUT_U32(skb, L2TP_ATTR_PEER_SESSION_ID, session->peer_session_id);
+	NLA_PUT_U32(skb, L2TP_ATTR_DEBUG, session->debug);
+	NLA_PUT_U16(skb, L2TP_ATTR_PW_TYPE, session->pwtype);
+	NLA_PUT_U16(skb, L2TP_ATTR_MTU, session->mtu);
+	if (session->mru)
+		NLA_PUT_U16(skb, L2TP_ATTR_MRU, session->mru);
+
+	if (ifname && ifname[0])
+		NLA_PUT_STRING(skb, L2TP_ATTR_IFNAME, ifname);
+	if (session->cookie_len)
+		NLA_PUT(skb, L2TP_ATTR_COOKIE, session->cookie_len, &session->cookie[0]);
+	if (session->peer_cookie_len)
+		NLA_PUT(skb, L2TP_ATTR_PEER_COOKIE, session->peer_cookie_len, &session->peer_cookie[0]);
+	if (session->recv_seq)
+		NLA_PUT_FLAG(skb, L2TP_ATTR_RECV_SEQ);
+	if (session->send_seq)
+		NLA_PUT_FLAG(skb, L2TP_ATTR_SEND_SEQ);
+	if (session->lns_mode)
+		NLA_PUT_FLAG(skb, L2TP_ATTR_LNS_MODE);
+#ifdef CONFIG_XFRM
+	if ((sk) && (sk->sk_policy[0] || sk->sk_policy[1]))
+		NLA_PUT_FLAG(skb, L2TP_ATTR_USING_IPSEC);
+#endif
+	if (session->reorder_timeout)
+		NLA_PUT_MSECS(skb, L2TP_ATTR_RECV_TIMEOUT, session->reorder_timeout);
+
+	nest = nla_nest_start(skb, L2TP_ATTR_STATS);
+	if (nest == NULL)
+		goto nla_put_failure;
+	NLA_PUT_U64(skb, L2TP_ATTR_TX_PACKETS, session->stats.tx_packets);
+	NLA_PUT_U64(skb, L2TP_ATTR_TX_BYTES, session->stats.tx_bytes);
+	NLA_PUT_U64(skb, L2TP_ATTR_TX_ERRORS, session->stats.tx_errors);
+	NLA_PUT_U64(skb, L2TP_ATTR_RX_PACKETS, session->stats.rx_packets);
+	NLA_PUT_U64(skb, L2TP_ATTR_RX_BYTES, session->stats.rx_bytes);
+	NLA_PUT_U64(skb, L2TP_ATTR_RX_SEQ_DISCARDS, session->stats.rx_seq_discards);
+	NLA_PUT_U64(skb, L2TP_ATTR_RX_OOS_PACKETS, session->stats.rx_oos_packets);
+	NLA_PUT_U64(skb, L2TP_ATTR_RX_ERRORS, session->stats.rx_errors);
+	nla_nest_end(skb, nest);
+
+	return genlmsg_end(skb, hdr);
+
+ nla_put_failure:
+	genlmsg_cancel(skb, hdr);
+	return -1;
+}
+
+static int l2tp_nl_cmd_session_get(struct sk_buff *skb, struct genl_info *info)
+{
+	struct l2tp_session *session;
+	struct sk_buff *msg;
+	int ret;
+
+	session = l2tp_nl_session_find(info);
+	if (session == NULL) {
+		ret = -ENODEV;
+		goto out;
+	}
+
+	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	if (!msg) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	ret = l2tp_nl_session_send(msg, info->snd_pid, info->snd_seq,
+				   0, session);
+	if (ret < 0)
+		goto err_out;
+
+	return genlmsg_unicast(msg, info->snd_pid);
+
+err_out:
+	nlmsg_free(msg);
+
+out:
+	return ret;
+}
+
+static int l2tp_nl_cmd_session_dump(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	int sessions_to_skip = cb->args[0];
+	struct l2tp_session *session;
+	struct l2tp_tunnel *tunnel;
+	int tun;
+	int skipped;
+
+	for (tun = 0; /* nothing */; tun++) {
+		tunnel = l2tp_tunnel_find_nth(tun);
+		if (tunnel == NULL)
+			break;
+
+		session = l2tp_session_find_nth(tunnel, sessions_to_skip, &skipped);
+		if (session == NULL) {
+			sessions_to_skip -= skipped;
+			continue;
+		}
+
+		if (l2tp_nl_session_send(skb, NETLINK_CB(cb->skb).pid,
+					 cb->nlh->nlmsg_seq, NLM_F_MULTI,
+					 session) < 0)
+			break;
+	}
+
+	cb->args[0]++;
+
+	return skb->len;
+}
+
+static struct nla_policy l2tp_nl_policy[L2TP_ATTR_MAX + 1] = {
+	[L2TP_ATTR_NONE]		= { .type = NLA_UNSPEC, },
+	[L2TP_ATTR_PW_TYPE]		= { .type = NLA_U16, },
+	[L2TP_ATTR_ENCAP_TYPE]		= { .type = NLA_U16, },
+	[L2TP_ATTR_OFFSET]		= { .type = NLA_U16, },
+	[L2TP_ATTR_DATA_SEQ]		= { .type = NLA_U8, },
+	[L2TP_ATTR_L2SPEC_TYPE]		= { .type = NLA_U8, },
+	[L2TP_ATTR_L2SPEC_LEN]		= { .type = NLA_U8, },
+	[L2TP_ATTR_PROTO_VERSION]	= { .type = NLA_U8, },
+	[L2TP_ATTR_CONN_ID]		= { .type = NLA_U32, },
+	[L2TP_ATTR_PEER_CONN_ID]	= { .type = NLA_U32, },
+	[L2TP_ATTR_SESSION_ID]		= { .type = NLA_U32, },
+	[L2TP_ATTR_PEER_SESSION_ID]	= { .type = NLA_U32, },
+	[L2TP_ATTR_UDP_CSUM]		= { .type = NLA_FLAG, },
+	[L2TP_ATTR_VLAN_ID]		= { .type = NLA_U16, },
+	[L2TP_ATTR_DEBUG]		= { .type = NLA_U32, },
+	[L2TP_ATTR_RECV_SEQ]		= { .type = NLA_FLAG, },
+	[L2TP_ATTR_SEND_SEQ]		= { .type = NLA_FLAG, },
+	[L2TP_ATTR_LNS_MODE]		= { .type = NLA_FLAG, },
+	[L2TP_ATTR_USING_IPSEC]		= { .type = NLA_FLAG, },
+	[L2TP_ATTR_RECV_TIMEOUT]	= { .type = NLA_MSECS, },
+	[L2TP_ATTR_FD]			= { .type = NLA_U32, },
+	[L2TP_ATTR_IP_SADDR]		= { .type = NLA_U32, },
+	[L2TP_ATTR_IP_DADDR]		= { .type = NLA_U32, },
+	[L2TP_ATTR_UDP_SPORT]		= { .type = NLA_U16, },
+	[L2TP_ATTR_UDP_DPORT]		= { .type = NLA_U16, },
+	[L2TP_ATTR_MTU]			= { .type = NLA_U16, },
+	[L2TP_ATTR_MRU]			= { .type = NLA_U16, },
+	[L2TP_ATTR_STATS]		= { .type = NLA_NESTED, },
+	[L2TP_ATTR_IFNAME] = {
+		.type = NLA_NUL_STRING,
+		.len = IFNAMSIZ - 1,
+	},
+	[L2TP_ATTR_COOKIE] = {
+		.type = NLA_BINARY,
+		.len = 8,
+	},
+	[L2TP_ATTR_PEER_COOKIE] = {
+		.type = NLA_BINARY,
+		.len = 8,
+	},
+};
+
+static struct genl_ops l2tp_nl_ops[] = {
+	{
+		.cmd = L2TP_CMD_NOOP,
+		.doit = l2tp_nl_cmd_noop,
+		.policy = l2tp_nl_policy,
+		/* can be retrieved by unprivileged users */
+	},
+	{
+		.cmd = L2TP_CMD_TUNNEL_CREATE,
+		.doit = l2tp_nl_cmd_tunnel_create,
+		.policy = l2tp_nl_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
+	{
+		.cmd = L2TP_CMD_TUNNEL_DELETE,
+		.doit = l2tp_nl_cmd_tunnel_delete,
+		.policy = l2tp_nl_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
+	{
+		.cmd = L2TP_CMD_TUNNEL_MODIFY,
+		.doit = l2tp_nl_cmd_tunnel_modify,
+		.policy = l2tp_nl_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
+	{
+		.cmd = L2TP_CMD_TUNNEL_GET,
+		.doit = l2tp_nl_cmd_tunnel_get,
+		.dumpit = l2tp_nl_cmd_tunnel_dump,
+		.policy = l2tp_nl_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
+	{
+		.cmd = L2TP_CMD_SESSION_CREATE,
+		.doit = l2tp_nl_cmd_session_create,
+		.policy = l2tp_nl_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
+	{
+		.cmd = L2TP_CMD_SESSION_DELETE,
+		.doit = l2tp_nl_cmd_session_delete,
+		.policy = l2tp_nl_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
+	{
+		.cmd = L2TP_CMD_SESSION_MODIFY,
+		.doit = l2tp_nl_cmd_session_modify,
+		.policy = l2tp_nl_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
+	{
+		.cmd = L2TP_CMD_SESSION_GET,
+		.doit = l2tp_nl_cmd_session_get,
+		.dumpit = l2tp_nl_cmd_session_dump,
+		.policy = l2tp_nl_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
+};
+
+static void l2tp_nl_tunnel_cleanup(struct l2tp_tunnel *tunnel, void *arg)
+{
+	u32 nl_pid = (u32) arg;
+
+	if (tunnel->nl_pid == nl_pid) {
+		tunnel->nl_pid = 0;
+		/* Close all sessions */
+		l2tp_tunnel_closeall(tunnel);
+		l2tp_tunnel_dec_refcount(tunnel);
+	}
+}
+
+static int l2tp_nl_notify(struct notifier_block *nb, unsigned long event, void *arg)
+{
+	struct netlink_notify *nn = arg;
+
+	switch (event) {
+	case NETLINK_URELEASE:
+		l2tp_tunnel_list_walk(l2tp_nl_tunnel_cleanup, (void *) nn->pid);
+		break;
+	}
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block l2tp_nl_notifier = {
+	.notifier_call = l2tp_nl_notify,
+};
+
+int l2tp_nl_register_ops(enum l2tp_pwtype pw_type, const struct l2tp_nl_cmd_ops *ops)
+{
+	int ret;
+
+	ret = -EINVAL;
+	if (pw_type >= __L2TP_PWTYPE_MAX)
+		goto err;
+
+	genl_lock();
+	ret = -EBUSY;
+	if (l2tp_nl_cmd_ops[pw_type])
+		goto out;
+
+	l2tp_nl_cmd_ops[pw_type] = ops;
+
+out:
+	genl_unlock();
+err:
+	return 0;
+}
+EXPORT_SYMBOL_GPL(l2tp_nl_register_ops);
+
+void l2tp_nl_unregister_ops(enum l2tp_pwtype pw_type)
+{
+	if (pw_type < __L2TP_PWTYPE_MAX) {
+		genl_lock();
+		l2tp_nl_cmd_ops[pw_type] = NULL;
+		genl_unlock();
+	}
+}
+EXPORT_SYMBOL_GPL(l2tp_nl_unregister_ops);
+
+static int l2tp_nl_init(void)
+{
+	int err, i;
+
+	printk(KERN_INFO "L2TP netlink interface: %s\n", __DATE__ " " __TIME__);
+	err = genl_register_family(&l2tp_nl_family);
+	if (err)
+		return err;
+
+	for (i = 0; i < ARRAY_SIZE(l2tp_nl_ops); i++) {
+		err = genl_register_ops(&l2tp_nl_family, &l2tp_nl_ops[i]);
+		if (err)
+			goto err_out;
+	}
+
+	err = netlink_register_notifier(&l2tp_nl_notifier);
+	if (err)
+		goto err_out;
+
+	return 0;
+
+err_out:
+	genl_unregister_family(&l2tp_nl_family);
+	return err;
+}
+
+void l2tp_nl_cleanup(void)
+{
+	genl_unregister_family(&l2tp_nl_family);
+	netlink_unregister_notifier(&l2tp_nl_notifier);
+}
+
+module_init(l2tp_nl_init);
+module_exit(l2tp_nl_cleanup);
+
+MODULE_AUTHOR("James Chapman <jchapman@katalix.com>");
+MODULE_DESCRIPTION("L2TP netlink");
+MODULE_LICENSE("GPL");
+MODULE_VERSION("1.0");
Index: net-next-2.6-l2tpv3-2/include/linux/l2tp.h
===================================================================
--- net-next-2.6-l2tpv3-2.orig/include/linux/l2tp.h
+++ net-next-2.6-l2tpv3-2/include/linux/l2tp.h
@@ -11,6 +11,8 @@
 #ifdef __KERNEL__
 #include <linux/socket.h>
 #include <linux/in.h>
+#else
+#include <netinet/in.h>
 #endif
 
 #define IPPROTO_L2TP		115
@@ -21,6 +23,7 @@
  * @l2tp_addr:    protocol specific address information
  * @l2tp_conn_id: connection id of tunnel
  */
+#define __SOCK_SIZE__	16		/* sizeof(struct sockaddr)	*/
 struct sockaddr_l2tpip {
 	/* The first fields must match struct sockaddr_in */
 	sa_family_t	l2tp_family;	/* AF_INET */
@@ -35,4 +38,127 @@ struct sockaddr_l2tpip {
 			      sizeof(__u32)];
 };
 
+/*****************************************************************************
+ *  NETLINK_GENERIC netlink family.
+ *****************************************************************************/
+
+/*
+ * Commands.
+ * Valid TLVs of each command are:-
+ * TUNNEL_CREATE	- CONN_ID, pw_type, netns, ifname, ipinfo, udpinfo, udpcsum, vlanid
+ * TUNNEL_DELETE	- CONN_ID
+ * TUNNEL_MODIFY	- CONN_ID, udpcsum
+ * TUNNEL_GETSTATS	- CONN_ID, (stats)
+ * TUNNEL_GET		- CONN_ID, (...)
+ * SESSION_CREATE	- SESSION_ID, PW_TYPE, offset, data_seq, cookie, peer_cookie, offset, l2spec
+ * SESSION_DELETE	- SESSION_ID
+ * SESSION_MODIFY	- SESSION_ID, data_seq
+ * SESSION_GET		- SESSION_ID, (...)
+ * SESSION_GETSTATS	- SESSION_ID, (stats)
+ *
+ */
+enum {
+	L2TP_CMD_NOOP,
+	L2TP_CMD_TUNNEL_CREATE,
+	L2TP_CMD_TUNNEL_DELETE,
+	L2TP_CMD_TUNNEL_MODIFY,
+	L2TP_CMD_TUNNEL_GET,
+	L2TP_CMD_SESSION_CREATE,
+	L2TP_CMD_SESSION_DELETE,
+	L2TP_CMD_SESSION_MODIFY,
+	L2TP_CMD_SESSION_GET,
+	__L2TP_CMD_MAX,
+};
+
+#define  L2TP_CMD_MAX		    	(__L2TP_CMD_MAX - 1)
+
+/*
+ * ATTR types defined for L2TP
+ */
+enum {
+	L2TP_ATTR_NONE,			/* no data */
+	L2TP_ATTR_PW_TYPE,		/* u16, enum l2tp_pwtype */
+	L2TP_ATTR_ENCAP_TYPE,		/* u16, enum l2tp_encap_type */
+	L2TP_ATTR_OFFSET,		/* u16 */
+	L2TP_ATTR_DATA_SEQ,		/* u16 */
+	L2TP_ATTR_L2SPEC_TYPE,		/* u8, enum l2tp_l2spec_type */
+	L2TP_ATTR_L2SPEC_LEN,		/* u8, enum l2tp_l2spec_type */
+	L2TP_ATTR_PROTO_VERSION,	/* u8 */
+	L2TP_ATTR_IFNAME,		/* string */
+	L2TP_ATTR_CONN_ID,		/* u32 */
+	L2TP_ATTR_PEER_CONN_ID,		/* u32 */
+	L2TP_ATTR_SESSION_ID,		/* u32 */
+	L2TP_ATTR_PEER_SESSION_ID,	/* u32 */
+	L2TP_ATTR_UDP_CSUM,		/* flag */
+	L2TP_ATTR_VLAN_ID,		/* u16 */
+	L2TP_ATTR_COOKIE,		/* 0, 4 or 8 bytes */
+	L2TP_ATTR_PEER_COOKIE,		/* 0, 4 or 8 bytes */
+	L2TP_ATTR_DEBUG,		/* u32 */
+	L2TP_ATTR_RECV_SEQ,		/* flag */
+	L2TP_ATTR_SEND_SEQ,		/* flag */
+	L2TP_ATTR_LNS_MODE,		/* flag */
+	L2TP_ATTR_USING_IPSEC,		/* flag */
+	L2TP_ATTR_RECV_TIMEOUT,		/* msec */
+	L2TP_ATTR_FD,			/* int */
+	L2TP_ATTR_IP_SADDR,		/* u32 */
+	L2TP_ATTR_IP_DADDR,		/* u32 */
+	L2TP_ATTR_UDP_SPORT,		/* u16 */
+	L2TP_ATTR_UDP_DPORT,		/* u16 */
+	L2TP_ATTR_MTU,			/* u16 */
+	L2TP_ATTR_MRU,			/* u16 */
+	L2TP_ATTR_STATS,		/* nested */
+	__L2TP_ATTR_MAX,
+};
+
+#define L2TP_ATTR_MAX			(__L2TP_ATTR_MAX - 1)
+
+/* Nested in L2TP_ATTR_STATS */
+enum {
+	L2TP_ATTR_STATS_NONE,		/* no data */
+	L2TP_ATTR_TX_PACKETS,		/* u64 */
+	L2TP_ATTR_TX_BYTES,		/* u64 */
+	L2TP_ATTR_TX_ERRORS,		/* u64 */
+	L2TP_ATTR_RX_PACKETS,		/* u64 */
+	L2TP_ATTR_RX_BYTES,		/* u64 */
+	L2TP_ATTR_RX_SEQ_DISCARDS,	/* u64 */
+	L2TP_ATTR_RX_OOS_PACKETS,	/* u64 */
+	L2TP_ATTR_RX_ERRORS,		/* u64 */
+	__L2TP_ATTR_STATS_MAX,
+};
+
+#define L2TP_ATTR_STATS_MAX		(__L2TP_ATTR_STATS_MAX - 1)
+
+enum l2tp_pwtype {
+	L2TP_PWTYPE_NONE = 0x0000,
+	L2TP_PWTYPE_ETH_VLAN = 0x0004,
+	L2TP_PWTYPE_ETH = 0x0005,
+	L2TP_PWTYPE_PPP = 0x0007,
+	L2TP_PWTYPE_PPP_AC = 0x0008,
+	L2TP_PWTYPE_IP = 0x000b,
+	__L2TP_PWTYPE_MAX
+};
+
+enum l2tp_l2spec_type {
+	L2TP_L2SPECTYPE_NONE,
+	L2TP_L2SPECTYPE_DEFAULT,
+};
+
+enum l2tp_encap_type {
+	L2TP_ENCAPTYPE_UDP,
+	L2TP_ENCAPTYPE_IP,
+};
+
+
+enum l2tp_seqmode {
+	L2TP_SEQ_NONE = 0,
+	L2TP_SEQ_IP = 1,
+	L2TP_SEQ_ALL = 2,
+};
+
+/*
+ * NETLINK_GENERIC related info
+ */
+#define L2TP_GENL_NAME		"l2tp"
+#define L2TP_GENL_VERSION	0x1
+
 #endif
Index: net-next-2.6-l2tpv3-2/net/l2tp/Makefile
===================================================================
--- net-next-2.6-l2tpv3-2.orig/net/l2tp/Makefile
+++ net-next-2.6-l2tpv3-2/net/l2tp/Makefile
@@ -7,3 +7,4 @@ obj-$(CONFIG_L2TP) += l2tp_core.o
 # Build l2tp as modules if L2TP is M
 obj-$(subst y,$(CONFIG_L2TP),$(CONFIG_PPPOL2TP)) += l2tp_ppp.o
 obj-$(subst y,$(CONFIG_L2TP),$(CONFIG_L2TP_IP)) += l2tp_ip.o
+obj-$(subst y,$(CONFIG_L2TP),$(CONFIG_L2TP_V3)) += l2tp_netlink.o
Index: net-next-2.6-l2tpv3-2/net/l2tp/l2tp_core.h
===================================================================
--- net-next-2.6-l2tpv3-2.orig/net/l2tp/l2tp_core.h
+++ net-next-2.6-l2tpv3-2/net/l2tp/l2tp_core.h
@@ -33,26 +33,6 @@ enum {
 	L2TP_MSG_DATA		= (1 << 3),	/* data packets */
 };
 
-enum l2tp_pwtype {
-	L2TP_PWTYPE_NONE = 0x0000,
-	L2TP_PWTYPE_ETH_VLAN = 0x0004,
-	L2TP_PWTYPE_ETH = 0x0005,
-	L2TP_PWTYPE_PPP = 0x0007,
-	L2TP_PWTYPE_PPP_AC = 0x0008,
-	L2TP_PWTYPE_IP = 0x000b,
-	__L2TP_PWTYPE_MAX
-};
-
-enum l2tp_l2spec_type {
-	L2TP_L2SPECTYPE_NONE,
-	L2TP_L2SPECTYPE_DEFAULT,
-};
-
-enum l2tp_encap_type {
-	L2TP_ENCAPTYPE_UDP,
-	L2TP_ENCAPTYPE_IP,
-};
-
 struct sk_buff;
 
 struct l2tp_stats {
@@ -126,6 +106,7 @@ struct l2tp_session {
 	atomic_t		ref_count;
 
 	char			name[32];	/* for logging */
+	char			ifname[IFNAMSIZ];
 	unsigned		data_seq:2;	/* data sequencing level
 						 * 0 => none, 1 => IP only,
 						 * 2 => all
@@ -146,12 +127,15 @@ struct l2tp_session {
 	enum l2tp_pwtype	pwtype;
 	struct l2tp_stats	stats;
 	struct hlist_node	global_hlist;	/* Global hash list node */
+	u32			nl_pid;		/* Netlink pid of creator */
 
 	int (*build_header)(struct l2tp_session *session, void *buf);
 	void (*recv_skb)(struct l2tp_session *session, struct sk_buff *skb, int data_len);
 	void (*session_close)(struct l2tp_session *session);
 	void (*ref)(struct l2tp_session *session);
 	void (*deref)(struct l2tp_session *session);
+	char *(*get_ifname)(void);
+	void (*get_info)(char **ifname);
 #ifdef CONFIG_PROC_FS
 	void (*show)(struct seq_file *m, void *priv);
 #endif
@@ -192,10 +176,16 @@ struct l2tp_tunnel {
 	void (*old_sk_destruct)(struct sock *);
 	struct sock		*sock;		/* Parent socket */
 	int			fd;
+	u32			nl_pid;		/* Netlink pid of creator */
 
 	uint8_t			priv[0];	/* private data */
 };
 
+struct l2tp_nl_cmd_ops {
+	int (*session_create)(u32 tunnel_id, u32 session_id, u32 peer_session_id, struct l2tp_session_cfg *cfg);
+	int (*session_delete)(struct l2tp_session *session);
+};
+
 static inline void *l2tp_tunnel_priv(struct l2tp_tunnel *tunnel)
 {
 	return &tunnel->priv[0];
@@ -227,10 +217,17 @@ out:
 }
 
 extern struct l2tp_session *l2tp_session_find(struct l2tp_tunnel *tunnel, u32 session_id);
+extern struct l2tp_session *l2tp_session_find_nth(struct l2tp_tunnel *tunnel, int nth, int *skipped);
+extern struct l2tp_session *l2tp_session_find_by_ifname(char *ifname);
 extern struct l2tp_tunnel *l2tp_tunnel_find(u32 tunnel_id);
+extern struct l2tp_tunnel *l2tp_tunnel_find_nth(int nth);
+extern void l2tp_tunnel_list_walk(void (*func)(struct l2tp_tunnel *tunnel, void *arg), void *arg);
+extern void l2tp_session_list_walk(void (*func)(struct l2tp_session *session, void *arg), void *arg);
 
 extern int l2tp_tunnel_create(int fd, int version, u32 tunnel_id, u32 peer_tunnel_id, struct l2tp_tunnel_cfg *cfg, struct l2tp_tunnel **tunnelp);
+extern int l2tp_tunnel_delete(struct l2tp_tunnel *tunnel);
 extern struct l2tp_session *l2tp_session_create(int priv_size, struct l2tp_tunnel *tunnel, u32 session_id, u32 peer_session_id, struct l2tp_session_cfg *cfg);
+extern int l2tp_session_delete(struct l2tp_session *session);
 extern void l2tp_tunnel_free(struct l2tp_tunnel *tunnel);
 extern void l2tp_session_free(struct l2tp_session *session);
 extern void l2tp_recv_common(struct l2tp_session *session, struct sk_buff *skb, unsigned char *ptr, unsigned char *optr, u16 hdrflags, int length, int (*payload_hook)(struct sk_buff *skb));
@@ -243,6 +240,9 @@ extern void l2tp_tunnel_destruct(struct 
 extern void l2tp_tunnel_closeall(struct l2tp_tunnel *tunnel);
 extern void l2tp_session_set_header_len(struct l2tp_session *session, int version);
 
+extern int l2tp_nl_register_ops(enum l2tp_pwtype pw_type, const struct l2tp_nl_cmd_ops *ops);
+extern void l2tp_nl_unregister_ops(enum l2tp_pwtype pw_type);
+
 /* Tunnel reference counts. Incremented per session that is added to
  * the tunnel.
  */
Index: net-next-2.6-l2tpv3-2/net/l2tp/l2tp_ppp.c
===================================================================
--- net-next-2.6-l2tpv3-2.orig/net/l2tp/l2tp_ppp.c
+++ net-next-2.6-l2tpv3-2/net/l2tp/l2tp_ppp.c
@@ -92,6 +92,7 @@
 #include <linux/hash.h>
 #include <linux/sort.h>
 #include <linux/proc_fs.h>
+#include <linux/l2tp.h>
 #include <net/net_namespace.h>
 #include <net/dst.h>
 #include <net/ip.h>
@@ -458,7 +459,6 @@ abort:
  */
 static void pppol2tp_session_close(struct l2tp_session *session)
 {
-	struct l2tp_tunnel *tunnel = session->tunnel;
 	struct pppol2tp_session *ps = l2tp_session_priv(session);
 	struct sock *sk = ps->sock;
 	struct sk_buff *skb;
@@ -469,14 +469,7 @@ static void pppol2tp_session_close(struc
 		goto out;
 
 	if (sk != NULL) {
-		/* Since we should hold the sock lock while
-		 * doing any unbinding, we need to release the
-		 * lock we're holding before taking that lock.
-		 * Hold a reference to the sock so it doesn't
-		 * disappear as we're jumping between locks.
-		 */
 		sock_hold(sk);
-		write_unlock_bh(&tunnel->hlist_lock);
 		lock_sock(sk);
 
 		if (sk->sk_state & (PPPOX_CONNECTED | PPPOX_BOUND)) {
@@ -495,8 +488,6 @@ static void pppol2tp_session_close(struc
 
 		release_sock(sk);
 		sock_put(sk);
-
-		write_lock_bh(&tunnel->hlist_lock);
 	}
 
 out:
@@ -557,6 +548,7 @@ static int pppol2tp_release(struct socke
 			kfree_skb(skb);
 			sock_put(sk);
 		}
+		sock_put(sk);
 	}
 
 	release_sock(sk);
@@ -680,18 +672,21 @@ static int pppol2tp_connect(struct socke
 	if (tunnel_id == 0)
 		goto end;
 
+	tunnel = l2tp_tunnel_find(tunnel_id);
+
 	/* Special case: create tunnel context if session_id and
 	 * peer_session_id is 0. Otherwise look up tunnel using supplied
 	 * tunnel id.
 	 */
 	if ((session_id == 0) && (peer_session_id == 0)) {
-		struct l2tp_tunnel_cfg tcfg = { 0, };
-		error = l2tp_tunnel_create(fd, ver, tunnel_id, peer_tunnel_id, &tcfg, &tunnel);
-		if (error < 0)
-			goto end;
+		if (tunnel == NULL) {
+			struct l2tp_tunnel_cfg tcfg = { 0, };
+			tcfg.encap = L2TP_ENCAPTYPE_UDP;
+			error = l2tp_tunnel_create(fd, ver, tunnel_id, peer_tunnel_id, &tcfg, &tunnel);
+			if (error < 0)
+				goto end;
+		}
 	} else {
-		tunnel = l2tp_tunnel_find(tunnel_id);
-
 		/* Error if we can't find the tunnel */
 		error = -ENOENT;
 		if (tunnel == NULL)
@@ -705,27 +700,46 @@ static int pppol2tp_connect(struct socke
 	if (tunnel->recv_payload_hook == NULL)
 		tunnel->recv_payload_hook = pppol2tp_recv_payload_hook;
 
-	/* Check that this session doesn't already exist */
-	error = -EEXIST;
+	if (tunnel->peer_tunnel_id == 0) {
+		if (ver == 2)
+			tunnel->peer_tunnel_id = sp->pppol2tp.d_tunnel;
+		else
+			tunnel->peer_tunnel_id = sp3->pppol2tp.d_tunnel;
+	}
+
+	/* Create session if it doesn't already exist. We handle the
+	 * case where a session was previously created by the netlink
+	 * interface by checking that the session doesn't already have
+	 * a socket and its tunnel socket are what we expect. If any
+	 * of those checks fail, return EEXIST to the caller.
+	 */
 	session = l2tp_session_find(tunnel, session_id);
-	if (session != NULL)
-		goto end;
+	if (session == NULL) {
+		/* Default MTU must allow space for UDP/L2TP/PPP
+		 * headers.
+		 */
+		cfg.mtu = cfg.mru = 1500 - PPPOL2TP_HEADER_OVERHEAD;
 
-	/* Default MTU values. */
-	if (cfg.mtu == 0)
-		cfg.mtu = 1500 - PPPOL2TP_HEADER_OVERHEAD;
-	if (cfg.mru == 0)
-		cfg.mru = cfg.mtu;
+		/* Allocate and initialize a new session context. */
+		session = l2tp_session_create(sizeof(struct pppol2tp_session),
+					      tunnel, session_id,
+					      peer_session_id, &cfg);
+		if (session == NULL) {
+			error = -ENOMEM;
+			goto end;
+		}
+	} else {
+		ps = l2tp_session_priv(session);
+		error = -EEXIST;
+		if (ps->sock != NULL)
+			goto end;
 
-	/* Allocate and initialize a new session context. */
-	session = l2tp_session_create(sizeof(struct pppol2tp_session),
-				      tunnel, session_id,
-				      peer_session_id, &cfg);
-	if (session == NULL) {
-		error = -ENOMEM;
-		goto end;
+		/* consistency checks */
+		if (ps->tunnel_sock != tunnel->sock)
+			goto end;
 	}
 
+	/* Associate session with its PPPoL2TP socket */
 	ps = l2tp_session_priv(session);
 	ps->owner	     = current->pid;
 	ps->sock	     = sk;
@@ -750,13 +764,6 @@ static int pppol2tp_connect(struct socke
 		dst_release(dst);
 	}
 
-	/* Get tunnel context from the tunnel socket */
-	tunnel = l2tp_sock_to_tunnel(tunnel->sock);
-	if (tunnel == NULL) {
-		error = -EBADF;
-		goto end;
-	}
-
 	/* Special case: if source & dest session_id == 0x0000, this socket is
 	 * being created to manage the tunnel. Don't add the session to the
 	 * session hash list, just set up the internal context for use by
@@ -780,7 +787,7 @@ static int pppol2tp_connect(struct socke
 
 	error = ppp_register_channel(&po->chan);
 	if (error)
-		goto end_put_tun;
+		goto end;
 
 out_no_ppp:
 	/* This is how we get the session context from the socket. */
@@ -789,14 +796,76 @@ out_no_ppp:
 	PRINTK(session->debug, PPPOL2TP_MSG_CONTROL, KERN_INFO,
 	       "%s: created\n", session->name);
 
-end_put_tun:
-	sock_put(tunnel->sock);
 end:
 	release_sock(sk);
 
 	return error;
 }
 
+/* Called when creating sessions via the netlink interface.
+ */
+static int pppol2tp_session_create(u32 tunnel_id, u32 session_id, u32 peer_session_id, struct l2tp_session_cfg *cfg)
+{
+	int error;
+	struct l2tp_tunnel *tunnel;
+	struct l2tp_session *session;
+	struct pppol2tp_session *ps;
+
+	tunnel = l2tp_tunnel_find(tunnel_id);
+
+	/* Error if we can't find the tunnel */
+	error = -ENOENT;
+	if (tunnel == NULL)
+		goto out;
+
+	/* Error if tunnel socket is not prepped */
+	if (tunnel->sock == NULL)
+		goto out;
+
+	/* Check that this session doesn't already exist */
+	error = -EEXIST;
+	session = l2tp_session_find(tunnel, session_id);
+	if (session != NULL)
+		goto out;
+
+	/* Default MTU values. */
+	if (cfg->mtu == 0)
+		cfg->mtu = 1500 - PPPOL2TP_HEADER_OVERHEAD;
+	if (cfg->mru == 0)
+		cfg->mru = cfg->mtu;
+
+	/* Allocate and initialize a new session context. */
+	error = -ENOMEM;
+	session = l2tp_session_create(sizeof(struct pppol2tp_session),
+				      tunnel, session_id,
+				      peer_session_id, cfg);
+	if (session == NULL)
+		goto out;
+
+	ps = l2tp_session_priv(session);
+	ps->tunnel_sock = tunnel->sock;
+
+	PRINTK(session->debug, PPPOL2TP_MSG_CONTROL, KERN_INFO,
+	       "%s: created\n", session->name);
+
+	error = 0;
+
+out:
+	return error;
+}
+
+/* Called when deleting sessions via the netlink interface.
+ */
+static int pppol2tp_session_delete(struct l2tp_session *session)
+{
+	struct pppol2tp_session *ps = l2tp_session_priv(session);
+
+	if (ps->sock == NULL)
+		l2tp_session_dec_refcount(session);
+
+	return 0;
+}
+
 /* getname() support.
  */
 static int pppol2tp_getname(struct socket *sock, struct sockaddr *uaddr,
@@ -1466,6 +1535,15 @@ static struct pppox_proto pppol2tp_proto
 	.ioctl		= pppol2tp_ioctl
 };
 
+#ifdef CONFIG_L2TP_V3
+
+static const struct l2tp_nl_cmd_ops pppol2tp_nl_cmd_ops = {
+	.session_create	= pppol2tp_session_create,
+	.session_delete	= pppol2tp_session_delete,
+};
+
+#endif /* CONFIG_L2TP_V3 */
+
 static int __init pppol2tp_init(void)
 {
 	int err;
@@ -1477,11 +1555,22 @@ static int __init pppol2tp_init(void)
 	if (err)
 		goto out_unregister_pppol2tp_proto;
 
+#ifdef CONFIG_L2TP_V3
+	err = l2tp_nl_register_ops(L2TP_PWTYPE_PPP, &pppol2tp_nl_cmd_ops);
+	if (err)
+		goto out_unregister_pppox;
+#endif
+
 	printk(KERN_INFO "PPPoL2TP kernel driver, %s\n",
 	       PPPOL2TP_DRV_VERSION);
 
 out:
 	return err;
+
+#ifdef CONFIG_L2TP_V3
+out_unregister_pppox:
+	unregister_pppox_proto(PX_PROTO_OL2TP);
+#endif
 out_unregister_pppol2tp_proto:
 	proto_unregister(&pppol2tp_sk_proto);
 	goto out;
@@ -1489,8 +1578,10 @@ out_unregister_pppol2tp_proto:
 
 static void __exit pppol2tp_exit(void)
 {
+#ifdef CONFIG_L2TP_V3
+	l2tp_nl_unregister_ops(L2TP_PWTYPE_PPP);
+#endif
 	unregister_pppox_proto(PX_PROTO_OL2TP);
-
 	proto_unregister(&pppol2tp_sk_proto);
 }
 
Index: net-next-2.6-l2tpv3-2/net/l2tp/l2tp_core.c
===================================================================
--- net-next-2.6-l2tpv3-2.orig/net/l2tp/l2tp_core.c
+++ net-next-2.6-l2tpv3-2/net/l2tp/l2tp_core.c
@@ -212,6 +212,77 @@ struct l2tp_session *l2tp_session_find(s
 }
 EXPORT_SYMBOL_GPL(l2tp_session_find);
 
+struct l2tp_session *l2tp_session_find_nth(struct l2tp_tunnel *tunnel, int nth, int *skipped)
+{
+	int hash;
+	struct hlist_node *walk;
+	struct l2tp_session *session;
+	struct l2tp_session *ret = NULL;
+	int count = 0;
+
+	read_lock_bh(&tunnel->hlist_lock);
+	for (hash = 0; hash < L2TP_HASH_SIZE; hash++) {
+		hlist_for_each_entry(session, walk, &tunnel->session_hlist[hash], hlist) {
+			if (++count > nth) {
+				ret = session;
+				break;
+			}
+		}
+	}
+
+	if (skipped)
+		*skipped = count;
+
+	read_unlock_bh(&tunnel->hlist_lock);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(l2tp_session_find_nth);
+
+/* Lookup a session by interface name.
+ * This is very inefficient but is only used by management interfaces.
+ */
+struct l2tp_session *l2tp_session_find_by_ifname(char *ifname)
+{
+	int hash;
+	struct hlist_node *walk;
+	struct l2tp_session *session;
+	struct l2tp_session *ret = NULL;
+
+	read_lock_bh(&l2tp_session_hlist_lock);
+	for (hash = 0; hash < L2TP_HASH_SIZE_2; hash++) {
+		hlist_for_each_entry(session, walk, &l2tp_session_hlist[hash], global_hlist) {
+			if (!strcmp(session->ifname, ifname)) {
+				ret = session;
+				break;
+			}
+		}
+	}
+
+	read_unlock_bh(&l2tp_session_hlist_lock);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(l2tp_session_find_by_ifname);
+
+/* Call a user callback for each session.
+ */
+void l2tp_session_list_walk(void (*func)(struct l2tp_session *session, void *arg), void *arg)
+{
+	int hash;
+	struct hlist_node *walk;
+	struct l2tp_session *session;
+	struct hlist_node *tmp;
+
+	read_lock_bh(&l2tp_session_hlist_lock);
+	for (hash = 0; hash < L2TP_HASH_SIZE_2; hash++) {
+		hlist_for_each_entry_safe(session, walk, tmp, &l2tp_session_hlist[hash], global_hlist) {
+			(*func)(session, arg);
+		}
+	}
+
+	read_unlock_bh(&l2tp_session_hlist_lock);
+}
+EXPORT_SYMBOL_GPL(l2tp_session_list_walk);
+
 /* Lookup a tunnel by id
  */
 struct l2tp_tunnel *l2tp_tunnel_find(u32 tunnel_id)
@@ -231,6 +302,40 @@ struct l2tp_tunnel *l2tp_tunnel_find(u32
 }
 EXPORT_SYMBOL_GPL(l2tp_tunnel_find);
 
+struct l2tp_tunnel *l2tp_tunnel_find_nth(int nth)
+{
+	struct l2tp_tunnel *tunnel;
+	struct l2tp_tunnel *ret = NULL;
+	int count = 0;
+
+	read_lock_bh(&l2tp_tunnel_list_lock);
+	list_for_each_entry(tunnel, &l2tp_tunnel_list, list) {
+		if (++count > nth) {
+			ret = tunnel;
+			break;
+		}
+	}
+
+	read_unlock_bh(&l2tp_tunnel_list_lock);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(l2tp_tunnel_find_nth);
+
+/* Call a user function for each tunnel.
+ */
+void l2tp_tunnel_list_walk(void (*func)(struct l2tp_tunnel *tunnel, void *arg), void *arg)
+{
+	struct l2tp_tunnel *tunnel = NULL;
+	struct l2tp_tunnel *tmp;
+
+	read_lock_bh(&l2tp_tunnel_list_lock);
+	list_for_each_entry_safe(tunnel, tmp, &l2tp_tunnel_list, list) {
+		(*func)(tunnel, arg);
+	}
+	read_unlock_bh(&l2tp_tunnel_list_lock);
+}
+EXPORT_SYMBOL_GPL(l2tp_tunnel_list_walk);
+
 /*****************************************************************************
  * Receive data handling
  *****************************************************************************/
@@ -707,7 +812,7 @@ int l2tp_udp_recv_core(struct l2tp_tunne
 
 	/* Find the session context */
 	session = l2tp_session_find(tunnel, session_id);
-	if (!session) {
+	if (!session || !session->recv_skb) {
 		/* Not found? Pass to userspace to deal with */
 		PRINTK(tunnel->debug, L2TP_MSG_DATA, KERN_INFO,
 		       "%s: no session found (%u/%u). Passing up.\n",
@@ -1120,12 +1225,6 @@ int l2tp_tunnel_create(int fd, int versi
 	sk = sock->sk;
 
 	/* Quick sanity checks */
-	err = -EPROTONOSUPPORT;
-	if (sk->sk_protocol != IPPROTO_UDP) {
-		printk(KERN_ERR "tunl %hu: fd %d wrong protocol, got %d, expected %d\n",
-		       tunnel_id, fd, sk->sk_protocol, IPPROTO_UDP);
-		goto err;
-	}
 	err = -EAFNOSUPPORT;
 	if (sock->ops->family != AF_INET) {
 		printk(KERN_ERR "tunl %hu: fd %d wrong family, got %d, expected %d\n",
@@ -1133,6 +1232,25 @@ int l2tp_tunnel_create(int fd, int versi
 		goto err;
 	}
 
+	switch (cfg->encap) {
+	case L2TP_ENCAPTYPE_UDP:
+		err = -EPROTONOSUPPORT;
+		if (sk->sk_protocol != IPPROTO_UDP) {
+			printk(KERN_ERR "tunl %hu: fd %d wrong protocol, got %d, expected %d\n",
+			       tunnel_id, fd, sk->sk_protocol, IPPROTO_UDP);
+			goto err;
+		}
+		break;
+	case L2TP_ENCAPTYPE_IP:
+		err = -EPROTONOSUPPORT;
+		if (sk->sk_protocol != IPPROTO_L2TP) {
+			printk(KERN_ERR "tunl %hu: fd %d wrong protocol, got %d, expected %d\n",
+			       tunnel_id, fd, sk->sk_protocol, IPPROTO_L2TP);
+			goto err;
+		}
+		break;
+	}
+
 	/* Check if this socket has already been prepped */
 	tunnel = (struct l2tp_tunnel *)sk->sk_user_data;
 	if (tunnel != NULL) {
@@ -1201,6 +1319,16 @@ err:
 }
 EXPORT_SYMBOL_GPL(l2tp_tunnel_create);
 
+/* This function is used by the netlink TUNNEL_DELETE command.
+ */
+int l2tp_tunnel_delete(struct l2tp_tunnel *tunnel)
+{
+	l2tp_tunnel_dec_refcount(tunnel);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(l2tp_tunnel_delete);
+
 /* Really kill the session.
  */
 void l2tp_session_free(struct l2tp_session *session)
@@ -1235,6 +1363,21 @@ void l2tp_session_free(struct l2tp_sessi
 }
 EXPORT_SYMBOL_GPL(l2tp_session_free);
 
+/* This function is used by the netlink SESSION_DELETE command and by
+   pseudowire modules.
+ */
+int l2tp_session_delete(struct l2tp_session *session)
+{
+	if (session->session_close != NULL)
+		(*session->session_close)(session);
+
+	l2tp_session_dec_refcount(session);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(l2tp_session_delete);
+
+
 /* We come here whenever a session's send_seq, cookie_len or
  * l2specific_len parameters are set.
  */
