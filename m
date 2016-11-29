From: "ASIX_Allan [Office]" <allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
Subject: RE: [PATCH v3 3/5] net: asix: Fix AX88772x resume failures
Date: Tue, 29 Nov 2016 16:54:28 +0800
Message-ID: <014301d24a1e$34513fe0$9cf3bfa0$@asix.com.tw>
References: <cover.c702ef6af13be7c1282a2f2d3189281fdc327abe.1472155176.git-series.robert.foss@collabora.com> <c708db3f1e006df543284cf5215b965ce4fc44ec.1472155176.git-series.robert.foss@collabora.com> <77fa76d6-ef63-47db-a316-93b3a0c0705b@nvidia.com> <00e501d23e54$337d4b70$9a77e250$@asix.com.tw> <f0d21edc-060b-bd9b-fced-faf1f51e8467@nvidia.com> <010d01d23e5b$d8993130$89cb9390$@asix.com.tw> <1fff2d2a-7bbe-298c-3d27-7dc44df08675@nvidia.com> <6aebd7f5-188a-f6b0-7eb0-75b764e069d3@nvidia.com>
Reply-To: <allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "'Jon Hunter'" <jonathanh-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>, <robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>,
        <freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>, <Dean_Jenkins-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>,
        <Mark_Craske-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        <ivecera-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        <vpalatin-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        <grundler-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, <changchias-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <andrew-g2DYL2Zd6BY@public.gmane.org>,
        <tremyfr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
        <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <vpalatin-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <6aebd7f5-188a-f6b0-7eb0-75b764e069d3-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
Content-Language: zh-tw
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dear Jon ,

We can reproduce your issue on x86 Linux kernel 4.9.0-rc system in our site
and modified the following code can fix this issue. Please let us know if
you still have problems. Thanks a lot.

static void ax88772_suspend(struct usbnet *dev)
{
        struct asix_common_private *priv = dev->driver_priv;
        u16 medium;

        /* Stop MAC operation */
-       medium = asix_read_medium_status(dev, 0);
+      medium = asix_read_medium_status(dev, 1);
        medium &= ~AX_MEDIUM_RE;
-       asix_write_medium_mode(dev, medium, 0);
+      asix_write_medium_mode(dev, medium, 1);

        netdev_dbg(dev->net, "ax88772_suspend: medium=0x%04x\n",
-                  asix_read_medium_status(dev, 0));
+                 asix_read_medium_status(dev, 1));

        /* Preserve BMCR for restoring */
        priv->presvd_phy_bmcr =
                asix_mdio_read_nopm(dev->net, dev->mii.phy_id, MII_BMCR);

        /* Preserve ANAR for restoring */
        priv->presvd_phy_advertise =
                asix_mdio_read_nopm(dev->net, dev->mii.phy_id,
MII_ADVERTISE);
} 


---
Best regards,
Allan Chou
Technical Support Division
ASIX Electronics Corporation
TEL: 886-3-5799500 ext.228
FAX: 886-3-5799558
E-mail: allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org 
http://www.asix.com.tw/ 


-----Original Message-----
From: Jon Hunter [mailto:jonathanh-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org] 
Sent: Tuesday, November 22, 2016 11:34 PM
To: allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org; robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org; freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org;
Dean_Jenkins-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org; Mark_Craske-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org; davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org;
ivecera-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org; john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org; vpalatin-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org;
stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org; grundler-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org; changchias-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org;
andrew-g2DYL2Zd6BY@public.gmane.org; tremyfr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org; colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org;
linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org;
linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; vpalatin-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
Subject: Re: [PATCH v3 3/5] net: asix: Fix AX88772x resume failures

Hi Allan,

On 18/11/16 15:09, Jon Hunter wrote:
> Hi Allan,
> 
> On 14/11/16 09:45, ASIX_Allan [Office] wrote:
>> Hi Jon,
>>
>> Please help to double check if the USB host controller of your Terga 
>> platform had been powered OFF while running the ax88772_suspend() 
>> routine or not?
> 
> Sorry for the delay. Today I set up a local board to reproduce this on 
> and was able to recreate the same problem. The Tegra xhci driver does 
> not power off during suspend and simply calls xhci_suspend(). I also 
> checked vbus to see if it was turning off but it is not. Furthermore I 
> don't see a new USB device detected after the error and so I don't see 
> any evidence that it ever disconnects.

In an attempt to isolate if this is a Tegra issue or not, I recompiled
v4.9-rc6 for x86 and I was able to reproduce the problem on my desktop ...

[  256.030060] PM: Syncing filesystems ... done.
[  256.113925] PM: Preparing system for sleep (mem) [  256.114119] Freezing
user space processes ... (elapsed 0.002 seconds) done.
[  256.116701] Freezing remaining freezable tasks ... (elapsed 0.001
seconds) done.
[  256.118041] PM: Suspending system (mem) [  256.118058] Suspending
console(s) (use no_console_suspend to debug) [  256.118324] asix 1-1.2:1.0
eth2: Failed to read reg index 0x0000: -19 [  256.118327] asix 1-1.2:1.0
eth2: Error reading Medium Status register: ffffffed [  256.118329] asix
1-1.2:1.0 eth2: Failed to write reg index 0x0000: -19 [  256.118332] asix
1-1.2:1.0 eth2: Failed to write Medium Mode mode to 0xfeed: ffffffed [
256.118374] sd 0:0:0:0: [sda] Synchronizing SCSI cache [  256.118471] sd
0:0:0:0: [sda] Stopping disk [  256.152992] hpet1: lost 1 rtc interrupts [
256.153893] serial 00:06: disabled [  256.153899] serial 00:06: System
wakeup disabled by ACPI [  256.154068] e1000e: EEE TX LPI TIMER: 00000011 [
256.628281] PM: suspend of devices complete after 509.782 msecs [
256.628620] PM: late suspend of devices complete after 0.336 msecs [
256.629366] ehci-pci 0000:00:1d.0: System wakeup enabled by ACPI [
256.629595] tg3 0000:03:00.0: System wakeup enabled by ACPI [  256.629601]
ehci-pci 0000:00:1a.0: System wakeup enabled by ACPI [  256.629652] e1000e
0000:00:19.0: System wakeup enabled by ACPI [  256.629812] xhci_hcd
0000:00:14.0: System wakeup enabled by ACPI [  256.648347] PM: noirq suspend
of devices complete after 19.713 msecs [  256.648685] ACPI: Preparing to
enter system sleep state S3 [  256.668275] PM: Saving platform NVS memory [
256.668283] Disabling non-boot CPUs ...

To reproduce this, I did the following:

1. Connect the asix device and noted the net interface (ie. eth2) 2.
Disabled the interface (ie. sudo ifconfig eth2 down) 3. Ran a suspend-resume
cycle using rtcwake (eg. sudo rtcwake -d rtc0 -m mem -s 5)

Cheers
Jon

--
nvpublic

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
