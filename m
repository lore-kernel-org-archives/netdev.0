From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: coping with memory limitations and packet flooding in
 codel and fq_codel
Date: Tue, 21 Aug 2012 10:38:18 +0200
Message-ID: <1345538298.5158.401.camel@edumazet-glaptop>
References: <CAA93jw7=K8Vvp6N5qYZ8gaODaFyZtAEjGyQe2BDh9-RBsvVHcQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, codel@lists.bufferbloat.net
To: Dave Taht <dave.taht@gmail.com>
Return-path: <codel-bounces@lists.bufferbloat.net>
In-Reply-To: <CAA93jw7=K8Vvp6N5qYZ8gaODaFyZtAEjGyQe2BDh9-RBsvVHcQ@mail.gmail.com>
List-Unsubscribe: <https://lists.bufferbloat.net/options/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=unsubscribe>
List-Archive: <https://lists.bufferbloat.net/pipermail/codel>
List-Post: <mailto:codel@lists.bufferbloat.net>
List-Help: <mailto:codel-request@lists.bufferbloat.net?subject=help>
List-Subscribe: <https://lists.bufferbloat.net/listinfo/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=subscribe>
Sender: codel-bounces@lists.bufferbloat.net
Errors-To: codel-bounces@lists.bufferbloat.net
List-Id: netdev.vger.kernel.org

On Mon, 2012-08-20 at 14:05 -0700, Dave Taht wrote:
> We've had a raft of deployment questions regarding fq_codel, memory
> use, and the impact of unresponsive flows
> over on the cerowrt development list.
> 
> sort of summary of the thread here, with some codel related ideas
> 
> https://lists.bufferbloat.net/pipermail/cerowrt-devel/2012-August/000423.html
> 
> some early data on wifi interactions here
> 
> https://lists.bufferbloat.net/pipermail/cerowrt-devel/2012-August/000407.html
> 

CC netdev

codel / fq_codel have a packet limit per qdisc, like any other linux
qdisc.

DEFAULT_CODEL_LIMIT = 1000 packets

fq_codel : 10240 packets

For memory constrained boxes, it would be wise to add a 'truesize' limit

Not a bytes limit based on skb->len sum, because a skb->len = 60 bytes
packet might consume far more memory (more than 2 Kbytes)

ath9k driver is known to deliver very fat skbs (skb->truesize is too
big)

One 'other way' to limit bloat would be to reallocate skbs when one
qdisc begins to use more than 25 % of its truesize limit

enqueue(q, skb)
{
	if (q->truesize_sum > q->truesize_limit / 4)
		skb = skb_reduce_truesize(skb, GFP_ATOMIC);
	...
}

This is what some drivers already do in their rx handler (this is called
copybreak), but this would do the copy (and extra cpu cost) only in
stress situations.

Note : we also have a very big struct skb_shared_info (320 bytes), we
probably could shrink it for packets without fragments.
