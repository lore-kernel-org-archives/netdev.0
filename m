From: "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
Subject: Re: [PATCH v2] net: tso: add support for IPv6
Date: Mon, 26 Oct 2015 08:17:50 +0000
Message-ID: <0BA3FCBA62E2DC44AF3030971E174FB32E8B09E0@hasmsx107.ger.corp.intel.com>
References: <1445803107-18513-1-git-send-email-emmanuel.grumbach@intel.com>
 <1445803371-19778-1-git-send-email-emmanuel.grumbach@intel.com>
 <562DA5FF.6040307@lab.ntt.co.jp>
 <0BA3FCBA62E2DC44AF3030971E174FB32E8B07E2@hasmsx107.ger.corp.intel.com>
 <562DE0A4.80100@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"egrumbach@gmail.com" <egrumbach@gmail.com>
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:12849 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753002AbbJZISv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 04:18:51 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10/26/2015 10:14 AM, Toshiaki Makita wrote:
> On 2015/10/26 16:47, Grumbach, Emmanuel wrote:
>> On 10/26/2015 06:03 AM, Toshiaki Makita wrote:
>>> On 2015/10/26 5:02, Emmanuel Grumbach wrote:
>>>> Adding IPv6 for the TSO helper API is trivial:
>>>> * Don't play with the id (which doesn't exist in IPv6)
>>>> * Correctly update the payload_len (don't include the
>>>>   length of the IP header itself)
>>> ...
>>>>  	memcpy(hdr, skb->data, hdr_len);
>>>> -	iph = (struct iphdr *)(hdr + mac_hdr_len);
>>>> -	iph->id = htons(tso->ip_id);
>>>> -	iph->tot_len = htons(size + hdr_len - mac_hdr_len);
>>>> +	if (skb->protocol == htons(ETH_P_IP)) {
>>>
>>> I guess this should be vlan_get_protocol(skb).
>>
>> I truly don't know. I guess we could have VLANs, but I'd need to check
>> how the packet would look like after it exits mac80211.
> 
> I don't know much about mac80211.
> 
> What I see is that mvneta has TSO in vlan_features and it uses
> tso_build_hdr(). When vlan device is used, we cannot access network
> protocol by skb->protocol without HW vlan acceleration.
> So it looks like this change corrupts TSO functionality on mvneta.

Convincing enough :)

> 
>> If we need that, I'll likely do this check once in tso_start() and add a
>> variable to struct tso_t.
> 
> I'm not sure if an additional variable is needed.
> At least, skb_network_offset()/ip_hdr() should correctly handle (skip)
> vlan headers.
> 

Adding a bool to tso_t is more an optimisation than something needed for
correctness. It avoid to call vlan_get_protocol(skb) for each MSS.

> Toshiaki Makita
> 
> 
