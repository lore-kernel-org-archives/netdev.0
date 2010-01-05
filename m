From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] igmp: fix ip_mc_sf_allow race [v3]
Date: Tue, 5 Jan 2010 15:03:04 -0800
Message-ID: <20100105150304.73d435da@nehalam>
References: <4B42E252.1080405@gmail.com>
	<1262724742-5232-1-git-send-email-fleitner@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	David Stevens <dlstevens@us.ibm.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Flavio Leitner <fleitner@redhat.com>
To: Flavio Leitner <fleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55438 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753320Ab0AEXDc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jan 2010 18:03:32 -0500
In-Reply-To: <1262724742-5232-1-git-send-email-fleitner@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  5 Jan 2010 18:52:22 -0200
Flavio Leitner <fleitner@redhat.com> wrote:

> @@ -2245,13 +2269,17 @@ void ip_mc_drop_socket(struct sock *sk)
>  	struct ip_mc_socklist *iml;
>  	struct net *net = sock_net(sk);
>  
> -	if (inet->mc_list == NULL)
> +	rcu_read_lock();
> +	if (rcu_dereference(inet->mc_list) == NULL) {
> +		rcu_read_unlock();
>  		return;
> +	}
> +	rcu_read_unlock();
>  
>  	rtnl_lock();
> -	while ((iml = i

All this would be cleaner if mc_list was using list_head and the
existing list_head_rcu stuff.



-- 
