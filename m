From: "Indan Zupancic" <indan@nul.nu>
Subject: Re: [PATCH v14 01/13] sk_run_filter: add BPF_S_ANC_SECCOMP_LD_W
Date: Wed, 14 Mar 2012 08:59:04 +0100
Message-ID: <3f56b0860272f4ca8925c0a249a30539.squirrel@webmail.greenhost.nl>
References: <1331587715-26069-1-git-send-email-wad@chromium.org>
    <0c55cb258e0b5bbd615923ee2a9f06b9.squirrel@webmail.greenhost.nl>
    <1331658828.4449.16.camel@edumazet-glaptop>
    <3e4fc1efb5d7dbe0dd966e3192e84645.squirrel@webmail.greenhost.nl>
    <1331704535.2456.37.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Will Drewry" <wad@chromium.org>, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
	kernel-hardening@lists.openwall.com, netdev@vger.kernel.org,
	x86@kernel.org, arnd@arndb.de, davem@davemloft.net, hpa@zytor.com,
	mingo@redhat.com, oleg@redhat.com, peterz@infradead.org,
	rdunlap@xenotime.net, mcgrathr@chromium.org, tglx@linutronix.de,
	luto@mit.edu, eparis@redhat.com, serge.hallyn@canonical.com,
	djm@mindrot.org, scarybeasts@gmail.com, pmoore@redhat.com,
	akpm@linux-foundation.org, corbet@lwn.net, markus@chromium.org,
	coreyb@linux.vnet.ibm.com, keescook@chromium.org
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <1331704535.2456.37.camel@edumazet-laptop>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, March 14, 2012 06:55, Eric Dumazet wrote:
> Le mercredi 14 mars 2012 =C3=A0 06:12 +0100, Indan Zupancic a =C3=A9c=
rit :
>
>> Problem is that 'old_size' can be up to 32kB in size and it would be=
 nice
>> if that memory could be released. If it isn't, then using JIT increa=
ses
>> memory usage, while also not accounting it to the socket.
>>
>
> It is accounted for, since jit size is in relation with standard filt=
er
> size. Check sock_kmalloc()
>
> Fact we can have a litle underestimation was already the case without
> jit, since kmalloc() does a roundup to next power of two.

OK.

> I dont think this discussion has anything to do with SECCOMP anyway.

Certainly true.

> These accounting dont need to be 100% precise, we only want a limit t=
o
> prevent rogue users from using all kernel memory.

=46air enough.

The only remaining question is, is it worth the extra code to release
up to 32kB of unused memory? It seems a waste to not free it, but if
people think it's not worth it then let's just leave it around.

>> >
>> > If it did, this kind of 'optimization' can actually be not good, b=
ecause
>> > sizeof(*fp) is small enough (less than half cache line size) to tr=
igger
>> > a possible false sharing issue. (other part of the cache line coul=
d be
>> > used to hold a often dirtied object)
>>
>> It could avoid this by allocating at least a cache size. But this is=
 a
>> problem for all small kmalloc's, isn't it?
>
> Its a problem that was already met on several critical paths :
>
> # find net|xargs grep -n L1_CACHE_BYTES
> net/core/dev_addr_lists.c:51:	if (alloc_size < L1_CACHE_BYTES)
> net/core/dev_addr_lists.c:52:		alloc_size =3D L1_CACHE_BYTES;
> net/core/net-sysfs.c:586:	    RPS_MAP_SIZE(cpumask_weight(mask)), L1_=
CACHE_BYTES),
> net/core/net-sysfs.c:1111:	    XPS_DEV_MAPS_SIZE, L1_CACHE_BYTES), GF=
P_KERNEL);
> net/ipv6/ip6_fib.c:1612:	size =3D max_t(size_t, size, L1_CACHE_BYTES)=
;
> net/ipv4/fib_frontend.c:1049:	size =3D max_t(size_t, size, L1_CACHE_B=
YTES);

So using L1_CACHE_BYTES is the more common thing to do, I'll keep that =
in
mind for next time.

Thanks,

Indan
