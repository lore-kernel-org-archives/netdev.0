From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] pkt_sched: fix bandwidth's accuracy of software device
 with htb
Date: Tue, 30 Jul 2013 20:08:42 -0700
Message-ID: <1375240122.10515.54.camel@edumazet-glaptop>
References: <51F878E6.1070806@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:36100 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751683Ab3GaDIo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 23:08:44 -0400
Received: by mail-pb0-f52.google.com with SMTP id wz12so205649pbc.39
        for <netdev@vger.kernel.org>; Tue, 30 Jul 2013 20:08:44 -0700 (PDT)
In-Reply-To: <51F878E6.1070806@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-07-31 at 10:39 +0800, Yang Yingliang wrote:
> When we set bandwidth on the software devices with htb,
> it's not precise.
> 
> With htb, sch->limit is set from devices TX queue's
> length that is not 0. Because software devices TX
> queue is 0, sch->limit is set to default value 1.
> 
> Because the length of skb_buff queue is bigger than
> sch->limit whose value is 1, some packets are dropped.
> This leads to software devices can't make full use of
> the bandwidth and influence the accuracy.
> 
> To fix this issue, set the default value of sch->limit
> to 1000 that is the value of eth device's tx_queueu_len.
> 
> Example:
> tc qdisc add dev bond0 root handle 1: htb default 1
> tc class add dev bond0 parent 1:0 classid 1:1 htb rate 1Gbit ceil 1Gbit
> iperf -c host -t 30 -i 10
> 
> With old sch->limit:
> [ ID] Interval       Transfer     Bandwidth
> [  3]  0.0-10.0 sec   579 MBytes   486 Mbits/sec
> [  3] 10.0-20.0 sec   604 MBytes   507 Mbits/sec
> [  3] 20.0-30.0 sec   551 MBytes   462 Mbits/sec
> [  3]  0.0-30.0 sec  1.69 GBytes   485 Mbits/sec
> 
> With new sch->limit:
> [ ID] Interval       Transfer     Bandwidth
> [  3]  0.0-10.0 sec  1.11 GBytes   955 Mbits/sec
> [  3] 10.0-20.0 sec  1.11 GBytes   955 Mbits/sec
> [  3] 20.0-30.0 sec  1.11 GBytes   955 Mbits/sec
> [  3]  0.0-30.0 sec  3.33 GBytes   955 Mbits/sec
> 
> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
> ---
>  net/sched/sch_fifo.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sched/sch_fifo.c b/net/sched/sch_fifo.c
> index e15a9eb..8dd27ec 100644
> --- a/net/sched/sch_fifo.c
> +++ b/net/sched/sch_fifo.c
> @@ -54,7 +54,7 @@ static int fifo_init(struct Qdisc *sch, struct nlattr *opt)
>  	bool is_bfifo = sch->ops == &bfifo_qdisc_ops;
>  
>  	if (opt == NULL) {
> -		u32 limit = qdisc_dev(sch)->tx_queue_len ? : 1;
> +		u32 limit = qdisc_dev(sch)->tx_queue_len ? : 1000;
>  
>  		if (is_bfifo)
>  			limit *= psched_mtu(qdisc_dev(sch));

Hmm. This looks like user error to me.

What if existing scripts relied on the limit being 1 ?

If you want to use pfifo on a virtual device, while not setting explicit
limit, you have to "ifconfig bond0 txqueuelen 1000"

Seriously, using pfifo or bfifo without setting explicit plimit/blimit
is not very safe, even with non virtual devices.
