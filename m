From: Ilia Mirkin <imirkin@alum.mit.edu>
Subject: Re: tg3: Occassional death on 3.3
Date: Wed, 18 Apr 2012 13:30:01 -0400
Message-ID: <CAKb7Uvj4VpW+TYFKdK8174k5QbECBPjMZg3njgnMZHAcRJ2cWw@mail.gmail.com>
References: <CAKb7UvjWACB5wF9B1GvznVd64Vby_9ri4SMo57RpAhrhf+awFg@mail.gmail.com>
	<20120418005511.GA2944@mcarlson.broadcom.com>
	<20120418171959.GA4823@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:45422 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753221Ab2DRRaD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 13:30:03 -0400
Received: by iagz16 with SMTP id z16so10693570iag.19
        for <netdev@vger.kernel.org>; Wed, 18 Apr 2012 10:30:01 -0700 (PDT)
In-Reply-To: <20120418171959.GA4823@mcarlson.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 18, 2012 at 1:19 PM, Matt Carlson <mcarlson@broadcom.com> w=
rote:
> On Tue, Apr 17, 2012 at 05:55:11PM -0700, Matt Carlson wrote:
>> On Tue, Apr 17, 2012 at 08:22:31PM -0400, Ilia Mirkin wrote:
>> > Hello,
>> >
>> > I'm observing an issue where it appears that tg3 gets wedged into =
a
>> > bad state every so often, and never recovers. Doing a sequence of
>> >
>> > ifconfig eth0 down
>> > rmmod broadcom
>> > rmmod tg3
>> >
>> > modprobe broadcom
>> > modprobe tg3
>> >
>> > Makes everything work again. The card I have:
>> >
>> > 03:00.0 Ethernet controller [0200]: Broadcom Corporation NetLink
>> > BCM57788 Gigabit Ethernet PCIe [14e4:1691] (rev 01)
>> > =A0 =A0 =A0 =A0 Subsystem: Dell XPS 8300 [1028:04aa]
>> > =A0 =A0 =A0 =A0 Flags: bus master, fast devsel, latency 0, IRQ 45
>> > =A0 =A0 =A0 =A0 Memory at fb100000 (64-bit, non-prefetchable) [siz=
e=3D64K]
>> > =A0 =A0 =A0 =A0 Capabilities: [48] Power Management version 3
>> > =A0 =A0 =A0 =A0 Capabilities: [60] Vendor Specific Information: Le=
n=3D6c <?>
>> > =A0 =A0 =A0 =A0 Capabilities: [50] MSI: Enable+ Count=3D1/1 Maskab=
le- 64bit+
>> > =A0 =A0 =A0 =A0 Capabilities: [cc] Express Endpoint, MSI 00
>> > =A0 =A0 =A0 =A0 Capabilities: [100] Advanced Error Reporting
>> > =A0 =A0 =A0 =A0 Capabilities: [13c] Virtual Channel
>> > =A0 =A0 =A0 =A0 Capabilities: [160] Device Serial Number [the mac =
address]
>> > =A0 =A0 =A0 =A0 Capabilities: [16c] Power Budgeting <?>
>> > =A0 =A0 =A0 =A0 Kernel driver in use: tg3
>> > =A0 =A0 =A0 =A0 Kernel modules: tg3
>> >
>> > I'm attaching the log for the full data dump, since my mailer will
>> > wrap it horribly otherwise, but the interesting lines are:
>> >
>> > [2234380.228971] tg3 0000:03:00.0: eth0: transmit timed out, reset=
ting
>> > ... some kind of data dump ...
>> > [2234382.216682] tg3 0000:03:00.0: eth0: 0: Host status block
>> > [00000001:00000080:(0000:01ef:0000):(01ef:00b2)]
>> > [2234382.216685] tg3 0000:03:00.0: eth0: 0: NAPI info
>> > [00000080:00000080:(00cb:00b2:01ff):01ef:(00b7:0000:0000:0000)]
>> > [2234382.319550] tg3 0000:03:00.0: tg3_stop_block timed out, ofs=3D=
1400
>> > enable_bit=3D2
>> > [2234382.421931] tg3 0000:03:00.0: tg3_stop_block timed out, ofs=3D=
c00
>> > enable_bit=3D2
>> > [2234382.427199] tg3 0000:03:00.0: eth0: Link is down
>> > [2234382.438168] tg3 0000:03:00.0: eth0: Link is down
>> >
>> > Any further attempts to use the NIC, like ifconfig down/up result =
in a
>> > similar error log sequence happening. Also, while it's happening, =
the
>> > computer feels extremely laggy for a short period of time (~1s),
>> > leading me to believe it's doing an uninterruptible sleep of some =
kind
>> > going on.
>> >
>> > This has happened twice, and at least the second time, there was n=
o
>> > unusual traffic on the network. It's linked at 100M, and was proba=
bly
>> > doing 10K/s at most when the error happened. If this is insufficie=
nt
>> > information, please let me know what I should collect next time th=
is
>> > might happen.
>> >
>> > Thanks,
>>
>> Thanks for the report Ilia. =A0I'm guessing the lag is coming from t=
he
>> driver as it logs the register dump to the syslog.
>>
>> The register dump shows that interrupts are enabled, but the tag val=
ue in
>> the interrupt mailbox register doesn't match the value in the status=
 block
>> or the driver's private tag value. =A0I'll see where that leads me.
>
> O.K. =A0The interrupt mailbox issue I mentioned above can happen when=
 in
> one-shot MSI mode, but it still smells strange. =A0If the tag stored =
in
> the device structure matches the tag value in the status block, there
> should be no more work to do. =A0In that case, the driver writes the =
new
> tag to the interrupt mailbox register.
>
> You may be encountering some type of hardware problem. =A0PCIe regist=
er
> 0x104 is the Uncorrectable Error Status register. =A0This register sh=
ows
> that the "Unsupported Request Error Status" bit is set. =A0This defin=
itely
> shouldn't happen.
>
> Do you know if there are any firmware updates available for your syst=
em?
>

I just checked on Dell's website, and I'm pretty sure I have the
latest BIOS. I'll double-check later, but the website says version
A06, as does my dmidecode. So unless they have multiple releases with
the same version number... :) In case it's of interest, the system is
a i7-2600 CPU, 18G of RAM (memtested).

Are there some PCI(e) debug options I should be turning on to perhaps
get a better picture of what's going on?
