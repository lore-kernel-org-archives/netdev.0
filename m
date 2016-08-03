From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [RFC PATCH] xfrm: Add option to reset oif in xfrm lookup
Date: Tue, 2 Aug 2016 22:06:34 -0600
Message-ID: <7c3836e2-adf0-8e04-8c2f-6ee714a38f70@cumulusnetworks.com>
References: <1469493272-14894-1-git-send-email-subashab@codeaurora.org>
 <ceb825e1-cba5-e252-f8d1-30198797bbb2@cumulusnetworks.com>
 <7e8efab3f896b081adb6bbaf6613a569@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, netdev-owner@vger.kernel.org
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33805 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751431AbcHCEHP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2016 00:07:15 -0400
Received: by mail-pa0-f42.google.com with SMTP id fi15so69716518pac.1
        for <netdev@vger.kernel.org>; Tue, 02 Aug 2016 21:06:37 -0700 (PDT)
In-Reply-To: <7e8efab3f896b081adb6bbaf6613a569@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/29/16 12:21 PM, subashab@codeaurora.org wrote:
>> Please don't try to workaround a bug with a sysctl.
>> If we have a bug here, we should fix it. Choosing
>> between bug A and bug B with a sysctl is not what
>> we are doing ;)
>
> Sure, this was just a quick hack.
>
>> Can you give an example of your use case -- e.g., commands for others
>> (me) to reproduce?
>
> Here is an equivalent set of rules. We see a difference in the oif when
> reset oif vs preserve it.
> eth1 is the interface from which traffic is generated while eth0 is the
> tunnel.
>
> --------------
> #Commands
> echo 1 > /proc/sys/net/ipv4/ip_forward
> echo 1 > /proc/sys/net/ipv4/conf/all/accept_local
> echo 1 > /proc/sys/net/ipv4/conf/eth0/accept_local
> echo 1 > /proc/sys/net/ipv4/conf/eth1/accept_local
>
> ip addr add 192.168.77.2/24 dev eth0
> ip link set eth0 mtu 1400
> ip link set eth0 up
>
> ip addr add 192.168.33.2/24 dev eth1
> ip link set eth1 mtu 1400
> ip link set eth1 up
>
> ip ru add to 192.168.33.1 lookup 8 prio 4000
> ip ru add oif eth1 lookup 8 prio 4010
> ip ru add to 192.168.77.1 lookup 9 prio 4030
>
> ip route add default dev eth1 table 8
> ip route add default dev eth0 table 9
>
> iptables -t raw -A OUTPUT -j LOG --log-prefix "RAW-OUT >> "
> iptables -t mangle -A POSTROUTING -j LOG --log-prefix "MAN-PST >> "
>
> echo 0 > /proc/sys/net/ipv4/tcp_timestamps
>
> # out direction
> ip xfrm state add src 192.168.77.2 dst 192.168.77.1 proto esp spi 0x1234
> mode tunnel enc 'cbc(aes)'
> 0xbb31df5b207dc1c7a8512eeda0b2d0691e27bc8059dbb82df616bb9955058cd5 auth
> 'hmac(sha1)' 0x93b43b527d564efb9eac8cd04510b86e409f8ea7 flag af-unspec
> encap espinudp 4500 4500 0.0.0.0
>
> ip xfrm policy add dir out src 192.168.33.2 tmpl src 192.168.77.2 dst
> 192.168.77.1 proto esp spi 0x1234 mode tunnel
>
> # in direction
> ip xfrm state add src 192.168.77.1 dst 192.168.77.2 proto esp spi 0x4321
> mode tunnel enc 'cbc(aes)'
> 0x5d3ca96d1af2eaa9cf8f1c1cace88f550e2a5b7b82027023287e1fe2a42f7f54 auth
> 'hmac(sha1)' 0xcd09f850d7c0dd6dc0ed342619c1165571452f9d flag af-unspec
> encap espinudp 4500 4500 0.0.0.0
>
> ip xfrm policy add dir in dst 192.168.33.2 tmpl src 192.168.77.1 dst
> 192.168.77.2 proto esp spi 0x4321 mode tunnel
> ip xfrm policy add dir fwd dst 192.168.33.2 tmpl src 192.168.77.1 dst
> 192.168.77.2 proto esp spi 0x4321 mode tunnel
> --------------
>
> Output when resetting oif (3.18)
>
> root@vm:~# ping -c 1 -I eth1 192.168.33.1
> PING 192.168.33.1 (192.168.33.1) 56(84) bytes of data.
> RAW-OUT >> IN= OUT=eth0 SRC=192.168.33.2 DST=192.168.33.1 LEN=84
> TOS=0x00 PREC=0x00 TTL=64 ID=801 DF PROTO=ICMP TYPE=8 CODE=0 ID=2040 SEQ=1
> MAN-PST >> IN= OUT=eth0 SRC=192.168.33.2 DST=192.168.33.1 LEN=84
> TOS=0x00 PREC=0x00 TTL=64 ID=801 DF PROTO=ICMP TYPE=8 CODE=0 ID=2040 SEQ=1
> RAW-OUT >> IN= OUT=eth0 SRC=192.168.77.2 DST=192.168.77.1 LEN=160
> TOS=0x00 PREC=0x00 TTL=64 ID=41757 DF PROTO=UDP SPT=4500 DPT=4500 LEN=140
> MAN-PST >> IN= OUT=eth0 SRC=192.168.77.2 DST=192.168.77.1 LEN=160
> TOS=0x00 PREC=0x00 TTL=64 ID=41757 DF PROTO=UDP SPT=4500 DPT=4500 LEN=140
>
> --------------
>
> Output when preserving oif (4.4)
>
> root@vm:~# ping -c 1 -I eth1 192.168.33.1
> PING 192.168.33.1 (192.168.33.1) 56(84) bytes of data.
> RAW-OUT >> IN= OUT=eth1 SRC=192.168.33.2 DST=192.168.33.1 LEN=84
> TOS=0x00 PREC=0x00 TTL=64 ID=20191 DF PROTO=ICMP TYPE=8 CODE=0 ID=2043
> SEQ=1
> MAN-PST >> IN= OUT=eth1 SRC=192.168.33.2 DST=192.168.33.1 LEN=84
> TOS=0x00 PREC=0x00 TTL=64 ID=20191 DF PROTO=ICMP TYPE=8 CODE=0 ID=2043
> SEQ=1
> RAW-OUT >> IN= OUT=eth1 SRC=192.168.77.2 DST=192.168.77.1 LEN=160
> TOS=0x00 PREC=0x00 TTL=64 ID=49515 DF PROTO=UDP SPT=4500 DPT=4500 LEN=140
> MAN-PST >> IN= OUT=eth1 SRC=192.168.77.2 DST=192.168.77.1 LEN=160
> TOS=0x00 PREC=0x00 TTL=64 ID=49515 DF PROTO=UDP SPT=4500 DPT=4500 LEN=140
>

