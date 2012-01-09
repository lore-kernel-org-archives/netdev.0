From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: RE: asix, setting MAC broken in v3.2. Bisected to "NET: fix phy
 init for AX88772 USB ethernet".
Date: Mon, 09 Jan 2012 12:53:24 +0200
Message-ID: <20120109125324.14414ynmnofsl5gc@www.81.fi>
References: <20120106131051.92814bd4b7x0nmqs@www.81.fi>
 <CANEJEGvXST4YzDL4kuF=kjZBN=ng-bC5UptCU2zk6JUmhpVjmg@mail.gmail.com>
 <20120108171802.287811bpiixnymys@www.81.fi>
 <002001ccce1a$3c5337a0$b4f9a6e0$@com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	DelSp=Yes	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: 'Grant Grundler' <grundler@chromium.org>, netdev@vger.kernel.org,
	'Freddy Xin' <freddy@asix.com.tw>,
	'Olof Johansson' <olofj@chromium.org>,
	"'David S. Miller'" <davem@davemloft.net>,
	'David Hollis' <dhollis@davehollis.com>
To: allan <allan@asix.com.tw>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-mail-sa-02.sanoma.fi ([158.127.18.162]:48882 "EHLO
	sd-mail-sa-02.sanoma.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752050Ab2AIKxe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2012 05:53:34 -0500
In-Reply-To: <002001ccce1a$3c5337a0$b4f9a6e0$@com.tw>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Yes, that is exactly what I have for interface initialization. System =20
is running Debian Squeeze, with following entry in =20
/etc/network/interfaces:

  # wan1 is asix device
  auto wan1
  iface wan1 inet dhcp
          pre-up /etc/network/change-mac-addr-to.sh wan1 00:02:xx:xx:xx=
:xx

and change-mac-addr-to.sh is:

  #!/bin/sh

  # check if mac address already set
  if [ "$(ifconfig "$1" | grep HWaddr | grep "$2")" =3D "" ]; then
          # set new mac
          ifconfig "$1" down
          ifconfig "$1" hw ether "$2"
          ifconfig "$1" up

          echo Changed MAC-address for interface $1 to $2
  fi

  exit 0

This works with kernel v3.1, but not with v3.2. Not working means: 1. =20
DHCP does not work on wan1/asix, does not receive answer from DHCP =20
server. 2. PPPoE connection doesn't initialize over wan1/asix. (DHCP =20
is for ISP private/local network and Internet connection is through =20
PPPoE).

With v3.2 I found out that enabling promisc for wan1 interface =20
(ifconfig wan1 promisc 1) allows DHCP and PPPoE to make connection and =
=20
to work.

Also the patch attached in previous message (patch is for kernel v3.2) =
=20
fixes the problem (for me).

-Jussi

Quoting allan <allan@asix.com.tw>:

> Dear Jussi,
>
> Please help to double check if the following information is helpful =20
> to solve your issue or not? If no, please deliver us your test
asix.c
> driver file and detailed test procedures for further investigation. =20
> Thanks a lot.
>
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> Actually, if you just want to manually set the MAC address of your =20
> AX88772B/AX88772A/AX88178 devices for engineering testing, you can =20
> refer to below procedures to temporary change the MAC address of
your
> AX88772B/AX88772A/AX88178 device on Linux platform through the =20
> =E2=80=9Cax8817x_set_mac_addr()=E2=80=9D routine of AX88772B/AX88772A=
/AX88178
Linux
> driver source code.
>
> How to change MAC address in Linux
>
http://linuxhelp.blogspot.com/2005/09/how-to-change-mac-address-of-your=
=2Ehtml
>
> # ifconfig eth0 down
> # ifconfig eth0 hw ether 00:80:48:BA:d1:30
> # ifconfig eth0 up
>
>
> ---
> Best regards,
> Allan Chou
> Technical Support Division
> ASIX Electronics Corporation
> TEL: 886-3-5799500 ext.228
> FAX: 886-3-5799558
> E-mail: allan@asix.com.tw
> http://www.asix.com.tw/
>
> -----Original Message-----
> From: Jussi Kivilinna [mailto:jussi.kivilinna@mbnet.fi]
> Sent: Sunday, January 08, 2012 11:18 PM
> To: Grant Grundler
> Cc: netdev@vger.kernel.org; Freddy Xin; Olof Johansson; David S. =20
> Miller; David Hollis; Allan Chou
> Subject: Re: asix, setting MAC broken in v3.2. Bisected to "NET: fix

> phy init for AX88772 USB ethernet".
>
> Quoting Grant Grundler <grundler@chromium.org>:
>
>> On Fri, Jan 6, 2012 at 3:10 AM, Jussi Kivilinna
>> <jussi.kivilinna@mbnet.fi> wrote:
>>> Hello,
>>>
>>> I have asix adapter plugged to mini-server
>>
>> Which Asix adapter do you have? (Vendor/model)
>
> It's Wii Ethernet adapter,
> Bus 001 Device 008: ID 0b95:7720 ASIX Electronics Corp. AX88772
>
>>
>> Can you please provide:
>> 1) dmesg output from asix driver
>> 2) lsusb output for the device
>
> Both attached.
>
>>> and have to change MAC address
>>> before DHCP because of ISP. This worked fine, until v3.2. Now I
have to set
>>> interface in promisc mode to have custom MAC working.
>>
>> Sorry - I didn't test this but I also would not expect this to
break
>> with the changes in 3.2.
>>
>> I'll see if Freddy or Allan (ASIX) need my help with this.
>
> I found out that setting MAC in ax88722_reset() solves the issue for
> me. Maybe changes to init/reset sequence causes hardware to be
reseted
> after set_mac_address call and revert to default MAC?
>
> Patch attached.
>
> -Jussi
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
