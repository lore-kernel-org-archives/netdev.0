From: "ASIX Allan Email [office]" <allan@asix.com.tw>
Subject: RE: drivers/net/usb/asix: bug in asix_get_wol
Date: Fri, 16 Dec 2011 13:15:56 +0800
Message-ID: <005201ccbbb1$cb242190$616c64b0$@com.tw>
References: <CAKbEaOBODRW1pL4OiwZTKOfqtPEhEOHBBwXQNWVoBh9zzLX9kQ@mail.gmail.com>	<CANEJEGud6++PGHRZGt1xMonX1XvxeU19Wd3YNsbgLQG+uQi47g@mail.gmail.com>	<CAKbEaOBnGAJuZiM5BRaR3RD6EzgB-mCVrC0v2AbnniFpx22m8A@mail.gmail.com> <CANEJEGvz2ZHD_ZNJm_WeKCdVE9pmSQJY5dCe8hNayAS0MFN=-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, "'Freddy Xin'" <freddy@asix.com.tw>,
	=?utf-8?B?QVNJWCBMb3VpcyBb6JiH5aiB6Zm4XQ==?= <louis@asix.com.tw>
To: "'Grant Grundler'" <grundler@chromium.org>,
	"'Eugene'" <elubarsky@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from asix.com.tw ([113.196.140.82]:56536 "EHLO asix.com.tw"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750921Ab1LPFQU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 00:16:20 -0500
In-Reply-To: 
Content-Language: zh-tw
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resend without attachment due to below email server error.=20

=3D=3D=3D=3D=3D=3D=3D=3D
   ----- The following addresses had permanent fatal errors -----
<grundler@chromium.org>
    (reason: 552-5.7.0 Our system detected an illegal attachment on you=
r message. Please)
<elubarsky@gmail.com>
    (reason: 552-5.7.0 Our system detected an illegal attachment on you=
r message. Please)



---
Best regards,
Allan Chou
Technical Support Division
ASIX Electronics Corporation
TEL: 886-3-5799500 ext.228
=46AX: 886-3-5799558
E-mail: allan@asix.com.tw=20
http://www.asix.com.tw/=20


-----Original Message-----
=46rom: ASIX Allan Email [office] [mailto:allan@asix.com.tw]=20
Sent: Friday, December 16, 2011 11:38 AM
To: 'Grant Grundler'; 'Eugene'
Cc: 'netdev@vger.kernel.org'; 'Freddy Xin'; ASIX Louis [=E8=98=87=E5=A8=
=81=E9=99=B8]
Subject: RE: drivers/net/usb/asix: bug in asix_get_wol
Importance: High

Dear Grant and Eugene,

Please refer to the attached file and below statements to modify the as=
ix_get_wol() routine and let us know if this suggestion can solve your =
issues or not? Thanks a lot.

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
static void
asix_get_wol(struct net_device *net, struct ethtool_wolinfo *wolinfo)
{
	struct usbnet *dev =3D netdev_priv(net);
	u8 opt;

	if (asix_read_cmd(dev, AX_CMD_READ_MONITOR_MODE, 0, 0, 1, &opt) < 0) {
		wolinfo->supported =3D 0;
		wolinfo->wolopts =3D 0;
		return;
	}
	wolinfo->supported =3D WAKE_PHY | WAKE_MAGIC;
	wolinfo->wolopts =3D 0;
	if (opt & AX_MONITOR_LINK)
		wolinfo->wolopts |=3D WAKE_PHY;
	if (opt & AX_MONITOR_MAGIC)
		wolinfo->wolopts |=3D WAKE_MAGIC;
}


---
Best regards,
Allan Chou
Technical Support Division
ASIX Electronics Corporation
TEL: 886-3-5799500 ext.228
=46AX: 886-3-5799558
E-mail: allan@asix.com.tw=20
http://www.asix.com.tw/=20


-----Original Message-----
=46rom: grundler@google.com [mailto:grundler@google.com] On Behalf Of G=
rant Grundler
Sent: Friday, December 16, 2011 12:48 AM
To: Eugene; Allan Chou
Cc: netdev@vger.kernel.org; Freddy Xin
Subject: Re: drivers/net/usb/asix: bug in asix_get_wol

On Tue, Dec 13, 2011 at 5:03 AM, Eugene <elubarsky@gmail.com> wrote:
> Hi Grant,
>
>
> The problem is that, as it's currently written, asix_get_wol always
> returns that wake-on-lan is disabled.

I think that was the intent.

Allan, can you please confirm?

thanks,
grant

>
>
> Cheers,
> Eugene
>
> On 12 December 2011 10:29, Grant Grundler <grundler@chromium.org> wro=
te:
>> [+freddy/allan @ ASIX]
>>
>> On Sat, Dec 10, 2011 at 5:02 PM, Eugene <elubarsky@gmail.com> wrote:
>>> Dear kernel devs,
>>>
>>> Thanks for the commit at
>>> http://git.kernel.org/?p=3Dlinux/kernel/git/next/linux-next.git;a=3D=
commitdiff;h=3D4ad1438f025ed8d1e4e95a796ca7f0ad5a22c378,
>>> It successfully stops my adapter from dying when wake-on-lan gets
>>> enabled.
>>
>> Hi Eugene!
>> thanks for the "it works!" report.
>>
>>> However, I've noticed that it has broken asix_get_wol - the
>>> lines
>>>
>>>       if (opt & AX_MONITOR_LINK)
>>>               wolinfo->wolopts |=3D WAKE_PHY;
>>>       if (opt & AX_MONITOR_MAGIC)
>>>               wolinfo->wolopts |=3D WAKE_MAGIC;
>>>
>>> have been accidentally removed.
>>
>> This wasn't by accident. This comment in the commit log perhaps
>> doesn't explain sufficiently:
>> |    Remove MONITOR_MODE. In this mode, Received packets are not buf=
fered when
>> | the remote wakeup is enabled.
>>
>>> The vendor driver has them, and I've
>>> successfully tested a kernel with these lines included. The change =
is
>>> too small for me to bother sending in a properly formatted patch...
>>
>> "Too small"? No such thing. :)
>>
>> cheers,
>> grant
