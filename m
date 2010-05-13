From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] TBF: stop qdisc infanticide
Date: Thu, 13 May 2010 18:22:56 +0200
Message-ID: <4BEC2760.7080704@trash.net>
References: <20100513091717.78bd7f1f@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58176 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757101Ab0EMQXA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 May 2010 12:23:00 -0400
In-Reply-To: <20100513091717.78bd7f1f@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> Several netem users have complained that when using TBF for rate control
> that any change to TBF parameters destroys the child qdisc. A typical
> use is to have a test that sets up netem + TBF then changes bandwidth
> setting.  But every time the parameters of TBF are changed it destroys
> the child qdisc, requiring reconfiguration. Other qdisc's like HTB
> don't do this.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> 
> --- a/net/sched/sch_tbf.c	2010-05-12 20:41:06.257006386 -0700
> +++ b/net/sched/sch_tbf.c	2010-05-12 20:52:35.671216316 -0700
> @@ -273,7 +273,11 @@ static int tbf_change(struct Qdisc* sch,
>  	if (max_size < 0)
>  		goto done;
>  
> -	if (qopt->limit > 0) {
> +	if (q->qdisc) {
> +		err = fifo_set_limit(q->qdisc, qopt->limit);
> +		if (err)
> +			goto done;

q->qdisc is never NULL since a noop_qdisc is assigned by default. Also
this should check that the child is in fact one of the *fifos.

> +	} else if (qopt->limit > 0) {
>  		child = fifo_create_dflt(sch, &bfifo_qdisc_ops, qopt->limit);
>  		if (IS_ERR(child)) {
>  			err = PTR_ERR(child);
> 

