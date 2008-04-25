From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Subject: netperf udp_rr testing hang
Date: Fri, 25 Apr 2008 15:42:23 +0800
Message-ID: <1209109343.28819.37.camel@ymzhang>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rick Jones <rick.jones2@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga10.intel.com ([192.55.52.92]:62175 "EHLO
	fmsmga102.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753425AbYDYHnz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 03:43:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am testing network UDP by netperf V2.4.4.

I have 2 machines. Every machine has 2 NIC, so 2 IP addresses per machi=
ne.
Client1: 192.168.1.164 (eth1:=EF=BB=BF=EF=BB=BFlkp-h01-nic2.tsp.org) an=
d =EF=BB=BF192.168.1.169 (eth2:=EF=BB=BF=EF=BB=BF=EF=BB=BFlkp-h01.tsp.o=
rg).
Server1: 192.168.1.160 (eth0:=EF=BB=BFlkp-tt02-x8664.tsp.org) and 192.1=
68.1.153 (eth1:=EF=BB=BFlkp-tt02-nic2.tsp.org).

They are connected to the same GIGA switch.

On Server1, start netserver:
#./netserver&

Then, on Client1: start netperf:
#./netperf -t UDP_RR -l 60 -H 192.168.1.153 -L 192.168.1.164 -i 3,3 -I =
99,5 -- -r 1,1
It looks like netperf hangs and exits after 180(or 60?) seconds. The re=
sult shows
RatePerSec is 0.0.
If I use tcpdump to intercept all packets on eth1 on client1, the dump =
shows:
14:49:14.820924 IP lkp-h01.tsp.org.41456 > lkp-tt02-nic2.tsp.org.12865:=
 . ack 1 win 46 <nop,nop,timestamp 1691048 1803244>
14:49:14.821043 IP lkp-h01.tsp.org.ssh > lkp-os.tsp.org.45485: P 176:36=
8(192) ack 49 win 146 <nop,nop,timestamp 1691048 1575061177>
14:49:14.821047 IP lkp-h01.tsp.org.41456 > lkp-tt02-nic2.tsp.org.12865:=
 P 1:257(256) ack 1 win 46 <nop,nop,timestamp 1691048 1803244>
14:49:14.821157 IP lkp-tt02-nic2.tsp.org.12865 > lkp-h01.tsp.org.41456:=
 . ack 257 win 54 <nop,nop,timestamp 1803244 1691048>
14:49:14.821307 IP lkp-tt02-nic2.tsp.org.12865 > lkp-h01.tsp.org.41456:=
 P 1:257(256) ack 257 win 54 <nop,nop,timestamp 1803244 1691048>
14:49:14.821312 IP lkp-h01.tsp.org.41456 > lkp-tt02-nic2.tsp.org.12865:=
 . ack 257 win 54 <nop,nop,timestamp 1691048 1803244>
14:49:14.821348 IP lkp-h01.tsp.org.54226 > lkp-tt02-nic2.tsp.org.42164:=
 UDP, length 1
14:49:14.821406 IP lkp-tt02-x8664.tsp.org.42164 > lkp-h01.tsp.org.54226=
: UDP, length 1
14:49:14.821415 IP lkp-h01.tsp.org > lkp-tt02-x8664.tsp.org: ICMP lkp-h=
01.tsp.org udp port 54226 unreachable, length 37

=EF=BB=BF
If I use tcpdump to intercept all packets on eth1 on Server1, the dump =
shows:
23:54:12.320760 IP lkp-h01.tsp.org.41456 > lkp-tt02-nic2.tsp.org.12865:=
 S 2825016431:2825016431(0) win 5840 <mss 1460,sackOK,timestamp 1691048=
 0,nop,wscale 7>
23:54:12.320858 IP lkp-h01.tsp.org.41456 > lkp-tt02-nic2.tsp.org.12865:=
 . ack 1965002601 win 46 <nop,nop,timestamp 1691048 1803244>
23:54:12.321010 IP lkp-h01.tsp.org.41456 > lkp-tt02-nic2.tsp.org.12865:=
 P 0:256(256) ack 1 win 46 <nop,nop,timestamp 1691048 1803244>
23:54:12.321259 IP lkp-h01.tsp.org.41456 > lkp-tt02-nic2.tsp.org.12865:=
 . ack 257 win 54 <nop,nop,timestamp 1691048 1803244>
23:54:12.321271 IP lkp-h01.tsp.org.54226 > lkp-tt02-nic2.tsp.org.42164:=
 UDP, length 1


If I start netperf by below command:
=EF=BB=BF#./netperf -t UDP_RR -l 60 -H 192.168.1.160 -L 192.168.1.164 -=
i 3,3 -I 99,5 -- -r 1,1
The testing really goes ahead and prints correct result after testing. =
However, tcpdump shows
the packets just pass between lkp-h01.tsp.org.50303 and lkp-tt02-x8664.=
tsp.org.41305, not
lkp-h01=EF=BB=BF-nic2.tsp.org.50303 and lkp-tt02-x8664.tsp.org.41305

I check source codes of netperf and send_udp_rr really binds the correc=
t local/host IP.

I tries TCP_RR and it has no hang issue although packets might be sent =
out from another IP.

I tested it with kernel 2.6.22/23/24/25.

Thanks,
Yanmin


