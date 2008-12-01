From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [RFC PATCH 0/5] IPsec parallelization
Date: Mon, 1 Dec 2008 08:16:14 +0100
Message-ID: <20081201071614.GP476@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, herbert@gondor.apana.org.au,
	klassert@mathematik.tu-chemnitz.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([213.68.205.161]:46523 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750824AbYLAHsU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Dec 2008 02:48:20 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a first throw to try to parallelize the expensive part of xfrm by
using a generic parallelization/serialization method. This method uses the
remote softirq invocation infrastructure for parallelization and serialization.
With this method data objects can be processed in parallel, starting 
at some given point. After doing some expensive operations in parallel, 
it is possible to serialize again. The parallelized data objects return after
serialization in the order as they were before the parallelization. 
In the case of xfrm, this makes it possible to run the expensive part in
parallel without getting packet reordering.
 
To use this parallelization method for xfrm, some changes in the crypto system
were necessary. First of all, we need to force disabling async crypto transforms
in the parallelization case, because we can't guarantee the packet order if
the packets are put to a queue during the parallel processing.
A second thing was a very high contended lock in crypto_authenc_hash() if
the crypto system runs in parallel. To get rid of this, the struct aead is
moved to percpu data, what in turn means that we have percpu IV chains now.
However, I'm not that familiar with the crypto system. So I'm not sure whether
this is acceptable as I did it, this needs review.

I did forwarding tests with two quad core machines (Intel Core 2 Quad Q6600) 
used as IPsec routers (xfrm tunnel between the two quad core machines) and two
notebooks T61 used as traffic generators.
With this testing environment I'm geting a throughput up to 910 Mbit/s (ipv4)
and 880 Mbit/s (ipv6) with aes192-sha1 encryption (measured with iperf,
_one_ tcp stream). Without the parallelization I'm getting with the same
environment about 340 Mbit/s (ipv4) and 320 Mbit/s (ipv6).

If somebody wants to test it, the parallelization is switched off by default.
To enable it, do 'echo 1 > /proc/sys/net/core/xfrm_padata'.

Steffen
