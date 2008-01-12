From: Dzianis Kahanovich <mahatma@bspu.unibel.by>
Subject: Re: [PATCH 2.6.23+] ingress classify to [nf]mark
Date: Sat, 12 Jan 2008 15:56:21 -0200
Message-ID: <4788FF45.702@bspu.unibel.by>
References: <47866C69.3080904@bspu.unibel.by> <1200001167.4443.38.camel@localhost>  <4787A663.4030204@bspu.unibel.by> <1200063541.4483.42.camel@localhost>  <4787D49E.6080906@bspu.unibel.by> <1200107027.4477.36.camel@localhost>
Reply-To: mahatma@eu.by
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bspu.unibel.by ([195.50.2.21]:49414 "EHLO
	mail.bspu.unibel.by" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751727AbYALN4c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2008 08:56:32 -0500
Received: from [10.200.200.1] ([10.200.200.1])
	by mail.bspu.unibel.by (8.14.1/8.14.0) with ESMTP id m0CDuS1H024924
	for <netdev@vger.kernel.org>; Sat, 12 Jan 2008 15:56:29 +0200
In-Reply-To: <1200107027.4477.36.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I in doubts only about "action continue".
To "and/or" behaviour one of best usage are (example):

# set bit 2 of mark to 0 (mark&0xfd|0) and continue
tc filter add ... prio 1 ... flowid fd:0 action continue
# continue
tc filter add ... prio 2 ...

- in current ingress_enqueue() code IMHO "case TC_ACT_OK:" will not reached 
for action continue. I use old (mark=...) solution only by this.

I think, "skb->mark = (skb->mark&(res.classid>>16))|TC_H_MIN(res.classid);" 
must be in the end of ingress_enqueue() before "return result". And not 
depended to "NET_CLS_ACT". But while not test it.
Or this:
---
#ifdef CONFIG_NET_SCH_INGRESS_TC2MARK
#ifdef CONFIG_NET_CLS_ACT
	skb->mark = (skb->mark&(res.classid>>16))|TC_H_MIN(res.classid);
#else
	skb->mark = res.classid;
#endif
#endif
         return result;
}


jamal wrote:

>> While I compose filter, I check flag ($TC_INDEX2MARK), tells me are patch
>> applied or no. If no - I use usual "-j MARK --set-mark", else I use classid to
>> change mark. All in ingress only. For example:
>> tc filter add dev eth0 parent ffff: protocol ip u32 ... action ipt -j MARK 0x10
>> are cname to:
>> tc filter add dev eth0 parent ffff: protocol ip u32 ... flowid :10
> 
> I thought you were doing something like this (to achieve your policy):
> 
> ----------
> major=1
> minor=12
> mark=`expr $major + $minor`
> #
> tc qdisc add dev XXX ingress
> tc filter add dev XXX parent ffff: protocol ip prio 5 \
> u32 blah bleh \
> flowid $major:$minor action \
> ipt -j mark --set-mark $mark
> ---------------
> 
>> - it use less code/modules and, in many cases, may be single/main goal to
>> ingress usage - pre-marking packets.
> 
> That is true and you would also have one less line in your policy; as an
> example in above the line "ipt -j mark --set-mark $mark" would be
> unnecessary; however, all the other lines in the policy setting _will be
> necessary_. And this + the fact there are many other values/shapes the
> default policy could take is essentially whats bothering me. 
> 
> In any case, scanning the current code it seems mark is no longer
> considered a netfilter-only metadatum - so it may not be semantically as
> obscene as i felt earlier; Can you pick something simpler for policy?
> example set the mark to whatever tc_index gets set?
> If you still could write the metadata action, we could use it to
> override mark, tc_index etc in addition.
> 
> cheers,
> jamal
> 
> 
> 


-- 
WBR,
Denis Kaganovich,  mahatma@eu.by  http://mahatma.bspu.unibel.by
