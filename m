From: Anton Nayshtut <anton@swortex.com>
Subject: [PATCH] IPv6 exthedrs offload registration fixed
Date: Wed,  5 Mar 2014 08:30:08 +0200
Message-ID: <1394001008-2444-1-git-send-email-anton@swortex.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Anton Nayshtut <anton@swortex.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Without this fix, ipv6_exthdrs_offload_init doesn't register IPPROTO_DSTOPTS
offload, but returns 0 (as the IPPROTO_ROUTING registration actually succeeds).

This then causes the ipv6_gso_segment to drop IPv6 packets with IPPROTO_DSTOPTS
header.

The issue detected and the fix verified by running MS HCK Offload LSO test on
top of QEMU Windows guests, as this test sends IPv6 packets with
IPPROTO_DSTOPTS.

Signed-off-by: Anton Nayshtut <anton@swortex.com>
---
 net/ipv6/exthdrs_offload.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/exthdrs_offload.c b/net/ipv6/exthdrs_offload.c
index cf77f3a..447a7fb 100644
--- a/net/ipv6/exthdrs_offload.c
+++ b/net/ipv6/exthdrs_offload.c
@@ -25,11 +25,11 @@ int __init ipv6_exthdrs_offload_init(void)
 	int ret;
 
 	ret = inet6_add_offload(&rthdr_offload, IPPROTO_ROUTING);
-	if (!ret)
+	if (ret)
 		goto out;
 
 	ret = inet6_add_offload(&dstopt_offload, IPPROTO_DSTOPTS);
-	if (!ret)
+	if (ret)
 		goto out_rt;
 
 out:
-- 
1.7.9.5
