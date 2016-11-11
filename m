From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH 0/2] bnx2: Hard reset bnx2 chip at probe stage
Date: Fri, 11 Nov 2016 09:37:26 -0800
Message-ID: <CACKFLimGyhzPY=0ehHGG7e0w58i7XfuTmAcsrjMwzc3weGNCjA@mail.gmail.com>
References: <1478871995-29652-1-git-send-email-bhe@redhat.com> <20161111140205.GD15325@x1>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        open list <linux-kernel@vger.kernel.org>,
        Dept-GELinuxNICDev@cavium.com, rasesh.mody@cavium.com,
        harish.patil@cavium.com, frank@undermydesk.org, jsr@dex.edzone.net,
        pmenzel@molgen.mpg.de, jroedel@suse.de, dyoung@redhat.com
To: Baoquan He <bhe@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161111140205.GD15325@x1>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 11, 2016 at 6:02 AM, Baoquan He <bhe@redhat.com> wrote:
> On 11/11/16 at 09:46pm, Baoquan He wrote:
>> Hi bnx2 experts,
>>
>> In commit 3e1be7a ("bnx2: Reset device during driver initialization"),
>> firmware requesting code was moved from open stage to probe stage.
>> The reason is in kdump kernel hardware iommu need device be reset in
>> driver probe stage, otherwise those in-flight DMA from 1st kernel
>> will continue going and look up into the newly created io-page tables.
>> So we need reset device to stop in-flight DMA as early as possibe.
>>
>> But with commit 3e1be7a merged, people reported their bnx2 driver init
>> failed because of failed firmware loading. After discussion, it's found
>> that they built bnx2 driver into kernel, and that makes probe function
>> bnx2_init_one be called in do_initcalls(). But at this time the initramfs
>> has not been uncompressed yet and mounted, kernel can't detect firmware.
>>
>> So there's only one way to cover both. Try to hard reset the bnx2 device
>> at probe stage, without involving firmware issues. I tried to add function
>> bnx2_hard_reset_chip() to do this and it's only called in kdump kernel.
>> The thing is I am not quite familiar with bnx2 chip spec, just abstract
>> code from bnx2_reset_chip, the testing result is good.
>
> Here I changed to send BNX2_MISC_COMMAND_HD_RESET in BNX2_CHIP_5709
> case.
>

>From my old 5709 Documentation:

Bit 6 HD_RESET:  Writing this bit as 1 will cause the chip to do a
hard reset like bit 5 except the sticky bits in the PCI function are
not reset.

Bit 5 POR_RESET: Writing this bit as 1 will cause the chip to do an
internal reset exactly like a power-up reset.  There is no protection
for this request and it may cause any current PCI cycle to lock up.
This reset is intended for use under manufacturing conditions only.

So it sounds like doing HD_RESET can potentially cause a PCI bus lock up.

Why not just disable DMA gracefully as done at the beginning of
bnx2_reset_chip()?
