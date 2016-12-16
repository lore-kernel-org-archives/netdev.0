From: "George Spelvin" <linux@sciencehorizons.net>
Subject: Re: [PATCH v5 1/4] siphash: add cryptographically secure PRF
Date: 16 Dec 2016 16:25:28 -0500
Message-ID: <20161216212528.26003.qmail@ns.sciencehorizons.net>
References: <CAHmME9q0LaxQ3uinzWyD1mDCpyeLw_2TEAN33T6dDrTKCuHs7g@mail.gmail.com>
Cc: ak@linux.intel.com, davem@davemloft.net, David.Laight@aculab.com,
        djb@cr.yp.to, ebiggers3@gmail.com, hannes@stressinduktion.org,
        jeanphilippe.aumasson@gmail.com,
        kernel-hardening@lists.openwall.com, linux-crypto@vger.kernel.org,
        linux-kernel@vger.kernel.org, luto@amacapital.net,
        netdev@vger.kernel.org, tom@herbertland.com,
        torvalds@linux-foundation.org, tytso@mit.edu,
        vegard.nossum@gmail.com
To: Jason@zx2c4.com, linux@sciencehorizons.net
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <CAHmME9q0LaxQ3uinzWyD1mDCpyeLw_2TEAN33T6dDrTKCuHs7g@mail.gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jason A. Donenfeld wrote:
> I saw that jiffies addition in there and was wondering what it was all
> about. It's currently added _after_ the siphash input, not before, to
> keep with how the old algorithm worked. I'm not sure if this is
> correct or if there's something wrong with that, as I haven't studied
> how it works. If that jiffies should be part of the siphash input and
> not added to the result, please tell me. Otherwise I'll keep things
> how they are to avoid breaking something that seems to be working.

Oh, geez, I didn't realize you didn't understand this code.

Full details at
https://en.wikipedia.org/wiki/TCP_sequence_prediction_attack

But yes, the sequence number is supposed to be (random base) + (timestamp).
In the old days before Canter & Siegel when the internet was a nice place,
people just used a counter that started at boot time.

But then someone observed that I can start a connection to host X,
see the sequence number it gives back to me, and thereby learn the
seauence number it's using on its connections to host Y.

And I can use that to inject forged data into an X-to-Y connection,
without ever seeing a single byte of the traffic!  (If I *can* observe
the traffic, of course, none of this makes the slightest difference.)

So the random base was made a keyed hash of the endpoint identifiers.
(Practically only the hosts matter, but generally the ports are thrown
in for good measure.)  That way, the ISN that host X sends to me
tells me nothing about the ISN it's using to talk to host Y.  Now the
only way to inject forged data into the X-to-Y connection is to
send 2^32 bytes, which is a little less practical.
