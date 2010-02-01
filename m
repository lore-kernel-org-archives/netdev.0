From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: debug: nt_conntrack and KVM crash
Date: Mon, 01 Feb 2010 12:23:57 +0100
Message-ID: <1265023437.2848.30.camel@edumazet-laptop>
References: <1264813832.2793.446.camel@tonnant>
	 <1264816634.2793.505.camel@tonnant> <1264816777.2793.510.camel@tonnant>
	 <1264834704.2919.3.camel@edumazet-laptop>
	 <1265016745.7499.144.camel@tonnant>
	 <b6fcc0a1002010136k7e78a998p31a9e7464c2e8d44@mail.gmail.com>
	 <1265019160.2848.14.camel@edumazet-laptop>
	 <b6fcc0a1002010225u4e74f9f0q633d73038234dc37@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jon Masters <jonathan@jonmasters.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <b6fcc0a1002010225u4e74f9f0q633d73038234dc37@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 01 f=C3=A9vrier 2010 =C3=A0 12:25 +0200, Alexey Dobriyan a =C3=
=A9crit :

> > 2) nf_conntrack_cachep is shared, it should be not shared.
>=20
> There is no need for it to be shared, unless you measured something.
>=20

I wrote the algos, I know that we need different slab caches, for sure,
this is not something I can _measure_, but theory can predict.

SLAB_DESTROY_BY_RCU has very special semantics, you can ask Paul E.
McKenny for details if you dont trust me.

If you use a shared slab cache, one object can instantly flight between
one hash table (netns ONE) to another one (netns TWO), and concurrent
reader (doing a lookup in netns ONE, 'finding' an object of netns TWO)
can be fooled without notice, because no RCU grace period has to be
observed between object freeing and its reuse.

We dont have this problem with UDP/TCP slab caches because TCP/UDP
hashtables are global to the machine (and each object has a pointer to
its netns).

If we use per netns conntrack hash tables, we also *must* use per netns
conntrack slab caches, to guarantee an object can not escape from one
namespace to another one.



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
