From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net-next v1 1/3] igmp: avoid taking RTNL for
 ip_mc_find_dev()
Date: Tue, 04 Jun 2013 21:07:02 -0700
Message-ID: <1370405222.24311.231.camel@edumazet-glaptop>
References: <1370403211-6851-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:58175 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750713Ab3FEEHF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jun 2013 00:07:05 -0400
Received: by mail-pd0-f171.google.com with SMTP id z11so1218464pdj.30
        for <netdev@vger.kernel.org>; Tue, 04 Jun 2013 21:07:03 -0700 (PDT)
In-Reply-To: <1370403211-6851-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-05 at 11:33 +0800, Cong Wang wrote:
> From: Cong Wang <amwang@redhat.com>
> 
> RCU is enough to protect ip_mc_find_dev().
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>
> ---
>  net/ipv4/igmp.c |   48 ++++++++++++++++++------------------------------
>  1 files changed, 18 insertions(+), 30 deletions(-)
> 
> diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
> index 450f625..d3218c0 100644
> --- a/net/ipv4/igmp.c
> +++ b/net/ipv4/igmp.c
> @@ -1433,7 +1433,6 @@ void ip_mc_destroy_dev(struct in_device *in_dev)
>  	}
>  }
>  
> -/* RTNL is locked */
>  static struct in_device *ip_mc_find_dev(struct net *net, struct ip_mreqn *imr)
>  {
>  	struct net_device *dev = NULL;
> @@ -1459,8 +1458,10 @@ static struct in_device *ip_mc_find_dev(struct net *net, struct ip_mreqn *imr)
>  		}
>  	}
>  	if (dev) {
> +		rcu_read_lock();
>  		imr->imr_ifindex = dev->ifindex;
> -		idev = __in_dev_get_rtnl(dev);
> +		idev = __in_dev_get_rcu(dev);
> +		rcu_read_unlock();
>  	}
>  	return idev;
>  }


You must be kidding.

This is obviously wrong.
