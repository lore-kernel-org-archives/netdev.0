From: Dilip Daya <dilip.daya@hp.com>
Subject: Re: ip_local_deliver_finish: proto 108 (IPComp) isn't netns-ready
Date: Wed, 16 Nov 2011 10:01:55 -0500
Message-ID: <1321455715.2530.27.camel@pro6455b.example.com>
References: <1320858706.2531.45.camel@pro6455b.example.com>
	 <m1d3d0oraf.fsf@fess.ebiederm.org>
Reply-To: dilip.daya@hp.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-TUR0reZ3hQhz4MwWHrXp"
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"adobrian@gmail.com" <adobrian@gmail.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1d3d0oraf.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-TUR0reZ3hQhz4MwWHrXp
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

Hi Eric,

> If you have a clue what is going on with ip compression my
> recommendation would be to add .netns_ok = 1.  Verify that the
> everything works and send the patch.  You probably want to
> verify and test ipv6 as well.  It really looks like the code
> is fine and it just needs to be enabled.

Thank you for the above feedback.

FYI..my results

Environment:
- v3.0.9-stable kernel with  ".netns_ok	= 1" applied to ipcomp.c
  (see attached patch)
- Same setup as described earlier for two netns stacks on single system.
- ltp-network test results:

- /usr/lib/ltp/testcases/bin/tcp[4|6]-multi-diffip13
  IPv4: no issues
  IPv6: no issues

- /usr/lib/ltp/testcases/bin/udp4-multi-diffip06
  IPv4 -> no issues
  IPv6 -> script issue (work-in-progress)

- /usr/lib/ltp/testcases/bin/udp[4|6]-multi-diffnic06
  IPv4: no issues
  IPv6:	no issues

- /usr/lib/ltp/testcases/bin/udp[4|6]-multi-diffport06
  IPv4 -> multiple messages:
    UDP: short packet: From 10.0.9.2:1025 1008/267 to 10.0.9.1:55575
    UDP: short packet: From 10.0.0.1:54544 253/38 to 10.0.0.2:1050
    UDP: short packet: From 10.0.0.1:21601 27128/1008 to 10.0.0.2:27137

  IPv6 -> multiple messages:
    UDPv6: short packet: From [fd00:1:1:1::2]:1028 242/122 to
[fd00:1:1:1::1]:38438
    UDPv6: short packet: From [fd00:1:1:1::2]:37972 21588/29 to
[fd00:1:1:1::1]:21588
    UDPv6: short packet: From [fd00:1:1:1::2]:1026 1008/898 to
[fd00:1:1:1::1]:55703

- /usr/lib/ltp/testcases/bin/icmp4-multi-diffip06
  IPv4 -> no issues
  IPv6 -> multiple messages:
    ICMPv6 checksum failed [fd00:0001:0000:0003:0000:0000:0000:0001 >
fd00:0001:0000:0003:0000:0000:0000:0002]
				

...continuing with debug.


--DilipD.

On Wed, 2011-11-09 at 22:38 +0000, Eric W. Biederman wrote:
> Dilip Daya <dilip.daya@hp.com> writes:
> 
> > Hi All,
> >
> > LTP-network tests produced:
> >
> > 	"ip_local_deliver_finish: proto 108 (IPComp) isn't netns-ready"
> >
> > Question:
> > Is the above a bug or feature (IPComp, mode: transport) not netns
> > enabled?
> 
> I would call it a missing feature.
> 
> > Environment:
> >
> > * v3.1-stable kernel.
> >
> > * Configured two network-namespaces via "ip netns add ...".
> >   on a single system: netns0 (assigned as server) and
> >   netns1 (assigned as client).
> >   - assigned multiple physical NICs to netns0 and netns1.
> >
> > * Entered netns1 (ip netns exec netns1 bash) to execute
> >   ltp-network suite of tests between netns1 and netns0.
> >
> > * The following LTP tests produced messages:
> >
> >   "kernel: ip_local_deliver_finish: proto 108 isn't netns-ready"
> >
> >    - /usr/lib/ltp/testcases/bin/icmp4-multi-diffip06
> >    - /usr/lib/ltp/testcases/bin/tcp4-multi-diffip13
> >    - /usr/lib/ltp/testcases/bin/udp4-multi-diffip06
> >    - /usr/lib/ltp/testcases/bin/udp4-multi-diffnic06
> >    - /usr/lib/ltp/testcases/bin/udp4-multi-diffport06
> >
> > * I also noticed missing ".netns_ok = 1" in:
> >   - http://lxr.linux.no/linux+v3.1/net/ipv4/ipcomp.c#L150
> 
> The .netns_ok flag indicates that someone has audited the code and made
> certain it all works with network namespaces.
> 
> Skimming the code I don't see anything that jumps out as me as
> wrong.  And it looks like Alexy did the work in Jan of 2010.
> 
>    commit a92df2545402c1a08e7a158f4477a52dea0eeeed
>    Author: Alexey Dobriyan <adobriyan@gmail.com>
>    Date:   Mon Jan 25 10:38:34 2010 +0000
>    
>        netns xfrm: ipcomp support
>        
>        Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
>        Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> However it is clear that no one has actually tested ipcomp with
> network namespaces.
> 
> If you have a clue what is going on with ip compression my
> recommendation would be to add .netns_ok = 1.  Verify that the
> everything works and send the patch.  You probably want to
> verify and test ipv6 as well.  It really looks like the code
> is fine and it just needs to be enabled.
> 
> Eric

--=-TUR0reZ3hQhz4MwWHrXp
Content-Disposition: attachment; filename="ipcomp_netns.patch"
Content-Type: text/x-patch; name="ipcomp_netns.patch"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

--- a/ipv4/ipcomp.c	2011-11-11 13:12:24.000000000 -0500
+++ b/net/ipv4/ipcomp.c	2011-11-08 09:12:37.000000000 -0500
@@ -151,6 +151,7 @@ static const struct net_protocol ipcomp4
 	.handler	=	xfrm4_rcv,
 	.err_handler	=	ipcomp4_err,
 	.no_policy	=	1,
+	.netns_ok		= 1,
 };

 static int __init ipcomp4_init(void)

--=-TUR0reZ3hQhz4MwWHrXp--
