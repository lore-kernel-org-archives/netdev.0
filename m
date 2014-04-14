From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net] net: filter: seccomp: fix wrong decoding of BPF_S_ANC_SECCOMP_LD_W
Date: Mon, 14 Apr 2014 21:20:12 +0200
Message-ID: <1397503212-17087-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, Alexei Starovoitov <ast@plumgrid.com>,
	Pavel Emelyanov <xemul@parallels.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53789 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750933AbaDNTVf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Apr 2014 15:21:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While reviewing seccomp code, we found that BPF_S_ANC_SECCOMP_LD_W has
been wrongly decoded by commit a8fc927780 ("sk-filter: Add ability to
get socket filter program (v2)") into the opcode BPF_LD|BPF_B|BPF_ABS
although it should have been decoded as BPF_LD|BPF_W|BPF_ABS.

In practice, this should not have much side-effect though, as such
conversion is/was being done through prctl(2) PR_SET_SECCOMP. Reverse
operation PR_GET_SECCOMP will only return the current seccomp mode, but
not the filter itself. Since the transition to the new BPF infrastructure,
it's also not used anymore, so we can simply remove this as it's
unreachable.

Fixes: a8fc927780 ("sk-filter: Add ability to get socket filter program (v2)")
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
Cc: Pavel Emelyanov <xemul@parallels.com>
---
 include/linux/filter.h | 1 -
 net/core/filter.c      | 1 -
 2 files changed, 2 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 262dcbb..024fd03 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -220,7 +220,6 @@ enum {
 	BPF_S_ANC_RXHASH,
 	BPF_S_ANC_CPU,
 	BPF_S_ANC_ALU_XOR_X,
-	BPF_S_ANC_SECCOMP_LD_W,
 	BPF_S_ANC_VLAN_TAG,
 	BPF_S_ANC_VLAN_TAG_PRESENT,
 	BPF_S_ANC_PAY_OFFSET,
diff --git a/net/core/filter.c b/net/core/filter.c
index 0e0856f..cd58614 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1743,7 +1743,6 @@ void sk_decode_filter(struct sock_filter *filt, struct sock_filter *to)
 		[BPF_S_ANC_RXHASH]	= BPF_LD|BPF_B|BPF_ABS,
 		[BPF_S_ANC_CPU]		= BPF_LD|BPF_B|BPF_ABS,
 		[BPF_S_ANC_ALU_XOR_X]	= BPF_LD|BPF_B|BPF_ABS,
-		[BPF_S_ANC_SECCOMP_LD_W] = BPF_LD|BPF_B|BPF_ABS,
 		[BPF_S_ANC_VLAN_TAG]	= BPF_LD|BPF_B|BPF_ABS,
 		[BPF_S_ANC_VLAN_TAG_PRESENT] = BPF_LD|BPF_B|BPF_ABS,
 		[BPF_S_ANC_PAY_OFFSET]	= BPF_LD|BPF_B|BPF_ABS,
-- 
1.7.11.7
