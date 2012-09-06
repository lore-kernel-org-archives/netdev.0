From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: CBQ(but probably u32 filter bug), kernel "freeze", at least
 from 3.2.0
Date: Thu, 06 Sep 2012 10:40:06 +0200
Message-ID: <1346920806.13121.180.camel@edumazet-glaptop>
References: <a680a8297b2f099eb713b266792b9b82@visp.net.lb>
	 <1346151568.3001.20.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:61551 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751619Ab2IFIkM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 04:40:12 -0400
Received: by bkwj10 with SMTP id j10so666150bkw.19
        for <netdev@vger.kernel.org>; Thu, 06 Sep 2012 01:40:11 -0700 (PDT)
In-Reply-To: <1346151568.3001.20.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-08-28 at 03:59 -0700, Eric Dumazet wrote:
> On Tue, 2012-08-28 at 07:50 +0300, Denys Fedoryshchenko wrote:
> > Hi
> > 
> > Got information from friend, confirmed that it crashed at least two my 
> > boxes also :)
> > 3.0.5-rc1 is working fine, 3.4.1 , 3.2.0 from ubuntu  - crashing
> > No watchdog fired, and didn't got yet significant debugging 
> > information.
> > 
> > Very easy to reproduce:
> > 1)run the script
> > 2)ping 192.168.3.234
> > 
> > script:
> > DEV_OUT=eth0
> > ICMP="match ip protocol 1 0xff"
> > U32="protocol ip u32"
> > DST="match ip dst"
> > tc qdisc add dev $DEV_OUT root handle 1: cbq avpkt 1000 bandwidth 
> > 100mbit
> > tc class add dev $DEV_OUT parent 1: classid 1:1 cbq rate 512kbit allot 
> > 1500 prio 5 bounded isolated
> > tc filter add dev $DEV_OUT parent 1:              prio 3 $U32 $ICMP 
> > $DST 192.168.3.234 flowid 1:
> > tc qdisc add dev $DEV_OUT parent 1:1 sfq perturb 10
> 
> Not sure what your friend expected from this buggy configuration.
> 
> It probably never worked at all.
> 
> CBQ needs at least one child class and one leaf class.
> 
> This scripts creates a loop inside CBQ, so cpu is probably looping in
> cbq_enqueue() (or more exactly cbq_classify()), as instructed by the
> sysadmin ;)
> 
> u32 (or sfq) seems ok.
> 
> Could you try the following patch ?
> 
> Thanks !
> 
> diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
> index 6aabd77..564b9fc 100644
> --- a/net/sched/sch_cbq.c
> +++ b/net/sched/sch_cbq.c
> @@ -250,10 +250,11 @@ cbq_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
>  			else if ((cl = defmap[res.classid & TC_PRIO_MAX]) == NULL)
>  				cl = defmap[TC_PRIO_BESTEFFORT];
>  
> -			if (cl == NULL || cl->level >= head->level)
> +			if (cl == NULL)
>  				goto fallback;
>  		}
> -
> +		if (cl->level >= head->level)
> +			goto fallback;
>  #ifdef CONFIG_NET_CLS_ACT
>  		switch (result) {
>  		case TC_ACT_QUEUED:
> 

Hi Denys

Any feedback on the suggested patch ?

Thanks !
