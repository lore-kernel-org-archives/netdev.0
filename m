From: Davide Caratti <dcaratti@redhat.com>
Subject: [PATCH RFC net-next v2 1/4] skbuff: add stub to help computing crc32c on SCTP packets
Date: Tue, 28 Feb 2017 11:32:45 +0100
Message-ID: <56fcd0848eae2b0693797e09500892659323546c.1488199633.git.dcaratti@redhat.com>
References: <1488202783.2713.67.camel@redhat.com>
Cc: "David S . Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "linux-sctp @ vger . kernel . org" <linux-sctp@vger.kernel.org>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: David Laight <David.Laight@ACULAB.COM>,
        Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40340 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751625AbdB1Kf3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 28 Feb 2017 05:35:29 -0500
In-Reply-To: <1488202783.2713.67.camel@redhat.com>
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
index 69ccd26..cab9a32 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3125,6 +3125,8 @@ struct skb_checksum_ops {
 	__wsum (*combine)(__wsum csum, __wsum csum2, int offset, int len);
 };
 
+extern const struct skb_checksum_ops *sctp_csum_stub __read_mostly;
+
 __wsum __skb_checksum(const struct sk_buff *skb, int offset, int len,
 		      __wsum csum, const struct skb_checksum_ops *ops);
 __wsum skb_checksum(const struct sk_buff *skb, int offset, int len,
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index f355795..64fd8fd 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2242,6 +2242,26 @@ __wsum skb_copy_and_csum_bits(const struct sk_buff *skb, int offset,
 }
 EXPORT_SYMBOL(skb_copy_and_csum_bits);
 
+static __wsum warn_sctp_csum_update(const void *buff, int len, __wsum sum)
+{
+	net_warn_ratelimited("attempt to compute crc32c without sctp.ko\n");
+	return 0;
+}
+
+static __wsum warn_sctp_csum_combine(__wsum csum, __wsum csum2,
+				     int offset, int len)
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
index 4f5a2b5..e9c3db0 100644
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
