From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: Lots of new warnings with gcc-7.1.1
Date: Wed, 12 Jul 2017 01:54:40 +0200
Message-ID: <C983283A-CB6B-47F5-BBCF-ED878ECB191C@holtmann.org>
References: <CA+55aFzXz-PxKSJP=hfHD+mfCX4M6+HMacWMkDz7KB8-3y55qw@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: Tejun Heo <tj@kernel.org>, Jean Delvare <jdelvare@suse.com>,
        Guenter Roeck <linux@roeck-us.net>,
        Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
        Sathya Prakash <sathya.prakash@broadcom.com>,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        the arch/x86 maintainers <x86@kernel.org>,
        xen-devel <xen-devel@lists.xenproject.org>,
        linux-block <linux-block@vger.kernel.org>,
        Linux Media Mailing List <linux-media@vger.kernel.org>,
        IDE-ML <linux-ide@vger.kernel.org>,
        "linux-fbdev@vger.kernel.org" <linux-fbdev@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([212.227.132.17]:49109 "EHLO
        mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756431AbdGKXyp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Jul 2017 19:54:45 -0400
In-Reply-To: <CA+55aFzXz-PxKSJP=hfHD+mfCX4M6+HMacWMkDz7KB8-3y55qw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Linus,

> At the same time, others aren't quite as insane, and in many cases the
> warnings might be easy to just fix.
> 
> And some actually look valid, although they might still require odd input:
> 
>  net/bluetooth/smp.c: In function ‘le_max_key_size_read’:
>  net/bluetooth/smp.c:3372:29: warning: ‘snprintf’ output may be
> truncated before the last format character [-Wformat-truncation=]
>    snprintf(buf, sizeof(buf), "%2u\n", SMP_DEV(hdev)->max_key_size);
>                               ^~~~~~~
>  net/bluetooth/smp.c:3372:2: note: ‘snprintf’ output between 4 and 5
> bytes into a destination of size 4
> 
> yeah, "max_key_size" is unsigned char, but if it's larger than 99 it
> really does need 5 bytes for "%2u\n" with the terminating NUL
> character.
> 
> Of course, the "%2d" implies that people expect it to be < 100, but at
> the same time it doesn't sound like a bad idea to just make the buffer
> be one byte bigger. So..

the Bluetooth specification defines that the Maximum Encryption Key Size shall be in the range 7 to 16 octets. Which is also reflected in these defines:

#define SMP_MIN_ENC_KEY_SIZE            7
#define SMP_MAX_ENC_KEY_SIZE            16

So it is buf[4] since we know it never gets larger than 16. So even in this case the warning is bogus.

I have no problem in increasing it to buf[5] to shut up the compiler, but that is what I would be doing here. I am not fixing an actual bug.

> Anyway, it would be lovely if some of the more affected developers
> would take a look at gcc-7.1.1 warnings. Right now I get about three
> *thousand* lines of warnings from a "make allmodconfig" build, which
> makes them a bit overwhelming.
> 
> I do suspect I'll make "-Wformat-truncation" (as opposed to
> "-Wformat-overflow") be a "V=1" kind of warning.  But let's see how
> many of these we can fix, ok?

I had to use the -Wno-format-trunction in a few projects since gcc was completely lost. And since we were using snprintf, I saw no point in trying to please gcc with a larger buffer.

Regards

Marcel
