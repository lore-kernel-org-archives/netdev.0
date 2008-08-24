From: Jan Engelhardt <jengelh@medozas.de>
Subject: Unexpected source address selection in routing
Date: Sun, 24 Aug 2008 19:39:52 -0400 (EDT)
Message-ID: <alpine.LNX.1.10.0808241936410.22921@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Netfilter Developer Mailing List <netfilter-devel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,


It appears that the routing code selects the outgoing source address to 
use for packets is chosen when the socket is established instead of
at routing time.

The following presents a test case for "unexpected" (from a user's 
perspective) behavior.

Is there any way to make it behave as a user would expect?


thanks,
Jan


#
#	Setup
#
modprobe dummy
ip a a 1.3.3.7/24 dev dummy0
iptables -t mangle -A OUTPUT -p tcp --dport 99 -j MARK --set-mark 99
ip ru a fwmark 99 table 99
ip r a default via 1.3.3.8 dev dummy0 table 99

#
# How things look now:
# ip a; ip r l;
#
# 3: sis0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast qlen 1000
#     inet 10.10.106.161/20 brd 10.10.111.255 scope global sis0
# 8: dummy0: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue 
#     inet 1.3.3.7/24 scope global dummy0
#
# 1.3.3.0/24 dev dummy0  proto kernel  scope link  src 1.3.3.7
# 10.10.96.0/20 dev sis0  proto kernel  scope link  src 10.10.106.161 
# default via 10.10.96.1 dev sis0 
# 

#
#	Test
#
tcpdump -lni dummy0 &
telnet 134.76.13.21 99


#
#	Tcpdump will say something like:
#
IP 10.10.106.161.57962 > 134.76.13.21.99: S 2153063224:2153063224(0) win 5840 <mss 1460,nop,nop,timestamp 3052479 0,nop,wscale 6>


#
#	What I would have expected:
#
IP 1.3.3.7.57962 > 134.76.13.21.99: S ...

