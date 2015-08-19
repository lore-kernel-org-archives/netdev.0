From: "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
Subject: Re: [RFC v2 0/3] add TSO / A-MSDU TX for iwlwifi
Date: Wed, 19 Aug 2015 17:00:08 +0000
Message-ID: <0BA3FCBA62E2DC44AF3030971E174FB32E825167@hasmsx107.ger.corp.intel.com>
References: <1439989181-4444-1-git-send-email-emmanuel.grumbach@intel.com>
	 <1439993647.6610.8.camel@edumazet-glaptop2.roam.corp.google.com>
	 <0BA3FCBA62E2DC44AF3030971E174FB32E8250B6@hasmsx107.ger.corp.intel.com>
 <1440000515.6610.20.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"ido@wizery.com" <ido@wizery.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:30691 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750991AbbHSRAN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 13:00:13 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08/19/2015 07:08 PM, Eric Dumazet wrote:
> On Wed, 2015-08-19 at 15:07 +0000, Grumbach, Emmanuel wrote:
> 
>> I'll look at it.
>> I was almost starting to implement that but then I thought with another
>> (good?) reason to use LSO. LSO gives me the guarantee that the packet is
>> directed to one peer, which might not be the case with xmit_more since
>> we have one Qdisc for several clients in case we are in AP mode.
>> Building an A-MSDU for several clients is not possible, at least not for
>> several client in the L2 (different MAC addresses).
>> LSO avoids this problem completely.
> 
> Then, simply calling skb_gso_segment() from the driver might be enough,
> and less work for you.
> 
> This would even support TSO on IPv6
> 

Well... I did take care of IPv6.

> segs = skb_gso_segment(skb, tp->dev->features &
>                             ~(NETIF_F_TSO | NETIF_F_TSO6));
> 
> 

Thing is that our HW layers are currently implemented to receive one skb
per 802.11 packet. So that if I call skb_gso_segment, I'd have to
re-assemble the segs into one A-MSDU which would translate one skb.
I guess I could change the HW layer in the driver to be able to get a
list of skbs and make a single packet out of it, but that'd be tricky or
wasteful. skb_gso_segment will duplicate the wifi header while it is not
needed. Only the TCP / IP / SNAP headers need to be duplicated.
Moreover, each subframe in the A-MSDU needs it own subframe header (same
format as ethhdr) and there is also some padding in there. So that would
be even more complicated IMHO.
My code doesn't copy any payload. Only the headers. This is why I
thought it'd be better than segmenting and then re-assembling.
I did call skb_gso_segment if I get lots of payload in the header (more
than 2 * mss) in order to simplify the implementation.
