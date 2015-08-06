From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: rtnl_mutex deadlock?
Date: Fri, 07 Aug 2015 00:39:47 +0200
Message-ID: <55C3E233.20502@iogearbox.net>
References: <CA+55aFwYhdHdLUbYYAc9GgmFuVXniwAESYHuzDWjdapPC0m1Xw@mail.gmail.com> <CAHA+R7N2fRz2zr-6MX9StqPLdNAWRiG55xidrC7reSRrVeQPcQ@mail.gmail.com> <20150805074330.GA2084@nanopsycho.orion> <CA+55aFw1856zEq88RfqoizjeVRR9Ut-ug+VWA+mKFOS77FYpSg@mail.gmail.com> <55C25CFB.2060103@iogearbox.net> <20150806003026.GA12785@gondor.apana.org.au> <55C3743F.1010900@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Jiri Pirko <jiri@resnulli.us>,
	Cong Wang <cwang@twopensource.com>,
	David Miller <davem@davemloft.net>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>, Scott Feldman <sfeldma@gmail.com>,
	Network Development <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35739 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751780AbbHFWjx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2015 18:39:53 -0400
In-Reply-To: <55C3743F.1010900@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/06/2015 04:50 PM, Daniel Borkmann wrote:
> On 08/06/2015 02:30 AM, Herbert Xu wrote:
>> On Wed, Aug 05, 2015 at 08:59:07PM +0200, Daniel Borkmann wrote:
>>>
>>> Here's a theory and patch below. Herbert, Thomas, does this make any
>>> sense to you resp. sound plausible? ;)
>>
>> It's certainly possible.  Whether it's plausible I'm not so sure.
>> The netlink hashtable is unlimited in size.  So it should always
>> be expanding, not rehashing.  The bug you found should only affect
>> rehashing.
>>
>>> I'm not quite sure what's best to return from here, i.e. whether we
>>> propagate -ENOMEM or instead retry over and over again hoping that the
>>> rehashing completed (and no new rehashing started in the mean time) ...../net/ipv4/af_inet.c:172:static
>>
>> Please use something other than ENOMEM as it is already heavily
>> used in this context.  Perhaps EOVERFLOW?
>
> Okay, I'll do that.
>
>> We should probably add a WARN_ON_ONCE in rhashtable_insert_rehash
>> since two concurrent rehashings indicates something is going
>> seriously wrong.
>
> So, if I didn't miss anything, it looks like the following could have
> happened: the worker thread, that is rht_deferred_worker(), itself could
> trigger the first rehashing, e.g. after shrinking or expanding (or also
> in case none of both happen).
>
> Then, in __rhashtable_insert_fast(), I could trigger an -EBUSY when I'm
> really unlucky and exceed the ht->elasticity limit of 16. I would then
> end up in rhashtable_insert_rehash() to find out there's already one
> ongoing and thus, I'm getting -EBUSY via __netlink_insert().
>
> Perhaps that is what could have happened? Seems rare though, but it was
> also only seen rarely so far ...

Experimenting a bit more, letting __netlink_insert() return -EBUSY so far,
I only managed when either artificially reducing ht->elasticity limit a bit
or biasing the hash function, that means, it would require some specific
knowledge at what slot we end up to overcome the elasticity limit and thus
trigger rehashing. Pretty unlikely though if you ask me. The other thing
I could observe, when I used the bind stress test from Thomas' repo and
reduced the amount of bind()'s, so that we very frequently fluctuate in the
ranges of 4 to 256 of the hashtable size, I could observe that we from time
to time enter rhashtable_insert_rehash() on insertions, but probably the
window was too small to trigger an error. I think in any case, remapping
seems okay.
