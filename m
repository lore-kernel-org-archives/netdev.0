From: weidong <weid@np.css.fujitsu.com>
Subject: Fix bugs in "Whether sock accept queue is full" checking
Date: Wed, 14 Feb 2007 11:30:57 -0500
Message-ID: <1171470657.7414.15.camel@LINE>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:52257 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964863AbXBOC1R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Feb 2007 21:27:17 -0500
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id l1F2RFwR002511
	for <netdev@vger.kernel.org> (envelope-from weid@np.css.fujitsu.com);
	Thu, 15 Feb 2007 11:27:16 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id DF1531B801E
	for <netdev@vger.kernel.org>; Thu, 15 Feb 2007 11:27:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A96352DC032
	for <netdev@vger.kernel.org>; Thu, 15 Feb 2007 11:27:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4 [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9565C161C00C
	for <netdev@vger.kernel.org>; Thu, 15 Feb 2007 11:27:09 +0900 (JST)
Received: from ml2.s.css.fujitsu.com (ml2.s.css.fujitsu.com [10.23.4.192])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 29EDF161C006
	for <netdev@vger.kernel.org>; Thu, 15 Feb 2007 11:27:09 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, All
	when I use linux TCP socket, and find there is a bug in function
sk_acceptq_is_full(). 

	When a new SYN comes, TCP module first checks its validation. If valid,
send SYN,ACK to the client and add the sock to the syn hash table. Next
time if received the valid ACK for SYN,ACK from the client. server will
accept this connection and increase the sk->sk_ack_backlog -- which is
done in function tcp_check_req().We check wether acceptq is full in
function tcp_v4_syn_recv_sock().

Consider an example:

 After listen(sockfd, 1) system call, sk->sk_max_ack_backlog is set to
1. As we know, sk->sk_ack_backlog is initialized to 0. Assuming accept()
system call is not invoked now.

1. 1st connection comes. invoke sk_acceptq_is_full(). sk-
>sk_ack_backlog=0 sk->sk_max_ack_backlog=1, function return 0 accept
this connection. Increase the sk->sk_ack_backlog
2. 2nd connection comes. invoke sk_acceptq_is_full(). sk-
>sk_ack_backlog=1 sk->sk_max_ack_backlog=1, function return 0 accept
this connection. Increase the sk->sk_ack_backlog
3. 3rd connection comes. invoke sk_acceptq_is_full(). sk-
>sk_ack_backlog=2 sk->sk_max_ack_backlog=1, function return 1. Refuse
this connection.

I think it has bugs. after listen system call. sk->sk_max_ack_backlog=1
but now it can accept 2 connections. The following patch can fix this
problem.

signed-off-by: Wei Dong <weid@np.css.fujitsu.com>

diff -ruN old/include/net/sock.h new/include/net/sock.h
--- old/include/net/sock.h	2007-02-03 08:38:21.000000000 -0500
+++ new/include/net/sock.h	2007-02-03 08:38:30.000000000 -0500
@@ -426,7 +426,7 @@
 
 static inline int sk_acceptq_is_full(struct sock *sk)
 {
-	return sk->sk_ack_backlog > sk->sk_max_ack_backlog;
+	return sk->sk_ack_backlog >= sk->sk_max_ack_backlog;
 }
 
 /*




