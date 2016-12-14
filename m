From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 1/3] siphash: add cryptographically secure hashtable
 function
Date: Wed, 14 Dec 2016 09:56:29 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB023F4ED@AcuExch.aculab.com>
References: <20161214001656.19388-1-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
        "Daniel J . Bernstein" <djb@cr.yp.to>
To: "'Jason A. Donenfeld'" <Jason@zx2c4.com>,
        Netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        LKML <linux-kernel@vger.kernel.org>,
        George Spelvin <linux@horizon.com>,
        Scott Bauer <sbauer@eng.utah.edu>,
        "Andi Kleen" <ak@linux.intel.com>,
        Andy Lutomirski <luto@amacapital.net>,
        Greg KH <gregkh@linuxfoundation.org>,
        Eric Biggers <ebiggers3@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161214001656.19388-1-Jason@zx2c4.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason A. Donenfeld
> Sent: 14 December 2016 00:17
> SipHash is a 64-bit keyed hash function that is actually a
> cryptographically secure PRF, like HMAC. Except SipHash is super fast,
> and is meant to be used as a hashtable keyed lookup function.
> 
> SipHash isn't just some new trendy hash function. It's been around for a
> while, and there really isn't anything that comes remotely close to
> being useful in the way SipHash is. With that said, why do we need this?
> 
> There are a variety of attacks known as "hashtable poisoning" in which an
> attacker forms some data such that the hash of that data will be the
> same, and then preceeds to fill up all entries of a hashbucket. This is
> a realistic and well-known denial-of-service vector.
> 
> Linux developers already seem to be aware that this is an issue, and
> various places that use hash tables in, say, a network context, use a
> non-cryptographically secure function (usually jhash) and then try to
> twiddle with the key on a time basis (or in many cases just do nothing
> and hope that nobody notices). While this is an admirable attempt at
> solving the problem, it doesn't actually fix it. SipHash fixes it.
> 
> (It fixes it in such a sound way that you could even build a stream
> cipher out of SipHash that would resist the modern cryptanalysis.)
> 
> There are a modicum of places in the kernel that are vulnerable to
> hashtable poisoning attacks, either via userspace vectors or network
> vectors, and there's not a reliable mechanism inside the kernel at the
> moment to fix it. The first step toward fixing these issues is actually
> getting a secure primitive into the kernel for developers to use. Then
> we can, bit by bit, port things over to it as deemed appropriate.
> 
> Dozens of languages are already using this internally for their hash
> tables. Some of the BSDs already use this in their kernels. SipHash is
> a widely known high-speed solution to a widely known problem, and it's
> time we catch-up.
...
> +u64 siphash24(const u8 *data, size_t len, const u8 key[SIPHASH24_KEY_LEN])
...
> +	u64 k0 = get_unaligned_le64(key);
> +	u64 k1 = get_unaligned_le64(key + sizeof(u64));
...
> +		m = get_unaligned_le64(data);

All these unaligned accesses are going to get expensive on architectures
like sparc64.

	David
