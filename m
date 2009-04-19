From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: What is lock_sock() before skb_free_datagram() for?
Date: Sun, 19 Apr 2009 14:12:15 +0900
Message-ID: <200904191412.GIF95380.SVFJOHOFOQtLMF@I-love.SAKURA.ne.jp>
References: <200904181804.AHC13042.VHFFOOJOFLSQMt@I-love.SAKURA.ne.jp>
	<20090418.020837.106276006.davem@davemloft.net>
	<200904182123.HFF13509.MVSJtQHFLFOFOO@I-love.SAKURA.ne.jp>
	<20090418.212842.163717535.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from wine.ocn.ne.jp ([122.1.235.145]:63844 "EHLO smtp.wine.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750893AbZDSFMR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Apr 2009 01:12:17 -0400
In-Reply-To: <20090418.212842.163717535.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> We worked so hard to split out this common code, it is simply
> a non-starter for anyone to start putting protocol specific test
> into here, or even worse to move this code back to being locally
> copied into every protocol implementation.
You don't want LSM modules to perform protocol specific test inside
__skb_recv_datagram(). I see.

> You may want to think about how you can achieve your goals by putting
> these unpleasant hooks into some other location.
May I insert security_socket_post_recv_datagram() into the caller of
skb_recv_datagram() (as shown below)?

 include/linux/security.h |   39 +++++++++++++++++++++++++++++++++++++++
 net/ipv4/raw.c           |    5 +++++
 net/ipv4/udp.c           |    7 +++++++
 net/ipv6/raw.c           |    5 +++++
 net/ipv6/udp.c           |    7 +++++++
 net/socket.c             |    5 +++++
 security/capability.c    |   13 +++++++++++++
 security/security.c      |   11 +++++++++++
 8 files changed, 92 insertions(+)

--- security-testing-2.6.git.orig/net/ipv4/raw.c
+++ security-testing-2.6.git/net/ipv4/raw.c
@@ -666,6 +666,11 @@ static int raw_recvmsg(struct kiocb *ioc
 	skb = skb_recv_datagram(sk, flags, noblock, &err);
 	if (!skb)
 		goto out;
+	err = security_socket_post_recv_datagram(sk, skb, flags);
+	if (err) {
+		skb_kill_datagram(sk, skb, flags);
+		goto out;
+	}
 
 	copied = skb->len;
 	if (len < copied) {
--- security-testing-2.6.git.orig/net/ipv4/udp.c
+++ security-testing-2.6.git/net/ipv4/udp.c
@@ -901,6 +901,13 @@ try_again:
 				  &peeked, &err);
 	if (!skb)
 		goto out;
+	err = security_socket_post_recv_datagram(sk, skb, flags);
+	if (err) {
+		lock_sock(sk);
+		skb_kill_datagram(sk, skb, flags);
+		release_sock(sk);
+		goto out;
+	}
 
 	ulen = skb->len - sizeof(struct udphdr);
 	copied = len;
--- security-testing-2.6.git.orig/net/ipv6/raw.c
+++ security-testing-2.6.git/net/ipv6/raw.c
@@ -465,6 +465,11 @@ static int rawv6_recvmsg(struct kiocb *i
 	skb = skb_recv_datagram(sk, flags, noblock, &err);
 	if (!skb)
 		goto out;
+	err = security_socket_post_recv_datagram(sk, skb, flags);
+	if (err) {
+		skb_kill_datagram(sk, skb, flags);
+		goto out;
+	}
 
 	copied = skb->len;
 	if (copied > len) {
--- security-testing-2.6.git.orig/net/ipv6/udp.c
+++ security-testing-2.6.git/net/ipv6/udp.c
@@ -208,6 +208,13 @@ try_again:
 				  &peeked, &err);
 	if (!skb)
 		goto out;
+	err = security_socket_post_recv_datagram(sk, skb, flags);
+	if (err) {
+		lock_sock(sk);
+		skb_kill_datagram(sk, skb, flags);
+		release_sock(sk);
+		goto out;
+	}
 
 	ulen = skb->len - sizeof(struct udphdr);
 	copied = len;
