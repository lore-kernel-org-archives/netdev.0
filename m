From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] softirq: let ksoftirqd do its job
Date: Thu, 01 Sep 2016 06:06:01 -0700
Message-ID: <1472735161.5019.17.camel@edumazet-glaptop3.roam.corp.google.com>
References: <4f1c4b38528762619fff1fa963de8971006c1234.1472460085.git.pabeni@redhat.com>
         <20160831100854.23dad2d8@redhat.com>
         <1472650472.14381.317.camel@edumazet-glaptop3.roam.corp.google.com>
         <1472650688.32433.115.camel@redhat.com>
         <1472652643.14381.320.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160831164216.2901190c@redhat.com>
         <1472661956.14381.335.camel@edumazet-glaptop3.roam.corp.google.com>
         <1472665349.14381.356.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160831214043.2f44cf08@redhat.com>
         <1472676150.14381.363.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160831235116.33b1946b@redhat.com>
         <1472682450.14381.364.camel@edumazet-glaptop3.roam.corp.google.com>
         <3567b503-8b3e-5a3f-580a-f99fd28cf77e@hpe.com>
         <1472685066.14381.380.camel@edumazet-glaptop3.roam.corp.google.com>
         <f131776f-7f53-c539-f283-10d6db0b6d57@hpe.com>
         <20160901123849.2c9aa5e1@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hpe.com>,
        Peter Zijlstra <peterz@infradead.org>,
        David Miller <davem@davemloft.net>,
        Rik van Riel <riel@redhat.com>,
        Paolo Abeni <pabeni@redhat.com>,
        Hannes Frederic Sowa <hannes@redhat.com>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>, Jonathan Corbet <corbet@lwn.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160901123849.2c9aa5e1@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-09-01 at 12:38 +0200, Jesper Dangaard Brouer wrote:

> I see max queue of 47MBytes, and worse an average standing queue of
> 25Mbytes, which is really bad for the latency seen by the
> application. And having this much outstanding memory is also bad for
> CPU cache size effects, and stressing the memory allocator.
>  I'm actually using this huge queue "misconfig" to stress the page
> allocator and my page_pool implementation into worse case situations ;-)
> 

Since commit 95766fff6b9a78d11f ("[UDP]: Add memory accounting."),
it is dangerous to have a big SO_RCVBUF value, since it adds unexpected
recvmsg() latencies.

1) User thread locks the socket.
2) Gets one skb from receive queue
   3) incoming flood of UDP packets are processed by softirq
   4) Socket is found 'owned by the user'
   5) packets are parked into the 'socket backlog' up to the SO_RCVBUF
limit
6) User thread release the socket.
7)  It finds many skbs in the backlog and have to process them _all_ and
re-inject in socket receive queue.
8) return to user space.


Time spent in 7) can me in the order of millions of cpu cycles...

At least starting from 5413d1babe8f10d ("net: do not block BH while
processing socket backlog") we no longer block BH while doing 7) and we
have cond resched points.
