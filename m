From: subashab@codeaurora.org
Subject: Re: [RFC PATCH] xfrm: Add option to reset oif in xfrm lookup
Date: Fri, 29 Jul 2016 12:21:27 -0600
Message-ID: <7e8efab3f896b081adb6bbaf6613a569@codeaurora.org>
References: <1469493272-14894-1-git-send-email-subashab@codeaurora.org>
 <ceb825e1-cba5-e252-f8d1-30198797bbb2@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, netdev-owner@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:42055 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752988AbcG2SV2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2016 14:21:28 -0400
In-Reply-To: <ceb825e1-cba5-e252-f8d1-30198797bbb2@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Please don't try to workaround a bug with a sysctl.
> If we have a bug here, we should fix it. Choosing
> between bug A and bug B with a sysctl is not what
> we are doing ;)

Sure, this was just a quick hack.

> Can you give an example of your use case -- e.g., commands for others
> (me) to reproduce?

Here is an equivalent set of rules. We see a difference in the oif when 
reset oif vs preserve it.
eth1 is the interface from which traffic is generated while eth0 is the 
tunnel.

--------------
#Commands
echo 1 > /proc/sys/net/ipv4/ip_forward
echo 1 > /proc/sys/net/ipv4/conf/all/accept_local
echo 1 > /proc/sys/net/ipv4/conf/eth0/accept_local
echo 1 > /proc/sys/net/ipv4/conf/eth1/accept_local

ip addr add 192.168.77.2/24 dev eth0
ip link set eth0 mtu 1400
ip link set eth0 up

ip addr add 192.168.33.2/24 dev eth1
ip link set eth1 mtu 1400
ip link set eth1 up

ip ru add to 192.168.33.1 lookup 8 prio 4000
ip ru add oif eth1 lookup 8 prio 4010
ip ru add to 192.168.77.1 lookup 9 prio 4030

ip route add default dev eth1 table 8
ip route add default dev eth0 table 9

iptables -t raw -A OUTPUT -j LOG --log-prefix "RAW-OUT >> "
iptables -t mangle -A POSTROUTING -j LOG --log-prefix "MAN-PST >> "

echo 0 > /proc/sys/net/ipv4/tcp_timestamps

# out direction
ip xfrm state add src 192.168.77.2 dst 192.168.77.1 proto esp spi 0x1234 
mode tunnel enc 'cbc(aes)' 
0xbb31df5b207dc1c7a8512eeda0b2d0691e27bc8059dbb82df616bb9955058cd5 auth 
'hmac(sha1)' 0x93b43b527d564efb9eac8cd04510b86e409f8ea7 flag af-unspec 
encap espinudp 4500 4500 0.0.0.0

ip xfrm policy add dir out src 192.168.33.2 tmpl src 192.168.77.2 dst 
192.168.77.1 proto esp spi 0x1234 mode tunnel

# in direction
ip xfrm state add src 192.168.77.1 dst 192.168.77.2 proto esp spi 0x4321 
mode tunnel enc 'cbc(aes)' 
0x5d3ca96d1af2eaa9cf8f1c1cace88f550e2a5b7b82027023287e1fe2a42f7f54 auth 
'hmac(sha1)' 0xcd09f850d7c0dd6dc0ed342619c1165571452f9d flag af-unspec 
encap espinudp 4500 4500 0.0.0.0

ip xfrm policy add dir in dst 192.168.33.2 tmpl src 192.168.77.1 dst 
192.168.77.2 proto esp spi 0x4321 mode tunnel
ip xfrm policy add dir fwd dst 192.168.33.2 tmpl src 192.168.77.1 dst 
192.168.77.2 proto esp spi 0x4321 mode tunnel
--------------

Output when resetting oif (3.18)

root@vm:~# ping -c 1 -I eth1 192.168.33.1
PING 192.168.33.1 (192.168.33.1) 56(84) bytes of data.
RAW-OUT >> IN= OUT=eth0 SRC=192.168.33.2 DST=192.168.33.1 LEN=84 
TOS=0x00 PREC=0x00 TTL=64 ID=801 DF PROTO=ICMP TYPE=8 CODE=0 ID=2040 
SEQ=1
MAN-PST >> IN= OUT=eth0 SRC=192.168.33.2 DST=192.168.33.1 LEN=84 
TOS=0x00 PREC=0x00 TTL=64 ID=801 DF PROTO=ICMP TYPE=8 CODE=0 ID=2040 
SEQ=1
RAW-OUT >> IN= OUT=eth0 SRC=192.168.77.2 DST=192.168.77.1 LEN=160 
TOS=0x00 PREC=0x00 TTL=64 ID=41757 DF PROTO=UDP SPT=4500 DPT=4500 
LEN=140
MAN-PST >> IN= OUT=eth0 SRC=192.168.77.2 DST=192.168.77.1 LEN=160 
TOS=0x00 PREC=0x00 TTL=64 ID=41757 DF PROTO=UDP SPT=4500 DPT=4500 
LEN=140

--------------

Output when preserving oif (4.4)

root@vm:~# ping -c 1 -I eth1 192.168.33.1
PING 192.168.33.1 (192.168.33.1) 56(84) bytes of data.
RAW-OUT >> IN= OUT=eth1 SRC=192.168.33.2 DST=192.168.33.1 LEN=84 
TOS=0x00 PREC=0x00 TTL=64 ID=20191 DF PROTO=ICMP TYPE=8 CODE=0 ID=2043 
SEQ=1
MAN-PST >> IN= OUT=eth1 SRC=192.168.33.2 DST=192.168.33.1 LEN=84 
TOS=0x00 PREC=0x00 TTL=64 ID=20191 DF PROTO=ICMP TYPE=8 CODE=0 ID=2043 
SEQ=1
RAW-OUT >> IN= OUT=eth1 SRC=192.168.77.2 DST=192.168.77.1 LEN=160 
TOS=0x00 PREC=0x00 TTL=64 ID=49515 DF PROTO=UDP SPT=4500 DPT=4500 
LEN=140
MAN-PST >> IN= OUT=eth1 SRC=192.168.77.2 DST=192.168.77.1 LEN=160 
TOS=0x00 PREC=0x00 TTL=64 ID=49515 DF PROTO=UDP SPT=4500 DPT=4500 
LEN=140
