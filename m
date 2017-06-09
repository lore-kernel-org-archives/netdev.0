From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net-next v2 3/3] udp: try to avoid 2 cache miss on
 dequeue
Date: Fri, 09 Jun 2017 17:44:29 +0200
Message-ID: <1497023069.3416.18.camel@redhat.com>
References: <cover.1496756090.git.pabeni@redhat.com>
         <cdbe7b4e6758719d3e02938f05c8575d009e2822.1496756090.git.pabeni@redhat.com>
         <1496822205.2409.1.camel@redhat.com>
         <20170607.101056.833234534371053047.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35632 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751534AbdFIPob (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Jun 2017 11:44:31 -0400
In-Reply-To: <20170607.101056.833234534371053047.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, 2017-06-07 at 10:10 -0400, David Miller wrote:
> From: Paolo Abeni <pabeni@redhat.com>
> Date: Wed, 07 Jun 2017 09:56:45 +0200
> 
> > Hi David,
> > 
> > On Tue, 2017-06-06 at 16:23 +0200, Paolo Abeni wrote:
> >> when udp_recvmsg() is executed, on x86_64 and other archs, most skb
> >> fields are on cold cachelines.
> >> If the skb are linear and the kernel don't need to compute the udp
> >> csum, only a handful of skb fields are required by udp_recvmsg().
> >> Since we already use skb->dev_scratch to cache hot data, and
> >> there are 32 bits unused on 64 bit archs, use such field to cache
> >> as much data as we can, and try to prefetch on dequeue the relevant
> >> fields that are left out.
> >> 
> >> This can save up to 2 cache miss per packet.
> >> 
> >> v1 -> v2:
> >>   - changed udp_dev_scratch fields types to u{32,16} variant,
> >>     replaced bitfield with bool
> >> 
> >> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> > 
> > Can you please keep on-hold this series a little time? the lkp-robot
> > just reported a performance regression on v1 which I have still to
> > investigate. I can't look at it really soon, but I expect the same
> > should apply to v2.
> > 
> > It sounds quite weird to me, since the bisected patch touches the UDP
> > code only and the regression is on apachebench.
> 
> Hmmm, DNS lookups?
> 
> Thanks for looking into this.

I spent a little time trying to reproduce the regression. There are not
 DNS requests during the test, because it's done against the loopback
address (verified with perf probe on UDP code).

I collected several samples for both the patched and vanilla kernels,
and I measured a lot of variance (while using the same kernel) - well
above 21% - and a similar results distribution when comparing vanilla
to patched kernel. 

I notified the lkp ML of the above, and I think this is actually a
test-suite artifact.

I'll re-submit v3 unchanged, if there are no objections.

Cheers,

Paolo
