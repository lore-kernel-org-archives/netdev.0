From: Carol Soto <clsoto@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] Do not set shared_ports when nreq > MAX_MSIX
Date: Wed, 7 Oct 2015 09:20:27 -0500
Message-ID: <56152A2B.9020701@linux.vnet.ibm.com>
References: <1444166829-17638-1-git-send-email-clsoto@linux.vnet.ibm.com>
 <1444166829-17638-2-git-send-email-clsoto@linux.vnet.ibm.com>
 <CAJ3xEMjYtmSj3kBo24w+4Y3Nh60C9J=NHb_=YQw1QASJ1i_i1g@mail.gmail.com>
 <5614411E.1070105@linux.vnet.ibm.com> <5614C8E5.8040607@mellanox.com>
 <5614D308.4010106@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>, brking@linux.vnet.ibm.com
To: Matan Barak <matanb@mellanox.com>,
	Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:39663 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753982AbbJGOUc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 10:20:32 -0400
Received: from localhost
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <clsoto@linux.vnet.ibm.com>;
	Wed, 7 Oct 2015 08:20:31 -0600
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id C3F463E4003B
	for <netdev@vger.kernel.org>; Wed,  7 Oct 2015 08:20:29 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by b03cxnp08025.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t97EJDsd65798362
	for <netdev@vger.kernel.org>; Wed, 7 Oct 2015 07:19:13 -0700
Received: from d03av01.boulder.ibm.com (localhost [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t97EKRRb017072
	for <netdev@vger.kernel.org>; Wed, 7 Oct 2015 08:20:29 -0600
In-Reply-To: <5614D308.4010106@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10/7/2015 3:08 AM, Matan Barak wrote:
>
>
> On 10/7/2015 10:25 AM, Matan Barak wrote:
>>
>>
>> On 10/7/2015 12:46 AM, Carol Soto wrote:
>>>
>>>
>>> On 10/6/2015 4:39 PM, Or Gerlitz wrote:
>>>> On Wed, Oct 7, 2015 at 12:27 AM, <clsoto@linux.vnet.ibm.com> wrote=
:
>>>>> From: Carol L Soto <clsoto@linux.vnet.ibm.com>
>>>>>
>>>>> If we get MAX_MSIX interrupts would like to have each receive rin=
g
>>>>> with his own msix interrupt line.
>>>> so 9293267a3e2a  was only partially correct? and/or not fully opti=
mal?
>>>> please elaborate more on that in your change log.
>>> just not fully optimal, with commit 9293267a3e2a if I have 64 MSIXs=
 and
>>> 2 ports I can get 8 rings for each port but then the rings will sha=
re
>>> the interrupt lines. For 64 MSIXs we can have each ring with his ow=
n
>>> interrupt line.
>>>
>>>>> Fixes: 9293267a3e2a ('net/mlx4_core: Capping number of requested
>>>>> MSIXs to MAX_MSIX')
>>>>> Signed-off-by: Carol L Soto <clsoto@linux.vnet.ibm.com>
>>>> Carol, you didn't use net/mlx4: prefix as ask for mlx4 driver patc=
h
>>>> titles, so please repost, but before that I'd like to see an ack f=
rom
>>>> Matan for this patch as well.
>>> Sorry completely missed it. When Matan acks will resend it.
>>
>> The logic seems correct to me. When there are more nreqs than we cou=
ld
>> possibly support (or want to support), there=E2=80=99s no reason to =
share the
>> EQs between the different ports.
>> Thanks for your fix.
>>
>
> Please also clean the shared_ports variable - we don't need this anym=
ore.
>
Thanks for the feedback, will resend.
Carol
>> Regards,
>> Matan
>>
>>>>
>>>> Or.
>>>>
>>>>> ---
>>>>>   drivers/net/ethernet/mellanox/mlx4/main.c | 4 +---
>>>>>   1 file changed, 1 insertion(+), 3 deletions(-)
>>>>>
>>>>> diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c
>>>>> b/drivers/net/ethernet/mellanox/mlx4/main.c
>>>>> index 006757f..f03f513 100644
>>>>> --- a/drivers/net/ethernet/mellanox/mlx4/main.c
>>>>> +++ b/drivers/net/ethernet/mellanox/mlx4/main.c
>>>>> @@ -2673,10 +2673,8 @@ static void mlx4_enable_msi_x(struct mlx4_=
dev
>>>>> *dev)
>>>>>
>>>>>                  nreq =3D min_t(int, dev->caps.num_eqs -
>>>>> dev->caps.reserved_eqs,
>>>>>                               nreq);
>>>>> -               if (nreq > MAX_MSIX) {
>>>>> +               if (nreq > MAX_MSIX)
>>>>>                          nreq =3D MAX_MSIX;
>>>>> -                       shared_ports =3D true;
>>>>> -               }
>>>>>
>>>>>                  entries =3D kcalloc(nreq, sizeof *entries,=20
>>>>> GFP_KERNEL);
>>>>>                  if (!entries)
>>>>> --=20
>>>>> 1.8.3.1
>>>>>
>>>>> --=20
>>>>> To unsubscribe from this list: send the line "unsubscribe netdev"=
 in
>>>>> the body of a message to majordomo@vger.kernel.org
>>>>> More majordomo info at http://vger.kernel.org/majordomo-info.html
>>>
>
