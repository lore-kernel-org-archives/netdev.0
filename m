From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 net] net: skbuff: skb_vlan_push: Fix wrong unwinding
 of skb->data after __vlan_insert_tag call
Date: Wed, 28 Sep 2016 16:43:38 +0200
Message-ID: <57EBD71A.90104@iogearbox.net>
References: <1475053721-27676-1-git-send-email-shmulik.ladkani@gmail.com>       <57EB9BE0.4080903@iogearbox.net> <20160928145644.662ecc04@pixies>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Pravin Shelar <pshelar@ovn.org>, netdev@vger.kernel.org,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Jiri Pirko <jiri@mellanox.com>
To: Shmulik Ladkani <shmulik.ladkani@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35421 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932409AbcI1Ono (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 10:43:44 -0400
In-Reply-To: <20160928145644.662ecc04@pixies>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/28/2016 01:56 PM, Shmulik Ladkani wrote:
> On Wed, 28 Sep 2016 12:30:56 +0200, daniel@iogearbox.net wrote:
>>> @@ -4608,6 +4608,8 @@ int skb_vlan_push(struct sk_buff *skb, __be16 vlan_proto, u16 vlan_tci)
>>>
>>>    		skb->protocol = skb->vlan_proto;
>>>    		skb->mac_len += VLAN_HLEN;
>>> +		if (offset)
>>> +			offset += VLAN_HLEN;
>>>
>>>    		skb_postpush_rcsum(skb, skb->data + (2 * ETH_ALEN), VLAN_HLEN);
>>>    		__skb_pull(skb, offset);
>>
>> This looks much better indeed than your v1 of this patch.
>
> Yep, after some meditation and history digging I happened to notice I
> was barking at the wrong tree.
>
>> So the issue might only be visible to act_vlan as the other remaining user of
>> skb_vlan_push().
>
> Yes, this is correct. I'll amend the log message to express that.
> The bug occurs for callers of skb_vlan_push() whose data is not
> pointing at mac_header.
>
>> My only question would be:
>> what about __skb_vlan_pop(), wouldn't that then need the same adjustment
>> a la offset -= VLAN_HLEN?
>
> Well, theoretically, yes; but caller may expect 2 different things:
>
> (assuming tags are in-payload)
>
> (1) suppose upon entry we have
>
>      DA,SA,0x8100,TCI,0x0800,
>      ^                ^
>      mac_hdr          data
>
> initial offset is 18, and after current unwinding code we'll get

You mean data points after the 0x0800, right?

>
>      DA,SA,0x0800,4_bytes,
>      ^                    ^
>      mac_hdr              data
>
> which is probably incorrect, adjustment 'offset -= VLAN_HLEN' is needed.
>
> (2) suppose upon entry we have
>
>      DA,SA,0x8100,TCI,0x0800
>      ^            ^
>      mac_hdr      data
>
> initial offset is 14, and after current unwinding code we'll get
>
>      DA,SA,0x0800,
>      ^            ^
>      mac_hdr      data
>
> which is probably what user has intended.
> (had we adjusted offset to be 10, 'data' would point into SA)
>
>  From test I've made using act_vlan upon ingress on QinQ tags, existing call
> provides data as in (2).
>
> Thoughts?

Yeah, so we likely end up at 2) because of things like eth_type_trans()
that would only pull ETH_HLEN.

Couldn't we end up with 1) for the act_vlan case when we'd have the
offset-adjusted skb_vlan_push() fix from here, where we'd then redirect
to ingress where skb_vlan_pop() would be called? If I'm not missing
something, skb_vlan_push() would then point to the data location of 1)
and with your other proposed direct netif_receive_skb() patch, no
further skb->data adjustments would be done, right?

Another potential issue (but unrelated to this fix here) I just noticed
is, whether act_vlan might have the same problem as we fixed in 8065694e6519
("bpf: fix checksum for vlan push/pop helper"). So potentially, we could
end up fixing CHECKSUM_COMPLETE wrongly on ingress, since these 14 bytes
are already pulled out of the sum at that point.

> Should we adjust "offset" back, only if resulting offset is >=14 ?

If also the checksum one might end up as an issue, maybe it's just best
to go through the pain and do the push/pull for data plus csum, so both
skb_vlan_*() functions see the frame starting from mac header temporarily?
Jiri, any thoughts?
