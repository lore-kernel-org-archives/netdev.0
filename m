From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: Re: [PATCH v9 00/20] simplify crypto wait for async op
Date: Wed, 18 Oct 2017 08:44:31 +0300
Message-ID: <CAOtvUMfOSo4KSBX3UKtYj1sgmReAdhmmi1MhZGq0aFk-vptahg@mail.gmail.com>
References: <1508059209-25529-1-git-send-email-gilad@benyossef.com> <20171017140629.GO20805@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        Jonathan Corbet <corbet@lwn.net>,
        David Howells <dhowells@redhat.com>,
        Tom Lendacky <thomas.lendacky@amd.com>,
        Gary Hook <gary.hook@amd.com>,
        Boris Brezillon <boris.brezillon@free-electrons.com>,
        Arnaud Ebalard <arno@natisbad.org>,
        Matthias Brugger <matthias.bgg@gmail.com>,
        Alasdair Kergon <agk@redhat.com>,
        Mike Snitzer <snitzer@redhat.com>,
        device-mapper development <dm-devel@redhat.com>,
        Steve French <sfrench@samba.org>,
        "Theodore Y. Ts'o" <tytso@mit.edu>,
        Jaegeuk Kim <jaegeuk@kernel.org>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Mimi Zohar <zohar@linux.vnet.ibm.com>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20171017140629.GO20805@n2100.armlinux.org.uk>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 17, 2017 at 5:06 PM, Russell King - ARM Linux
<linux@armlinux.org.uk> wrote:
> On Sun, Oct 15, 2017 at 10:19:45AM +0100, Gilad Ben-Yossef wrote:
>> Many users of kernel async. crypto services have a pattern of
>> starting an async. crypto op and than using a completion
>> to wait for it to end.
>>
>> This patch set simplifies this common use case in two ways:
>>
>> First, by separating the return codes of the case where a
>> request is queued to a backlog due to the provider being
>> busy (-EBUSY) from the case the request has failed due
>> to the provider being busy and backlogging is not enabled
>> (-EAGAIN).
>>
>> Next, this change is than built on to create a generic API
>> to wait for a async. crypto operation to complete.
>>
>> The end result is a smaller code base and an API that is
>> easier to use and more difficult to get wrong.
>>
>> The patch set was boot tested on x86_64 and arm64 which
>> at the very least tests the crypto users via testmgr and
>> tcrypt but I do note that I do not have access to some
>> of the HW whose drivers are modified nor do I claim I was
>> able to test all of the corner cases.
>>
>> The patch set is based upon linux-next release tagged
>> next-20171013.
>
> Has there been any performance impact analysis of these changes?  I
> ended up with patches for one of the crypto drivers which converted
> its interrupt handling to threaded interrupts being reverted because
> it caused a performance degredation.
>
> Moving code to latest APIs to simplify it is not always beneficial.

I agree with the sentiment but I believe this one is justified.

This patch set basically does 3 things:

1.  Replace one immediate value (-EBUSY) by another (-EAGAIN). Mostly it's just
s/EBUSY/EAGAIN/g. In very few places this resulted very trivial code
changes. I don't
foresee this having any effect on performance.

2. Removal of some conditions and/or conditional jumps that were used to discern
between two different cases which are now now easily tested for by the
different return
value. If at all, this will be an increase in performance, although I
don't expect it to be
noticeable.

3. Replacing a whole bunch of open coded code and data structures
which were pretty much
cut and pasted from the Documentation and therefore identical, with a
single copy thereof.

Every place that I found that deviated slightly from the identical
pattern, it turned out to be
a bug of some sorts and patches for those were sent and accepted already.

So, we might be losing a few inline optimization opportunities but
we're gaining better
cache utilization. Again, I don't expect any of this to have a
noticeable effect to either
direction.

I did run the changed code as best I could and did not notice any
performance changes and
none of the testers and maintainers that ACKed mentioned any.

Having said that, it's a big change that touches many places,
sub-systems and drivers. I do
not claim to have thoroughly tested for performance all the changes in
person. In some cases,
I don't even have access to the specialized hardware. I did get a
reasonable amount of review
and testers I believe - would always love to see more :-)

Many thanks,
Gilad




-- 
Gilad Ben-Yossef
Chief Coffee Drinker

"If you take a class in large-scale robotics, can you end up in a
situation where the homework eats your dog?"
 -- Jean-Baptiste Queru
