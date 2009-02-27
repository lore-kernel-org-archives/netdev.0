From: roel kluin <roel.kluin@gmail.com>
Subject: Re: [PATCH] net: more timeouts that reach -1
Date: Fri, 27 Feb 2009 16:37:30 +0100
Message-ID: <25e057c00902270737x529fb5b8m2fdbb044fa75ab0d@mail.gmail.com>
References: <49A5286D.80304@gmail.com> <20090227114015.M80857@cooldavid.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: cooldavid@cooldavid.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f178.google.com ([209.85.218.178]:52771 "EHLO
	mail-bw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754633AbZB0Phe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 10:37:34 -0500
Received: by bwz26 with SMTP id 26so1079174bwz.37
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2009 07:37:30 -0800 (PST)
In-Reply-To: <20090227114015.M80857@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 27, 2009 at 12:43 PM, Guo-Fu Tseng <cooldavid@cooldavid.org=
> wrote:
> On Wed, 25 Feb 2009 12:15:57 +0100, Roel Kluin wrote
>> These were not previously reported by me.
>> ------------------------------>8-------------8<---------------------=
------------
>> with while (timeout-- > 0); timeout reaches -1 after the loop, so th=
e tests
>> below are off by one.
>>
>> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
>> ---

>> diff --git a/drivers/net/jme.c b/drivers/net/jme.c
>> index 08b3405..0173ed0 100644
>> --- a/drivers/net/jme.c
>> +++ b/drivers/net/jme.c
>> @@ -957,7 +957,8 @@ jme_process_receive(struct jme_adapter *jme, int=
 limit)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_inc;
>>
>> =A0 =A0 =A0 i =3D atomic_read(&rxring->next_to_clean);
>> - =A0 =A0 while (limit-- > 0) {
>> + =A0 =A0 while (limit > 0) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 limit--;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 rxdesc =3D rxring->desc;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 rxdesc +=3D i;
>>
> There should be no difference after this modification.
> The return value of this function is: "limit > 0 ? limit : 0;"

There is:
In the last iteration limit is 1 during the test before it is decrement=
ed to 0.

rxdesc =3D rxring->desc;
rxdesc +=3D i;

If then we break out of the loop by the 'goto out;', we continue with:

out:
        atomic_set(&rxring->next_to_clean, i);

out_inc:
        atomic_inc(&jme->rx_cleaning);

but since limit is already decremented, 0 is returned.

>
> Guo-Fu Tseng
>

Roel
