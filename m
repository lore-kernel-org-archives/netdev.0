From: "Grumbach, Emmanuel" <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC v2 3/3] iwlwifi: mvm: transfer the truesize to the last
 TSO segment
Date: Thu, 20 Aug 2015 19:34:53 +0000
Message-ID: <0BA3FCBA62E2DC44AF3030971E174FB32E8266E6@hasmsx107.ger.corp.intel.com>
References: <1439989181-4444-1-git-send-email-emmanuel.grumbach@intel.com>
	 <1439989181-4444-4-git-send-email-emmanuel.grumbach@intel.com>
	 <1439994266.6610.14.camel@edumazet-glaptop2.roam.corp.google.com>
	 <0BA3FCBA62E2DC44AF3030971E174FB32E8253CF@hasmsx107.ger.corp.intel.com>
	 <1440016762.6610.33.camel@edumazet-glaptop2.roam.corp.google.com>
	 <0BA3FCBA62E2DC44AF3030971E174FB32E8257BD@hasmsx107.ger.corp.intel.com>
 <1440076269.6610.39.camel@edumazet-glaptop2.roam.corp.google.com>
 <0BA3FCBA62E2DC44AF3030971E174FB32E82654B@hasmsx107.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"ido-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org" <ido-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Sharon, Sara" <sara.sharon-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Language: en-US
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 08/20/2015 04:53 PM, Grumbach, Emmanuel wrote:
> 
> 
> On 08/20/2015 04:11 PM, Eric Dumazet wrote:
>> On Thu, 2015-08-20 at 06:21 +0000, Grumbach, Emmanuel wrote:
>>>
>>> On 08/19/2015 11:39 PM, Eric Dumazet wrote:
>>>> On Wed, 2015-08-19 at 19:17 +0000, Grumbach, Emmanuel wrote:
>>>>
>>>>> Hm.. how would net/core/tso.c avoid this?
>>>>
>>>> Because a driver using these helpers keep around the original LSO packet
>>>> and frees it normally at TX completion time.
>>>>
>>>
>>> Which is why I can't really use it. The complexity is that I have to
>>> (ieee802.11 specification) split an LSO is several 802.11 packets. The
>>> maximal 802.11 packet I can send under ideal condition is 11K long or
>>> so. So I *must* generate several 802.11 frames from one single LSO
>>> packet. OTOH, I can have more than MSS bytes in a 802.11 A-MSDU.
>>>
>>
>> Who said you had to free original packet ? Just keep it around.
>>
>> TCP will work better ( check skb_still_in_host_queue() helper if you
>> want to know why)
> 
> I do keep the original skb: it becomes the first 802.11 packet generated
> from that LSO skb. Thing is that it will be freed first and I wanted the
> *last packet* to release the pressure on the socket.
> So I guess that skb_still_in_host_queue will still find it and avoid
> retransmissions at least until the first skb of the LSO is freed.
> But unless you are fine with releasing the pressing on the socket as
> soon as the *first* 802.11 skb is freed, I need that code.
> 
> I'll try to look at dev->gso_max_size that you mentioned below. This can
> really be a game changer for me.
> 


Err... no :( It won't work for me because the MSS impacts the number of
segments which in turns impact the number of time the headers have to be
copied which impacts... the A-MSDU maximal size which must be bigger
than gso_max_size. So basically, a connection parameter (MSS) impacts a
device parameter (gso_max_size). Now, of course, I could give up on
small MSS connections and skb_gso_segment() skbs whose MSS is smaller
than the default. This means that I give up on LSO in certain cases...

I will get back to the drawing board and check what I can do to use /
enhance the core infra... But it will be hard to lose functionality /
efficiency just to use the core infra...
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
