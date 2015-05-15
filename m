From: Dan Williams <dcbw@redhat.com>
Subject: Re: GSM Modem management?
Date: Fri, 15 May 2015 09:27:30 -0500
Message-ID: <1431700050.12788.13.camel@redhat.com>
References: <20150514194442.GA21972@bamboo.electronicsoup>
	 <1431634836.10190.7.camel@redhat.com>
	 <20150514213443.GA23715@bamboo.electronicsoup>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: John Whitmore <arigead@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49831 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933865AbbEOO1d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 May 2015 10:27:33 -0400
In-Reply-To: <20150514213443.GA23715@bamboo.electronicsoup>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-05-14 at 22:34 +0100, John Whitmore wrote:
> On Thu, May 14, 2015 at 03:20:36PM -0500, Dan Williams wrote:
> > On Thu, 2015-05-14 at 20:44 +0100, John Whitmore wrote:
> > > Chances are that I'm in the wrong place here, "Linux" networking having so many
> > > parts, many of which aren't in the kernel, that being said this might be
> > > considered the centre of it all, so I thought I'd start here and see if
> > > somebody would point me in a direction that was better placed to answer some
> > > of my queries.
> > > 
> > > I'm working on a mobile system, RaspberryPi based, which has two 4G USB
> > > Dongles for communications to the Internet. Both dongles are the same make and
> > > model but have different service provider sims. The idea being that if one has
> > > no coverage hopefully the other does have some degree of connectivity. I
> > > started by connecting up to the internet using network-manager-gnome for a
> > > single dongle. Unfortunately when I started a ping test after a couple of ping
> > > messages it crashed the whole raspbian system without any message going to
> > > /var/log/messages. Totally locked up. 
> > 
> > Odd, are these dongles using AT commands or are they using one of the
> > proprietary protocols like QMI, MBIM, or QCDM?  It's highly unlikely
> > that NetworkManager + ModemManager would be crashing your system when
> > using plain AT commands, but there have in the past been driver problems
> > with QMI and MBIM.  Can you give specifics on the dongles?
> >
> 
> Thanks a million for that! I've never played with GSM Dongles before, so I'd
> never heard of anything but AT being used. That is a great help. Dongle is a
> Huawei E398. It's a LTE/UMTS/GSM Modem/Networkcard according to "lsusb" and
> comes in as 12d1:1505 and then after usb_modeswitch 12d1:1506. Given that
> "Networkcard" all those protocols you mentioned are probably what's being used.

I got your mail on ModemManager-devel and responded there too, just a
quick follow-up here.

So you're actually using a QMI-native device, but using it in PPP mode
with wvdial.  It looks from your logs like the modem is crashing and
dropping off the USB bus.  We should try QMI+net to see if that will
work better than PPP.
 
> > > Having failed with the Network-manager I used wvdial to establish a connection
> > > and that is as happy as larry, pinging away. 
> > 
> > Are you using PPP as the mechanism here?  Unless you have very low
> > bandwidth requirements I'd recommend using the pseudo-ethernet interface
> > provided by the modem (which often also requires using a proprietary
> > protocol like QMI or MBIM to control it) since this gives much higher
> > throughput especially with HSPA+ and LTE.
> >
> 
> Yes when I use wvdial it brings them up using a ppp0 interface. I should go
> back to the network-manager and keep an eye on the modem manager. Didn't
> realise that service was in there so again thanks a million.
>  
> > > My questions are to do with how to manage two identical Dongles. At present
> > > when usb-modeswitch ejects them, from CD Drive, into modem configuration, when
> > > "qmi_wwan" assignes a network name. I'd like to assign udev rules to assign
> > > carrier based names to the network interfaces. I'm not sure if udev will
> > > interfere with qmi_wwan? 
> > 
> > Aha, so you are using Qualcomm-based dongles :)  So NetworkManager +
> > ModemManager will natively try to use QMI + ethernet on these dongles
> > just like Windows does, because that provides the most flexibility and
> > speed.  So the crashes/hangs you were experiencing may be due to driver
> > issues in the qmi_wwan and cdc_wdm modules.  What kernel version are you
> > using here too?
> 
> Latest for the RaspberryPi, I think, 3.18.13 on a RPi Vesion 2. It's not what
> came with raspbian but I built the latest.

Given that you're using ModemManager 0.5 (without QMI) or wvdial, kernel
version and driver issues in qmi_wwan or cdc-wdm won't be the cause of
the problems here and could be the solution :)

Anyway, lets follow up on ModemManager-devel.

Thanks!
Dan

> > 
> > > That is possibly the easy part. I then want to attach some logic to manage the
> > > connections in a very basic manner and perhaps display connectivity
> > > information to the user on the desktop. Could somebody tell me where this
> > > functionality would be added? I assume that ppp has no idea about GSM signal
> > > strength. It'd be great if a simple user space program could monitor DBus and
> > > bring up or drop the connections as conditions change, but I guess that might
> > > be asking for a little bit much. So if not ppp what sub-system controls the
> > > Modem? 
> > 
> > It all depends on the modem itself and what it supports.  We've tried to
> > develop ModemManager as single system service that works with all kinds
> > of modems and insulates you from these kind of issues.  The end result
> > is that nothing in the Linux kernel itself provides this kind of
> > management; the kernel only provides interfaces to the modem's firmware
> > and its up to userspace to figure out what protocols the modem speaks
> > (AT, QMI, MBIM, QCDM, etc) and to talk those protocols to the modem.
> > 
> > Dan
> > 
> 
> Thanks so much for taking the time to educate me! I have to look into all this
> and more protocols then I knew existed. I'll have a look into the modem
> manager as that's probably something I've done incorrectly.
> 
> John
