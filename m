From: Brenden Blanco <bblanco@plumgrid.com>
Subject: [RFC PATCH v2 3/5] rtnl: add option for setting link bpf prog
Date: Thu,  7 Apr 2016 21:48:48 -0700
Message-ID: <1460090930-11219-3-git-send-email-bblanco@plumgrid.com>
References: <1460090930-11219-1-git-send-email-bblanco@plumgrid.com>
Cc: Brenden Blanco <bblanco@plumgrid.com>, netdev@vger.kernel.org,
	tom@herbertland.com, alexei.starovoitov@gmail.com,
	ogerlitz@mellanox.com, daniel@iogearbox.net, brouer@redhat.com,
	eric.dumazet@gmail.com, ecree@solarflare.com,
	john.fastabend@gmail.com, tgraf@suug.ch, johannes@sipsolutions.net,
	eranlinuxmellanox@gmail.com, lorenzo@google.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34715 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755381AbcDHEs6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 00:48:58 -0400
Received: by mail-pa0-f50.google.com with SMTP id fe3so67865800pab.1
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2016 21:48:57 -0700 (PDT)
In-Reply-To: <1460090930-11219-1-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sets the bpf program represented by fd as an early filter in the rx path
of the netdev. The fd must have been created as BPF_PROG_TYPE_PHYS_DEV.
Providing a negative value as fd clears the program. Getting the fd back
via rtnl is not possible, therefore reading of this value merely
provides a bool whether the program is valid on the link or not.

Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
---
 include/uapi/linux/if_link.h |  1 +
 net/core/rtnetlink.c         | 12 ++++++++++++
 2 files changed, 13 insertions(+)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 9427f17..ccad234 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -155,6 +155,7 @@ enum {
 	IFLA_PROTO_DOWN,
 	IFLA_GSO_MAX_SEGS,
 	IFLA_GSO_MAX_SIZE,
+	IFLA_BPF_FD,
 	__IFLA_MAX
 };
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index a75f7e9..96579ce 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -910,6 +910,7 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
 	       + nla_total_size(MAX_PHYS_ITEM_ID_LEN) /* IFLA_PHYS_PORT_ID */
 	       + nla_total_size(MAX_PHYS_ITEM_ID_LEN) /* IFLA_PHYS_SWITCH_ID */
 	       + nla_total_size(IFNAMSIZ) /* IFLA_PHYS_PORT_NAME */
+	       + nla_total_size(4) /* IFLA_BPF_FD */
 	       + nla_total_size(1); /* IFLA_PROTO_DOWN */
 
 }
@@ -1242,6 +1243,9 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	     nla_put_string(skb, IFLA_IFALIAS, dev->ifalias)) ||
 	    nla_put_u32(skb, IFLA_CARRIER_CHANGES,
 			atomic_read(&dev->carrier_changes)) ||
+	    (dev->netdev_ops->ndo_bpf_get &&
+	     nla_put_s32(skb, IFLA_BPF_FD,
+			 dev->netdev_ops->ndo_bpf_get(dev))) ||
 	    nla_put_u8(skb, IFLA_PROTO_DOWN, dev->proto_down))
 		goto nla_put_failure;
 
@@ -1375,6 +1379,7 @@ static const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_PHYS_SWITCH_ID]	= { .type = NLA_BINARY, .len = MAX_PHYS_ITEM_ID_LEN },
 	[IFLA_LINK_NETNSID]	= { .type = NLA_S32 },
 	[IFLA_PROTO_DOWN]	= { .type = NLA_U8 },
+	[IFLA_BPF_FD]		= { .type = NLA_S32 },
 };
 
 static const struct nla_policy ifla_info_policy[IFLA_INFO_MAX+1] = {
@@ -2029,6 +2034,13 @@ static int do_setlink(const struct sk_buff *skb,
 		status |= DO_SETLINK_NOTIFY;
 	}
 
+	if (tb[IFLA_BPF_FD]) {
+		err = dev_change_bpf_fd(dev, nla_get_s32(tb[IFLA_BPF_FD]));
+		if (err)
+			goto errout;
+		status |= DO_SETLINK_NOTIFY;
+	}
+
 errout:
 	if (status & DO_SETLINK_MODIFIED) {
 		if (status & DO_SETLINK_NOTIFY)
-- 
2.8.0
