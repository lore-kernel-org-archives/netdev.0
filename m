From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next v3 6/7] fib: hook IPv4 fib for hardware offload
Date: Wed, 04 Mar 2015 23:03:49 -0800
Message-ID: <54F7FFD5.8080407@gmail.com>
References: <1425425520-34017-1-git-send-email-sfeldma@gmail.com> <1425425520-34017-7-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jiri@resnulli.us,
	roopa@cumulusnetworks.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:41280 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752278AbbCEHEG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 02:04:06 -0500
Received: by obcva8 with SMTP id va8so842638obc.8
        for <netdev@vger.kernel.org>; Wed, 04 Mar 2015 23:04:05 -0800 (PST)
In-Reply-To: <1425425520-34017-7-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/03/2015 03:31 PM, sfeldma@gmail.com wrote:
> From: Scott Feldman <sfeldma@gmail.com>
>
> Call into the switchdev driver any time an IPv4 fib entry is
> added/modified/deleted from the kernel's FIB.  The switchdev driver may or
> may not install the route to the offload device.  In the case where the
> driver tries to install the route and something goes wrong (device's routing
> table is full, etc), then all of the offloaded routes will be flushed from the
> device, and route forwarding falls back to the kernel.
>
> We can refine this fail-over logic in subsequent patches.  For now, use the
> simplist model of offloading routes up to the point of failure, and then on
> failure, undo everything.
>
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> ---

[...]

> @@ -1197,12 +1209,20 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
>   	new_fa->fa_state = 0;
>   	new_fa->fa_slen = slen;
>
> +	/* (Optionally) offload fib entry to switch hardware. */
> +	err = netdev_switch_fib_ipv4_add(key, plen, fi, tos,
> +					 cfg->fc_type, tb->tb_id);
> +	if (err) {
> +		fib_flush_external(fi->fib_net);
> +		goto out_free_new_fa;
> +	}
> +


Don't you need something to disable further fib entries from being added
once you get a failure and flush the table? Maybe I'm just not seeing.

The case being you add a set of entries, you get a failure and flush the
table then add another entry. The last entry is successfully inserted
but now your out of sync.

>   	/* Insert new entry to the list. */
>   	if (!l) {
>   		l = fib_insert_node(t, key, plen);
>   		if (unlikely(!l)) {
>   			err = -ENOMEM;
> -			goto out_free_new_fa;
> +			goto out_sw_fib_del;
>   		}
>   	}
>

Thanks.


-- 
John Fastabend         Intel Corporation
