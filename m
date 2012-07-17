From: =?iso-8859-1?Q?Andr=E1s_Tak=E1cs?= <wakoond@wakoond.hu>
Subject: PATCH net/ipv6/mip6.c destopt corruption
Date: Tue, 17 Jul 2012 16:47:34 +0200
Message-ID: <F4227CB5-5E07-457D-8DE5-16CDDABAEE2F@wakoond.hu>
References: <A81B4C3A-8B30-4860-BFE1-AE91F7F0DD6E@wakoond.hu> <A9CE2E85-2DDC-4182-B494-431A6A62BC95@wakoond.hu>
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:34573 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752593Ab2GQOrj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 10:47:39 -0400
Received: by wibhr14 with SMTP id hr14so496501wib.1
        for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 07:47:37 -0700 (PDT)
In-Reply-To: <A9CE2E85-2DDC-4182-B494-431A6A62BC95@wakoond.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Dear All,


I have added a lot of debug messages to the kernel source and finally f=
ound the problem. When the kernel creates the skb from iovec (ip6_appen=
d_data) it sets the pointer of the network header to a wrong position. =
It will be shifted with 24 bytes (it is the length of the HAO dest. opt=
=2E header with paddings).

After this point, the message will be corrupted, the beginning (the fir=
st 24 bytes) of the MH part will be truncated. Later, when the kernel a=
dds the dest. opt. header itself, there isn't any issue.

So, back to the wrong network header pointer. It is shifted by exthdrle=
n (=3D 24) by the skb_set_network_header() function. This exthdrlen com=
es from rt->rt6i_nfheader_len, which comes from the dst_entry chain. Th=
is nfheader_len value comes from the header_len of the desired xfrm typ=
e (in this case hao dest opt):

(net/xfrm/xfrm_policy.c: xfrm_bundle_create)
header_len +=3D xfrm[i]->props.header_len;
if (xfrm[i]->type->flags & XFRM_TYPE_NON_FRAGMENT)
	nfheader_len +=3D xfrm[i]->props.header_len;
=2E..
xfrm_init_path((struct xfrm_dst *)dst0, dst, nfheader_len);

I have run a fast grep on the kernel tree, and this XFRM_TYPE_NON_FRAGM=
ENT does not have any effect, just sets (or not) nfheader_len here. So,=
 the following patch solves the issue:

diff -Nuar linux-3.4.2-orig/net/ipv6/mip6.c linux-3.4.2/net/ipv6/mip6.c
--- linux-3.4.2-orig/net/ipv6/mip6.c	2012-07-17 15:18:30.148777104 +020=
0
+++ linux-3.4.2/net/ipv6/mip6.c	2012-07-17 15:21:12.104779113 +0200
@@ -338,7 +338,7 @@
 	.description	=3D "MIP6DESTOPT",
 	.owner		=3D THIS_MODULE,
 	.proto	     	=3D IPPROTO_DSTOPTS,
-	.flags		=3D XFRM_TYPE_NON_FRAGMENT | XFRM_TYPE_LOCAL_COADDR,
+	.flags		=3D XFRM_TYPE_LOCAL_COADDR,
 	.init_state	=3D mip6_destopt_init_state,
 	.destructor	=3D mip6_destopt_destroy,
 	.input		=3D mip6_destopt_input,
@@ -471,7 +471,7 @@
 	.description	=3D "MIP6RT",
 	.owner		=3D THIS_MODULE,
 	.proto	     	=3D IPPROTO_ROUTING,
-	.flags		=3D XFRM_TYPE_NON_FRAGMENT | XFRM_TYPE_REMOTE_COADDR,
+	.flags		=3D XFRM_TYPE_REMOTE_COADDR,
 	.init_state	=3D mip6_rthdr_init_state,
 	.destructor	=3D mip6_rthdr_destroy,
 	.input		=3D mip6_rthdr_input,

What do you think about this fix? Does it have any drawback?


Ragards,
Andr=E1s


On Jul 16, 2012, at 3:40 PM, Andr=E1s Tak=E1cs wrote:

>=20
> Dear All,
>=20
>=20
> I have serious problems with HAO dest opt XFRM processing. In the pas=
t few days I have tried to find the problem, and I figured out the foll=
owing:
>=20
> 1. case: No XFRM rules
> It works fine (as it was described in my previous e-mail)
>=20
> 2. case: HAO RO XFRM processing
> I have created the following rules manually:
> sudo ip -6 xfrm policy add src 2001:470:7210:10::11 dst 2001:470:7210=
:10::1000 proto 135 type 5 dir out priority 2 ptype sub tmpl src 2001:4=
70:7210:10::11 dst 2001:470:7210:10::1000 proto hao reqid 0 mode ro
> sudo ip -6 xfrm state add src 2001:470:7210:10::11 dst 2001:470:7210:=
10::1000 proto hao reqid 0 mode ro replay-window 0 coa 2001:470:7210:11=
:20c:29ff:fe46:a0e3 sel src 2001:470:7210:10::11 dst 2001:470:7210:10::=
1000
>=20
> The message format is corrupted, because during the xfrm processing, =
the beginning of the MH part will be overwritten by the DST OPT header.
>=20
> 3. case: ESP TUNNEL XFRM
> I have created ESP TUNNEL XFRM rules manually, and it was worked fine=
=2E=20
> So the problem has to be somewhere in the net/ipv6/mip6.c or net/ipv6=
/xfrm_mode_ro.c files.
>=20
> -------------
>=20
> I added a lot of debug printk statements to the source, and I have fi=
gured out the following:
>=20
> When the kernel creates the skb from the iovec, it seems to be ok (in=
 ip6_append_data):
