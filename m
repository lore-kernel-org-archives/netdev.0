From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [net-next] neigh: remove duplicate check for same neigh
Date: Tue, 29 Nov 2016 09:22:49 -0700
Message-ID: <d641245a-8442-9238-a507-6f94184354a0@cumulusnetworks.com>
References: <1480407771-12884-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:32984 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753639AbcK2QWx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 11:22:53 -0500
Received: by mail-pf0-f176.google.com with SMTP id d2so32810612pfd.0
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 08:22:52 -0800 (PST)
In-Reply-To: <1480407771-12884-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/29/16 1:22 AM, Zhang Shengju wrote:
> @@ -2285,20 +2295,15 @@ static int neigh_dump_table(struct neigh_table *tbl, struct sk_buff *skb,
>  	rcu_read_lock_bh();
>  	nht = rcu_dereference_bh(tbl->nht);
>  
> -	for (h = s_h; h < (1 << nht->hash_shift); h++) {
> -		if (h > s_h)
> -			s_idx = 0;
> +	for (h = s_h; h < (1 << nht->hash_shift); h++, s_idx = 0) {
>  		for (n = rcu_dereference_bh(nht->hash_buckets[h]), idx = 0;
>  		     n != NULL;
> -		     n = rcu_dereference_bh(n->next)) {
> -			if (!net_eq(dev_net(n->dev), net))
> -				continue;
> -			if (neigh_ifindex_filtered(n->dev, filter_idx))
> +		     n = rcu_dereference_bh(n->next), idx++) {

incrementing idx here ...

> +			if (idx < s_idx || !net_eq(dev_net(n->dev), net))
>  				continue;
> -			if (neigh_master_filtered(n->dev, filter_master_idx))
> +			if (neigh_dump_filtered(n->dev, filter_idx,
> +						filter_master_idx))
>  				continue;
> -			if (idx < s_idx)
> -				goto next;
>  			if (neigh_fill_info(skb, n, NETLINK_CB(cb->skb).portid,
>  					    cb->nlh->nlmsg_seq,
>  					    RTM_NEWNEIGH,

... causes a missed entry when an error happens here

idx is only incremented when a neigh has been successfully added to the skb.


Your intention is to save a few cycles by making idx an absolute index within the hash bucket and jumping to the next entry to be dumped without evaluating any filters per entry.

So why not keep it simple and do this:

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 2ae929f9bd06..2e49a85e696a 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2291,14 +2291,12 @@ static int neigh_dump_table(struct neigh_table *tbl, struct sk_buff *skb,
                for (n = rcu_dereference_bh(nht->hash_buckets[h]), idx = 0;
                     n != NULL;
                     n = rcu_dereference_bh(n->next)) {
-                       if (!net_eq(dev_net(n->dev), net))
-                               continue;
-                       if (neigh_ifindex_filtered(n->dev, filter_idx))
-                               continue;
-                       if (neigh_master_filtered(n->dev, filter_master_idx))
-                               continue;
                        if (idx < s_idx)
                                goto next;
+                       if (!net_eq(dev_net(n->dev), net) ||
+                           neigh_ifindex_filtered(n->dev, filter_idx) ||
+                           neigh_master_filtered(n->dev, filter_master_idx))
+                               goto next;
                        if (neigh_fill_info(skb, n, NETLINK_CB(cb->skb).portid,
                                            cb->nlh->nlmsg_seq,
                                            RTM_NEWNEIGH,
