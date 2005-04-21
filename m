From: Asim Shankar <asimshankar@gmail.com>
Subject: BUG: HTB?
Date: Thu, 21 Apr 2005 14:21:07 -0500
Message-ID: <7bca1cb50504211221655fd54c@mail.gmail.com>
Reply-To: Asim Shankar <asimshankar@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I think there is a bug in htb_enqueue() (net/sched/sch_htb.c)

Specifically, in the lines:
if (cl == HTB_DIRECT) {
        /* enqueue to helper queue */
        if (q->direct_queue.qlen < q->direct_qlen) {
                __skb_queue_tail(&q->direct_queue, skb);
                q->direct_pkts++;
        }
}

If a packet is classified as HTB_DIRECT but the direct_queue is
already full, then the packet doesn't get enqueued but sch->q.qlen++
will happen a few lines later. Overflowing of the direct_queue
probably rarely happens in practice, but I was playing around and
noticed it happen in some corner cases of my testing.

Should the packet be dropped instead? Like:

if (cl == HTB_DIRECT) {
        /* enqueue to helper queue */
        if (q->direct_queue.qlen < q->direct_qlen) {
                __skb_queue_tail(&q->direct_queue, skb);
                q->direct_pkts++;
        } else {
               sch->qstats.drops++;
                kfree_skb(skb);
                return NET_XMIT_DROP;
       }
}


Thanks,

-- Asim
