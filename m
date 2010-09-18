From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: E1000E/82567LM-3: link reported up too soon
Date: Sat, 18 Sep 2010 16:14:16 +0200
Message-ID: <87bp7vnnpj.fsf@small.ssi.corp>
References: <87eicvi0cz.fsf@small.ssi.corp> <4C90E11B.7020807@hp.com>
	<87pqwff2bd.fsf@small.ssi.corp> <4C90EDF3.8010401@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from copper.chdir.org ([88.191.97.87]:60643 "EHLO copper.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755290Ab0IROOU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Sep 2010 10:14:20 -0400
In-Reply-To: <4C90EDF3.8010401@hp.com> (Brian Haley's message of "Wed, 15 Sep
	2010 12:01:55 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Brian and David,                         [removed Intel people from CC]

Brian Haley <brian.haley@hp.com> writes:

>> I am not familiar with e1000e code but as I said previously I'd be happy
>> to test patches to help determine precisely where the packet gets lost
>> and why.
>
> I'm not either, the patches I've tried are all for IPv6.

I definitely think the issue is not chipset-specific (keep reading) and
that it is not just a matter of few milliseconds. It also not
IPv6-specific. 

I spent some additional time on it in userspace. I implemented a
*workaround* in UMIP to allow configuration of a per-interface
additional delay before sending RS after a link up event. I initially
thought few milliseconds would be sufficient. It is not. Obviously, this
gets better when delay is increased but still.

I progressively increased the value until RS is no more dropped. Below,
UMIP is configured to send RS only *550ms* after the RTM_NEWLINK event
(indicating link is up and running event) is received and the packet is
still dropped locally. Note that the IPv4 DHCP Request below is sent as
soon as link gets up to show the time difference (RS is indeed sent
550ms later):

15:12:32.728429 ethertype IPv4 (0x0800), length 342: 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request
15:12:33.256201 ethertype IPv6 (0x86dd), length 62: :: > ff02::2: ICMP6, router solicitation, length 8
15:12:35.729668 ethertype IPv4 (0x0800), length 342: 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request
15:12:35.741238 ethertype IPv4 (0x0800), length 590: 192.168.0.254.67 > 192.168.0.16.68: BOOTP/DHCP, Reply

The switch is a 5 ports Planex gigabit switch connected to the 82567LM-3
on my Dell E4300 (negotiated 1000baseT-FD flow-control, link ok). Still
on a 2.6.35.4 kernel.

Then, I decided to test with a totally different kind of ethernet
interface. An USB2 Ethernet 10/100 dongle. Here is what lsusb reports
about it:

Bus 002 Device 003: ID 0411:003d MelCo., Inc. LUA-U2-KTX Ethernet

Below, UMIP is configured w/o any additional delay before RS emission on
that interface. No DHCP running either:

15:40:22.984311 ethertype IPv6 (0x86dd), length 62: :: > ff02::2: ICMP6, router solicitation, length 8
15:40:26.984845 ethertype IPv6 (0x86dd), length 62: :: > ff02::2: ICMP6, router solicitation, length 8
15:40:26.989264 ethertype IPv6 (0x86dd), length 158: fe80::224:d5ff:fed4:476c > ff02::1: ICMP6, router advertisement

David, any idea on where this may come from and how to track the cause?

Cheers,

a+
