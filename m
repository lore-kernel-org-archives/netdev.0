From: Karl Krach <ml@kkrach.de>
Subject: TUN works when SRC != own IP
Date: Mon, 21 Dec 2015 18:44:16 +0100
Message-ID: <56783A70.6020308@kkrach.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.mail.vrmd.de ([81.28.224.28]:38258 "EHLO
	relay2.mail.vrmd.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750965AbbLUR7X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2015 12:59:23 -0500
Received: from [62.245.205.51] (helo=[172.16.11.137])
	by relay2.mail.vrmd.de with esmtpsa (TLS1.0:DHE_RSA_AES_128_CBC_SHA1:128)
	(Exim 4.82.1)
	(envelope-from <ml@kkrach.de>)
	id 1aB4VM-00017L-Qy
	for netdev@vger.kernel.org; Mon, 21 Dec 2015 18:44:16 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I have to forward IP-packets from an FPGA via network. For this I use 
packet_mmap / PACKET_TX_RING for destinations within the ARP cache and 
the TUN interface for all others (incl. packets to my own device).

When I send these foreign packets (ip4h->saddr != device address) via 
TUN device, they are forwarded to the appropriate interface eth1 
correctly. But when I want to send packets from the own device 
(ip4h->saddr == device address) they get lost between tunX and ethX.

I use the following to setup the system (Linux 4.0.0, PowerPC TQMP2020):

# openvpn --mktun --dev tun16
# ip link set tun16 up
# ip rule add iif tun16 table 50
# ip route add 0/0 dev eth1 table 50

and this program (https://github.com/kkrach/tuncom) to test the data 
transfer over TUN. When I use "1.1.1.1" as source address, everything 
works fine. But when I use the device's IP (192.168.32.60) the packets 
can be seen on the TUN interface (tcpdump -i tun16) but not on the 
network interface (tcpdump -i eth1).

Can't I use TUN for this purpose - or is my setup somehow wrong?





I ve figured out, that when I remove the rule "local 192.168.32.60 dev 
eth1 proto kernel scope host src 192.168.32.60" from the table "local" 
all packets (also those with the correct SRC address) are sent correctly 
- but then the device stops to receive any.

Could the problem be somewhere in my (local) rules?


# ip route show table local
broadcast 127.0.0.0 dev lo proto kernel  scope link  src 127.0.0.1
local 127.0.0.0/8 dev lo proto kernel  scope host  src 127.0.0.1
local 127.0.0.1 dev lo proto kernel  scope host  src 127.0.0.1
broadcast 127.255.255.255 dev lo proto kernel scope link  src 127.0.0.1
broadcast 172.16.10.0 dev eth0 proto kernel scope link src 172.16.10.12
local 172.16.10.12 dev eth0 proto kernel scope host  src 172.16.10.12
broadcast 172.16.11.255 dev eth0 proto kernel scope link src 172.16.10.12
broadcast 192.168.32.0 dev eth1 proto kernel scope link src 192.168.32.60
local 192.168.32.60 dev eth1 proto kernel scope host  src 192.168.32.60
broadcast 192.168.32.255 dev eth1  proto kernel scope link  src 
192.168.32.60
#

Best regards,
Karl Krach
