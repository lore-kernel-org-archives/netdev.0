From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V1 1/2] net: Header length compution function
Date: Mon, 28 Jul 2014 15:42:11 -0700 (PDT)
Message-ID: <20140728.154211.834824360197491109.davem@davemloft.net>
References: <1406546881-21863-2-git-send-email-amirv@mellanox.com>
	<53D66344.2050207@intel.com>
	<CAHA+R7NkWxbLM_T202o86G_0MgmpHG71jV+2_fQ3JCjZu9sw1g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, amirv@mellanox.com,
	edumazet@google.com, netdev@vger.kernel.org, ogerlitz@mellanox.com,
	yevgenyp@mellanox.com, idos@mellanox.com, eric.dumazet@gmail.com
To: cwang@twopensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33956 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751502AbaG1WmO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2014 18:42:14 -0400
In-Reply-To: <CAHA+R7NkWxbLM_T202o86G_0MgmpHG71jV+2_fQ3JCjZu9sw1g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <cwang@twopensource.com>
Date: Mon, 28 Jul 2014 14:26:08 -0700

> On Mon, Jul 28, 2014 at 7:50 AM, Alexander Duyck
> <alexander.h.duyck@intel.com> wrote:
>> On 07/28/2014 04:28 AM, Amir Vadai wrote:
>>> +u32 eth_frame_headlen(void *data, unsigned int len)
>>> +{
>>> +     const struct ethhdr *eth = data;
>>> +     struct sk_buff skb;
>>> +
>>> +     if (unlikely(len < ETH_HLEN))
>>> +             return len;
>>> +
>>> +     skb.protocol = eth->h_proto;
>>> +     skb.head = data + ETH_HLEN;
>>> +     skb.data = skb.head;
>>> +     skb_reset_network_header(&skb);
>>> +     skb.len = len - ETH_HLEN;
>>> +     skb.data_len = 0;
>>> +     return __skb_get_poff(&skb) + ETH_HLEN;
>>> +}
>>
>> I'm still not a big fan of allocating an sk_buff on the stack.  Seems
>> like it isn't maintainable and really opens things up to possible issues
>> if someone ever extends the __skb_get_poff call.  But I'm not going to
>> force the issue since for now this isn't impacting igb or ixgbe.
>>
> 
> +1
> 
> I think you can refactor the code to pass all these input as
> arguments instead of a whole skbuff.

I was going to say the same thing, but if you take a look it's not so
simple.

The code currently handles fragmented SKBs just fine, and you'd
therefore have to make a seperate code path for purely linear buffers,
and thus code duplication.

I'm still not sure what's better, to be honest.  Currently I'm leaning
towards allowing the version in this patch set, even though it's a bit
risky this is in the fast path so perhaps warrants such tricks for
performance's sake.
