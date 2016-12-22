From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Re: [PATCH v7 3/6] random: use SipHash in
 place of MD5
Date: Thu, 22 Dec 2016 13:47:20 +0100
Message-ID: <1482410840.2472.2.camel@stressinduktion.org>
References: <20161216030328.11602-1-Jason@zx2c4.com>
	 <20161221230216.25341-1-Jason@zx2c4.com>
	 <20161221230216.25341-4-Jason@zx2c4.com>
	 <CALCETrVttVoZMvCYZcrAqM1c=YQP_nCfdfO1MsrSHjvjTFxH+A@mail.gmail.com>
	 <17bd0c70-d2c1-165b-f5b2-252dfca404e8@stressinduktion.org>
	 <CAHmME9phg=GuhEUaMxxv_=RexffPDqrOEhmaKffy_ZSt7bfC7g@mail.gmail.com>
	 <20161222054125.lzxhd6ctovm3wk4p@thunk.org>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andy Lutomirski <luto@amacapital.net>, Netdev <netdev@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>, Linux Crypto Mailing List
 <linux-crypto@vger.kernel.org>, David Laight <David.Laight@aculab.com>,
 Eric Dumazet <edumazet@google.com>, Linus Torvalds
 <torvalds@linux-foundation.org>, Eric Biggers <ebiggers3@gmail.com>, Tom
 Herbert <tom@herbertland.com>, Andi Kleen <ak@linux.intel.com>, "David S.
 Miller" <davem@davemloft.net>, Jean-Philippe Aumasson
 <jeanphilippe.aumasson@gmail.com>
To: Theodore Ts'o <tytso@mit.edu>, kernel-hardening@lists.openwall.com
Return-path: <kernel-hardening-return-5776-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20161222054125.lzxhd6ctovm3wk4p@thunk.org>
List-Id: netdev.vger.kernel.org

Hi Ted,

On Thu, 2016-12-22 at 00:41 -0500, Theodore Ts'o wrote:
> On Thu, Dec 22, 2016 at 03:49:39AM +0100, Jason A. Donenfeld wrote:
> > 
> > Funny -- while you guys were sending this back & forth, I was writing
> > my reply to Andy which essentially arrives at the same conclusion.
> > Given that we're all arriving to the same thing, and that Ted shot in
> > this direction long before we all did, I'm leaning toward abandoning
> > SipHash for the de-MD5-ification of get_random_int/long, and working
> > on polishing Ted's idea into something shiny for this patchset.
> 
> here are my numbers comparing siphash (using the first three patches
> of the v7 siphash patches) with my batched chacha20 implementation.
> The results are taken by running get_random_* 10000 times, and then
> dividing the numbers by 10000 to get the average number of cycles for
> the call.  I compiled 32-bit and 64-bit kernels, and ran the results
> using kvm:
> 
>                    siphash                        batched chacha20
>          get_random_int  get_random_long   get_random_int   get_random_long   
> 
> 32-bit    270                  278             114            146
> 64-bit     75                   75             106            186
> 
> > I did have two objections to this. The first was that my SipHash
> > construction is faster.
> 
> Well, it's faster on everything except 32-bit x86.  :-P
> 
> > The second, and the more
> > important one, was that batching entropy up like this means that 32
> > calls will be really fast, and then the 33rd will be slow, since it
> > has to do a whole ChaCha round, because get_random_bytes must be
> > called to refill the batch.
> 
> ... and this will take 2121 cycles on 64-bit x86, and 2315 cycles on a
> 32-bit x86.  Which on a 2.3 GHz processor, is just under a
> microsecond.  As far as being inconsistent on process startup, I very
> much doubt a microsecond is really going to be visible to the user.  :-)
> 
> The bottom line is that I think we're really "pixel peeping" at this
> point --- which is what obsessed digital photographers will do when
> debating the quality of a Canon vs Nikon DSLR by blowing up a photo by
> a thousand times, and then trying to claim that this is visible to the
> human eye.  Or people who obsessing over the frequency response curves
> of TH-X00 headphones with Mahogony vs Purpleheart wood, when it's
> likely that in a blind head-to-head comparison, most people wouldn't
> be able to tell the difference....
> 
> I think the main argument for using the batched getrandom approach is
> that it, I would argue, simpler than introducing siphash into the
> picture.  On 64-bit platforms it is faster and more consistent, so
> it's basically that versus complexity of having to adding siphash to
> the things that people have to analyze when considering random number
> security on Linux.   But it's a close call either way, I think.

following up on what appears to be a random subject: ;)

IIRC, ext4 code by default still uses half_md4 for hashing of filenames
in the htree. siphash seems to fit this use case pretty good.

xfs could also need an update, as they don't seed the directory hash
tables at all (but not sure if they are vulnerable). I should improve
[1] a bit.

[1] http://oss.sgi.com/cgi-bin/gitweb.cgi?p=xfs/cmds/xfstests.git;a=blo
b;f=src/dirhash_collide.c;h=55cec872d5061ac2ca0f56d1f11e6bf349d5bb97;hb
=HEAD

Bye,
Hannes