I can't explain the iptables output but from a FIB lookup perspective it 
is using table 8 per the FIB rules, the xfrm is hit and packets shift to 
192.168.77.1 and go out what you have as eth0.

Take a look at:
   perf record -e fib:* -a -g
   perf script

And then run tcpdump on both eth0 and eth1. For me on "eth0" (which is 
really eth11 for my VM setup) I see this on the ping:

20:50:11.389837 ARP, Request who-has 192.168.77.2 tell 192.168.77.1, 
length 28
20:50:11.390079 ARP, Reply 192.168.77.2 is-at 02:00:12:34:02:0a, length 28
20:50:11.390101 IP 192.168.77.1 > 192.168.77.2: ICMP 192.168.77.1 udp 
port 4500 unreachable, length 168

So the packets are going out "eth0" as expected.

That said, the commands you have given do not totally transfer to 
another setup. In my case I have 2 VMs with eth11 and eth12 directly 
connected (VM1 eth11 <--> VM2 eth11 and ditto for eth12). You have given 
one side of the commands and I have configured the other side with the 
.1 addresses but not bothered to translate the xfrm commands.

That said, this seems like a contrived example -- you pin ping to device 
eth1 (-I eth1), you are pinging a host on the network for eth1 but want 
packets to go out eth0 via the xfrm. Can you elaborate on the real use 
case and problem here?
