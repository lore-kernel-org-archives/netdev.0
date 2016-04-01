From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net PATCH 2/2] ipv4/GRO: Make GRO conform to RFC 6864
Date: Fri, 01 Apr 2016 11:49:03 -0700
Message-ID: <1459536543.6473.289.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160401175741.13882.24175.stgit@localhost.localdomain>
	 <20160401180531.13882.44793.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, tom@herbertland.com, jesse@kernel.org,
	alexander.duyck@gmail.com, edumazet@google.com,
	netdev@vger.kernel.org, davem@davemloft.net
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35793 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751314AbcDAStG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 14:49:06 -0400
Received: by mail-pa0-f45.google.com with SMTP id td3so96899817pab.2
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 11:49:06 -0700 (PDT)
In-Reply-To: <20160401180531.13882.44793.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-04-01 at 11:05 -0700, Alexander Duyck wrote:
> RFC 6864 states that the IPv4 ID field MUST NOT be used for purposes other
> than fragmentation and reassembly.  Currently we are looking at this field
> as a way of identifying what frames can be aggregated and  which cannot for
> GRO.  While this is valid for frames that do not have DF set, it is invalid
> to do so if the bit is set.
> 
> In addition we were generating IPv4 ID collisions when 2 or more flows were
> interleaved over the same tunnel.  To prevent that we store the result of
> all IP ID checks via a "|=" instead of overwriting previous values.

Note that for atomic datagrams (DF = 1), since fragmentation and
reassembly can not occur, maybe some people use ID field for other
purposes.

For example, TCP stack tracks per socket ID generation, even if it sends
DF=1 frames. Damn useful for tcpdump analysis and drop inference.


With your change, the resulting GRO packet would propagate the ID of
first frag. Most GSO/GSO engines will then provide a ID sequence, which
might not match original packets.

I do not particularly care, but it is worth mentioning that GRO+TSO
would not be idempotent anymore.
