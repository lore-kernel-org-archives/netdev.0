From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH v4 net-next 0/3] tcp: Make use of MSG_EOR in tcp_sendmsg
Date: Mon, 25 Apr 2016 14:44:47 -0700
Message-ID: <1461620690-1081063-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Soheil Hassas Yeganeh <soheil@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Kernel Team <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:25575 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965004AbcDYVpI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 17:45:08 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u3PLhTcW030259
	for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 14:45:07 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 22g4qb0hhb-2
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 14:45:07 -0700
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.223.100.97) with ESMTP	id
 f804974a0b2e11e6a27b24be0593f280-349f1c50 for <netdev@vger.kernel.org>;	Mon,
 25 Apr 2016 14:45:04 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v4:
~ Do not set eor bit in do_tcp_sendpages() since there is
  no way to pass MSG_EOR from the userland now.
~ Avoid rmw by testing MSG_EOR first in tcp_sendmsg().
~ Move TCP_SKB_CB(skb)->eor test to a new helper
  tcp_skb_can_collapse_to() (suggested by Soheil).
~ Add some packetdrill tests.

v3:
~ Separate EOR marking from the SKBTX_ANY_TSTAMP logic.
~ Move the eor bit test back to the loop in tcp_sendmsg and
  tcp_sendpage because there could be >1 threads doing
  sendmsg.
~ Thanks to Eric Dumazet's suggestions on v2.
~ The TCP timestamp bug fixes are separated into other threads.

v2:
~ Rework based on the recent work
  "add TX timestamping via cmsg" by
  Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
~ This version takes the MSG_EOR bit as a signal of
  end-of-response-message and leave the selective
  timestamping job to the cmsg
~ Changes based on the v1 feedback (like avoid
  unlikely check in a loop and adding tcp_sendpage
  support)
~ The first 3 patches are bug fixes.  The fixes in this
  series depend on the newly introduced txstamp_ack in
  net-next.  I will make relevant patches against net after
  getting some feedback.
~ The test results are based on the recently posted net fix:
  "tcp: Fix SOF_TIMESTAMPING_TX_ACK when handling dup acks"

One potential use case is to use MSG_EOR with
SOF_TIMESTAMPING_TX_ACK to get a more accurate
TCP ack timestamping on application protocol with
multiple outgoing response messages (e.g. HTTP2).

One of our use case is at the webserver.  The webserver tracks
the HTTP2 response latency by measuring when the webserver sends
the first byte to the socket till the TCP ACK of the last byte
is received.  In the cases where we don't have client side
measurement, measuring from the server side is the only option.
In the cases we have the client side measurement, the server side
data can also be used to justify/cross-check-with the client
side data.
