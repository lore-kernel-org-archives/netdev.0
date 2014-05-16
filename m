From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: [PATCH net-next 10/11] ieee802154: add netlink interfaces for llsec
Date: Fri, 16 May 2014 17:46:44 +0200
Message-ID: <1400255205-9031-11-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1400255205-9031-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Cc: linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net,
	Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:40092 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753554AbaEPPu5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 11:50:57 -0400
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-9.4) with ESMTP id s4GForxS000566
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 16 May 2014 17:50:53 +0200
In-Reply-To: <1400255205-9031-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds user-visible interfaces for the llsec infrastructure.
For the added methods, the only major difference between all add/remove
implementation lies in how the specific object is parsed, and for dump
requests, how objects are written into netlink messages.

To save on boilerplate code, table dumps are routed through a helper
function that handles netlink dump state, leaving the actual dumping
code to care only about iterating over the table to be dumped and
filling netlink messages. For add/remove methods, the boilerplate
required to work is not quite as large, but still enough to also move
into a local helper.

Signed-off-by: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
---
 include/linux/nl802154.h    |   31 ++
 net/ieee802154/ieee802154.h |   19 +
 net/ieee802154/netlink.c    |   20 ++
 net/ieee802154/nl-mac.c     |  807 +++++++++++++++++++++++++++++++++++++++++++
 net/ieee802154/nl_policy.c  |   16 +
 5 files changed, 893 insertions(+)

diff --git a/include/linux/nl802154.h b/include/linux/nl802154.h
index c8d7f39..20163b9 100644
--- a/include/linux/nl802154.h
+++ b/include/linux/nl802154.h
@@ -80,6 +80,22 @@ enum {
 
 	IEEE802154_ATTR_FRAME_RETRIES,
 
+	IEEE802154_ATTR_LLSEC_ENABLED,
+	IEEE802154_ATTR_LLSEC_SECLEVEL,
+	IEEE802154_ATTR_LLSEC_KEY_MODE,
+	IEEE802154_ATTR_LLSEC_KEY_SOURCE_SHORT,
+	IEEE802154_ATTR_LLSEC_KEY_SOURCE_EXTENDED,
+	IEEE802154_ATTR_LLSEC_KEY_ID,
+	IEEE802154_ATTR_LLSEC_FRAME_COUNTER,
+	IEEE802154_ATTR_LLSEC_KEY_BYTES,
+	IEEE802154_ATTR_LLSEC_KEY_USAGE_FRAME_TYPES,
+	IEEE802154_ATTR_LLSEC_KEY_USAGE_COMMANDS,
+	IEEE802154_ATTR_LLSEC_FRAME_TYPE,
+	IEEE802154_ATTR_LLSEC_CMD_FRAME_ID,
+	IEEE802154_ATTR_LLSEC_SECLEVELS,
+	IEEE802154_ATTR_LLSEC_DEV_OVERRIDE,
+	IEEE802154_ATTR_LLSEC_DEV_KEY_MODE,
+
 	__IEEE802154_ATTR_MAX,
 };
 
@@ -134,6 +150,21 @@ enum {
 
 	IEEE802154_SET_MACPARAMS,
 
+	IEEE802154_LLSEC_GETPARAMS,
+	IEEE802154_LLSEC_SETPARAMS,
+	IEEE802154_LLSEC_LIST_KEY,
+	IEEE802154_LLSEC_ADD_KEY,
+	IEEE802154_LLSEC_DEL_KEY,
+	IEEE802154_LLSEC_LIST_DEV,
+	IEEE802154_LLSEC_ADD_DEV,
+	IEEE802154_LLSEC_DEL_DEV,
+	IEEE802154_LLSEC_LIST_DEVKEY,
+	IEEE802154_LLSEC_ADD_DEVKEY,
+	IEEE802154_LLSEC_DEL_DEVKEY,
+	IEEE802154_LLSEC_LIST_SECLEVEL,
+	IEEE802154_LLSEC_ADD_SECLEVEL,
+	IEEE802154_LLSEC_DEL_SECLEVEL,
+
 	__IEEE802154_CMD_MAX,
 };
 
diff --git a/net/ieee802154/ieee802154.h b/net/ieee802154/ieee802154.h
index 6693a5c..8b83a23 100644
--- a/net/ieee802154/ieee802154.h
+++ b/net/ieee802154/ieee802154.h
@@ -68,4 +68,23 @@ int ieee802154_list_iface(struct sk_buff *skb, struct genl_info *info);
 int ieee802154_dump_iface(struct sk_buff *skb, struct netlink_callback *cb);
 int ieee802154_set_macparams(struct sk_buff *skb, struct genl_info *info);
 
+int ieee802154_llsec_getparams(struct sk_buff *skb, struct genl_info *info);
+int ieee802154_llsec_setparams(struct sk_buff *skb, struct genl_info *info);
+int ieee802154_llsec_add_key(struct sk_buff *skb, struct genl_info *info);
+int ieee802154_llsec_del_key(struct sk_buff *skb, struct genl_info *info);
+int ieee802154_llsec_dump_keys(struct sk_buff *skb,
+			       struct netlink_callback *cb);
+int ieee802154_llsec_add_dev(struct sk_buff *skb, struct genl_info *info);
+int ieee802154_llsec_del_dev(struct sk_buff *skb, struct genl_info *info);
+int ieee802154_llsec_dump_devs(struct sk_buff *skb,
+			       struct netlink_callback *cb);
+int ieee802154_llsec_add_devkey(struct sk_buff *skb, struct genl_info *info);
+int ieee802154_llsec_del_devkey(struct sk_buff *skb, struct genl_info *info);
+int ieee802154_llsec_dump_devkeys(struct sk_buff *skb,
+				  struct netlink_callback *cb);
+int ieee802154_llsec_add_seclevel(struct sk_buff *skb, struct genl_info *info);
+int ieee802154_llsec_del_seclevel(struct sk_buff *skb, struct genl_info *info);
+int ieee802154_llsec_dump_seclevels(struct sk_buff *skb,
+				    struct netlink_callback *cb);
+
 #endif
