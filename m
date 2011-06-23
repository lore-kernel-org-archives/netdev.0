From: David Miller <davem@davemloft.net>
Subject: Re: unintended ipv4 broadcast policy change
Date: Wed, 22 Jun 2011 22:41:44 -0700 (PDT)
Message-ID: <20110622.224144.671030256188122882.davem@davemloft.net>
References: <20110622.163935.2248705300315908767.davem@davemloft.net>
	<20110623004134.GA22314@gondor.apana.org.au>
	<20110622.194158.820637934689036237.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.hengli.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60862 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752368Ab1FWFmB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2011 01:42:01 -0400
In-Reply-To: <20110622.194158.820637934689036237.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 22 Jun 2011 19:41:58 -0700 (PDT)

> From: Herbert Xu <herbert@gondor.hengli.com.au>
> Date: Thu, 23 Jun 2011 08:41:34 +0800
> 
>> On Wed, Jun 22, 2011 at 04:39:35PM -0700, David Miller wrote:
>>> This subtle new behavior is interesting because it means that
>>> a DHCP client could be implemented entirely with plain UDP
>>> sockets.
>> 
>> Yes this is indeed possible.  However, for compatibility purposes
>> I'm not sure whether we can safely rely on this new behaviour.
>> Maybe if we add the disable_ipv4 sysctl we can use it to signal
>> the presence of this new behaviour.
> 
> The easiest thing to do is to have the DHCP server first go:
> 
> 	ip addr add 0.0.0.0/0 broadcast 255.255.255.255 dev $(DEVICE)
> 
> and in fact this is essentially what ISC DHCP does on NetBSD and
> similar.

Except that my experiments show that we don't allow this.

In fact, it fails silently because of the code in __inet_insert_ifa()
that goes:

	if (!ifa->ifa_local) {
		inet_free_ifa(ifa);
		return 0;
	}

Sigh...

The only problematic case is receiving the initial broadcast
responses.

Sends are easy because if you use SO_BINDTODEVICE and MSG_DONTROUTE we
can convince the kernel to build us a route, even if no addresses and
routes are configured on the interface.

Will think about this some more.
