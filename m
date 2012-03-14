From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v14 01/13] sk_run_filter: add BPF_S_ANC_SECCOMP_LD_W
Date: Tue, 13 Mar 2012 22:55:35 -0700
Message-ID: <1331704535.2456.37.camel@edumazet-laptop>
References: <1331587715-26069-1-git-send-email-wad@chromium.org>
	 <0c55cb258e0b5bbd615923ee2a9f06b9.squirrel@webmail.greenhost.nl>
	 <1331658828.4449.16.camel@edumazet-glaptop>
	 <3e4fc1efb5d7dbe0dd966e3192e84645.squirrel@webmail.greenhost.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Will Drewry <wad@chromium.org>, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
	kernel-hardening@lists.openwall.com, netdev@vger.kernel.org,
	x86@kernel.org, arnd@arndb.de, davem@davemloft.net, hpa@zytor.com,
	mingo@redhat.com, oleg@redhat.com, peterz@infradead.org,
	rdunlap@xenotime.net, mcgrathr@chromium.org, tglx@linutronix.de,
	luto@mit.edu, eparis@redhat.com, serge.hallyn@canonical.com,
	djm@mindrot.org, scarybeasts@gmail.com, pmoore@redhat.com,
	akpm@linux-foundation.org, corbet@lwn.net, markus@chromium.org,
	coreyb@linux.vnet.ibm.com, keescook@chromium.org
To: Indan Zupancic <indan@nul.nu>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <3e4fc1efb5d7dbe0dd966e3192e84645.squirrel@webmail.greenhost.nl>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 14 mars 2012 =C3=A0 06:12 +0100, Indan Zupancic a =C3=A9cri=
t :

> Problem is that 'old_size' can be up to 32kB in size and it would be =
nice
> if that memory could be released. If it isn't, then using JIT increas=
es
> memory usage, while also not accounting it to the socket.
>=20

It is accounted for, since jit size is in relation with standard filter
size. Check sock_kmalloc()

=46act we can have a litle underestimation was already the case without
jit, since kmalloc() does a roundup to next power of two.

I dont think this discussion has anything to do with SECCOMP anyway.

These accounting dont need to be 100% precise, we only want a limit to
prevent rogue users from using all kernel memory.

> >
> > If it did, this kind of 'optimization' can actually be not good, be=
cause
> > sizeof(*fp) is small enough (less than half cache line size) to tri=
gger
> > a possible false sharing issue. (other part of the cache line could=
 be
> > used to hold a often dirtied object)
>=20
> It could avoid this by allocating at least a cache size. But this is =
a
> problem for all small kmalloc's, isn't it?

Its a problem that was already met on several critical paths :

# find net|xargs grep -n L1_CACHE_BYTES
net/core/dev_addr_lists.c:51:	if (alloc_size < L1_CACHE_BYTES)
net/core/dev_addr_lists.c:52:		alloc_size =3D L1_CACHE_BYTES;
net/core/net-sysfs.c:586:	    RPS_MAP_SIZE(cpumask_weight(mask)), L1_CA=
CHE_BYTES),
net/core/net-sysfs.c:1111:	    XPS_DEV_MAPS_SIZE, L1_CACHE_BYTES), GFP_=
KERNEL);
net/ipv6/ip6_fib.c:1612:	size =3D max_t(size_t, size, L1_CACHE_BYTES);
net/ipv4/fib_frontend.c:1049:	size =3D max_t(size_t, size, L1_CACHE_BYT=
ES);



