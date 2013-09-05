From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] openvswitch: Fix alignment of struct sw_flow_key.
Date: Thu, 5 Sep 2013 21:20:16 +0200
Message-ID: <CAMuHMdVgd499_oAU0oodE8ie+h+Oc6M-dRcyC4tT6QDB=01GSg@mail.gmail.com>
References: <1378402887-17331-1-git-send-email-jesse@nicira.com>
	<20130905.141751.945639989861997124.davem@davemloft.net>
	<CAEP_g=8gcCtkv=no=HkVmS+NDWPM-Uu-SVyR+vb-YQ=7TWJsXA@mail.gmail.com>
	<20130905.144044.1053960608071929025.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesse Gross <jesse@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Andy Zhou <azhou@nicira.com>, fengguan.wu@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:63510 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752412Ab3IETUQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 15:20:16 -0400
Received: by mail-pa0-f44.google.com with SMTP id fz6so2323200pac.3
        for <netdev@vger.kernel.org>; Thu, 05 Sep 2013 12:20:16 -0700 (PDT)
In-Reply-To: <20130905.144044.1053960608071929025.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 5, 2013 at 8:40 PM, David Miller <davem@davemloft.net> wrote:
> When doing comparisons, this structure is being accessed as a byte
> array in 'long' sized chunks, not by its members. Therefore, the

Like ... an optimized memcmp() does? Which handles all (un)alignment
well?

>> To completely honest, I think the correct alignment should be
>> sizeof(long) because I know that 'long' is not always 8 bytes on all
>> architectures. However, you made the point before that this could
>> break the alignment of the 64-bit values on architectures where 'long'
>> is 32 bits wide, so 8 bytes is the generic solution.
>
> Look at net/core/flow.c:flow_key_compare().
>
> And then we annotate struct flowi with
>
> } __attribute__((__aligned__(BITS_PER_LONG/8)));
>
> Don't reinvent the wheel, either mimick how existing code does
> this kind of thing or provide a justification for doing it differently
> and update the existing cases to match and be consistent.

This may still break the alignment of 64-bit values on 32-bit architectures
where __alignof__(u64) == 8.

Now let's look at the comparison function:

static bool __cmp_key(const struct sw_flow_key *key1,
                const struct sw_flow_key *key2,  int key_start, int key_end)
{
        const long *cp1 = (long *)((u8 *)key1 + key_start);
        const long *cp2 = (long *)((u8 *)key2 + key_start);
        long diffs = 0;
        int i;

        for (i = key_start; i < key_end;  i += sizeof(long))
                diffs |= *cp1++ ^ *cp2++;

        return diffs == 0;
}

Why don't you abort the loop if a difference is found?
Or is this a security-related struct where you want to protect against
timing attacks?

Furthermore, as you compare the raw bytes, I hope you always
initialize all gaps in the struct to zero.
E.g. there's a 2-byte gap immediately after "ip", as the next member
is 32-bit (except op m68k, where the 32-bit member will be 2-byte aligned).

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
