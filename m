From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v6 1/8] vxlan: Restructure vxlan socket apis.
Date: Sun, 4 Aug 2013 14:42:15 -0700
Message-ID: <20130804144215.640c9336@nehalam.linuxnetplumber.net>
References: <1375382680-3137-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:39761 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753934Ab3HDVmT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Aug 2013 17:42:19 -0400
Received: by mail-pb0-f48.google.com with SMTP id ma3so2589866pbc.21
        for <netdev@vger.kernel.org>; Sun, 04 Aug 2013 14:42:19 -0700 (PDT)
In-Reply-To: <1375382680-3137-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  1 Aug 2013 11:44:40 -0700
Pravin B Shelar <pshelar@nicira.com> wrote:

> @@ -1642,59 +1651,56 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port)
>  			 &vxlan_addr.sin_addr, ntohs(vxlan_addr.sin_port), rc);
>  		sk_release_kernel(sk);
>  		kfree(vs);
> -		return ERR_PTR(rc);
> +		return;
>  	}
> +	atomic_set(&vs->refcnt, 0);
>  
>  	/* Disable multicast loopback */
>  	inet_sk(sk)->mc_loop = 0;
> +	spin_lock(&vn->sock_lock);
> +	hlist_add_head_rcu(&vs->hlist, vs_head(net, port));
> +	spin_unlock(&vn->sock_lock);

Overall I am fine with this set, except for this.
The change causes a socket to be put into the hash list with a ref count
of 0 and then you increment the ref count. If some other thread
finds the socket and then decrements the ref count, it would go
below zero and might leak, crash or delete it prematurely.

This concerns me. 
