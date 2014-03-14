From: Pasi =?iso-8859-1?Q?K=E4rkk=E4inen?= <pasik@iki.fi>
Subject: Re: [PATCH net-next v6 0/3] The huawei_cdc_ncm driver / E3276
 problem
Date: Fri, 14 Mar 2014 16:25:59 +0200
Message-ID: <20140314142559.GD3200@reaktio.net>
References: <1394746907.15946.8.camel@dcbw.local>
 <20140313220812.GW3200@reaktio.net>
 <20140314075548.GX3200@reaktio.net>
 <87wqfxnppc.fsf@nemi.mork.no>
 <20140314084159.GA3200@reaktio.net>
 <87siqlnol8.fsf@nemi.mork.no>
 <20140314090525.GB3200@reaktio.net>
 <87ob19nndo.fsf@nemi.mork.no>
 <20140314125934.GC3200@reaktio.net>
 <87vbvgnbv3.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dan Williams <dcbw@redhat.com>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Enrico Mioso <mrkiko.rs@gmail.com>,
	Oliver Neukum <oliver@neukum.org>
To: =?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emh07.mail.saunalahti.fi ([62.142.5.117]:41982 "EHLO
	emh07.mail.saunalahti.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754804AbaCNO0C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 10:26:02 -0400
Content-Disposition: inline
In-Reply-To: <87vbvgnbv3.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 14, 2014 at 02:33:36PM +0100, Bj=F8rn Mork wrote:
> Pasi K=E4rkk=E4inen <pasik@iki.fi> writes:
> > On Fri, Mar 14, 2014 at 10:24:51AM +0100, Bj=F8rn Mork wrote:
> >> Pasi K=E4rkk=E4inen <pasik@iki.fi> writes:
> >>=20
> >> > # ifconfig wwp0s26u1u5i1
> >> > wwp0s26u1u5i1: flags=3D4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu=
 1500
> >> >         inet 10.8.219.204  netmask 255.255.255.248  broadcast 10=
=2E8.219.207
> >> >         inet6 fe80::e5b:8fff:fe27:9a64  prefixlen 64  scopeid 0x=
20<link>
> >> >         ether 0c:5b:8f:27:9a:64  txqueuelen 1000  (Ethernet)
> >> >         RX packets 0  bytes 0 (0.0 B)
> >> >         RX errors 1493  dropped 0  overruns 0  frame 0
> >> >
> >> > Note the RX errors.. ?=20
> >>=20
> >>=20
> >> Yes, that is not expected and is quite possibly hiding the explana=
tion.
> >>=20
> >
> > Ok, good to know.
> >
> >> Could you do a usbmon dump to try to capture the contents of the U=
SB
> >> buffers we drop here?  See
> >> https://www.kernel.org/doc/Documentation/usb/usbmon.txt
> >>=20
> >> Note that the text interface may truncate the buffers too early fo=
r the
> >> result to be useful.  wireshark/thsark will for example allow you =
to
> >> capture the whole buffer (when snooping on the "usbmonX" interface=
 - not
> >> the netdev!)
> >>=20
> >
> > I'll try that..=20
> >
> >> We also have a few debug messages in the driver for different type=
s of
> >> errors we drop.  Turning on those might explain something (assumin=
g you
> >> have DYNAMIC_DEBUG enabled):
> >>=20
> >>   ethtool -s wwp0s26u1u5i1 msglvl rx_err on
> >>=20
> >> Note that these will be logged at "debug" level, so you need to tu=
rn on
> >> logging/showing such messages as well.
> >>=20
> >
> > # uname -a
> > Linux localhost.localdomain 3.13.6-200.fc20.x86_64 #1 SMP Fri Mar 7=
 17:02:28 UTC 2014 x86_64 x86_64 x86_64 GNU/Linux
> >
> > # grep -i DYNAMIC_DEBUG /boot/config-3.13.6-200.fc20.x86_64
> > CONFIG_DYNAMIC_DEBUG=3Dy
> >
> > # echo 8 > /proc/sys/kernel/printk
> > # cat /proc/sys/kernel/printk
> > 8       4       1       7
> >
> > # ethtool -s wwp0s26u1u5i1 msglvl rx_err on
> >
> > Is that enough?
>=20
> I believe so, but I don't feel too steady on all the dynamic-ness her=
e.
>=20
> > I don't see any errors logged in "dmesg" output,
> > but the RX errors counters do keep increasing in ifconfig output..=20
>=20
> OK, let's see if we can figure it out based on the usbmon data.
>=20

http://pasik.reaktio.net/huawei-e3276-usbmon3.pcapng

(I did move the dongle to a different usb bus nr 3 to make it the only =
device on that bus before capturing..)=20

So what I did:

- Start wireshark capture on USB bus nr 3.
- Plug in the Huawei E3276 dongle.
- Wait for usb_modeswitch to happen.
- Use minicom to talk to /dev/cdc-wdm0 and send AT commands to connect =
to Internet:
	- ATQ0 V1 E1 S0=3D0
	- AT^NDISDUP=3D1,1,"internet"

- After the dongle has connected query for DHCP status:
	- AT^DHCP?

- Launch dhcp client (dhclient) on wwp0s20u1i1 interface.
- Wait for a while and see RX error counters increasing on ifconfig out=
put.
- Cancel (ctrl+c) the dhclient.
- Stop wireshark capture.=20


Does that capture file show anything interesting to you?=20

>=20
>=20
> Bj=F8rn


Thanks,

-- Pasi
