From: "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
Subject: Re: [RFC v3 1/2] iwlwifi: pcie: allow to build an A-MSDU using TSO
 core
Date: Thu, 22 Oct 2015 06:07:42 +0000
Message-ID: <0BA3FCBA62E2DC44AF3030971E174FB32E8AB4C7@hasmsx107.ger.corp.intel.com>
References: <1445452464-19525-1-git-send-email-emmanuel.grumbach@intel.com>
 <1445452464-19525-2-git-send-email-emmanuel.grumbach@intel.com>
 <1445470211.22974.86.camel@edumazet-glaptop2.roam.corp.google.com>
 <0BA3FCBA62E2DC44AF3030971E174FB32E8AB280@hasmsx107.ger.corp.intel.com>
 <1445480807.22974.91.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Sharon, Sara" <sara.sharon@intel.com>,
	"ido@wizery.com" <ido@wizery.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:39603 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756482AbbJVGHr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 02:07:47 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10/22/2015 05:27 AM, Eric Dumazet wrote:
> On Thu, 2015-10-22 at 00:14 +0000, Grumbach, Emmanuel wrote:
> 
>>
>> Well. I guess I should at least check, but even with very small MSS, our
>> device supports up to 20 pointers for the same 802.11 packet: 2 are for
>> metadata. So basically, so leaves me only 18 pointers. for each MSS I
>> need at least 2 (one for the headers and one for the payload), so I will
>> have at most 9 of these for one packet, even with a tiny MSS.
>>
> 
> I did not see in your patch where you made the checks about 18 segs in a
> TSO packet ?

It is in the other patch: iwlwifi: mvm: send large SKBs to the transport
mvm is the op_mode and the op_mode needs to make sure that the payload
fits in one 802.11 packet AND it doesn't exhaust the number of pointers.
I'll add a comment here.

> 
>> I agree that all this should be added to the code in a comment.
>> Speaking of which...
>> int tso_count_descs(struct sk_buff *skb)
>> {
>>         /* The Marvell Way */
>>         return skb_shinfo(skb)->gso_segs * 2 + skb_shinfo(skb)->nr_frags;
>> }
>>
>> What if there is some payload in the header?
>> To me it sounds safer to return:
>>
>> skb_shinfo(skb)->gso_segs * 2 + skb_shinfo(skb)->nr_frags + 1;
>>
>> or maybe to test if there is some payload in the header and then add 1?
>> If there is payload in the header, it should be considered as another
>> frag, shouldn't it?
> 
> Minimal count is gso_segs (one per MSS)
> 
> Then you have to add extra for the cases we have a mss spanning a frag
> in skb.
> 
> Thats a max of (skb_shinfo(skb)->nr_frags - 1) + (data_in_head() ? 1 :
> 0);
> So I believe formula would be correct.
> 

I needed a piece of paper and a few drawings to understand you are
right... :)
