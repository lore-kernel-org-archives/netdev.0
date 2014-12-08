From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Where exactly will arch_fast_hash be used
Date: Mon, 08 Dec 2014 12:25:08 +0100
Message-ID: <1418037908.190744.200156353.5DD668E8@webmail.messagingengine.com>
References: <20141207213354.20910.qmail@ns.horizon.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, dborkman@redhat.com,
	herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, tgraf@suug.ch, tytso@mit.edu
To: George Spelvin <linux@horizon.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141207213354.20910.qmail@ns.horizon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Sun, Dec 7, 2014, at 22:33, George Spelvin wrote:
> On Sun, 2014-12-07 at 15:06 +0100, Hannes Frederic Sowa wrote:
> > In case of openvswitch it shows a performance improvment. The seed
> > parameter could be used as an initial biasing of the crc32 function, but
> > in case of openvswitch it is only set to 0.
> 
> NACK.
> 
> This is the Fatal Error in thinking that Herbert was warning about.
> The seed parameter doesn't affect CRC32 collisions *at all* if the inputs
> are the same size.
> 
> For fixed-size inputs, a non-zero seed is equivalent to XORing a
> constant into the output of the CRC computation.

Sorry for being unclear, I understood that and didn't bother patching
that '0' with a random seed exactly because of this.

> for *different* sized inputs, a non-zero seed detects zero-padding
> better than a zero one, but *which* non-zero value is also irrelevant;
> all-ones is the traditional choice because it's simplest in hardware.
> 
> 
> A CRC is inherently linear.  CRC(a^b) = CRC(a) ^ CRC(b).  This makes
> them easy to analyze mathematically and gives them a number of nice
> properties for detecting hardware corruption.
> 
> But that same simplicity makes it *ridiculously* easy to generate
> collisions if you try.

Yes, understood and I totally agree we shouldn't use crc32 hashing in a
lot of places where unsafe data is going to be hashed and inserted into
hash tables.

> One way of looking at a CRC is to say that each bit in the input
> has a CRC.  The CRC of a message string is just the XOR of the CRCs
> of the individual bits that are set in the message.
> 
> Now, a CRC polynomial is chosen so that all of the bits of a
> message have different CRCs.  Obviously, there's a limit: when the
> message is 2^n bits long, it's not possible for all the bits to
> have different, non-zero n-bit CRCs.
> 
> But a CRC is a really efficient way of assigning different bit patterns
> to different input bits up to that limit.
> 
> (Something like CRC32c is also chosen so that, for messages up to a
> reasonable length, no 3-bit, 4-bit, etc. combinations have CRCs that
> XOR to zero.)
> 
> 
> But, and this might be what Herbert was trying to say and I was
> misunderstanding, if you then *truncate* that CRC, the CRCs of the
> message bits lose that uniqueness guarantee.  They're just pseudorandom
> numbers, and a CRC loses its special collision-resistance properties.
> 
> It's just an ordinary random hash, and thanks to the birthday paradox,
> you're likely to find two bits whose CRCs agree in any particular 8 bits
> within roughly sqrt(2*256) or 22 bits.
> 
> Here are a few such collisions for the least significant 8 bits of
> CRC32c:
> 
> Msg1    CRC32c          Msg2    CRC32c          Match
> 1<<11   3fc5f181        1<<30   bf672381        81
> 1<<12   9d14c3b8        1<<31   dd45aab8        b8
> 1<<5    c79a971f        1<<44   6006181f        1f
> 1<<15   13a29877        1<<45   b2f53777        77
> 
> There's nothing special about the lsbits of the CRC.
> Within 64 bits, the most significant 8 bits have it worse:
> 
> 1<<5    c79a971f        1<<17   c76580d9        c7
> 1<<6    e13b70f7        1<<18   e144fb14        e1
> 1<<19   70a27d8a        1<<38   7022df58        70
> 1<<20   38513ec5        1<<39   38116fac        38
> 1<<13   4e8a61dc        1<<52   4e2dfd53        4e
> 1<<23   a541927e        1<<53   a5e0c5d1        a5
> 
> 
> Now, I'd like to stress that this collision rate is no worse than any
> *other* hash function.  A truncated CRC loses its special resistance to
> the birthday paradox (you'd have been much smarter to use 8-bit CRC),
> but it doesn't become especially bad.  A truncated SHA-1 will have
> coillisions just as often.
> 
> The concern with a CRC is that, once you've found one collision, you've
> found a huge number of them.  Just XOR the bit pattern of your choice
> into both of the colliding messages, and you have a new collision.

Ack.

> For another example, if you consider the CRC32c of all possible 1-byte
> messages *and then take only the low byte*, there are only 128 possible
> values.
> 
> It turns out that the byte 0x5d has a CRC32c of 0xee0d9600.  This ends
> in 00, so if I XOR 0x5d into anything, the low 8 bits of the CRC
> don't change.
> 
> Likewise, the message "23 00" has a CRC32c of 0x00ee0d96.  So you can
> XOR 0x23 into the second-last byte of anything, and the high 8 bits of
> the CRC don't change.

A very interesting read, thanks for your mail!

Bye,
Hannes
