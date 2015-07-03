From: GMAIL <ranamazharp@gmail.com>
Subject: Re: [PATCH v2] bonding: "primary_reselect" with "failure" is not
 working properly
Date: Fri, 03 Jul 2015 15:23:27 +0530
Message-ID: <55965B97.80109@gmail.com>
References: <1435838839-21233-1-git-send-email-ranamazharp@gmail.com> <24978.1435869761@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vfalico@gmail.com,
	gospo@cumulusnetworks.com, davem@davemloft.net,
	sanket.shah@cyberoam.com, mazhar.rana@cyberoam.com,
	linux-kernel@vger.kernel.org
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <24978.1435869761@famine>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jay,

On Friday 03 July 2015 02:12 AM, Jay Vosburgh wrote:

> 	[ added netdev to cc ]
>
> Mazhar Rana <ranamazharp@gmail.com> wrote:
>
>> When "primary_reselect" is set to "failure", primary interface should
>> not become active until current active slave is up. But if we set first
> 	I think you mean "until current active slave is down" here, not
> "up."

Yes, It should be "up", grammatical mistake

>
>> member of bond device as a "primary" interface and "primary_reselect"
>> is set to "failure" then whenever primary interface's link get back(up)
>> it become active slave even if current active slave is still up.
>>
>> With this patch, "bond_find_best_slave" will not traverse members if
>> primary interface is not candidate for failover/reselection and current
>> active slave is still up.
>>
>> Signed-off-by: Mazhar Rana <mazhar.rana@cyberoam.com>
>> Reviewed-by: Sanket Shah <sanket.shah@cyberoam.com>
>> ---
>> v2: return "curr" instead of "bond->curr_active_slave".
>>
>> drivers/net/bonding/bond_main.c | 10 +++++++++-
>> 1 file changed, 9 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index 19eb990..ac71261 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -715,7 +715,7 @@ static bool bond_should_change_active(struct bonding *bond)
>>   */
>> static struct slave *bond_find_best_slave(struct bonding *bond)
>> {
>> -	struct slave *slave, *bestslave = NULL, *primary;
>> +	struct slave *slave, *bestslave = NULL, *primary, *curr;
>> 	struct list_head *iter;
>> 	int mintime = bond->params.updelay;
>>
>> @@ -724,6 +724,14 @@ static struct slave *bond_find_best_slave(struct bonding *bond)
>> 	    bond_should_change_active(bond))
>> 		return primary;
>>
>> +	/* We are here means primary interface is not candidate for
>> +	 * reslection/failover. If currenet active slave is still up
>> +	 * then there is no meaning to traverse  members.
>> +	 */
>> +	curr = rtnl_dereference(bond->curr_active_slave);
>> +	if (curr && curr->link == BOND_LINK_UP)
>> +		return curr;
>> +
>> 	bond_for_each_slave(bond, slave, iter) {
>> 		if (slave->link == BOND_LINK_UP)
>> 			return slave;
>> -- 
> 	I believe the above patch will work, but I also think these
> functions are kind of hacky, as bond_should_change_active() doesn't
> really give the answer its name implies, so we have to second guess
> here.
>
> 	I think the following, while a bigger change, ends up with
> clearer code.  Compile tested only.  Comments?
>
> 	-J
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 19eb990..8c30f6b 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -689,40 +689,54 @@ out:
>   
>   }
>   
> -static bool bond_should_change_active(struct bonding *bond)
> +static struct slave *bond_choose_primary_or_current(struct bonding *bond)
>   {
>   	struct slave *prim = rtnl_dereference(bond->primary_slave);
>   	struct slave *curr = rtnl_dereference(bond->curr_active_slave);
>   
> -	if (!prim || !curr || curr->link != BOND_LINK_UP)
> -		return true;
> +	if (!prim || !prim->link == BOND_LINK_UP)
> +		return curr;

This will not work when prim and curr both are pointing to same
interface, e.g. bond0={eth0, eth1, eth2}, prim=eth0, curr=eth0, now if
prim goes down then it will return curr which is again pointing to
primary interface, so failover never happen.

> +
>   	if (bond->force_primary) {
>   		bond->force_primary = false;
> -		return true;
> +		return prim;
> +	}
> +
> +	if (!curr || curr->link != BOND_LINK_UP)
> +		return prim;
> +
> +	/* At this point, prim and curr are both up */
> +	switch (bond->params.primary_reselect) {
> +	case BOND_PRI_RESELECT_ALWAYS:
> +		return prim;
> +	case BOND_PRI_RESELECT_BETTER:
> +		if (prim->speed < curr->speed)
> +			return curr;
> +		if (prim->speed == curr->speed && prim->duplex <= curr->duplex)
> +			return curr;
> +		return prim;
> +	case BOND_PRI_RESELECT_FAILURE:
> +		return curr;
> +	default:
> +		netdev_err(bond->dev, "impossible primary_reselect %d\n",
> +			   bond->params.primary_reselect);
> +		return curr;
>   	}
> -	if (bond->params.primary_reselect == BOND_PRI_RESELECT_BETTER &&
> -	    (prim->speed < curr->speed ||
> -	     (prim->speed == curr->speed && prim->duplex <= curr->duplex)))
> -		return false;
> -	if (bond->params.primary_reselect == BOND_PRI_RESELECT_FAILURE)
> -		return false;
> -	return true;
>   }
>   
>   /**
> - * find_best_interface - select the best available slave to be the active one
> + * bond_find_best_slave - select the best available slave to be the active one
>    * @bond: our bonding struct
>    */
>   static struct slave *bond_find_best_slave(struct bonding *bond)
>   {
> -	struct slave *slave, *bestslave = NULL, *primary;
> +	struct slave *slave, *bestslave = NULL;
>   	struct list_head *iter;
>   	int mintime = bond->params.updelay;
>   
> -	primary = rtnl_dereference(bond->primary_slave);
> -	if (primary && primary->link == BOND_LINK_UP &&
> -	    bond_should_change_active(bond))
> -		return primary;
> +	slave = bond_choose_primary_or_current(bond);

primary_reselect policy only make sense when 'primary' interface is
specified. And we should go for reselection only when primary link is
up. So this function call should be conditional.
If we make this call conditional and remove first condition/check from
"bond_choose_primary_or_current" then it will work fine.

> +	if (slave)
> +		return slave;
>   
>   	bond_for_each_slave(bond, slave, iter) {
>   		if (slave->link == BOND_LINK_UP)
>
> ---
> 	-Jay Vosburgh, jay.vosburgh@canonical.com

Below is the updated version of your patch. Any Comments or suggestions ?


diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 19eb990..3520a1b 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -689,40 +689,54 @@ out:
  
  }
  
-static bool bond_should_change_active(struct bonding *bond)
+static struct slave *bond_choose_primary_or_current(struct bonding *bond)
  {
  	struct slave *prim = rtnl_dereference(bond->primary_slave);
  	struct slave *curr = rtnl_dereference(bond->curr_active_slave);
  
-	if (!prim || !curr || curr->link != BOND_LINK_UP)
-		return true;
  	if (bond->force_primary) {
  		bond->force_primary = false;
-		return true;
+		return prim;
+	}
+
+	if (!curr || curr->link != BOND_LINK_UP)
+		return prim;
+
+	/* At this point, prim and curr are both up */
+	switch (bond->params.primary_reselect) {
+	case BOND_PRI_RESELECT_ALWAYS:
+		return prim;
+	case BOND_PRI_RESELECT_BETTER:
+		if (prim->speed < curr->speed)
+			return curr;
+		if (prim->speed == curr->speed && prim->duplex <= curr->duplex)
+			return curr;
+		return prim;
+	case BOND_PRI_RESELECT_FAILURE:
+		return curr;
+	default:
+		netdev_err(bond->dev, "impossible primary_reselect %d\n",
+			   bond->params.primary_reselect);
+		return curr;
  	}
-	if (bond->params.primary_reselect == BOND_PRI_RESELECT_BETTER &&
-	    (prim->speed < curr->speed ||
-	     (prim->speed == curr->speed && prim->duplex <= curr->duplex)))
-		return false;
-	if (bond->params.primary_reselect == BOND_PRI_RESELECT_FAILURE)
-		return false;
-	return true;
  }
  
  /**
- * find_best_interface - select the best available slave to be the active one
+ * bond_find_best_slave - select the best available slave to be the active one
   * @bond: our bonding struct
   */
  static struct slave *bond_find_best_slave(struct bonding *bond)
  {
-	struct slave *slave, *bestslave = NULL, *primary;
+	struct slave *slave = NULL, *bestslave = NULL, *primary;
  	struct list_head *iter;
  	int mintime = bond->params.updelay;
  
  	primary = rtnl_dereference(bond->primary_slave);
-	if (primary && primary->link == BOND_LINK_UP &&
-	    bond_should_change_active(bond))
-		return primary;
+	if (primary && primary->link == BOND_LINK_UP)
+		slave = bond_choose_primary_or_current(bond);
+
+	if (slave)
+		return slave;
  
  	bond_for_each_slave(bond, slave, iter) {
  		if (slave->link == BOND_LINK_UP)

---

Regards,
Mazhar Rana
