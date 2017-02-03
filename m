From: Jon Mason <jon.mason@broadcom.com>
Subject: Re: [PATCH v2 1/2] net: ethernet: bgmac: init sequence bug
Date: Fri, 3 Feb 2017 17:34:48 -0500
Message-ID: <CAC3K-4q7XObojqPppn=Qvps=BDMAQOfgxMBrci3VJrX+Pc73AQ@mail.gmail.com>
References: <1486156133-5639-1-git-send-email-jon.mason@broadcom.com>
 <1486156133-5639-2-git-send-email-jon.mason@broadcom.com> <8b0979e4-7202-869f-95b3-ab5d0381ed69@milecki.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@davemloft.net>,
        BCM Kernel Feedback <bcm-kernel-feedback-list@broadcom.com>,
        Network Development <netdev@vger.kernel.org>,
        open list <linux-kernel@vger.kernel.org>,
        Zac Schroff <zschroff@broadcom.com>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <rafal@milecki.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f52.google.com ([209.85.214.52]:36417 "EHLO
        mail-it0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752356AbdBCWeu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 17:34:50 -0500
Received: by mail-it0-f52.google.com with SMTP id c7so21385540itd.1
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 14:34:50 -0800 (PST)
In-Reply-To: <8b0979e4-7202-869f-95b3-ab5d0381ed69@milecki.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 3, 2017 at 4:41 PM, Rafa=C5=82 Mi=C5=82ecki <rafal@milecki.pl> =
wrote:
> On 02/03/2017 10:08 PM, Jon Mason wrote:
>>
>> @@ -61,15 +60,20 @@ static bool platform_bgmac_clk_enabled(struct bgmac
>> *bgmac)
>>
>>  static void platform_bgmac_clk_enable(struct bgmac *bgmac, u32 flags)
>>  {
>> -       bgmac_idm_write(bgmac, BCMA_IOCTL,
>> -                       (BCMA_IOCTL_CLK | BCMA_IOCTL_FGC | flags));
>> +       u32 val;
>> +
>> +       val =3D bgmac_idm_read(bgmac, BCMA_IOCTL);
>> +       /* Some bits of BCMA_IOCTL set by HW/ATF and should not change *=
/
>> +       val |=3D flags & ~(BGMAC_AWCACHE | BGMAC_ARCACHE | BGMAC_AWUSER =
|
>> +                        BGMAC_ARUSER);
>> +       val |=3D BGMAC_CLK_EN;
>>         bgmac_idm_read(bgmac, BCMA_IOCTL);
>
>
> This read was previously following write op most likely to flush it or
> something. I don't think it makes any sense to read after read.

Actually, that is sloppy coding on my part.  It should have a write
prior to the read to match what was there before.

I find it odd that it worked when I tested this patch.  It makes me
wonder if this "modify, reset, modify" series is really necessary
after all.  The docs indicate that writing a 0 to the reset brings it
out of reset.  I do not see any code that puts the HW in reset.  So,
unless the bootloader puts the HW in reset or it is in the reset state
by default, this seems like unnecessary code.  I can add some CYA
logic to read and see if it is in reset, toggle the bit, and then just
do the CLK enable.  Thoughts?

Thanks,
Jon
