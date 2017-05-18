From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH] net/smc: mark as BROKEN due to remote memory exposure
Date: Thu, 18 May 2017 07:22:33 +0300
Message-ID: <20170518042233.GT3616@mtr-leonro.local>
References: <1494955244.3259.130.camel@redhat.com>
 <20170516.133644.850927380166261577.davem@davemloft.net>
 <1494957802.3259.131.camel@redhat.com>
 <20170516.145249.871010194359061722.davem@davemloft.net>
 <1494962899.3259.141.camel@redhat.com>
 <1495053467.2240.29.camel@redhat.com>
 <VI1PR0502MB3008604A216B388A440A8B53D1E70@VI1PR0502MB3008.eurprd05.prod.outlook.com>
 <4a873ea1-ba83-1506-9172-e955d5f9ae16@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="iTgyUaBDSpHJk5wi"
Cc: Parav Pandit <parav@mellanox.com>,
        David Miller <davem@davemloft.net>,
        "Bart.VanAssche@sandisk.com" <Bart.VanAssche@sandisk.com>,
        "hch@lst.de" <hch@lst.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "stable@vger.kernel.org" <stable@vger.kernel.org>,
        "ubraun@linux.vnet.ibm.com" <ubraun@linux.vnet.ibm.com>
To: Doug Ledford <dledford@redhat.com>,
        Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:46642 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752934AbdEREWi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 May 2017 00:22:38 -0400
