From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] net: filter: return -EINVAL if BPF_S_ANC* operation is not supported
Date: Fri, 28 Dec 2012 21:50:17 +0100
Message-ID: <1356727817-10649-1-git-send-email-dborkman@redhat.com>
Cc: ani@aristanetworks.com, netdev@vger.kernel.org,
	Daniel Borkmann <dborkman@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10327 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752689Ab2L1Uvh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Dec 2012 15:51:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, we return -EINVAL for malformed or wrong BPF filters.
However, this is not done for BPF_S_ANC* operations, which makes it
more difficult to detect if it's actually supported or not by the
BPF machine. Therefore, we should also return -EINVAL if K is within
the SKF_AD_OFF universe and the ancillary operation did not match.

Why exactly is it needed? If tools such as libpcap/tcpdump want to
make use of new ancillary operations (like filtering VLAN in kernel
space), there is currently no sane way to test if this feature /
BPF_S_ANC* op is present or not, since no error is returned. This
patch will make life easier for that and allow for a proper usage
for user space applications.

There was concern, if this patch will break userland. Short answer: Yes
and no. Long answer: It will "break" only for code that calls ...

  { BPF_LD | BPF_(W|H|B) | BPF_ABS, 0, 0, <K> },

... where <K> is in [0xfffff000, 0xffffffff] _and_ <K> is *not* an
ancillary. And here comes the BUT: assuming some *old* code will have
such an instruction where <K> is between [0xfffff000, 0xffffffff] and
it doesn't know ancillary operations, then this will give a
non-expected / unwanted behavior as well (since we do not return the
BPF machine with 0 after a failed load_pointer(), which was the case
before introducing ancillary operations, but load sth. into the
accumulator instead, and continue with the next instruction, for
instance). Thus, user space code would already have been broken by
introducing ancillary operations into the BPF machine per se. Code
that does such a direct load, e.g. "load word at packet offset
0xffffffff into accumulator" ("ld [0xffffffff]") is quite broken,
isn't it? The whole assumption of ancillary operations is that no-one
intentionally calls things like "ld [0xffffffff]" and expect this
word to be loaded from such a packet offset. Hence, we can also safely
make use of this feature testing patch and facilitate application
development. Therefore, at least from this patch onwards, we have
*for sure* a check whether current or in future implemented BPF_S_ANC*
ops are supported in the kernel. Patch was tested on x86_64.

(Thanks to Eric for the previous review.)

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Reported-by: Ani Sinha <ani@aristanetworks.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/core/filter.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/core/filter.c b/net/core/filter.c
index c23543c..2ead2a9 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -532,6 +532,7 @@ int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
 		[BPF_JMP|BPF_JSET|BPF_X] = BPF_S_JMP_JSET_X,
 	};
 	int pc;
+	bool anc_found;
 
 	if (flen == 0 || flen > BPF_MAXINSNS)
 		return -EINVAL;
@@ -592,8 +593,10 @@ int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
 		case BPF_S_LD_W_ABS:
 		case BPF_S_LD_H_ABS:
 		case BPF_S_LD_B_ABS:
+			anc_found = false;
 #define ANCILLARY(CODE) case SKF_AD_OFF + SKF_AD_##CODE:	\
 				code = BPF_S_ANC_##CODE;	\
+				anc_found = true;		\
 				break
 			switch (ftest->k) {
 			ANCILLARY(PROTOCOL);
@@ -610,6 +613,10 @@ int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
 			ANCILLARY(VLAN_TAG);
 			ANCILLARY(VLAN_TAG_PRESENT);
 			}
+
+			/* ancillary operation unknown or unsupported */
+			if (anc_found == false && ftest->k >= SKF_AD_OFF)
+				return -EINVAL;
 		}
 		ftest->code = code;
 	}
-- 
1.7.11.7
