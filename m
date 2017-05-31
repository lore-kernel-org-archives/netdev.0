From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH V3] neigh: Really delete an arp/neigh entry on "ip neigh
 delete" or "arp -d"
Date: Thu, 1 Jun 2017 00:41:33 +0300 (EEST)
Message-ID: <alpine.LFD.2.20.1705312337280.5775@ja.home.ssi.bg>
References: <1496188346-83229-1-git-send-email-sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        stephen@networkplumber.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:56158 "EHLO ja.ssi.bg"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750952AbdEaVlv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 May 2017 17:41:51 -0400
In-Reply-To: <1496188346-83229-1-git-send-email-sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 30 May 2017, Sowmini Varadhan wrote:

> @@ -1650,6 +1689,7 @@ static int neigh_delete(struct sk_buff *skb, struct nlmsghdr *nlh,
>  			   NEIGH_UPDATE_F_ADMIN,
>  			   NETLINK_CB(skb).portid);
>  	neigh_release(neigh);
> +	neigh_remove_one(neigh, tbl);

	So, we do not hold reference to neigh while accessing
its fields. I suspect we need to move the table lock from
neigh_remove_one here, for example:

+	write_lock_bh(&tbl->lock);
	neigh_release(neigh);
+	neigh_remove_one(neigh, tbl);
+	write_unlock_bh(&tbl->lock);

	Otherwise, neigh_forced_gc can call neigh_destroy
where neigh is freed (and replaced by another neigh entry) after
RCU grace period (which can end prematurely if there are no
running RCU read-side critical sections) and I'm not sure if
our thread can be delayed, so that such pointer replacement
can happen unnoticed by us.

	Another solution to cause faster removal would be
to cancel the gc_work and to schedule it after 1 jiffie.
It helps when many entries are deleted at once but the
work prefers to just sleep when gc_thresh1 is not reached,
so such solution is not good enough.

Regards
