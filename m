From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] ipv6,mcast: always hold idev->lock before mca_lock
Date: Sat, 11 May 2013 16:11:58 -0700 (PDT)
Message-ID: <20130511.161158.1119064774406426541.davem@davemloft.net>
References: <1367998914-26423-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dingtianhong@huawei.com,
	yoshfuji@linux-ipv6.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60152 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751220Ab3EKXL7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 May 2013 19:11:59 -0400
In-Reply-To: <1367998914-26423-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Wed,  8 May 2013 15:41:54 +0800

> @@ -1369,7 +1370,7 @@ static struct sk_buff *mld_newpack(struct net_device *dev, int size)
>  
>  	skb_reserve(skb, hlen);
>  
> -	if (ipv6_get_lladdr(dev, &addr_buf, IFA_F_TENTATIVE)) {
> +	if (__ipv6_get_lladdr(idev, &addr_buf, IFA_F_TENTATIVE)) {
>  		/* <draft-ietf-magma-mld-source-05.txt>:
>  		 * use unspecified address as the source address
>  		 * when a valid link-local address is not available.

You aren't necessarily going to be holding idev->lock, therefore you can't
just do a lockless traversal of idev->addr_list here.

Yes, you can elide the rcu_read_lock() because you have a known reference
to 'idev' in these paths, but you can't get rid of the address list locking
altogether.
