From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net 0/2] tcp: Merge timestamp info when coalescing skbs
Date: Tue, 19 Apr 2016 22:39:27 -0700
Message-ID: <1461130769-1442865-1-git-send-email-kafai@fb.com>
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
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:56430 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751791AbcDTFjz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 01:39:55 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u3K5aPOl017661
	for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 22:39:55 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 22e2gs0axh-1
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 22:39:55 -0700
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 4de9107406ba11e6b2650002c95209d8-66d7c50 for <netdev@vger.kernel.org>;	Tue,
 19 Apr 2016 22:39:52 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series is separated from the RFC series related to
tcp_sendmsg(MSG_EOR) and it is targeting for the net branch.
This patchset is focusing on fixing cases where TCP
timestamp could be lost after coalescing skbs.

A BPF prog is used to kprobe to sock_queue_err_skb()
and print out the value of serr->ee.ee_data.  The BPF
prog (run-able from bcc) is attached here:

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
