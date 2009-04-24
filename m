From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: [1/2] tun: Only free a netdev when all tun descriptors are closed
Date: Fri, 24 Apr 2009 10:55:49 +0200
Message-ID: <200904241055.49794.borntraeger@de.ibm.com>
References: <20090415083610.GA8579@gondor.apana.org.au> <20090415143834.GA12384@gondor.apana.org.au> <20090416110818.GA20950@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Patrick McHardy <kaber@trash.net>,
	Matias Zabaljauregui <zabaljauregui@gmail.com>, odie@cs.aau.dk,
	Rusty Russell <rusty@rustcorp.com.au>, lguest@ozlabs.org,
	virtualization@lists.osdl.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Carsten Otte <cotte@de.ibm.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:38475 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753061AbZDXIzz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2009 04:55:55 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.14.3/8.13.8) with ESMTP id n3O8tpQ6119140
	for <netdev@vger.kernel.org>; Fri, 24 Apr 2009 08:55:52 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3O8tpx83477574
	for <netdev@vger.kernel.org>; Fri, 24 Apr 2009 10:55:51 +0200
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3O8todN028142
	for <netdev@vger.kernel.org>; Fri, 24 Apr 2009 10:55:51 +0200
In-Reply-To: <20090416110818.GA20950@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Thursday 16 April 2009 13:08:18 schrieb Herbert Xu:
> On Wed, Apr 15, 2009 at 10:38:34PM +0800, Herbert Xu wrote:
> > 
> > So how about this? We replace the dev destructor with our own that
> > doesn't immediately call free_netdev.  We only call free_netdev once
> > all tun fd's attached to the device have been closed.
> 
> Here's the patch.  I'd appreciate if everyone can review it
> and see if they can recreate the original race by
> 
> 1) Starting a process using tun and polls on it;
> 2) Doing ip tun del tunXXX while the process is polling.
> 
> tun: Only free a netdev when all tun descriptors are closed
> 
> The commit c70f182940f988448f3c12a209d18b1edc276e33 ("tun: Fix
> races between tun_net_close and free_netdev") fixed a race where
> an asynchronous deletion of a tun device can hose a poll(2) on
> a tun fd attached to that device.

Sorry for the late reply, but this patch creates another regression:
Now TUNSETIFF returns EBUSY on a persistent tap device:

open("/dev/net/tun", O_RDWR) = 11
ioctl(11, 0x400454ca, 0x3ffff8e2270) = -1 EBUSY (Device or resource busy)

Some debugging (thanks to Carsten Otte) showed that

tun_set_iff calls tun_attach (the first call inside the if(dev)). tun_attach
now checks for tun->tfile but this is already set.
Looks like we need another fix on top :-(

Christian
