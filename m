From: "George Spelvin" <linux@sciencehorizons.net>
Subject: Re: HalfSipHash Acceptable Usage
Date: 21 Dec 2016 20:13:35 -0500
Message-ID: <20161222011335.8023.qmail@ns.sciencehorizons.net>
References: <20161221222702.h2vboms776zpgpi4@thunk.org>
Cc: ak@linux.intel.com, davem@davemloft.net, David.Laight@aculab.com,
        djb@cr.yp.to, ebiggers3@gmail.com, eric.dumazet@gmail.com,
        hannes@stressinduktion.org, Jason@zx2c4.com,
        jeanphilippe.aumasson@gmail.com,
        kernel-hardening@lists.openwall.com, linux-crypto@vger.kernel.org,
        linux-kernel@vger.kernel.org, luto@amacapital.net,
        netdev@vger.kernel.org, tom@herbertland.com,
        torvalds@linux-foundation.org, vegard.nossum@gmail.com
To: linux@sciencehorizons.net, tytso@mit.edu
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20161221222702.h2vboms776zpgpi4@thunk.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As a separate message, to disentangle the threads, I'd like to
talk about get_random_long().

After some thinking, I still like the "state-preserving" construct
that's equivalent to the current MD5 code.  Yes, we could just do
siphash(current_cpu || per_cpu_counter, global_key), but it's nice to
preserve a bit more.

It requires library support from the SipHash code to return the full
SipHash state, but I hope that's a fair thing to ask for.

Here's my current straw man design for comment.  It's very similar to
the current MD5-based design, but feeds all the seed material in the
"correct" way, as opposed to Xring directly into the MD5 state.

* Each CPU has a (Half)SipHash state vector,
  "unsigned long get_random_int_hash[4]".  Unlike the current
  MD5 code, we take care to initialize it to an asymmetric state.

* There's a global 256-bit random_int_secret (which we could
  reseed periodically).

To generate a random number:
* If get_random_int_hash is all-zero, seed it with fresh a half-sized
  SipHash key and the appropriate XOR constants.
* Generate three words of random_get_entropy(), jiffies, and current->pid.
  (This is arbitary seed material, copied from the current code.)
* Crank through that with (Half)SipHash-1-0.
* Crank through the random_int_secret with (Half)SipHash-1-0.
* Return v1 ^ v3.

Here are the reasons:
* The first step is just paranoia, but SipHash's security promise depends
  on starting with an asymmetric state, we want unique per-CPU states,
  and it's a one-time cost.
* When the input words are themselves secret, there's no security
  advantage, and almost no speed advantage, to doing two rounds for one
  input word versus two words with one round each.  Thus, SipHash-1.
* The above is not exactly true, due to the before+after XOR pattern
  that SipHash uses, but I think it's true anyway.
* Likewise, there's no benefit to unkeyed finalization rounds over keyed
  ones.  That's why I just enlarged the global secret.
* The per-call seed material is hashed first on general principles,
  because that's the novel part that might have fresh entropy.
* To the extent the initial state is secret, the rounds processing the
  global secret are 4 finalization rounds for the initial state and
  the per-call entropy.
* The final word(s) of the global secret might be vulnerable to analysis,
  due to incomplete mixing, but since the global secret is always hashed
  in the same order, and larger that the desired security level, the
  initial words should be secure.
* By carrying forward the full internal state, we ensure that repeated
  calls return different results, and to the extent that the per-call
  seed material has entropy, it's preserved.
* The final return is all that's needed, since the last steps in the 
  SipRound are "v1 ^= v2" and "v3 ^= v0".  It's no security loss,
  and a very minor speedup.
* Also, this avoids directly "exposing" the final XOR with the last
  word of the global secret (which is made to v0).

If I'm allowed to use full SipHash, some shortcuts can be taken,
but I believe the above would be secure with HalfSipHash.

If additional performance is required, I'd consider shrinking the
global secret to 192 bits on 32-bit machines but I want more than
128 bits of ey material, and enough rounds to be equivalent to 4
finalization rounds.
