From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v5 3/4] secure_seq: use SipHash in place of MD5
Date: Fri, 16 Dec 2016 09:59:32 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB0240E66@AcuExch.aculab.com>
References: <20161215203003.31989-1-Jason@zx2c4.com>
 <20161215203003.31989-4-Jason@zx2c4.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable
To: "'Jason A. Donenfeld'" <Jason@zx2c4.com>, Netdev <netdev@vger.kernel.org>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
	LKML <linux-kernel@vger.kernel.org>, "linux-crypto@vger.kernel.org"
	<linux-crypto@vger.kernel.org>, Ted Tso <tytso@mit.edu>, Hannes Frederic Sowa
	<hannes@stressinduktion.org>, Linus Torvalds <torvalds@linux-foundation.org>,
	Eric Biggers <ebiggers3@gmail.com>, Tom Herbert <tom@herbertland.com>,
	"George Spelvin" <linux@sciencehorizons.net>, Vegard Nossum
	<vegard.nossum@gmail.com>, "ak@linux.intel.com" <ak@linux.intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>, "luto@amacapital.net"
	<luto@amacapital.net>
Return-path: <kernel-hardening-return-5629-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20161215203003.31989-4-Jason@zx2c4.com>
Content-Language: en-US
List-Id: netdev.vger.kernel.org

From: Jason A. Donenfeld
> Sent: 15 December 2016 20:30
> This gives a clear speed and security improvement. Siphash is both
> faster and is more solid crypto than the aging MD5.
>=20
> Rather than manually filling MD5 buffers, for IPv6, we simply create
> a layout by a simple anonymous struct, for which gcc generates
> rather efficient code. For IPv4, we pass the values directly to the
> short input convenience functions.
...
> diff --git a/net/core/secure_seq.c b/net/core/secure_seq.c
> index 88a8e429fc3e..c80583bf3213 100644
...
> +	const struct {
> +		struct in6_addr saddr;
> +		struct in6_addr daddr;
> +		__be16 sport;
> +		__be16 dport;
> +		u32 padding;
> +	} __aligned(SIPHASH_ALIGNMENT) combined =3D {
> +		.saddr =3D *(struct in6_addr *)saddr,
> +		.daddr =3D *(struct in6_addr *)daddr,
> +		.sport =3D sport,
> +		.dport =3D dport
> +	};

I think you should explicitly initialise the 'padding'.
It can do no harm and makes it obvious that it is necessary.

You are still putting over-aligned data on stack.
You only need to align it to the alignment of u64 (not the size of u64).
If an on-stack item has a stronger alignment requirement than the stack
the gcc has to generate two stack frames for the function.

If you assign to each field (instead of using initialisers) then you
can get the alignment by making the first member an anonymous union
of in6_addr and u64.

Oh - and wait a bit longer between revisions.

	David
