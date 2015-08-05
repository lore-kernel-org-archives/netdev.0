From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v3 2/3] openvswitch: Use regular GRE net_device
 instead of vport
Date: Tue, 4 Aug 2015 19:27:04 -0700
Message-ID: <20150805022701.GA50708@Alexeis-MacBook-Pro.local>
References: <1438730555-3142-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f173.google.com ([209.85.160.173]:33860 "EHLO
	mail-yk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751233AbbHEC1I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 22:27:08 -0400
Received: by ykax123 with SMTP id x123so24688540yka.1
        for <netdev@vger.kernel.org>; Tue, 04 Aug 2015 19:27:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1438730555-3142-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 04, 2015 at 04:22:35PM -0700, Pravin B Shelar wrote:
> Following patch adds support for flow based tunnel to GRE
> tap deivces. Using flow based tunneling, we can implement
> OVS GRE vport. This patch removes all of the OVS
> specific GRE code and make OVS use a ip_gre net_device.
> Minimal GRE vport is kept to handle compatibility with
> current userspace application.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
...
> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
...
> +struct net_device *ipgre_fb_dev_create(struct net *net, const char *name,
> +				       u8 name_assign_type)
> +{
> +	struct ip_tunnel_net *itn = net_generic(net, gre_tap_net_id);
> +	struct nlattr *tb[IFLA_MAX + 1];
> +	struct net_device *dev;
> +	struct ip_tunnel *t;
> +	int err;
> +
> +	if (rtnl_dereference(itn->flow_based_tunnel))
> +		return ERR_PTR(-EEXIST);
> +
> +	memset(&tb, 0, sizeof(tb));
> +
> +	dev = rtnl_create_link(net, name, name_assign_type,
> +			       &ipgre_tap_ops, tb);
> +	if (IS_ERR(dev))
> +		return dev;
> +
> +	/* Configure flow based GRE device. */
> +	t = netdev_priv(dev);
> +	t->is_fb_tunnel = true;
> +
> +	err = ipgre_newlink(net, dev, tb, NULL);
> +	if (err < 0)
> +		goto out;
> +	return dev;
> +out:
> +	free_netdev(dev);
> +	return ERR_PTR(err);
> +}
> +EXPORT_SYMBOL_GPL(ipgre_fb_dev_create);

...
> diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
...
> +static struct vport *gre_tnl_create(const struct vport_parms *parms)
>  {
...
> +	rtnl_lock();
> +	dev = ipgre_fb_dev_create(net, parms->name, NET_NAME_USER);
> +	if (IS_ERR(dev)) {
> +		rtnl_unlock();
> +		ovs_vport_free(vport);
> +		return ERR_CAST(dev);

So the code from vport-gre.c got moved into ip_gre.c and ipgre_fb_dev_create()
got exported with the only user being ovs vport-gre ?!
Then the proper commit message should say 'move ovs specific gre bits
to ip_gre.c', since the only way to use it is to create ovs vport-gre.
Instead, can you please do it similar to Thomas's vxlan patch so that
such gre tunnel can actually be usable outside of ovs?
