From: "Ruslan N. Marchenko" <me@ruff.mobi>
Subject: 802.1Q VLAN random tag injected when vlan configured on forcedeth
 interface
Date: Tue, 30 Aug 2011 14:51:11 +0200
Message-ID: <20110830125111.GA28341@ruff.mobi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ip-89-176-12-106.net.upcbroadband.cz ([89.176.12.106]:35664
	"EHLO ruff.mobi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752045Ab1H3M51 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 08:57:27 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi guys,
I've faced with strange behaviour of 8021q driver: when enabling vlan subinterface on eth interface I'm getting ~50% packetloss due to packets are marked with incorrect tags (and eventually dropped by kernel since no vlans configured for such IDs).
Scenario:
[    0.476950] cpufreq-nforce2: No nForce2 chipset.
[    1.519133] forcedeth: Reverse Engineered nForce ethernet driver. Version 0.64.
[    1.519991] forcedeth 0000:00:0a.0: PCI INT A -> Link[LMAC] -> GSI 22 (level, low) -> IRQ 22
[    1.520037] forcedeth 0000:00:0a.0: setting latency timer to 64
[    1.586526] forcedeth 0000:00:0a.0: ifname eth0, PHY OUI 0x732 @ 3, addr 00:26:18:40:21:61
[    1.586542] forcedeth 0000:00:0a.0: highdma csum pwrctl gbit lnktim msi desc-v3

modprobe 8021q

- network still works properly, packets are comming not marked at all.

ip li add link eth0 name vl6 type vlan id 6

- from this moment massive packetdrop starting to happen, almost half of the *incoming* packets are shown in tcpdump as 
14:15:52.859296 00:13:f7:1e:fe:e4 > 00:26:18:40:21:61, ethertype 802.1Q (0x8100), length 102: vlan 64, p 3, ethertype IPv4, [|ip]
14:15:56.869572 00:13:f7:1e:fe:e4 > 00:26:18:40:21:61, ethertype 802.1Q (0x8100), length 102: vlan 2112, p 7, ethertype IPv4, [|ip]

mostly only these two tags appears (64 & 2112). Moreover this happens as on native vlan level (pure ethernet) so on tagged subinterface (as if qinq double tagging) for properly tagged with ID 6 incomming packets.

I've tried disabling all offloads:

Offload parameters for eth0:
rx-checksumming: off
tx-checksumming: off
scatter-gather: off
tcp-segmentation-offload: off
udp-fragmentation-offload: off
generic-segmentation-offload: off
generic-receive-offload: off
large-receive-offload: off
rx-vlan-offload: off
tx-vlan-offload: off
ntuple-filters: off
receive-hashing: off

- doesn't have any effect.
Once executing 
ip li del vl6 type vlan
misterious tags disappear and everything works smoothly. Don't know who injects that garbage into frames - 8021q or forcedeth driver :(
Any ideas or suggestions to narrow the problem down?

Additional data.
Link level data dump example for broken frame:
12:35:32.175523 00:13:f7:1e:fe:e4 > 00:26:18:40:21:61, ethertype 802.1Q (0x8100), length 102: vlan 2112, p 2, ethertype IPv4, [|ip]
        0x0000:  0026 1840 2161 0013 f71e fee4 8100 4840
        0x0010:  0800 4500 0054 7a12 0000 4001 eb0f
0x0C-0D - TPID: ethertype 802.1Q (0x8100) 
0x0E-0F - TCI (0100100001000000) PCP 010, CFI 0, VID 100001000000/0x840/2112
0x10-11 - ethertype IPv4
normal ping reply follows, which appears untagged in 50% cases with vlan configured and 100% cases without.

Interface is plugged into openwrt box into non-switched (wan) gigabit port with vid 6 subinterface configured.

Regards,
Ruslan
