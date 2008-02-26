From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [Bluez-devel] forcing SCO connection patch
Date: Tue, 26 Feb 2008 20:43:30 +0100
Message-ID: <B96BD3FE-F490-4AD5-9315-ECD42CE9C728@holtmann.org>
References: <47666E1F.2000902@mizi.com>	 <a8e1da0802242330l765b8b1ava62b857baf8a5568@mail.gmail.com>	 <47C28A33.4070102@mizi.com> <a8e1da0802250155u1b7af481va203849f68d9106b@mail.gmail.com> <47C2A7FA.2060902@mizi.com> <70692DDF-93B7-447E-ABEE-3CDBD94F15F1@holtmann.org> <47C38D40.3040809@mizi.com>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Dave Young <hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	bmidgley-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Louis JANG <louis-6CAt/Z4uMM0@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <47C38D40.3040809-6CAt/Z4uMM0@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Loius,

>>> --- linux-2.6.23/net/bluetooth/hci_event.c.orig 2008-02-25
>>> 17:17:11.000000000 +0900
>>> +++ linux-2.6.23/net/bluetooth/hci_event.c 2008-02-25
>>> 17:30:23.000000000 +0900
>>> @@ -1313,8 +1313,17 @@
>>> hci_dev_lock(hdev);
>>>
>>> conn = hci_conn_hash_lookup_ba(hdev, ev->link_type, &ev->bdaddr);
>>> - if (!conn)
>>> - goto unlock;
>>> + if (!conn) {
>>> + if (ev->link_type != ACL_LINK) {
>>> + __u8 link_type = (ev->link_type == ESCO_LINK) ? SCO_LINK :  
>>> ESCO_LINK;
>>> +
>>> + conn = hci_conn_hash_lookup_ba(hdev, link_type, &ev->bdaddr);
>>> + if (conn)
>>> + conn->type = ev->link_type;
>>> + }
>>> + if (!conn)
>>> + goto unlock;
>>> + }
>>
>> NAK. There is no need to check for ACL_LINK. The sync_complete will
>> only be called for SCO or eSCO connections.
> I see. I removed this check line in the patch.
>
> Thanks.
> Louis JANG
> Signed-off-by: Louis JANG <louis-6CAt/Z4uMM0@public.gmane.org>
> --- linux-2.6.23/net/bluetooth/hci_event.c.orig	2008-02-26  
> 12:46:36.000000000 +0900
> +++ linux-2.6.23/net/bluetooth/hci_event.c	2008-02-26  
> 12:47:23.000000000 +0900
> @@ -1313,8 +1313,15 @@
> 	hci_dev_lock(hdev);
>
> 	conn = hci_conn_hash_lookup_ba(hdev, ev->link_type, &ev->bdaddr);
> -	if (!conn)
> -		goto unlock;
> +	if (!conn) {
> +		__u8 link_type = (ev->link_type == ESCO_LINK) ? SCO_LINK :  
> ESCO_LINK;
> +
> +		conn = hci_conn_hash_lookup_ba(hdev, link_type, &ev->bdaddr);
> +		if (conn)
> +			conn->type = ev->link_type;
> +		else
> +			goto unlock;
> +	}
>
> 	if (!ev->status) {
> 		conn->handle = __le16_to_cpu(ev->handle);

do something like this:

if (!conn) {
	....

	conn = ....
	if (!conn)
		goto unlock;

	conn->type = ev->link_type;
}

And include a description when submitting a patch.

Regards

Marcel

-
To unsubscribe from this list: send the line "unsubscribe linux-bluetooth" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
