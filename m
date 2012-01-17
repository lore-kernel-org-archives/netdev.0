From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch v2, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet
 multipoint GRE over IP
Date: Tue, 17 Jan 2012 05:47:23 +0100
Message-ID: <1326775643.2564.36.camel@edumazet-laptop>
References: <CAGsizz+x1GVNR9Pz=b7wO0ELx29=FMosfvhQWL5K26EpkwsUCg@mail.gmail.com>
	 <1326745733.2564.14.camel@edumazet-laptop>
	 <CAGsizz+2nH+Sx+7TjZwEeKBiHbio0BxoN7CgT4Sspp0EzRN6Ug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: =?UTF-8?Q?=C5=A0tefan?= Gula <steweg@ynet.sk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGsizz+2nH+Sx+7TjZwEeKBiHbio0BxoN7CgT4Sspp0EzRN6Ug@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 17 janvier 2012 =C3=A0 00:11 +0100, =C5=A0tefan Gula a =C3=A9c=
rit :

> I agree with you, but for the start of this feature I believe static
> slots size is enough here - same limitation is inside the original
> linux bridge code. I have merged hopefully all your comments and here
> is the newest patch:



1) Before sending a new version of your patch, please fix your mailer,
you can read Documentation/email-clients.txt for hints.

Send it to you and check you can apply it.
Then, once you are confident its OK, you can send it to netdev.

Right now, it doesnt apply, because of unexpected line wraps.

# cd next-next
# cat /tmp/patch | patch -p1
patching file include/net/ipip.h
patching file net/ipv4/Kconfig
patching file net/ipv4/ip_gre.c
patch: **** malformed patch at line 495: ipgre_tap_bridge_entry *entry)


2) You call ipgre_tap_bridge_fini() from ipgre_exit_net() and
ipgre_init_net(), thats completely bogus if CONFIG_NET_NS=3Dy

Just remove the struct kmem_cache *ipgre_tap_bridge_cache
and use instead kmalloc(sizeof(...))/kfree(ptr) instead.

3) ipgre_tap_bridge_init() should not be __net_init, but __init


4) I cant find why you store 'struct net_device *dev;' in a
ipgre_tap_bridge_entry, it seems you never read it ?

5) Also please add an empty line between variable declaration and
function body. Also, we prefer an alignement of parameters.

=46or example :

static __be32 ipgre_tap_bridge_get_raddr(struct ip_tunnel *tunnel,
	const unsigned char *addr)
{
	__be32 raddr;
	struct ipgre_tap_bridge_entry *entry;
	rcu_read_lock();
	entry =3D __ipgre_tap_bridge_get(tunnel, addr);
	if (entry =3D=3D NULL)
		raddr =3D 0;
	else
		raddr =3D entry->raddr;
	rcu_read_unlock();
 	return raddr;
}

should be :

static __be32 ipgre_tap_bridge_get_raddr(struct ip_tunnel *tunnel,
					 const unsigned char *addr)
{
	__be32 raddr =3D 0;
	struct ipgre_tap_bridge_entry *entry;

	rcu_read_lock();
	entry =3D __ipgre_tap_bridge_get(tunnel, addr);
	if (entry)
		raddr =3D entry->raddr;
	rcu_read_unlock();

	return raddr;
}
