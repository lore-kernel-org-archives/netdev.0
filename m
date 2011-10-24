From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next V4] net: introduce ethernet teaming device
Date: Mon, 24 Oct 2011 15:50:43 +0200
Message-ID: <20111024135042.GA8113@minipsycho.brq.redhat.com>
References: <1319444005-1281-1-git-send-email-jpirko@redhat.com>
 <20111024130918.GB24473@synalogic.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, bhutchings@solarflare.com,
	shemminger@vyatta.com, fubar@us.ibm.com, andy@greyhouse.net,
	tgraf@infradead.org, ebiederm@xmission.com, mirqus@gmail.com,
	kaber@trash.net, greearb@candelatech.com, jesse@nicira.com,
	fbl@redhat.com, jzupka@redhat.com,
	Dipankar Sarma <dipankar@in.ibm.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Benjamin Poirier <benjamin.poirier@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53253 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932704Ab1JXNvE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Oct 2011 09:51:04 -0400
Content-Disposition: inline
In-Reply-To: <20111024130918.GB24473@synalogic.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Oct 24, 2011 at 03:09:19PM CEST, benjamin.poirier@gmail.com wrote:
>On 11/10/24 10:13, Jiri Pirko wrote:
>> This patch introduces new network device called team. It supposes to be
>> very fast, simple, userspace-driven alternative to existing bonding
>> driver.
>> 
>> Userspace library called libteam with couple of demo apps is available
>> here:
>> https://github.com/jpirko/libteam
>> Note it's still in its dipers atm.
>> 
>> team<->libteam use generic netlink for communication. That and rtnl
>> suppose to be the only way to configure team device, no sysfs etc.
>> 
>> Python binding basis for libteam was recently introduced (some need
>> still need to be done on it though). Daemon providing arpmon/miimon
>> active-backup functionality will be introduced shortly.
>> All what's necessary is already implemented in kernel team driver.
>> 
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>> 
>> v3->v4:
>> 	- remove redundant synchronize_rcu from __team_change_mode()
>> 	- revert "set and clear of mode_ops happens per pointer, not per
>> 	  byte"
>> 	- extend comment of function __team_change_mode()
>> 
>> v2->v3:
>> 	- team_change_mtu() user rcu version of list traversal to unwind
>> 	- set and clear of mode_ops happens per pointer, not per byte
>> 	- port hashlist changed to be embedded into team structure
>> 	- error branch in team_port_enter() does cleanup now
>> 	- fixed rtln->rtnl
>> 
>> v1->v2:
>> 	- modes are made as modules. Makes team more modular and
>> 	  extendable.
>> 	- several commenters' nitpicks found on v1 were fixed
>> 	- several other bugs were fixed.
>> 	- note I ignored Eric's comment about roundrobin port selector
>> 	  as Eric's way may be easily implemented as another mode (mode
>> 	  "random") in future.
>> ---
>>  Documentation/networking/team.txt         |    2 +
>>  MAINTAINERS                               |    7 +
>>  drivers/net/Kconfig                       |    2 +
>>  drivers/net/Makefile                      |    1 +
>>  drivers/net/team/Kconfig                  |   38 +
>>  drivers/net/team/Makefile                 |    7 +
>>  drivers/net/team/team.c                   | 1573 +++++++++++++++++++++++++++++
>>  drivers/net/team/team_mode_activebackup.c |  152 +++
>>  drivers/net/team/team_mode_roundrobin.c   |  107 ++
>>  include/linux/Kbuild                      |    1 +
>>  include/linux/if.h                        |    1 +
>>  include/linux/if_team.h                   |  231 +++++
>>  include/linux/rculist.h                   |   14 +
>
>I think you're missing some CC's for the modifications to this file.
>I've taken the liberty of adding Dipankar and Paul to the discussion.
>
>>  13 files changed, 2136 insertions(+), 0 deletions(-)
>>  create mode 100644 Documentation/networking/team.txt
>>  create mode 100644 drivers/net/team/Kconfig
>>  create mode 100644 drivers/net/team/Makefile
>>  create mode 100644 drivers/net/team/team.c
>>  create mode 100644 drivers/net/team/team_mode_activebackup.c
>>  create mode 100644 drivers/net/team/team_mode_roundrobin.c
>>  create mode 100644 include/linux/if_team.h
>> 
>
>[...]
>
>> diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
>> new file mode 100644
>> index 0000000..acfef4c
>> --- /dev/null
>> +++ b/drivers/net/team/team.c
>> +
>[...]
>> +static int team_change_mtu(struct net_device *dev, int new_mtu)
>> +{
>> +	struct team *team = netdev_priv(dev);
>> +	struct team_port *port;
>> +	int err;
>> +
>> +	rcu_read_lock();
>> +	list_for_each_entry_rcu(port, &team->port_list, list) {
>> +		err = dev_set_mtu(port->dev, new_mtu);
>> +		if (err) {
>> +			netdev_err(dev, "Device %s failed to change mtu",
>> +				   port->dev->name);
>> +			goto unwind;
>> +		}
>> +	}
>> +	rcu_read_unlock();
>> +
>> +	dev->mtu = new_mtu;
>> +
>> +	return 0;
>> +
>> +unwind:
>> +	list_for_each_entry_continue_reverse_rcu(port, &team->port_list, list)
>> +		dev_set_mtu(port->dev, dev->mtu);
>> +
>> +	rcu_read_unlock();
>> +	return err;
>> +}
>> +
>> +
>
>[...]
>
>> diff --git a/include/linux/rculist.h b/include/linux/rculist.h
>> index d079290..7586b2c 100644
>> --- a/include/linux/rculist.h
>> +++ b/include/linux/rculist.h
>> @@ -288,6 +288,20 @@ static inline void list_splice_init_rcu(struct list_head *list,
>>  	     pos = list_entry_rcu(pos->member.next, typeof(*pos), member))
>>  
>>  /**
>> + * list_for_each_entry_continue_reverse_rcu - iterate backwards from the given point
>> + * @pos:	the type * to use as a loop cursor.
>> + * @head:	the head for your list.
>> + * @member:	the name of the list_struct within the struct.
>> + *
>> + * Start to iterate over list of given type backwards, continuing after
>> + * the current position.
>> + */
>> +#define list_for_each_entry_continue_reverse_rcu(pos, head, member)	\
>> +	for (pos = list_entry_rcu(pos->member.prev, typeof(*pos), member); \
>> +	     &pos->member != (head);	\
>> +	     pos = list_entry_rcu(pos->member.prev, typeof(*pos), member))
>> +
>
>rcu lists can be modified while they are traversed with *_rcu()
>primitives. This benefit comes with the constraint that they may only be
>traversed forwards. This is implicit in the choice of *_rcu()
>list-traversal primitives: they only go forwards.
>
>You suggest to add a backwards rcu list-traversal primitive. But
>consider what happens in this sequence:
>
>CPU0					CPU1
>list_for_each_entry_continue_reverse_rcu(...)
>pos = list_entry_rcu(pos->member.prev, typeof(*pos), member)
>					list_del_rcu(&pos->member)
>					{ (&pos->member)->prev = LIST_POISON2 }
>pos = list_entry_rcu(pos->member.prev, typeof(*pos), member)
>    = container_of(LIST_POISON2, typeof(*pos), member)
>do_something(*pos)
>    BAM!

Doh, you are right. :(

>
>Going back to the problem you're trying to solve in team_change_mtu(),
>I think you could either:
>1) take team->lock instead of rcu_read_lock() throughout this particular
>function
>2) save each deleted element in a separate list on the side in case it's
>necessary to roll back

I would go with this one.

>3) remove the rcu double locking, rely on rtnl and add some
>ASSERT_RTNL() if desired. You've said that you don't want to rely on
>rtnl and you want to use separate locking but I fail to see what
>advantage that brings to balance out the extra complexity in code and
>execution? Please clarify this.

I do not want to use rtnl. For example in gennetlink code rtnl is not
held so I need to depend on own lock.


>
>Thanks,
>-Ben
>
>> +/**
>>   * hlist_del_rcu - deletes entry from hash list without re-initialization
>>   * @n: the element to delete from the hash list.
>>   *
>> -- 
>> 1.7.6
>> 
