From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH v2 net-next 6/6] bonding: add an option to fail when any
 of arp_ip_target is inaccessible
Date: Fri, 21 Jun 2013 14:24:09 +0200
Message-ID: <20130621122409.GG1157@redhat.com>
References: <1371746105-2482-7-git-send-email-vfalico@redhat.com>
 <20130621102318.GA7269@unicorn.suse.cz>
 <20130621110031.GF1157@redhat.com>
 <20130621120319.GB7269@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	davem@davemloft.net, linux@8192.net, nicolas.2p.debian@free.fr,
	rick.jones2@hp.com, nikolay@redhat.com
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11151 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161222Ab3FUMYu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jun 2013 08:24:50 -0400
Content-Disposition: inline
In-Reply-To: <20130621120319.GB7269@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 21, 2013 at 02:03:20PM +0200, Michal Kubecek wrote:
>On Fri, Jun 21, 2013 at 01:00:31PM +0200, Veaceslav Falico wrote:
>> On Fri, Jun 21, 2013 at 12:23:18PM +0200, Michal Kubecek wrote:
>> >On Thu, Jun 20, 2013 at 06:35:05PM +0200, Veaceslav Falico wrote:
>> >>@@ -1712,6 +1721,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>> >>
>> >> 	new_slave->last_arp_rx = jiffies -
>> >> 		(msecs_to_jiffies(bond->params.arp_interval) + 1);
>> >>+	for (i = 0; i < BOND_MAX_ARP_TARGETS; i++)
>> >>+		new_slave->target_last_arp_rx[i] = jiffies;
>> >>
>> >> 	if (bond->params.miimon && !bond->params.use_carrier) {
>> >> 		link_reporting = bond_check_dev_link(bond, slave_dev, 1);
>> >
>> >For cards with slow initial negotiation, this can cause a down -> up ->
>> >down -> up flap on enslaving. This is why initial walue of last_arp_rx
>> >was modified in commit f31c7937. Is there a reason not to initialize
>> >target_last_arp_rx[i] to the same value?
>>
>> Yep, I've seen this commit, however I didn't really understand it.
>>
>> My logic is:
>>
>> 1) on enslaving, we suppose that the new slave is up and give it a chance
>> to prove it.
>> 	1.1) if there is no active slave, lets try the new one, anyway
>> 	     we're down.
>> 	1.2) if there is one - nothing changes
>>
>> 2) if, as you've said, it's still initializing - then it basically will just
>> be marked as down until it finishes the initialization, and after that will
>> go up. So, it goes up -> down (while initializing) -> up (when arps are
>> received).
>>
>> So, by using jiffies, we can start using the slave immediately, without
>> waiting to receive the confirmation - if we don't have an active one,
>> obviously. If we have one - nothing changes.
>>
>> Did I miss something?
>
>Experiments I've done show that most cards fall into one of two groups:
>
>1. device is ready after dev_open() and netif_carrier_ok() reflects it
>2. device is not ready for some time after dev_open()
>
>For some cards from group 2, especially modern gigabit cards, this delay
>can be surprisingly long, e.g. for some igb based cards it can take more
>than two seconds until the card is ready and working. The original logic
>(always start in up state) then caused ARP monitor to detect a failure
>which was recorded and shown in statistics. I was not a functional
>problem but it confused some customers and their monitoring tools.

Yep, didn't think of these consequences, seems fair.

>
>Therefore commit f31c7937 changed logic to start a new slave in down
>state if bond uses ARP monitoring and netif_carrier_ok() returns false.
>This allows slaves from group 1 to start as up and stay that way and
>slaves from group 2 to start as down and do only one down -> up
>transition once the card is really ready; to be more precise: with a bit
>of delay but exactly at the same time the slave would be finally up
>without the patch.

Ok, finally got it, thank you!

>
>This also required setting last_arp_rx not to "now" but to "more that
>arp_interval ago", otherwise with arp_interval short enough (with
>respect to the initialization delay), ARP monitor would falsely detect
>up state on first opportunity, switch the slave to up, then after
>arp_interval back to down once more and later finally to up. And unless
>I overlooked something, if you set target_last_arp_rx[i] to jiffies,
>this is exactly what happens with the "all" setting.

Great catch, thank you, will modify in the next version.

>
>                                                        Michal Kubecek
>
