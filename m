From: Dave Johnson <djohnson+linux-kernel@sw.starentnetworks.com>
Subject: expected behavior of PF_PACKET on NETIF_F_HW_VLAN_RX device?
Date: Wed, 31 Oct 2007 14:43:51 -0400
Message-ID: <18216.52455.698606.497464@zeus.sw.starentnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Bin Guo <bguo@sw.starentnetworks.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756887AbXJaSoQ@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Depending on the network driver, I'm seeing different behavior if
a .1q packet is received to an PF_PACKET, SOCK_RAW, ETH_P_ALL socket.


On devices what do not use NETIF_F_HW_VLAN_RX, the packet socket gets
the complete packet with vlan tag included as the driver simply calls
netif_receive_skb() or equivilant.  packet_rcv() then gets the whole
thing vlan tag included and sends this through the socket.

vlan_skb_recv() also gets these all and will drop them because there
are no vlans configured.

Example, e100 driver gives this to tcpdump:

# ifconfig eth1 up
# tcpdump -s 2000 -e -n -i eth1
tcpdump: WARNING: eth1: no IPv4 address assigned
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth1, link-type EN10MB (Ethernet), capture size 2000 bytes
14:11:03.707178 00:0b:82:05:22:0a > ff:ff:ff:ff:ff:ff, ethertype 802.1Q (0x8100), length 64: vlan 101, p 0, ethertype ARP, arp who-has 192.168.101.191 tell 192.168.101.131
14:11:04.215164 00:0b:82:05:22:05 > ff:ff:ff:ff:ff:ff, ethertype 802.1Q (0x8100), length 64: vlan 101, p 0, ethertype ARP, arp who-has 192.168.101.191 tell 192.168.101.130
14:11:04.658940 00:0b:82:05:22:0c > ff:ff:ff:ff:ff:ff, ethertype 802.1Q (0x8100), length 64: vlan 101, p 0, ethertype ARP, arp who-has 192.168.101.191 tell 192.168.101.135
14:11:05.706070 00:0b:82:05:22:0a > ff:ff:ff:ff:ff:ff, ethertype 802.1Q (0x8100), length 64: vlan 101, p 0, ethertype ARP, arp who-has 192.168.101.191 tell 192.168.101.131
14:11:05.939195 00:b0:c2:e8:d8:1c > 33:33:00:00:00:01, ethertype 802.1Q (0x8100), length 122: vlan 108, p 0, ethertype IPv6, fe80::2b0:c2ff:fee8:d81c > ff02::1: icmp6: router advertisement [class 0xe0]
14:11:07.222302 00:b0:c2:e8:d8:1c > 33:33:00:00:00:01, ethertype 802.1Q (0x8100), length 122: vlan 110, p 0, ethertype IPv6, fe80::2b0:c2ff:fee8:d81c > ff02::1: icmp6: router advertisement [class 0xe0]
14:11:08.486953 00:b0:c2:e8:d8:1c > 01:00:5e:00:00:05, ethertype 802.1Q (0x8100), length 134: vlan 110, p 0, ethertype IPv4, IP 192.168.110.20 > 224.0.0.5: OSPFv2, Hello (1), length: 80
14:11:11.528569 00:30:48:22:63:50 > ff:ff:ff:ff:ff:ff, ethertype 802.1Q (0x8100), length 154: vlan 208, p 0, ethertype IPv4, IP 195.180.3.200.33350 > 195.180.3.255.111: UDP, length: 108
14:11:12.642762 00:0b:82:05:22:05 > ff:ff:ff:ff:ff:ff, ethertype 802.1Q (0x8100), length 64: vlan 101, p 0, ethertype ARP, arp who-has 192.168.101.191 tell 192.168.101.130
14:11:12.642766 00:0b:82:05:22:05 > ff:ff:ff:ff:ff:ff, ethertype 802.1Q (0x8100), length 64: vlan 101, p 0, ethertype ARP, arp who-has 192.168.101.191 tell 192.168.101.130

The packet socket gets everything including the vlan tag as I'd
expect.


But on the bnx2 driver (for example) I get 2 different behaviors:

1)

If no vlan interfaces are configured, it calls netif_receive_skb()
because there isn't a vlan group registered via
bnx2_vlan_rx_register().