diff --git a/net/ieee802154/netlink.c b/net/ieee802154/netlink.c
index 04b2058..26efcf4 100644
--- a/net/ieee802154/netlink.c
+++ b/net/ieee802154/netlink.c
@@ -124,6 +124,26 @@ static const struct genl_ops ieee8021154_ops[] = {
 	IEEE802154_DUMP(IEEE802154_LIST_IFACE, ieee802154_list_iface,
 			ieee802154_dump_iface),
 	IEEE802154_OP(IEEE802154_SET_MACPARAMS, ieee802154_set_macparams),
+	IEEE802154_OP(IEEE802154_LLSEC_GETPARAMS, ieee802154_llsec_getparams),
+	IEEE802154_OP(IEEE802154_LLSEC_SETPARAMS, ieee802154_llsec_setparams),
+	IEEE802154_DUMP(IEEE802154_LLSEC_LIST_KEY, NULL,
+			ieee802154_llsec_dump_keys),
+	IEEE802154_OP(IEEE802154_LLSEC_ADD_KEY, ieee802154_llsec_add_key),
+	IEEE802154_OP(IEEE802154_LLSEC_DEL_KEY, ieee802154_llsec_del_key),
+	IEEE802154_DUMP(IEEE802154_LLSEC_LIST_DEV, NULL,
+			ieee802154_llsec_dump_devs),
+	IEEE802154_OP(IEEE802154_LLSEC_ADD_DEV, ieee802154_llsec_add_dev),
+	IEEE802154_OP(IEEE802154_LLSEC_DEL_DEV, ieee802154_llsec_del_dev),
+	IEEE802154_DUMP(IEEE802154_LLSEC_LIST_DEVKEY, NULL,
+			ieee802154_llsec_dump_devkeys),
+	IEEE802154_OP(IEEE802154_LLSEC_ADD_DEVKEY, ieee802154_llsec_add_devkey),
+	IEEE802154_OP(IEEE802154_LLSEC_DEL_DEVKEY, ieee802154_llsec_del_devkey),
+	IEEE802154_DUMP(IEEE802154_LLSEC_LIST_SECLEVEL, NULL,
+			ieee802154_llsec_dump_seclevels),
+	IEEE802154_OP(IEEE802154_LLSEC_ADD_SECLEVEL,
+		      ieee802154_llsec_add_seclevel),
+	IEEE802154_OP(IEEE802154_LLSEC_DEL_SECLEVEL,
+		      ieee802154_llsec_del_seclevel),
 };
 
 static const struct genl_multicast_group ieee802154_mcgrps[] = {
diff --git a/net/ieee802154/nl-mac.c b/net/ieee802154/nl-mac.c
index cbe6b1a..7e9cc59 100644
--- a/net/ieee802154/nl-mac.c
+++ b/net/ieee802154/nl-mac.c
@@ -715,3 +715,810 @@ out:
 	dev_put(dev);
 	return rc;
 }
