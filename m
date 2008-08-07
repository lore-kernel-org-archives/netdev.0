From: "Adam Langley" <agl@imperialviolet.org>
Subject: Code query: tcp_request_sock deallocation
Date: Thu, 7 Aug 2008 16:07:55 -0700
Message-ID: <396556a20808071607o7157932bt373d4b9a5e1bbedb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.237]:12321 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752955AbYHGXH5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 19:07:57 -0400
Received: by rv-out-0506.google.com with SMTP id k40so720971rvb.1
        for <netdev@vger.kernel.org>; Thu, 07 Aug 2008 16:07:55 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm hoping someone can explain part of the lifetime of a request_sock for me.

In tcp_minisocks.c:tcp_check_req (near the bottom) we have the code
path for upgrading a request_sock to a full sock in the case that we
get a valid ack:

child = inet_csk(sk)->icsk_af_ops->syn_recv_sock(sk, skb,
								 req, NULL);
if (child == NULL)
	goto listen_overflow;

// MD5 stuff omitted

inet_csk_reqsk_queue_unlink(sk, req, prev);
inet_csk_reqsk_queue_removed(sk, req);

inet_csk_reqsk_queue_add(sk, req, child);

Those last three lines appear to remove the request_sock from the
queue (fine), can then re-enqueue it at the end of the queue with ->sk
pointing to the new ESTABLISHED socket. At this point I loose track,
because I don't see where the request_sock is free'ed, except maybe
from inet_csk_reqsk_queue_prune.

Other code paths in that function (like goto embryonic_reset) end up
removing it from the queue and freeing it immediately (with
inet_csk_reqsk_queue_drop).

I wondered if it was enqueued in order to be reused, but new
request_socks seem to be alloced rather than taken from that queue.


Thanks

AGL

-- 
Adam Langley agl@imperialviolet.org http://www.imperialviolet.org
