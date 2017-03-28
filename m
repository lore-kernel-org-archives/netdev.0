From: Christian Lamparter <chunkeey@googlemail.com>
Subject: Re: [PATCH 1/7] Documentation: dt: net: Update the ath9k binding for SoC devices
Date: Tue, 28 Mar 2017 16:53:32 +0200
Message-ID: <2357006.NGKQYCh4BG@debian64>
References: <1489439116-4233-1-git-send-email-albeu@free.fr> <1897671.fKa4XTnU1K@debian64> <20170328104441.5feedcf4@avionic-0020>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
        John Crispin <john@phrozen.org>,
        Kalle Valo <kvalo@codeaurora.org>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        m@kresin.me
To: Alban <albeu@free.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170328104441.5feedcf4@avionic-0020>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday, March 28, 2017 10:44:41 AM CEST Alban wrote:
> On Mon, 27 Mar 2017 18:11:15 +0200
> Christian Lamparter <chunkeey@googlemail.com> wrote:
> 
> > On Monday, March 13, 2017 10:05:09 PM CEST Alban wrote:
> > > The current binding only cover PCI devices so extend it for SoC devices.
> > > 
> > > Most SoC platforms use an MTD partition for the calibration data
> > > instead of an EEPROM. The qca,no-eeprom property was added to allow
> > > loading the EEPROM content using firmware loading. This new binding
> > > replace this hack with NVMEM cells, so we also mark the qca,no-eeprom
> > > property as deprecated in case anyone ever used it.  
> > 
> > Please don't mark "qca,no-eeprom" as deprecated then.
> > If some devices geniously need to rely on userspace for extracting 
> > and processing the calibration data, it should be stay a
> > optional properties.
> 
> Deprecated just mean that it shouldn't be used for new devices. 
> But as it is not used by any board, misuse the firmware loading API and
> firmware loader user helper are deprecated in udev, I find we could also
> just drop it.
But LEDE/OpenWRT rely on the firmware loading API more than ever and 
currently there is not a replacement for it. From what I know, Luis 
tried to replace it with his sysdata approach:

<https://lkml.org/lkml/2016/12/16/204>

however, this was disliked by Greg KH and Linus for the following reasons.
<https://lkml.org/lkml/2016/6/16/995>:

|So I absolutely abhor "changes for changes sake".
|
|If the existing code works for existing drivers, let them keep it.
|
|And if a new interface is truly more flexible, then it should be able
|to implement the old interface with no changes, so that drivers
|shouldn't need to be changed/upgraded.
|
|Then, drivers that actually _want_ new features, or that can take
|advantage of new interfaces to actually make things *simpler*, can
|choose to make those changes. But those changes should have real
|advantages.
|[...]


your nvmem approach would need to be as universal and
powerful as the "qca,no-eeprom" + userspace solutions
in order to deprecate it.
 
> > For example: A device that can't do easily without "qca,no-eeprom" is
> > the AVM FRITZ!WLAN Repeater 300E. For this device, the caldata 
> > is stored in the flash, however for whatever reason the vendor
> > choose to "reverse" it. (like completely back to front, not byteswapped
> > or something). So an extra "unreversing step" is required. So, it would
> > require some sort of a special nvmem-provider-processor as an 
> > alternative.
> 
> Or just handle this special eeprom format in the ath9k driver. I doubt
> that this case is so common that it would justify adding a whole new
> layer to nvmem.
Well, you'll have to deal with it in nvmem, if you want it to deprecate
"qca,no-eeprom".

I looked into 10-ath9k-eeprom [0] of LEDE's AR71XX target and I noticed
that quite a few devices patch the MACs of the wifi.
If you look at the code for the Airtight C-55 and C-60, Meraki MR18,
Meraki Z1, you'll notice that each one has to add a fixed value (+1,
+2, ...) to the extraced MAC-Address. So how would you replicate this,
with "nvmem-cell-names = address" without some sort of 
nvmem-provider-processor?

Also, there's another usecase of a nvmem-provider-processor. 
For example, one could be convert all the different types of
ascii-macs (Either strings like "00:11:22:33:44:55", 
"00.11.22.33..." or "00112233..." ) to their binary representation.
For AR71XX, this is mostly done by ath79_parse_ascii_mac:

https://github.com/lede-project/source/blob/master/target/linux/ar71xx/files/arch/mips/ath79/dev-eth.c#L1204

and grep lists the following devices:
mach-dgl-5500-a1.c, mach-dhp-1565-a1.c, mach-dir-505-a1.c, mach-dir-615-c1.c
mach-dir-615-i1.c, mach-dir-825-b1.c, mach-dir-825-c1.c, mach-tew-673gru.c
mach-tew-712br.c, mach-tew-732br.c, mach-tew-823dru.c

I did a quick check: All of them use the extracted MACs for ath9k
and/or ethernet.

Note: I think Ralink/MediaTek will have the same issues.

> > >  Optional properties:
> > > +- mac-address: See ethernet.txt in the parent directory
> > > +- local-mac-address: See ethernet.txt in the parent directory
> > > [...]
> > > +
> > > +Deprecated properties:
> > >  - qca,no-eeprom: Indicates that there is no physical EEPROM
> > > connected to the ath9k wireless chip (in this case the calibration /
> > >  			EEPROM data will be loaded from userspace
> > > using the kernel firmware loader).
> > > -- mac-address: See ethernet.txt in the parent directory
> > > -- local-mac-address: See ethernet.txt in the parent directory
> > > -  
> > It sounds like you want to deprecate mac-address and
> > local-mac-address as well. If so you sould add this to the commit as
> > well. From my point of view, people mostly flat-out patched the
> > eeprom-image if they wanted to set the mac-address. However, this was
> > an extra step, if nvmem does away with it, I'm completely fine with
> > deprecating these properties.
> 
> The produced diff is very misleading because the mac-address properties
> get lumped with the other new optional  properties. But if you look
> closely it just move qca,no-eeprom to the deprecated section.
Yes ok. This is the case.

Thanks,
Christian

[0] <https://github.com/lede-project/source/blob/master/target/linux/ar71xx/base-files/etc/hotplug.d/firmware/10-ath9k-eeprom#L85>
