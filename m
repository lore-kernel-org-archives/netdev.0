From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: RFC: bridge get fdb by bridge device
Date: Sun, 09 Feb 2014 11:33:02 -0800
Message-ID: <52F7D7EE.7010302@gmail.com>
References: <52F21F72.2090405@mojatatu.com> <52F29747.7040008@redhat.com> <52F3CF76.9090404@mojatatu.com> <52F3E357.4040006@redhat.com> <52F79990.3000400@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	vyasevic@redhat.com,
	Stephen Hemminger <stephen@networkplumber.org>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:54667 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751548AbaBITdZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Feb 2014 14:33:25 -0500
Received: by mail-ob0-f180.google.com with SMTP id wp4so6290672obc.39
        for <netdev@vger.kernel.org>; Sun, 09 Feb 2014 11:33:25 -0800 (PST)
In-Reply-To: <52F79990.3000400@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/09/2014 07:06 AM, Jamal Hadi Salim wrote:
>
> This patch allows something equivalent to
> "brctl showmacs <bridge device>" with iproute2
> syntax "bridge link br <bridge device>"
> Filtering by bridge is done in the kernel.
> The current setup doesnt scale when you have many bridges each
> with large fdbs (preliminary fix with the kernel patch).
>
> iproute2 allows filtering by bridge port, example:
> "bridge link br br1234 dev port1234"
> but the filtering is done in user space.
> In a future patch i would like to do the port filtering
> in the kernel. As well, adding a MAC filter in the kernel
> makes sense.
>
> Kernel patch is against net-next.
>
> cheers,
> jamal

[...]

> +	if (ndm->ndm_ifindex) {
> +		dev = __dev_get_by_index(net, ndm->ndm_ifindex);
> +		if (dev == NULL) {
> +			pr_info("PF_BRIDGE: RTM_GETNEIGH with unknown ifindex\n");
> +			return -ENODEV;
> +		}
> +	
> +		if (!(dev->priv_flags & IFF_EBRIDGE)) {

Can we drop this 'if case' and just use the 'if (ops->ndo_fdb_dump)'
below? IFF_EBRIDGE is specific to ./net/bridge so it will fail for
macvlans and I think the command is useful in both cases.


> +			pr_info("PF_BRIDGE: RTM_GETNEIGH %s not a bridge device\n",
> +				dev->name);
> +			return -EINVAL;
>  		}
> +		ops = dev->netdev_ops;
> +		if (ops->ndo_fdb_dump) {
> +			idx = ops->ndo_fdb_dump(skb, cb, dev, idx);
> +		} else {

Is there any problem with using the ndo_dflt_fdb_dump() in the else
here?

Userspace should be able to easily learn which ports are ebridge ports
so I don't think that should be an issue. Anyways with the above
IFF_EBRIDGE check you should never hit this else case although I think
its safe to drop the above check as noted.

> +			pr_info("PF_BRIDGE: RTM_GETNEIGH %s no dumper\n",
> +				dev->name);
> +			return -EINVAL;
> +		}
> +	} else {

Thanks,
John

-- 
John Fastabend         Intel Corporation
