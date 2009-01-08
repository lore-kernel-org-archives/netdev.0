From: mysql.jorge@decimal.pt
Subject: Re: [BUG #12364] Re: HTB - very bad precision? HFSC works fine!
     2.6.28
Date: Thu, 8 Jan 2009 11:22:01 -0000 (WET)
Message-ID: <2111.192.168.1.3.1231413721.squirrel@webmail.decimal.pt>
References: <1935.87.196.72.187.1231371721.squirrel@webmail.decimal.pt>
    <20090108094231.GD4496@ff.dom.local>
    <20090108095403.GE4496@ff.dom.local>
    <20090108100614.GA5418@ff.dom.local>
    <2025.192.168.1.3.1231410939.squirrel@webmail.decimal.pt>
    <20090108110430.GB5493@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Denys Fedoryschenko" <denys@visp.net.lb>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: "Jarek Poplawski" <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrly06.isp.novis.pt ([195.23.133.216]:42037 "EHLO
	mailrly06.isp.novis.pt" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977AbZAHLVn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 06:21:43 -0500
In-Reply-To: <20090108110430.GB5493@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

here are them:

i see in the TBF class, 25000bps, where did it get that value?
the rules i used was:
---
/sbin/tc qdisc del dev eth0 root
/sbin/tc qdisc add dev eth0 root handle 1 cbq bandwidth 100Mbit avpkt 1000
cell 8
/sbin/tc class change dev eth0 root cbq weight 10Mbit allot 1514

/sbin/tc class add dev eth0 parent 1: classid 1:1280 cbq bandwidth 100Mbit
rate 200Kbit weight 6kbit prio 5 allot 1514 cell 8
maxburst 20 avpkt 1000 bounded isolated
/sbin/tc qdisc add dev eth0 parent 1:1280 handle 1280 tbf rate 200Kbit
buffer 10Kb/8 limit 15Kb mtu 1500
/sbin/tc filter add dev eth0 parent 1:0 protocol ip prio 100 u32 match ip
src 195.23.114.76 match ip sport 80 0xffff classid 1
:1280

---



lira:~# tc -s class show dev eth0
class cbq 1: root rate 125000000bps (bounded,isolated) prio no-transmit
 Sent 3165780 bytes 4451 pkts (dropped 0, overlimits 0)
  borrowed 0 overactions 0 avgidle 7 undertime 0
class cbq 1:1280 parent 1: leaf 1280: rate 25000bps (bounded,isolated) prio 5
 Sent 644302 bytes 455 pkts (dropped 218, overlimits 0)
  borrowed 0 overactions 0 avgidle 1.10849e+06 undertime 0
class tbf 1280:1 parent 1280: [UNKNOWN]
 Sent 0 bytes 0 pkts (dropped 0, overlimits 0)
lira:~# tc -s qdisc show dev eth0
qdisc cbq 1: root rate 125000000bps (bounded,isolated) prio no-transmit
 Sent 4214629 bytes 5893 pkts (dropped 251, overlimits 0)
  borrowed 0 overactions 0 avgidle 7 undertime 0

 qdisc tbf 1280: parent 1:1280 rate 25000bps burst 10Kb lat 209.7ms
 Sent 747550 bytes 527 pkts (dropped 251, overlimits 0)

lira:~# ethtool -k eth0
Offload parameters for eth0:
Cannot get device flags: Operation not supported
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: on
udp fragmentation offload: off
generic segmentation offload: off
large receive offload: off


(the shaping is done in the eth0:1 IP ADDR)

lira:~# ifconfig
eth0      Link encap:Ethernet  HWaddr 00:13:d4:68:c6:33
          inet addr:195.23.114.76  Bcast:195.23.114.79  Mask:255.255.255.248
          inet6 addr: fe80::213:d4ff:fe68:c633/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:4544600 errors:0 dropped:0 overruns:0 frame:0
          TX packets:4047072 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:2148440536 (2.0 GiB)  TX bytes:2942330389 (2.7 GiB)
          Interrupt:17

eth0:0    Link encap:Ethernet  HWaddr 00:13:d4:68:c6:33
          inet addr:192.168.1.222  Bcast:192.168.1.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          Interrupt:17



> On Thu, Jan 08, 2009 at 10:35:39AM -0000, mysql.jorge@decimal.pt wrote:
>> Well, even with that, why it works perfectly when i use the 100Mbit NIC?
>> There must be something here that needs an ajustment, no?
>
> It's hard to tell because these two things (cbq and tbf) use different
> methods, which could interact strange way (and are not expected to work
> together). I think you should test them alone first (especially tbf),
> and send here the tc comannd plus "tc -s qdisc show dev eth0" and
> "tc -s class show dev eth0" output while traffic is run. You could also
> add this "ethtool -k eth0" and "ifconfig eth0".
>
> Jarek P.
>

