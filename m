From: "George Spelvin" <linux@sciencehorizons.net>
Subject: Re: George's crazy full state idea (Re: HalfSipHash Acceptable Usage)
Date: 22 Dec 2016 14:24:45 -0500
Message-ID: <20161222192445.963.qmail@ns.sciencehorizons.net>
References: <CALCETrUSM7KDNuVqh169241PNumJVOF5hrNQUq=k5Fnet6nSgA@mail.gmail.com>
Cc: ak@linux.intel.com, davem@davemloft.net, David.Laight@aculab.com,
        djb@cr.yp.to, ebiggers3@gmail.com, eric.dumazet@gmail.com,
        hannes@stressinduktion.org, Jason@zx2c4.com,
        jeanphilippe.aumasson@gmail.com,
        kernel-hardening@lists.openwall.com, linux-crypto@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux@sciencehorizons.net,
        netdev@vger.kernel.org, tom@herbertland.com,
        torvalds@linux-foundation.org, tytso@mit.edu,
        vegard.nossum@gmail.com
To: luto@amacapital.net, luto@kernel.org
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <CALCETrUSM7KDNuVqh169241PNumJVOF5hrNQUq=k5Fnet6nSgA@mail.gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Having slept on this, I like it less.  The problem is that a
> backtracking attacker doesn't just learn H(random seed || entropy_0 ||
> secret || ...) -- they learn the internal state of the hash function
> that generates that value.  This probably breaks any attempt to apply
> security properties of the hash function.  For example, the internal
> state could easily contain a whole bunch of prior outputs it in
> verbatim.

The problem is, anti-backtracing is in severe tension with your desire
to use unmodified SipHash.

First of all, I'd like to repeat that it isn't a design goal of the current
generator and isn't necessary.

The current generator just returns hash[0] from the MD5 state, then
leaves the state stored.  The fact that it conceals earlier outputs is
an accident of the Davies-Meyer structure of md5_transform.

It isn't necessary, because every secret generated is stored unencrypted
for as long as it's of value.  A few values are used for retransmit
backoffs and random MAC addresses.  Those are revealed to the world as
soon as they're used.

Most values are used for ASLR.  These address are of interest to an
attacker trying to mount a buffer-overflow attack, but that only lasts
as long as the process is running to receive buffers.  After the process
exits, knowledge of its layout is worthless.

And this is stored as long as it's running in kernel-accessible data,
so storing a *second* copy in less conveniently kernel-accessible data
(the RNG state) doesn't make the situation any worse.


In addition to the above, if you're assuming a state capture, then
since we have (for necessary efficieny reasons) a negligible about of
fresh entropy, an attacker has the secret key and can predict *future*
outputs very easily.

Given that information, an attacker doesn't need to learn the layout of
vulnerable server X.  If they have a buffer overflow, they can crash
the current instance and wait for a fresh image to be started (with a
known address space) to launch their attack at.


Kernel state capture attacks are a very unlikely attack, mostly because
it's a narrow target a hair's breadth away from the much more interesting
outright kernel compromise (attacker gains write access as well as read)
which renders all this fancy cryptanaysis moot.


Now, the main point:  it's not likely to be solvable.

The problem with unmodified SipHash is that is has only 64 bits of
output.  No mix-back mechanism can get around the fundamental problem
that that's too small to prevent a brute-force guessing attack.  You need
wider mix-back.  And getting more output from unmodified SipHash requires
more finalization rounds, which is expensive.

(Aside: 64 bits does have the advantage that it can't be brute-forced on
the attacked machine.  It must be exfiltrated to the attacker, and the
solution returned to the attack code.  But doing this is getting easier
all the time.)

Adding antibacktracking to SipHash is trivial: just add a Davies-Meyer
structure around its internal state.  Remember the internal state before
hashing in the entropy and secret, generate the output, then add the
previous and final states together for storage.

This is a standard textbook construction, very cheap, and doesn't touch
the compression function which is the target of analysis and attacks,
but it requires poking around in SipHash's internal state.  (And people
who read the textbooks without understanding them will get upset because
the textbooks all talk about using this construction with block ciphers,
and SipHash's compression function is not advertised as a block cipher.)

Alternative designs exist; you could extract additional output from
earlier rounds of SipHash, using the duplex sponge construction you
mentioned earlier.  That output would be used for mixback purposes *only*,
so wouldn't affect the security proof of the "primary" output.
But this is also getting creative with SipHash's internals.


Now, you could use a completely *different* cryptographic primitive
to enforce one-way-ness, and apply SipHash as a strong output transform,
but that doesn't feel like good design, and is probably more expensive.


Finally, your discomfort about an attacker learning the internal state...
if an attacker knows the key and the input, they can construct the
internal state.  Yes, we could discard the internal state and construct
a fresh one on the next call to get_random_int, but what are you going
to key it with?  What are you going to feed it?  What keeps *that*
internal state any more secret from an attacker than one that's explicitly
stored?

Keeping the internal state around is a cacheing optimization, that's all.

*If* you're assuming a state capture, the only thing secret from the
attacker is any fresh entropy collected between the time of capture
and the time of generation.  Due to mandatory efficiency requirements,
this is very small.  

I really think you're wishing for the impossible here.


A final note: although I'm disagreeing with you, thank you very much for 
the informed discussion.  Knowing that someone will read and think about
this message carefully has forced me to think it through carefully myself.

For example, clearly stating the concern over starting new processes
with predictable layout, and the limits on the fresh entropy supply,
has made me realize that there *is* a possible source: each exec()
is passed 128 bits from get_random_bytes in the AT_RANDOM element of
its auxv.  Since get_random_int() accesses "current" anyway, we could
store some seed material there rather than using "pid".  While this is
not fresh for each call to get_random_int, it *is* fresh for each new
address space whose layout is being randomized.
