From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RFC PATCH 11/24] net: rbridge: Add rbr_node management function
Date: Thu, 25 Sep 2014 15:24:17 +0400
Message-ID: <5423FB61.6080804@cogentembedded.com>
References: <1411573940-14079-1-git-send-email-ahmed@gandi.net> <1411573940-14079-12-git-send-email-ahmed@gandi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: william@gandi.net, f.cachereul@alphalink.fr,
	Kamel Haddadou <kamel@gandi.net>
To: Ahmed Amamou <ahmed@gandi.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:43860 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751500AbaIYLYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 07:24:20 -0400
Received: by mail-la0-f41.google.com with SMTP id s18so12445495lam.14
        for <netdev@vger.kernel.org>; Thu, 25 Sep 2014 04:24:18 -0700 (PDT)
In-Reply-To: <1411573940-14079-12-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 9/24/2014 7:52 PM, Ahmed Amamou wrote:

> rbr_node are used to save distant Rbridges information
> they are use by local Rbridge to take routing decision
> this patch add get/put/free/find/del  function to rbr_node to
> avoid freeing a rbr_node that is still in use for routing

> Signed-off-by: Ahmed Amamou <ahmed@gandi.net>
> Signed-off-by: Kamel Haddadou <kamel@gandi.net>
> Signed-off-by: William Dauchy <william@gandi.net>
> ---
>   net/bridge/rbridge/rbr.c         | 34 ++++++++++++++++++++++++++++++++++
>   net/bridge/rbridge/rbr_private.h | 26 ++++++++++++++++++++++++++
>   2 files changed, 60 insertions(+)

> diff --git a/net/bridge/rbridge/rbr.c b/net/bridge/rbridge/rbr.c
> index 8d6d37e..1df8f8d 100644
> --- a/net/bridge/rbridge/rbr.c
> +++ b/net/bridge/rbridge/rbr.c
> @@ -93,3 +93,37 @@ int set_treeroot(struct rbr *rbr, uint16_t treeroot)
>    set_tree_root_fail:
>   	return ENOENT;
>   }
> +
> +struct rbr_node *rbr_find_node(struct rbr *rbr, __u16 nickname)
> +{
> +	struct rbr_node *rbr_node;

    There should be an empty line here, like in the next functions.

> +	if (unlikely(!VALID_NICK(nickname)))
> +		return NULL;
> +	rbr_node = rcu_dereference(rbr->rbr_nodes[nickname]);
> +	rbr_node_get(rbr_node);
> +
> +	return rbr_node;
> +}
> +
> +static void rbr_del_node(struct rbr *rbr, uint16_t nickname)
> +{
> +	struct rbr_node *rbr_node;
> +
> +	if (likely(VALID_NICK(nickname))) {
> +		rbr_node = rbr->rbr_nodes[nickname];
> +		if (likely(rbr_node != NULL)) {
> +			rcu_assign_pointer(rbr->rbr_nodes[nickname], NULL);
> +			rbr_node_put(rbr_node);
> +		}
> +	}
> +}
> +
> +static void rbr_del_all(struct rbr *rbr)
> +{
> +	unsigned int i;
> +
> +	for (i = RBRIDGE_NICKNAME_MIN; i < RBRIDGE_NICKNAME_MAX; i++) {
> +		if (likely(rbr->rbr_nodes[i] != NULL))
> +			rbr_del_node(rbr, i);
> +	}
> +}
[...]

WBR, Sergei
