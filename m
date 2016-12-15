From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v2 1/4] siphash: add cryptographically secure hashtable function
Date: Thu, 15 Dec 2016 19:50:36 +0100
Message-ID: <CAHmME9pTLFu3-4n6m_OMj5jVWGE-+yC-4CnkynD--H4Nt8_cpA@mail.gmail.com>
References: <20161214035927.30004-1-Jason@zx2c4.com> <CAHmME9q9ffdtWRbzyMO1ktTdtEFdfumTfojTTNLXFhoa+R+MWQ@mail.gmail.com>
 <8ea3fdff-23c4-b81d-2588-44549bd2d8c1@stressinduktion.org>
 <063D6719AE5E284EB5DD2968C1650D6DB02401ED@AcuExch.aculab.com>
 <707472e1-b385-836d-c4c6-791c1dcc0776@stressinduktion.org>
 <063D6719AE5E284EB5DD2968C1650D6DB02402C0@AcuExch.aculab.com>
 <0f3c3694-c00b-aae2-5b08-25bc64bf6372@stressinduktion.org>
 <063D6719AE5E284EB5DD2968C1650D6DB0240437@AcuExch.aculab.com>
 <f6813084-6f46-0b22-e9c3-97b2e266f8f6@stressinduktion.org>
 <063D6719AE5E284EB5DD2968C1650D6DB0240529@AcuExch.aculab.com> <924ef794-eae0-2a6b-508b-069718339edc@stressinduktion.org>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
	Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>, LKML <linux-kernel@vger.kernel.org>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, "Daniel J . Bernstein" <djb@cr.yp.to>,
	Linus Torvalds <torvalds@linux-foundation.org>, Eric Biggers <ebiggers3@gmail.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>, David Laight <David.Laight@aculab.com>
Return-path: <kernel-hardening-return-5588-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <924ef794-eae0-2a6b-508b-069718339edc@stressinduktion.org>
List-Id: netdev.vger.kernel.org

Hi David & Hannes,

This conversation is veering off course. I think this doesn't really
matter at all. Gcc converts u64 into essentially a pair of u32 on
32-bit platforms, so the alignment requirements for 32-bit is at a
maximum 32 bits. On 64-bit platforms the alignment requirements are
related at a maximum to the biggest register size, so 64-bit
alignment. For this reason, no matter the behavior of __aligned(8),
we're okay. Likewise, even without __aligned(8), if gcc aligns structs
by their biggest member, then we get 4 byte alignment on 32-bit and 8
byte alignment on 64-bit, which is fine. There's no 32-bit platform
that will trap on a 64-bit unaligned access because there's no such
thing as a 64-bit access there. In short, we're fine.

(The reason in6_addr aligns itself to 4 bytes on 64-bit platforms is
that it's defined as being u32 blah[4]. If we added a u64 blah[2],
we'd get 8 byte alignment, but that's not in the header. Feel free to
start a new thread about this issue if you feel this ought to be added
for whatever reason.)

One optimization that's been suggested on this list is that instead of
u8 key[16] and requiring the alignment attribute, I should just use
u64 key[2]. This seems reasonable to me, and it will also save the
endian conversion call. These keys generally aren't transmitted over a
network, so I don't think a byte-wise encoding is particularly
important.

The other suggestion I've seen is that I make the functions take a
const void * instead of a const u8 * for the data, in order to save
ugly casts. I'll do this too.

Meanwhile Linus has condemned our 4dwords/2qwords naming, and I'll
need to think of something different. The best I can think of right
now is siphash_4_u32/siphash_2_u64, but I don't find it especially
pretty. Open to suggestions.

Regards,
Jason
