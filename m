From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v2 3/3] igmp: convert RTNL lock to a spinlock
Date: Thu, 06 Jun 2013 08:36:03 +0800
Message-ID: <1370478963.31875.2.camel@cr0>
References: <1370425101-31683-1-git-send-email-amwang@redhat.com>
	 <1370425101-31683-3-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53593 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754106Ab3FFAgM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jun 2013 20:36:12 -0400
In-Reply-To: <1370425101-31683-3-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-05 at 17:38 +0800, Cong Wang wrote:
> -       while ((i = rtnl_dereference(in_dev->mc_list)) != NULL) {
> -               in_dev->mc_list = i->next_rcu;
> +       spin_lock(&ipv4_sk_mc_lock);
> +       while ((i = rcu_dereference_protected(in_dev->mc_list,
> +                       lockdep_is_held(&ipv4_sk_mc_lock))) != NULL) {
> +               rcu_assign_pointer(in_dev->mc_list, i->next_rcu);
>                 in_dev->mc_count--;
>  
>                 /* We've dropped the groups in ip_mc_down already */
>                 ip_mc_clear_src(i);
>                 ip_ma_put(i);
>         }
> +       spin_unlock(&ipv4_sk_mc_lock);
> +       synchronize_rcu(); 

Hmm, it seems this kind synchronize_rcu() is not needed, since we don't
free anything here, not very sure if it is okay that readers still have
the old value of ->mc_list... I think probably yes.
