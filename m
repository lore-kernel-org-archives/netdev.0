From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 1/7] bpf: allow bpf_csum_diff to feed bpf_l3_csum_replace as well
Date: Fri,  4 Mar 2016 15:15:02 +0100
Message-ID: <f8ef1d7fe50d463e4d39f31b5979747127002021.1457099834.git.daniel@iogearbox.net>
References: <cover.1457099834.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39181 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751852AbcCDOPc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 09:15:32 -0500
In-Reply-To: <cover.1457099834.git.daniel@iogearbox.net>
In-Reply-To: <cover.1457099834.git.daniel@iogearbox.net>
References: <cover.1457099834.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 7d672345ed29 ("bpf: add generic bpf_csum_diff helper") added a
generic checksum diff helper that can feed bpf_l4_csum_replace() with
a target __wsum diff that is to be applied to the L4 checksum. This
facility is very flexible, can be cascaded, allows for adding, removing,
or diffing data, or for calculating the pseudo header checksum from
scratch, but it can also be reused for working with the IPv4 header
checksum.

Thus, analogous to bpf_l4_csum_replace(), add a case for header field
value of 0 to change the checksum at a given offset through a new helper
csum_replace_by_diff(). Also, in addition to that, this provides an
easy to use interface for feeding precalculated diffs f.e. coming from
a map. It nicely complements bpf_l3_csum_replace() that currently allows
only for csum updates of 2 and 4 byte diffs.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/net/checksum.h | 5 +++++
 net/core/filter.c      | 6 ++++++
 2 files changed, 11 insertions(+)

diff --git a/include/net/checksum.h b/include/net/checksum.h
index 10a16b5..abffc64 100644
--- a/include/net/checksum.h
+++ b/include/net/checksum.h
@@ -120,6 +120,11 @@ static inline __wsum csum_partial_ext(const void *buff, int len, __wsum sum)
 
 #define CSUM_MANGLED_0 ((__force __sum16)0xffff)
 
+static inline void csum_replace_by_diff(__sum16 *sum, __wsum diff)
+{
+	*sum = csum_fold(csum_add(diff, ~csum_unfold(*sum)));
+}
+
 static inline void csum_replace4(__sum16 *sum, __be32 from, __be32 to)
 {
 	__wsum tmp = csum_sub(~csum_unfold(*sum), (__force __wsum)from);
diff --git a/net/core/filter.c b/net/core/filter.c
index 69f4ffc..356a251 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1447,6 +1447,12 @@ static u64 bpf_l3_csum_replace(u64 r1, u64 r2, u64 from, u64 to, u64 flags)
 		return -EFAULT;
 
 	switch (flags & BPF_F_HDR_FIELD_MASK) {
+	case 0:
+		if (unlikely(from != 0))
+			return -EINVAL;
+
+		csum_replace_by_diff(ptr, to);
+		break;
 	case 2:
 		csum_replace2(ptr, from, to);
 		break;
-- 
1.9.3
