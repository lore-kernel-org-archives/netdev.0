From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net] ipv6,mcast: always hold idev->lock before mca_lock
Date: Thu, 06 Jun 2013 10:35:01 +0800
Message-ID: <1370486101.31875.10.camel@cr0>
References: <1367998914-26423-1-git-send-email-amwang@redhat.com>
	 <20130511.161158.1119064774406426541.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dingtianhong@huawei.com,
	yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22794 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754385Ab3FFCfO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jun 2013 22:35:14 -0400
In-Reply-To: <20130511.161158.1119064774406426541.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-05-11 at 16:11 -0700, David Miller wrote:
> From: Cong Wang <amwang@redhat.com>
> Date: Wed,  8 May 2013 15:41:54 +0800
> 
> > @@ -1369,7 +1370,7 @@ static struct sk_buff *mld_newpack(struct net_device *dev, int size)
> >  
> >  	skb_reserve(skb, hlen);
> >  
> > -	if (ipv6_get_lladdr(dev, &addr_buf, IFA_F_TENTATIVE)) {
> > +	if (__ipv6_get_lladdr(idev, &addr_buf, IFA_F_TENTATIVE)) {
> >  		/* <draft-ietf-magma-mld-source-05.txt>:
> >  		 * use unspecified address as the source address
> >  		 * when a valid link-local address is not available.
> 
> You aren't necessarily going to be holding idev->lock, therefore you can't
> just do a lockless traversal of idev->addr_list here.
> 
> Yes, you can elide the rcu_read_lock() because you have a known reference
> to 'idev' in these paths, but you can't get rid of the address list locking
> altogether.

(Apologize for the delay...)

The upper callers of mld_newpack() already take
read_lock_bh(&idev->lock): 


mld_newpack() ...-> add_grec() -|-> mld_send_cr()     LOCKED
                                |-> mld_send_report() LOCKED


therefore it is safe to travel idev->addr_list locklessly here.
