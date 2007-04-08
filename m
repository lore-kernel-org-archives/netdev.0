From: W Agtail <wagtail@iol.ie>
Subject: two gateways with one NIC
Date: Sun, 08 Apr 2007 04:35:53 +0100
Message-ID: <1176003353.686.45.camel@owl.home.ie>
Reply-To: wagtail@iol.ie
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpc1-york1-0-0-cust229.leed.cable.ntl.com ([82.3.204.230]:25600
	"EHLO owl.home.ie" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752421AbXDHDf4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Apr 2007 23:35:56 -0400
Received: from owl.home.ie (localhost.localdomain [127.0.0.1])
	by owl.home.ie (8.13.7/8.13.4) with ESMTP id l383Zs0A020048
	for <netdev@vger.kernel.org>; Sun, 8 Apr 2007 04:35:54 +0100
Received: (from wagtail@localhost)
	by owl.home.ie (8.13.7/8.13.7/Submit) id l383Zr2C020047
	for netdev@vger.kernel.org; Sun, 8 Apr 2007 04:35:53 +0100
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hope you can help.

I have the following setup using LVS (Linux Virtual Servers):

LAN--------------------192.168.0.0/24-----------------  <= CLIENTS
        |                               |
        |                               |
        LVS1                            LVS2
         vip1: 192.168.0.111             vip2: 192.168.0.121
         eth0: 192.168.0.110             eth0: 192.168.0.120
         eth1: 10.18.35.10               eth1: 10.18.35.20
         gw1:  10.18.35.11               gw2:  10.18.35.21
                |                               |
                |                               |
LAN--------------------10.18.35.0/24-----------------
                |                               |
                |                               |
Apache>         WEB1 10.18.35.51:8088           WEB2 10.18.35.52:8088
Apache>         WEB1 10.18.35.51:8089           WEB2 10.18.35.52:8088


### LVS ###
The two LVS servers have a VIP and a GW.
LVS1 & LVS2 have ip_forward set to 1.

LVS1 has the following iptables:
iptables -t nat -A PREROUTING  -i eth0 -j DNAT --to 192.168.0.111
iptables -t nat -A POSTROUTING -o eth0 -j SNAT --to 192.168.0.111
with ipvsadm forwarding vip1:8088 to web1:8088 & web2:8088

LVS2 has the following iptables:
iptables -t nat -A PREROUTING  -i eth0 -j DNAT --to 192.168.0.121
iptables -t nat -A POSTROUTING -o eth0 -j SNAT --to 192.168.0.121
with ipvsadm forwarding vip1:8089 to web1:8089 & web2:8089

### WEB ###
The two Web servers have 2 virtual web servers listening on ports 8088 &
8089 and have the following iptables & iproute2 config:
iptables -t mangle -A PREROUTING -p tcp --dport 8088 -i eth0 -j MARK
--set-mark 1
iptables -t mangle -A PREROUTING -p tcp --dport 8089 -i eth0 -j MARK
--set-mark 2

ip route add table 1 default via 10.18.35.11 dev eth0
ip route add table 2 default via 10.18.35.21 dev eth0

ip rule add fwmark 1 table 1
ip rule add fwmark 2 table 2

WEB1's default GW is set to gw1.
WEB2's default GW is set to gw2.

CLIENTS should be able to connect to vip1:8088 and vip2:8089

### MY PROBLEM ###

If i set WEB2's default GW to gw1, everything works as expected (as I
now only have one GW).
But when trying to set WEB2's default GW to gw2, things don't work.
For example, if i was to run: curl vip1:8088 from a CLIENT, I would be
able to connect to web1:8088 via LVS OK, but unable to connect to
web2:8088 should LVS take me to web2.

Its as though the iptables/ip route settings are not working as they
should.

Any ideas what I'm doing wrong?
Many thanks, W Agtail.

