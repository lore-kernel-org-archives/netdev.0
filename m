From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] bpf: make padding in bpf_tunnel_key explicit
Date: Wed, 30 Mar 2016 00:02:00 +0200
Message-ID: <6589c70157238797e63986eeea67cfe2abfb3260.1459288316.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54274 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754848AbcC2WCr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2016 18:02:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the 2 byte padding in struct bpf_tunnel_key between tunnel_ttl
and tunnel_label members explicit. No issue has been observed, and
gcc/llvm does padding for the old struct already, where tunnel_label
was not yet present, so the current code works, but since it's part
of uapi, make sure we don't introduce holes in structs.

Therefore, add tunnel_ext that we can use generically in future
(f.e. to flag OAM messages for backends, etc). Also add the offset
to the compat tests to be sure should some compilers not padd the
tail of the old version of bpf_tunnel_key.

Fixes: 4018ab1875e0 ("bpf: support flow label for bpf_skb_{set, get}_tunnel_key")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/uapi/linux/bpf.h | 1 +
 net/core/filter.c        | 5 ++++-
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 924f537..23917bb 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -375,6 +375,7 @@ struct bpf_tunnel_key {
 	};
 	__u8 tunnel_tos;
 	__u8 tunnel_ttl;
+	__u16 tunnel_ext;
 	__u32 tunnel_label;
 };
 
diff --git a/net/core/filter.c b/net/core/filter.c
index b7177d0..4b81b71 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1764,6 +1764,7 @@ static u64 bpf_skb_get_tunnel_key(u64 r1, u64 r2, u64 size, u64 flags, u64 r5)
 	if (unlikely(size != sizeof(struct bpf_tunnel_key))) {
 		switch (size) {
 		case offsetof(struct bpf_tunnel_key, tunnel_label):
+		case offsetof(struct bpf_tunnel_key, tunnel_ext):
 			goto set_compat;
 		case offsetof(struct bpf_tunnel_key, remote_ipv6[1]):
 			/* Fixup deprecated structure layouts here, so we have
@@ -1849,6 +1850,7 @@ static u64 bpf_skb_set_tunnel_key(u64 r1, u64 r2, u64 size, u64 flags, u64 r5)
 	if (unlikely(size != sizeof(struct bpf_tunnel_key))) {
 		switch (size) {
 		case offsetof(struct bpf_tunnel_key, tunnel_label):
+		case offsetof(struct bpf_tunnel_key, tunnel_ext):
 		case offsetof(struct bpf_tunnel_key, remote_ipv6[1]):
 			/* Fixup deprecated structure layouts here, so we have
 			 * a common path later on.
@@ -1861,7 +1863,8 @@ static u64 bpf_skb_set_tunnel_key(u64 r1, u64 r2, u64 size, u64 flags, u64 r5)
 			return -EINVAL;
 		}
 	}
-	if (unlikely(!(flags & BPF_F_TUNINFO_IPV6) && from->tunnel_label))
+	if (unlikely((!(flags & BPF_F_TUNINFO_IPV6) && from->tunnel_label) ||
+		     from->tunnel_ext))
 		return -EINVAL;
 
 	skb_dst_drop(skb);
-- 
1.9.3
