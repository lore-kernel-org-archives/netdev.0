From: Asim Shankar <asimshankar@gmail.com>
Subject: [PATCH 2.6.11.7] sch_htb: Drop packet when direct queue is full
Date: Thu, 21 Apr 2005 18:02:55 -0500
Message-ID: <7bca1cb505042116022f64a87e@mail.gmail.com>
References: <7bca1cb50504211221655fd54c@mail.gmail.com>
	 <20050421195605.GJ577@postel.suug.ch>
	 <7bca1cb505042113417a5d9f59@mail.gmail.com>
	 <20050421215440.GL577@postel.suug.ch>
Reply-To: Asim Shankar <asimshankar@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: devik@cdi.cz, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20050421215440.GL577@postel.suug.ch>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

htb_enqueue(): Free skb and return NET_XMIT_DROP if a packet is
destined for the direct_queue but the direct_queue is full. (Before
this: erroneously returned NET_XMIT_SUCCESS even though the packet was
not enqueued)

Signed-off-by: Asim Shankar <asimshankar@gmail.com>

--- linux-2.6.11.7/net/sched/sch_htb.c.orig 2005-04-21 17:40:05.305709014 -0500
+++ linux-2.6.11.7/net/sched/sch_htb.c 2005-04-21 17:35:27.872624173 -0500
@@ -717,6 +717,10 @@ static int htb_enqueue(struct sk_buff *s
if (q->direct_queue.qlen < q->direct_qlen) {
    __skb_queue_tail(&q->direct_queue, skb);
    q->direct_pkts++;
+ } else {
+     kfree_skb(skb);
+     sch->qstats.drops++;
+     return NET_XMIT_DROP;
}
#ifdef CONFIG_NET_CLS_ACT
     } else if (!cl) {
