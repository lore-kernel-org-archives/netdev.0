From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] rps: selective flow shedding during softnet
 overflow
Date: Mon, 22 Apr 2013 15:30:08 -0700
Message-ID: <1366669808.16391.90.camel@edumazet-glaptop>
References: <CA+FuTSfyo5YdtLpyXPawYoppM7zj5cp1_k1hD7+qWL6DUpNd4Q@mail.gmail.com>
	 <1366663561-12305-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stephen@networkplumber.org
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:45987 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753317Ab3DVWaL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 18:30:11 -0400
Received: by mail-ie0-f175.google.com with SMTP id a11so6495576iee.34
        for <netdev@vger.kernel.org>; Mon, 22 Apr 2013 15:30:10 -0700 (PDT)
In-Reply-To: <1366663561-12305-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-22 at 16:46 -0400, Willem de Bruijn wrote:

> +		len = sizeof(*cur) + netdev_flow_limit_table_len;
[1]
> +		mutex_lock(&flow_limit_update_mutex);
[2]
> +		for_each_possible_cpu(i) {
> +			sd = &per_cpu(softnet_data, i);
> +			cur = rcu_dereference_protected(sd->flow_limit,
> +				      lockdep_is_held(flow_limit_update_mutex));
> +			if (cur && !cpumask_test_cpu(i, mask)) {
> +				RCU_INIT_POINTER(sd->flow_limit, NULL);
> +				synchronize_rcu();
> +				kfree(cur);
> +			} else if (!cur && cpumask_test_cpu(i, mask)) {
> +				cur = kzalloc(len, GFP_KERNEL);
> +				cur->num_buckets = netdev_flow_limit_table_len;
[3]

Its a bit tricky, but the value of netdev_flow_limit_table_len could
change between [1] and [3]

So you should read its value once, or protect the whole thing using
mutex_lock(&flow_limit_update_mutex) in sysctl code ( and move [1] after
[2])
