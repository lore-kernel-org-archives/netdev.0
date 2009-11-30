From: Ashwani Wason <ashwas@gmail.com>
Subject: SO_BINDTODEVICE and IP_TRANSPARENT (TPROXY)
Date: Mon, 30 Nov 2009 15:15:27 -0800
Message-ID: <fd1a5ee40911301515y7d5e9f8fq62ff3e28b747c308@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f219.google.com ([209.85.219.219]:42591 "EHLO
	mail-ew0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876AbZK3XPm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 18:15:42 -0500
Received: by ewy19 with SMTP id 19so4337647ewy.21
        for <netdev@vger.kernel.org>; Mon, 30 Nov 2009 15:15:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It appears that SO_BINDTODEVICE is not working when used along with
IP_TRANSPARENT of TPROXY. The use case is for a transparent proxy that
has to handle clients with overlapping IP addresses coming in on
different interfaces (VLANs or physical). Each such interface has a
unique next hop gateway.

Setup: Kernel 2.6.30.9 built with required TPROXY configuration. A
system with three interfaces, eth0 (192.168.0.65/24), eth0.1
(10.0.7.65/16), and eth1 (192.168.1.65/24), each with its own default
router and a fairly standard set of TPROXY rules:

default via 192.168.1.62 dev eth1
default via 192.168.0.62 dev eth0
default via 10.0.0.9 dev eth0.1

iptables -t mangle -N DIVERT
iptables -t mangle -A DIVERT -j MARK --set-mark 1
iptables -t mangle -A DIVERT -j ACCEPT
iptables -t mangle -A PREROUTING -p tcp -m socket -j DIVERT
iptables -t mangle -A PREROUTING -p tcp --dport 80 -j TPROXY
--tproxy-mark 0x1/0x1 --on-port 4002

ip rule add fwmark 1 iif eth0 lookup 101
ip rule add fwmark 1 iif eth1 lookup 101

ip route add local 0.0.0.0/0 dev lo table 101

Additional information:

* The proxy has a separate listening socket for each interface.

* On each listening socket the proxy sets the IP_TRANSPARENT option.
It also sets the SO_BINDTODEVICE option (on each socket) to the
associated interface. (I have experimented with the ordering of these
options and setting one before the other has no change in behavior.)

* The proxy works perfectly fine in "transparent mode" when
SO_BINDTODEVICE is not used.

* The proxy works perfectly fine in "explicit mode" when
SO_BINDTODEVICE *is used*.

Now my test is very simple with the expectation that when a SYN comes
in on, say, interface eth0 then the SYN/ACK must go out back on that
interface to the MAC address of the designated next hop router. That
does not seem to happen however. The SYN/ACK is not being sent out at
all, from any interface. It seems that either the SYN or the SYN/ACK
is being eaten up somewhere. No one 'netstat -s' seems to be updated
either. (Since even 'netstat -ant' does not show the TCP connection
state, I suspect that the SYN is being eaten up.)

When I reconfigure the proxy to be in explicit mode, i.e. not set the
IP_TRANSPARENT option, and have the clients connect directly to the IP
address and port of the proxy then the system works as expected, i.e.
the SYN/ACK (and all subsequent packets) go out on the associated
interface.

Thank you,
Ashwani
