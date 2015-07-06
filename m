From: GMAIL <ranamazharp@gmail.com>
Subject: Re: [PATCH v2] bonding: "primary_reselect" with "failure" is not
 working properly
Date: Mon, 06 Jul 2015 17:34:01 +0530
Message-ID: <559A6EB1.6080000@gmail.com>
References: <1435838839-21233-1-git-send-email-ranamazharp@gmail.com> <24978.1435869761@famine> <55965B97.80109@gmail.com> <4080.1435947370@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vfalico@gmail.com,
	gospo@cumulusnetworks.com, davem@davemloft.net,
	sanket.shah@cyberoam.com, mazhar.rana@cyberoam.com,
	linux-kernel@vger.kernel.org
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4080.1435947370@famine>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 03 July 2015 11:46 PM, Jay Vosburgh wrote:
> GMAIL <ranamazharp@gmail.com> wrote:
>
>> Hi Jay,
>>
>> On Friday 03 July 2015 02:12 AM, Jay Vosburgh wrote:
>>
>>> 	[ added netdev to cc ]
>>>
>>> Mazhar Rana <ranamazharp@gmail.com> wrote:
>>>
>>>> When "primary_reselect" is set to "failure", primary interface should
>>>> not become active until current active slave is up. But if we set first
>>> 	I think you mean "until current active slave is down" here, not
>>> "up."
>> Yes, It should be "up", grammatical mistake
> 	"down," right?

Yes, "Down".

>
> [...]
>> Below is the updated version of your patch. Any Comments or suggestions ?
> [...]
>> static struct slave *bond_find_best_slave(struct bonding *bond)
>> {
>> -	struct slave *slave, *bestslave = NULL, *primary;
>> +	struct slave *slave = NULL, *bestslave = NULL, *primary;
>> 	struct list_head *iter;
>> 	int mintime = bond->params.updelay;
>> 	primary = rtnl_dereference(bond->primary_slave);
>> -	if (primary && primary->link == BOND_LINK_UP &&
>> -	    bond_should_change_active(bond))
>> -		return primary;
>> +	if (primary && primary->link == BOND_LINK_UP)
>> +		slave = bond_choose_primary_or_current(bond);
>> +
>> +	if (slave)
>> +		return slave;
>> 	bond_for_each_slave(bond, slave, iter) {
>> 		if (slave->link == BOND_LINK_UP)
> 	I think this will misbehave in the case that curr is up and
> available, but primary is NULL (this can happen when the primary option
> is cleared).  In this case, the above code will not call
> bond_choose_primary_or_current, and will then run the loop to find a new
> curr, which may select a different slave unnecessarily.
>
> 	How does the following look?  I prefer to make the call to
> choose_primary_or_current unconditional, and have it decide if the
> search loop should be run.  In this version, _choose_ tests curr if prim
> is not suitable.  Compile tested only.
>
> 	Thoughts?
>
> 	-J
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 19eb990..1e35e25 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -689,40 +689,57 @@ out:
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
> +	if (!prim || !prim->link == BOND_LINK_UP) {
> +		if (!curr || !curr->link == BOND_LINK_UP)
> +			return NULL;
> +		return curr;
> +	}
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
> +	if (slave)
> +		return slave;
>   
>   	bond_for_each_slave(bond, slave, iter) {
>   		if (slave->link == BOND_LINK_UP)
>
> ---
> 	-Jay Vosburgh, jay.vosburgh@canonical.com

Looks good, added cosmetic changes for more readability,
it might save some instructions :)


diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 19eb990..317a494 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -689,40 +689,57 @@ out:
  
  }
  
-static bool bond_should_change_active(struct bonding *bond)
+static struct slave *bond_choose_primary_or_current(struct bonding *bond)
  {
         struct slave *prim = rtnl_dereference(bond->primary_slave);
         struct slave *curr = rtnl_dereference(bond->curr_active_slave);
  
-       if (!prim || !curr || curr->link != BOND_LINK_UP)
-               return true;
+       if (!prim || prim->link != BOND_LINK_UP) {
+               if (!curr || curr->link != BOND_LINK_UP)
+                       return NULL;
+               return curr;
+       }
+
         if (bond->force_primary) {
                 bond->force_primary = false;
-               return true;
+               return prim;
+       }
+
+       if (!curr || curr->link != BOND_LINK_UP)
+               return prim;
+
+       /* At this point, prim and curr are both up */
+       switch (bond->params.primary_reselect) {
+       case BOND_PRI_RESELECT_ALWAYS:
+               return prim;
+       case BOND_PRI_RESELECT_BETTER:
+               if (prim->speed < curr->speed)
+                       return curr;
+               if (prim->speed == curr->speed && prim->duplex <= curr->duplex)
+                       return curr;
+               return prim;
+       case BOND_PRI_RESELECT_FAILURE:
+               return curr;
+       default:
+               netdev_err(bond->dev, "impossible primary_reselect %d\n",
+                          bond->params.primary_reselect);
+               return curr;
         }
-       if (bond->params.primary_reselect == BOND_PRI_RESELECT_BETTER &&
-           (prim->speed < curr->speed ||
-            (prim->speed == curr->speed && prim->duplex <= curr->duplex)))
-               return false;
-       if (bond->params.primary_reselect == BOND_PRI_RESELECT_FAILURE)
-               return false;
-       return true;
  }

  /**
- * find_best_interface - select the best available slave to be the active one
+ * bond_find_best_slave - select the best available slave to be the active one
   * @bond: our bonding struct
   */
  static struct slave *bond_find_best_slave(struct bonding *bond)
  {
-       struct slave *slave, *bestslave = NULL, *primary;
+       struct slave *slave, *bestslave = NULL;
         struct list_head *iter;
         int mintime = bond->params.updelay;

-       primary = rtnl_dereference(bond->primary_slave);
-       if (primary && primary->link == BOND_LINK_UP &&
-           bond_should_change_active(bond))
-               return primary;
+       slave = bond_choose_primary_or_current(bond);
+       if (slave)
+               return slave;

         bond_for_each_slave(bond, slave, iter) {
                 if (slave->link == BOND_LINK_UP)
---

Regards,
Mazhar Rana
