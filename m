From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: DNS (?) not working on G5 (64-bit powerpc) (was
 [net-next,v3,3/3] udp: try to avoid 2 cache miss on dequeue)
Date: Thu, 22 Jun 2017 18:43:55 +0200
Message-ID: <1498149835.2503.1.camel@redhat.com>
References: <87shisqihz.fsf@concordia.ellerman.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org
To: Michael Ellerman <mpe@ellerman.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51620 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752123AbdFVQoE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Jun 2017 12:44:04 -0400
In-Reply-To: <87shisqihz.fsf@concordia.ellerman.id.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-06-22 at 23:06 +1000, Michael Ellerman wrote:
> Paolo wrote:
> > when udp_recvmsg() is executed, on x86_64 and other archs, most skb
> > fields are on cold cachelines.
> > If the skb are linear and the kernel don't need to compute the udp
> > csum, only a handful of skb fields are required by udp_recvmsg().
> > Since we already use skb->dev_scratch to cache hot data, and
> > there are 32 bits unused on 64 bit archs, use such field to cache
> > as much data as we can, and try to prefetch on dequeue the relevant
> > fields that are left out.
> > 
> > This can save up to 2 cache miss per packet.
> > 
> > v1 -> v2:
> >   - changed udp_dev_scratch fields types to u{32,16} variant,
> >     replaced bitfiled with bool
> > 
> > Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> > Acked-by: Eric Dumazet <edumazet@google.com>
> > ---
> >  net/ipv4/udp.c | 114 +++++++++++++++++++++++++++++++++++++++++++++++++++------
> >  1 file changed, 103 insertions(+), 11 deletions(-)
> 
> This appears to break wget on one of my machines.
> 
> Networking in general is working, I'm able to SSH in, but then I can't
> do a wget.
> 
> eg:
> 
> $ wget google.com
> --2017-06-22 22:45:39--  http://google.com/
> Resolving proxy.pmdw.com (proxy.pmdw.com)... failed: Temporary failure in name resolution.
> wget: unable to resolve host address ‘proxy.pmdw.com’
> 
> $ host proxy.pmdw.com
> proxy.pmdw.com is an alias for raven.pmdw.com.
> raven.pmdw.com has address 10.1.2.3
> 
> $ wget google.com
> --2017-06-22 22:52:08--  http://google.com/
> Resolving proxy.pmdw.com (proxy.pmdw.com)... failed: Temporary failure in name resolution.
> wget: unable to resolve host address ‘proxy.pmdw.com’
> 
> Maybe host is using TCP but the man page says it doesn't?
> 
> 
> Everything is OK if I boot back to the previous commit 0a463c78d25b
> ("udp: avoid a cache miss on dequeue"):
> 
> $ wget google.com
> --2017-06-22 23:00:01--  http://google.com/
> Resolving proxy.pmdw.com (proxy.pmdw.com)... 10.1.2.3
> Connecting to proxy.pmdw.com (proxy.pmdw.com)|10.1.2.3|:3128... connected.
> Proxy request sent, awaiting response... 302 Found
> Location: http://www.google.com.au/?gfe_rd=cr&ei=Ub9LWbPbLujDXrH1uPgE [following]
> --2017-06-22 23:00:01--  http://www.google.com.au/?gfe_rd=cr&ei=Ub9LWbPbLujDXrH1uPgE
> Reusing existing connection to proxy.pmdw.com:3128.
> Proxy request sent, awaiting response... 200 OK
> Length: unspecified [text/html]
> Saving to: ‘index.html’
> 
> index.html                      [ <=>                                       ]  11.37K  --.-KB/s    in 0.001s  
> 
> 2017-06-22 23:00:01 (22.0 MB/s) - ‘index.html’ saved [11640]
> 
> $ uname -a
> Linux 4.12.0-rc4-gcc6-00988-g0a463c7 #88 SMP Thu Jun 22 22:55:12 AEST 2017 ppc64 GNU/Linux
> 
> 
> Haven't had time to debug any further. Any ideas?

Thank you for this report.

Can you please specify features of the relevant NIC ? (ethtool -k
<name>) 

I'll try to replicate the issue as soon I'll get hands on suitable HW,
meanwhile can you please try to trace the system behavior with perf?

Something like:

perf probe -a __udp_enqueue_schedule_skb
perf probe -a udp_recvmsg
perf probe -a udpv6_recvmsg
perf record -e probe:__udp_enqueue_schedule_skb -e probe:udp_recvmsg -e probe:udpv6_recvmsg -ag wget google.com
perf report --stdio

Thanks,

Paolo
