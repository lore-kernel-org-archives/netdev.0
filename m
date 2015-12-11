From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH net-next] hv_netvsc: Fix race condition on Multi-Send Data field
Date: Fri, 11 Dec 2015 14:52:32 +0100
Message-ID: <87vb85xfbz.fsf@vitty.brq.redhat.com>
References: <1449778775-14404-1-git-send-email-haiyangz@microsoft.com>
	<877fklyxiu.fsf@vitty.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, olaf@aepfle.de,
	jasowang@redhat.com, driverdev-devel@linuxdriverproject.org,
	linux-kernel@vger.kernel.org
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56542 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751687AbbLKNwg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Dec 2015 08:52:36 -0500
In-Reply-To: <877fklyxiu.fsf@vitty.brq.redhat.com> (Vitaly Kuznetsov's message
	of "Fri, 11 Dec 2015 13:34:17 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vitaly Kuznetsov <vkuznets@redhat.com> writes:

> Haiyang Zhang <haiyangz@microsoft.com> writes:
>
>> In commit 2a04ae8acb14 ("hv_netvsc: remove locking in netvsc_send()"=
), the
>> locking for MSD (Multi-Send Data) field was removed. This could caus=
e a
>> race condition between RNDIS control messages and data packets proce=
ssing,
>> because these two types of traffic are not synchronized.
>> This patch fixes this issue by sending control messages out directly
>> without reading MSD field.
>>
>> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
>> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
>> ---
>>  drivers/net/hyperv/netvsc.c |    9 +++++++++
>>  1 files changed, 9 insertions(+), 0 deletions(-)
>>
>> diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc=
=2Ec
>> index 02bab9a..059fc52 100644
>> --- a/drivers/net/hyperv/netvsc.c
>> +++ b/drivers/net/hyperv/netvsc.c
>> @@ -867,6 +867,14 @@ int netvsc_send(struct hv_device *device,
>>  	packet->send_buf_index =3D NETVSC_INVALID_INDEX;
>>  	packet->cp_partial =3D false;
>> =20
>> +	/* Send control message directly without accessing msd (Multi-Send
>> +	 * Data) field which may be changed during data packet processing.
>> +	 */
>> +	if (!skb) {
>> +		cur_send =3D packet;
>> +		goto send_now;
>> +	}
>> +
>
> Is is supposed to be applied on top of some other patches? It doesn't
> compile on top of current net-next:
>
> drivers/net/hyperv/netvsc.c: In function =E2=80=98netvsc_send=E2=80=99=
:
> drivers/net/hyperv/netvsc.c:865:7: error: =E2=80=98skb=E2=80=99 undec=
lared (first use in
> this function)
>   if (!skb) {
>          ^
>
> Did you mean to check rndis_msg instead (as skb is not defined here)?

Oh, my bad, it was me who was looking at the wrong branch... Sorry for
the noise.

>
>>  	msdp =3D &net_device->msd[q_idx];
>> =20
>>  	/* batch packets in send buffer if possible */
>> @@ -939,6 +947,7 @@ int netvsc_send(struct hv_device *device,
>>  		}
>>  	}
>> =20
>> +send_now:
>>  	if (cur_send)
>>  		ret =3D netvsc_send_pkt(cur_send, net_device, pb, skb);
>
> I suppose we untangle these two pathes completely: let
> rndis_filter_send_request() call netvsc_send_pkt() directly. Please s=
ee
> my patch attached (note: it should be split in 3 patches if
> submitted). If you like the idea I can send it.

This patch will need some changes but the suggestion still stands: let'=
s
untangle sending data and control messages.

--=20
  Vitaly
