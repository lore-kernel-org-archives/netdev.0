From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: dev_addr_init() fix
Date: Mon, 08 Jun 2009 15:49:24 +0200
Message-ID: <4A2D16E4.3030702@gmail.com>
References: <19f34abd0905301323k1498ca3fv31b271de65d60afc@mail.gmail.com> <1244408607.9064.8.camel@Maple> <19f34abd0906080300w796c6b65o6b537064cac917b0@mail.gmail.com> <4A2CEB9E.7080109@gmail.com> <4A2D006C.70302@cosmosbay.com> <20090608130653.GB3272@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vegard Nossum <vegard.nossum@gmail.com>,
	John Dykstra <john.dykstra1@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	LKML <linux-kernel@vger.kernel.org>,
	Jiri Pirko <jpirko@redhat.com>
To: Ingo Molnar <mingo@elte.hu>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:52327 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753987AbZFHNvB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 09:51:01 -0400
In-Reply-To: <20090608130653.GB3272@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo Molnar a =E9crit :
> * Eric Dumazet <dada1@cosmosbay.com> wrote:
>=20
>> Eric Dumazet a =E9crit :
>>> Vegard Nossum a =E9crit :
>>>> 2009/6/7 John Dykstra <john.dykstra1@gmail.com>:
>>>>> On Sat, 2009-05-30 at 22:23 +0200, Vegard Nossum wrote:
>>>>>> It seems that loopback's hardware address is never initialized b=
y the
>>>>>> kernel. So if userspace attempts to read this address before it =
has
>>>>>> been set, the kernel will return some uninitialized data (only 6
>>>>>> bytes, though).
>>>>> Thank you for the report, Vegard.
>>>>>
>>>>> I've been unable to reproduce the problem you describe, using
>>>>> 2.6-30-rc8, this test program and a couple of kernel builds for s=
ystem
>>>>> load:
>>>> [...]
>>>>> -----------------------------------------------------------------=
-
>>>>>
>>>>> Looking at the kernel code, it appears that all bytes of struct
>>>>> net_device, including the L2 address, are initialized to zeros at
>>>>> interface creation time.
>>>>>
>>>>> Can you spot a difference between your test procedures and mine t=
hat
>>>>> would enable me to reproduce the problem?
>>>> Hi,
>>>>
>>>> I just tried your test program on a linux-next kernel, it works be=
autifully :-)
>>>>
>>>> (I made one change: The stack grows downwards on x86, so I think y=
ou
>>>> should put child_stack + 16386 as the stack to clone()?)
>>>>
>>>> As I wrote in reply to Stephen Hemminger, this problem seems to be
>>>> caused by a particular patch in linux-next:
>>>>
>>>> commit f001fde5eadd915f4858d22ed70d7040f48767cf
>>>> Author: Jiri Pirko <jpirko@redhat.com>
>>>> Date:   Tue May 5 02:48:28 2009 +0000
>>>>
>>>>    net: introduce a list of device addresses dev_addr_list (v6)
>>>>
>>> I believe following patch should fix this problem.
>>>
>>> Thank you
>>>
>>> [PATCH net-next-2.6] net: loopback device dev->addr_len fix
>>>
>>> commit f001fde5eadd915f4858d22ed70d7040f48767cf=20
>>> (net: introduce a list of device addresses dev_addr_list (v6))
>>> added one regression Vegard Nossum found in its testings.
>>>
>>> loopback device doesnt have a hw address, we should set its
>>> dev->addr_len to 0, not ETH_ALEN.
>>>
>>> Reported-by: Vegard Nossum <vegard.nossum@gmail.com>
>>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> Oh well, following is probably even more appropriate
>>
>> [PATCH net-next-2.6] net: dev_addr_init() fix
>>
>> commit f001fde5eadd915f4858d22ed70d7040f48767cf=20
>> (net: introduce a list of device addresses dev_addr_list (v6))
>> added one regression Vegard Nossum found in its testings.
>>
>> dev_addr_init() incorrectly uses sizeof() operator
>>
>> Reported-by: Vegard Nossum <vegard.nossum@gmail.com>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Could you please put the word 'kmemcheck' somewhere into the=20
> changelog, to make git-grepping and historic comparisons easier?
>=20

Sure I can do that, giving me opportunity to use my current email addre=
ss,
since dada1@cosmosbay.com will disappear shortly.

Thank you

[PATCH net-next-2.6] net: dev_addr_init() fix

commit f001fde5eadd915f4858d22ed70d7040f48767cf=20
(net: introduce a list of device addresses dev_addr_list (v6))
added one regression Vegard Nossum found in its testings.

With kmemcheck help, Vegard found some uninitialized memory
was read and reported to user, potentialy leaking kernel data.
( thread can be found on http://lkml.org/lkml/2009/5/30/177 )

dev_addr_init() incorrectly uses sizeof() operator. We were
initializing one byte instead of MAX_ADDR_LEN bytes.

Reported-by: Vegard Nossum <vegard.nossum@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Acked-by: Jiri Pirko <jpirko@redhat.com>
---

diff --git a/net/core/dev.c b/net/core/dev.c
index 1f38401..65387d9 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3655,8 +3655,8 @@ static int dev_addr_init(struct net_device *dev)
 	/* rtnl_mutex must be held here */
=20
 	INIT_LIST_HEAD(&dev->dev_addr_list);
-	memset(addr, 0, sizeof(*addr));
-	err =3D __hw_addr_add(&dev->dev_addr_list, NULL, addr, sizeof(*addr),
+	memset(addr, 0, sizeof(addr));
+	err =3D __hw_addr_add(&dev->dev_addr_list, NULL, addr, sizeof(addr),
 			    NETDEV_HW_ADDR_T_LAN);
 	if (!err) {
 		/*

