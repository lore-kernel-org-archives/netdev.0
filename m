From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: release idev lock before calling
 ipv6_ifa_notify()
Date: Fri, 29 Jan 2016 17:43:03 -0800 (PST)
Message-ID: <20160129.174303.663518084694618919.davem@davemloft.net>
References: <1453970092-10605-1-git-send-email-gregory.herrero@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	linux-kernel@vger.kernel.org
To: gregory.herrero@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453970092-10605-1-git-send-email-gregory.herrero@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gregory Herrero <gregory.herrero@intel.com>
Date: Thu, 28 Jan 2016 09:34:52 +0100

> @@ -2302,8 +2302,11 @@ static void manage_tempaddrs(struct inet6_dev *idev,
>  			ift->flags &= ~IFA_F_DEPRECATED;
>  
>  		spin_unlock(&ift->lock);
> -		if (!(flags&IFA_F_TENTATIVE))
> +		if (!(flags & IFA_F_TENTATIVE)) {
> +			read_unlock_bh(&idev->lock);
>  			ipv6_ifa_notify(0, ift);
> +			read_lock_bh(&idev->lock);
> +		}
>  	}
>  
>  	if ((create || list_empty(&idev->tempaddr_list)) &&

You can't do this, the idev->lock has to be held to keep the list we
are iterating over from changing.
