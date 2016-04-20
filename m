From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 0/2] tcp: Handle txstamp_ack when fragmenting/coalescing skbs
Date: Tue, 19 Apr 2016 22:50:46 -0700
Message-ID: <1461131448-1460418-1-git-send-email-kafai@fb.com>
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
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:11971 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751432AbcDTFv2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 01:51:28 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u3K5lUMe001713
	for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 22:51:27 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 22e0dt0xdp-2
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 22:51:27 -0700
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 eae5583206bb11e6811b24be0595f910-416c7c50 for <netdev@vger.kernel.org>;	Tue,
 19 Apr 2016 22:51:25 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset is to handle the txstamp-ack bit when
fragmenting/coalescing skbs.

The second patch depends on the recently posted series
for the net branch:
"tcp: Merge timestamp info when coalescing skbs"

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
