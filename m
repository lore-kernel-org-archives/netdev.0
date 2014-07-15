From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next v2 01/11] openvswitch: Allow each vport to have
 an array of 'port_id's.
Date: Tue, 15 Jul 2014 19:31:04 +0200
Message-ID: <53C56558.5090404@redhat.com>
References: <1405444476-16867-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alex Wang <alexw@nicira.com>
To: Pravin B Shelar <pshelar@nicira.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9467 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751595AbaGORbJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2014 13:31:09 -0400
In-Reply-To: <1405444476-16867-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

<snip>
> +/**
> + *	ovs_vport_set_upcall_portids - set upcall portids of @vport.
> + *
> + * @vport: vport to modify.
> + * @ids: new configuration, an array of port ids.
> + *
> + * Sets the vport's upcall_portids to @ids.
> + *
> + * Returns 0 if successful, -EINVAL if @ids is zero length or cannot be parsed
> + * as an array of U32.
> + *
> + * Must be called with ovs_mutex.
> + */
> +int ovs_vport_set_upcall_portids(struct vport *vport,  struct nlattr *ids)
> +{
> +	struct vport_portids *old, *vport_portids;
> +
> +	if (!nla_len(ids) || nla_len(ids) % sizeof(u32))
> +		return -EINVAL;
> +
> +	old = ovsl_dereference(vport->upcall_portids);
> +
> +	vport_portids = kmalloc(sizeof(*vport_portids) + nla_len(ids),
> +				GFP_KERNEL);
^^^^^^^
Shouldn't there be a null check after the kmalloc instead of directly
dereferencing vport_portids ?

> +	vport_portids->n_ids = nla_len(ids) / sizeof(u32);
> +	vport_portids->rn_ids = reciprocal_value(vport_portids->n_ids);
> +	nla_memcpy(vport_portids->ids, ids, nla_len(ids));
> +
> +	rcu_assign_pointer(vport->upcall_portids, vport_portids);
> +
> +	if (old)
> +		call_rcu(&old->rcu, vport_portids_destroy_rcu_cb);
> +
> +	return 0;
> +}
<snip>
