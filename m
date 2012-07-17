From: Joe Perches <joe@perches.com>
Subject: Re: [net-next PATCH 01/02] net/ipv4: VTI support rx-path hook in
 xfrm4_mode_tunnel.
Date: Tue, 17 Jul 2012 13:36:42 -0700
Message-ID: <1342557402.15318.22.camel@joe2Laptop>
References: <20120717194449.GA3350@debian-saurabh-64.vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Saurabh <saurabh.mohan@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:35623 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753858Ab2GQUgo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jul 2012 16:36:44 -0400
In-Reply-To: <20120717194449.GA3350@debian-saurabh-64.vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-07-17 at 12:44 -0700, Saurabh wrote:
> Incorporated David and Steffen's comments.
> Add hook for rx-path xfmr4_mode_tunnel for VTI tunnel module.
[]
> diff --git a/net/ipv4/xfrm4_mode_tunnel.c b/net/ipv4/xfrm4_mode_tunnel.c
[]
> +int xfrm4_mode_tunnel_input_register(struct xfrm_tunnel *handler)
> +{
> +	struct xfrm_tunnel __rcu **pprev;
> +	struct xfrm_tunnel *t;
> +	int ret = -EEXIST;
> +	int priority = handler->priority;
> +
> +	mutex_lock(&xfrm4_mode_tunnel_input_mutex);
> +
> +	for (pprev = &rcv_notify_handlers;
> +	     (t = rcu_dereference_protected(*pprev,
> +	     lockdep_is_held(&xfrm4_mode_tunnel_input_mutex))) != NULL;
> +	     pprev = &t->next) {
> +		if (t->priority > priority)
> +			break;
> +		if (t->priority == priority)
> +			goto err;
> +
> +	}
> +
> +	handler->next = *pprev;
> +	rcu_assign_pointer(*pprev, handler);
> +
> +	ret = 0;
> +
> +err:
> +	mutex_unlock(&xfrm4_mode_tunnel_input_mutex);
> +	return ret;
> +}
> +EXPORT_SYMBOL_GPL(xfrm4_mode_tunnel_input_register);

Isn't the multiple indirection of **pprev unnecessary?
Perhaps something like this is simpler and easier to read?

int xfrm4_mode_tunnel_input_register(struct xfrm_tunnel *handler)
{
	struct xfrm_tunnel __rcu *prev;
	struct xfrm_tunnel *t;
	int ret = -EEXIST;
	int priority = handler->priority;

	mutex_lock(&xfrm4_mode_tunnel_input_mutex);

	prev = rcv_notify_handlers;
	while ((t = rcu_dereference_protected(prev,
					      lockdep_is_held(&xfrm4_mode_tunnel_input_mutex))) {
		if (t->priority > priority)
			break;
		if (t->priority == priority)
			goto err;
		prev = t->next;
	}

	handler->next = prev;
	rcu_assign_pointer(prev, handler);

	ret = 0;

err:
	mutex_unlock(&xfrm4_mode_tunnel_input_mutex);
	return ret;
}