>=20
> skb->data to skb->tail:
> 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 57 39 B1 FB 87 39 B1 =
=46B 64 92 FF FF 18 00 00 00 00 00 00 00 00 00 00 00 3B 03 05 00 00 00 =
00 01 00 00 00 02 01 00 03 10 20 01 04 70 72 10 00 11 02 0C 29 FF FE 46=
 A0 E3
>=20
> Unfortunately at the beginning of the xfrm6_ro_output function, it se=
ems to be corrupt:
>=20
> 60 00 00 00 00 08 87 40 20 01 04 70 72 10 00 10 00 00 00 00 00 00 00 =
11 20 01 04 70 72 10 00 10 00 00 00 00 00 00 10 00 02 0C 29 FF FE 46 A0=
 E3
>=20
> Here missing the first 24 bytes of the MH part. It is quite suspiciou=
s, because the size of the DST OPT header (with the necessary padding) =
is exactly same long.=20
>=20
> After this point xfrm6_ro_output and mip6_destopt_output works fine, =
and insert the DST OPT header to this truncated skb.
>=20
>=20
> Could you please help me to find the connection ("call - graph" ?) be=
tween ip6_append_data and xfrm6_ro_output? I can't find the point where=
 it fails. In ip6_append_data, the beginning of the skb is reserved for=
 the IPv6 header, but where will be this part filled with the right val=
ues?
>=20
>=20
> Thank you very much for your help!
>=20
>=20
> Regards,
> Andr=E1s
>=20
>=20
> On Jun 21, 2012, at 10:41 PM, Andras Takacs wrote:
>=20
>> Dear All,
>>=20
>> I'm working with Mobile IPv6 systems, and I'm setting up a new MIP6 =
environment. I would like to use the latest stable kernel, so I'm using=
 3.4.2. Unfortunately I have some serious problems with destination opt=
ion XFRM processing. I have done the following tests to find the issue:
>>=20
>> First case: No XFRM policies and states.
>> Sending MH messages without destopt header.
>> In this case the message format is OK, I have tested it with tcpdump=
 and wireshark.
>>=20
>> 21:33:58.817130 IP6 2001:470:7210:10::11 > 2001:470:7210:10::1000: m=
obility: BU seq#=3D1 lifetime=3D8
>> 	0x0000:  6000 0000 0020 8740 2001 0470 7210 0010  `......@...pr...
>> 	0x0010:  0000 0000 0000 0011 2001 0470 7210 0010  ...........pr...
>> 	0x0020:  0000 0000 0000 1000 3b03 0500 1c46 0001  ........;....F..
>> 	0x0030:  0000 0002 0100 0310 2001 0470 7210 0011  ...........pr...
>> 	0x0040:  020c 29ff fe46 a0e3                      ..)..F..
>>=20
>> Second case: Adding destopt XFRM policy and state:
>>=20
>> ip -6 xfrm policy add src 2001:470:7210:10::11 dst 2001:470:7210:10:=
:1000 proto 135 type 5 dir out priority 2 ptype sub tmpl src 2001:470:7=
210:10::11 dst 2001:470:7210:10::1000 proto hao reqid 0 mode ro level u=
se
>> ip -6 xfrm state add src 2001:470:7210:10::11 dst 2001:470:7210:10::=
1000 proto hao reqid 0 mode ro replay-window 0 coa 2001:470:7210:11:20c=
:29ff:fe46:a0e3 sel src 2001:470:7210:10::11 dst 2001:470:7210:10::1000
>>=20
>> In this case, the message format is corrupted:
>>=20
>> 21:30:42.350315 IP6 2001:470:7210:11:20c:29ff:fe46:a0e3 > 2001:470:7=
210:10::1000: DSTOPT mobility: type-#41 len=3D12
>> 	0x0000:  6000 0000 0020 3c40 2001 0470 7210 0011  `.....<@...pr...
>> 	0x0010:  020c 29ff fe46 a0e3 2001 0470 7210 0010  ..)..F.....pr...
>> 	0x0020:  0000 0000 0000 1000 8702 0102 0000 c910  ................
>> 	0x0030:  2001 0470 7210 0010 0000 0000 0000 0011  ...pr...........
>> 	0x0040:  020c 29ff fe46 a0e3=20
>>=20
>> As you can see, the IPv6 header is OK. Next, the destination option =
header is OK. Finally, the following part of the packet isn't OK. If yo=
u compare the two dump carefully, you will see, that the last 8 bytes a=
re identical. The mip6_destopt_output function adds the destination opt=
ion header correctly, but overwrites the existing MH header, and doesn'=
t shift it after the destopt header.
>>=20
>> I'm not familiar with the XFRM framework enough to fix the problem. =
:(
>> Maybe, could anyone help to me to fix this issue?
>>=20
>> The last environment, which worked fine was built on 2.6.35 version.=
 The problem happened between 2.6.35 and 3.4.2. Sorry, I know, it is a =
quite big interval. :(
>>=20
>> Thanks!
>>=20
>>=20
>> Best regards,
>> Andr=E1s Tak=E1cs
>=20
