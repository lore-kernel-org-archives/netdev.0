From: GMAIL <ranamazharp@gmail.com>
Subject: Re: [PATCH v2] bonding: "primary_reselect" with "failure" is not
 working properly
Date: Tue, 07 Jul 2015 14:37:08 +0530
Message-ID: <559B96BC.1010309@gmail.com>
References: <1435838839-21233-1-git-send-email-ranamazharp@gmail.com> <24978.1435869761@famine> <55965B97.80109@gmail.com> <4080.1435947370@famine> <559A6EB1.6080000@gmail.com> <20150706153221.GA588@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <jay.vosburgh@canonical.com>, netdev@vger.kernel.org,
	vfalico@gmail.com, davem@davemloft.net, sanket.shah@cyberoam.com,
	mazhar.rana@cyberoam.com, linux-kernel@vger.kernel.org
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150706153221.GA588@gospo.home.greyhouse.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 06 July 2015 09:02 PM, Andy Gospodarek wrote:

> On Mon, Jul 06, 2015 at 05:34:01PM +0530, GMAIL wrote:
>> On Friday 03 July 2015 11:46 PM, Jay Vosburgh wrote:
>>> GMAIL<ranamazharp@gmail.com>  wrote:
> [...]
>> Looks good, added cosmetic changes for more readability,
>> it might save some instructions :)
>>
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index 19eb990..317a494 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -689,40 +689,57 @@ out:
>>   }
>> -static bool bond_should_change_active(struct bonding *bond)
>> +static struct slave *bond_choose_primary_or_current(struct bonding *bond)
>>   {
>>          struct slave *prim = rtnl_dereference(bond->primary_slave);
>>          struct slave *curr = rtnl_dereference(bond->curr_active_slave);
> Probably a good idea to add back a blank line here.
>
> Otherwise this logic appears to be proper to resolve your issue and
> Jay's additions appear to handle the case where primary_slave is NULL.

It was there, I don't know, may be mail client issue.

>> -       if (!prim || !curr || curr->link != BOND_LINK_UP)
>> -               return true;
>> +       if (!prim || prim->link != BOND_LINK_UP) {
>> +               if (!curr || curr->link != BOND_LINK_UP)
>> +                       return NULL;
>> +               return curr;
>> +       }
>> +
>>          if (bond->force_primary) {
>>                  bond->force_primary = false;
>> -               return true;
>> +               return prim;
>> +       }
>> +
>> +       if (!curr || curr->link != BOND_LINK_UP)
>> +               return prim;
>> +
>> +       /* At this point, prim and curr are both up */
>> +       switch (bond->params.primary_reselect) {
>> +       case BOND_PRI_RESELECT_ALWAYS:
>> +               return prim;
>> +       case BOND_PRI_RESELECT_BETTER:
>> +               if (prim->speed < curr->speed)
>> +                       return curr;
>> +               if (prim->speed == curr->speed && prim->duplex <= curr->duplex)
>> +                       return curr;
>> +               return prim;
>> +       case BOND_PRI_RESELECT_FAILURE:
>> +               return curr;
>> +       default:
>> +               netdev_err(bond->dev, "impossible primary_reselect %d\n",
>> +                          bond->params.primary_reselect);
>> +               return curr;
>>          }
>> -       if (bond->params.primary_reselect == BOND_PRI_RESELECT_BETTER &&
>> -           (prim->speed < curr->speed ||
>> -            (prim->speed == curr->speed && prim->duplex <= curr->duplex)))
>> -               return false;
>> -       if (bond->params.primary_reselect == BOND_PRI_RESELECT_FAILURE)
>> -               return false;
>> -       return true;
>>   }
>>
>>   /**
>> - * find_best_interface - select the best available slave to be the active one
>> + * bond_find_best_slave - select the best available slave to be the active one
>>    * @bond: our bonding struct
>>    */
>>   static struct slave *bond_find_best_slave(struct bonding *bond)
>>   {
>> -       struct slave *slave, *bestslave = NULL, *primary;
>> +       struct slave *slave, *bestslave = NULL;
>>          struct list_head *iter;
>>          int mintime = bond->params.updelay;
>>
>> -       primary = rtnl_dereference(bond->primary_slave);
>> -       if (primary && primary->link == BOND_LINK_UP &&
>> -           bond_should_change_active(bond))
>> -               return primary;
>> +       slave = bond_choose_primary_or_current(bond);
>> +       if (slave)
>> +               return slave;
>>
>>          bond_for_each_slave(bond, slave, iter) {
>>                  if (slave->link == BOND_LINK_UP)
>> ---
>>
>> Regards,
>> Mazhar Rana
>>
Sending updated version of patch(v3) separately which will accommodate
my and Jay's changes.

Regards,
Mazhar Rana