Content-Disposition: inline
In-Reply-To: <4a873ea1-ba83-1506-9172-e955d5f9ae16@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--iTgyUaBDSpHJk5wi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, May 17, 2017 at 08:07:00PM -0400, Doug Ledford wrote:
> On 5/17/2017 6:37 PM, Parav Pandit wrote:
> > Hi Doug,
> >
>
> >> It would have been better with AF_INET/AF_INET6 and an option to enable
> >> SMC than AF_SMC.  The first implementation simply assumes AF_INET in
> >> the presence of AF_SMC.  When IPv6 support is added, some sort of
> >> guessing logic will have to be put in place to try and determine if an
> >> AF_SMC address is actually AF_INET or AF_INET6 since we won't have a
> >> guaranteed way of telling.  Apps can use struct sockaddr_storage as their
> >> normal element to stick the address into, and could rely on the kernel to
> >> interpret it properly based on the AF_INET/AF_INET6 differentiation, and
> >> this breaks that.  The RFC gives *some* thought to adding IPv6 in the
> >> future, but not a lot.  It may be that the answer is that in the future, IPv6
> >> support is enabled by making the IPv6 API be
> >> AF_INET6 + setsockopt(SMC) or the equivalent.  If that's the case, then I
> >> would suggest making the later API specifically call out AF_INET +
> >> setsockopt(SMC) be identical to AF_SMC.
> >>
> >
> > What are the shortcomings in my proposal [1] which I am reiterating below.
> > Bart also suggested to define new stream protocol for SMC similar to SCTP.
> >
> > (a) address family should be either AF_INET or AF_INET6
> > (b) socket() API to introduce new protocol as PROTO_SMC for in socket() system call.
> >
> > With this there is no additional setsockop() needed.
> >
> > With this - user space applications, do getaddrinfo() with hint as
> > hints.ai_family  = AF_INET;
> > hints.ai_socktype = SOCK_STREAM;
> >
> > getaddrinfo() returns back both the protocols TCP and SMC.
> > Famous database application such as Redis client iterates over all entries of getaddrinfo() and establishes connection to servers.
> >
> > There are few advantages of this interface.
> > 1. No change in any makefile of applications needed - unless user wants to specify explicitly that it wants to force SMC protocol.
> > 2. No need to do LD_LIBRARY_PRELOAD, (which won't work anyway because bind() connect() of SMC checks for AF_INET).
> > 3. No major changes to glibc to process AF_SMC differently
> > glibc references IPPROTO_TCP at 22 places. (compare to AF_INET at 140+ places).
> > A lot simpler test matrix for glibc for new protocol
> > 5. No need to recompile applications, as long as getaddrinfo returns all streaming protocols (TCP, SMC)
> > 6. for applications to make use of setsockopt() it needs another knob and hint from other places, which can be avoided because SMC TCP option negotiates with remote end
> >
> > And representing new protocol as new protocol for a given address family appears correct, compare to setting socket options.
> >
> > Tools like CRIU or similar tool might find a race conditions - when it queries socket option, SMC was not set, but later on SMC was set, and does incorrect handling.
> > Setting socket() with SMC protocol makes it easier to understand in this area as well.
>
> I have no problem with the proposal in itself, but as IBM released this
> publication and did their own implementation prior to submitting things
> upstream, and as there might exist in the field implementations, it
> depends on whether we wish to call those in the field implementations
> experimental and break them as we go to a final implementation of
> version 1, or if we consider version 1 baked.  I'm fine breaking it.
> After all, that's what happened with XRC back in the day and Mellanox
> learned a valuable lesson about upstream first.  I have no problem with
> IBM learning that same lesson IMO.  So, I find your proposal, including
> breaking the API of the version 1 implementation just taken into the
> kernel before it has had time to fully sit and gel, acceptable.

Doug,
I am amused that after your excellent summary you are not calling to
this v1 of protocol in its real word: BROKEN.

Current implementation and RFC are DOA (dead-on-arrival) and are not
usable for ALL RDMA key players (Mellanox, Intel, Chelsio, ...) and
ALL RDMA major users. It doesn't fit into existing infrastructure
(DB, HPC, glibc, e.t.c.) and doesn't even fulfill the expected from
cover letter (doesn't work with LD_PRELOAD_*).

The fact that IBM implemented it and used it doesn't mean that they
can't continue to leave it with out-of-tree solution for a little
bit more time till usable version will come.

>
> But this is where we kind of need a judgment from on high, and why I
> Cc:ed Linus on this thread.  Any input on this issue Linus?

It should be dropped/moved_to_staging as soon as possible, before
UAPI started to spread.

>
> > I have additional proposal for link groups, resource creation area. I will take that up after this discussion.
>
> Look forward to hearing it.
>
> > [1] https://patchwork.kernel.org/patch/9719375/
>
>
> --
> Doug Ledford <dledford@redhat.com>
>     GPG Key ID: B826A3330E572FDD
>     Key fingerprint = AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FDD
>




--iTgyUaBDSpHJk5wi
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlkdIYkACgkQ5GN7iDZy
WKfWWg/7BJAfsUsmkw7KHt65IZl6Sg1oQEhiMuZeTSF1OX48tSuiKK0O8gap+x84
9GIPAXN4ptzYj6+mfI/vr5JRGe71AX5tYHf7KkzOXusHhpqqLzz2zy3ScMhlal/W
QGPDgUnGAa6ZUra7dA34g9ovc09ZgJ2eZhgeH1dc+cr+Lh2wtFScWGlDFUbYT4hd
2yKA1YjpEhxSRtWAeSwICytCVgRSuyIb8+b4RESHTFo1e9uLTtiwzDU/6Gb9gJ8y
fmI6RxuHRSshF+Vba2ZO8p/H5EyhDGWtyEHkXWzDOAx0I7E/YIAvZyeUQ7AOvwVW
PR3lJoEV0XX+4dFRwAy82hoBLx8q8CwDbuk3dh0U7A4XNP44mkZHubAHgR0Zbdgz
n/WU6J7fHz8vs9G+xgce55C0T1lDZp+DXh7Ks50B/FC17EEKPZk689az4agEiejV
zX90v087pYBZqdrFlgzDoJT/p5P9vf9I0mDkLKXIcXE8wn8MMoaOo4HN11NF9/c/
IwwgcV2U3BOTgh1az8qWb7ulRXQDjniq9H/wXvmfppy1WKqzV5FNgVG38IePmjla
LdlmZGr6VRTgQ5JDDs8Tc2XA5N64lxCAgCP1jsT9r57j0LS7ktyGNbK9ODlzUHc+
s1/EJwZYvLVq+hzZ+g7xGwoYKxhnvP7xSVNeb1u3/L4wG5MoOB4=
=qAT2
-----END PGP SIGNATURE-----

--iTgyUaBDSpHJk5wi--
