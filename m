From: Richard Alpe <richard.alpe@ericsson.com>
Subject: Re: [PATCH net-next 04/14] tipc: add sock dump to new netlink api
Date: Mon, 15 Sep 2014 09:55:24 +0200
Message-ID: <54169B6C.5060709@ericsson.com>
References: <1410424167-17427-1-git-send-email-richard.alpe@ericsson.com>	<1410424167-17427-5-git-send-email-richard.alpe@ericsson.com> <20140912.171038.1165432718811920305.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg23.ericsson.net ([193.180.251.37]:46960 "EHLO
	sesbmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752579AbaIOH40 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 03:56:26 -0400
In-Reply-To: <20140912.171038.1165432718811920305.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/12/2014 11:10 PM, David Miller wrote:
> From: <richard.alpe@ericsson.com>
> Date: Thu, 11 Sep 2014 10:29:17 +0200
>
>> +	list_for_each_entry_from(p, &tsk->publications, pport_list) {
>> +		publ = nla_nest_start(skb, TIPC_NLA_SOCK_PUBL);
>> +		if (nla_put_u32(skb, TIPC_NLA_PUBL_TYPE, p->type))
>> +			goto msg_full;
>> +		if (nla_put_u32(skb, TIPC_NLA_PUBL_LOWER, p->lower))
>> +			goto msg_full;
>> +		if (nla_put_u32(skb, TIPC_NLA_PUBL_UPPER, p->upper))
>> +			goto msg_full;
>> +		nla_nest_end(skb, publ);
>> +	}
>> +
>> +	*prev_publ = 0;
>> +
>> +	return 0;
>> +
>> +msg_full:
>> +	*prev_publ = p->key;
>> +	nla_nest_cancel(skb, publ);
>
> This restart mechanism is broken.
>
> You can't public nested information this way.
>
> What happens in your code is that if we hit the limit in the middle of
> adding the publications, the next time we'll put the same socket into
> the netlink message and then the rest of the nested publications.
> That's malformed.
Yes, that's true.

> You can't just say sometimes you'll partially list the set of nested
> attributes in an object, you must public the entire object fully in
> the netlink message or skip the object entirely.
Ok. I bluntly assumed we could put some reassemble logic in the client 
as the end integrity should still be preserved(?).

> I would suggest that you instead size the amount of space you'll
> need for at least the first socket being listed, and if NLMSG_GOODSIZE
> is insufficient, allocate as much as you will actually need.
>
> Then you put full socket netlink blobs in there, including all nested
> attributes, and then stop and reset back the the most recent full socket
> published if you run out of space.
The amount of publications a socket can have is large (~65 000). Do you 
still think this a viable solution?

I thought about querying socket publications individually. Meaning that 
the user-space tool would have to first list sockets, then ask for there 
publications. This would remove the nested malformation but create some 
overhead and increase the potential port-gone window. What do you think?

Thanks for the review, much appreciated!
/Richard
