From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: ipsec smp scalability and cpu use fairness (softirqs)
Date: Tue, 13 Aug 2013 09:46:14 +0200
Message-ID: <20130813074614.GM25511@secunet.com>
References: <20130812160142.71737a95@vostro>
 <CAKTPYJTVhvF=215eS0xriEdUyyCLaC+zzja4zPrG668ALzERyw@mail.gmail.com>
 <20130813092312.2493354e@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Collins <bsderandrew@gmail.com>, netdev@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:39832 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752223Ab3HMHqR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Aug 2013 03:46:17 -0400
Content-Disposition: inline
In-Reply-To: <20130813092312.2493354e@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 13, 2013 at 09:23:12AM +0300, Timo Teras wrote:
> 
> For my scenario it will be usually even same SPI. So even if flow
> dissector learns ESP and uses SPI in hash, I'd need a way to balance
> traffic to multiple SAs.
> 
> I guess the place where I'd want to see the distribution to cores is
> crypto_aead_*() calls. In fact, it seems there's code infracture
> already for it: crypto/cryptd.c. Seems it needs to be manually
> configured and only few places e.g. aesni gcm parts use it.
> 
> I'm wondering if it'd make sense to patch net/xfrm/xfrm_algo.c to use
> cryptd? Or at least have a Kconfig or sysctl option make it do so.
> 

It is possible to configure the used crypto algorithm from userspace
with the crypto user configuration API, see crypto/crypto_user.c.

I wrote to tool that usses this API some time ago, it is still
a bit rudimentary but it does the job. You can find it at:
https://sourceforge.net/projects/crconf/

Also, if you want parallelism, you could use the pcrypt algorithm.
It sends the crypto requests asynchronously round robin to a
configurable set of cpus. Finaly it takes care to bring the
served crypto requests back into the order they were submitted
to avoid packet reordering.

Currently we have only one systemwide workqueue for encryption
and one decryption. So all IPsec packets are send to the same
workqueue, regardless which state they use.

I have patches that make it possible to configure a separate
workqueue for each state or to group some states to a specific
workqueue. These patches are still unpublished because they
have not much testing yet, but I could send them after some
polishing for review or testing if you are interested.
