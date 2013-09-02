From: Hin-Tak Leung <htl10-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Subject: Re: [PATCH] rtl8187: fix use after free on failure path in rtl8187_init_urbs()
Date: Mon, 2 Sep 2013 07:34:45 +0100 (BST)
Message-ID: <1378103685.43571.YahooMailBasic@web172301.mail.ir2.yahoo.com>
Reply-To: htl10-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: larry.finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ldv-project-tpLiQldItUH5n4uC9ZG1Ww@public.gmane.org,
	gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org
To: khoroshilov-ufN2psIa012HXe+LvDLADg@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

------------------------------
On Mon, Sep 2, 2013 05:06 BST Alexey Khoroshilov wrote:

>On 01.09.2013 10:51, Hin-Tak Leung wrote:
>> ------------------------------
>> On Sat, Aug 31, 2013 22:18 BST Alexey Khoroshilov wrote:
>>
>> In case of __dev_alloc_skb() failure rtl8187_init_urbs()
>> calls usb_free_urb(entry) where 'entry' can points to urb
>> allocated at the previous iteration. That means refcnt will be
>> decremented incorrectly and the urb can be used after memory
>> deallocation.
>>
>> The patch fixes the issue and implements error handling of init_urbs
>> in rtl8187_start().
>>
>> Found by Linux Driver Verification project (linuxtesting.org).
>>
>> Signed-off-by: Alexey Khoroshilov <khoroshilov-ufN2psIa012HXe+LvDLADg@public.gmane.org>
>> ---
>> drivers/net/wireless/rtl818x/rtl8187/dev.c | 15 ++++++++++-----
>> 1 file changed, 10 insertions(+), 5 deletions(-)
>>
>> diff --git a/drivers/net/wireless/rtl818x/rtl8187/dev.c b/drivers/ne=
t/wireless/rtl818x/rtl8187/dev.c
>> index f49220e..e83d53c 100644
>> --- a/drivers/net/wireless/rtl818x/rtl8187/dev.c
>> +++ b/drivers/net/wireless/rtl818x/rtl8187/dev.c
>> @@ -438,17 +438,16 @@ static int rtl8187_init_urbs(struct ieee80211_=
hw *dev)
>>=A0 =A0 =A0 =A0 =A0 skb_queue_tail(&priv->rx_queue, skb);
>>=A0 =A0 =A0 =A0 =A0 usb_anchor_urb(entry, &priv->anchored);
>>=A0 =A0 =A0 =A0 =A0 ret =3D usb_submit_urb(entry, GFP_KERNEL);
>> +=A0 =A0 =A0 =A0 usb_free_urb(entry);
>>=A0 =A0 =A0 =A0 =A0 if (ret) {
>>=A0 =A0 =A0 =A0 =A0 =A0 =A0 skb_unlink(skb, &priv->rx_queue);
>>=A0 =A0 =A0 =A0 =A0 =A0 =A0 usb_unanchor_urb(entry);
>>=A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err;
>>=A0 =A0 =A0 =A0 =A0 }
>> -=A0 =A0 =A0 =A0 usb_free_urb(entry);
>>=A0 =A0 =A0 }
>>=A0 =A0 =A0 return ret;
>>
>> err:
>> -=A0 =A0 usb_free_urb(entry);
>>=A0 =A0 =A0 kfree_skb(skb);
>>=A0 =A0 =A0 usb_kill_anchored_urbs(&priv->anchored);
>>=A0 =A0 =A0 return ret;
>> This part looks wrong - you free_urb(entry) then unanchor_urb(entry)=
=2E
>I do not see any problems here.
>usb_free_urb() just decrements refcnt of the urb.
>While usb_anchor_urb() and usb_unanchor_urb() increment and decrement =
it=20
>as well.
>So actual memory deallocation will happen in usb_unanchor_urb().

If the routines work as you say, they probably are misnamed, and/or pro=
totyped wrongly?
Also, you are making assumptions about how they are implemented, and re=
lying
on the implementation details to be fixed for eternity.

I am just saying,

XXX_free(some_entity);
if(condtion)
     do_stuff(some_entity);

looks wrong, and if that's intentional, those routines really shouldn't=
 be named as such.

Hin-Tak



--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
