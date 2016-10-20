From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] bpf, test: fix ld_abs + vlan push/pop stress test
Date: Thu, 20 Oct 2016 17:13:53 +0200
Message-ID: <24f37bd819eceb02c56fc5a6fcd5b8450b1db36a.1476976082.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37782 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759450AbcJTPOD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 11:14:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After commit 636c2628086e ("net: skbuff: Remove errornous length
validation in skb_vlan_pop()") mentioned test case stopped working,
throwing a -12 (ENOMEM) return code. The issue however is not due to
636c2628086e, but rather due to a buggy test case that got uncovered
from the change in behaviour in 636c2628086e.

The data_size of that test case for the skb was set to 1. In the
bpf_fill_ld_abs_vlan_push_pop() handler bpf insns are generated that
loop with: reading skb data, pushing 68 tags, reading skb data,
popping 68 tags, reading skb data, etc, in order to force a skb
expansion and thus trigger that JITs recache skb->data. Problem is
that initial data_size is too small.

While before 636c2628086e, the test silently bailed out due to the
skb->len < VLAN_ETH_HLEN check with returning 0, and now throwing an
error from failing skb_ensure_writable(). Set at least minimum of
ETH_HLEN as an initial length so that on first push of data, equivalent
pop will succeed.

Fixes: 4d9c5c53ac99 ("test_bpf: add bpf_skb_vlan_push/pop() tests")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 lib/test_bpf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index 94346b4..0362da0 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -4831,7 +4831,7 @@ static int bpf_fill_ld_abs_vlan_push_pop(struct bpf_test *self)
 		{ },
 		INTERNAL,
 		{ 0x34 },
-		{ { 1, 0xbef } },
+		{ { ETH_HLEN, 0xbef } },
 		.fill_helper = bpf_fill_ld_abs_vlan_push_pop,
 	},
 	/*
-- 
1.9.3
