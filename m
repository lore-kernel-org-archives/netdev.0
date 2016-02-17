From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH net-next] hv_netvsc: Increase delay for RNDIS_STATUS_NETWORK_CHANGE
Date: Wed, 17 Feb 2016 13:53:14 +0100
Message-ID: <878u2jmrb9.fsf@vitty.brq.redhat.com>
References: <1454458556-10591-1-git-send-email-haiyangz@microsoft.com>
	<20160209.050438.1204672612521151525.davem@davemloft.net>
	<BN1PR0301MB07700DD7E77C7B71C650B37DCAD60@BN1PR0301MB0770.namprd03.prod.outlook.com>
	<20160216.152827.2202202588726087877.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: haiyangz@microsoft.com, netdev@vger.kernel.org, kys@microsoft.com,
	olaf@aepfle.de, linux-kernel@vger.kernel.org,
	driverdev-devel@linuxdriverproject.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160216.152827.2202202588726087877.davem@davemloft.net> (David
	Miller's message of "Tue, 16 Feb 2016 15:28:27 -0500 (EST)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: Haiyang Zhang <haiyangz@microsoft.com>
> Date: Tue, 9 Feb 2016 15:31:34 +0000
>
>> 1) I share your concern as well. Is there a universal way to immediately trigger 
>> DHCP renew of all current and future daemons with a single event from kernel? 
>> If not, can we put the delay (RNDIS_STATUS_NETWORK_CHANGE only) into a 
>> tunable variable of this driver?
>> 
>> 2) We used to have the call_usermodehelper "/etc/init.d/network restart" to 
>> trigger DHCP renew. In commit 27a70af3f4, Vitaly has replaced it with the current 
>> code that updates the link status with at least 2 seconds interval, so that the 
>> "link_watch infrastructure" can send notification out. link_watch infrastructure 
>> only sends one notification per second.
>
> If the daemon is waiting for the link state change properly, there should be
> no delay necessary at all.

The daemon won't get 2 state change notifications if they happen within
1 second, it will get the last state only so our link will transition
from 'UP' to 'UP'. Why is that? To signal link state change we call
netif_carrier_on()/netif_carrier_off() from the driver. These functions
do linkwatch_fire_event() which has the following code for non-urgent events:

        if (!test_and_set_bit(__LINK_STATE_LINKWATCH_PENDING, &dev->state)) {
		linkwatch_add_event(dev);
	} else if (!urgent)
		return;

	linkwatch_schedule_work(urgent);

So we'll add just one event (because of test_and_set_bit) for a pair of
consequent netif_carrier_off()/netif_carrier_on() calls.

linkwatch_schedule_work() does the following:
	unsigned long delay = linkwatch_nextevent - jiffies;

        ....

	/* If we wrap around we'll delay it by at most HZ. */
	if (delay > HZ)
		delay = 0;

so here is where mandatory ' > 1s' wait comes from.
        ....
        schedule_delayed_work(&linkwatch_work, delay);        

linkwatch_work is linkwatch_event() which calls __linkwatch_run_queue()
which does linkwatch_do_dev() for the list of events we have. But
linkwatch_do_dev() checks current carrier status (which in our case if
'UP' if we didn't wait for > 1s before doing /netif_carrier_on()).

Hyper-V driver is not the only one which has this delay. e1000 driver,
for example, has the following:

...
 * Need to wait a few seconds after link up to get diagnostic information from
 * the phy
 */
static void e1000_update_phy_info_task(struct work_struct *work)
...

which we schedule with
      schedule_delayed_work(&adapter->phy_info_task, 2 * HZ);

To my understanding this code serves the same purpose, so even if you're
super fast with unplugging and plugging back your cable you'll have 2
seconds between 'down' and 'up'. I don't think there is something wrong
with linkwatch, the '1s' protection against drivers going mad is fine so
'2s' workarounds in drivers seem legit.

-- 
  Vitaly
