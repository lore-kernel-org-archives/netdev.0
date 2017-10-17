From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC] sctp: suspicious rcu_read_lock() in sctp_packet_config()
Date: Tue, 17 Oct 2017 06:45:56 -0700
Message-ID: <1508247956.31614.103.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Wei Wang <weiwan@google.com>,
        edumazet@google.com
To: Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Xin Long <lucien.xin@gmail.com>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:50968 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752540AbdJQNp6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 09:45:58 -0400
Received: by mail-pg0-f44.google.com with SMTP id y7so1459017pgb.7
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 06:45:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SCTP experts.

syszkaller reported a few crashes in sctp_packet_config() with invalid
access to a deleted dst.

The rcu_read_lock() in sctp_packet_config() is suspect.

It does not protect anything at the moment.

If we expect tp->dst to be manipulated/changed by another cpu/thread,
then we need proper rcu protection.

Following patch to show what would be a minimal change (but obviously
bigger changes are needed, like sctp_transport_pmtu_check() and
sctp_transport_dst_check(), and proper sparse annotations)


BTW, sparse throws a lot of errors, any volunteer to clean this mess ?

make C=2 M=net/sctp

Thanks.

diff --git a/net/sctp/output.c b/net/sctp/output.c
index 4a865cd06d76cd5b2aa417de618da3203f7b53e4..d7f320f5acc271189ec9474795b6ececed7ad2b9 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -86,6 +86,7 @@ void sctp_packet_config(struct sctp_packet *packet, __u32 vtag,
 {
 	struct sctp_transport *tp = packet->transport;
 	struct sctp_association *asoc = tp->asoc;
+	struct dst_entry *dst;
 	struct sock *sk;
 
 	pr_debug("%s: packet:%p vtag:0x%x\n", __func__, packet, vtag);
@@ -121,17 +122,15 @@ void sctp_packet_config(struct sctp_packet *packet, __u32 vtag,
 			sctp_packet_append_chunk(packet, chunk);
 	}
 
-	if (!tp->dst)
-		return;
-
 	/* set packet max_size with gso_max_size if gso is enabled*/
 	rcu_read_lock();
-	if (__sk_dst_get(sk) != tp->dst) {
-		dst_hold(tp->dst);
-		sk_setup_caps(sk, tp->dst);
+	dst = rcu_dereference(tp->dst);
+	if (dst) {
+		if (__sk_dst_get(sk) != dst && dst_hold_safe(dst))
+			sk_setup_caps(sk, dst);
+		packet->max_size = sk_can_gso(sk) ? dst->dev->gso_max_size
+						  : asoc->pathmtu;
 	}
-	packet->max_size = sk_can_gso(sk) ? tp->dst->dev->gso_max_size
-					  : asoc->pathmtu;
 	rcu_read_unlock();
 }
 
