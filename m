From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH net-next 01/11] net: cdc_ncm: split out rx_max/tx_max update of setup
Date: Tue, 13 May 2014 11:25:28 +0200
Message-ID: <87sioe114n.fsf@nemi.mork.no>
References: <1399736509-1159-1-git-send-email-bjorn@mork.no>
	<1399736509-1159-2-git-send-email-bjorn@mork.no>
	<1399968546.8278.2.camel@linux-fkkt.site>
	<871tvy2hcp.fsf@nemi.mork.no>
	<1399972165.8278.11.camel@linux-fkkt.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1399972165.8278.11.camel-B2T3B9s34ElbnMAlSieJcQ@public.gmane.org> (Oliver Neukum's
	message of "Tue, 13 May 2014 11:09:25 +0200")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org> writes:

>> The reason I put that min_t() there instead was an attempt to deal w=
ith
>> the (not unlikely) event that some buggy device set dwNtbInMaxSize l=
ower
>> than this required minimum value.  We then have the choices:
>>=20
>>  a) fail to support the buggy device
>>  b) attempt to set a larger buffer size than the device supports
>>  c) accept the lower size
>
> My preference would be b) > a) > c)
> It seems to me that would should respect the spec and if the spec set=
s
> a lower limit then we don't go lower.
>
>> So I chose c) in an attempt to be as gentle as possible.  But I am o=
pen
>> to go for a) instead if you think that is better. After all
>> USB_CDC_NCM_NTB_MIN_IN_SIZE is as low as 2048, so it doesn't fit muc=
h
>> more than the headers and a single full size ethernet frame.  And I =
see
>> now that we fail to do further sanity checking after this.  What if
>> dwNtbInMaxSize is 0? Or smaller than the necessary headers?
>
> Exactly. Some fool may simply overlook setting it at all.
>
>> Should I rewrite the above to do a) instead?  I.e.
>>=20
>> 	min =3D USB_CDC_NCM_NTB_MIN_IN_SIZE;
>> 	max =3D min_t(u32, CDC_NCM_NTB_MAX_SIZE_RX, le32_to_cpu(ctx->ncm_pa=
rm.dwNtbInMaxSize));
>>         if (min > max)
>>            fail;
>>=20
>> I don't think b) is a good idea.  It might work, but it might also f=
ail
>> in surprising ways making it hard to debug.
>
> Users may prefer working devices to clean failures, but
> I primarily care about conforming to spec. We just shouldn't
> do such violations in a general case.

Yes, I agree.  Will change this. Let's try to go for b) then. I.e.

 	min =3D USB_CDC_NCM_NTB_MIN_IN_SIZE;
 	max =3D min_t(u32, CDC_NCM_NTB_MAX_SIZE_RX, le32_to_cpu(ctx->ncm_parm=
=2EdwNtbInMaxSize));
        if (max < min)
              max =3D min;


Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
