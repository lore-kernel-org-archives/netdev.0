From: Dave Watson <davejwatson@fb.com>
Subject: [PATCH net-next] tcp: fix null ptr deref in getsockopt(..., TCP_ULP,
 ...)
Date: Mon, 26 Jun 2017 08:36:47 -0700
Message-ID: <20170626153647.GA15170@achao-mbp1.DHCP.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Ilya Lesokhin <ilyal@mellanox.com>,
        Aviad Yehezkel <aviadye@mellanox.com>,
        Boris Pismenny <borisp@mellanox.com>,
        "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>,
        David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:44750 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751366AbdFZPhC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2017 11:37:02 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If icsk_ulp_ops is unset, it dereferences a null ptr.
Add a null ptr check.

BUG: KASAN: null-ptr-deref in copy_to_user include/linux/uaccess.h:168 [inline]
BUG: KASAN: null-ptr-deref in do_tcp_getsockopt.isra.33+0x24f/0x1e30 net/ipv4/tcp.c:3057
Read of size 4 at addr 0000000000000020 by task syz-executor1/15452

Signed-off-by: Dave Watson <davejwatson@fb.com>
Reported-by: "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>
---
 net/ipv4/tcp.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 058f509..4c88d20 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3062,6 +3062,11 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
 		if (get_user(len, optlen))
 			return -EFAULT;
 		len = min_t(unsigned int, len, TCP_ULP_NAME_MAX);
+		if (!icsk->icsk_ulp_ops) {
+			if (put_user(0, optlen))
+				return -EFAULT;
+			return 0;
+		}
 		if (put_user(len, optlen))
 			return -EFAULT;
 		if (copy_to_user(optval, icsk->icsk_ulp_ops->name, len))
-- 
2.9.3
