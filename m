From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH v2 1/3] bpf: Use 1<<16 as ceiling for immediate alignment
 in verifier.
Date: Thu, 18 May 2017 15:49:52 +0100
Message-ID: <c8e4ce49-5707-3d6d-c8c2-80dd8335d981@solarflare.com>
References: <20170515.120431.1588221938554447723.davem@davemloft.net>
 <754f2c39-fdb0-2407-c2f2-aa36d506d202@solarflare.com>
 <f2bff26d-8b4d-c6a2-23c9-9db198569e40@fb.com>
 <50288778-10f6-7201-c979-bfe4635831fc@solarflare.com>
 <e873f261-e1c1-c344-3d72-254623e0c91a@solarflare.com>
 <97910214-213c-c5c6-4a02-adc16cd836aa@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: <alexei.starovoitov@gmail.com>, <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@fb.com>,
        David Miller <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([67.231.154.164]:48921 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932227AbdEROuI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 10:50:08 -0400
In-Reply-To: <97910214-213c-c5c6-4a02-adc16cd836aa@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18/05/17 03:48, Alexei Starovoitov wrote:
> Would it be easier to represent this logic via (mask_of_unknown, value)
> instead of (mask0, mask1) ?
Yes, I like this.
> As far as upper bits we can tweak the algorithm to eat into
> one or more bits of known bits due to carry.
> Like
> 00xx11 + 00xx11 = 0xxx10
> we will eat only one bit (second from left) and the highest bit
> is known to stay zero, since carry can only compromise 2nd from left.
> Such logic should work for sparse representation of unknown bits too
> Like:
> 10xx01xx10 +
> 01xx01xx00 =
> xxxx1xxx10
> both upper two bits would be unknown, but only one middle bit becomes
> unknown.
Yes, that is the behaviour we want.  But it's unclear how to efficiently
 compute it, without just iterating over the bits and computing carry
 possibilities.
Here's one idea that seemed to work when I did a couple of experiments:
let A = (a;am), B = (b;bm) where the m are the masks
Σ = am + bm + a + b
χ = Σ ^ (a + b) /* unknown carries */
μ = χ | am | bm /* mask of result */
then A + B = ((a + b) & ~μ; μ)

The idea is that we find which bits change between the case "all x are
 1" and "all x are 0", and those become xs too.  But I'm not certain
 that that's always going to cover all possible values in between.
It worked on the tests I came up with, and also your example above, but
 I can't quite prove it'll always work.

-Ed
