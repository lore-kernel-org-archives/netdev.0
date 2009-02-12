From: Karl Hiramoto <karl@hiramoto.org>
Subject: problem with IPoA (CLIP),  NAT, and VLANS
Date: Thu, 12 Feb 2009 14:28:41 +0100
Message-ID: <49942409.4080506@hiramoto.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org, netfilter@vger.kernel.org
Return-path: <netfilter-owner@vger.kernel.org>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

   
Hi all,

I have a scenario with  CLIP  IPoA(RFC1577) atm link over ADSL on the
WAN, 801.1q  VLANs on the LAN, and  NAT/MASQUERADE   that does not work.


Network config:
Nat_host <-->  router <---> server

a ping from the Nat_host  reaches the server on the WAN fine, and the
ping comes back to the  router, but the ping response never reaches the
Nat_Host.    Using TRACE rules it seems the ICMP ping response gets lost
inside the router.   I see the same behavior with TCP and UDP.



Other similar cases that everything works fine.

1.    If i don't use VLAN's  on the LAN everything works fine with
NAT/MASQUERADE on the WAN  with Ethernet, ATM IPoA (RFC1577), and  ATM
IPoE (RFC2684).

2.    If I use  VLAN's on the LAN everything works fine with
NAT/MASQUERADE but only with  Ethernet and ATM IPoE(RFC2684) on the WAN.



Script to configure  CLIP on the WAN and VLANs on the LAN where NAT does
not work:

cat atm.vlan.sh
#!/bin/sh

vconfig add eth0 1
vconfig add eth0 2
ip addr add 192.168.88.1/24 broadcast 192.168.88.255 dev eth0.1
ip link set eth0.1 up

echo "NOTE: config switch vlans at this point"


ip addr
ip link
echo -------
echo " remove old eth0"
ip addr del 192.168.88.1/24 dev eth0
ip link
ip addr


atmarpd -b
atmarp -c atm0

ip addr add 10.1.1.178/24 dev atm0
ip link set atm0 up
atmarp -s 10.1.1.1 0.8.32
atmarp -a


#echo "delete route to LAN  ERROR ok here if no route exists"
#ip route del default via 192.168.88.1 dev eth0.1
echo "route via ATM"
ip route add default via 10.1.1.1

#flush tables and make default policy accept.
iptables -F; iptables -t nat -F; iptables -t mangle -F
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT

iptables -t nat -A POSTROUTING -o atm0 -j MASQUERADE
echo 1 > /proc/sys/net/ipv4/ip_forward



##########  Script to configure IPoA on the WAN without vlans  where
everything works fine:

cat atm.no.vlan.sh
#!/bin/sh

atmarpd -b
atmarp -c atm0

ip addr add 10.1.1.178/24 dev atm0
ip link set atm0 up
atmarp -s 10.1.1.1 0.8.32
atmarp -a

ip route del default via 192.168.88.1 dev eth0
ip route add default via 10.1.1.1

#flush tables and make default policy accept.
iptables -F; iptables -t nat -F; iptables -t mangle -F
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT

iptables -t nat -A POSTROUTING -o atm0 -j MASQUERADE
echo 1 > /proc/sys/net/ipv4/ip_forward


############

This WARN_ON() is occurring When using VLANs on IPoA and NAT

------------[ cut here ]------------
WARNING: at net/ipv4/netfilter/nf_nat_standalone.c:89 nf_nat_fn+0x44/0x194 [iptable_nat]()
Modules linked in: xt_MARK crc_ccitt nf_conntrack_pptp nf_conntrack_proto_gre ixp4xx_crypto ipt_MASQUERADE ipt_REDIRECT nf_nat_sip nf_conntrack
_sip nf_nat_h323 nf_conntrack_h323 nf_nat_tftp nf_conntrack_tftp nf_nat_ftp nf_conntrack_ftp nf_nat_irc nf_conntrack_irc ipt_addrtype iptable_n
at nf_nat xt_TCPMSS xt_pkttype nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack xt_mark iptable_mangle iptable_filter ip_tables ixp4xx_sa
r ixp4xx_atm ixp_osal eagle utopia ipt_ULOG

