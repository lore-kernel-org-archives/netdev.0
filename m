From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [RFC PATCH 00/11] udp: full early demux for unconnected sockets
Date: Mon, 25 Sep 2017 22:26:09 +0200
Message-ID: <1506371169.2614.3.camel@redhat.com>
References: <cover.1506114055.git.pabeni@redhat.com>
         <1506117524.29839.176.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41176 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934254AbdIYU0N (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 25 Sep 2017 16:26:13 -0400
In-Reply-To: <1506117524.29839.176.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-09-22 at 14:58 -0700, Eric Dumazet wrote:
> On Fri, 2017-09-22 at 23:06 +0200, Paolo Abeni wrote:
> > This series refactor the UDP early demux code so that:
> > 
> > * full socket lookup is performed for unicast packets
> > * a sk is grabbed even for unconnected socket match
> > * a dst cache is used even in such scenario
> > 
> > To perform this tasks a couple of facilities are added:
> > 
> > * noref socket references, scoped inside the current RCU section, to be
> >   explicitly cleared before leaving such section
> > * a dst cache inside the inet and inet6 local addresses tables, caching the
> >   related local dst entry
> > 
> > The measured performance gain under small packet UDP flood is as follow:
> > 
> > ingress NIC	vanilla		patched		delta
> > rx queues	(kpps)		(kpps)		(%)
> > [ipv4]
> > 1		2177		2414		10
> > 2		2527		2892		14
> > 3		3050		3733		22
> 
> 
> This is a clear sign your program is not using latest SO_REUSEPORT +
> [ec]BPF filter [1]
> 
> return socket[RX_QUEUE# | or CPU#];
> 
> If udp_sink uses SO_REUSEPORT with no extra hint, socket selection is
> based on a lazy hash, meaning that you do not have proper siloing.
> 
> return socket[hash(skb)];
> 
> Multiple cpus can then :
>  - compete on grabbing same socket refcount
>  - compete on grabbing the receive queue lock
>  - compete for releasing lock and socket refcount
>  - skb freeing done on different cpus than where allocated.
> 
> You are adding complexity to the kernel because you are using a
> sub-optimal user space program, favoring false sharing.
> 
> First solve the false sharing issue.
> 
> Performance with 2 rx queues should be almost twice the performance with
> 1 rx queue.
> 
> Then we can see if the gains you claim are still applicable.

Here are the performance results using a BPF filter to distribute the
ingress packet to the reuseport socket with the same id of the ingress
CPU - we have 1 to 1 mapping between the ingress receive queue and the
destination socket:

ingress NIC     vanilla         patched         delta
rx queues       (kpps)          (kpps)          (%)
[ipv4]
2               3020                3663                21
3               4352                5179                19
4               5318                6194                16
5               6258                7583                21
6               7376                8558                16

[ipv6]
2               2446                3949                61
3               3099                5092                64
4               3698                6611                78
5               4382                7852                79
6               5116                8851                73

Sone notes:

- figures obtained with: 

ethtool  -L em2 combined $n
MASK=1
for I in `seq 0 $((n - 1))`; do
        [ $I -eq 0 ] && USE_BPF="--use_bpf" || USE_BPF=""
        udp_sink  --reuseport $USE_BPF --recvfrom --count 10000000 --port 9 &
        taskset -p $((MASK << ($I + $n) )) $!
done

- in the IPv6 routing code we currently have a relevant bottle-neck in
ip6_pol_route(), I see a lot of contention on a dst refcount, so
without early demux the performances do not scale well there.

- For maximum performances BH and user space sink need to run on
difference CPUs - yes we have some more cacheline misses and a little
contention on the receive queue spin lock, but a lot less icache misses
and more CPU cycles available, the overall tput is a lot higher than
binding on the same CPU where the BH is running.

> PS: Wei Wan is about to release the IPV6 changes so that the big
> differences you showed are going to disappear soon.

Interesting, looking forward to that!

Cheers,

Paolo
