From: Pidoux <f6bvp@free.fr>
Subject: Re: [PATCH][AX25] ax25_out: check skb for NULL in ax25_kick()
Date: Sun, 09 Mar 2008 10:02:39 +0100
Message-ID: <47D3A7AF.1030607@free.fr>
References: <20080206074529.GC4496@ff.dom.local> <20080213115607.GB2867@ff.dom.local> <025801c86ea3$75add3f0$453c822c@dg8ngn>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: 'Jarek Poplawski' <jarkao2@gmail.com>,
	'David Miller' <davem@davemloft.net>,
	'Ralf Baechle' <ralf@linux-mips.org>, netdev@vger.kernel.org
To: Jann Traschewski <jann@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g19.free.fr ([212.27.42.35]:50879 "EHLO smtp5-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751991AbYCIJEr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Mar 2008 05:04:47 -0400
In-Reply-To: <025801c86ea3$75add3f0$453c822c@dg8ngn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jann Traschewski a =E9crit :
> Applied and stable with Kernel 2.6.24.2 since 12 hours.
> Regards,
> Jann
>
>  =20
>> -----Urspr=FCngliche Nachricht-----
>> Von: Jarek Poplawski [mailto:jarkao2@gmail.com]=20
>> Gesendet: Mittwoch, 13. Februar 2008 12:56
>> An: David Miller
>> Cc: Jann Traschewski; Bernard Pidoux F6BVP; Ralf Baechle;=20
>> netdev@vger.kernel.org
>> Betreff: [PATCH][AX25] ax25_out: check skb for NULL in ax25_kick()
>>
>> Hi,
>>
>> Here is an "official" version of "testing patch #2" from this thread=
=2E
>> The only difference: ax25->vs is changed only after checking=20
>> skb is not NULL (plus a comment). IMHO it could be applied.
>>
>> Thanks,
>> Jarek P.
>>
>> ---------------->
>>
>> Subject: [AX25] ax25_out: check skb for NULL in ax25_kick()
>>
>> According to some OOPS reports ax25_kick tries to clone NULL=20
>> skbs sometimes. It looks like a race with=20
>> ax25_clear_queues(). Probably there is no need to add more=20
>> than a simple check for this yet.
>> Another report suggested there are probably also cases where ax25
>> ->paclen =3D=3D 0 can happen in ax25_output(); this wasn't confirmed
>> during testing but let's leave this debugging check for some time.
>>
>>
>> Reported-and-tested-by: Jann Traschewski <jann@gmx.de>
>> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
>>
>> ---
>>
>> diff -Nurp 2.6.24-mm1-/net/ax25/ax25_out.c=20
>> 2.6.24-mm1+/net/ax25/ax25_out.c
>> --- 2.6.24-mm1-/net/ax25/ax25_out.c	2008-01-24=20
>> 22:58:37.000000000 +0000
>> +++ 2.6.24-mm1+/net/ax25/ax25_out.c	2008-02-13=20
>> 10:43:50.000000000 +0000
>> @@ -117,6 +117,12 @@ void ax25_output(ax25_cb *ax25, int pacl
>>  	unsigned char *p;
>>  	int frontlen, len, fragno, ka9qfrag, first =3D 1;
>> =20
>> +	if (paclen < 16) {
>> +		WARN_ON_ONCE(1);
>> +		kfree_skb(skb);
>> +		return;
>> +	}
>> +
>>  	if ((skb->len - 1) > paclen) {
>>  		if (*skb->data =3D=3D AX25_P_TEXT) {
>>  			skb_pull(skb, 1); /* skip PID */
>> @@ -251,8 +257,6 @@ void ax25_kick(ax25_cb *ax25)
>>  	if (start =3D=3D end)
>>  		return;
>> =20
>> -	ax25->vs =3D start;
>> -
>>  	/*
>>  	 * Transmit data until either we're out of data to send or
>>  	 * the window is full. Send a poll on the final I frame=20
>> if @@ -261,8 +265,13 @@ void ax25_kick(ax25_cb *ax25)
>> =20
>>  	/*
>>  	 * Dequeue the frame and copy it.
>> +	 * Check for race with ax25_clear_queues().
>>  	 */
>>  	skb  =3D skb_dequeue(&ax25->write_queue);
>> +	if (!skb)
>> +		return;
>> +
>> +	ax25->vs =3D start;
>> =20
>>  	do {
>>  		if ((skbn =3D skb_clone(skb, GFP_ATOMIC)) =3D=3D NULL) {
>>    =20
>
>
>
>  =20
Applied too and stable with kernel 2.6.24.3 since a week.

Thanks Jarek.

Bernard Pidoux
