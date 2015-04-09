From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v3 net-next 2/2] tc: add 'needs_l2' flag to ingress qdisc
Date: Wed, 08 Apr 2015 22:20:47 -0700
Message-ID: <55260C2F.608@plumgrid.com>
References: <1428535575-7736-2-git-send-email-ast@plumgrid.com>	<20150408.224404.1913719826015357860.davem@davemloft.net>	<5525EC69.1080606@plumgrid.com> <20150408.231456.1063648455572594170.davem@davemloft.net> <5525F48F.5030108@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, tgraf@suug.ch, jiri@resnulli.us,
	jhs@mojatatu.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:36322 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751607AbbDIFUu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 01:20:50 -0400
Received: by iebrs15 with SMTP id rs15so92385663ieb.3
        for <netdev@vger.kernel.org>; Wed, 08 Apr 2015 22:20:49 -0700 (PDT)
In-Reply-To: <5525F48F.5030108@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/8/15 8:39 PM, Alexei Starovoitov wrote:
> On 4/8/15 8:14 PM, David Miller wrote:
>> From: Alexei Starovoitov <ast@plumgrid.com>
>> Date: Wed, 08 Apr 2015 20:05:13 -0700
>>
>>> I'm sure there is a way to propagate the offset into the programs.
>>> It's not about efficiency of programs, but about consistency.
>>> Programs should know nothing about kernel. Sending network offset
>>> into them is exposing this very specific kernel behavior.
>>
>> It can be performed by the data access helpers the JIT'd programs
>> have to invoke anyways.
>
> hmm, not sure what you mean.
> Let's take specific line from sockex1_kern.c:
> int index = load_byte(skb, ETH_HLEN + offsetof(struct iphdr, protocol));
> this C code is compiled into
> R0 = LD_ABS_B 23
> (instruction with fixed offset)
> which is being interpreted as:
> skb_header_pointer(skb, 23, 1, buffer);
> and similar by JITs which are using doing
> r0 = *(char *)(skb->data + 23)
> in this case.
>
> Are you proposing to change semantics of LD_ABS instruction to use
> skb->head + skb->mac_header instead of skb->data in interpreter
> and in all JITs?
> Performance wise it will be ok, since JITs can cache that pointer.
> But that will be huge and very risky change.
> I'm not sure yet whether all programs will keep working afterwards.
> Is it really worth taking so much risk vs push/pull of L2?
> If you say, let's take the risk, sure, I can try hacking all the bits
> and see what the cost.

have to correct myself.
we cannot change the meaning of ld_abs, since for dgram sockets
offset is actually not pointing to L2.
af_packet is doing:
  if (sk->sk_type != SOCK_DGRAM)
       skb_push(skb, skb->data - skb_mac_header(skb));
  res = run_filter(skb, sk, snaplen);
so not everything assumes L2. raw socket taps, ppp, team, cls_bpf
certainly want to see L2.
I still hate to see ingress and egress cls/act programs to be different.
af_packet also does:
skb = skb_share_check(skb, GFP_ATOMIC);

so Dave, would you consider early_ingress_l2() hook that doesn't need
to do skb_share_check ?
If not, the only option I have is to introduce a set of helpers
that can read from packet where offset is always starts at L2.
Then we can say that cls/act_bpf should never use ld_abs/ld_ind
instructions if they want to run on both ingress and egress and
should use these new read helpers instead.
