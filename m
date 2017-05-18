From: Davide Caratti <dcaratti@redhat.com>
Subject: [PATCH net-next v3 1/7] skbuff: add stub to help computing crc32c on SCTP packets
Date: Thu, 18 May 2017 15:44:37 +0200
Message-ID: <9611ff15ff678161d6c83f98ff1bac087052bbcf.1495112301.git.dcaratti@redhat.com>
References: <cover.1495112301.git.dcaratti@redhat.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        David Laight <David.Laight@ACULAB.COM>,
        "David S. Miller" <davem@davemloft.net>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58890 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753994AbdERNo4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 May 2017 09:44:56 -0400
In-Reply-To: <cover.1495112301.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sctp_compute_checksum requires crc32c symbol (provided by libcrc32c), so
it can't be used in net core. Like it has been done previously with other
symbols (e.g. ipv6_dst_lookup), introduce a stub struct skb_checksum_ops
to allow computation of crc32c checksum in net core after sctp.ko (and thus
libcrc32c) has been loaded.

Signed-off-by: Davide Caratti <dcaratti@redhat.com>
---
 include/linux/skbuff.h |  2 ++
 net/core/skbuff.c      | 26 ++++++++++++++++++++++++++
 net/sctp/offload.c     |  6 ++++++
 3 files changed, 34 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 7c0cb2c..b1f46a0 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3076,6 +3076,8 @@ struct skb_checksum_ops {
 	__wsum (*combine)(__wsum csum, __wsum csum2, int offset, int len);
 };
 
+extern const struct skb_checksum_ops *crc32c_csum_stub __read_mostly;
+
 __wsum __skb_checksum(const struct sk_buff *skb, int offset, int len,
 		      __wsum csum, const struct skb_checksum_ops *ops);
 __wsum skb_checksum(const struct sk_buff *skb, int offset, int len,
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 346d3e8..d5c9811 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2243,6 +2243,32 @@ __wsum skb_copy_and_csum_bits(const struct sk_buff *skb, int offset,
 }
 EXPORT_SYMBOL(skb_copy_and_csum_bits);
 
+static __wsum warn_crc32c_csum_update(const void *buff, int len, __wsum sum)
+{
+	net_warn_ratelimited(
+		"%s: attempt to compute crc32c without libcrc32c.ko\n",
+		__func__);
+	return 0;
+}
+
+static __wsum warn_crc32c_csum_combine(__wsum csum, __wsum csum2,
+				       int offset, int len)
+{
+	net_warn_ratelimited(
+		"%s: attempt to compute crc32c without libcrc32c.ko\n",
+		__func__);
+	return 0;
+}
+
+static const struct skb_checksum_ops default_crc32c_ops = {
+	.update  = warn_crc32c_csum_update,
+	.combine = warn_crc32c_csum_combine,
+};
+
+const struct skb_checksum_ops *crc32c_csum_stub __read_mostly =
+	&default_crc32c_ops;
+EXPORT_SYMBOL(crc32c_csum_stub);
+
  /**
  *	skb_zerocopy_headlen - Calculate headroom needed for skb_zerocopy()
  *	@from: source buffer
diff --git a/net/sctp/offload.c b/net/sctp/offload.c
index 4f5a2b5..b671984 100644
--- a/net/sctp/offload.c
+++ b/net/sctp/offload.c
@@ -98,6 +98,11 @@ static const struct net_offload sctp6_offload = {
 	},
 };
 
+static const struct skb_checksum_ops crc32c_csum_ops = {
+	.update  = sctp_csum_update,
+	.combine = sctp_csum_combine,
+};
+
 int __init sctp_offload_init(void)
 {
 	int ret;
@@ -110,6 +115,7 @@ int __init sctp_offload_init(void)
 	if (ret)
 		goto ipv4;
 
+	crc32c_csum_stub = &crc32c_csum_ops;
 	return ret;
 
 ipv4:
-- 
2.7.4
