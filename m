From: "Daniel Blueman" <daniel.blueman@gmx.net>
Subject: Re: [2.6.0-test9] QoS HTB crash...
Date: Sat, 1 Nov 2003 19:13:27 +0100 (MET)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <4371.1067710407@www6.gmx.net>
References: <20031030130859.605f856d.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: devik@cdi.cz, netdev@oss.sgi.com, linux-net@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
List-Id: netdev.vger.kernel.org

Having applied this patch, I still get this issue when I kill pppd:

Oops: 0002 [#1]
CPU:    0
>>EIP; c02ced99 <htb_unbind_filter+49/6b>   <=3D=3D=3D=3D=3D

>>ebx; d9c0586c <_end+19797f60/3fb906f4>
>>ecx; dc95adf8 <_end+1c4ed4ec/3fb906f4>
>>edx; d9c057f8 <_end+19797eec/3fb906f4>
>>esi; dc95adf8 <_end+1c4ed4ec/3fb906f4>
>>edi; df4eceac <_end+1f07f5a0/3fb906f4>
>>ebp; d9c4bdfc <_end+197de4f0/3fb906f4>
>>esp; d9c4bde4 <_end+197de4d8/3fb906f4>

Trace; c011a647 <kernel_map_pages+28/5d>
Trace; c02d3876 <u32_destroy_key+6a/6c>
Trace; c02d3b1f <u32_clear_hnode+2e/48>
Trace; c02d3b5e <u32_destroy_hnode+25/a9>
Trace; c011a647 <kernel_map_pages+28/5d>
Trace; c02d3cc4 <u32_destroy+e2/110>
Trace; c02ce073 <htb_destroy_class+18b/1c3>
Trace; c02cdedc <htb_destroy_filters+1d/29>
Trace; c02ce112 <htb_destroy+67/d2>
Trace; c02c1ea9 <qdisc_destroy+81/92>
Trace; c02c260a <dev_shutdown+aa/268>
Trace; c01398e8 <wakeme_after_rcu+0/c>
Trace; c02b59e2 <unregister_netdevice+db/352>
Trace; c02bd6ce <rtnl_lock+22/37>
Trace; c0235f8c <unregister_netdev+19/25>
Trace; c023c1ce <ppp_shutdown_interface+21e/3ba>
Trace; c0183836 <dput+23/723>
Trace; c016527c <__fput+7c/cd>
Trace; c02363a5 <ppp_release+5f/61>
Trace; c01652bb <__fput+bb/cd>
Trace; c0163353 <filp_close+57/81>
Trace; c0163481 <sys_close+104/228>
Trace; c010a3eb <syscall_call+7/b>

Code;  c02ced99 <htb_unbind_filter+49/6b>
00000000 <_EIP>:
Code;  c02ced99 <htb_unbind_filter+49/6b>   <=3D=3D=3D=3D=3D
   0:   83 ae 58 01 00 00 01      subl   $0x1,0x158(%esi)   <=3D=3D=3D=3D=
=3D
Code;  c02ceda0 <htb_unbind_filter+50/6b>
   7:   8b 5d f8                  mov    0xfffffff8(%ebp),%ebx
Code;  c02ceda3 <htb_unbind_filter+53/6b>
   a:   8b 75 fc                  mov    0xfffffffc(%ebp),%esi
Code;  c02ceda6 <htb_unbind_filter+56/6b>
   d:   89 ec                     mov    %ebp,%esp
Code;  c02ceda8 <htb_unbind_filter+58/6b>
   f:   5d                        pop    %ebp
Code;  c02ceda9 <htb_unbind_filter+59/6b>
  10:   c3                        ret
Code;  c02cedaa <htb_unbind_filter+5a/6b>
  11:   83 ab 3c 00 00 00 00      subl   $0x0,0x3c(%ebx)

 <0>Kernel panic: Fatal exception in interrupt

---

> On Thu, 30 Oct 2003 20:50:16 +0100 (CET)
> devik <devik@cdi.cz> wrote:
>=20
> > thanks for the report. I know that there is an issue regarding
> > HTB in 2.6.x. Please send me net/sched/sch_htb.o,
> > net/sched/sch_htb.c (just to be sure) and be sure that you
> > build the kernel with debugging symbols (see debugging section
> > of menuconfig/xconfig).
>=20
> I think the problem is the changes that were made
> in 2.5.x to htb_next_rb_node().  It used to be:
>=20
> static void htb_next_rb_node(rb_node_t **n)
> {
>         rb_node_t *p;
>         if ((*n)->rb_right) {
>                 /* child at right. use it or its leftmost ancestor */
>                 *n =3D (*n)->rb_right;
>                 while ((*n)->rb_left)
>                         *n =3D (*n)->rb_left;
>                 return;
>         }
>         while ((p =3D (*n)->rb_parent) !=3D NULL) {
>                 /* if we've arrived from left child then we have next=
 node
> */
>                 if (p->rb_left =3D=3D *n) break;
>                 *n =3D p;
>         }
>         *n =3D p;
> }
>=20
> But it was changed into:
>=20
> static void htb_next_rb_node(struct rb_node **n)
> {
>         *n =3D rb_next(*n);
> }
>=20
> This is wrong, the new code has much different side effects
> than the original code.
>=20
> This looks like the problem, devik what do you think?
>=20

--=20
Daniel J Blueman

NEU F=DCR ALLE - GMX MediaCenter - f=FCr Fotos, Musik, Dateien...
=46otoalbum, File Sharing, MMS, Multimedia-Gru=DF, GMX FotoService

Jetzt kostenlos anmelden unter http://www.gmx.net

+++ GMX - die erste Adresse f=FCr Mail, Message, More! +++

