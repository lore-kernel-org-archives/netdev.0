From: Lawrence Brakmo <brakmo@fb.com>
Subject: [PATCH v4 net-next] tcp: Change txhash on every SYN and RTO retransmit
Date: Tue, 27 Sep 2016 19:03:37 -0700
Message-ID: <20160928020337.3057238-1-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:33207 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754696AbcI1CDm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 22:03:42 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
        by m0001303.ppops.net (8.16.0.17/8.16.0.17) with SMTP id u8S21o06006433
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 19:03:41 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0001303.ppops.net with ESMTP id 25ptb9nh4a-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 19:03:41 -0700
Received: from facebook.com (2401:db00:11:d025:face:0:13:0)     by
 mx-out.facebook.com (10.223.101.97) with ESMTP id
 c55c1f32851f11e6a41624be0595f910-d6cf3a50 for <netdev@vger.kernel.org>;        Tue,
 27 Sep 2016 19:03:38 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current code changes txhash (flowlables) on every retransmitted
SYN/ACK, but only after the 2nd retransmitted SYN and only after
tcp_retries1 RTO retransmits.

With this patch:
1) txhash is changed with every SYN retransmits
2) txhash is changed with every RTO.

The result is that we can start re-routing around failed (or very
congested paths) as soon as possible. Otherwise application health
checks may fail and the connection may be terminated before we start
to change txhash.

v4: Removed sysctl, txhash is changed for all RTOs
v3: Removed text saying default value of sysctl is 0 (it is 100)
v2: Added sysctl documentation and cleaned code

Tested with packetdrill tests

Signed-off-by: Lawrence Brakmo <brakmo@fb.com>
---
 net/ipv4/tcp_timer.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index f712b41..3ea1cf8 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -192,6 +192,8 @@ static int tcp_write_timeout(struct sock *sk)
 			if (tp->syn_data && icsk->icsk_retransmits == 1)
 				NET_INC_STATS(sock_net(sk),
 					      LINUX_MIB_TCPFASTOPENACTIVEFAIL);
+		} else if (!tp->syn_data && !tp->syn_fastopen) {
+			sk_rethink_txhash(sk);
 		}
 		retry_until = icsk->icsk_syn_retries ? : net->ipv4.sysctl_tcp_syn_retries;
 		syn_set = true;
@@ -213,6 +215,8 @@ static int tcp_write_timeout(struct sock *sk)
 			tcp_mtu_probing(icsk, sk);
 
 			dst_negative_advice(sk);
+		} else {
+			sk_rethink_txhash(sk);
 		}
 
 		retry_until = net->ipv4.sysctl_tcp_retries2;
-- 
2.9.3
