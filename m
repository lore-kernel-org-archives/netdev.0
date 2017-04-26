From: Alexei Starovoitov <ast@fb.com>
Subject: Re: more test_progs...
Date: Wed, 26 Apr 2017 16:49:35 -0700
Message-ID: <cb627763-4df8-13ad-9dfe-88a79cccef64@fb.com>
References: <20170425.125217.1962662516948420246.davem@davemloft.net>
 <470871b2-c4c0-ad23-7fda-1a38c2736679@fb.com>
 <590056F2.5010600@iogearbox.net>
 <20170426.105511.742633353102583622.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:40020 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1033095AbdDZXt7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 19:49:59 -0400
In-Reply-To: <20170426.105511.742633353102583622.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/26/17 7:55 AM, David Miller wrote:
> From: Daniel Borkmann <daniel@iogearbox.net>
> Date: Wed, 26 Apr 2017 10:14:42 +0200
>
>> On 04/26/2017 05:42 AM, Alexei Starovoitov wrote:
>>> That sucks for sparc, of course. I don't have good suggestions for
>>> workaround other than marking tcphdr as packed :(
>>>  From code efficiency point of view it still will be faster than
>>> LD_ABS insn.
>>
>> Plus, ld_abs would also only work on skbs right now, and would
>> need JIT support for XDP. But it's also cumbersome to use with
>> f.e. IPv6, etc, so should not be encouraged, imo.
>>
>> One other option for !HAVE_EFFICIENT_UNALIGNED_ACCESS archs could
>> be to provide a bpf_skb_load_bytes() helper equivalent for XDP,
>> where you eventually do the memcpy() inside. We could see to inline
>> the helper itself to optimize it slightly.
>
> We have to do something that works transparently and always,
> regardless of whether HAVE_EFFICIENT_UNALIGNED_ACCESS is in
> play or not.
>
> And no, marking objects with __packed is not the answer.

I'm not suggesting to mark everything as __packed.
Why the following is not the answer?
index fd1e0832d409..c215dffd7189 100644
--- a/tools/testing/selftests/bpf/test_pkt_access.c
+++ b/tools/testing/selftests/bpf/test_pkt_access.c
@@ -19,13 +19,52 @@
  #define barrier() __asm__ __volatile__("": : :"memory")
  int _version SEC("version") = 1;

+struct __tcphdr {
+       __u16  source;
...
+       __u16  window;
+       __u16 check;
+       __u16  urg_ptr;
+}
+#if defined(__sparc__) || defined(__s390__)
+__packed
+#endif
+;
  SEC("test1")
  int process(struct __sk_buff *skb)
  {
         void *data_end = (void *)(long)skb->data_end;
         void *data = (void *)(long)skb->data;
         struct ethhdr *eth = (struct ethhdr *)(data);
-       struct tcphdr *tcp = NULL;
+       struct __tcphdr *tcp = NULL;
         __u8 proto = 255;

It's only needed for test_pkt_access.c test,
since it's being fancy and doing iph->ihl * 4.

Also such tcp->urg_ptr access into packed struct is more efficient
after JITing then sparc's own load_half_unaligned in asm, since it's
done inline and doesn't need a call.

Note that such tcphdr workaround is not necessary for more
real programs: test_l4lb.c and test_xdp.c, since they do:
if (iph->ihl != 5)
    return drop;

Another idea:
x64, arm64, ppc have efficient unaligned.
s390 and mips64 have special instructions to do unaligned
access efficiently and we can make verifier convert unknown-align
load/stores into special internal load/stores, so they can be
executed differently by interpreter and by JITs.
Does sparc64 have some special instructions like that?
