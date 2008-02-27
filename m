From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [Bluez-devel] forcing SCO connection patch
Date: Wed, 27 Feb 2008 10:57:23 +0100
Message-ID: <2A7EF87C-1340-45D7-B457-F81799674B1E@holtmann.org>
References: <47666E1F.2000902@mizi.com>	 <a8e1da0802242330l765b8b1ava62b857baf8a5568@mail.gmail.com>	 <47C28A33.4070102@mizi.com> <a8e1da0802250155u1b7af481va203849f68d9106b@mail.gmail.com> <47C2A7FA.2060902@mizi.com> <70692DDF-93B7-447E-ABEE-3CDBD94F15F1@holtmann.org> <47C38D40.3040809@mizi.com> <B96BD3FE-F490-4AD5-9315-ECD42CE9C728@holtmann.org> <47C4C3D4.8010902@mizi.com>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Dave Young <hidave.darkstar@gmail.com>,
	linux-bluetooth@vger.kernel.org,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	bmidgley@gmail.com, David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Louis JANG <louis@mizi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:49767 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750842AbYB0J51 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2008 04:57:27 -0500
In-Reply-To: <47C4C3D4.8010902@mizi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Louis,

>>>>> --- linux-2.6.23/net/bluetooth/hci_event.c.orig 2008-02-25
>>>>> 17:17:11.000000000 +0900
>>>>> +++ linux-2.6.23/net/bluetooth/hci_event.c 2008-02-25
>>>>> 17:30:23.000000000 +0900
>>>>> @@ -1313,8 +1313,17 @@
>>>>> hci_dev_lock(hdev);
>>>>>
>>>>> conn = hci_conn_hash_lookup_ba(hdev, ev->link_type, &ev->bdaddr);
>>>>> - if (!conn)
>>>>> - goto unlock;
>>>>> + if (!conn) {
>>>>> + if (ev->link_type != ACL_LINK) {
>>>>> + __u8 link_type = (ev->link_type == ESCO_LINK) ? SCO_LINK :
>>>>> ESCO_LINK;
>>>>> +
>>>>> + conn = hci_conn_hash_lookup_ba(hdev, link_type, &ev->bdaddr);
>>>>> + if (conn)
>>>>> + conn->type = ev->link_type;
>>>>> + }
>>>>> + if (!conn)
>>>>> + goto unlock;
>>>>> + }
>>>>
>>>> NAK. There is no need to check for ACL_LINK. The sync_complete will
>>>> only be called for SCO or eSCO connections.
>>> I see. I removed this check line in the patch.
>>>
>>> Thanks.
>>> Louis JANG
>>> Signed-off-by: Louis JANG <louis@mizi.com>
>>> --- linux-2.6.23/net/bluetooth/hci_event.c.orig 2008-02-26
>>> 12:46:36.000000000 +0900
>>> +++ linux-2.6.23/net/bluetooth/hci_event.c 2008-02-26
>>> 12:47:23.000000000 +0900
>>> @@ -1313,8 +1313,15 @@
>>> hci_dev_lock(hdev);
>>>
>>> conn = hci_conn_hash_lookup_ba(hdev, ev->link_type, &ev->bdaddr);
>>> - if (!conn)
>>> - goto unlock;
>>> + if (!conn) {
>>> + __u8 link_type = (ev->link_type == ESCO_LINK) ? SCO_LINK :  
>>> ESCO_LINK;
>>> +
>>> + conn = hci_conn_hash_lookup_ba(hdev, link_type, &ev->bdaddr);
>>> + if (conn)
>>> + conn->type = ev->link_type;
>>> + else
>>> + goto unlock;
>>> + }
>>>
>>> if (!ev->status) {
>>> conn->handle = __le16_to_cpu(ev->handle);
>>
>> do something like this:
>>
>> if (!conn) {
>> ....
>>
>> conn = ....
>> if (!conn)
>> goto unlock;
>>
>> conn->type = ev->link_type;
>> }
>>
>> And include a description when submitting a patch.
>>
>> Regards
>>
>> Marcel
> I changed code with this style and included patch description.
> Thanks
>
> Louis JANG
> This patch is to handle different type of synchronous link is
> estabilished with its request.
>
> Signed-off-by: Louis JANG <louis@mizi.com>
> --- linux-2.6.23/net/bluetooth/hci_event.c.orig	2008-02-26  
> 12:46:36.000000000 +0900
> +++ linux-2.6.23/net/bluetooth/hci_event.c	2008-02-27  
> 10:48:29.000000000 +0900
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
> +		if (!conn)
> +			goto unlock;
> +
> +		conn->type = ev->link_type;
> +	}
>
> 	if (!ev->status) {
> 		conn->handle = __le16_to_cpu(ev->handle);

so the patch is fine, but the description of what this patch is doing,  
why it is doing it this way and what it fixes is fully missing. Please  
update it with a proper description.

Regards

Marcel

