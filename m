From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v2 net-next 2/2] tc: make ingress and egress qdiscs consistent
Date: Tue, 07 Apr 2015 20:22:34 -0700
Message-ID: <55249EFA.5040405@plumgrid.com>
References: <1428455025-5945-1-git-send-email-ast@plumgrid.com>	<1428455025-5945-2-git-send-email-ast@plumgrid.com> <20150407.223549.335906307265617841.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, jiri@resnulli.us, jhs@mojatatu.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:36066 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752267AbbDHDWi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 23:22:38 -0400
Received: by iebrs15 with SMTP id rs15so64015347ieb.3
        for <netdev@vger.kernel.org>; Tue, 07 Apr 2015 20:22:38 -0700 (PDT)
In-Reply-To: <20150407.223549.335906307265617841.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/7/15 7:35 PM, David Miller wrote:
> From: Alexei Starovoitov <ast@plumgrid.com>
> Date: Tue,  7 Apr 2015 18:03:45 -0700
>
>> +
>> +	/* don't recompute skb->csum back and forth while pushing/pulling L2 */
>> +	__skb_push(skb, hard_header_len);
>>   	result = tc_classify(skb, fl, &res);
>> +	__skb_pull(skb, hard_header_len);
>
> This is not legal.
>
> This SKB can be referenced by other entities, such as AF_PACKET
> sockets and other network taps on input.  You absolutely do not
> have private access to this SKB object, and any modification you
> make to it will be seen by others.
>
> Therefore you cannot push and pull the headers, because that
> modification will be seen by the other entities referencing this SKB.

ohh, yes. Spent too much time looking at TC that forgot the obvious.
Was modeling this one by skb_defer_rx_timestamp() which is called before
taps. My v1 patch was obviously broken too :(

> And you do not want to add this expensive operation here.
>
> That would be really stupid overhead just to accomodate BPF things.

skb_share_check is only expensive if taps are active and
not only cls_bpf, but ematch and bunch of other cls/acts assume L2,
but it seems no one cares about using them with ingress, so I'll go back
to cls_bpf specific skb_share_check and push.
Other classifiers that care about attaching to ingress would need
to do the same thing or play nicely with offsets. Fair enough.
