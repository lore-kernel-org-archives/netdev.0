From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: Is this 32-bit NCM?y
Date: Thu, 04 Dec 2014 12:44:56 +0100
Message-ID: <877fy7myfb.fsf@nemi.mork.no>
References: <AMSPR06MB6011E001029C251790CB923EE780@AMSPR06MB601.eurprd06.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Enrico Mioso <mrkiko.rs@gmail.com>,
	Kevin Zhu <Mingying.Zhu@audiocodes.com>,
	Eli Britstein <Eli.Britstein@audiocodes.com>,
	Alex Strizhevsky <alexxst@gmail.com>,
	"youtux\@gmail.com" <youtux@gmail.com>,
	"linux-usb\@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: "Midge Shaojun Tan" <ShaojunMidge.Tan@audiocodes.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:56388 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753385AbaLDLpO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 06:45:14 -0500
In-Reply-To: <AMSPR06MB6011E001029C251790CB923EE780@AMSPR06MB601.eurprd06.prod.outlook.com>
	(Midge Shaojun Tan's message of "Thu, 4 Dec 2014 10:10:16 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Midge Shaojun  Tan" <ShaojunMidge.Tan@audiocodes.com> writes:

> Hi all,
>
> I test OK with kervel 3.16.4
> Need disable other Ethernet network, just like eth1. (Then the DNS an=
d route is OK)
> And also need disable arp, (ifconfig wwan0 -arp up), because China UN=
ICOM don't respond the ARP message.

The ARP functionality is independent of operator.  It is handled
internally by the modem firmware.  There are no MAC addresses or
ethernet headers transmitted over the radio link.  That's all faked by
the modem.  All MAC addresses and ethernet headers are local to the
modem<->host USB link.

> With new mode switch string: /etc/usb_modeswitch.d/12d1:14fe
> Please see the patch and check whether it is correct?

I see that you have two changes there:

1) the ETH_HLEN adjustment of ctx->tx_remainder is dropped
2) the NDP is placed after the first frame.

I haven't verified the effect of the tx_remainder change, but I assume
it fixes an alignment problem for this device.  I'd like to look more a=
t
the effect of this for different values of wNdpOutPayloadRemainder and
wNdpOutDivisor.

We can choose to put the NDP at the end of the NTB if we find that this
fixes some problem, but doing so by default for every NCM and MBIM
device is a bit risky. If we accept that some devices are so buggy that
the NDP cannot be placed anywhere (as required by the spec), then we
have to assume that this goes both ways.  Which means that moving the
NDP to the end of the NTB might break some other device.  We just don't
know that since we haven't ever tried it.

And your fix doesn't really move it to the end either.  It just places
the NDP after the first ethernet packet.  Which happens to be the end i=
f
there is only one packet in the NTB. But if we aggregate more packets
into this NTB then the result will look like this:

 NTH
 eth packet 1
 NDP
 eth packet 2
 ..
 eth packet N

I'm not convinced this modem will handle that if it cannot handle the
NDP being before the first packet...  This needs to be tested.  Try
increasing /sys/class/net/wwan0/cdc_ncm/tx_timer_usecs to force the
driver to aggregate packets and see if everything still works.
Preferably while looking at the resulting NTB to verify that it does
contain more than one ethernet packet.

I realize I sound a bit negative now.  This is absolutely not my
intention. This is great work, providing some real progress wrt figurin=
g
out what goes on here.  Thanks a lot!  I am sure we can sort out the
remaining issues, which are really minor compared to what you have foun=
d
so far.



Bj=C3=B8rn
