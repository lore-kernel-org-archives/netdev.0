From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] tc: cls_bpf: make ingress and egress qdiscs
 consistent
Date: Fri, 03 Apr 2015 16:11:15 -0700
Message-ID: <551F1E13.8050508@plumgrid.com>
References: <1428095784-7091-1-git-send-email-ast@plumgrid.com> <551F0A1B.3000100@iogearbox.net> <551F0B96.2090403@plumgrid.com> <551F0FE2.8000502@iogearbox.net> <551F1177.7090902@plumgrid.com> <551F1A14.7080205@iogearbox.net> <551F1C9B.6070908@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, Jamal Hadi Salim <jhs@mojatatu.com>,
	linux-api@vger.kernel.org, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33161 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752133AbbDCXLR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 19:11:17 -0400
Received: by paboj16 with SMTP id oj16so48483063pab.0
        for <netdev@vger.kernel.org>; Fri, 03 Apr 2015 16:11:16 -0700 (PDT)
In-Reply-To: <551F1C9B.6070908@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/3/15 4:04 PM, Alexei Starovoitov wrote:
> On 4/3/15 3:54 PM, Daniel Borkmann wrote:
>> On 04/04/2015 12:17 AM, Alexei Starovoitov wrote:
>> ...
>>> 1. there shouldn't be a choice at all for bpf. Because not pulling l2
>>> means it's bug.
>>
>> Yep, correct. You would also loose context for a possible dissection,
>> at best you only have skb->protocol.
>>
>>> 2. adding a flag means adding it to iproute2 with default off and making
>>> users forgetting it from time to time and have no way of knowing why
>>> their programs all of a sudden stopped working.
>>>
>>> classic falls under the same rules. It doesn't make sense at all to run
>>> a program on packet without L2 header. It's very odd both for classic
>>> and extended programs.
>>
>> Yep.
>>
>>> Two 'if' conditions in critical path is bogus argument, since these
>>> checks would be there in ingress as well. Same critical path.
>>
>> Why bogus? There would be no such test on the normal egress path,
>> where this is irrelevant. I wasn't talking about ingress here.
>>
>> I see the point regarding the user option. So, why not adding a flag
>> to tcf_proto_ops a la `.flags = CLS_REQUIRES_L2` that gets propagated
>> to tcf_proto, and only ingress_enqueue() would need to test if the
>> classifier imposes that requirement, so it can push/pull.
>
> ok. that sounds better, but neither tcf_proto nor tcf_proto_ops have
> 'flags' field today... well, I guess it's time to add flags there.
> Probably add 'flags' to tcf_proto_ops only and do fl->ops->flags in
> ingress_enqueue()?
>
> Will respin.

nope. will take it back.
that doesn't work, since this check cannot be done in ingress_enqueue(),
because it sees the pointer to first filter only, so both TCQ_F_INGRESS
flag and CLS_REQUIRES_L2 flag need to be checked inside
tc_classify_compat() which is a lot worse than my current patch.

So I prefer this patch still :)
