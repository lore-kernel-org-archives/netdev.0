From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] fib_trie: Send RTM_DELROUTE when link goes down
Date: Thu, 17 Oct 2013 10:23:30 -0700
Message-ID: <1382030610.22110.112.camel@joe-AO722>
References: <CAKfDRXizw1TaK-oHrAQv8Hi80gKiUHjQ6d21o3MOQpuVkcXSow@mail.gmail.com>
	 <1382028894-14236-1-git-send-email-kristian.evensen@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kristian Evensen <kristian.evensen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0046.hostedemail.com ([216.40.44.46]:51604 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755608Ab3JQRXd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 13:23:33 -0400
In-Reply-To: <1382028894-14236-1-git-send-email-kristian.evensen@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-10-17 at 18:54 +0200, Kristian Evensen wrote:
> From: Kristian Evensen <kristian.evensen@gmail.com>
> 
> When a link is set as down using for example "ip link set dev X down", routes
> are deleted, but RTM_DELROUTE messages are not sent to RTNLGRP_IPV4_ROUTE. This
> patch makes trie_flush_list() send a RTM_DELROUTE for each route that is
> removed, and makes rtnelink route deletion behavior consistent across commands.
> The parameter lists for trie_flush_list() and trie_flush_leaf() are expanded to
> include required information otherwise unavailable in trie_flush_list().
[]
> diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
[]
> @@ -1698,15 +1698,23 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
>  	return 0;
>  }
>  
> -static int trie_flush_list(struct list_head *head)
> +static int trie_flush_list(struct list_head *head, u32 tb_id, t_key key,
> +			    int plen)
>  {
>  	struct fib_alias *fa, *fa_node;
>  	int found = 0;
> +	struct nl_info cfg;
> +
> +	memset(&cfg, 0, sizeof(cfg));

Perhaps this memset should be moved into the
list_for_each_entry_safe loop where cfg is used.
 
>  	list_for_each_entry_safe(fa, fa_node, head, fa_list) {
>  		struct fib_info *fi = fa->fa_info;
>  
>  		if (fi && (fi->fib_flags & RTNH_F_DEAD)) {

			memset(&cfg, 0, sizeof(cfg));

?

> +			cfg.nl_net = fi->fib_net;
> +			rtmsg_fib(RTM_DELROUTE, htonl(key), fa, plen, tb_id,
> +				  &cfg, 0);
