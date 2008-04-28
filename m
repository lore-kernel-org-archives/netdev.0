From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Subject: RE: netperf udp_rr testing hang
Date: Mon, 28 Apr 2008 11:43:20 +0800
Message-ID: <1209354200.2873.11.camel@ymzhang>
References: <1209109343.28819.37.camel@ymzhang>
	 <36D9DB17C6DE9E40B059440DB8D95F520507661D@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga10.intel.com ([192.55.52.92]:37543 "EHLO
	fmsmga102.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1762197AbYD1Dpc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2008 23:45:32 -0400
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F520507661D@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sun, 2008-04-27 at 16:47 -0700, Brandeburg, Jesse wrote:=20
Thanks for your kind response. I think it might be an issue of kernel. =
Pls. see below comments.

> are you turning on arp_filter in sysctl?
No. I use the default configuration, i.e. arp_filter=3D0.

>=20
> IMO you can't use two IP addresses in the same subnet on the same swi=
tch anyway, even with arp filter.
>=20
> if you were to assign 192.168.0.X to one interface and 192.168.1.X to=
 the other, *and* then use arp filter it will work okay.
Why does TCP work well? Lab manager just configures 192.168.0.XXX on th=
e dns server.

I tried =EF=BB=BFarp_filter=3D1 a moment ago and it doesn't work.

I checked document e1000.txt and it says Multiple Interfaces on Same Et=
hernet Broadcast Network
results in unbalanced receive traffic. But it doesn't say it will break=
 the network.

>From the tcpdump info, I think kernel on the client machine always dro=
ps the first UDP packet unexpectedly, after
the server (=EF=BB=BF=EF=BB=BFlkp-tt02-nic2.tsp.org) sends the first UD=
P response back. If I disable =EF=BB=BF192.168.1.160 (eth0:=EF=BB=BFlkp=
-tt02-x8664.tsp.org)
on server, the testing could go ahead. That also means the issue isn't =
relevant to arp_filter. If I firstly disable
=EF=BB=BF192.168.1.160 (eth0:=EF=BB=BFlkp-tt02-x8664.tsp.org) and then =
reenable it, restart testing, the testing also could go ahead, but then
the testing to IP =EF=BB=BF192.168.1.160 becomes hanging. So it looks l=
ike only one ip at the same time could be
available for UDP.

>=20
> jesse=20
>=20
> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.o=
rg] On Behalf Of Zhang, Yanmin
> Sent: Friday, April 25, 2008 12:42 AM
> To: netdev@vger.kernel.org
> Cc: Rick Jones
> Subject: netperf udp_rr testing hang
>=20
> I am testing network UDP by netperf V2.4.4.
>=20
> I have 2 machines. Every machine has 2 NIC, so 2 IP addresses per mac=
hine.
> Client1: 192.168.1.164 (eth1:=EF=BB=BF=EF=BB=BFlkp-h01-nic2.tsp.org) =
and =EF=BB=BF192.168.1.169 (eth2:=EF=BB=BF=EF=BB=BF=EF=BB=BFlkp-h01.tsp=
=2Eorg).
> Server1: 192.168.1.160 (eth0:=EF=BB=BFlkp-tt02-x8664.tsp.org) and 192=
=2E168.1.153 (eth1:=EF=BB=BFlkp-tt02-nic2.tsp.org).
>=20
> They are connected to the same GIGA switch.
>=20
> On Server1, start netserver:
> #./netserver&
>=20
> Then, on Client1: start netperf:
> #./netperf -t UDP_RR -l 60 -H 192.168.1.153 -L 192.168.1.164 -i 3,3 -=
I 99,5 -- -r 1,1
> It looks like netperf hangs and exits after 180(or 60?) seconds. The =
result shows
> RatePerSec is 0.0.
> If I use tcpdump to intercept all packets on eth1 on client1, the dum=
p shows:
> 14:49:14.820924 IP lkp-h01.tsp.org.41456 > lkp-tt02-nic2.tsp.org.1286=
5: . ack 1 win 46 <nop,nop,timestamp 1691048 1803244>
> 14:49:14.821043 IP lkp-h01.tsp.org.ssh > lkp-os.tsp.org.45485: P 176:=
368(192) ack 49 win 146 <nop,nop,timestamp 1691048 1575061177>
> 14:49:14.821047 IP lkp-h01.tsp.org.41456 > lkp-tt02-nic2.tsp.org.1286=
5: P 1:257(256) ack 1 win 46 <nop,nop,timestamp 1691048 1803244>
> 14:49:14.821157 IP lkp-tt02-nic2.tsp.org.12865 > lkp-h01.tsp.org.4145=
6: . ack 257 win 54 <nop,nop,timestamp 1803244 1691048>
> 14:49:14.821307 IP lkp-tt02-nic2.tsp.org.12865 > lkp-h01.tsp.org.4145=
6: P 1:257(256) ack 257 win 54 <nop,nop,timestamp 1803244 1691048>
> 14:49:14.821312 IP lkp-h01.tsp.org.41456 > lkp-tt02-nic2.tsp.org.1286=
5: . ack 257 win 54 <nop,nop,timestamp 1691048 1803244>
> 14:49:14.821348 IP lkp-h01.tsp.org.54226 > lkp-tt02-nic2.tsp.org.4216=
4: UDP, length 1
> 14:49:14.821406 IP lkp-tt02-x8664.tsp.org.42164 > lkp-h01.tsp.org.542=
26: UDP, length 1
> 14:49:14.821415 IP lkp-h01.tsp.org > lkp-tt02-x8664.tsp.org: ICMP lkp=
-h01.tsp.org udp port 54226 unreachable, length 37
>=20
> =EF=BB=BF
> If I use tcpdump to intercept all packets on eth1 on Server1, the dum=
p shows:
> 23:54:12.320760 IP lkp-h01.tsp.org.41456 > lkp-tt02-nic2.tsp.org.1286=
5: S 2825016431:2825016431(0) win 5840 <mss 1460,sackOK,timestamp 16910=
48 0,nop,wscale 7>
> 23:54:12.320858 IP lkp-h01.tsp.org.41456 > lkp-tt02-nic2.tsp.org.1286=
5: . ack 1965002601 win 46 <nop,nop,timestamp 1691048 1803244>
> 23:54:12.321010 IP lkp-h01.tsp.org.41456 > lkp-tt02-nic2.tsp.org.1286=
5: P 0:256(256) ack 1 win 46 <nop,nop,timestamp 1691048 1803244>
> 23:54:12.321259 IP lkp-h01.tsp.org.41456 > lkp-tt02-nic2.tsp.org.1286=
5: . ack 257 win 54 <nop,nop,timestamp 1691048 1803244>
> 23:54:12.321271 IP lkp-h01.tsp.org.54226 > lkp-tt02-nic2.tsp.org.4216=
4: UDP, length 1
>=20
>=20
> If I start netperf by below command:
> =EF=BB=BF#./netperf -t UDP_RR -l 60 -H 192.168.1.160 -L 192.168.1.164=
 -i 3,3 -I 99,5 -- -r 1,1
> The testing really goes ahead and prints correct result after testing=
=2E However, tcpdump shows
> the packets just pass between lkp-h01.tsp.org.50303 and lkp-tt02-x866=
4.tsp.org.41305, not
> lkp-h01=EF=BB=BF-nic2.tsp.org.50303 and lkp-tt02-x8664.tsp.org.41305
>=20
> I check source codes of netperf and send_udp_rr really binds the corr=
ect local/host IP.
>=20
> I tries TCP_RR and it has no hang issue although packets might be sen=
t out from another IP.
>=20
> I tested it with kernel 2.6.22/23/24/25.
>=20
> Thanks,
> Yanmin


