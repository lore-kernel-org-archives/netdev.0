From: =?iso-8859-1?Q?Andr=E1s_Tak=E1cs?= <wakoond@wakoond.hu>
Subject: Re: 3.4.2 net/ipv6/mip6.c destopt regression
Date: Mon, 16 Jul 2012 15:40:25 +0200
Message-ID: <A9CE2E85-2DDC-4182-B494-431A6A62BC95@wakoond.hu>
References: <A81B4C3A-8B30-4860-BFE1-AE91F7F0DD6E@wakoond.hu>
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:59824 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753155Ab2GPNka convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 09:40:30 -0400
Received: by eaak11 with SMTP id k11so1662503eaa.19
        for <netdev@vger.kernel.org>; Mon, 16 Jul 2012 06:40:28 -0700 (PDT)
In-Reply-To: <A81B4C3A-8B30-4860-BFE1-AE91F7F0DD6E@wakoond.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Dear All,


I have serious problems with HAO dest opt XFRM processing. In the past =
few days I have tried to find the problem, and I figured out the follow=
ing:

1. case: No XFRM rules
It works fine (as it was described in my previous e-mail)

2. case: HAO RO XFRM processing
I have created the following rules manually:
sudo ip -6 xfrm policy add src 2001:470:7210:10::11 dst 2001:470:7210:1=
0::1000 proto 135 type 5 dir out priority 2 ptype sub tmpl src 2001:470=
:7210:10::11 dst 2001:470:7210:10::1000 proto hao reqid 0 mode ro
sudo ip -6 xfrm state add src 2001:470:7210:10::11 dst 2001:470:7210:10=
::1000 proto hao reqid 0 mode ro replay-window 0 coa 2001:470:7210:11:2=
0c:29ff:fe46:a0e3 sel src 2001:470:7210:10::11 dst 2001:470:7210:10::10=
00

The message format is corrupted, because during the xfrm processing, th=
e beginning of the MH part will be overwritten by the DST OPT header.

3. case: ESP TUNNEL XFRM
I have created ESP TUNNEL XFRM rules manually, and it was worked fine.=20
So the problem has to be somewhere in the net/ipv6/mip6.c or net/ipv6/x=
frm_mode_ro.c files.

-------------

I added a lot of debug printk statements to the source, and I have figu=
red out the following:

When the kernel creates the skb from the iovec, it seems to be ok (in i=
p6_append_data):

skb->data to skb->tail:
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 57 39 B1 FB 87 39 B1 FB=
 64 92 FF FF 18 00 00 00 00 00 00 00 00 00 00 00 3B 03 05 00 00 00 00 0=
1 00 00 00 02 01 00 03 10 20 01 04 70 72 10 00 11 02 0C 29 FF FE 46 A0 =
E3

Unfortunately at the beginning of the xfrm6_ro_output function, it seem=
s to be corrupt:

60 00 00 00 00 08 87 40 20 01 04 70 72 10 00 10 00 00 00 00 00 00 00 11=
 20 01 04 70 72 10 00 10 00 00 00 00 00 00 10 00 02 0C 29 FF FE 46 A0 E=
3

Here missing the first 24 bytes of the MH part. It is quite suspicious,=
 because the size of the DST OPT header (with the necessary padding) is=
 exactly same long.=20

After this point xfrm6_ro_output and mip6_destopt_output works fine, an=
d insert the DST OPT header to this truncated skb.


Could you please help me to find the connection ("call - graph" ?) betw=
een ip6_append_data and xfrm6_ro_output? I can't find the point where i=
t fails. In ip6_append_data, the beginning of the skb is reserved for t=
he IPv6 header, but where will be this part filled with the right value=
s?


Thank you very much for your help!


Regards,
Andr=E1s


On Jun 21, 2012, at 10:41 PM, Andras Takacs wrote:

> Dear All,
>=20
> I'm working with Mobile IPv6 systems, and I'm setting up a new MIP6 e=
nvironment. I would like to use the latest stable kernel, so I'm using =
3.4.2. Unfortunately I have some serious problems with destination opti=
on XFRM processing. I have done the following tests to find the issue:
>=20
> First case: No XFRM policies and states.
> Sending MH messages without destopt header.
> In this case the message format is OK, I have tested it with tcpdump =
and wireshark.
>=20
> 21:33:58.817130 IP6 2001:470:7210:10::11 > 2001:470:7210:10::1000: mo=
bility: BU seq#=3D1 lifetime=3D8
> 	0x0000:  6000 0000 0020 8740 2001 0470 7210 0010  `......@...pr...
> 	0x0010:  0000 0000 0000 0011 2001 0470 7210 0010  ...........pr...
> 	0x0020:  0000 0000 0000 1000 3b03 0500 1c46 0001  ........;....F..
> 	0x0030:  0000 0002 0100 0310 2001 0470 7210 0011  ...........pr...
> 	0x0040:  020c 29ff fe46 a0e3                      ..)..F..
>=20
> Second case: Adding destopt XFRM policy and state:
>=20
> ip -6 xfrm policy add src 2001:470:7210:10::11 dst 2001:470:7210:10::=
1000 proto 135 type 5 dir out priority 2 ptype sub tmpl src 2001:470:72=
10:10::11 dst 2001:470:7210:10::1000 proto hao reqid 0 mode ro level us=
e
> ip -6 xfrm state add src 2001:470:7210:10::11 dst 2001:470:7210:10::1=
000 proto hao reqid 0 mode ro replay-window 0 coa 2001:470:7210:11:20c:=
29ff:fe46:a0e3 sel src 2001:470:7210:10::11 dst 2001:470:7210:10::1000
>=20
> In this case, the message format is corrupted:
>=20
> 21:30:42.350315 IP6 2001:470:7210:11:20c:29ff:fe46:a0e3 > 2001:470:72=
10:10::1000: DSTOPT mobility: type-#41 len=3D12
> 	0x0000:  6000 0000 0020 3c40 2001 0470 7210 0011  `.....<@...pr...
> 	0x0010:  020c 29ff fe46 a0e3 2001 0470 7210 0010  ..)..F.....pr...
> 	0x0020:  0000 0000 0000 1000 8702 0102 0000 c910  ................
> 	0x0030:  2001 0470 7210 0010 0000 0000 0000 0011  ...pr...........
> 	0x0040:  020c 29ff fe46 a0e3=20
>=20
> As you can see, the IPv6 header is OK. Next, the destination option h=
eader is OK. Finally, the following part of the packet isn't OK. If you=
 compare the two dump carefully, you will see, that the last 8 bytes ar=
e identical. The mip6_destopt_output function adds the destination opti=
on header correctly, but overwrites the existing MH header, and doesn't=
 shift it after the destopt header.
>=20
> I'm not familiar with the XFRM framework enough to fix the problem. :=
(
> Maybe, could anyone help to me to fix this issue?
>=20
> The last environment, which worked fine was built on 2.6.35 version. =
The problem happened between 2.6.35 and 3.4.2. Sorry, I know, it is a q=
uite big interval. :(
>=20
> Thanks!
>=20
>=20
> Best regards,
> Andr=E1s Tak=E1cs
