From: Lorenzo Bianconi <lorenzo.bianconi83@gmail.com>
Subject: Re: [GIT] Networking
Date: Sat, 5 Sep 2015 18:14:47 +0200
Message-ID: <CAA2SeNKkH2neVkDxaqD5L76AE077JQqTFBr7jGehgjzMGD-Knw@mail.gmail.com>
References: <20150902.223522.1792493140210966693.davem@davemloft.net>
	<CA+55aFx=xh4+vCNOgwXyfeV-t=6anXimqBxH_i71RjYy+Gy9-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Johannes Berg <johannes.berg@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:37238 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751353AbbIEQOs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Sep 2015 12:14:48 -0400
In-Reply-To: <CA+55aFx=xh4+vCNOgwXyfeV-t=6anXimqBxH_i71RjYy+Gy9-w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

> On Wed, Sep 2, 2015 at 10:35 PM, David Miller <davem@davemloft.net> wrote:
>>
>> Another merge window, another set of networking changes.  I've heard
>> rumblings that the lightweight tunnels infrastructure has been voted
>> networking change of the year.
>
> .. and others say that the most notable feature is the idiotic bugs
> that it introduces, and the compiler even complains about.
>
> Christ, people. Learn C, instead of just stringing random characters
> together until it compiles (with warnings).
>
> This:
>
>   static bool rate_control_cap_mask(struct ieee80211_sub_if_data *sdata,
>                                    struct ieee80211_supported_band *sband,
>                                    struct ieee80211_sta *sta, u32 *mask,
>                                    u8 mcs_mask[IEEE80211_HT_MCS_MASK_LEN])
>
> is horribly broken to begin with, because array arguments in C don't
> actually exist. Sadly, compilers accept it for various bad historical
> reasons, and silently turn it into just a pointer argument. There are
> arguments for them, but they are from weak minds.
>
> But happily gcc has a really really valid warning (kudos - I often end
> up ragging on the bad warnings gcc has, but this one is a keeper),
> because a few lines down the mistake then turns into pure and utter
> garbage.
>
> It's garbage that was basically encouraged by the first mistake
> (thinking that C allows array arguments), namely:
>
>                   for (i = 0; i < sizeof(mcs_mask); i++)
>

I moved rate_control_apply_mask() logic in rate_control_cap_mask() in
order to be applied in multiple code points (i.e.
 rate_control_apply_mask_ratetbl()). Since I was using gcc version
4.9.2, the warning did not show up. Sorry for that bug.

> the "sizeof(mcs_mask)" is _shit_. Since array arguments don't actually
> exist in C, it is the size of the pointer, not the array. The first
> mistake makes the bug look like reasonable code. Although I'd argue
> that the code would actually be bad regardless, since "sizeof" is the
> size in bytes, and the code actually wants the number of entries (and
> we do have ARRAY_SIZE() for that).
>
> Sure, in this case the entries are just one byte each, so it would
> have *worked* had it not been for the array argument issue, but it's
> misleading and the code is just fundamentally buggy and nonsensical in
> two entirely different ways that fed on each other.
>
> That line should read
>
>                   for (i = 0; i < IEEE80211_HT_MCS_MASK_LEN; i++)
>
> and the argument should just have been declared as the pointer it actually is.
>
> A later patch then added onto the pile of manure by adding *another*
> broken array argument, but at least that one then used the proper loop
> for traversal of that array.
>
> The fact that I notice this bug from a very basic "let's just compile
> each pull request and make sure it isn't complete crap" is sad.
>
> Now, it *looks* like the code was just moved, and the "sizeof()" was
> initially correct (because it was a size of an actual array). Well, it
> was "correct" in the sense that it generated the right code, even if
> the whole confusion between "number of entries" and "size in bytes"
> was still there. Then it got moved and turned from "confused but
> happens to generate correct code" into "buggy pile of bovine manure".
> See commit 90c66bd2232a ("mac80211: remove ieee80211_tx_rate
> dependency in rate mask code").
>
> So I can see how this bug happened, and I am only slightly upset with
> Lorenzo who is the author of that commit.
>
> What I can't see is why the code has existed in at least two
> maintainer trees (Johannes' and David's) for a couple of weeks, and
> nobody cared about the new compiler warnings? And it was sent to me
> despite that new warning?
>
> I realy want people to take a really hard look at functions that use
> arrays as arguments. It really is very misleading, even if it can look
> "prettier", and some people will argue that it's "documentation" about
> how the pointer is a particular size. But it's neither. It's basically
> just lying about what is going on, and the only thing it documents is
> "I don't know how to C". Misleading documentation isn't documentation,
> it's a mistake.
>
> I see it in that file for at least the functions rate_idx_match_mask()
> and rate_control_cap_mask(). I tried - and failed - to come up with a
> reasonable grep pattern to try to see how common it is, and I'm too
> lazy to add some sparse check for it.
>
> Please people. When I see these kinds of obviously bogus code
> problems, that just makes me very upset. Because it makes me worry
> about all the non-obvious stuff that I miss.  Sadly, this time I had
> pushed out the merge early (because I wanted to test the wireless
> changes on my laptop), so now the bug is out there.
>
> I'm not sure what the practical *impact* of the bug is. Yes, it only
> traverses four or eight rate entries (depending on 32-bit or
> 64-bitness of the kernel) out of the ten that it should. But maybe in
> practice one of the first entries are always good enough matches. So
> maybe _testing_ doesn't actually show this bug, but I sure wish people
> just took compiler warnings more seriously (and were a lot more
> careful about moving things to functions, and never ever used the
> "function argument is an array" model).
>
>                Linus

Best regards,
Lorenzo

-- 
UNIX is Sexy: who | grep -i blonde | talk; cd ~; wine; talk; touch;
unzip; touch; strip; gasp; finger; gasp; mount; fsck; more; yes; gasp;
umount; make clean; sleep
