From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: sha512: make it work, undo percpu message schedule
Date: Fri, 13 Jan 2012 07:48:38 +0100
Message-ID: <1326437318.2617.17.camel@edumazet-laptop>
References: <20120111000040.GA3801@p183.telecom.by>
	 <20120111003611.GA12257@gondor.apana.org.au>
	 <20120113062256.GC12501@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	ken@codelabs.ch
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20120113062256.GC12501@secunet.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 13 janvier 2012 =C3=A0 07:22 +0100, Steffen Klassert a =C3=A9=
crit :
> On Wed, Jan 11, 2012 at 11:36:11AM +1100, Herbert Xu wrote:
> > On Wed, Jan 11, 2012 at 03:00:40AM +0300, Alexey Dobriyan wrote:
> > > commit f9e2bca6c22d75a289a349f869701214d63b5060
> > > aka "crypto: sha512 - Move message schedule W[80] to static percp=
u area"
> > > created global message schedule area.
> > >=20
> > > If sha512_update will ever be entered twice, hilarity ensures.
> >=20
> > Hmm, do you know why this happens? On the face of it this shouldn't
> > be possible as preemption is disabled.
> >=20
>=20
> I did not try to reproduce, but this looks like a race of the 'local =
out'
> and the receive packet path. On 'lokal out' bottom halves are enabled=
,
> so could be interrupted by the NET_RX_SOFTIRQ while doing a sha512_up=
date.
> The NET_RX_SOFTIRQ could invoke sha512_update too, that would corrupt=
 the
> hash value. My guess could be checked easily by disabling the bottom =
halves
> before the percpu value is fetched.

Good catch. It can be generalized to any interrupts (soft and hard)

Another solution is using two blocks, one used from interrupt context.

static DEFINE_PER_CPU(u64[80], msg_schedule);
static DEFINE_PER_CPU(u64[80], msg_schedule_irq);

(Like we do for SNMP mibs on !x86 arches)
