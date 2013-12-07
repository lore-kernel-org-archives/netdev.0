From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: vxlan/veth performance issues on net.git + latest kernels
Date: Sat, 7 Dec 2013 23:20:40 +0200
Message-ID: <CAJZOPZLqVxS_=9CLfodz2=ncZ0K2xEJaOVoUWUgoSDY7q4yKWg@mail.gmail.com>
References: <CAJZOPZL9LxB5HdqS=+gQW-MjvW2NsZOt3NPB7v1iOFoEB7SsMQ@mail.gmail.com>
	<1386105850.30495.38.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAJZOPZ+vnqLpdjS0TNdxDa4CNTzzfqp1=Ftjf86Fd5Lb+QdSzw@mail.gmail.com>
	<20131203.165034.1085515763685633822.davem@davemloft.net>
	<1386107714.30495.40.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAJZOPZ+bkvg4G6qzY6YmMui9-KmGmpHyFCJUD2xsFLOXm12rgA@mail.gmail.com>
	<1386115199.30495.44.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAMEtUuzEM957fRjsb5aSG7xHWKp13fy59QxWpsU_=d+-6ydazg@mail.gmail.com>
	<1386117362.30495.49.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAMEtUuy8HA1nOQJTnxy+p7vNFV25zxMAmz1fh2spj0k4hYgh4w@mail.gmail.com>
	<1386120216.30495.59.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAJZOPZK8UnjGYDdZ4=6BQq55WviSkKA36WHfsmk03u6S7BxZNA@mail.gmail.com>
	<1386337011.30495.253.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	David Miller <davem@davemloft.net>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	Jerry Chu <hkchu@google.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eric Dumazet <edumazet@google.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:47417 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754506Ab3LGVUl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Dec 2013 16:20:41 -0500
Received: by mail-pd0-f176.google.com with SMTP id w10so2909205pde.7
        for <netdev@vger.kernel.org>; Sat, 07 Dec 2013 13:20:41 -0800 (PST)
In-Reply-To: <1386337011.30495.253.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 6, 2013 at 3:36 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2013-12-06 at 11:06 +0200, Or Gerlitz wrote:
>> On Wed, Dec 4, 2013 at 3:23 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > skb->dev is in the first cache line, where we access skb->next anyway.
>> > I could use skb->cb[] like the following patch :
>>
>> Hi Eric, I applied on the net tree the patch you posted yesterday
>> "net: introduce dev_consume_skb_any()" along with the network drivers
>> part of this patch, unless I got it wrong, I assume both pieces are
>> needed?
>>
>> So I re-run the vxlan/veth test that we suspect goes through packet drops on TX.
>>
>> With the patches applied I have almost no samples of that event
>>
>> $ ./perf report -i perf.data
>
> How did you get this perf.data file ? There are a few drops.

Using the command you suggested on the active side while running
traffic (iperf tcp)

$ ./perf record -e skb:kfree_skb -g -a sleep 10

>> Samples: 89  of event 'skb:kfree_skb', Event count (approx.): 89
>> +  39.33%  ksoftirqd/2  [kernel.kallsyms]  [k] net_tx_action
>> +  28.09%      swapper  [kernel.kallsyms]  [k] net_tx_action
>> +  28.09%         sshd  [kernel.kallsyms]  [k] net_tx_action
>> +   2.25%      swapper  [kernel.kallsyms]  [k] kfree_skb
>> +   1.12%  kworker/2:2  [kernel.kallsyms]  [k] net_tx_action
>> +   1.12%        iperf  [kernel.kallsyms]  [k] net_tx_action

>>  ./perf report -i perf.data --sort dso,symbol
>> Samples: 89  of event 'skb:kfree_skb', Event count (approx.): 89
>> +  97.75%  [kernel.kallsyms]  [k] net_tx_action
>> +   2.25%  [kernel.kallsyms]  [k] kfree_skb
>> --

> OK, this means your driver drops few packets in its ndo_start_xmit()
> handler.
>
> Could you give us "ifconfig -a" reports as I already asked  ?

will do tomorrow while infront of the setup.

When I provided you the info last time
http://marc.info/?l=linux-netdev&m=138610891121531&w=2 it included the
ifconfig -a output and no drops were seen there


>
> You could temporary change the dev_kfree_skb_any() in mlx4_en_xmit()
> to call kfree_skb(skb) instead, to get  a stack trace (perf record -a -g
> -e skb:kfree_skb sleep 20 ; perf report)

yes, tomorrow

>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> index f54ebd5a1702..53130f27dec0 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> @@ -873,7 +873,7 @@ tx_drop_unmap:
>         }
>
>  tx_drop:
> -       dev_kfree_skb_any(skb);
> +       kfree_skb(skb);
>         priv->stats.tx_dropped++;
>         return NETDEV_TX_OK;
>  }
>
>
