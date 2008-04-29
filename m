From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Subject: RE: netperf udp_rr testing hang
Date: Tue, 29 Apr 2008 17:27:58 +0800
Message-ID: <1209461278.2873.34.camel@ymzhang>
References: <1209109343.28819.37.camel@ymzhang>
	 <36D9DB17C6DE9E40B059440DB8D95F520507661D@orsmsx418.amr.corp.intel.com>
	 <1209354200.2873.11.camel@ymzhang>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Rick Jones <rick.jones2@hp.com>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:60870 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751585AbYD2Ja1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2008 05:30:27 -0400
In-Reply-To: <1209354200.2873.11.camel@ymzhang>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-04-28 at 11:43 +0800, Zhang, Yanmin wrote:
> On Sun, 2008-04-27 at 16:47 -0700, Brandeburg, Jesse wrote:=20
> Thanks for your kind response. I think it might be an issue of kernel=
=2E Pls. see below comments.
I located the root cause.
kernel is ok. It's an issue of netperf.

I instrumented kernel and turn on netperf debug to capture more data.
As a matter of fact, netserver on the Server1 machine binds ip 0.0.0.0 =
and the port to
receive UDP packets, but netperf on Client1 machine binds ip =EF=BB=BF1=
92.168.1.164 by bind and
remote ip =EF=BB=BF192.168.1.153 by connect. When Server1 sends back a =
response, it just chooses
one ip of Server1 as the source ip to send out the packets, because ser=
ver socket just binds
=EF=BB=BF0.0.0.0. So kernel on Client1 just drops the packets.

The fix could be one of them:
1) Don't call connect in netperf for UDP testing; But it looks like the=
 transactions just pass
from one interface, not distributed on the 2 interface;
2) Pass remote_ip to server by udp_rr_request;

1 is more simple.

-yanmin

>=20
> > are you turning on arp_filter in sysctl?
> No. I use the default configuration, i.e. arp_filter=3D0.
>=20
> >=20
> > IMO you can't use two IP addresses in the same subnet on the same s=
witch anyway, even with arp filter.
> >=20
> > if you were to assign 192.168.0.X to one interface and 192.168.1.X =
to the other, *and* then use arp filter it will work okay.
> Why does TCP work well? Lab manager just configures 192.168.0.XXX on =
the dns server.
>=20
> I tried =EF=BB=BFarp_filter=3D1 a moment ago and it doesn't work.
>=20
> I checked document e1000.txt and it says Multiple Interfaces on Same =
Ethernet Broadcast Network
> results in unbalanced receive traffic. But it doesn't say it will bre=
ak the network.
>=20
> >From the tcpdump info, I think kernel on the client machine always d=
rops the first UDP packet unexpectedly, after
> the server (=EF=BB=BF=EF=BB=BFlkp-tt02-nic2.tsp.org) sends the first =
UDP response back. If I disable =EF=BB=BF192.168.1.160 (eth0:=EF=BB=BFl=
kp-tt02-x8664.tsp.org)
> on server, the testing could go ahead. That also means the issue isn'=
t relevant to arp_filter. If I firstly disable
> =EF=BB=BF192.168.1.160 (eth0:=EF=BB=BFlkp-tt02-x8664.tsp.org) and the=
n reenable it, restart testing, the testing also could go ahead, but th=
en
> the testing to IP =EF=BB=BF192.168.1.160 becomes hanging. So it looks=
 like only one ip at the same time could be
> available for UDP.
>=20
> >=20
> > jesse=20
> >=20
> > -----Original Message-----
> > From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel=
=2Eorg] On Behalf Of Zhang, Yanmin
> > Sent: Friday, April 25, 2008 12:42 AM
> > To: netdev@vger.kernel.org
> > Cc: Rick Jones
> > Subject: netperf udp_rr testing hang
> >=20
> > I am testing network UDP by netperf V2.4.4.
> >=20
> > I have 2 machines. Every machine has 2 NIC, so 2 IP addresses per m=
achine.
> > Client1: 192.168.1.164 (eth1:=EF=BB=BF=EF=BB=BFlkp-h01-nic2.tsp.org=
) and =EF=BB=BF192.168.1.169 (eth2:=EF=BB=BF=EF=BB=BF=EF=BB=BFlkp-h01.t=
sp.org).
> > Server1: 192.168.1.160 (eth0:=EF=BB=BFlkp-tt02-x8664.tsp.org) and 1=
92.168.1.153 (eth1:=EF=BB=BFlkp-tt02-nic2.tsp.org).
> >=20
> > They are connected to the same GIGA switch.
> >=20
> > On Server1, start netserver:
> > #./netserver&
> >=20
> > Then, on Client1: start netperf:
> > #./netperf -t UDP_RR -l 60 -H 192.168.1.153 -L 192.168.1.164 -i 3,3=
 -I 99,5 -- -r 1,1
