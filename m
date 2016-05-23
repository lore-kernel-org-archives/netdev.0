From: Tom Herbert <tom@herbertland.com>
Subject: [RFC PATCH 6/7] tcp6: Support for TOU
Date: Mon, 23 May 2016 15:48:25 -0700
Message-ID: <1464043706-2843932-7-git-send-email-tom@herbertland.com>
References: <1464043706-2843932-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:40979 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751810AbcEWWsx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2016 18:48:53 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u4NMkx65024132
	for <netdev@vger.kernel.org>; Mon, 23 May 2016 15:48:52 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 2341q73793-7
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 23 May 2016 15:48:52 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.103.99.97) with ESMTP	id
 7fb9c2b8213811e697a70002c9931860-31cbd6d0 for <netdev@vger.kernel.org>;	Mon,
 23 May 2016 15:48:42 -0700
In-Reply-To: <1464043706-2843932-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Need to adjust MSS to account for encapsulation overhead. This is done
by add encpasulation header length into icsk_ext_hdr_len.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv6/tcp_ipv6.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 79e33e0..6a3c2e7 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -62,6 +62,7 @@
 #include <net/inet_common.h>
 #include <net/secure_seq.h>
 #include <net/busy_poll.h>
+#include <net/tou.h>
 
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
@@ -210,7 +211,7 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 		err = tcp_v4_connect(sk, (struct sockaddr *)&sin, sizeof(sin));
 
 		if (err) {
-			icsk->icsk_ext_hdr_len = exthdrlen;
+			icsk->icsk_ext_hdr_len = tou_hdr_len(sk) + exthdrlen;
 			icsk->icsk_af_ops = &ipv6_specific;
 			sk->sk_backlog_rcv = tcp_v6_do_rcv;
 #ifdef CONFIG_TCP_MD5SIG
@@ -262,9 +263,9 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	    ipv6_addr_equal(&fl6.daddr, &sk->sk_v6_daddr))
 		tcp_fetch_timewait_stamp(sk, dst);
 
-	icsk->icsk_ext_hdr_len = 0;
+	icsk->icsk_ext_hdr_len = tou_hdr_len(sk);
 	if (opt)
-		icsk->icsk_ext_hdr_len = opt->opt_flen +
+		icsk->icsk_ext_hdr_len += opt->opt_flen +
 					 opt->opt_nflen;
 
 	tp->rx_opt.mss_clamp = IPV6_MIN_MTU - sizeof(struct tcphdr) - sizeof(struct ipv6hdr);
@@ -1114,9 +1115,9 @@ static struct sock *tcp_v6_syn_recv_sock(const struct sock *sk, struct sk_buff *
 		opt = ipv6_dup_options(newsk, opt);
 		RCU_INIT_POINTER(newnp->opt, opt);
 	}
-	inet_csk(newsk)->icsk_ext_hdr_len = 0;
+	inet_csk(newsk)->icsk_ext_hdr_len = tou_hdr_len(sk);
 	if (opt)
-		inet_csk(newsk)->icsk_ext_hdr_len = opt->opt_nflen +
+		inet_csk(newsk)->icsk_ext_hdr_len += opt->opt_nflen +
 						    opt->opt_flen;
 
 	tcp_ca_openreq_child(newsk, dst);
-- 
2.8.0.rc2
