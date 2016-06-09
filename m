From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] udp reuseport: fix packet of same flow hashed to
 different socket
Date: Wed, 08 Jun 2016 20:11:04 -0700
Message-ID: <1465441864.7945.33.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1465357219-34240-1-git-send-email-suxm@chinanetcenter.com>
	 <1465400620.7945.16.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1465436616.2825.39.camel@chinanetcenter.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Su Xuemin <suxm@chinanetcenter.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465436616.2825.39.camel@chinanetcenter.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-06-09 at 09:43 +0800, Su Xuemin wrote:
> On Wed 2016-06-08 at 08:43 -0700, Eric Dumazet wrote:
> > I am not convinced this is the right way to fix the issue.
> > 
> > Fact that you did not change udp4_lib_lookup2() is telling me something.
> > 
> > 
> > 1) If host has 100 different IP, and 10 sockets bound to 0.0.0.0:53 
> > 2) If we receive datagrams from SRCIP:srcport send to IP{1..100}:53
> > will all be hashed on same slot.
> > 
> > See the hash used in soreuseport logic as an equivalent of a 4-tuple
> > hash really, not a 3-tuple one.
> > 
> 
> This is my understanding of __udp4_lib_lookup(), see the comments below,
> please kindly review it.
> The problem of the current code is:
>   In Path 1, we pass daddr to udp_ehashfn() inside udp4_lib_lookup2().
>   In Path 2, we pass 0.0.0.0 to udp_ehashfn() inside udp4_lib_lookup2().
>   In Path 3, we pass daddr to udp_ehashfn(), even if inet->inet_rcv_saddr
> is 0.0.0.0.

My patch always pass daddr, and never 0.0.0.0 which makes little sense.

If a socket is bound to 0.0.0.0, then daddr will match it anyway.

I wrote this code, and clearly I was wrong.

The only moment we should use 0.0.0.0 is to get the hash bucket, but
really the lookup should use all the available keys.

Your patch can not be backported to stable versions because socket is
not stable (SLAB_DESTROY_BY_RCU rules) meaning that
inet_sk(sk)->inet_rcv_saddr could contain garbage.

daddr on the other hand is stable, since it is on the caller stack or
incoming packet (IPv6) and can not change under us.

We do not want to compute a hash based on garbage.

Have you tried my patch ?
