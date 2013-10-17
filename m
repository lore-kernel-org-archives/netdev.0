From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] fib_trie: Send RTM_DELROUTE when link goes down
Date: Thu, 17 Oct 2013 17:43:21 +0400
Message-ID: <525FE979.3010109@cogentembedded.com>
References: <1382008395-9869-1-git-send-email-kristian.evensen@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kristian Evensen <kristian.evensen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:42570 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755034Ab3JQNoZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 09:44:25 -0400
Received: by mail-lb0-f178.google.com with SMTP id z5so1971708lbh.9
        for <netdev@vger.kernel.org>; Thu, 17 Oct 2013 06:44:24 -0700 (PDT)
In-Reply-To: <1382008395-9869-1-git-send-email-kristian.evensen@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 17-10-2013 15:13, Kristian Evensen wrote:

> From: Kristian Evensen <kristian.evensen@gmail.com>

> When a link is set as down using for example "ip link set dev X down", routes
> are deleted, but RTM_DELROUTE messages are not sent to RTNLGRP_IPV4_ROUTE. This
> patch makes trie_flush_list() send a RTM_DELROUTE for each route that is
> removed, and makes rtnelink route deletion behavior consistent across commands.
> The parameter lists for trie_flush_list() and trie_flush_leaf() are expanded to
> include required information otherwise unavailable in trie_flush_list().

> One use case that is simplified by this patch is IPv4 WAN connection monitoring.
> Instead of listening for and handling both RTM_*ROUTE and RTM_*LINK-messages, it
> is sufficient to handle RTM_*ROUTE.

> Signed-off-by: Kristian Evensen <kristian.evensen@gmail.com>

> ---
>   net/ipv4/fib_trie.c | 16 ++++++++++++----
>   1 file changed, 12 insertions(+), 4 deletions(-)

> diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
> index ec9a9ef..acd5b3b 100644
> --- a/net/ipv4/fib_trie.c
> +++ b/net/ipv4/fib_trie.c
> @@ -1698,15 +1698,23 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
>   	return 0;
>   }
>
> -static int trie_flush_list(struct list_head *head)
> +static int trie_flush_list(struct list_head *head, u32 tb_id, t_key key,
> +		int plen)

    The continuation line should start right under *struct* on the first line, 
according to the networking coding style.

>   {
>   	struct fib_alias *fa, *fa_node;
>   	int found = 0;
> +	struct nl_info cfg;
> +
> +	memset(&cfg, 0, sizeof(cfg));
>
>   	list_for_each_entry_safe(fa, fa_node, head, fa_list) {
>   		struct fib_info *fi = fa->fa_info;
>
>   		if (fi && (fi->fib_flags & RTNH_F_DEAD)) {
> +			cfg.nl_net = fi->fib_net;
> +			rtmsg_fib(RTM_DELROUTE, htonl(key), fa, plen, tb_id,
> +					&cfg, 0);

    Here the line should start right under RTM_DELROUTE.

WBR, Sergei
