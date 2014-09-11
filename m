From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v4 10/16] net: sched: make cls_u32 lockless
Date: Wed, 10 Sep 2014 18:26:00 -0700
Message-ID: <1410398760.7106.47.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140910154517.2036.53084.stgit@nitbit.x32>
	 <20140910155050.2036.26320.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, davem@davemloft.net, jhs@mojatatu.com,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:46178 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751038AbaIKB0D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 21:26:03 -0400
Received: by mail-pd0-f170.google.com with SMTP id fp1so4513319pdb.1
        for <netdev@vger.kernel.org>; Wed, 10 Sep 2014 18:26:02 -0700 (PDT)
In-Reply-To: <20140910155050.2036.26320.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-09-10 at 08:50 -0700, John Fastabend wrote:
> Make cls_u32 classifier safe to run without holding lock. This patch
> converts statistics that are kept in read section u32_classify into
> per cpu counters.
> 
> This patch was tested with a tight u32 filter add/delete loop while
> generating traffic with pktgen. By running pktgen on vlan devices
> created on top of a physical device we can hit the qdisc layer
> correctly. For ingress qdisc's a loopback cable was used.
> 
> for i in {1..100}; do
>         q=`echo $i%8|bc`;
>         echo -n "u32 tos: iteration $i on queue $q";
>         tc filter add dev p3p2 parent $p prio $i u32 match ip tos 0x10 0xff \
>                   action skbedit queue_mapping $q;
>         sleep 1;
>         tc filter del dev p3p2 prio $i;
> 
>         echo -n "u32 tos hash table: iteration $i on queue $q";
>         tc filter add dev p3p2 parent $p protocol ip prio $i handle 628: u32 divisor 1
>         tc filter add dev p3p2 parent $p protocol ip prio $i u32 \
>                 match ip protocol 17 0xff link 628: offset at 0 mask 0xf00 shift 6 plus 0
>         tc filter add dev p3p2 parent $p protocol ip prio $i u32 \
>                 ht 628:0 match ip tos 0x10 0xff action skbedit queue_mapping $q
>         sleep 2;
>         tc filter del dev p3p2 prio $i
>         sleep 1;
> done
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
