From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] net: Toeplitz library functions
Date: Mon, 23 Sep 2013 17:03:11 -0700
Message-ID: <1379980991.3165.37.camel@edumazet-glaptop>
References: <alpine.DEB.2.02.1309231535030.23896@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:52864 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752446Ab3IXADN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 20:03:13 -0400
Received: by mail-pa0-f47.google.com with SMTP id kp14so2909837pab.6
        for <netdev@vger.kernel.org>; Mon, 23 Sep 2013 17:03:13 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1309231535030.23896@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-09-23 at 15:41 -0700, Tom Herbert wrote:

> +#ifdef CONFIG_NET_TOEPLITZ
> +	toeplitz_net = toeplitz_alloc();
> +	if (!toeplitz_net)
> +		goto out;
> +
> +	toeplitz_init(toeplitz_net, NULL);
> +#endif
> +

Hmm

1) Security alert here.

Many devices (lets say Android phones) have no entropy at this point,
all devices will have same toeplitz key.

Check build_ehash_secret() for a possible point for the feeding of the
key. (and commit 08dcdbf6a7b9d14c2302c5bd0c5390ddf122f664 )

If hardware toeplitz is ever used, we want to make sure every host uses
a private and hidden Toeplitz key.

2) Also it seems a given tuple would hash the same on different
namespaces. Could be a problem if one particular TCP hash bucket is
holding thousand of sockets.

3) jhash() is fast, there is no possible cache line misses

  With your implementation, toeplitz hashing 36 bytes could have a cost
of 36 additional cache line misses.

You do not see that on TCP_RR test because cpu caches are preloaded, but
it will show on latency sensitive workload.