[<c0025798>] (dump_stack+0x0/0x14) from [<c0031878>] (warn_on_slowpath+0x4c/0x68)
[<c003182c>] (warn_on_slowpath+0x0/0x68) from [<bf0d13a0>] (nf_nat_fn+0x44/0x194 [iptable_nat])
 r6:00000004 r5:c583d240 r4:bf0d24e8
[<bf0d135c>] (nf_nat_fn+0x0/0x194 [iptable_nat]) from [<bf0d1764>] (nf_nat_out+0x44/0xc4 [iptable_nat])
[<bf0d1720>] (nf_nat_out+0x0/0xc4 [iptable_nat]) from [<c01e5a9c>] (nf_iterate+0x64/0xd0)
 r5:c0313d70 r4:bf0d24e8
[<c01e5a38>] (nf_iterate+0x0/0xd0) from [<c01e5b6c>] (nf_hook_slow+0x64/0xf0)
[<c01e5b08>] (nf_hook_slow+0x0/0xf0) from [<c01f1c38>] (ip_output+0x84/0xa4)
[<c01f1bb4>] (ip_output+0x0/0xa4) from [<c01eea10>] (ip_forward_finish+0x44/0x4c)
 r4:c583d240
[<c01ee9cc>] (ip_forward_finish+0x0/0x4c) from [<c01eecdc>] (ip_forward+0x2c4/0x340)
 r4:c583d240
[<c01eea18>] (ip_forward+0x0/0x340) from [<c01ed5d8>] (ip_rcv_finish+0x338/0x35c)
 r7:c7d78000 r6:c034ce64 r5:c588e018 r4:c034d0ac
[<c01ed2a0>] (ip_rcv_finish+0x0/0x35c) from [<c01edb18>] (ip_rcv+0x23c/0x270)
[<c01ed8dc>] (ip_rcv+0x0/0x270) from [<c01d0fe8>] (netif_receive_skb+0x380/0x3c0)
 r7:00000800 r6:c7d78000 r5:c583d240 r4:c034d0ac
[<c01d0c68>] (netif_receive_skb+0x0/0x3c0) from [<c01d35fc>] (process_backlog+0x8c/0x128)
[<c01d3570>] (process_backlog+0x0/0x128) from [<c01d2fec>] (net_rx_action+0x60/0x1b8)
[<c01d2f8c>] (net_rx_action+0x0/0x1b8) from [<c0036458>] (__do_softirq+0x68/0x104)
[<c00363f0>] (__do_softirq+0x0/0x104) from [<c00367c8>] (irq_exit+0x44/0x4c)
[<c0036784>] (irq_exit+0x0/0x4c) from [<c0021068>] (__exception_text_start+0x68/0x84)
[<c0021000>] (__exception_text_start+0x0/0x84) from [<c00219c4>] (__irq_svc+0x24/0x80)
Exception stack(0xc0313f4c to 0xc0313f94)
3f40:                            c0333ad4 c78e4600 a0000013 00000000 c0022dd8
3f60: c0312000 c0022dd8 c0333148 0001d74c 69054041 0001d67c c0313fc0 c0313fa4
3f80: c0313f94 c0022ca0 c0022de0 60000013 ffffffff
 r5:0000001f r4:ffffffff
[<c0022c64>] (cpu_idle+0x0/0x58) from [<c025b078>] (rest_init+0x54/0x68)
 r7:c031636c r6:c001edb8 r5:c0332cc4 r4:c033f260
[<c025b024>] (rest_init+0x0/0x68) from [<c00089d0>] (start_kernel+0x244/0x2a4)
[<c000878c>] (start_kernel+0x0/0x2a4) from [<00008034>] (0x8034)
 r6:c001f1bc r5:c03331ac r4:000039fd
---[ end trace 223a280469e2bcdb ]---






Thanks for any help or info you can give me.   Please CC me on responses.


Karl.
