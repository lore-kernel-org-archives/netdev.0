From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] vlan: pull on __vlan_insert_tag error path and fix
 csum correction
Date: Sat, 02 Apr 2016 02:04:20 +0200
Message-ID: <56FF0C84.5030300@iogearbox.net>
References: <244f8d5684800cc98545932aa6851bf73f7326e2.1459503053.git.daniel@iogearbox.net> <20160401.150000.1165010490623034251.davem@davemloft.net> <56FEE80C.9080806@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, alexei.starovoitov@gmail.com, jesse@kernel.org,
	tom@herbertland.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34454 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752095AbcDBAEc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 20:04:32 -0400
In-Reply-To: <56FEE80C.9080806@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/01/2016 11:28 PM, Daniel Borkmann wrote:
> On 04/01/2016 09:00 PM, David Miller wrote:
>> From: Daniel Borkmann <daniel@iogearbox.net>
>> Date: Fri,  1 Apr 2016 11:41:03 +0200
>>
>>> Moreover, I noticed that when in the non-error path the __skb_pull()
>>> is done and the original offset to mac header was non-zero, we fixup
>>> from a wrong skb->data offset in the checksum complete processing.
>>>
>>> So the skb_postpush_rcsum() really needs to be done before __skb_pull()
>>> where skb->data still points to the mac header start.
>>
>> Ugh, what a mess, are you sure any of this is right even after your
>> change?  What happens (outside of the csum part) is this:
>>
>>     __skb_push(offset);
>>     __vlan_insert_tag(); {
>>         skb_push(VLAN_HLEN);
>>     ...
>>         memmove(skb->data, skb->data + VLAN_HLEN, 2 * ETH_ALEN);
>>     }
>>     __skb_pull(offset);
>>
>> If I understand this correctly, the last pull will therefore put
>> skb->data pointing at vlan_ethhdr->h_vlan_TCI of the new VLAN header
>> pushed by __vlan_insert_tag().
>>
>> That is assuming skb->data began right after the original ethernet
>> header.
>
> Yes, this is correct. Now, continuing this train of thought: you have
> skb->data pointing _currently_ at vlan_ethhdr->h_vlan_TCI.
>
> And then you call:
>
>    skb_postpush_rcsum(skb, skb->data + (2 * ETH_ALEN), VLAN_HLEN);
>
> So, we point from the ->vlan_TCI + (2 * ETH_ALEN) as start offset, and
> with VLAN_HLEN (= 4 bytes that we added) as length for the csum
> correction as input. So, we point way beyond what we actually wanted
> to fixup wrt csum, no?
>
> But what we actually want to sum is [h_vlan_proto + h_vlan_TCI], which
> is where above skb_postpush_rcsum() call points to _before_ the last
> __skb_pull() happens. In other words, still at that time, we have the
> same expectations as in __vlan_insert_tag().
>
>> To me, that postpull csum currently is absolutely in the correct spot,
>> because it's acting upon the pull done by __vlan_insert_tag(), not the
>> one done here by skb_vlan_push().
>>
>> Right?
>>
>> Can you tell me how you tested this?  Just curious...
>
> I noticed both while reviewing the code, the error path fixup is not
> critical for ovs or act_vlan as the skb is dropped afterwards, but not
> necessarily in eBPF case, so there it matters as eBPF doesn't know at
> this point, what the program is going to do with it (similar fixup is
> done in __skb_vlan_pop() error path, btw). For the csum, I did a hexdump
> to compare what we write and what is being passed in for the csum correction.
>
> Anyway ...
>
> Aside from all this and based on your comment, I'm investigating whether
> for the vlan push and also pop case the __skb_pull(skb, offset) in success
> case is actually enough and whether it needs to take VLAN_HLEN into account
> as well. But, I need to do more test for that one first. At least the skb_vlan_push()
> comment says "__vlan_insert_tag expect skb->data pointing to mac header.
> So change skb->data before calling it and change back to original position
> later", Jiri?

For this part, what is meant with "original" position (relative to the start
of the ethernet header [currently the case], or relative to some data, e.g.
before/after the call, I still expect skb->data position to point to my IP header)?

Thanks,
Daniel
