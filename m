From: Daniel Drake <drake@endlessm.com>
Subject: Re: [PATCH 2/6] ath9k: add a quirk to set use_msi automatically
Date: Mon, 2 Oct 2017 12:21:57 +0800
Message-ID: <CAD8Lp46mdgbfCGY_i=N7FB1rMfL0KA0VFQxJESxshe4Cn6k4+Q@mail.gmail.com>
References: <1506408099-18488-1-git-send-email-acelan.kao@canonical.com>
 <1506408099-18488-2-git-send-email-acelan.kao@canonical.com>
 <20170926064456.GA28611@infradead.org> <CAFv23Qm9kZLSqJ_BP1D7mWCxekq0nt3S8onT1ckH-AoHDBUDzw@mail.gmail.com>
 <20170926140413.GA19977@infradead.org> <878th14kde.fsf@kamboji.qca.qualcomm.com>
 <CAFv23Qn4OMuHaSA6UG+Q7L1sTt+ZO8T-JYVaBM1FxZtGNxOhdQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Kalle Valo <kvalo@codeaurora.org>,
        Christoph Hellwig <hch@infradead.org>,
        QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        "Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>
To: AceLan Kao <acelan.kao@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAFv23Qn4OMuHaSA6UG+Q7L1sTt+ZO8T-JYVaBM1FxZtGNxOhdQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi AceLan,

On Thu, Sep 28, 2017 at 4:28 PM, AceLan Kao <acelan.kao@canonical.com> wrote:
> Hi Daniel,
>
> I've tried your patch, but it doesn't work for me.
> Wifi can scan AP, but can't get connected.

Can you please clarify which patch(es) you have tried?

This is the base patch which adds the infrastructure to request
specific MSI IRQ vectors:
https://marc.info/?l=linux-wireless&m=150631274108016&w=2

This is the ath9k MSI patch which makes use of that:
https://github.com/endlessm/linux/commit/739c7a924db8f4434a9617657

If you were already able to use ath9k MSI interrupts without specific
consideration for which MSI vector numbers were used, these are the
possible explanations that spring to mind:

1. You got lucky and it picked a vector number that is 4-aligned. You
can check this in the "lspci -vvv" output. You'll see something like:
Capabilities: [50] MSI: Enable+ Count=1/4 Maskable+ 64bit+
        Address: 00000000fee0300c  Data: 4142
The lower number is the vector number. In my example here 0x42 (66) is
not 4-aligned so the failure condition will be hit.

2. You are using interrupt remapping, which I suspect may provide a
high likelihood of MSI interrupt vectors being 4-aligned. See if
/proc/interrupts shows the IRQ type as IR-PCI-MSI
Unfortunately interrupt remapping is not available here,
https://lists.linuxfoundation.org/pipermail/iommu/2017-August/023717.html

3. My assumption that all ath9k hardware corrupts the MSI vector
number could wrong. However we've seen this on different wifi modules
in laptops produced by different OEMs and ODMs, so it seems to be a
somewhat widespread problem at least.

4. My assumption that ath9k hardware is corrupting the MSI vector
number could be wrong; maybe another component is to blame, could it
be a BIOS issue? Admittedly I don't really know how I can debug the
layers inbetween seeing the MSI Message Data value disagree with the
vector number being handled inside do_IRQ().

Daniel
