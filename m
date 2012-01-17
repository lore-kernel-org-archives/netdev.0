From: =?ISO-8859-2?Q?=A9tefan_Gula?= <steweg@ynet.sk>
Subject: Re: [patch v2, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet
 multipoint GRE over IP
Date: Tue, 17 Jan 2012 09:04:00 +0100
Message-ID: <CAGsizz+kgBB9APmU9dPExkGQvPUVa3m6qz3NvSguPYNuJQQ_7Q@mail.gmail.com>
References: <CAGsizz+x1GVNR9Pz=b7wO0ELx29=FMosfvhQWL5K26EpkwsUCg@mail.gmail.com>
 <1326745733.2564.14.camel@edumazet-laptop> <CAGsizz+2nH+Sx+7TjZwEeKBiHbio0BxoN7CgT4Sspp0EzRN6Ug@mail.gmail.com>
 <1326775643.2564.36.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1326775643.2564.36.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

D=C5=88a 17. janu=C3=A1ra 2012 5:47, Eric Dumazet <eric.dumazet@gmail.c=
om> nap=C3=ADsal/a:
> Le mardi 17 janvier 2012 =C3=A0 00:11 +0100, =C5=A0tefan Gula a =C3=A9=
crit :
>
>> I agree with you, but for the start of this feature I believe static
>> slots size is enough here - same limitation is inside the original
>> linux bridge code. I have merged hopefully all your comments and her=
e
>> is the newest patch:
>
>
>
> 1) Before sending a new version of your patch, please fix your mailer=
,
> you can read Documentation/email-clients.txt for hints.
>
Sorry, I have to test it as I am using clasical gmail web GUI to send e=
mails

> Send it to you and check you can apply it.
> Then, once you are confident its OK, you can send it to netdev.
>
> Right now, it doesnt apply, because of unexpected line wraps.
>
> # cd next-next
> # cat /tmp/patch | patch -p1
> patching file include/net/ipip.h
> patching file net/ipv4/Kconfig
> patching file net/ipv4/ip_gre.c
> patch: **** malformed patch at line 495: ipgre_tap_bridge_entry *entr=
y)
>
>
> 2) You call ipgre_tap_bridge_fini() from ipgre_exit_net() and
> ipgre_init_net(), thats completely bogus if CONFIG_NET_NS=3Dy
>
> Just remove the struct kmem_cache *ipgre_tap_bridge_cache
> and use instead kmalloc(sizeof(...))/kfree(ptr) instead.
>
As this is completely the same part of code from net/bridge/br_fdb.c,
can you give me a hint about how change that as I believe it should be
changed also there?

> 3) ipgre_tap_bridge_init() should not be __net_init, but __init
>
Ok

>
> 4) I cant find why you store 'struct net_device *dev;' in a
> ipgre_tap_bridge_entry, it seems you never read it ?
>
yes you are right, it is not needed - removed from code

> 5) Also please add an empty line between variable declaration and
> function body. Also, we prefer an alignement of parameters.
>
I used scripts/checkpatch.pl to check my coding styles, but apparently
this is missing from it as it never complains before about this.
Anyway hopefully done ok based your comments

> For example :
>
> static __be32 ipgre_tap_bridge_get_raddr(struct ip_tunnel *tunnel,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0const unsigned char *addr)
> {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0__be32 raddr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct ipgre_tap_bridge_entry *entry;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0rcu_read_lock();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0entry =3D __ipgre_tap_bridge_get(tunnel, a=
ddr);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (entry =3D=3D NULL)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0raddr =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0else
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0raddr =3D entr=
y->raddr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0rcu_read_unlock();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return raddr;
> }
>
> should be :
>
> static __be32 ipgre_tap_bridge_get_raddr(struct ip_tunnel *tunnel,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
const unsigned char *addr)
> {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0__be32 raddr =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct ipgre_tap_bridge_entry *entry;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0rcu_read_lock();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0entry =3D __ipgre_tap_bridge_get(tunnel, a=
ddr);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (entry)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0raddr =3D entr=
y->raddr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0rcu_read_unlock();
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return raddr;
> }
>
>
>
>
>
>
