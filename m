From: Davide Caratti <dcaratti@redhat.com>
Subject: [RFC PATCH net-next 1/5] skbuff: add stub to help computing crc32c on SCTP packets
Date: Mon, 23 Jan 2017 17:52:42 +0100
Message-ID: <44239e443681996a9bc950177f0663fe35c31e15.1485177252.git.dcaratti@redhat.com>
References: <cover.1485177252.git.dcaratti@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45500 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751421AbdAWQ7X (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 11:59:23 -0500
In-Reply-To: <cover.1485177252.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sctp_compute_checksum requires crc32c symbol (provided by libcrc32c), so
it can't be used in net core. Like it has been done previously with other
symbols (e.g. ipv6_dst_lookup), introduce a stub struct skb_checksum_ops
to allow computation of SCTP checksum in net core after sctp.ko (and thus
libcrc32c) has been loaded.

Reviewed-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Signed-off-by: Davide Caratti <dcaratti@redhat.com>
---
 include/linux/skbuff.h |  2 ++
 net/core/skbuff.c      | 20 ++++++++++++++++++++
 net/sctp/offload.c     |  7 +++++++
 3 files changed, 29 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 6f63b7e..44fc804 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3119,6 +3119,8 @@ struct skb_checksum_ops {
 	__wsum (*combine)(__wsum csum, __wsum csum2, int offset, int len);
 };
 
+extern const struct skb_checksum_ops *sctp_csum_stub __read_mostly;
+
 __wsum __skb_checksum(const struct sk_buff *skb, int offset, int len,
 		      __wsum csum, const struct skb_checksum_ops *ops);
 __wsum skb_checksum(const struct sk_buff *skb, int offset, int len,
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index f8dbe4a..60e9963 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2235,6 +2235,26 @@ __wsum skb_copy_and_csum_bits(const struct sk_buff *skb, int offset,
 }
 EXPORT_SYMBOL(skb_copy_and_csum_bits);
 
+static __wsum warn_sctp_csum_update(const void *buff, int len, __wsum sum)
+{
+	net_warn_ratelimited("attempt to compute crc32c without sctp.ko\n");
+	return 0;
+}
+
+static __wsum warn_sctp_csum_combine(__wsum csum, __wsum csum2,
+					 int offset, int len)
+{
+	net_warn_ratelimited("attempt to compute crc32c without sctp.ko\n");
+	return 0;
+}
+
+const struct skb_checksum_ops *sctp_csum_stub __read_mostly =
+	&(struct skb_checksum_ops) {
+	.update  = warn_sctp_csum_update,
+	.combine = warn_sctp_csum_combine,
+};
+EXPORT_SYMBOL(sctp_csum_stub);
+
  /**
  *	skb_zerocopy_headlen - Calculate headroom needed for skb_zerocopy()
  *	@from: source buffer
diff --git a/net/sctp/offload.c b/net/sctp/offload.c
index 7e869d0..1c9c548 100644
--- a/net/sctp/offload.c
+++ b/net/sctp/offload.c
@@ -98,6 +98,12 @@ static const struct net_offload sctp6_offload = {
 	},
 };
 
+static const struct skb_checksum_ops *sctp_csum_ops __read_mostly =
+	&(struct skb_checksum_ops) {
+	.update  = sctp_csum_update,
+	.combine = sctp_csum_combine,
+};
+
 int __init sctp_offload_init(void)
 {
 	int ret;
@@ -110,6 +116,7 @@ int __init sctp_offload_init(void)
 	if (ret)
 		goto ipv4;
 
+	sctp_csum_stub = sctp_csum_ops;
 	return ret;
 
 ipv4:
-- 
2.7.4
