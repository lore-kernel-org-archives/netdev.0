From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH v7 3/6] random: use SipHash in place of MD5
Date: Wed, 21 Dec 2016 18:09:53 -0800
Message-ID: <CALCETrWhoCB0iriLTAE3SHEdQyX=Z4n5JD2rJZ6n8Tx6sQX8jw@mail.gmail.com>
References: <20161216030328.11602-1-Jason@zx2c4.com> <20161221230216.25341-1-Jason@zx2c4.com>
 <20161221230216.25341-4-Jason@zx2c4.com> <CALCETrVttVoZMvCYZcrAqM1c=YQP_nCfdfO1MsrSHjvjTFxH+A@mail.gmail.com>
 <17bd0c70-d2c1-165b-f5b2-252dfca404e8@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Netdev <netdev@vger.kernel.org>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        David Laight <David.Laight@aculab.com>,
        Ted Tso <tytso@mit.edu>, Eric Dumazet <edumazet@google.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Eric Biggers <ebiggers3@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Andi Kleen <ak@linux.intel.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f180.google.com ([209.85.217.180]:33565 "EHLO
        mail-ua0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761439AbcLVCKP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 21:10:15 -0500
Received: by mail-ua0-f180.google.com with SMTP id y22so36900304uay.0
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2016 18:10:14 -0800 (PST)
In-Reply-To: <17bd0c70-d2c1-165b-f5b2-252dfca404e8@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 21, 2016 at 6:07 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On 22.12.2016 00:42, Andy Lutomirski wrote:
>> On Wed, Dec 21, 2016 at 3:02 PM, Jason A. Donenfeld <Jason@zx2c4.com> wrote:
>>>  unsigned int get_random_int(void)
>>>  {
>>> -       __u32 *hash;
>>> -       unsigned int ret;
>>> -
>>> -       if (arch_get_random_int(&ret))
>>> -               return ret;
>>> -
>>> -       hash = get_cpu_var(get_random_int_hash);
>>> -
>>> -       hash[0] += current->pid + jiffies + random_get_entropy();
>>> -       md5_transform(hash, random_int_secret);
>>> -       ret = hash[0];
>>> -       put_cpu_var(get_random_int_hash);
>>> -
>>> -       return ret;
>>> +       unsigned int arch_result;
>>> +       u64 result;
>>> +       struct random_int_secret *secret;
>>> +
>>> +       if (arch_get_random_int(&arch_result))
>>> +               return arch_result;
>>> +
>>> +       secret = get_random_int_secret();
>>> +       result = siphash_3u64(secret->chaining, jiffies,
>>> +                             (u64)random_get_entropy() + current->pid,
>>> +                             secret->secret);
>>> +       secret->chaining += result;
>>> +       put_cpu_var(secret);
>>> +       return result;
>>>  }
>>>  EXPORT_SYMBOL(get_random_int);
>>
>> Hmm.  I haven't tried to prove anything for real.  But here goes (in
>> the random oracle model):
>>
>> Suppose I'm an attacker and I don't know the secret or the chaining
>> value.  Then, regardless of what the entropy is, I can't predict the
>> numbers.
>>
>> Now suppose I do know the secret and the chaining value due to some
>> leak.  If I want to deduce prior outputs, I think I'm stuck: I'd need
>> to find a value "result" such that prev_chaining + result = chaining
>> and result = H(prev_chaining, ..., secret);.  I don't think this can
>> be done efficiently in the random oracle model regardless of what the
>> "..." is.
>>
>> But, if I know the secret and chaining value, I can predict the next
>> output assuming I can guess the entropy.  What's worse is that, even
>> if I can't guess the entropy, if I *observe* the next output then I
>> can calculate the next chaining value.
>>
>> So this is probably good enough, and making it better is hard.  Changing it to:
>>
>> u64 entropy = (u64)random_get_entropy() + current->pid;
>> result = siphash(..., entropy, ...);
>> secret->chaining += result + entropy;
>>
>> would reduce this problem by forcing an attacker to brute-force the
>> entropy on each iteration, which is probably an improvement.
>>
>> To fully fix it, something like "catastrophic reseeding" would be
>> needed, but that's hard to get right.
>
> I wonder if Ted's proposal was analyzed further in terms of performance
> if get_random_int should provide cprng alike properties?
>
> For reference: https://lkml.org/lkml/2016/12/14/351
>
> The proposal made sense to me and would completely solve the above
> mentioned problem on the cost of repeatedly reseeding from the crng.
>

Unless I've misunderstood it, Ted's proposal causes get_random_int()
to return bytes straight from urandom (effectively), which should make
it very strong.  And if urandom is competitively fast now, I don't see
the problem.  ChaCha20 is designed for speed, after all.
