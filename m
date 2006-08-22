From: Daikichi Osuga <osugad@s1.nttdocomo.co.jp>
Subject: [PATCH] tcp: RFC3465 Appropriate Byte Count fix
Date: Tue, 22 Aug 2006 14:52:43 +0900
Message-ID: <0J4D00BIVXNW7H40@NTTDoCoMo.co.jp>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Received: from dish-sg.nttdocomo.co.jp ([202.19.227.74]:9170 "EHLO
	zcsg-mailro12.is.nttdocomo.co.jp") by vger.kernel.org with ESMTP
	id S1750787AbWHVFwq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 01:52:46 -0400
Received: from zcsg-mailmt12.is.nttdocomo.co.jp (unknown [10.160.86.41])
	by zcsg-mailro12.is.nttdocomo.co.jp (Postfix) with ESMTP id 849F33402D
	for <netdev@vger.kernel.org>; Tue, 22 Aug 2006 14:52:44 +0900 (JST)
Received: from smtp_saver-daemon.zcsg-mailmt12.is.nttdocomo.co.jp by
 zcsg-mailmt12.is.nttdocomo.co.jp (NTT DoCoMo Mail System)
 id <0J4D00961XNWU900@NTTDoCoMo.co.jp> for netdev@vger.kernel.org; Tue,
 22 Aug 2006 14:52:44 +0900 (JST)
Received: from zcsg-mailmi11.is.nttdocomo.co.jp ([10.160.86.49])
 by zcsg-mailmt12.is.nttdocomo.co.jp (NTT DoCoMo Mail System)
 with SMTP id <0J4D00AK6XNWAPD0@NTTDoCoMo.co.jp> for netdev@vger.kernel.org;
 Tue, 22 Aug 2006 14:52:44 +0900 (JST)
Received: from zcsg-mailvs14.is.nttdocomo.co.jp (localhost [127.0.0.1])
	by localhost.nttdocomo.co.jp (Postfix) with ESMTP id 5DDD738004	for
 <netdev@vger.kernel.org>; Tue, 22 Aug 2006 14:52:44 +0900 (JST)
Received: from zcsg-mailsa13.is.nttdocomo.co.jp (unknown [10.160.86.46])
	by zcsg-mailvs14.is.nttdocomo.co.jp (Postfix) with ESMTP id 50B3238002	for
 <netdev@vger.kernel.org>; Tue, 22 Aug 2006 14:52:44 +0900 (JST)
Received: from gc_check-daemon.zcsg-mailsa13.is.nttdocomo.co.jp by
 zcsg-mailsa13.is.nttdocomo.co.jp (NTT DoCoMo Mail System)
 id <0J4D00A23XNWZP00@NTTDoCoMo.co.jp> for netdev@vger.kernel.org; Tue,
 22 Aug 2006 14:52:44 +0900 (JST)
Received: from akosugad222.docomo.docomogr.net
 (akosugad222.docomo.docomogr.net [10.19.102.139])
 by zcsg-mailsa13.is.nttdocomo.co.jp (NTT DoCoMo Mail System)
 with ESMTPA id <0J4D00BIUXNV7H40@NTTDoCoMo.co.jp> for netdev@vger.kernel.org;
 Tue, 22 Aug 2006 14:52:44 +0900 (JST)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daikichi Osuga <osugad@s1.nttdocomo.co.jp>

RFC3465 Appropriate Byte Count fix
slow start after retransmit timeout does not work is fixed.
case of L=2*SMSS acked bytes comparison is fixed.

Signed-off-by: Daikichi Osuga <osugad@s1.nttdocomo.co.jp>

--- linux-2.6.15.i686.org/net/ipv4/tcp_input.c	2006-08-21 17:58:18.000000000 +0900
+++ linux-2.6.15.i686/net/ipv4/tcp_input.c	2006-08-22 09:59:46.000000000 +0900
@@ -2450,8 +2450,13 @@ static int tcp_ack(struct sock *sk, stru
 	if (before(ack, prior_snd_una))
 		goto old_ack;
 
-	if (sysctl_tcp_abc && icsk->icsk_ca_state < TCP_CA_CWR)
-		tp->bytes_acked += ack - prior_snd_una;
+	if (sysctl_tcp_abc) {
+		if (icsk->icsk_ca_state < TCP_CA_CWR)
+			tp->bytes_acked += ack - prior_snd_una;
+		else if (icsk->icsk_ca_state == TCP_CA_Loss)
+			/* we assume just one segment left network */
+			tp->bytes_acked += min(ack - prior_snd_una, tp->mss_cache);
+	}
 
 	if (!(flag&FLAG_SLOWPATH) && after(ack, prior_snd_una)) {
 		/* Window is constant, pure forward advance.
--- linux-2.6.15.i686.org/net/ipv4/tcp_cong.c	2006-08-21 17:58:18.000000000 +0900
+++ linux-2.6.15.i686/net/ipv4/tcp_cong.c	2006-08-22 09:59:53.000000000 +0900
@@ -190,7 +190,7 @@ void tcp_slow_start(struct tcp_sock *tp)
 			return;
 
 		/* We MAY increase by 2 if discovered delayed ack */
-		if (sysctl_tcp_abc > 1 && tp->bytes_acked > 2*tp->mss_cache) {
+		if (sysctl_tcp_abc > 1 && tp->bytes_acked >= 2*tp->mss_cache) {
 			if (tp->snd_cwnd < tp->snd_cwnd_clamp)
 				tp->snd_cwnd++;
 		}
