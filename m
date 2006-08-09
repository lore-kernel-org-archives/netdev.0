From: Daikichi Osuga <osugad@s1.nttdocomo.co.jp>
Subject: [PATCH] tcp: RFC3465 Appropriate Byte Count fix
Date: Wed, 09 Aug 2006 14:02:37 +0900
Message-ID: <010001c6bb71$097fd930$8b66130a@docomo.docomogr.net>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=iso-2022-jp;
 reply-type=original
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from dish-sg.nttdocomo.co.jp ([202.19.227.74]:22485 "EHLO
	zcsg-mailro11.is.nttdocomo.co.jp") by vger.kernel.org with ESMTP
	id S1030474AbWHIFCk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 01:02:40 -0400
Received: from zcsg-mailmt12.is.nttdocomo.co.jp (unknown [10.160.86.41])
	by zcsg-mailro11.is.nttdocomo.co.jp (Postfix) with ESMTP id B6F1E34010
	for <netdev@vger.kernel.org>; Wed,  9 Aug 2006 14:02:39 +0900 (JST)
Received: from smtp_saver-daemon.zcsg-mailmt12.is.nttdocomo.co.jp by
 zcsg-mailmt12.is.nttdocomo.co.jp (NTT DoCoMo Mail System)
 id <0J3P00LB9SOF5H00@NTTDoCoMo.co.jp> for netdev@vger.kernel.org; Wed,
 09 Aug 2006 14:02:39 +0900 (JST)
Received: from zcsg-mailmi11.is.nttdocomo.co.jp ([10.160.86.49])
 by zcsg-mailmt12.is.nttdocomo.co.jp (NTT DoCoMo Mail System)
 with SMTP id <0J3P000ZCSOFNN00@NTTDoCoMo.co.jp> for netdev@vger.kernel.org;
 Wed, 09 Aug 2006 14:02:39 +0900 (JST)
Received: from zcsg-mailvs14.is.nttdocomo.co.jp (localhost [127.0.0.1])
	by localhost.nttdocomo.co.jp (Postfix) with ESMTP id 91E4338004	for
 <netdev@vger.kernel.org>; Wed, 09 Aug 2006 14:02:39 +0900 (JST)
Received: from zcsg-mailsa13.is.nttdocomo.co.jp (unknown [10.160.86.46])
	by zcsg-mailvs14.is.nttdocomo.co.jp (Postfix) with ESMTP id 8651638002	for
 <netdev@vger.kernel.org>; Wed, 09 Aug 2006 14:02:39 +0900 (JST)
Received: from gc_check-daemon.zcsg-mailsa13.is.nttdocomo.co.jp by
 zcsg-mailsa13.is.nttdocomo.co.jp (NTT DoCoMo Mail System)
 id <0J3P00735SOFHN00@NTTDoCoMo.co.jp> for netdev@vger.kernel.org; Wed,
 09 Aug 2006 14:02:39 +0900 (JST)
Received: from akosugad222 (akosugad222.docomo.docomogr.net [10.19.102.139])
 by zcsg-mailsa13.is.nttdocomo.co.jp (NTT DoCoMo Mail System)
 with ESMTPA id <0J3P0098BSOEDID0@NTTDoCoMo.co.jp> for netdev@vger.kernel.org;
 Wed, 09 Aug 2006 14:02:39 +0900 (JST)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In current RFC3465 Appropriate Byte Count implementation,
slow start after retransmit timeout does not work.
I fixed it.

--
Daikichi Osuga


*** linux-2.6.15.i686.org/net/ipv4/tcp_input.c 2006-07-25 15:44:35.000000000 +0900
--- linux-2.6.15.i686/net/ipv4/tcp_input.c 2006-08-08 14:38:24.000000000 +0900
***************
*** 2450,2456 ****
   if (before(ack, prior_snd_una))
    goto old_ack;
  
!  if (sysctl_tcp_abc && icsk->icsk_ca_state < TCP_CA_CWR)
    tp->bytes_acked += ack - prior_snd_una;
  
   if (!(flag&FLAG_SLOWPATH) && after(ack, prior_snd_una)) {
--- 2551,2557 ----
   if (before(ack, prior_snd_una))
    goto old_ack;
  
!  if (sysctl_tcp_abc && (icsk->icsk_ca_state < TCP_CA_CWR || icsk->icsk_ca_state == TCP_CA_Loss))
    tp->bytes_acked += ack - prior_snd_una;
  
   if (!(flag&FLAG_SLOWPATH) && after(ack, prior_snd_una)) {
*** linux-2.6.15.i686.org/net/ipv4/tcp_cong.c 2006-07-25 15:44:35.000000000 +0900
--- linux-2.6.15.i686/net/ipv4/tcp_cong.c 2006-08-08 15:47:45.000000000 +0900
***************
*** 180,185 ****
--- 180,186 ----
   */
  void tcp_slow_start(struct tcp_sock *tp)
  {
+  struct inet_connection_sock *icsk = (struct inet_connection_sock *)tp;
   if (sysctl_tcp_abc) {
    /* RFC3465: Slow Start
     * TCP sender SHOULD increase cwnd by the number of
***************
*** 190,196 ****
     return;
  
    /* We MAY increase by 2 if discovered delayed ack */
!   if (sysctl_tcp_abc > 1 && tp->bytes_acked > 2*tp->mss_cache) {
     if (tp->snd_cwnd < tp->snd_cwnd_clamp)
      tp->snd_cwnd++;
    }
--- 191,197 ----
     return;
  
    /* We MAY increase by 2 if discovered delayed ack */
!   if (sysctl_tcp_abc > 1 && tp->bytes_acked >= 2*tp->mss_cache && icsk->icsk_ca_state != TCP_CA_Loss) {
     if (tp->snd_cwnd < tp->snd_cwnd_clamp)
      tp->snd_cwnd++;
    }

