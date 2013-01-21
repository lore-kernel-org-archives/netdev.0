From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net 2/3] net: cdc_mbim: send ZLP after max sized NTBs
Date: Mon, 21 Jan 2013 23:36:49 +0100
Message-ID: <878v7mb1tq.fsf@nemi.mork.no>
References: <1358783440-11459-1-git-send-email-bjorn@mork.no>
	<1358783440-11459-3-git-send-email-bjorn@mork.no>
	<2AC7D4AD8BA1C640B4C60C61C8E520154A8EE17D57@EXDCVYMBSTM006.EQ1STM.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb\@vger.kernel.org" <linux-usb@vger.kernel.org>,
	Greg Suarez <gsuarez@smithmicro.com>,
	Oliver Neukum <oneukum@suse.de>,
	Alexey Orishko <alexey.orishko@gmail.com>
To: Alexey ORISHKO <alexey.orishko@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:44771 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752365Ab3AUWhm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 17:37:42 -0500
In-Reply-To: <2AC7D4AD8BA1C640B4C60C61C8E520154A8EE17D57@EXDCVYMBSTM006.EQ1STM.local>
	(Alexey ORISHKO's message of "Mon, 21 Jan 2013 17:31:37 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey ORISHKO <alexey.orishko@stericsson.com> writes:

>> -----Original Message-----
>> From: Bj=C3=B8rn Mork [mailto:bjorn@mork.no]
>>=20
>> We normally avoid sending ZLPs by padding NTBs with a zero byte if t=
he
>> NTB is shorter than dwNtbOutMaxSize, resulting in a short USB packet
>> instead of a ZLP.  But in the case where the NTB length is exactly
>> dwNtbOutMaxSize and this is an exact multiplum of wMaxPacketSize, th=
en
>> we must send a ZLP.
>>=20
>> This fixes an issue seen on a Sierra Wireless MC7710 device where th=
e
>> transmission would fail whenever we ended up padding the NTBs to max
>> size.
>
> If you add ZLP for NTBs of dwNtbOutMaxSize, you are heavily affecting=
 CPU
> load, increasing interrupt load by factor of 2 in high load traffic
> scenario and possibly decreasing throughput for all other devices
> which behaves correctly.=20
>
> Why should others pay for Sierra Wireless fault?

No, they shouldn't.

> At least, do check VID/PID in usbnet and send ZLP only for malfunctio=
ning=20
> devices.

Yes, this would be easy to implement by simply creating a vendor/device
specific entry in cdc_mbim.

But I do worry that this isn't Sierra Wireless fault, but Qualcomms
fault.  SW are using Qualcomm firmware to do the low level stuff, and I
know the Qualcomm firmware implement MBIM functionality so it may very
well be the one to blame (I don't know this for sure, and I have no ide=
a
how to verify it). If this is correct than we can expect hundreds of
devices needing a device specific entry in a year or two. That's not
what I was looking forward to with a class driver like cdc_mbim.

And I still believe that there is reason to ask if this is really a
fault at all.


I don't know if this is particularily useful, but here is an usbmon
extract from the driver without the extra ZLP fix:

ffff88022aef3d40 3883111197 S Bo:8:005:1 -115 4096 =3D 4e434d48 0c00060=
0 00100c00 49505300 10000000 b8007a01 00000000 00000000
ffff880213f2d2c0 3883111233 S Bi:8:005:2 -115 16384 <
ffff8802274eab40 3883111255 S Bi:8:005:2 -115 16384 <
ffff88022fd65980 3883111276 S Bi:8:005:2 -115 16384 <
ffff880204351440 3883111297 S Bi:8:005:2 -115 16384 <
ffff880213f2d8c0 3883111317 S Bi:8:005:2 -115 16384 <
ffff88022aef3d40 3883111460 C Bo:8:005:1 0 4096 >
ffff880204351e00 3883965516 S Bo:8:005:1 -115 4096 =3D 4e434d48 0c00070=
0 00100c00 49505300 10000000 b8007a01 00000000 00000000
ffff880204351e00 3883965849 C Bo:8:005:1 0 4096 >
ffff880204351e00 3884973428 S Bo:8:005:1 -115 4096 =3D 4e434d48 0c00080=
0 00100c00 49505300 10000000 b8007a01 00000000 00000000
ffff880204351e00 3884973752 C Bo:8:005:1 0 4096 >
ffff880204351d40 3885981392 S Bo:8:005:1 -115 4096 =3D 4e434d48 0c00090=
0 00100c00 49505300 10000000 b8007a01 00000000 00000000
ffff880204351d40 3885981638 C Bo:8:005:1 0 4096 >
ffff880231b128c0 3886989391 S Bo:8:005:1 -115 4096 =3D 4e434d48 0c000a0=
0 00100c00 49505300 10000000 b8007a01 00000000 00000000
ffff880231b128c0 3886989622 C Bo:8:005:1 0 4096 >
ffff8802041d8a40 3887997401 S Bo:8:005:1 -115 4096 =3D 4e434d48 0c000b0=
0 00100c00 49505300 10000000 b8007a01 00000000 00000000
ffff8802041d8a40 3887997675 C Bo:8:005:1 0 4096 >
ffff8802041d8a40 3889005720 S Bo:8:005:1 -115 4096 =3D 4e434d48 0c000c0=
0 00100c00 49505300 10000000 b8007a01 00000000 00000000
ffff8802041d8a40 3889006019 C Bo:8:005:1 0 4096 >
ffff8802041d8c80 3890013428 S Bo:8:005:1 -115 4096 =3D 4e434d48 0c000d0=
0 00100c00 49505300 10000000 b8007a01 00000000 00000000
ffff8802041d8c80 3890013784 C Bo:8:005:1 0 4096 >
ffff880213f2d2c0 3892433962 C Bi:8:005:2 -104 0
ffff8802274eab40 3892434032 C Bi:8:005:2 -104 0
ffff88022fd65980 3892434078 C Bi:8:005:2 -104 0
ffff880204351440 3892434126 C Bi:8:005:2 -104 0
ffff880213f2d8c0 3892434172 C Bi:8:005:2 -104 0

same driver, with smaller packets keeping the NTB size below the magic
limit:

ffff88022b1de200 3896794916 S Bi:8:005:2 -115 16384 <
ffff88022767d780 3896794928 C Bo:8:005:1 0 262 >
ffff88022b1de140 3896794948 S Bi:8:005:2 -115 16384 <
ffff88022767d780 3896794971 S Bi:8:005:2 -115 16384 <
ffff88022b1deb00 3896794995 S Bi:8:005:2 -115 16384 <
ffff88022767d900 3896864077 C Bi:8:005:2 0 416 =3D 4e434d48 0c003500 a0=
010c00 49505300 10000000 1c007a01 00000000 4500017a
ffff88022767d900 3896864129 S Bi:8:005:2 -115 16384 <
ffff88022d639e40 3897644729 S Bo:8:005:1 -115 262 =3D 4e434d48 0c000f00=
 06010c00 49505300 10000000 b8004e00 00000000 00000000
ffff88022d639e40 3897644965 C Bo:8:005:1 0 262 >
ffff88022b1de380 3897711770 C Bi:8:005:2 0 112 =3D 4e434d48 0c003600 70=
000c00 49505300 10000000 1c004e00 00000000 4500004e
ffff88022b1de380 3897711812 S Bi:8:005:2 -115 16384 <
ffff88022b07c600 3898646616 S Bo:8:005:1 -115 262 =3D 4e434d48 0c001000=
 06010c00 49505300 10000000 b8004e00 00000000 00000000
ffff88022b07c600 3898646848 C Bo:8:005:1 0 262 >
ffff88022b1de200 3898697788 C Bi:8:005:2 0 112 =3D 4e434d48 0c003700 70=
000c00 49505300 10000000 1c004e00 00000000 4500004e
ffff88022b1de200 3898697829 S Bi:8:005:2 -115 16384 <
ffff88022b1de140 3901425927 C Bi:8:005:2 -104 0


driver with ZLP:

ffff8802041d82c0 3651255294 C Bo:8:005:1 0 4096 >
ffff88021a3ef380 3652103000 S Bo:8:005:1 -115 4096 =3D 4e434d48 0c00320=
0 00100c00 49505300 10000000 b8007a01 00000000 00000000
ffff88021a3ef380 3652103315 C Bo:8:005:1 0 4096 >
ffff8802041af540 3652439129 C Bi:8:005:2 0 416 =3D 4e434d48 0c002c00 a0=
010c00 49505300 10000000 1c007a01 00000000 4500017a
ffff8802041af540 3652439183 S Bi:8:005:2 -115 16384 <
ffff8802041af240 3653099148 C Bi:8:005:2 0 416 =3D 4e434d48 0c002d00 a0=
010c00 49505300 10000000 1c007a01 00000000 4500017a
ffff8802041af240 3653099183 S Bi:8:005:2 -115 16384 <
ffff88021a3efb00 3653101946 S Bo:8:005:1 -115 4096 =3D 4e434d48 0c00330=
0 00100c00 49505300 10000000 b8007a01 00000000 00000000
ffff88021a3efb00 3653102201 C Bo:8:005:1 0 4096 >
ffff8802041af9c0 3654039362 C Bi:8:005:2 0 416 =3D 4e434d48 0c002e00 a0=
010c00 49505300 10000000 1c007a01 00000000 4500017a
ffff8802041af9c0 3654039414 S Bi:8:005:2 -115 16384 <
ffff88021a3ef980 3654101353 S Bo:8:005:1 -115 4096 =3D 4e434d48 0c00340=
0 00100c00 49505300 10000000 b8007a01 00000000 00000000
ffff88021a3ef980 3654101622 C Bo:8:005:1 0 4096 >
ffff88021a3efc80 3654999361 C Bi:8:005:2 0 416 =3D 4e434d48 0c002f00 a0=
010c00 49505300 10000000 1c007a01 00000000 4500017a
ffff88021a3efc80 3654999412 S Bi:8:005:2 -115 16384 <
ffff88021a3ef200 3655102396 S Bo:8:005:1 -115 4096 =3D 4e434d48 0c00350=
0 00100c00 49505300 10000000 b8007a01 00000000 00000000
ffff88021a3ef200 3655102737 C Bo:8:005:1 0 4096 >
ffff88021a3efe00 3655949445 C Bi:8:005:2 0 416 =3D 4e434d48 0c003000 a0=
010c00 49505300 10000000 1c007a01 00000000 4500017a
ffff88021a3efe00 3655949491 S Bi:8:005:2 -115 16384 <
ffff88021a3ef500 3656103498 S Bo:8:005:1 -115 4096 =3D 4e434d48 0c00360=
0 00100c00 49505300 10000000 b8007a01 00000000 00000000
ffff88021a3ef500 3656103779 C Bo:8:005:1 0 4096 >
ffff8802041af540 3657229210 C Bi:8:005:2 0 416 =3D 4e434d48 0c003100 a0=
010c00 49505300 10000000 1c007a01 00000000 4500017a
ffff8802041af540 3657229251 S Bi:8:005:2 -115 16384 <
ffff8802041af240 3659438084 C Bi:8:005:2 -104 0
ffff8802041af9c0 3659438159 C Bi:8:005:2 -104 0
ffff88021a3efc80 3659438206 C Bi:8:005:2 -104 0



Bj=C3=B8rn
