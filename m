From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v3 net-next 2/2] tc: add 'needs_l2' flag to ingress qdisc
Date: Wed, 08 Apr 2015 20:39:59 -0700
Message-ID: <5525F48F.5030108@plumgrid.com>
References: <1428535575-7736-2-git-send-email-ast@plumgrid.com>	<20150408.224404.1913719826015357860.davem@davemloft.net>	<5525EC69.1080606@plumgrid.com> <20150408.231456.1063648455572594170.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, tgraf@suug.ch, jiri@resnulli.us,
	jhs@mojatatu.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35050 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754373AbbDIDkA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 23:40:00 -0400
Received: by pabtp1 with SMTP id tp1so30044190pab.2
        for <netdev@vger.kernel.org>; Wed, 08 Apr 2015 20:40:00 -0700 (PDT)
In-Reply-To: <20150408.231456.1063648455572594170.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/8/15 8:14 PM, David Miller wrote:
> From: Alexei Starovoitov <ast@plumgrid.com>
> Date: Wed, 08 Apr 2015 20:05:13 -0700
>
>> I'm sure there is a way to propagate the offset into the programs.
>> It's not about efficiency of programs, but about consistency.
>> Programs should know nothing about kernel. Sending network offset
>> into them is exposing this very specific kernel behavior.
>
> It can be performed by the data access helpers the JIT'd programs
> have to invoke anyways.

hmm, not sure what you mean.
Let's take specific line from sockex1_kern.c:
int index = load_byte(skb, ETH_HLEN + offsetof(struct iphdr, protocol));
this C code is compiled into
R0 = LD_ABS_B 23
(instruction with fixed offset)
which is being interpreted as:
skb_header_pointer(skb, 23, 1, buffer);
and similar by JITs which are using doing
r0 = *(char *)(skb->data + 23)
in this case.

Are you proposing to change semantics of LD_ABS instruction to use
skb->head + skb->mac_header instead of skb->data in interpreter
and in all JITs?
Performance wise it will be ok, since JITs can cache that pointer.
But that will be huge and very risky change.
I'm not sure yet whether all programs will keep working afterwards.
Is it really worth taking so much risk vs push/pull of L2?
If you say, let's take the risk, sure, I can try hacking all the bits
and see what the cost.
