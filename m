From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] net: sched: convert qdisc linked list to hashtable
 (was Re: Deleting child qdisc doesn't reset parent to default qdisc?)
Date: Thu, 07 Jul 2016 15:51:03 +0200
Message-ID: <1467899463.1273.37.camel@edumazet-glaptop3.roam.corp.google.com>
References: <alpine.LNX.2.00.1604141638230.27368@cbobk.fhfr.pm>
	  <1460646099.10638.44.camel@edumazet-glaptop3.roam.corp.google.com>
	  <20160414151813.GE3715@orbyte.nwl.cc>
	  <alpine.LNX.2.00.1604141807350.27368@cbobk.fhfr.pm>
	  <1460656170.10638.61.camel@edumazet-glaptop3.roam.corp.google.com>
	  <5710E1C1.2090209@mojatatu.com>
	 <1460732328.10638.74.camel@edumazet-glaptop3.roam.corp.google.com>
	 <alpine.LNX.2.00.1607071102010.24757@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, Phil Sutter <phil@nwl.cc>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jiri Kosina <jikos@kernel.org>,
	Craig Gallek <kraigatgoog@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f196.google.com ([209.85.161.196]:36271 "EHLO
	mail-yw0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751055AbcGGNvI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 09:51:08 -0400
In-Reply-To: <alpine.LNX.2.00.1607071102010.24757@cbobk.fhfr.pm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-07-07 at 11:04 +0200, Jiri Kosina wrote:

> 
> 
> From: Jiri Kosina <jkosina@suse.cz>
> Subject: [PATCH] net: sched: convert qdisc linked list to hashtable
> 
> Convert the per-device linked list into a hashtable. The primary motivation
> for this change is that currently, we're not tracking all the qdiscs in
> hierarchy (e.g. excluding default qdiscs), as the lookup performed over the
> linked list by qdisc_match_from_root() is rather expensive.

...

>  	}
> @@ -1440,6 +1441,7 @@ static int tc_dump_qdisc_root(struct Qdisc *root, struct sk_buff *skb,
>  {
>  	int ret = 0, q_idx = *q_idx_p;
>  	struct Qdisc *q;
> +	int b;
>  
>  	if (!root)
>  		return 0;
> @@ -1454,7 +1456,7 @@ static int tc_dump_qdisc_root(struct Qdisc *root, struct sk_buff *skb,
>  			goto done;
>  		q_idx++;
>  	}
> -	list_for_each_entry(q, &root->list, list) {
> +	hash_for_each(qdisc_dev(root)->qdisc_hash, b, q, hash) {
>  		if (q_idx < s_q_idx) {
>  			q_idx++;
>  			continue;
> @@ -1771,6 +1773,7 @@ static int tc_dump_tclass_root(struct Qdisc *root, struct sk_buff *skb,
>  			       int *t_p, int s_t)
>  {
>  	struct Qdisc *q;
> +	int b;
>  
>  	if (!root)
>  		return 0;
> @@ -1778,7 +1781,7 @@ static int tc_dump_tclass_root(struct Qdisc *root, struct sk_buff *skb,
>  	if (tc_dump_tclass_qdisc(root, skb, tcm, cb, t_p, s_t) < 0)
>  		return -1;
>  
> -	list_for_each_entry(q, &root->list, list) {
> +	hash_for_each_rcu(qdisc_dev(root)->qdisc_hash, b, q, hash) {
>  		if (tc_dump_tclass_qdisc(q, skb, tcm, cb, t_p, s_t) < 0)
>  			return -1;
>  	}


Not sure why you used the rcu version here, but the non rcu version in
tc_dump_qdisc_root()

Thanks.
