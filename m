From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 6/6] netlink: allow to listen "all" netns
Date: Wed, 6 May 2015 14:10:22 +0200
Message-ID: <20150506121022.GG25248@pox.localdomain>
References: <1430906288-5108-1-git-send-email-nicolas.dichtel@6wind.com>
 <1430906288-5108-7-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, ebiederm@xmission.com
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:32850 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751029AbbEFMKZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 08:10:25 -0400
Received: by wgin8 with SMTP id n8so9264257wgi.0
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 05:10:24 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1430906288-5108-7-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/06/15 at 11:58am, Nicolas Dichtel wrote:
> More accurately, listen all netns that have a nsid assigned into the netns
> where the netlink socket is opened.
> For this purpose, a netlink socket option is added:
> NETLINK_LISTEN_ALL_NSID. When this option is set on a netlink socket, this
> socket will receive netlink notifications from all netns that have a nsid
> assigned into the netns where the socket has been opened. The nsid is sent
> to userland via an anscillary data.
> 
> With this patch, a daemon needs only one socket to listen many netns. This
> is useful when the number of netns is high.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

[...]

> +/* This function returns true is the peer netns has an id assigned into the
> + * current netns.
> + */
> +bool peernet_has_id(struct net *net, struct net *peer)
> +{
> +	return peernet2id(net, peer) >= 0;
> +}

Missing export?

> +
>  struct net *get_net_ns_by_id(struct net *net, int id)
>  {
>  	unsigned long flags;
> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> index ec4adbdcb9b4..bdbde542e952 100644
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -83,6 +83,7 @@ struct listeners {
>  #define NETLINK_RECV_PKTINFO	0x2
>  #define NETLINK_BROADCAST_SEND_ERROR	0x4
>  #define NETLINK_RECV_NO_ENOBUFS	0x8
> +#define NETLINK_LISTEN_ALL	0x10

Maybe name this NETLINK_LISTEN_ALL_NSID just to make it clear?

> +		if (!file_ns_capable(sk->sk_socket->file, p->net->user_ns,
> +				     CAP_NET_BROADCAST))
> +			return;
> +	}
> +	NETLINK_CB(p->skb).net = p->net;

Does this need a get_net()? The netns could disappear while the skb is
queued, right?
