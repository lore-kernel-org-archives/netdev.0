From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 3/3] vxlan: allow multiple VXLANs with same VNI
 for IPv6 link-local addresses
Date: Tue, 14 Mar 2017 16:28:15 +0100
Message-ID: <20170314162815.7aae9e94@griffin>
References: <cover.1489184335.git.mschiffer@universe-factory.net>
        <5c74248483272110d0ca249b80b943b0ceb0b610.1489184335.git.mschiffer@universe-factory.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, hannes@stressinduktion.org, pshelar@ovn.org,
        aduyck@mirantis.com, roopa@cumulusnetworks.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Matthias Schiffer <mschiffer@universe-factory.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5c74248483272110d0ca249b80b943b0ceb0b610.1489184335.git.mschiffer@universe-factory.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 10 Mar 2017 23:39:44 +0100, Matthias Schiffer wrote:
> @@ -233,17 +234,30 @@ static struct vxlan_dev *vxlan_vs_find_vni(struct vxlan_sock *vs, __be32 vni)
>  		vni = 0;
>  
>  	hlist_for_each_entry_rcu(vxlan, vni_head(vs, vni), hlist) {
> -		if (vxlan->default_dst.remote_vni == vni)
> -			return vxlan;
> +		if (vxlan->default_dst.remote_vni != vni)
> +			continue;
> +
> +		if (IS_ENABLED(CONFIG_IPV6)) {
> +			const struct vxlan_config *cfg = &vxlan->cfg;
> +
> +			if (cfg->remote_ifindex != 0 &&
> +			    cfg->remote_ifindex != ifindex &&
> +			    cfg->saddr.sa.sa_family == AF_INET6 &&
> +			    (ipv6_addr_type(&cfg->saddr.sin6.sin6_addr) &
> +			     IPV6_ADDR_LINKLOCAL))

Calculating this (especially ipv6_addr_type) on every received packet
looks unnecessarily expensive. Just store the fact the the local
address is link-local in a flag during config. And compare the flag
first before considering remote_ifindex.

This is especially important for lwtunnels which can have anything in
the saddr and remote_ifindex, yet those fields are ignored and the
vni 0 entry has to be returned. It also means that the link-local flag
must not be set for lwtunnels.

> +#if IS_ENABLED(CONFIG_IPV6)
> +		if (conf->remote_ifindex != tmp->cfg.remote_ifindex &&
> +		    conf->saddr.sa.sa_family == AF_INET6 &&
> +		    tmp->cfg.saddr.sa.sa_family == AF_INET6 &&
> +		    (ipv6_addr_type(&conf->saddr.sin6.sin6_addr) &
> +		     IPV6_ADDR_LINKLOCAL) &&
> +		    (ipv6_addr_type(&tmp->cfg.saddr.sin6.sin6_addr) &
> +		     IPV6_ADDR_LINKLOCAL))
> +			continue;
> +#endif

In patch 1, you're checking for either source and destination address
being link-local, while here you're consider only those that have both
addresses link-local.

Wouldn't it be better to plainly reject configuration that has one
address link-local but not the other one?

 Jiri
