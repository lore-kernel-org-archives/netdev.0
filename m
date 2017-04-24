From: Alexei Starovoitov <ast@fb.com>
Subject: Re: test_progs packed...
Date: Mon, 24 Apr 2017 16:16:49 -0700
Message-ID: <ba98a264-e398-af62-fc65-b5f34317b016@fb.com>
References: <20170424.190601.2066346847263955701.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <daniel@iogearbox.net>, <kafai@fb.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:54901 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S977612AbdDXXRL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 19:17:11 -0400
In-Reply-To: <20170424.190601.2066346847263955701.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/24/17 4:06 PM, David Miller wrote:
>
> Alexei, why the packed attribute usage in test_progs.c?
>
> There should be no reason for this and it results in the object(s)
> having odd addresses (and thus be unaligned) on sparc.

because in:
static struct {
         struct ethhdr eth;
         struct iphdr iph;
         struct tcphdr tcp;
} __packed pkt_v4 = {

iph is 4 byte aligned and eth is 2-byte.
We can add 2 byte hole in front of eth, but it's ugly since clean:
bpf_prog_test_run(prog_fd, 100000, &pkt_v4, sizeof(pkt_v4),
would need to deal with this extra padding explicitly.

It's only a user space thing and not in critical path,
so inefficient loads shouldn't be a problem.

You're bringing a good point that bpf_prog_test_run_skb() on
the kernel side should probably do:
skb_reserve(skb, NET_SKB_PAD + NET_IP_ALIGN);
