From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 05/14] isdn: isdnloop: suppress a gcc-7 warning
Date: Fri, 14 Jul 2017 12:37:05 +0200
Message-ID: <CAK8P3a2fYr11L-0sg-veKx5F5dGH5btQAhSZtFbNXxVtcHd8dg@mail.gmail.com>
References: <20170714092540.1217397-1-arnd@arndb.de> <20170714092540.1217397-6-arnd@arndb.de>
 <1500026936.4457.68.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Karsten Keil <isdn@linux-pingi.de>,
        "David S. Miller" <davem@davemloft.net>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Tejun Heo <tj@kernel.org>, Guenter Roeck <linux@roeck-us.net>,
        IDE-ML <linux-ide@vger.kernel.org>,
        Linux Media Mailing List <linux-media@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        dri-devel <dri-devel@lists.freedesktop.org>,
        Networking <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:35972 "EHLO
        mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753479AbdGNKhH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2017 06:37:07 -0400
In-Reply-To: <1500026936.4457.68.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 14, 2017 at 12:08 PM, Joe Perches <joe@perches.com> wrote:
> On Fri, 2017-07-14 at 11:25 +0200, Arnd Bergmann wrote:
>> We test whether a bit is set in a mask here, which is correct
>> but gcc warns about it as it thinks it might be confusing:
>>
>> drivers/isdn/isdnloop/isdnloop.c:412:37: error: ?: using integer constants in boolean context, the expression will always evaluate to 'true' [-Werror=int-in-bool-context]
>>
>> This replaces the negation of an integer with an equivalent
>> comparison to zero, which gets rid of the warning.
> []
>> diff --git a/drivers/isdn/isdnloop/isdnloop.c b/drivers/isdn/isdnloop/isdnloop.c
> []
>> @@ -409,7 +409,7 @@ isdnloop_sendbuf(int channel, struct sk_buff *skb, isdnloop_card *card)
>>               return -EINVAL;
>>       }
>>       if (len) {
>> -             if (!(card->flags & (channel) ? ISDNLOOP_FLAGS_B2ACTIVE : ISDNLOOP_FLAGS_B1ACTIVE))
>> +             if ((card->flags & (channel) ? ISDNLOOP_FLAGS_B2ACTIVE : ISDNLOOP_FLAGS_B1ACTIVE) == 0)
>>                       return 0;
>>               if (card->sndcount[channel] > ISDNLOOP_MAX_SQUEUE)
>>                       return 0;
>
> The if as written can not be zero.
>
> drivers/isdn/isdnloop/isdnloop.h:#define ISDNLOOP_FLAGS_B1ACTIVE 1      /* B-Channel-1 is open           */
> drivers/isdn/isdnloop/isdnloop.h:#define ISDNLOOP_FLAGS_B2ACTIVE 2      /* B-Channel-2 is open           */
>
> Perhaps this is a logic defect and should be:
>
>                 if (!(card->flags & ((channel) ? ISDNLOOP_FLAGS_B2ACTIVE : ISDNLOOP_FLAGS_B1ACTIVE)))

Yes, good catch. I had thought about it for a bit whether that would be
the answer, but come to the wrong conclusion on my own.

Note that the version you suggested will still have the warning, so I think
it needs to be

                 if (card->flags &
                    ((channel) ? ISDNLOOP_FLAGS_B2ACTIVE :
ISDNLOOP_FLAGS_B1ACTIVE)
                     == 0)

or something like that, probably having a temporary flag variable would be best:

          int flag =  channel ? ISDNLOOP_FLAGS_B2ACTIVE :
ISDNLOOP_FLAGS_B1ACTIVE;
          if ((card->flags & flag) == 0)
                       return 0;

         Arnd
