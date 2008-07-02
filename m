From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: net-sched 05/05: sch_htb: use dynamic class hash helpers
Date: Wed, 2 Jul 2008 23:31:02 +0200
Message-ID: <20080702213102.GB2476@ami.dom.local>
References: <20080701143417.26309.30902.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devik@cdi.cz
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.183]:3092 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752068AbYGBVcD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2008 17:32:03 -0400
Received: by ik-out-1112.google.com with SMTP id c28so275524ika.5
        for <netdev@vger.kernel.org>; Wed, 02 Jul 2008 14:32:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080701143417.26309.30902.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote, On 07/01/2008 04:34 PM:

> net-sched: sch_htb: use dynamic class hash helpers
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

This patch also looks OK too me, except 2 tiny doubts below:

> diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
> index 879f0b6..d5e4fdb 100644
> --- a/net/sched/sch_htb.c
> +++ b/net/sched/sch_htb.c
> @@ -51,7 +51,6 @@
>      one less than their parent.
>  */
>  
> -#define HTB_HSIZE 16		/* classid hash size */
>  static int htb_hysteresis __read_mostly = 0; /* whether to use mode hysteresis for speedup */
>  #define HTB_VER 0x30011		/* major must be matched with number suplied by TC as version */
>  
> @@ -72,8 +71,8 @@ enum htb_cmode {
>  
>  /* interior & leaf nodes; props specific to leaves are marked L: */
>  struct htb_class {
> +	struct Qdisc_class_common common;

Hmm... isn't this variable name too "common"? Why not something more
meaningful like: id, node, head, info etc?

...
> @@ -975,13 +957,14 @@ static unsigned int htb_drop(struct Qdisc *sch)
>  static void htb_reset(struct Qdisc *sch)
>  {
>  	struct htb_sched *q = qdisc_priv(sch);
> -	int i;
> -
> -	for (i = 0; i < HTB_HSIZE; i++) {
> -		struct hlist_node *p;
> -		struct htb_class *cl;
> +	struct Qdisc_class_common *clc;
> +	struct hlist_node *n;
> +	struct htb_class *cl;
> +	unsigned int i;
>  
> -		hlist_for_each_entry(cl, p, q->hash + i, hlist) {
> +	for (i = 0; i < q->clhash.hashsize; i++) {
> +		hlist_for_each_entry(clc, n, &q->clhash.hash[i], hnode) {
> +			cl = container_of(clc, struct htb_class, common);

Why not?:
		hlist_for_each_entry(cl, n, &q->clhash.hash[i], common.hnode) {

Of course, this is probably a matter of taste, so I don't persist...

Jarek P.
