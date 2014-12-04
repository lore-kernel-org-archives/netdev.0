From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: Where exactly will arch_fast_hash be used
Date: Thu, 04 Dec 2014 14:14:24 +0100
Message-ID: <54805E30.4090109@redhat.com>
References: <20141204081147.GA19030@gondor.apana.org.au> <1417696468.5386.23.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Thomas Graf <tgraf@suug.ch>,
	"David S. Miller" <davem@davemloft.net>,
	"Theodore Ts'o" <tytso@mit.edu>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	fusco@ntop.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417696468.5386.23.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/04/2014 01:34 PM, Hannes Frederic Sowa wrote:
> On Do, 2014-12-04 at 16:11 +0800, Herbert Xu wrote:
>> While working on rhashtable it came to me that this whole concept
>> of arch_fast_hash is flawed.  CRCs are linear functions so it's
>> fairly easy for an attacker to identify collisions or at least
>> eliminate a large amount of search space (e.g., controlling the
>> last bit of the hash result is almost trivial, even when you add
>> a random seed).
>>
>> So what exactly are we going to use arch_fast_hash for? Presumably
>> it's places where security is never goint to be an issue, right?

The original proposal [1] targeted ovs-only as a closed-door user in
order to speed up the worst case of calculating a hash over the extracted
flow key, that is, struct sw_flow_key (which nowadays consumes up to
7 cachelines on x86_64 ...).

   [1] http://thread.gmane.org/gmane.linux.network/293981/

>> Even if security wasn't an issue, straight CRC32 has really poor
>> lower-order bit distribution, which makes it a terrible choice for
>> a hash table that simply uses the lower-order bits.
>
> I wondered the same while trying to use arch_fast_hash in a lot more
> places (I did a new implementation in assembler I'll send later on, it
> is mostly optimized to deal with ovs flow keys).
>
> While the uniformity of crc32 does actually look good and IMHO this even
> holds for the lower bits of the hash, I totally agree on the linearity
> matters.
>
> The easiest way to make arch_fast_hash non-linear would be to build up
> on the crc32 instruction like e.g. the cityhash function family does and
> it seems not too hard to do that by combining two crc32c outputs of the
> original and cyclic shifted input data. I have doubts if this is faster
> than jhash in the end. There are proposals from Intel to do so, but they
> are patent encumbered. :/
>
> For most consumers in the networking stack, security and DoS resistence
> is an issue. OVS, for which this was designed at first does do rehashing
> from time to time, but still there is a possible DoS attack vector with
> this hashing algorithm.
