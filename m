From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6 V3] net: convert bonding to use rx_handler
Date: Tue, 22 Feb 2011 00:20:04 +0100
Message-ID: <4D62F324.6020301@gmail.com>
References: <21593.1298070371@death> <20110219080523.GB2782@psychotron.redhat.com> <4D5FA1D7.4050801@gmail.com> <20110219110830.GD2782@psychotron.redhat.com> <20110219112842.GE2782@psychotron.redhat.com> <4D5FC308.9020507@gmail.com> <20110219134645.GF2782@psychotron.redhat.com> <4D6027B9.6050108@gmail.com> <20110220103609.GA2750@psychotron.redhat.com> <4D610511.4050902@gmail.com> <20110220150710.GB2750@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, andy@greyhouse.net,
	"Fischer, Anna" <anna.fischer@hp.com>
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f51.google.com ([209.85.214.51]:58424 "EHLO
	mail-bw0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750756Ab1BUXUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Feb 2011 18:20:09 -0500
Received: by bwz10 with SMTP id 10so2637185bwz.10
        for <netdev@vger.kernel.org>; Mon, 21 Feb 2011 15:20:08 -0800 (PST)
In-Reply-To: <20110220150710.GB2750@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 20/02/2011 16:07, Jiri Pirko a =E9crit :
> Sun, Feb 20, 2011 at 01:12:01PM CET, nicolas.2p.debian@gmail.com wrot=
e:

[snip]

>> And thinking about all this, I wonder what the protocol handlers exp=
ect as the orig_dev value ?
>>
>> Lets imagine the following configuration: eth0 ->  bond0 ->  br0.
>>
>> What does a protocol handler listening on br0 expect for orig_dev ?
>> bond0 or eth0 ? Current implementation give eth0, but I think bond0
>> should be the right value, for proper nesting.
>
> I agree with you.

[snip}

>>> This hook is something I do not like at all :/ But anyway if should=
 be in vlan
>>> part I think.
>>
>> Yes, and in order for the future rx_handler for vlan to properly
>> handle it, it needs to know the device just below it, not the pure
>> original device. Hence, my question about the exact meaning of
>> orig_dev...

After checking every protocol handlers installed by dev_add_pack(), it =
appears that only 4 of them=20
really use the orig_dev parameter given by __netif_receive_skb():

- bond_3ad_lacpdu_recv() @ drivers/net/bonding/bond_3ad.c
- bond_arp_recv() @ drivers/net/bonding/bond_main.c
- packet_rcv() @ net/packet/af_packet.c
- tpacket_rcv() @ net/packet/af_packet.c

 From the bonding point of view, the meaning of orig_dev is obviously "=
the device one layer below=20
the bonding device, through which the packet reached the bonding device=
". It is used by=20
bond_3ad_lacpdu_recv() and bond_arp_recv(), to find the underlying slav=
e device through which the=20
LACPDU or ARP was received. (The protocol handler is registered at the =
bonding device level).

 From the af_packet point of view, the meaning is documented (in commit=
 "[AF_PACKET]: Add option to=20
return orig_dev to userspace") as the "physical device [that] actually =
received the traffic, instead=20
of having the encapsulating device hide that information."

When the bonding device is just one level above the physical device, th=
e two meanings happen to=20
match the same device, by chance.

So, currently, a bonding device cannot stack properly on top of anythin=
g but physical devices. It=20
might not be a problem today, but may change in the future...

	Nicolas.






