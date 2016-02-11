From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 5/7] net: add dst_cache to ovs vxlan lwtunnel
Date: Thu, 11 Feb 2016 12:48:38 +0100
Message-ID: <20160211124838.0b22d29b@griffin>
References: <cover.1455184959.git.pabeni@redhat.com>
	<3e02e47b27bfa69fc2ed6c5a76b3cb20b89a655c.1455184959.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Pravin B Shelar <pshelar@nicira.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Tom Herbert <therbert@google.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53882 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751974AbcBKLso (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Feb 2016 06:48:44 -0500
In-Reply-To: <3e02e47b27bfa69fc2ed6c5a76b3cb20b89a655c.1455184959.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 11 Feb 2016 11:12:01 +0100, Paolo Abeni wrote:
> In case of UDP traffic with datagram length
> below MTU this give about 2% performance increase

The performance increase is not that great probably because of the
addition of the pointer to ip_tunnel_info, making it even fatter than
it is now.

> diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
> index d1bd4a4..f181186 100644
> --- a/net/openvswitch/flow_netlink.c
> +++ b/net/openvswitch/flow_netlink.c
> @@ -1698,6 +1698,7 @@ static void ovs_nla_free_set_action(const struct nlattr *a)
>  	case OVS_KEY_ATTR_TUNNEL_INFO:
>  		ovs_tun = nla_data(ovs_key);
>  		dst_release((struct dst_entry *)ovs_tun->tun_dst);
> +		dst_cache_destroy(&ovs_tun->dst_cache);

We need a helper function for this, operating on ovs_tunnel_info.

>  		break;
>  	}
>  }
> @@ -1928,6 +1929,7 @@ static int validate_and_copy_set_tun(const struct nlattr *attr,
>  {
>  	struct sw_flow_match match;
>  	struct sw_flow_key key;
> +	struct dst_cache dst_cache;
>  	struct metadata_dst *tun_dst;
>  	struct ip_tunnel_info *tun_info;
>  	struct ovs_tunnel_info *ovs_tun;
> @@ -1959,15 +1961,24 @@ static int validate_and_copy_set_tun(const struct nlattr *attr,
>  	if (!tun_dst)
>  		return -ENOMEM;
>  
> +	err = dst_cache_init(&dst_cache, GFP_KERNEL);
> +	if (err) {
> +		dst_release((struct dst_entry *)tun_dst);
> +		return err;
> +	}
> +
>  	a = __add_action(sfa, OVS_KEY_ATTR_TUNNEL_INFO, NULL,
>  			 sizeof(*ovs_tun), log);
>  	if (IS_ERR(a)) {
>  		dst_release((struct dst_entry *)tun_dst);
> +		dst_cache_destroy(&dst_cache);

Make the local variable be of ovs_tunnel_info type and use the helper
function here.

>  		return PTR_ERR(a);
>  	}
>  
>  	ovs_tun = nla_data(a);
>  	ovs_tun->tun_dst = tun_dst;
> +	ovs_tun->dst_cache = dst_cache;

Why are you copying the data here? The cache should be initialized in
place in ovs_tun.

> +	tun_dst->u.tun_info.dst_cache = &ovs_tun->dst_cache;

The absence of reference counting here will lead to use after free when
processing a packet referencing tun_dst while the corresponding
dst_cache memory is freed on flow deletion. Note that tun_dst is
reference counted (see execute_set_action).

 Jiri

-- 
Jiri Benc
