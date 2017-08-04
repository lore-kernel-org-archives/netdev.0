From: Benoit Panizzon <benoit.panizzon@imp.ch>
Subject: Realtek r8169 driver VLAN TAG stripping / offloading
Date: Fri, 4 Aug 2017 13:55:13 +0200
Message-ID: <20170804135513.4606462f@go.imp.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from thor.imp.ch ([157.161.4.18]:22531 "EHLO thor.imp.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752161AbdHDMFt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Aug 2017 08:05:49 -0400
Received: from go.imp.ch (go.imp.ch [157.161.4.87])
        by thor.imp.ch (8.15.2/8.13.3) with ESMTPS id v74BtDoa074915
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NO)
        for <netdev@vger.kernel.org>; Fri, 4 Aug 2017 13:55:13 +0200 (CEST)
        (envelope-from benoit.panizzon@imp.ch)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

Yes, someone posted the same problem a couple of years ago:
https://www.spinics.net/lists/netdev/msg152505.html

But as far as I have read the thread, nobody figured out the problem.

I have run in the same strange problem, where I suspect either a driver
of firmware bug, after upgrading a system from kernel 3.16 (whatever
subversion debian used) to the actual: 4.9.30-2+deb9u2

I use native and untagged vlan.

The two ports on the Cisco Switch have this config:

 switchport trunk encapsulation dot1q
 switchport trunk native vlan 3
 switchport trunk allowed vlan 2,3
 switchport mode trunk

So for outgoing packets (switch => Linux) with vlan id 3 that id is
stripped and for ingress packets without tag, vlan id 3 is added.

Packets with vlan id 2 are passed unaltered between switch and linux
box.

Now I have two machines with slightly different r8169 NIC:

01:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
RTL8111/8168/8411 PCI Express Gigabit Ethernet Controller (rev 02)

=> This one works fine

And

03:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
RTL8111/8168/8411 PCI Express Gigabit Ethernet Controller (rev 09)

=> This one stripps all ingress vlan tags!

Both use the exact same kernel version.

On rev 02 I don't bother to load the firmware, it works fine without.
On the rev 09 one I did try with and without firmware, no difference.

Observation:

Packets generated on linux on vlan id 2 are sent out to the switch
containing the vlan tag.

Packets which leave the switch with vlan id 2 loose this id after being
processed by the r8169 driver and therefore do not make it out of the
vlan interface on linux.

As an example, the same ARP packet capture on the rev 02 and the rev 09
NIC:

13:51:05.955414 4c:5e:0c:41:0c:83 > ff:ff:ff:ff:ff:ff, ethertype 802.1Q
(0x8100), length 64: vlan 2, p 0, ethertype ARP, Request who-has
157.161.6.10 tell 157.161.6.1, length 46

=> This is fine, see vlan 2?

13:51:05.957652 4c:5e:0c:41:0c:83 > ff:ff:ff:ff:ff:ff, ethertype 802.1Q
(0x8100), length 64: vlan 0, p 0, ethertype ARP, Request who-has
157.161.6.10 tell 157.161.6.1, length 46

=> Wrong vlan tag!

# ethtool -k eth0
Features for eth0:
rx-checksumming: on
tx-checksumming: off
        tx-checksum-ipv4: off
        tx-checksum-ip-generic: off [fixed]
        tx-checksum-ipv6: off
        tx-checksum-fcoe-crc: off [fixed]
        tx-checksum-sctp: off [fixed]
scatter-gather: off
        tx-scatter-gather: off
        tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: off
        tx-tcp-segmentation: off
        tx-tcp-ecn-segmentation: off [fixed]
        tx-tcp-mangleid-segmentation: off
        tx-tcp6-segmentation: off
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: off [requested on]
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: on
tx-vlan-offload: on
ntuple-filters: off [fixed]
receive-hashing: off [fixed]
highdma: on [fixed]
rx-vlan-filter: off [fixed]
vlan-challenged: off [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: off [fixed]
tx-gre-csum-segmentation: off [fixed]
tx-ipxip4-segmentation: off [fixed]
tx-ipxip6-segmentation: off [fixed]
tx-udp_tnl-segmentation: off [fixed]
tx-udp_tnl-csum-segmentation: off [fixed]
tx-gso-partial: off [fixed]
tx-sctp-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: off
loopback: off [fixed]
rx-fcs: off
rx-all: off
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
l2-fwd-offload: off [fixed]
busy-poll: off [fixed]
hw-tc-offload: off [fixed]

I have been trying to turn 'off' rx-vlan-offload and tx-vlan-offload
with ethtool, but I don't succeed.

As I suppose the problem was introduced somewhen between kernel 3.16
and 4.9 I will be trying to reboot with 3.16 tonight when I have
physical access to the machine.

Any hints on what could cause the problem or how I could further debug
it, is highly welcome.

-Benoît Panizzon-
-- 
I m p r o W a r e   A G    -    Leiter Commerce Kunden
______________________________________________________

Zurlindenstrasse 29             Tel  +41 61 826 93 00
CH-4133 Pratteln                Fax  +41 61 826 93 01
Schweiz                         Web  http://www.imp.ch
______________________________________________________
