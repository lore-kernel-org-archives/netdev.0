From: "Marc Bevand" <m.bevand@gmail.com>
Subject: Re: [PATCH -rt DO NOT APPLY] Fix for tg3 networking lockup
Date: Fri, 25 Aug 2006 16:48:49 -0700
Message-ID: <aaccfcb60608251648l138ae3bdre9a41aef3d541d7d@mail.gmail.com>
References: <20060805202603.GA9740@thunk.org>
	 <1551EAE59135BE47B544934E30FC4FC093FA21@NT-IRVA-0751.brcm.ad.broadcom.com>
	 <loom.20060825T235849-675@post.gmane.org>
	 <1156546533.5021.10.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.228]:18596 "EHLO
	wx-out-0506.google.com") by vger.kernel.org with ESMTP
	id S932085AbWHYXst (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 19:48:49 -0400
Received: by wx-out-0506.google.com with SMTP id s14so1027648wxc
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2006 16:48:49 -0700 (PDT)
To: "Michael Chan" <mchan@broadcom.com>
In-Reply-To: <1156546533.5021.10.camel@rh4>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/25/06, Michael Chan <mchan@broadcom.com> wrote:
>
> The reason is that TSO on 5704 and older chips is done by firmware.  ASF
> is also implemented by firmware.  If ASF is enabled, there is no room to
> do TSO and ASF at the same time.

Just for test purpose, I have applied the following patch to my tg3.c. I now
seem to be able to enable/disable TSO, but I admit don't know whether ASF
is still functional or not.

        else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5700 ||
            GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701 ||
-           tp->pci_chip_rev_id == CHIPREV_ID_5705_A0 ||
-           (tp->tg3_flags & TG3_FLAG_ENABLE_ASF) != 0) {
+           tp->pci_chip_rev_id == CHIPREV_ID_5705_A0) {
                tp->tg3_flags2 &= ~TG3_FLG2_TSO_CAPABLE;
        } else {

Then tg3 considered my interface as TSO-capable ("TSOcap[1]" in dmesg).
TSO was still disabled by default, which is normal because there is this other
check a couple of lines below:

        /* TSO is on by default on chips that support hardware TSO.
         * Firmware TSO on older chips gives lower performance, so it
         * is off by default, but can be enabled using ethtool.
         */
        if (tp->tg3_flags2 & TG3_FLG2_HW_TSO)
                dev->features |= NETIF_F_TSO;

But I was able to turn TSO on via ethtool -K. This is exactly the behavior I
would like to see in tg3. So are you saying the patch I applied actually
breaks ASF ?

> Firmware-based TSO is actually slower than no TSO.  The only benefit is
> a little better CPU utilization.

I know, in one of my test-cases, firmware TSO reduces the max achievable
TCP bandwidth from 930 to 840 Mbit/s on a GigE network while reducing
the CPU utilization from 44% to 22%. I think firmware TSO still makes sense
in some cases.

-- 
Marc Bevand
