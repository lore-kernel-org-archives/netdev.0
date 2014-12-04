From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: Re: Is this 32-bit NCM?y
Date: Thu, 4 Dec 2014 13:17:17 +0100 (CET)
Message-ID: <alpine.LNX.2.03.1412041302260.9926@gmail.com>
References: <AMSPR06MB6011E001029C251790CB923EE780@AMSPR06MB601.eurprd06.prod.outlook.com> <877fy7myfb.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-1850245393-1417695440=:9926"
Cc: Midge Shaojun Tan <ShaojunMidge.Tan@audiocodes.com>,
	Kevin Zhu <Mingying.Zhu@audiocodes.com>,
	Eli Britstein <Eli.Britstein@audiocodes.com>,
	Alex Strizhevsky <alexxst@gmail.com>,
	"youtux@gmail.com" <youtux@gmail.com>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:63363 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753531AbaLDMQr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 07:16:47 -0500
In-Reply-To: <877fy7myfb.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-1850245393-1417695440=:9926
Content-Type: TEXT/PLAIN; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8BIT




On Thu, 4 Dec 2014, Bjørn Mork wrote:

> "Midge Shaojun  Tan" <ShaojunMidge.Tan@audiocodes.com> writes:
>
>> Hi all,
>>
>> I test OK with kervel 3.16.4
>> Need disable other Ethernet network, just like eth1. (Then the DNS and route is OK)
>> And also need disable arp, (ifconfig wwan0 -arp up), because China UNICOM don't respond the ARP message.
>
> The ARP functionality is independent of operator.  It is handled
> internally by the modem firmware.  There are no MAC addresses or
> ethernet headers transmitted over the radio link.  That's all faked by
> the modem.  All MAC addresses and ethernet headers are local to the
> modem<->host USB link.
>
>> With new mode switch string: /etc/usb_modeswitch.d/12d1:14fe
>> Please see the patch and check whether it is correct?
>
> I see that you have two changes there:
>
> 1) the ETH_HLEN adjustment of ctx->tx_remainder is dropped
> 2) the NDP is placed after the first frame.
>
> I haven't verified the effect of the tx_remainder change, but I assume
> it fixes an alignment problem for this device.  I'd like to look more at
> the effect of this for different values of wNdpOutPayloadRemainder and
> wNdpOutDivisor.
>
> We can choose to put the NDP at the end of the NTB if we find that this
> fixes some problem, but doing so by default for every NCM and MBIM
> device is a bit risky. If we accept that some devices are so buggy that
> the NDP cannot be placed anywhere (as required by the spec), then we
> have to assume that this goes both ways.  Which means that moving the
> NDP to the end of the NTB might break some other device.  We just don't
> know that since we haven't ever tried it.

Guys - this is a little hard moment for my life, so sorry if I sound negative 
too, really. No humor here.

Bjorn, I am starting to think that we might need to (sadly) differentiate how
we threat "standard" NCM devices in respect to Huawei ones, a little bit more.
As you said - changing the handling in any way would be too risky - and
definitely, I am starting to think that different firmware versions have
different bugs in this regard (might be not in NCM handling itself, but in
respect to other areas, like ARP handling / faking ).
At the end we might come out with a good enough solution - but we would start 
to complicate things more and more, and definitely we might end up complicating
more and more the driver itself. At some point, we might also end up finding 
out that we need a different workarounds for different firmwares, not even 
compatible one another.
so - my idea, that is hypotetical:
1 - Factorize out cdc_ncm more
2 - Creating new {tx,rx}_fixup routines applying different workarounds.

then, when the need to apply different workarounds for difference device (or 
firmware versions) arise, we might also think of a way to communicate to the 
driver the firmware version, allowing it to select some quirks to apply.
What do you all think about it?

> And your fix doesn't really move it to the end either.  It just places
> the NDP after the first ethernet packet.  Which happens to be the end if
> there is only one packet in the NTB. But if we aggregate more packets
> into this NTB then the result will look like this:
>
> NTH
> eth packet 1
> NDP
> eth packet 2
> ..
> eth packet N
>
> I'm not convinced this modem will handle that if it cannot handle the
> NDP being before the first packet...  This needs to be tested.  Try
> increasing /sys/class/net/wwan0/cdc_ncm/tx_timer_usecs to force the
> driver to aggregate packets and see if everything still works.
> Preferably while looking at the resulting NTB to verify that it does
> contain more than one ethernet packet.
>
> I realize I sound a bit negative now.  This is absolutely not my
> intention. This is great work, providing some real progress wrt figuring
> out what goes on here.  Thanks a lot!  I am sure we can sort out the
> remaining issues, which are really minor compared to what you have found
> so far.
>
>
>
> Bjørn
>
>
I'll test this now.
--8323328-1850245393-1417695440=:9926--
