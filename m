From: Thomas Habets <thomas@habets.pp.se>
Subject: Re: BUG: IPv6 stops working after a while, needs ip ne del command
 to reset
Date: Wed, 1 Sep 2010 11:21:43 +0200 (CEST)
Message-ID: <alpine.DEB.1.10.1009011034560.31938@red.crap.retrofitta.se>
References: <1282024802.2487.687.camel@edumazet-laptop> <alpine.DEB.1.10.1008171053230.21857@red.crap.retrofitta.se> <1282050920.2448.47.camel@edumazet-laptop> <alpine.DEB.1.10.1008171547090.21857@red.crap.retrofitta.se> <1282055659.2448.58.camel@edumazet-laptop>
 <alpine.DEB.1.10.1008171737260.21857@red.crap.retrofitta.se> <20100817171115.GA4134@mcarlson.broadcom.com> <alpine.DEB.1.10.1008171928160.21857@red.crap.retrofitta.se> <20100817183112.GA4351@mcarlson.broadcom.com> <alpine.DEB.1.10.1008172035520.21857@red.crap.retrofitta.se>
 <20100818012318.GA4630@mcarlson.broadcom.com> <alpine.DEB.1.10.1008180900350.21857@red.crap.retrofitta.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Matt Carlson <mcarlson@broadcom.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>
To: Thomas Habets <thomas@habets.pp.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from reptilian.habets.pp.se ([193.151.93.131]:1629 "EHLO
	reptilian.habets.pp.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751274Ab0IAJVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 05:21:55 -0400
In-Reply-To: <alpine.DEB.1.10.1008180900350.21857@red.crap.retrofitta.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I've continued this a bit off-list but thought I would summarize for the 
archives.


Summary
-------
It looks like a firmware issue on the network card. When ILO is enabled it 
shares the first network card with the OS. When it does this multicast 
is broken. When multicast (on a L2 level) is broken IPv6 neighbor 
discovery breaks. Only eth0 breaks, eth1 is unaffected.


System
------
HP Proliant DL320 G5p
Xeon 3GHz
1GB RAM
Arch: amd64
NIC: Broadcom Corporation NetXtreme BCM5715 Gigabit Ethernet (rev a3)
Debian Lenny (5.0.5)
Kernels: 2.6.35 mainline, 2.6.33.6
Config: http://pastebin.com/raw.php?i=Y6S8iKW7


Problem
-------
Buggy box will not answer IPv6 ND or ping to ff02::1. May work at some 
point in the boot process, but once box is fully booted it does not.

If I on the neighboring Cisco router run "clear ipv6 neighbors" (or it 
times out) that router cannot re-acquire the neigborship with the buggy 
box. Instant IPv6 breakage until I do one of:
* Turn on promisc mode long enough for IPv6 ND to do its thing
* ip ne del <address of neighbor> on the buggy host.


Workarounds
-----------
Either one of these will hide the problem:
* Set promisc mode on interface (ip link set promisc on eth0) forever
* Disable ILO
* Use eth1 instead of eth0.


Troubleshooting
---------------
Got patch for kernel from Eric Dumazet (eric.dumazet@gmail.com) to output 
what MAC addresses are being subscribed to, and some registers from the 
card. Output is earlier in this thread, along with "ethtool -i eth0" and 
some other data.

Managed to get diagnostic tool[1] booting from stick (no CD drive in 
server), but did not set up memory (himem.sys etc..). Running b57udiag 
it therefore failed due to insufficient memory at test "Group D. Driver 
Associated tests". Card is assumed to be OK anyway.

Matt Carlson (mcarlson@broadcom.com) suspected firmware bug and asked me 
to try disabling ASF and/or IPMI using the diagnostic tool, but running 
"setasf -d" and "setipmi -d" inside "b57udiag -cmd" did not seem to stick 
across reboot. It stuck properly before reboot (confirmed with setasf -q). 
Also tried "b57udiag -u 0". Tried both C-A-D reboot and powercycling (by 
power cord).

At boot Linux still said ASF[1] for eth0 and ASF[0] for eth1:
tg3 0000:03:04.0: eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[1] TSOcap[1]
tg3 0000:03:04.1: eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[1]
(this output never changed throughout the process)
ethtool -d eth1 | grep 0x047 did not change either.

Then I disabled ILO and PXE in ILO bios and BIOS respectively. That fixed 
it. eth0 now works with multicast.

I don't use ILO on this server so in this case that fixes it for me, but 
the bug is still there.

At this point Matt thinks I should file a bug report with HP. I will 
attempt to do that.

I have more detailed logs of what I did and when, and what the effect was.


Related
-------
May be the same issue as this:
   https://bugs.launchpad.net/ubuntu/+source/linux/+bug/263260
Which means it's the same with Ubuntu kernels 2.6.26.3, 2.6.26-5-generic 
and 2.6.27-2-generic, and mainline kernels 2.6.25, 2.6.26 and 2.6.27.


[1] http://www.broadcom.com/support/ethernet_nic/netxtreme_server.php

---------
typedef struct me_s {
   char name[]      = { "Thomas Habets" };
   char email[]     = { "thomas@habets.pp.se" };
   char kernel[]    = { "Linux" };
   char *pgpKey[]   = { "http://www.habets.pp.se/pubkey.txt" };
   char pgp[] = { "A8A3 D1DD 4AE0 8467 7FDE  0945 286A E90A AD48 E854" };
   char coolcmd[]   = { "echo '. ./_&. ./_'>_;. ./_" };
} me_t;
