From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RCU PATCH 06/14] net: sched: fw use RCU
Date: Fri, 14 Mar 2014 13:35:34 -0700
Message-ID: <20140314203534.GF21124@linux.vnet.ibm.com>
References: <20140313202245.GK21124@linux.vnet.ibm.com>
 <1394744203.21721.53.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140313211509.GP21124@linux.vnet.ibm.com>
 <53229704.1040808@gmail.com>
 <20140314132834.GS21124@linux.vnet.ibm.com>
 <1394804798.21721.64.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140314153810.GX21124@linux.vnet.ibm.com>
 <20140314185005.GA17041@linux.vnet.ibm.com>
 <20140314185917.GA18933@linux.vnet.ibm.com>
 <1394826958.9668.4.camel@edumazet-glaptop2.roam.corp.google.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.fastabend@gmail.com>,
	xiyou.wangcong@gmail.com, jhs@mojatatu.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:35097 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753570AbaCNUfj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 16:35:39 -0400
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
	Fri, 14 Mar 2014 14:35:39 -0600
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 58B043E40040
	for <netdev@vger.kernel.org>; Fri, 14 Mar 2014 14:35:36 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08027.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2EKZ5pU2425256
	for <netdev@vger.kernel.org>; Fri, 14 Mar 2014 21:35:05 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s2EKd9IJ022812
	for <netdev@vger.kernel.org>; Fri, 14 Mar 2014 14:39:10 -0600
Content-Disposition: inline
In-Reply-To: <1394826958.9668.4.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 14, 2014 at 12:55:58PM -0700, Eric Dumazet wrote:
> On Fri, 2014-03-14 at 11:59 -0700, Paul E. McKenney wrote:
> 
> > Or I could find some other large area of memory that never contains
> > functions, for example, the beginning of data or bss (if we still have
> > those).  Then check for a range rather than a cutoff.
> 
> For the particular cls_fw.c case I think we should just use one page.
> 
> Not that I think extending kfree_rcu() range is not useful, do not be
> fooled !
> 
> This fw_hash() is really complex, gcc can use a reciprocal divide and it
> will be even faster...
> 
> If John adds a rcu_head, it will simply remove two slots in the hash
> table, big deal....

OK, dropping my current patch, and adding this back to the todo list.

I am sure I will kick myself when the trivial solution makes itself
apparent...

							Thanx, Paul

> diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
> index a366537f82c6..6b68f2da6860 100644
> --- a/net/sched/cls_fw.c
> +++ b/net/sched/cls_fw.c
> @@ -29,11 +29,12 @@
>  #include <net/act_api.h>
>  #include <net/pkt_cls.h>
> 
> -#define HTSIZE (PAGE_SIZE/sizeof(struct fw_filter *))
> +
> +#define HTSIZE ((PAGE_SIZE - sizeof(u32)) / sizeof(struct fw_filter *))
> 
>  struct fw_head {
> -	struct fw_filter *ht[HTSIZE];
>  	u32 mask;
> +	struct fw_filter *ht[HTSIZE];
>  };
> 
>  struct fw_filter {
> @@ -48,28 +49,7 @@ struct fw_filter {
> 
>  static inline int fw_hash(u32 handle)
>  {
> -	if (HTSIZE == 4096)
> -		return ((handle >> 24) & 0xFFF) ^
> -		       ((handle >> 12) & 0xFFF) ^
> -		       (handle & 0xFFF);
> -	else if (HTSIZE == 2048)
> -		return ((handle >> 22) & 0x7FF) ^
> -		       ((handle >> 11) & 0x7FF) ^
> -		       (handle & 0x7FF);
> -	else if (HTSIZE == 1024)
> -		return ((handle >> 20) & 0x3FF) ^
> -		       ((handle >> 10) & 0x3FF) ^
> -		       (handle & 0x3FF);
> -	else if (HTSIZE == 512)
> -		return (handle >> 27) ^
> -		       ((handle >> 18) & 0x1FF) ^
> -		       ((handle >> 9) & 0x1FF) ^
> -		       (handle & 0x1FF);
> -	else if (HTSIZE == 256) {
> -		u8 *t = (u8 *) &handle;
> -		return t[0] ^ t[1] ^ t[2] ^ t[3];
> -	} else
> -		return handle & (HTSIZE - 1);
> +	return handle % HTSIZE;
>  }
> 
>  static int fw_classify(struct sk_buff *skb, const struct tcf_proto *tp,
> 
> 
