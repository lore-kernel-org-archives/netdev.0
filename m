From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bonding: "primary_reselect" with "failure" is not
 working properly
Date: Thu, 02 Jul 2015 13:35:40 +0200
Message-ID: <1435836940.11970.18.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1435832026-19918-1-git-send-email-ranamazharp@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
	gospo@cumulusnetworks.com, davem@davemloft.net,
	sanket.shah@cyberoam.com, mazhar.rana@cyberoam.com,
	linux-kernel@vger.kernel.org
To: Mazhar Rana <ranamazharp@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:38110 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752899AbbGBLfo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2015 07:35:44 -0400
In-Reply-To: <1435832026-19918-1-git-send-email-ranamazharp@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-07-02 at 15:43 +0530, Mazhar Rana wrote:
> When "primary_reselect" is set to "failure", primary interface should
> not become active until current active slave is up. But if we set first
> member of bond device as a "primary" interface and "primary_reselect"
> is set to "failure" then whenever primary interface's link get back(up)
> it become active slave even if current active slave is still up.
> 
> With this patch, "bond_find_best_slave" will not traverse members if
> primary interface is not candidate for failover/reselection and current
> active slave is still up.
> 
> Signed-off-by: Mazhar Rana <mazhar.rana@cyberoam.com>
> Reviewed-by: Sanket Shah <sanket.shah@cyberoam.com>
> ---
>  drivers/net/bonding/bond_main.c | 10 +++++++++-
>  1 file changed, 9 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 19eb990..ac71261 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -715,7 +715,7 @@ static bool bond_should_change_active(struct bonding *bond)
>   */
>  static struct slave *bond_find_best_slave(struct bonding *bond)
>  {
> -	struct slave *slave, *bestslave = NULL, *primary;
> +	struct slave *slave, *bestslave = NULL, *primary, *curr;
>  	struct list_head *iter;
>  	int mintime = bond->params.updelay;
>  
> @@ -724,6 +724,14 @@ static struct slave *bond_find_best_slave(struct bonding *bond)
>  	    bond_should_change_active(bond))
>  		return primary;
>  
> +	/* We are here means primary interface is not candidate for
> +	 * reslection/failover. If currenet active slave is still up
> +	 * then there is no meaning to traverse  members.
> +	 */
> +	curr = rtnl_dereference(bond->curr_active_slave);

Here you carefully use rtnl_dereference(bond->curr_active_slave)

(This is good)

> +	if (curr && curr->link == BOND_LINK_UP)
> +		return bond->curr_active_slave;

But here you return bond->curr_active_slave 
instead of curr

> +
>  	bond_for_each_slave(bond, slave, iter) {
>  		if (slave->link == BOND_LINK_UP)
>  			return slave;
