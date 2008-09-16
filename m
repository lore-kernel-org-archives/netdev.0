From: "Bosko Radivojevic" <bosko.radivojevic@gmail.com>
Subject: Re: GRE keepalives, again
Date: Tue, 16 Sep 2008 02:20:53 +0200
Message-ID: <d6c8ef150809151720o73528dcfqcc7358c244005fa6@mail.gmail.com>
References: <d6c8ef150809141549m52289f1cr7b4da508b311af1f@mail.gmail.com>
	 <20080914.170302.132520341.davem@davemloft.net>
	 <d6c8ef150809150445qbd16c5ap7923468008477705@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <d6c8ef150809150445qbd16c5ap7923468008477705@mail.gmail.com>
Content-Disposition: inline
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi again.

Problem is - fib_validate_source() explicitly doesn't allow any local
address to be specified as source address. I figured out I'm not the
first in need for different behavior. One of the solutions I've found
is forward_shared patch
[http://www.ssi.bg/~ja/forward_shared-2.6.25-2.diff] which exists for
centuries. Actually, it is not working for me but it is addressing the
same thing - forwarding packets with local addresses.

I've solved my problem (Cisco's GRE keepalive and Linux) with this small change:

--- linux-2.6.26.3/net/ipv4/fib_frontend.c-orig	2008-09-16
01:50:07.000000000 +0200
+++ linux-2.6.26.3/net/ipv4/fib_frontend.c	2008-09-16 01:50:27.000000000 +0200
@@ -260,7 +260,7 @@ int fib_validate_source(__be32 src, __be
 	net = dev_net(dev);
 	if (fib_lookup(net, &fl, &res))
 		goto last_resort;
-	if (res.type != RTN_UNICAST)
+	if ((res.type != RTN_UNICAST) && !((res.type == RTN_LOCAL) &&
(dev->type == ARPHRD_IPGRE))) {
 		goto e_inval_res;
 	*spec_dst = FIB_RES_PREFSRC(res);
 	fib_combine_itag(itag, &res);
----------------------------------------------------------------------

I'm pretty sure this is not the right solution, if there is a need for
'solution' at all. Maybe this behavior is what we need and there is no
real need to ever forward packets coming with local source address. I
failed to find a way to test if destination address is remote end of
GRE tunnel.

I found another strange (for me, at least) thing -
ip_route_input_slow() is discarding packets if "IP is not enabled" on
the device. The only way to "enable IP" on IP_GRE interface is to
assign it an IP. Is there another way of "enabling IP" on IP_GRE
interface? I think there is no much need for assigning an IP address
to GRE interface. Am I wrong here? IP should be 'enabled' by default
for IP_GRE interfaces.

PS. Of course, I order this forwarding of encapsulated packets with
local source address to work, GRE tunnel must be created, GRE
interface have to be UP with IP address assigned and with forwarding
enabled.

Sincerely,
Bosko
