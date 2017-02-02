From: Jon Mason <jon.mason@broadcom.com>
Subject: Re: [PATCH 1/2] net: ethernet: bgmac: init sequence bug
Date: Thu, 2 Feb 2017 13:54:50 -0500
Message-ID: <CAC3K-4pNX00hC4PwUNZ6xj1LRooT-3Sno+daHkLQGCGnfxrAsw@mail.gmail.com>
References: <1485988752-21030-1-git-send-email-jon.mason@broadcom.com>
 <1485988752-21030-2-git-send-email-jon.mason@broadcom.com> <12ceba49-5465-072c-1770-b57d265bee86@milecki.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@davemloft.net>,
        BCM Kernel Feedback <bcm-kernel-feedback-list@broadcom.com>,
        Network Development <netdev@vger.kernel.org>,
        open list <linux-kernel@vger.kernel.org>,
        Zac Schroff <zschroff@broadcom.com>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <rafal@milecki.pl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <12ceba49-5465-072c-1770-b57d265bee86@milecki.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 1, 2017 at 6:06 PM, Rafa=C5=82 Mi=C5=82ecki <rafal@milecki.pl> =
wrote:
> On 02/01/2017 11:39 PM, Jon Mason wrote:
>>
>> From: Zac Schroff <zschroff@broadcom.com>
>>
>> Fix a bug in the 'bgmac' driver init sequence that blind writes for init
>> sequence where it should preserve most bits other than the ones it is
>> deliberately manipulating.
>>
>> Signed-off-by: Zac Schroff <zschroff@broadcom.com>
>> Signed-off-by: Jon Mason <jon.mason@broadcom.com>
>> Fixes: f6a95a24957 ("net: ethernet: bgmac: Add platform device support")
>> ---
>>  drivers/net/ethernet/broadcom/bgmac-platform.c | 10 +++++++---
>>  include/linux/bcma/bcma_regs.h                 |  1 +
>>  2 files changed, 8 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/broadcom/bgmac-platform.c
>> b/drivers/net/ethernet/broadcom/bgmac-platform.c
>> index 6f736c1..9bbe05c 100644
>> --- a/drivers/net/ethernet/broadcom/bgmac-platform.c
>> +++ b/drivers/net/ethernet/broadcom/bgmac-platform.c
>> @@ -61,15 +61,19 @@ static bool platform_bgmac_clk_enabled(struct bgmac
>> *bgmac)
>>
>>  static void platform_bgmac_clk_enable(struct bgmac *bgmac, u32 flags)
>>  {
>> -       bgmac_idm_write(bgmac, BCMA_IOCTL,
>> -                       (BCMA_IOCTL_CLK | BCMA_IOCTL_FGC | flags));
>> +       u32 regval;
>> +
>> +       /* Some bits of BCMA_IOCTL set by HW/ATF & should not change */
>> +       regval =3D bgmac_idm_read(bgmac, BCMA_IOCTL) &
>> BCMA_IOCTL_DO_NOT_MODIFY;
>> +       regval |=3D ((flags & (~BCMA_IOCTL_DO_NOT_MODIFY)) |
>> BCMA_IOCTL_CLK);
>
>
> You don't need these braces around whole calculation.
> This should work the same:
> (flags & (~BCMA_IOCTL_DO_NOT_MODIFY)) | BCMA_IOCTL_CLK

Fair enough

>
>
>> +       bgmac_idm_write(bgmac, BCMA_IOCTL, regval | BCMA_IOCTL_FGC);
>>         bgmac_idm_read(bgmac, BCMA_IOCTL);
>>
>>         bgmac_idm_write(bgmac, BCMA_RESET_CTL, 0);
>>         bgmac_idm_read(bgmac, BCMA_RESET_CTL);
>>         udelay(1);
>>
>> -       bgmac_idm_write(bgmac, BCMA_IOCTL, (BCMA_IOCTL_CLK | flags));
>> +       bgmac_idm_write(bgmac, BCMA_IOCTL, regval);
>>         bgmac_idm_read(bgmac, BCMA_IOCTL);
>>         udelay(1);
>>  }
>> diff --git a/include/linux/bcma/bcma_regs.h
>> b/include/linux/bcma/bcma_regs.h
>> index 9986f82..41d7404 100644
>> --- a/include/linux/bcma/bcma_regs.h
>> +++ b/include/linux/bcma/bcma_regs.h
>> @@ -31,6 +31,7 @@
>>  #define  BCMA_IOCTL_CORE_BITS          0x3FFC
>>  #define  BCMA_IOCTL_PME_EN             0x4000
>>  #define  BCMA_IOCTL_BIST_EN            0x8000
>> +#define  BCMA_IOCTL_DO_NOT_MODIFY      0x7FFFFF80
>
>
> This sounds like a pretty bad name.

Name change coming

> Take a look at brcmsmac and SICF_*:
> http://lxr.free-electrons.com/source/drivers/net/wireless/broadcom/brcm80=
211/brcmsmac/d11.h?v=3D4.9#L1737
>
> Or b43 and B43_BCMA_IOCTL_*:
> http://lxr.free-electrons.com/source/drivers/net/wireless/broadcom/b43/b4=
3.h?v=3D4.9#L494
>
> Both drives modify bits you marked as DO_NOT_MODIFY and they are OK.

I think the point Zac was trying to make is that this is changing bits
that aren't meaning to be modified.  We should only be flipping the
bits necessary to enable the clocks, etc.  Bootloaders, etc might be
setting bits (and in our case they are) which are being removed
forcing it to a predefined value.

Thanks,
Jon