# ifconfig eth1 up
# tcpdump -s 2000 -e -n -i eth1
tcpdump: WARNING: eth1: no IPv4 address assigned
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth1, link-type EN10MB (Ethernet), capture size 2000 bytes
14:21:27.170505 00:0b:82:05:22:05 > ff:ff:ff:ff:ff:ff, ethertype ARP (0x0806), length 60: arp who-has 192.168.101.191 tell 192.168.101.130
14:21:27.170577 00:0b:82:05:22:05 > ff:ff:ff:ff:ff:ff, ethertype ARP (0x0806), length 60: arp who-has 192.168.101.191 tell 192.168.101.130
14:21:27.495814 00:0b:82:05:22:0c > ff:ff:ff:ff:ff:ff, ethertype ARP (0x0806), length 60: arp who-has 192.168.101.191 tell 192.168.101.135
14:21:27.495881 00:0b:82:05:22:0c > ff:ff:ff:ff:ff:ff, ethertype ARP (0x0806), length 60: arp who-has 192.168.101.191 tell 192.168.101.135
14:21:28.151070 00:0b:82:05:22:05 > ff:ff:ff:ff:ff:ff, ethertype ARP (0x0806), length 60: arp who-has 192.168.101.191 tell 192.168.101.130
14:21:28.166780 00:b0:c2:e8:d8:1c > 33:33:00:00:00:01, ethertype IPv6 (0x86dd), length 118: fe80::2b0:c2ff:fee8:d81c > ff02::1: icmp6: router advertisement [class 0xe0]
14:21:28.476404 00:0b:82:05:22:0c > ff:ff:ff:ff:ff:ff, ethertype ARP (0x0806), length 60: arp who-has 192.168.101.191 tell 192.168.101.135
14:21:28.492099 00:b0:c2:e8:d8:1c > 01:00:5e:00:00:05, ethertype IPv4 (0x0800), length 130: IP 192.168.110.20 > 224.0.0.5: OSPFv2, Hello (1), length: 80
14:21:28.631439 00:19:b9:e7:8a:d7 > 33:33:ff:e7:8a:d7, ethertype IPv6 (0x86dd), length 78: :: > ff02::1:ffe7:8ad7: icmp6: neighbor sol: who has fd4d:5643:2886:67:219:b9ff:fee7:8ad7
14:21:28.671611 00:0b:82:05:22:0a > ff:ff:ff:ff:ff:ff, ethertype ARP (0x0806), length 60: arp who-has 192.168.101.191 tell 192.168.101.131
14:21:28.671684 00:0b:82:05:22:0a > ff:ff:ff:ff:ff:ff, ethertype ARP (0x0806), length 60: arp who-has 192.168.101.191 tell 192.168.101.131

the packet handed to netif_receive_skb() does not have the vlan tag on
it.  this allows all these packets to be processed by not only the
packet ptype handler, but also ip, arp, etc... this seems very wrong
as all vlan packets are stripped of their tag, then processed by the
kernel as if they didn't have a tag to begin with.

Normally vlan_skb_recv() would be the only handler to get these
packets, but ip_rcv(), arp_rcv(), ipv6_rcv() etc.. can be called
instead!

ipv6 for example will pay attention to router advertisements and add
global scope addresses to the base device even though those packets
came in on a vlan that would otherwise be ignored.

the packet socket recipient also has no idea which vlan each packet
came in on.


2)

If there is one or more vlan interfaces configured, it calls
vlan_hwaccel_receive_skb().  

# ifconfig eth1 up  
# vconfig add eth1 300
# ifconfig eth1.300 up
# tcpdump -s 2000 -e -n -i eth1
tcpdump: WARNING: eth1: no IPv4 address assigned
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth1, link-type EN10MB (Ethernet), capture size 2000 bytes
[Nothing....]

when vlan_hwaccel_receive_skb() gets the packets it discards
everything except vid 300 that I configured above.

Shouldn't it pass these unknown vids back to the base device as tagged
packets, especially if IFF_PROMISC is set?


What is the expected behavior for these?  Should
vlan_hwaccel_receive_skb() shim a vlan tag back on the packet and send
it to the base device if there is no vlan device to send to?  Also, is
it up to the individual driver to have a vlan tag on the packet if it
uses netif_receive_skb() as in case 1 above?


-- 
Dave Johnson
Starent Networks
