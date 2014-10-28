From: David Miller <davem@davemloft.net>
Subject: Re: [net v2] iptunnel: Fix iptunnel_xmit return code for stats
 maintenance
Date: Tue, 28 Oct 2014 14:53:24 -0400 (EDT)
Message-ID: <20141028.145324.563071277454050623.davem@davemloft.net>
References: <1414127459-16128-1-git-send-email-azhou@nicira.com>
	<CALnjE+rVpGsr_1cG1qSNQqRM7h7nG8SjZRujD_-pxGwrFY=Cmg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: azhou@nicira.com, netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34055 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750813AbaJ1Sx0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 14:53:26 -0400
In-Reply-To: <CALnjE+rVpGsr_1cG1qSNQqRM7h7nG8SjZRujD_-pxGwrFY=Cmg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin Shelar <pshelar@nicira.com>
Date: Fri, 24 Oct 2014 14:41:20 -0700

> On Thu, Oct 23, 2014 at 10:10 PM, Andy Zhou <azhou@nicira.com> wrote:
>> @@ -1636,13 +1638,15 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
>>         /* Need space for new headers (invalidates iph ptr) */
>>         err = skb_cow_head(skb, min_headroom);
>>         if (unlikely(err))
>> -               return err;
>> +               goto error;
>>
>>         if (vlan_tx_tag_present(skb)) {
>>                 if (WARN_ON(!__vlan_put_tag(skb,
>>                                             skb->vlan_proto,
>> -                                           vlan_tx_tag_get(skb))))
>> -                       return -ENOMEM;
>> +                                           vlan_tx_tag_get(skb)))) {
>> +                       err = -ENOMEM;
>> +                       goto error;
>> +               }
>>
> I just noticed that __vlan_put_tag() frees skb in case of error, so
> goto results in double free.
> maybe it is time we improve __vlan_put_tag() API, so that it is easier to use.

Agreed, and this would not be the first time we have been burnt by these
semantics.
