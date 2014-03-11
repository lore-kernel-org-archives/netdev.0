From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 01/11] bonding: Call dev_kfree_skby_any instead of kfree_skb.
Date: Mon, 10 Mar 2014 22:31:49 -0700
Message-ID: <87y50hl2re.fsf@xmission.com>
References: <871ty9qvaf.fsf_-_@xmission.com> <87vbvlpgnk.fsf_-_@xmission.com>
	<1394509467.21721.2.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140311.004217.1616529960369263682.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:51172 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752562AbaCKFb4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 01:31:56 -0400
In-Reply-To: <20140311.004217.1616529960369263682.davem@davemloft.net> (David
	Miller's message of "Tue, 11 Mar 2014 00:42:17 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 10 Mar 2014 20:44:27 -0700
>
>> On Mon, 2014-03-10 at 20:18 -0700, Eric W. Biederman wrote:
>>> -			consume_skb(skb);
>>> +			dev_consume_skb_any(skb);
>> 
>> Why is this needed ? AFAIK we run in softirq here.
>> 
>>>  			return ret;
>>>  		}
>>>  	}
>>> @@ -1132,7 +1132,7 @@ static rx_handler_result_t bond_handle_frame(struct sk_buff **pskb)
>>>  
>>>  		if (unlikely(skb_cow_head(skb,
>>>  					  skb->data - skb_mac_header(skb)))) {
>>> -			kfree_skb(skb);
>>> +			dev_kfree_skb_any(skb);
>> 
>> same here.
>
> These changes eminate from a recent discussion about netpoll, which can
> call into the driver from hardware interrupts, particularly when netconsole
> services a printk from hardware interrupt context.
>
> bnx2x already makes similar ammends.
>
> I hope that Eric B. here audited to make sure he's only doing this
> transformation in situations that actually need this treatment for
> the above mentioned issue.

It looks like our replies crossed.  Yes every location that I changed is
a location that I can currently find a code path to from a printk in a
hard irq context.

Furthermore the difference between dev_kfree_skb/kfree_skb and
dev_kfree_skb_any is simply a test to see if you are in interrupt
context so there should be no functional differences except
when we make it to these code paths in interrupt context.

Eric
