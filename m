From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH v2] tipc: avoid possible deadlock while enable and disable
 bearer
Date: Fri, 9 Aug 2013 17:34:05 +0800
Message-ID: <5204B78D.4090509@windriver.com>
References: <5204B29A.80809@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>,
	Allan Stephens <allan.stephens@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	<tipc-discussion@lists.sourceforge.net>,
	Netdev <netdev@vger.kernel.org>, <wangweidong1@huawei.com>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:36135 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964961Ab3HIJed (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 05:34:33 -0400
In-Reply-To: <5204B29A.80809@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> The problem is that the tipc_link_delete() will cancel the timer disc_timeout() when
> the b_ptr->lock is hold, but the disc_timeout() still call b_ptr->lock to finish the
> work, so the dead lock occurs.
> 
> We should unlock the b_ptr->lock when del the disc_timeout().
> 
> Remove link_timeout() still met the same problem, the patch:
> 
> http://article.gmane.org/gmane.network.tipc.general/4380
> 
> fix the problem, so no need to send patch for fix link_timeout() deadlock warming.
> 
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> Cc: Ying Xue <ying.xue@windriver.com>

Ack-by: Ying Xue <ying.xue@windriver.com>

> ---
>  net/tipc/bearer.c | 9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
> 
> diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
> index cb29ef7..609c30c 100644
> --- a/net/tipc/bearer.c
> +++ b/net/tipc/bearer.c
> @@ -460,6 +460,7 @@ static void bearer_disable(struct tipc_bearer *b_ptr)
>  {
>  	struct tipc_link *l_ptr;
>  	struct tipc_link *temp_l_ptr;
> +	struct tipc_link_req *temp_req;
>  
>  	pr_info("Disabling bearer <%s>\n", b_ptr->name);
>  	spin_lock_bh(&b_ptr->lock);
> @@ -468,9 +469,13 @@ static void bearer_disable(struct tipc_bearer *b_ptr)
>  	list_for_each_entry_safe(l_ptr, temp_l_ptr, &b_ptr->links, link_list) {
>  		tipc_link_delete(l_ptr);
>  	}
> -	if (b_ptr->link_req)
> -		tipc_disc_delete(b_ptr->link_req);
> +	temp_req = b_ptr->link_req;
> +	b_ptr->link_req = NULL;
>  	spin_unlock_bh(&b_ptr->lock);
> +
> +	if (temp_req)
> +		tipc_disc_delete(temp_req);
> +
>  	memset(b_ptr, 0, sizeof(struct tipc_bearer));
>  }
>  
> 
