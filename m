From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: vpnc-script fix for changed iproute output with newer kernels
Date: Fri, 29 Jul 2011 22:26:36 +0100
Message-ID: <1311974797.20983.0.camel@i7.infradead.org>
References: <20110728021227.GA3620@gmail.com>
	 <20110728021853.GB3620@gmail.com>
	 <1311942793.17528.57.camel@i7.infradead.org>
	 <20110729.054649.1274733167127164255.davem@davemloft.net>
	 <1311944244.17528.76.camel@i7.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jsbronder@gentoo.org, netdev@vger.kernel.org, shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:51119 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752838Ab1G2V0m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2011 17:26:42 -0400
In-Reply-To: <1311944244.17528.76.camel@i7.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-07-29 at 13:57 +0100, David Woodhouse wrote:
> > You're going to have to be knowledgable about which attributes are
> > part of the route, whether you want to do this with iproute2 as a tool
> > or whether you do this directly with C code using netlink.
> 
> I don't think I really want to try shipping vpnc-script with C code.
> 
> The 'opt-in' approach seems like the best one for now, then. I suppose
> we want just the 'via' and 'dev' and 'src' attributes... anything else?

This should do it for now, I suppose:

--- a/vpnc-script
+++ b/vpnc-script
@@ -139,8 +139,9 @@ destroy_tun_device() {
 
 if [ -n "$IPROUTE" ]; then
 	fix_ip_get_output () {
-		sed 's/cache//;s/metric \?[0-9]\+ [0-9]\+//g;s/hoplimit [0-9]\+//g;s/ipid 0x....//g'
+		sed -e 's/ /\n/g' | \
+		    sed -ne '1p;/via/{N;p};/dev/{N;p};/src/{N;p};/mtu/{N;p}'
 	}
 
 	set_vpngateway_route() {
 		$IPROUTE route add `$IPROUTE route get "$VPNGATEWAY" | fix_ip_get_output`

I'm still not happy with it, since I'm not 100% convinced I'm
preserving all the attributes that need to be preserved, and will need
to be preserved in future. I managed to keep 'src', but what else might
there be? I just don't want to have to know.

On trying to torture-test it, I also noticed that 'ip route get' doesn't
do what I'd want in the case of the following route:

default  src 90.155.92.214 
	nexthop via 81.2.98.173  dev eth1 weight 1
	nexthop dev ppp1 weight 1
[root@solos ~]# ip route get 131.111.8.42
131.111.8.42 via 81.2.98.173 dev eth1  src 90.155.92.214 
    cache  mtu 1500 advmss 1460 hoplimit 64


-- 
dwmw2