+
+
+
+static int
+ieee802154_llsec_parse_key_id(struct genl_info *info,
+			      struct ieee802154_llsec_key_id *desc)
+{
+	memset(desc, 0, sizeof(*desc));
+
+	if (!info->attrs[IEEE802154_ATTR_LLSEC_KEY_MODE])
+		return -EINVAL;
+
+	desc->mode = nla_get_u8(info->attrs[IEEE802154_ATTR_LLSEC_KEY_MODE]);
+
+	if (desc->mode == IEEE802154_SCF_KEY_IMPLICIT) {
+		if (!info->attrs[IEEE802154_ATTR_PAN_ID] &&
+		    !(info->attrs[IEEE802154_ATTR_SHORT_ADDR] ||
+		      info->attrs[IEEE802154_ATTR_HW_ADDR]))
+			return -EINVAL;
+
+		desc->device_addr.pan_id = nla_get_shortaddr(info->attrs[IEEE802154_ATTR_PAN_ID]);
+
+		if (info->attrs[IEEE802154_ATTR_SHORT_ADDR]) {
+			desc->device_addr.mode = IEEE802154_ADDR_SHORT;
+			desc->device_addr.short_addr = nla_get_shortaddr(info->attrs[IEEE802154_ATTR_SHORT_ADDR]);
+		} else {
+			desc->device_addr.mode = IEEE802154_ADDR_LONG;
+			desc->device_addr.extended_addr = nla_get_hwaddr(info->attrs[IEEE802154_ATTR_HW_ADDR]);
+		}
+	}
+
+	if (desc->mode != IEEE802154_SCF_KEY_IMPLICIT &&
+	    !info->attrs[IEEE802154_ATTR_LLSEC_KEY_ID])
+		return -EINVAL;
+
+	if (desc->mode == IEEE802154_SCF_KEY_SHORT_INDEX &&
+	    !info->attrs[IEEE802154_ATTR_LLSEC_KEY_SOURCE_SHORT])
+		return -EINVAL;
+
+	if (desc->mode == IEEE802154_SCF_KEY_HW_INDEX &&
+	    !info->attrs[IEEE802154_ATTR_LLSEC_KEY_SOURCE_EXTENDED])
+		return -EINVAL;
+
+	if (desc->mode != IEEE802154_SCF_KEY_IMPLICIT)
+		desc->id = nla_get_u8(info->attrs[IEEE802154_ATTR_LLSEC_KEY_ID]);
+
+	switch (desc->mode) {
+	case IEEE802154_SCF_KEY_SHORT_INDEX:
+	{
+		u32 source = nla_get_u32(info->attrs[IEEE802154_ATTR_LLSEC_KEY_SOURCE_SHORT]);
+		desc->short_source = cpu_to_le32(source);
+		break;
+	}
+	case IEEE802154_SCF_KEY_HW_INDEX:
+		desc->extended_source = nla_get_hwaddr(info->attrs[IEEE802154_ATTR_LLSEC_KEY_SOURCE_EXTENDED]);
+		break;
+	}
+
+	return 0;
+}
+
+static int
+ieee802154_llsec_fill_key_id(struct sk_buff *msg,
+			     const struct ieee802154_llsec_key_id *desc)
+{
+	if (nla_put_u8(msg, IEEE802154_ATTR_LLSEC_KEY_MODE, desc->mode))
+		return -EMSGSIZE;
+
+	if (desc->mode == IEEE802154_SCF_KEY_IMPLICIT) {
+		if (nla_put_shortaddr(msg, IEEE802154_ATTR_PAN_ID,
+				      desc->device_addr.pan_id))
+			return -EMSGSIZE;
+
+		if (desc->device_addr.mode == IEEE802154_ADDR_SHORT &&
+		    nla_put_shortaddr(msg, IEEE802154_ATTR_SHORT_ADDR,
+				      desc->device_addr.short_addr))
+			return -EMSGSIZE;
+
+		if (desc->device_addr.mode == IEEE802154_ADDR_LONG &&
+		    nla_put_hwaddr(msg, IEEE802154_ATTR_HW_ADDR,
+				   desc->device_addr.extended_addr))
+			return -EMSGSIZE;
+	}
+
+	if (desc->mode != IEEE802154_SCF_KEY_IMPLICIT &&
+	    nla_put_u8(msg, IEEE802154_ATTR_LLSEC_KEY_ID, desc->id))
+		return -EMSGSIZE;
+
+	if (desc->mode == IEEE802154_SCF_KEY_SHORT_INDEX &&
+	    nla_put_u32(msg, IEEE802154_ATTR_LLSEC_KEY_SOURCE_SHORT,
+			le32_to_cpu(desc->short_source)))
+		return -EMSGSIZE;
+
+	if (desc->mode == IEEE802154_SCF_KEY_HW_INDEX &&
+	    nla_put_hwaddr(msg, IEEE802154_ATTR_LLSEC_KEY_SOURCE_EXTENDED,
+			   desc->extended_source))
+		return -EMSGSIZE;
+
+	return 0;
+}
+
+int ieee802154_llsec_getparams(struct sk_buff *skb, struct genl_info *info)
+{
+	struct sk_buff *msg;
+	struct net_device *dev = NULL;
+	int rc = -ENOBUFS;
+	struct ieee802154_mlme_ops *ops;
+	void *hdr;
+	struct ieee802154_llsec_params params;
+
+	pr_debug("%s\n", __func__);
+
+	dev = ieee802154_nl_get_dev(info);
+	if (!dev)
+		return -ENODEV;
+
+	ops = ieee802154_mlme_ops(dev);
+	if (!ops->llsec)
+		return -EOPNOTSUPP;
+
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!msg)
+		goto out_dev;
+
+	hdr = genlmsg_put(msg, 0, info->snd_seq, &nl802154_family, 0,
+		IEEE802154_LLSEC_GETPARAMS);
+	if (!hdr)
+		goto out_free;
+
+	rc = ops->llsec->get_params(dev, &params);
+	if (rc < 0)
+		goto out_free;
+
+	if (nla_put_string(msg, IEEE802154_ATTR_DEV_NAME, dev->name) ||
+	    nla_put_u32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex) ||
+	    nla_put_u8(msg, IEEE802154_ATTR_LLSEC_ENABLED, params.enabled) ||
+	    nla_put_u8(msg, IEEE802154_ATTR_LLSEC_SECLEVEL, params.out_level) ||
+	    nla_put_u32(msg, IEEE802154_ATTR_LLSEC_FRAME_COUNTER,
+			be32_to_cpu(params.frame_counter)) ||
+	    ieee802154_llsec_fill_key_id(msg, &params.out_key))
+		goto out_free;
+
+	dev_put(dev);
+
+	return ieee802154_nl_reply(msg, info);
+out_free:
+	nlmsg_free(msg);
+out_dev:
+	dev_put(dev);
+	return rc;
+}
+
+int ieee802154_llsec_setparams(struct sk_buff *skb, struct genl_info *info)
+{
+	struct net_device *dev = NULL;
+	int rc = -EINVAL;
+	struct ieee802154_mlme_ops *ops;
+	struct ieee802154_llsec_params params;
+	int changed = 0;
+
+	pr_debug("%s\n", __func__);
+
+	dev = ieee802154_nl_get_dev(info);
+	if (!dev)
+		return -ENODEV;
+
+	if (!info->attrs[IEEE802154_ATTR_LLSEC_ENABLED] &&
+	    !info->attrs[IEEE802154_ATTR_LLSEC_KEY_MODE] &&
+	    !info->attrs[IEEE802154_ATTR_LLSEC_SECLEVEL])
+		goto out;
+
+	ops = ieee802154_mlme_ops(dev);
+	if (!ops->llsec) {
+		rc = -EOPNOTSUPP;
+		goto out;
+	}
+
+	if (info->attrs[IEEE802154_ATTR_LLSEC_SECLEVEL] &&
+	    nla_get_u8(info->attrs[IEEE802154_ATTR_LLSEC_SECLEVEL]) > 7)
+		goto out;
+
+	if (info->attrs[IEEE802154_ATTR_LLSEC_ENABLED]) {
+		params.enabled = nla_get_u8(info->attrs[IEEE802154_ATTR_LLSEC_ENABLED]);
+		changed |= IEEE802154_LLSEC_PARAM_ENABLED;
+	}
+
+	if (info->attrs[IEEE802154_ATTR_LLSEC_KEY_MODE]) {
+		if (ieee802154_llsec_parse_key_id(info, &params.out_key))
+			goto out;
+
+		changed |= IEEE802154_LLSEC_PARAM_OUT_KEY;
+	}
+
+	if (info->attrs[IEEE802154_ATTR_LLSEC_SECLEVEL]) {
+		params.out_level = nla_get_u8(info->attrs[IEEE802154_ATTR_LLSEC_SECLEVEL]);
+		changed |= IEEE802154_LLSEC_PARAM_OUT_LEVEL;
+	}
+
+	if (info->attrs[IEEE802154_ATTR_LLSEC_FRAME_COUNTER]) {
+		u32 fc = nla_get_u32(info->attrs[IEEE802154_ATTR_LLSEC_FRAME_COUNTER]);
+
+		params.frame_counter = cpu_to_be32(fc);
+		changed |= IEEE802154_LLSEC_PARAM_FRAME_COUNTER;
+	}
+
+	rc = ops->llsec->set_params(dev, &params, changed);
+
+	dev_put(dev);
+
+	return rc;
+out:
+	dev_put(dev);
+	return rc;
+}
+
+
+
+struct llsec_dump_data {
+	struct sk_buff *skb;
+	int s_idx, s_idx2;
+	int portid;
+	int nlmsg_seq;
+	struct net_device *dev;
+	struct ieee802154_mlme_ops *ops;
+	struct ieee802154_llsec_table *table;
+};
+
+static int
+ieee802154_llsec_dump_table(struct sk_buff *skb, struct netlink_callback *cb,
+			    int (*step)(struct llsec_dump_data*))
+{
+	struct net *net = sock_net(skb->sk);
+	struct net_device *dev;
+	struct llsec_dump_data data;
+	int idx = 0;
+	int first_dev = cb->args[0];
+	int rc;
+
+	for_each_netdev(net, dev) {
+		if (idx < first_dev || dev->type != ARPHRD_IEEE802154)
+			goto skip;
+
+		data.ops = ieee802154_mlme_ops(dev);
+		if (!data.ops->llsec)
+			goto skip;
+
+		data.skb = skb;
+		data.s_idx = cb->args[1];
+		data.s_idx2 = cb->args[2];
+		data.dev = dev;
+		data.portid = NETLINK_CB(cb->skb).portid;
+		data.nlmsg_seq = cb->nlh->nlmsg_seq;
+
+		data.ops->llsec->lock_table(dev);
+		data.ops->llsec->get_table(data.dev, &data.table);
+		rc = step(&data);
+		data.ops->llsec->unlock_table(dev);
+
+		if (rc < 0)
+			break;
+
+skip:
+		idx++;
+	}
+	cb->args[0] = idx;
+
+	return skb->len;
+}
+
+static int
+ieee802154_nl_llsec_change(struct sk_buff *skb, struct genl_info *info,
+			   int (*fn)(struct net_device*, struct genl_info*))
+{
+	struct net_device *dev = NULL;
+	int rc = -EINVAL;
+
+	dev = ieee802154_nl_get_dev(info);
+	if (!dev)
+		return -ENODEV;
+
+	if (!ieee802154_mlme_ops(dev)->llsec)
+		rc = -EOPNOTSUPP;
+	else
+		rc = fn(dev, info);
+
+	dev_put(dev);
+	return rc;
+}
+
+
+
+static int
+ieee802154_llsec_parse_key(struct genl_info *info,
+			   struct ieee802154_llsec_key *key)
+{
+	u8 frames;
+	u32 commands[256 / 32];
+
+	memset(key, 0, sizeof(*key));
+
+	if (!info->attrs[IEEE802154_ATTR_LLSEC_KEY_USAGE_FRAME_TYPES] ||
+	    !info->attrs[IEEE802154_ATTR_LLSEC_KEY_BYTES])
+		return -EINVAL;
+
+	frames = nla_get_u8(info->attrs[IEEE802154_ATTR_LLSEC_KEY_USAGE_FRAME_TYPES]);
+	if ((frames & BIT(IEEE802154_FC_TYPE_MAC_CMD)) &&
+	    !info->attrs[IEEE802154_ATTR_LLSEC_KEY_USAGE_COMMANDS])
+		return -EINVAL;
+
+	if (info->attrs[IEEE802154_ATTR_LLSEC_KEY_USAGE_COMMANDS]) {
+		nla_memcpy(commands,
+			   info->attrs[IEEE802154_ATTR_LLSEC_KEY_USAGE_COMMANDS],
+			   256 / 8);
+
+		if (commands[0] || commands[1] || commands[2] || commands[3] ||
+		    commands[4] || commands[5] || commands[6] ||
+		    commands[7] >= BIT(IEEE802154_CMD_GTS_REQ + 1))
+			return -EINVAL;
+
+		key->cmd_frame_ids = commands[7];
+	}
+
+	key->frame_types = frames;
+
+	nla_memcpy(key->key, info->attrs[IEEE802154_ATTR_LLSEC_KEY_BYTES],
+		   IEEE802154_LLSEC_KEY_SIZE);
+
+	return 0;
+}
+
+static int llsec_add_key(struct net_device *dev, struct genl_info *info)
+{
+	struct ieee802154_mlme_ops *ops = ieee802154_mlme_ops(dev);
+	struct ieee802154_llsec_key key;
+	struct ieee802154_llsec_key_id id;
+
+	if (ieee802154_llsec_parse_key(info, &key) ||
+	    ieee802154_llsec_parse_key_id(info, &id))
+		return -EINVAL;
+
+	return ops->llsec->add_key(dev, &id, &key);
+}
+
+int ieee802154_llsec_add_key(struct sk_buff *skb, struct genl_info *info)
+{
+	if ((info->nlhdr->nlmsg_flags & (NLM_F_CREATE | NLM_F_EXCL)) !=
+	    (NLM_F_CREATE | NLM_F_EXCL))
+		return -EINVAL;
+
+	return ieee802154_nl_llsec_change(skb, info, llsec_add_key);
+}
+
+static int llsec_remove_key(struct net_device *dev, struct genl_info *info)
+{
+	struct ieee802154_mlme_ops *ops = ieee802154_mlme_ops(dev);
+	struct ieee802154_llsec_key_id id;
+
+	if (ieee802154_llsec_parse_key_id(info, &id))
+		return -EINVAL;
+
+	return ops->llsec->del_key(dev, &id);
+}
+
+int ieee802154_llsec_del_key(struct sk_buff *skb, struct genl_info *info)
+{
+	return ieee802154_nl_llsec_change(skb, info, llsec_remove_key);
+}
+
+static int
+ieee802154_nl_fill_key(struct sk_buff *msg, u32 portid, u32 seq,
+		       const struct ieee802154_llsec_key_entry *key,
+		       const struct net_device *dev)
+{
+	void *hdr;
+	u32 commands[256 / 32];
+
+	hdr = genlmsg_put(msg, 0, seq, &nl802154_family, NLM_F_MULTI,
+			  IEEE802154_LLSEC_LIST_KEY);
+	if (!hdr)
+		goto out;
+
+	if (nla_put_string(msg, IEEE802154_ATTR_DEV_NAME, dev->name) ||
+	    nla_put_u32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex) ||
+	    ieee802154_llsec_fill_key_id(msg, &key->id) ||
+	    nla_put_u8(msg, IEEE802154_ATTR_LLSEC_KEY_USAGE_FRAME_TYPES,
+		       key->key->frame_types))
+		goto nla_put_failure;
+
+	if (key->key->frame_types & BIT(IEEE802154_FC_TYPE_MAC_CMD)) {
+		memset(commands, 0, sizeof(commands));
+		commands[7] = key->key->cmd_frame_ids;
+		if (nla_put(msg, IEEE802154_ATTR_LLSEC_KEY_USAGE_COMMANDS,
+			    sizeof(commands), commands))
+			goto nla_put_failure;
+	}
+
+	if (nla_put(msg, IEEE802154_ATTR_LLSEC_KEY_BYTES,
+		    IEEE802154_LLSEC_KEY_SIZE, key->key->key))
+		goto nla_put_failure;
+
+	genlmsg_end(msg, hdr);
+	return 0;
+
+nla_put_failure:
+	genlmsg_cancel(msg, hdr);
+out:
+	return -EMSGSIZE;
+}
+
+static int llsec_iter_keys(struct llsec_dump_data *data)
+{
+	struct ieee802154_llsec_key_entry *pos;
+	int rc = 0, idx = 0;
+
+	list_for_each_entry(pos, &data->table->keys, list) {
+		if (idx++ < data->s_idx)
+			continue;
+
+		if (ieee802154_nl_fill_key(data->skb, data->portid,
+					   data->nlmsg_seq, pos, data->dev)) {
+			rc = -EMSGSIZE;
+			break;
+		}
+
+		data->s_idx++;
+	}
+
+	return rc;
+}
+
+int ieee802154_llsec_dump_keys(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	return ieee802154_llsec_dump_table(skb, cb, llsec_iter_keys);
+}
+
+
+
+static int
+llsec_parse_dev(struct genl_info *info,
+		struct ieee802154_llsec_device *dev)
+{
+	memset(dev, 0, sizeof(*dev));
+
+	if (!info->attrs[IEEE802154_ATTR_LLSEC_FRAME_COUNTER] ||
+	    !info->attrs[IEEE802154_ATTR_HW_ADDR] ||
+	    !info->attrs[IEEE802154_ATTR_LLSEC_DEV_OVERRIDE] ||
+	    !info->attrs[IEEE802154_ATTR_LLSEC_DEV_KEY_MODE] ||
+	    (!!info->attrs[IEEE802154_ATTR_PAN_ID] !=
+	     !!info->attrs[IEEE802154_ATTR_SHORT_ADDR]))
+		return -EINVAL;
+
+	if (info->attrs[IEEE802154_ATTR_PAN_ID]) {
+		dev->pan_id = nla_get_shortaddr(info->attrs[IEEE802154_ATTR_PAN_ID]);
+		dev->short_addr = nla_get_shortaddr(info->attrs[IEEE802154_ATTR_SHORT_ADDR]);
+	} else {
+		dev->short_addr = cpu_to_le16(IEEE802154_ADDR_UNDEF);
+	}
+
+	dev->hwaddr = nla_get_hwaddr(info->attrs[IEEE802154_ATTR_HW_ADDR]);
+	dev->frame_counter = nla_get_u32(info->attrs[IEEE802154_ATTR_LLSEC_FRAME_COUNTER]);
+	dev->seclevel_exempt = !!nla_get_u8(info->attrs[IEEE802154_ATTR_LLSEC_DEV_OVERRIDE]);
+	dev->key_mode = nla_get_u8(info->attrs[IEEE802154_ATTR_LLSEC_DEV_KEY_MODE]);
+
+	if (dev->key_mode >= __IEEE802154_LLSEC_DEVKEY_MAX)
+		return -EINVAL;
+
+	return 0;
+}
+
+static int llsec_add_dev(struct net_device *dev, struct genl_info *info)
+{
+	struct ieee802154_mlme_ops *ops = ieee802154_mlme_ops(dev);
+	struct ieee802154_llsec_device desc;
+
+	if (llsec_parse_dev(info, &desc))
+		return -EINVAL;
+
+	return ops->llsec->add_dev(dev, &desc);
+}
+
+int ieee802154_llsec_add_dev(struct sk_buff *skb, struct genl_info *info)
+{
+	if ((info->nlhdr->nlmsg_flags & (NLM_F_CREATE | NLM_F_EXCL)) !=
+	    (NLM_F_CREATE | NLM_F_EXCL))
+		return -EINVAL;
+
+	return ieee802154_nl_llsec_change(skb, info, llsec_add_dev);
+}
+
+static int llsec_del_dev(struct net_device *dev, struct genl_info *info)
+{
+	struct ieee802154_mlme_ops *ops = ieee802154_mlme_ops(dev);
+	__le64 devaddr;
+
+	if (!info->attrs[IEEE802154_ATTR_HW_ADDR])
+		return -EINVAL;
+
+	devaddr = nla_get_hwaddr(info->attrs[IEEE802154_ATTR_HW_ADDR]);
+
+	return ops->llsec->del_dev(dev, devaddr);
+}
+
+int ieee802154_llsec_del_dev(struct sk_buff *skb, struct genl_info *info)
+{
+	return ieee802154_nl_llsec_change(skb, info, llsec_del_dev);
+}
+
+static int
+ieee802154_nl_fill_dev(struct sk_buff *msg, u32 portid, u32 seq,
+		       const struct ieee802154_llsec_device *desc,
+		       const struct net_device *dev)
+{
+	void *hdr;
+
+	hdr = genlmsg_put(msg, 0, seq, &nl802154_family, NLM_F_MULTI,
+			  IEEE802154_LLSEC_LIST_DEV);
+	if (!hdr)
+		goto out;
+
+	if (nla_put_string(msg, IEEE802154_ATTR_DEV_NAME, dev->name) ||
+	    nla_put_u32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex) ||
+	    nla_put_shortaddr(msg, IEEE802154_ATTR_PAN_ID, desc->pan_id) ||
+	    nla_put_shortaddr(msg, IEEE802154_ATTR_SHORT_ADDR,
+			      desc->short_addr) ||
+	    nla_put_hwaddr(msg, IEEE802154_ATTR_HW_ADDR, desc->hwaddr) ||
+	    nla_put_u32(msg, IEEE802154_ATTR_LLSEC_FRAME_COUNTER,
+			desc->frame_counter) ||
+	    nla_put_u8(msg, IEEE802154_ATTR_LLSEC_DEV_OVERRIDE,
+		       desc->seclevel_exempt) ||
+	    nla_put_u8(msg, IEEE802154_ATTR_LLSEC_DEV_KEY_MODE, desc->key_mode))
+		goto nla_put_failure;
+
+	genlmsg_end(msg, hdr);
+	return 0;
+
+nla_put_failure:
+	genlmsg_cancel(msg, hdr);
+out:
+	return -EMSGSIZE;
+}
+
+static int llsec_iter_devs(struct llsec_dump_data *data)
+{
+	struct ieee802154_llsec_device *pos;
+	int rc = 0, idx = 0;
+
+	list_for_each_entry(pos, &data->table->devices, list) {
+		if (idx++ < data->s_idx)
+			continue;
+
+		if (ieee802154_nl_fill_dev(data->skb, data->portid,
+					   data->nlmsg_seq, pos, data->dev)) {
+			rc = -EMSGSIZE;
+			break;
+		}
+
+		data->s_idx++;
+	}
+
+	return rc;
+}
+
+int ieee802154_llsec_dump_devs(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	return ieee802154_llsec_dump_table(skb, cb, llsec_iter_devs);
+}
+
+
+
+static int llsec_add_devkey(struct net_device *dev, struct genl_info *info)
+{
+	struct ieee802154_mlme_ops *ops = ieee802154_mlme_ops(dev);
+	struct ieee802154_llsec_device_key key;
+	__le64 devaddr;
+
+	if (!info->attrs[IEEE802154_ATTR_LLSEC_FRAME_COUNTER] ||
+	    !info->attrs[IEEE802154_ATTR_HW_ADDR] ||
+	    ieee802154_llsec_parse_key_id(info, &key.key_id))
+		return -EINVAL;
+
+	devaddr = nla_get_hwaddr(info->attrs[IEEE802154_ATTR_HW_ADDR]);
+	key.frame_counter = nla_get_u32(info->attrs[IEEE802154_ATTR_LLSEC_FRAME_COUNTER]);
+
+	return ops->llsec->add_devkey(dev, devaddr, &key);
+}
+
+int ieee802154_llsec_add_devkey(struct sk_buff *skb, struct genl_info *info)
+{
+	if ((info->nlhdr->nlmsg_flags & (NLM_F_CREATE | NLM_F_EXCL)) !=
+	    (NLM_F_CREATE | NLM_F_EXCL))
+		return -EINVAL;
+
+	return ieee802154_nl_llsec_change(skb, info, llsec_add_devkey);
+}
+
+static int llsec_del_devkey(struct net_device *dev, struct genl_info *info)
+{
+	struct ieee802154_mlme_ops *ops = ieee802154_mlme_ops(dev);
+	struct ieee802154_llsec_device_key key;
+	__le64 devaddr;
+
+	if (!info->attrs[IEEE802154_ATTR_HW_ADDR] ||
+	    ieee802154_llsec_parse_key_id(info, &key.key_id))
+		return -EINVAL;
+
+	devaddr = nla_get_hwaddr(info->attrs[IEEE802154_ATTR_HW_ADDR]);
+
+	return ops->llsec->del_devkey(dev, devaddr, &key);
+}
+
+int ieee802154_llsec_del_devkey(struct sk_buff *skb, struct genl_info *info)
+{
+	return ieee802154_nl_llsec_change(skb, info, llsec_del_devkey);
+}
+
+static int
+ieee802154_nl_fill_devkey(struct sk_buff *msg, u32 portid, u32 seq,
+			  __le64 devaddr,
+			  const struct ieee802154_llsec_device_key *devkey,
+			  const struct net_device *dev)
+{
+	void *hdr;
+
+	hdr = genlmsg_put(msg, 0, seq, &nl802154_family, NLM_F_MULTI,
+			  IEEE802154_LLSEC_LIST_DEVKEY);
+	if (!hdr)
+		goto out;
+
+	if (nla_put_string(msg, IEEE802154_ATTR_DEV_NAME, dev->name) ||
+	    nla_put_u32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex) ||
+	    nla_put_hwaddr(msg, IEEE802154_ATTR_HW_ADDR, devaddr) ||
+	    nla_put_u32(msg, IEEE802154_ATTR_LLSEC_FRAME_COUNTER,
+			devkey->frame_counter) ||
+	    ieee802154_llsec_fill_key_id(msg, &devkey->key_id))
+		goto nla_put_failure;
+
+	genlmsg_end(msg, hdr);
+	return 0;
+
+nla_put_failure:
+	genlmsg_cancel(msg, hdr);
+out:
+	return -EMSGSIZE;
+}
+
+static int llsec_iter_devkeys(struct llsec_dump_data *data)
+{
+	struct ieee802154_llsec_device *dpos;
+	struct ieee802154_llsec_device_key *kpos;
+	int rc = 0, idx = 0, idx2;
+
+	list_for_each_entry(dpos, &data->table->devices, list) {
+		if (idx++ < data->s_idx)
+			continue;
+
+		idx2 = 0;
+
+		list_for_each_entry(kpos, &dpos->keys, list) {
+			if (idx2++ < data->s_idx2)
+				continue;
+
+			if (ieee802154_nl_fill_devkey(data->skb, data->portid,
+						      data->nlmsg_seq,
+						      dpos->hwaddr, kpos,
+						      data->dev)) {
+				return rc = -EMSGSIZE;
+			}
+
+			data->s_idx2++;
+		}
+
+		data->s_idx++;
+	}
+
+	return rc;
+}
+
+int ieee802154_llsec_dump_devkeys(struct sk_buff *skb,
+				  struct netlink_callback *cb)
+{
+	return ieee802154_llsec_dump_table(skb, cb, llsec_iter_devkeys);
+}
+
+
+
+static int
+llsec_parse_seclevel(struct genl_info *info,
+		     struct ieee802154_llsec_seclevel *sl)
+{
+	memset(sl, 0, sizeof(*sl));
+
+	if (!info->attrs[IEEE802154_ATTR_LLSEC_FRAME_TYPE] ||
+	    !info->attrs[IEEE802154_ATTR_LLSEC_SECLEVELS] ||
+	    !info->attrs[IEEE802154_ATTR_LLSEC_DEV_OVERRIDE])
+		return -EINVAL;
+
+	sl->frame_type = nla_get_u8(info->attrs[IEEE802154_ATTR_LLSEC_FRAME_TYPE]);
+	if (sl->frame_type == IEEE802154_FC_TYPE_MAC_CMD) {
+		if (!info->attrs[IEEE802154_ATTR_LLSEC_CMD_FRAME_ID])
+			return -EINVAL;
+
+		sl->cmd_frame_id = nla_get_u8(info->attrs[IEEE802154_ATTR_LLSEC_CMD_FRAME_ID]);
+	}
+
+	sl->sec_levels = nla_get_u8(info->attrs[IEEE802154_ATTR_LLSEC_SECLEVELS]);
+	sl->device_override = nla_get_u8(info->attrs[IEEE802154_ATTR_LLSEC_DEV_OVERRIDE]);
+
+	return 0;
+}
+
+static int llsec_add_seclevel(struct net_device *dev, struct genl_info *info)
+{
+	struct ieee802154_mlme_ops *ops = ieee802154_mlme_ops(dev);
+	struct ieee802154_llsec_seclevel sl;
+
+	if (llsec_parse_seclevel(info, &sl))
+		return -EINVAL;
+
+	return ops->llsec->add_seclevel(dev, &sl);
+}
+
+int ieee802154_llsec_add_seclevel(struct sk_buff *skb, struct genl_info *info)
+{
+	if ((info->nlhdr->nlmsg_flags & (NLM_F_CREATE | NLM_F_EXCL)) !=
+	    (NLM_F_CREATE | NLM_F_EXCL))
+		return -EINVAL;
+
+	return ieee802154_nl_llsec_change(skb, info, llsec_add_seclevel);
+}
+
+static int llsec_del_seclevel(struct net_device *dev, struct genl_info *info)
+{
+	struct ieee802154_mlme_ops *ops = ieee802154_mlme_ops(dev);
+	struct ieee802154_llsec_seclevel sl;
+
+	if (llsec_parse_seclevel(info, &sl))
+		return -EINVAL;
+
+	return ops->llsec->del_seclevel(dev, &sl);
+}
+
+int ieee802154_llsec_del_seclevel(struct sk_buff *skb, struct genl_info *info)
+{
+	return ieee802154_nl_llsec_change(skb, info, llsec_del_seclevel);
+}
+
+static int
+ieee802154_nl_fill_seclevel(struct sk_buff *msg, u32 portid, u32 seq,
+			    const struct ieee802154_llsec_seclevel *sl,
+			    const struct net_device *dev)
+{
+	void *hdr;
+
+	hdr = genlmsg_put(msg, 0, seq, &nl802154_family, NLM_F_MULTI,
+			  IEEE802154_LLSEC_LIST_SECLEVEL);
+	if (!hdr)
+		goto out;
+
+	if (nla_put_string(msg, IEEE802154_ATTR_DEV_NAME, dev->name) ||
+	    nla_put_u32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex) ||
+	    nla_put_u8(msg, IEEE802154_ATTR_LLSEC_FRAME_TYPE, sl->frame_type) ||
+	    nla_put_u8(msg, IEEE802154_ATTR_LLSEC_SECLEVELS, sl->sec_levels) ||
+	    nla_put_u8(msg, IEEE802154_ATTR_LLSEC_DEV_OVERRIDE,
+		       sl->device_override))
+		goto nla_put_failure;
+
+	if (sl->frame_type == IEEE802154_FC_TYPE_MAC_CMD &&
+	    nla_put_u8(msg, IEEE802154_ATTR_LLSEC_CMD_FRAME_ID,
+		       sl->cmd_frame_id))
+		goto nla_put_failure;
+
+	genlmsg_end(msg, hdr);
+	return 0;
+
+nla_put_failure:
+	genlmsg_cancel(msg, hdr);
+out:
+	return -EMSGSIZE;
+}
+
+static int llsec_iter_seclevels(struct llsec_dump_data *data)
+{
+	struct ieee802154_llsec_seclevel *pos;
+	int rc = 0, idx = 0;
+
+	list_for_each_entry(pos, &data->table->security_levels, list) {
+		if (idx++ < data->s_idx)
+			continue;
+
+		if (ieee802154_nl_fill_seclevel(data->skb, data->portid,
+						data->nlmsg_seq, pos,
+						data->dev)) {
+			rc = -EMSGSIZE;
+			break;
+		}
+
+		data->s_idx++;
+	}
+
+	return rc;
+}
+
+int ieee802154_llsec_dump_seclevels(struct sk_buff *skb,
+				    struct netlink_callback *cb)
+{
+	return ieee802154_llsec_dump_table(skb, cb, llsec_iter_seclevels);
+}
diff --git a/net/ieee802154/nl_policy.c b/net/ieee802154/nl_policy.c
index fd7be5e..3a703ab8 100644
--- a/net/ieee802154/nl_policy.c
+++ b/net/ieee802154/nl_policy.c
@@ -62,5 +62,21 @@ const struct nla_policy ieee802154_policy[IEEE802154_ATTR_MAX + 1] = {
 	[IEEE802154_ATTR_CSMA_MAX_BE] = { .type = NLA_U8, },
 
 	[IEEE802154_ATTR_FRAME_RETRIES] = { .type = NLA_S8, },
+
+	[IEEE802154_ATTR_LLSEC_ENABLED] = { .type = NLA_U8, },
+	[IEEE802154_ATTR_LLSEC_SECLEVEL] = { .type = NLA_U8, },
+	[IEEE802154_ATTR_LLSEC_KEY_MODE] = { .type = NLA_U8, },
+	[IEEE802154_ATTR_LLSEC_KEY_SOURCE_SHORT] = { .type = NLA_U32, },
+	[IEEE802154_ATTR_LLSEC_KEY_SOURCE_EXTENDED] = { .type = NLA_HW_ADDR, },
+	[IEEE802154_ATTR_LLSEC_KEY_ID] = { .type = NLA_U8, },
+	[IEEE802154_ATTR_LLSEC_FRAME_COUNTER] = { .type = NLA_U32 },
+	[IEEE802154_ATTR_LLSEC_KEY_BYTES] = { .len = 16, },
+	[IEEE802154_ATTR_LLSEC_KEY_USAGE_FRAME_TYPES] = { .type = NLA_U8, },
+	[IEEE802154_ATTR_LLSEC_KEY_USAGE_COMMANDS] = { .len = 258 / 8 },
+	[IEEE802154_ATTR_LLSEC_FRAME_TYPE] = { .type = NLA_U8, },
+	[IEEE802154_ATTR_LLSEC_CMD_FRAME_ID] = { .type = NLA_U8, },
+	[IEEE802154_ATTR_LLSEC_SECLEVELS] = { .type = NLA_U8, },
+	[IEEE802154_ATTR_LLSEC_DEV_OVERRIDE] = { .type = NLA_U8, },
+	[IEEE802154_ATTR_LLSEC_DEV_KEY_MODE] = { .type = NLA_U8, },
 };
 
-- 
1.7.9.5
