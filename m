From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] dcache: better name hash function
Date: Tue, 27 Oct 2009 10:32:44 -0700 (PDT)
Message-ID: <alpine.LFD.2.01.0910271017170.31845@localhost.localdomain>
References: <19864844.24581256620784317.JavaMail.root@tahiti.vyatta.com> <4AE68E23.20205@gmail.com> <4AE69829.9070207@gmail.com> <4AE6A16F.4020002@gmail.com> <20091027100736.5303f1ab@nehalam>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Octavian Purdila <opurdila@ixiacom.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Al Viro <viro@zeniv.linux.org.uk>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756310AbZJ0Rcq@vger.kernel.org>
In-Reply-To: <20091027100736.5303f1ab@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Tue, 27 Oct 2009, Stephen Hemminger wrote:
> 
> Rather than wasting space, or doing expensive, modulus; just folding
> the higher bits back with XOR redistributes the bits better.

Please don't make up any new hash functions without having a better input 
set than the one you seem to use.

The 'fnv' function I can believe in, because the whole "multiply by big 
prime number" thing to spread out the bits is a very traditional model. 
But making up a new hash function based on essentially consecutive names 
is absolutely the wrong thing to do. You need a much better corpus of path 
component names for testing.

> The following seems to give best results (combination of 16bit trick
> and string17).

.. and these kinds of games are likely to work badly on some 
architectures. Don't use 16-bit values, and don't use 'get_unaligned()'. 
Both tend to work fine on x86, but likely suck on some other 
architectures.

Also remember that the critical hash function needs to check for '/' and 
'\0' while at it, which is one reason why it does things byte-at-a-time. 
If you try to be smart, you'd need to be smart about the end condition 
too.

The loop to optimize is _not_ based on 'name+len', it is this code:

                this.name = name;
                c = *(const unsigned char *)name;

                hash = init_name_hash();
                do {
                        name++;
                        hash = partial_name_hash(c, hash);
                        c = *(const unsigned char *)name;
                } while (c && (c != '/'));
                this.len = name - (const char *) this.name;
                this.hash = end_name_hash(hash);

(which depends on us having already removed all slashed at the head, and 
knowing that the string is not zero-sized)

So doing things multiple bytes at a time is certainly still possible, but 
you would always have to find the slashes/NUL's in there first. Doing that 
efficiently and portably is not trivial - especially since a lot of 
critical path components are short.

(Remember: there may be just a few 'bin' directory names, but if you do 
performance analysis, 'bin' as a path component is probably hashed a lot 
more than 'five_slutty_bimbos_and_a_donkey.jpg'. So the relative weighting 
of importance of the filename should probably include the frequency it 
shows up in pathname lookup)

		Linus
