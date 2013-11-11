From: Govindarajulu Varadarajan <gvaradar-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next 02/13] driver: net: remove unnecessary skb NULL
 check before calling dev_kfree_skb_irq
Date: Mon, 11 Nov 2013 16:01:22 +0530 (IST)
Message-ID: <alpine.LNX.2.03.1311111537020.2363@cisco.com>
References: <1383400074-30555-1-git-send-email-govindarajulu90@gmail.com> <1383400074-30555-3-git-send-email-govindarajulu90@gmail.com> <20131104.151230.1978898006990867916.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: govindarajulu90-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	IvDoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, sbhatewara-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org, samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org,
	chas-vT06rRrALxcmhCb6mdbn6A@public.gmane.org, roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, isdn-iHCpqvpFUx0uJkBD2foKsQ@public.gmane.org,
	jcliburn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, benve-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org, ssujith-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org,
	jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, jesse.brandeburg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	shahed.shaikh-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org, joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org, apw-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20131104.151230.1978898006990867916.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On Mon, 4 Nov 2013, David Miller wrote:

> From: Govindarajulu Varadarajan <govindarajulu90-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Sat,  2 Nov 2013 19:17:43 +0530
>
>> @@ -1030,10 +1030,8 @@ static void ni65_xmit_intr(struct net_device *dev,int csr0)
>>  		}
>>
>>  #ifdef XMT_VIA_SKB
>> -		if(p->tmd_skb[p->tmdlast]) {
>> -			 dev_kfree_skb_irq(p->tmd_skb[p->tmdlast]);
>> -			 p->tmd_skb[p->tmdlast] = NULL;
>> -		}
>> +		 dev_kfree_skb_irq(p->tmd_skb[p->tmdlast]);
>> +		 p->tmd_skb[p->tmdlast] = NULL;
>>  #endif
>
> I absolutely disagree with this kind of change.
>
> There is a non-trivial cost for NULL'ing out that array entry
> unconditionally.  It's a dirtied cache line and this is in the
> fast path of TX SKB reclaim of this driver.
>
> You've made several changes of this kind.
>
> And it sort-of shows that the places that do check for NULL,
> are getting something in return for that test, namely avoidance
> of an unnecessary cpu store in the fast path of the driver.
>

True, in case of dev_kfree_skb_irq. If you look at patch 06-12, at many
places we do

if (s->skb) {
 	dev_kfree_skb_any(s->skb);
 	s->skb = NULL)
}

This is in fast path. If the code is not running in hardirq,
dev_kfree_skb_any calls dev_kfree_skb. Which again check if skb is NULL.
So we are checking if skb is null twice. That is what this patch is
trying to fix. (sorry I should have mentioned this in cover letter).

I am not sure if you have read my previous mail. I am pasting it below.

>> On Sun, 3 Nov 2013, Brandeburg, Jesse wrote: 
>> Thanks for this work, I'm a little concerned that there is a
>> non-trivial 
>> overhead to this patch.
>> 
>> when doing (for example in the Intel drivers): 
>> if (s->skb) {
>>      dev_kfree_skb(s->skb);
>>      s->skb = NULL; 
>> }
>>
> 
>In current code, dev_kfree_skb is NULL safe. Which means skb is
>checked for NULL inside dev_kfree_skb. dev_kfree_skb_any is also NULL safe
>when the code is running in non-hardirq.
>
>Lets consider two cases
> 
>1. skb is not NULL:
>      * Without my patch:
>           In the code above, we check for skb!=NULL twice. (once
>           before calling dev_kfree_skb, once by dev_kfree_skb). And
>           then we do assignment.
>       * With this patch:
>           we check for skb!=NULL once, And then we do assignment.
>
>       To fix the twice NULL check, we either have to remove the check
>       which is inside dev_kfree_skb (1). Or do whats done in this
>       patch.
>
>       (1) is not an option because a lot of kernel code already
>       assumes that dev_kfree_skb is NULL safe.
>
>2. skb is NULL:
>       * Without this patch:
>           One if statement is executed.
>       * With this patch:
>           One if statement and one assignment is executed.
> 
> From my observation most of the dev_kfree_skb calls are from
> e1000_unmap_and_free_tx_resource, e1000_put_txbuf,
> atl1_clean_tx_ring, alx_free_txbuf etc. in clean up functions.
>
> Is is quite unlikely thats skb is NULL. So it comes down to one extra
> if-branching statement or one extra assignment. I would prefer extra
> assignment to branching statement. In my opinion extra assignment is
> very little price we pay.
>
> //govind

Another way to solve the double NULL check is to define a new function
something like this

dev_kfree_skb_NULL(struct sk_buff **skb)
{
 	if(*skb) {
 		free_skb(*skb);
 		*skb=NULL;
 	}
}

and use this if you want to free a skb and make it NULL.
Is this approach better?

//govind

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
