From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH iproute2 v2] fq: allow options of fair queue set to ~0U
Date: Mon, 12 May 2014 20:03:59 -0700
Message-ID: <1399950239.7973.38.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1399868319-2184-1-git-send-email-yangyingliang@huawei.com>
		 <1399874336.7973.17.camel@edumazet-glaptop2.roam.corp.google.com>
		 <5370713F.7040701@huawei.com>
	 <1399908225.7973.25.camel@edumazet-glaptop2.roam.corp.google.com>
	 <53718221.6040909@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:59536 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750791AbaEMDEC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 23:04:02 -0400
Received: by mail-pa0-f48.google.com with SMTP id rd3so9608306pab.21
        for <netdev@vger.kernel.org>; Mon, 12 May 2014 20:04:01 -0700 (PDT)
In-Reply-To: <53718221.6040909@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-05-13 at 10:23 +0800, Yang Yingliang wrote:
> From: Yang Yingliang <yangyingliang@huawei.com>
> 
> Some options of fair queue cannot be (~0U). It leads to maxrate
> cannot be reset to unlimited because it cannot be (~0U).
> 
> Suggested-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
> ---
>  tc/q_fq.c | 36 ++++++++++++++++++++++++------------
>  1 file changed, 24 insertions(+), 12 deletions(-)
> 
> diff --git a/tc/q_fq.c b/tc/q_fq.c
> index c1f658e..6a493a5 100644
> --- a/tc/q_fq.c
> +++ b/tc/q_fq.c
> @@ -71,13 +71,19 @@ static unsigned int ilog2(unsigned int val)
>  static int fq_parse_opt(struct qdisc_util *qu, int argc, char **argv,
>  			struct nlmsghdr *n)
>  {
> -	unsigned int plimit = ~0U;
> -	unsigned int flow_plimit = ~0U;
> -	unsigned int quantum = ~0U;
> -	unsigned int initial_quantum = ~0U;
> +	unsigned int plimit;
> +	unsigned int flow_plimit;
> +	unsigned int quantum;
> +	unsigned int initial_quantum;
>  	unsigned int buckets = 0;
> -	unsigned int maxrate = ~0U;
> -	unsigned int defrate = ~0U;
> +	unsigned int maxrate;
> +	unsigned int defrate;
> +	int set_plimit = 0;
> +	int set_flow_plimit = 0;
> +	int set_quantum = 0;
> +	int set_initial_quantum = 0;
> +	int set_maxrate = 0;
> +	int set_defrate = 0;
>  	int pacing = -1;
>  	struct rtattr *tail;
>  
> @@ -88,12 +94,14 @@ static int fq_parse_opt(struct qdisc_util *qu, int argc, char **argv,
>  				fprintf(stderr, "Illegal \"limit\"\n");
>  				return -1;
>  			}
> +			set_plimit = 1;
>  		} else if (strcmp(*argv, "flow_limit") == 0) {
>  			NEXT_ARG();
>  			if (get_unsigned(&flow_plimit, *argv, 0)) {
>  				fprintf(stderr, "Illegal \"flow_limit\"\n");
>  				return -1;
>  			}
> +			set_flow_plimit = 0;


= 1; ?

>  		} else if (strcmp(*argv, "buckets") == 0) {
>  			NEXT_ARG();
>  			if (get_unsigned(&buckets, *argv, 0)) {
> @@ -106,24 +114,28 @@ static int fq_parse_opt(struct qdisc_util *qu, int argc, char **argv,
>  				fprintf(stderr, "Illegal \"maxrate\"\n");
>  				return -1;
>  			}
> +			set_maxrate = 1;
>  		} else if (strcmp(*argv, "defrate") == 0) {
>  			NEXT_ARG();
>  			if (get_rate(&defrate, *argv)) {
>  				fprintf(stderr, "Illegal \"defrate\"\n");
>  				return -1;
>  			}
> +			set_defrate = 1;
>  		} else if (strcmp(*argv, "quantum") == 0) {
>  			NEXT_ARG();
>  			if (get_unsigned(&quantum, *argv, 0)) {
>  				fprintf(stderr, "Illegal \"quantum\"\n");
>  				return -1;
>  			}
> +			set_quantum = 1;
>  		} else if (strcmp(*argv, "initial_quantum") == 0) {
>  			NEXT_ARG();
>  			if (get_unsigned(&initial_quantum, *argv, 0)) {
>  				fprintf(stderr, "Illegal \"initial_quantum\"\n");
>  				return -1;
>  			}
> +			set_initial_quantum = 1;
>  		} else if (strcmp(*argv, "pacing") == 0) {
>  			pacing = 1;
>  		} else if (strcmp(*argv, "nopacing") == 0) {
> @@ -147,24 +159,24 @@ static int fq_parse_opt(struct qdisc_util *qu, int argc, char **argv,
>  		addattr_l(n, 1024, TCA_FQ_BUCKETS_LOG,
>  			  &log, sizeof(log));
>  	}
> -	if (plimit != ~0U)
> +	if (set_plimit)
>  		addattr_l(n, 1024, TCA_FQ_PLIMIT,
>  			  &plimit, sizeof(plimit));
> -	if (flow_plimit != ~0U)
> +	if (set_flow_plimit)
>  		addattr_l(n, 1024, TCA_FQ_FLOW_PLIMIT,
>  			  &flow_plimit, sizeof(flow_plimit));
> -	if (quantum != ~0U)
> +	if (set_quantum)
>  		addattr_l(n, 1024, TCA_FQ_QUANTUM, &quantum, sizeof(quantum));
> -	if (initial_quantum != ~0U)
> +	if (set_initial_quantum)
>  		addattr_l(n, 1024, TCA_FQ_INITIAL_QUANTUM,
>  			  &initial_quantum, sizeof(initial_quantum));
>  	if (pacing != -1)
>  		addattr_l(n, 1024, TCA_FQ_RATE_ENABLE,
>  			  &pacing, sizeof(pacing));
> -	if (maxrate != ~0U)
> +	if (set_maxrate)
>  		addattr_l(n, 1024, TCA_FQ_FLOW_MAX_RATE,
>  			  &maxrate, sizeof(maxrate));
> -	if (defrate != ~0U)
> +	if (set_defrate)
>  		addattr_l(n, 1024, TCA_FQ_FLOW_DEFAULT_RATE,
>  			  &defrate, sizeof(defrate));
>  	tail->rta_len = (void *) NLMSG_TAIL(n) - (void *) tail;
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