> > It looks like netperf hangs and exits after 180(or 60?) seconds. Th=
e result shows
> > RatePerSec is 0.0.
> > If I use tcpdump to intercept all packets on eth1 on client1, the d=
ump shows:
> > 14:49:14.820924 IP lkp-h01.tsp.org.41456 > lkp-tt02-nic2.tsp.org.12=
865: . ack 1 win 46 <nop,nop,timestamp 1691048 1803244>
> > 14:49:14.821043 IP lkp-h01.tsp.org.ssh > lkp-os.tsp.org.45485: P 17=
6:368(192) ack 49 win 146 <nop,nop,timestamp 1691048 1575061177>
> > 14:49:14.821047 IP lkp-h01.tsp.org.41456 > lkp-tt02-nic2.tsp.org.12=
865: P 1:257(256) ack 1 win 46 <nop,nop,timestamp 1691048 1803244>
> > 14:49:14.821157 IP lkp-tt02-nic2.tsp.org.12865 > lkp-h01.tsp.org.41=
456: . ack 257 win 54 <nop,nop,timestamp 1803244 1691048>
> > 14:49:14.821307 IP lkp-tt02-nic2.tsp.org.12865 > lkp-h01.tsp.org.41=
456: P 1:257(256) ack 257 win 54 <nop,nop,timestamp 1803244 1691048>
> > 14:49:14.821312 IP lkp-h01.tsp.org.41456 > lkp-tt02-nic2.tsp.org.12=
865: . ack 257 win 54 <nop,nop,timestamp 1691048 1803244>
> > 14:49:14.821348 IP lkp-h01.tsp.org.54226 > lkp-tt02-nic2.tsp.org.42=
164: UDP, length 1
> > 14:49:14.821406 IP lkp-tt02-x8664.tsp.org.42164 > lkp-h01.tsp.org.5=
4226: UDP, length 1
> > 14:49:14.821415 IP lkp-h01.tsp.org > lkp-tt02-x8664.tsp.org: ICMP l=
kp-h01.tsp.org udp port 54226 unreachable, length 37
> >=20
> > =EF=BB=BF
> > If I use tcpdump to intercept all packets on eth1 on Server1, the d=
ump shows:
> > 23:54:12.320760 IP lkp-h01.tsp.org.41456 > lkp-tt02-nic2.tsp.org.12=
865: S 2825016431:2825016431(0) win 5840 <mss 1460,sackOK,timestamp 169=
1048 0,nop,wscale 7>
> > 23:54:12.320858 IP lkp-h01.tsp.org.41456 > lkp-tt02-nic2.tsp.org.12=
865: . ack 1965002601 win 46 <nop,nop,timestamp 1691048 1803244>
> > 23:54:12.321010 IP lkp-h01.tsp.org.41456 > lkp-tt02-nic2.tsp.org.12=
865: P 0:256(256) ack 1 win 46 <nop,nop,timestamp 1691048 1803244>
> > 23:54:12.321259 IP lkp-h01.tsp.org.41456 > lkp-tt02-nic2.tsp.org.12=
865: . ack 257 win 54 <nop,nop,timestamp 1691048 1803244>
> > 23:54:12.321271 IP lkp-h01.tsp.org.54226 > lkp-tt02-nic2.tsp.org.42=
164: UDP, length 1
> >=20
> >=20
> > If I start netperf by below command:
> > =EF=BB=BF#./netperf -t UDP_RR -l 60 -H 192.168.1.160 -L 192.168.1.1=
64 -i 3,3 -I 99,5 -- -r 1,1
> > The testing really goes ahead and prints correct result after testi=
ng. However, tcpdump shows
> > the packets just pass between lkp-h01.tsp.org.50303 and lkp-tt02-x8=
664.tsp.org.41305, not
> > lkp-h01=EF=BB=BF-nic2.tsp.org.50303 and lkp-tt02-x8664.tsp.org.4130=
5
> >=20
> > I check source codes of netperf and send_udp_rr really binds the co=
rrect local/host IP.
> >=20
> > I tries TCP_RR and it has no hang issue although packets might be s=
ent out from another IP.
> >=20
> > I tested it with kernel 2.6.22/23/24/25.
> >=20
> > Thanks,
> > Yanmin
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

