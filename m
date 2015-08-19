From: "Grumbach, Emmanuel" <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC v2 0/3] add TSO / A-MSDU TX for iwlwifi
Date: Wed, 19 Aug 2015 17:56:20 +0000
Message-ID: <0BA3FCBA62E2DC44AF3030971E174FB32E825252@hasmsx107.ger.corp.intel.com>
References: <1439989181-4444-1-git-send-email-emmanuel.grumbach@intel.com>
	 <1439993647.6610.8.camel@edumazet-glaptop2.roam.corp.google.com>
	 <0BA3FCBA62E2DC44AF3030971E174FB32E8250B6@hasmsx107.ger.corp.intel.com>
	 <1440000515.6610.20.camel@edumazet-glaptop2.roam.corp.google.com>
	 <0BA3FCBA62E2DC44AF3030971E174FB32E825167@hasmsx107.ger.corp.intel.com>
 <1440004777.6610.23.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"ido-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org" <ido-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Language: en-US
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 08/19/2015 08:20 PM, Eric Dumazet wrote:
> On Wed, 2015-08-19 at 17:00 +0000, Grumbach, Emmanuel wrote:
>>
>> On 08/19/2015 07:08 PM, Eric Dumazet wrote:
>>> On Wed, 2015-08-19 at 15:07 +0000, Grumbach, Emmanuel wrote:
>>>
>>>> I'll look at it.
>>>> I was almost starting to implement that but then I thought with another
>>>> (good?) reason to use LSO. LSO gives me the guarantee that the packet is
>>>> directed to one peer, which might not be the case with xmit_more since
>>>> we have one Qdisc for several clients in case we are in AP mode.
>>>> Building an A-MSDU for several clients is not possible, at least not for
>>>> several client in the L2 (different MAC addresses).
>>>> LSO avoids this problem completely.
>>>
>>> Then, simply calling skb_gso_segment() from the driver might be enough,
>>> and less work for you.
>>>
>>> This would even support TSO on IPv6
>>>
>>
>> Well... I did take care of IPv6.
> 
> net/core/tso.c does not yet handle IPv6
> 

Yeah - I can see that now.
I can teach him - that's not a big deal. The bigger problem is that
net/core/tso.c doesn't do what I really need: it does only a small
portion. Since I need to add one frag to several skbs, I need to
refcount the frags' page. net/core/tso.c hides the page from me.

I can try to use tso_build_hdr but it will copy the entire header where
I need only SNAP / IP / TCP (and not 802.11).
I am getting the feeling that net/core/tso.c is close to what I need,
but not close enough to be usable without making changes that would make
the implementation too complicated and changing net/core/tso.c in a way
that would be much less readable for other users.
I know that our device is quite "unique" in the sense that most other
vendors do all the header twiddling in hardware. We unfortunately don't.
The A-MSDU's format is also somewhat unusual:

<802.11 HDR>
	<ETH><SNAP><IP><TCP><PAYLOAD><PAD (variable length)
	<ETH><SNAP><IP><TCP><PAYLOAD><PAD (variable length)
	<ETH><SNAP><IP><TCP><PAYLOAD><PAD (variable length)
	etc...

So I feel that making net/core/tso.c more complicated just because of
our craziness seems an overkill to me.
I'll try a bit harder to see how I can use net/core/tso.c, but I have to
say I am pessimistic.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
