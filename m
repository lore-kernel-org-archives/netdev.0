From: Dirkjan Ochtman <dirkjan@ochtman.nl>
Subject: Re: Problems with tg3 on BCM5720
Date: Thu, 27 Sep 2012 08:45:20 +0200
Message-ID: <CAKmKYaAWhTwucTP1joMcywv61ugi9gHNDGS3KaJjn6SLhvL5Dw@mail.gmail.com>
References: <CAKmKYaCBG5hURNomffgp9gRhS7g2BYsNG-LTmBrKsX-iyVzVxg@mail.gmail.com>
 <50636FEA.7080509@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Nithin Nayak Sujir <nsujir@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:54131 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751378Ab2I0Gpm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 02:45:42 -0400
Received: by qaas11 with SMTP id s11so618766qaa.19
        for <netdev@vger.kernel.org>; Wed, 26 Sep 2012 23:45:41 -0700 (PDT)
In-Reply-To: <50636FEA.7080509@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 26, 2012 at 11:13 PM, Nithin Nayak Sujir
<nsujir@broadcom.com> wrote:
> 1. Can you tell me the last patch that is included in the tg3 driver in
> 3.4.9 on your distro?

There are no tg3-specific patches in my distro's 3.4.9 package.

> 2. Can you give more info about the working setup?

The working setup is a simple small VLAN with a 192.168.1.0/24 subnet
and a few other Linux boxes on it (some of them also have BCM5720,
others have BCM5722 or BCM5709 networking). Not sure what other
information you'd want about this?

> 3. Was there any system reset or driver reload between the working and not
> working setups? Or was it just a cable switch?

Just a cable switch suffices to reproduce the problem we're seeing.

> 4. Please give the output of
> ethtool eth0
> ethtool -i eth0
> ethtool -k eth0

djc@jansky ~ $ sudo ethtool eth0
Settings for eth0:
	Supported ports: [ TP ]
	Supported link modes:   10baseT/Half 10baseT/Full
	                        100baseT/Half 100baseT/Full
	                        1000baseT/Half 1000baseT/Full
	Supported pause frame use: No
	Supports auto-negotiation: Yes
	Advertised link modes:  10baseT/Half 10baseT/Full
	                        100baseT/Half 100baseT/Full
	                        1000baseT/Half 1000baseT/Full
	Advertised pause frame use: Symmetric
	Advertised auto-negotiation: Yes
	Link partner advertised link modes:  10baseT/Half 10baseT/Full
	                                     100baseT/Half 100baseT/Full
	Link partner advertised pause frame use: No
	Link partner advertised auto-negotiation: Yes
	Speed: 100Mb/s
	Duplex: Full
	Port: Twisted Pair
	PHYAD: 1
	Transceiver: internal
	Auto-negotiation: on
	MDI-X: off
	Supports Wake-on: g
	Wake-on: d
	Current message level: 0x000000ff (255)
			       drv probe link timer ifdown ifup rx_err tx_err
	Link detected: yes
djc@jansky ~ $ sudo ethtool -i eth0
driver: tg3
version: 3.124
firmware-version: FFV7.2.14 bc 5720-v1.25
bus-info: 0000:01:00.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes
djc@jansky ~ $ sudo ethtool -k eth0
Offload parameters for eth0:
rx-checksumming: on
tx-checksumming: on
scatter-gather: off
tcp-segmentation-offload: off
udp-fragmentation-offload: off
generic-segmentation-offload: off
generic-receive-offload: on
large-receive-offload: off
rx-vlan-offload: on
tx-vlan-offload: on
ntuple-filters: off
receive-hashing: off

(Note that this is with my hacked up driver from the 3.6 tree, taken
from 185d4c8bf579322e1c2835d70729bc30f6f80f55, with
8d4057a938481351dc690fbe23e8c72af08d5890,
d3836f21b0af5513ef55701dd3f50b8c42e44c7a,
a1e8b307986ab27b7608f107aec71d3569650f46,
118008784965003307ea164370094c7d0810546e,
3f84749004925dd1e94025292fed5c76ce418516 reverted to make it compile
on 3.4.9.)

> 5. Can you run ethtool --test in the working setup?

Here's the ethtool --test result from eth1, which is currently plugged
into the VLAN (eth0 was plugged into it before; we also tried plugging
the external network into eth1, but that gave the same results as
plugging it into eth0).

djc@jansky ~ $ sudo ethtool --test eth1
The test result is PASS
The test extra info:
nvram test        (online) 	 0
link test         (online) 	 0
register test     (offline)	 0
memory test       (offline)	 0
mac loopback test (offline)	 0
phy loopback test (offline)	 0
ext loopback test (offline)	 0
interrupt test    (offline)	 0

> 6. I noticed in the syslog, the link is coming up at 100 Mbps. Is this
> expected?

No, I don't think so, it should be a Gbit line.

> 7. Does it fail immediately on connect to the data center switch? Or is it
> after some traffic goes through?

The vendor whose switch we're connecting to says they see that the
link is up, but they don't see a MAC attached. One of the things that
look weird to me is the ifconfig output saying "RX packets:513
errors:0 dropped:0 overruns:0 frame:0" but also "TX packets:0 errors:0
dropped:0 overruns:0 carrier:0".

On Wed, Sep 26, 2012 at 11:40 PM, Michael Chan <mchan@broadcom.com> wrote:
> It is most likely that the device eth0 is down.  The device needs to be
> up in order to perform all the tests that failed.  Please bring up the
> device and run the test again.  Thanks.

Right, sorry about that. Here's the results again, with the interface up:

djc@jansky ~ $ sudo ethtool --test eth0
The test result is FAIL
The test extra info:
nvram test        (online) 	 0
link test         (online) 	 0
register test     (offline)	 0
memory test       (offline)	 0
mac loopback test (offline)	 0
phy loopback test (offline)	 5
ext loopback test (offline)	 0
interrupt test    (offline)	 0

Hope that helps,

Dirkjan
