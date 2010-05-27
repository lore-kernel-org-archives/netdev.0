From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: boot crash in arp_error_report() (Re: [GIT] Networking)
Date: Thu, 27 May 2010 22:18:24 +0200
Message-ID: <1274991504.2446.13.camel@edumazet-laptop>
References: <20100525.165945.39198480.davem@davemloft.net>
	 <20100527190652.GA20303@elte.hu>
	 <alpine.LFD.2.00.1005271213091.3689@i5.linux-foundation.org>
	 <1274989637.2446.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1274989637.2446.1.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 27 mai 2010 =C3=A0 21:47 +0200, Eric Dumazet a =C3=A9crit :

> I am looking at this bug report, as I am probably at fault, please gi=
ve
> me one or two hour ;)

I believe problem comes from commit 7fee226ad2
(net: add a noref bit on skb dst)

We probably should add a WARN in __skb_queue_tail() and similar enqueue
 functions to catch other problems. I'll post a followup.

Thanks !

[PATCH] net: fix __neigh_event_send()

commit 7fee226ad23 (net: add a noref bit on skb dst) missed one spot
where an skb is enqueued, with a possibly not refcounted dst entry.

__neigh_event_send() inserts skb into arp_queue, so we must make sure
dst entry is refcounted, or dst entry can be freed by garbage collector
after caller exits from rcu protected section.

Reported-by: Ingo Molnar <mingo@elte.hu>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/neighbour.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index bff3790..6ba1c0e 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -934,6 +934,7 @@ int __neigh_event_send(struct neighbour *neigh, str=
uct sk_buff *skb)
 				kfree_skb(buff);
 				NEIGH_CACHE_STAT_INC(neigh->tbl, unres_discards);
 			}
+			skb_dst_force(skb);
 			__skb_queue_tail(&neigh->arp_queue, skb);
 		}
 		rc =3D 1;
