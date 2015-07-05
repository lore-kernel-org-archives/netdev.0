From: roopa <roopa@cumulusnetworks.com>
Subject: Re: Summary lightweight tunnel discussion at NFWS
Date: Sat, 04 Jul 2015 23:21:45 -0700
Message-ID: <5598CCF9.4090407@cumulusnetworks.com>
References: <1434689355-4088-3-git-send-email-roopa@cumulusnetworks.com> <20150703100023.GH26182@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, rshearma@brocade.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34771 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750859AbbGEJU2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jul 2015 05:20:28 -0400
Received: by pabvl15 with SMTP id vl15so79448640pab.1
        for <netdev@vger.kernel.org>; Sun, 05 Jul 2015 02:20:28 -0700 (PDT)
In-Reply-To: <20150703100023.GH26182@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/3/15, 3:00 AM, Thomas Graf wrote:
> On 06/18/15 at 09:49pm, Roopa Prabhu wrote:
>> +#ifdef CONFIG_LWTUNNEL
>> +		if (fi->fib_nh->nh_lwtstate) {
>> +			struct lwtunnel_state *lwtstate;
>> +
>> +			lwtstate = fi->fib_nh->nh_lwtstate;
>> +			if (nla_put_u16(skb, RTA_ENCAP_TYPE, lwtstate->type))
>> +				goto nla_put_failure;
>> +			lwtunnel_fill_encap(skb, lwtstate);
>> +		}
>>   	}
>> +#endif
> Misplaced #endif ;-)
Thx. I have fixed this since,...did not realize it came in as part of 
this RFC series.
>
> Other than that I managed to rebase my changes onto yours and it
> looks clean.
Glad to know!. thanks Thomas. I had a few more changes (mostly 
cleanup/bug fixes, ipv6 support and mostly earlier feedback from you)
in my local clone, pushed it to my github tree just now.
This also tries to not use CONFIG_LWTUNNEL all over the place. I had it 
that way initially also because of fib struct members
under #ifdef CONFIG_LWTUNNEL. (If we think at a later point that it is 
better to #ifdef CONFIG_LWTUNNEL fib struct members,
I can bring some of that back in). And, Only control path (rtnetlink) 
for ipv6 mpls iptunnels has been tested.

>
> Since we also discussed this a bit at NFWS, I'm enclosing a quick
> summary:
>
>   * Overall consensus that a lightweight flow based encapsulation
>     makes sense.
>   * Realization that what we actually want is stackable skb metadata
>     between layers without over engineering it.
>   * Consensus to avoid adding it to skb_shared_info and try to reuse
>     the skb dst field.
>   * New dst_metadata type similar to xfrm_dst which can carry metadata
>     such as encapsulation instructions/information.
>   * Can be made stackable to implement nested encapsulation if needed.
>     Left out in the beginning to keep it simple.
>   * Possible optimization option by putting the dst_metadata into a
>     per cpu scratch buffer or stack without taking a reference and
>     only force the reference & allocation when the skb is about to
>     be queued. The regular fast path should never queue a skb with
>     dst metadata attached.
Thanks for the summary. this helps.
I have been thinking of moving lwtstate from rtable to struct dst_entry.
I will also look at the dst_metadata.
