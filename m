From: Andras Takacs <wakoond@wakoond.hu>
Subject: 3.4.2 net/ipv6/mip6.c destopt regression
Date: Thu, 21 Jun 2012 22:41:49 +0200
Message-ID: <A81B4C3A-8B30-4860-BFE1-AE91F7F0DD6E@wakoond.hu>
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:37278 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753062Ab2FUUl5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2012 16:41:57 -0400
Received: by wgbdr13 with SMTP id dr13so1071959wgb.1
        for <netdev@vger.kernel.org>; Thu, 21 Jun 2012 13:41:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear All,

I'm working with Mobile IPv6 systems, and I'm setting up a new MIP6 env=
ironment. I would like to use the latest stable kernel, so I'm using 3.=
4.2. Unfortunately I have some serious problems with destination option=
 XFRM processing. I have done the following tests to find the issue:

=46irst case: No XFRM policies and states.
Sending MH messages without destopt header.
In this case the message format is OK, I have tested it with tcpdump an=
d wireshark.

21:33:58.817130 IP6 2001:470:7210:10::11 > 2001:470:7210:10::1000: mobi=
lity: BU seq#=3D1 lifetime=3D8
	0x0000:  6000 0000 0020 8740 2001 0470 7210 0010  `......@...pr...
	0x0010:  0000 0000 0000 0011 2001 0470 7210 0010  ...........pr...
	0x0020:  0000 0000 0000 1000 3b03 0500 1c46 0001  ........;....F..
	0x0030:  0000 0002 0100 0310 2001 0470 7210 0011  ...........pr...
	0x0040:  020c 29ff fe46 a0e3                      ..)..F..

Second case: Adding destopt XFRM policy and state:

ip -6 xfrm policy add src 2001:470:7210:10::11 dst 2001:470:7210:10::10=
00 proto 135 type 5 dir out priority 2 ptype sub tmpl src 2001:470:7210=
:10::11 dst 2001:470:7210:10::1000 proto hao reqid 0 mode ro level use
ip -6 xfrm state add src 2001:470:7210:10::11 dst 2001:470:7210:10::100=
0 proto hao reqid 0 mode ro replay-window 0 coa 2001:470:7210:11:20c:29=
ff:fe46:a0e3 sel src 2001:470:7210:10::11 dst 2001:470:7210:10::1000

In this case, the message format is corrupted:

21:30:42.350315 IP6 2001:470:7210:11:20c:29ff:fe46:a0e3 > 2001:470:7210=
:10::1000: DSTOPT mobility: type-#41 len=3D12
	0x0000:  6000 0000 0020 3c40 2001 0470 7210 0011  `.....<@...pr...
	0x0010:  020c 29ff fe46 a0e3 2001 0470 7210 0010  ..)..F.....pr...
	0x0020:  0000 0000 0000 1000 8702 0102 0000 c910  ................
	0x0030:  2001 0470 7210 0010 0000 0000 0000 0011  ...pr...........
	0x0040:  020c 29ff fe46 a0e3=20

As you can see, the IPv6 header is OK. Next, the destination option hea=
der is OK. Finally, the following part of the packet isn't OK. If you c=
ompare the two dump carefully, you will see, that the last 8 bytes are =
identical. The mip6_destopt_output function adds the destination option=
 header correctly, but overwrites the existing MH header, and doesn't s=
hift it after the destopt header.

I'm not familiar with the XFRM framework enough to fix the problem. :(
Maybe, could anyone help to me to fix this issue?

The last environment, which worked fine was built on 2.6.35 version. Th=
e problem happened between 2.6.35 and 3.4.2. Sorry, I know, it is a qui=
te big interval. :(

Thanks!


Best regards,
Andr=E1s Tak=E1cs