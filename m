From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RFC PATCH net-next 1/5] netns: allocate netns ids
Date: Wed, 02 Jul 2014 17:33:09 +0400
Message-ID: <53B40A15.3030603@cogentembedded.com>
References: <537327F1.4060603@6wind.com> <1404302346-4507-1-git-send-email-nicolas.dichtel@6wind.com> <1404302346-4507-2-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ebiederm@xmission.com,
	stephen@networkplumber.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:56778 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752249AbaGBNdI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 09:33:08 -0400
Received: by mail-lb0-f173.google.com with SMTP id s7so8100973lbd.32
        for <netdev@vger.kernel.org>; Wed, 02 Jul 2014 06:33:06 -0700 (PDT)
In-Reply-To: <1404302346-4507-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 07/02/2014 03:59 PM, Nicolas Dichtel wrote:

> With this patch, netns allocates ids for all netns. Each netns has its own list
> of ids, it means that the id is valid only in the current netns.

> For homogeneity, an id is also allocated for the netns owner itself.

> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
[...]

> diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
> index 85b62691f4f2..2976864cef13 100644
> --- a/net/core/net_namespace.c
> +++ b/net/core/net_namespace.c
> @@ -144,6 +144,30 @@ static void ops_free_list(const struct pernet_operations *ops,
>   	}
>   }
>
> +static int net_eq_idr(int id, void *net, void *peer)
> +{
> +	return net_eq(net, peer) ? id : 0;
> +}
> +
> +int net2id(struct net *net, struct net *peer)
> +{
> +	ASSERT_RTNL();
> +	return idr_for_each(&(net)->netns_ids, net_eq_idr, (peer)) ? : -ENOENT;

    I don't think the inner parens are needed, this is not a macro body...

> +}
> +
> +struct net *get_net_from_netnsid(struct net *net, int id)
> +{
> +	struct net *peer;
> +
> +	rcu_read_lock();
> +	peer = idr_find(&(net)->netns_ids, id);

    Same here.

> +	if (peer)
> +		get_net(peer);
> +	rcu_read_unlock();
> +
> +	return peer;
> +}
> +
>   /*
>    * setup_net runs the initializers for the network namespace object.
>    */
[...]

WBR, Sergei
