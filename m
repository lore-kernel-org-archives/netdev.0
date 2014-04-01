From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vxlan: using AF_PACKET socket to send multicast packet
 cause WARNING
Date: Tue, 01 Apr 2014 16:10:47 -0400 (EDT)
Message-ID: <20140401.161047.854771903443514987.davem@davemloft.net>
References: <1396343330-23648-1-git-send-email-lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54882 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751419AbaDAUKu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 16:10:50 -0400
In-Reply-To: <1396343330-23648-1-git-send-email-lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Tue,  1 Apr 2014 17:08:50 +0800

> dev_queue_xmit()->dev_hard_start_xmit()->vxlan_xmit()->ip_tunnel_xmit()->ip_mc_output(),
> after reaching ip_mc_output(), it will check the mc_loop by sk_mc_loop(), but
> it have no case for AF_PACKET, then cause WARN_ON(1).
 ...
> --- a/include/net/ip.h
> +++ b/include/net/ip.h
> @@ -428,6 +428,8 @@ static inline int sk_mc_loop(struct sock *sk)
>  	case AF_INET6:
>  		return inet6_sk(sk)->mc_loop;
>  #endif
> +	case AF_PACKET:
> +		return 1;
>  	}
>  	WARN_ON(1);
>  	return 1;

This is not the correct fix.

If vxlan is going to reinject dev_hard_start_xmit() bound packets into
the ipv4 stack, it must make sure that they are well formed.

The SKB traversing the ipv4 stack must either be bound to an ipv4/ipv6
socket or be orphaned.
