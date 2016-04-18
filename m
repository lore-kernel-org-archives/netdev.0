From: Martin KaFai Lau <kafai@fb.com>
Subject: [RFC PATCH v2 net-next 0/7] tcp: Make use of MSG_EOR in tcp_sendmsg
Date: Mon, 18 Apr 2016 15:46:02 -0700
Message-ID: <1461019569-3037369-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Soheil Hassas Yeganeh <soheil.kdev@gmail.com>,
	Willem de Bruijn <willemb@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Kernel Team <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:37719 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751473AbcDRWqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 18:46:36 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u3IMi0UH006412
	for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 15:46:30 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 22d1yjtj7d-2
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 15:46:30 -0700
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 62ae06da05b711e6b04f24be0595f910-3e3f8c50 for <netdev@vger.kernel.org>;	Mon,
 18 Apr 2016 15:46:27 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
~ Due to the lacking cmsg support in packetdrill (or I just
  could not find it), a BPF prog is used to kprobe
  to sock_queue_err_skb() and print out the value of
  serr->ee.ee_data.  The BPF prog (run-able from bcc) is
  attached at the end.

Some of the following is stolen from a commit message of
the following patch to serve as a high level description of
the objective in this series:

This patchset allows the user process to use MSG_EOR during
tcp_sendmsg to tell the kernel that it is the last byte
of an application response message.

It is currently useful when the end-user has turned on any bit of the
SOF_TIMESTAMPING_TX_RECORD_MASK (either by setsockopt or cmsg).
The kernel will then mark the newly added tcb->eor_info bit so
that the shinfo->tskey will not be overwritten (i.e. lost) in
the later skb append/collapse operation.

Each skb can only track one tskey (which is the seq number of the
last byte of the message).   To allow tracking the last byte of
multiple response messages (e.g. HTTP2), this patch takes an
approach by not appending to the previous skb during tcp_sendmsg
if this previous skb's eor information (only shinfo->tskey for now)
will be overwritten.  A similar case also happens during
retransmission.

This approach avoids introducing another list to track the tskey.
The downside is that it will have less tso benefit and/or more
outgoing packets.  Practically, due to the amount of measurement
data generated, sampling is usually used in production. (i.e. not
every connection is tracked).

One of our use case is at the webserver.  The webserver tracks
the HTTP2 response latency by measuring when the webserver sends
the first byte to the socket till the TCP ACK of the last byte
is received.  In the cases where we don't have client side
measurement, measuring from the server side is the only option.
In the cases we have the client side measurement, the server side
data can also be used to justify/cross-check-with the client
side data.

The TCP PRR paper [1] also measures a similar metrics:
"The TCP latency of a HTTP response when the server sends the first
byte until it receives the acknowledgment (ACK) for the last byte."

[1] Proportional Rate Reduction for TCP:
http://static.googleusercontent.com/media/research.google.com/en//pubs/archive/37486.pdf

BPF prog used for testing:
~~~~~
#!/usr/bin/env python

from __future__ import print_function
from bcc import BPF

bpf_text = """
#include <uapi/linux/ptrace.h>
#include <net/sock.h>
#include <bcc/proto.h>
#include <linux/errqueue.h>

#ifdef memset
#undef memset
#endif

int trace_err_skb(struct pt_regs *ctx)
{
	struct sk_buff *skb = (struct sk_buff *)ctx->si;
	struct sock *sk = (struct sock *)ctx->di;
	struct sock_exterr_skb *serr;
	u32 ee_data = 0;

	if (!sk || !skb)
		return 0;

	serr = SKB_EXT_ERR(skb);
	bpf_probe_read(&ee_data, sizeof(ee_data), &serr->ee.ee_data);
	bpf_trace_printk("ee_data:%u\\n", ee_data);

	return 0;
};
"""

b = BPF(text=bpf_text)
b.attach_kprobe(event="sock_queue_err_skb", fn_name="trace_err_skb")
print("Attached to kprobe")
b.trace_print()
