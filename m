From: Chuck Ebbert <cebbert.lkml@gmail.com>
Subject: LTP recv/recvmsg tests failing on 3.17
Date: Tue, 23 Sep 2014 09:11:08 -0500
Message-ID: <20140923091108.2788de76@as>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:40088 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751978AbaIWOLQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 10:11:16 -0400
Received: by mail-ob0-f182.google.com with SMTP id wo20so5078569obc.27
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2014 07:11:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

LTP tests recv01, recvfrom01 and recvmsg01 are reporting failure on
their "invalid flags" tests on 3.17. They pass a value of -1 for flags
and expect to get EINVAL back, but now they get EAGAIN. It looks like
this is due to:

commit 4ed2d765dfaccff5ebdac68e2064b59125033a3b
Author: Willem de Bruijn <willemb@google.com>
Date:   Mon Aug 4 22:11:49 2014 -0400

    net-timestamp: TCP timestamping

which adds this hunk to net/ipv4/tcp.c:

@@ -1617,6 +1630,9 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
        struct sk_buff *skb;
        u32 urg_hole = 0;
 
+       if (unlikely(flags & MSG_ERRQUEUE))
+               return ip_recv_error(sk, msg, len, addr_len);
+
        if (sk_can_busy_loop(sk) && skb_queue_empty(&sk->sk_receive_queue) &&
            (sk->sk_state == TCP_ESTABLISHED))
                sk_busy_loop(sk, nonblock);

Before this change, the first flag tested was MSG_OOB, which eventually
causes EINVAL to be returned. Now this flag gets tested first, and
ip_recv_err() returns EAGAIN.

LTP setting every flag and expecting behavior to remain unchanged is
probably wrong, but is EAGAIN correct here? I can't find any spec for
this.
