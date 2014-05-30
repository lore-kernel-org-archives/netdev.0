From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH v2 net-next 3/8] net: cdc_ncm: inform usbnet when rx buffers are reduced
Date: Fri, 30 May 2014 15:35:43 +0200
Message-ID: <87r43b8k40.fsf@nemi.mork.no>
References: <1401435070-26721-1-git-send-email-bjorn@mork.no>
	<1401435070-26721-4-git-send-email-bjorn@mork.no>
	<063D6719AE5E284EB5DD2968C1650D6D1725057A@AcuExch.aculab.com>
	<87d2eva41t.fsf@nemi.mork.no>
	<063D6719AE5E284EB5DD2968C1650D6D172506D0@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb\@vger.kernel.org" <linux-usb@vger.kernel.org>,
	Alexey Orishko <alexey.orishko@gmail.com>,
	Oliver Neukum <oliver@neukum.org>,
	Enrico Mioso <mrkiko.rs@gmail.com>,
	Lars Melin <larsm17@gmail.com>, Peter Stuge <peter@stuge.se>,
	Greg Suarez <gsuarez@smithmicro.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:56043 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752069AbaE3Ng2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 09:36:28 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D172506D0@AcuExch.aculab.com>
	(David Laight's message of "Fri, 30 May 2014 12:39:55 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Laight <David.Laight@ACULAB.COM> writes:

> From: Bj=C3=B8rn Mork
>> David Laight <David.Laight@ACULAB.COM> writes:
>> > From: Bj=C3=B8rn Mork
>> >> It doesn't matter whether the buffer size goes up or down.  We ha=
ve to
>> >> keep usbnet and device syncronized to be able to split transfers =
at the
>> >> correct boundaries. The spec allow skipping short packets when us=
ing
>> >> max sized transfers.  If we don't tell usbnet about our new expec=
ted rx
>> >> buffer size, then it will merge and/or split NTBs.  The driver do=
es not
>> >> support this, and the result will be lots of framing errors.
>> >>
>> >> Fix by always reallocating usbnet rx buffers when the rx_max valu=
e
>> >> changes.
>> >
>> > I'm guessing that the rx_max value is the maximum size of the USB =
bulk
>> > data 'message' that the device generates?
>> >
>> > As such the URB only need to be longer that it.
>>=20
>> So did I think too at first.  That's how I added the bug fixed by th=
is
>> commit :-)
>>=20
>> The problem with NCM is that it explicitly allows (and encourage) us=
ing
>> transfers which are multiples of the USB packet size, *without* any
>> terminating short packet (0 or 1 byte). This means that the USB core
>> won't know or care about the end of one transfer and the beginning o=
f
>> the next.  Which is fine.  But the cdc_ncm driver has to know, becau=
se
>> it must split the transfers into frames it can decode.
>>=20
>> Now, the current cdc_ncm implementation has a built-in assumption th=
at
>> the size of the URB =3D=3D rx_max.  This lets it simplify the splitt=
ing into
>> frames to nearly nothing: Any received URB contains exactly one fram=
e.
>> Therefore we need to keep the rx URB size strictly syncronized the
>> rx_max.
>
> Hmmm....
> So there is an ethernet packet size somewhere near 500 that exactly f=
ills
> a 512 byte USB2 frame.
> If you receive one of those does the hardware send a 0 length termina=
ting
> fragment?
> If not the then URB won't complete until after the next ethernet fram=
e
> arrives.
> Receive three of them followed by a longer frame and you'll overrun t=
he
> end of the URB.
>
> At least one path through usbnet ensures that the rx buffers aren't
> a multiple of the USB frame size. I'm not sure whether that really he=
lps.
>
> Sounds like the hardware expects you to receive each USB bulk buffer
> separately.

Please, go read the NCM spec.


Bj=C3=B8rn
