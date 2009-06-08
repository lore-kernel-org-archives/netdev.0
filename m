From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: loopback device dev->addr_len fix
Date: Mon, 08 Jun 2009 12:44:46 +0200
Message-ID: <4A2CEB9E.7080109@gmail.com>
References: <19f34abd0905301323k1498ca3fv31b271de65d60afc@mail.gmail.com>	 <1244408607.9064.8.camel@Maple> <19f34abd0906080300w796c6b65o6b537064cac917b0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John Dykstra <john.dykstra1@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	LKML <linux-kernel@vger.kernel.org>,
	Jiri Pirko <jpirko@redhat.com>
To: Vegard Nossum <vegard.nossum@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:35926 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752825AbZFHKpP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 06:45:15 -0400
In-Reply-To: <19f34abd0906080300w796c6b65o6b537064cac917b0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vegard Nossum a =C3=A9crit :
> 2009/6/7 John Dykstra <john.dykstra1@gmail.com>:
>> On Sat, 2009-05-30 at 22:23 +0200, Vegard Nossum wrote:
>>> It seems that loopback's hardware address is never initialized by t=
he
>>> kernel. So if userspace attempts to read this address before it has
>>> been set, the kernel will return some uninitialized data (only 6
>>> bytes, though).
>> Thank you for the report, Vegard.
>>
>> I've been unable to reproduce the problem you describe, using
>> 2.6-30-rc8, this test program and a couple of kernel builds for syst=
em
>> load:
> [...]
>> ------------------------------------------------------------------
>>
>> Looking at the kernel code, it appears that all bytes of struct
>> net_device, including the L2 address, are initialized to zeros at
>> interface creation time.
>>
>> Can you spot a difference between your test procedures and mine that
>> would enable me to reproduce the problem?
>=20
> Hi,
>=20
> I just tried your test program on a linux-next kernel, it works beaut=
ifully :-)
>=20
> (I made one change: The stack grows downwards on x86, so I think you
> should put child_stack + 16386 as the stack to clone()?)
>=20
> As I wrote in reply to Stephen Hemminger, this problem seems to be
> caused by a particular patch in linux-next:
>=20
> commit f001fde5eadd915f4858d22ed70d7040f48767cf
> Author: Jiri Pirko <jpirko@redhat.com>
> Date:   Tue May 5 02:48:28 2009 +0000
>=20
>    net: introduce a list of device addresses dev_addr_list (v6)
>=20

I believe following patch should fix this problem.

Thank you

[PATCH net-next-2.6] net: loopback device dev->addr_len fix

commit f001fde5eadd915f4858d22ed70d7040f48767cf=20
(net: introduce a list of device addresses dev_addr_list (v6))
added one regression Vegard Nossum found in its testings.

loopback device doesnt have a hw address, we should set its
dev->addr_len to 0, not ETH_ALEN.

Reported-by: Vegard Nossum <vegard.nossum@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index da472c6..40ded4e 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -166,7 +166,7 @@ static void loopback_setup(struct net_device *dev)
 {
 	dev->mtu		=3D (16 * 1024) + 20 + 20 + 12;
 	dev->hard_header_len	=3D ETH_HLEN;	/* 14	*/
-	dev->addr_len		=3D ETH_ALEN;	/* 6	*/
+	dev->addr_len		=3D 0;
 	dev->tx_queue_len	=3D 0;
 	dev->type		=3D ARPHRD_LOOPBACK;	/* 0x0001*/
 	dev->flags		=3D IFF_LOOPBACK;

