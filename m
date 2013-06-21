From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH v2 net-next 6/6] bonding: add an option to fail when any
 of arp_ip_target is inaccessible
Date: Fri, 21 Jun 2013 13:00:31 +0200
Message-ID: <20130621110031.GF1157@redhat.com>
References: <1371746105-2482-7-git-send-email-vfalico@redhat.com>
 <20130621102318.GA7269@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	davem@davemloft.net, linux@8192.net, nicolas.2p.debian@free.fr,
	rick.jones2@hp.com, nikolay@redhat.com
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64399 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753278Ab3FULBn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jun 2013 07:01:43 -0400
Content-Disposition: inline
In-Reply-To: <20130621102318.GA7269@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 21, 2013 at 12:23:18PM +0200, Michal Kubecek wrote:
>On Thu, Jun 20, 2013 at 06:35:05PM +0200, Veaceslav Falico wrote:
>> @@ -1712,6 +1721,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>>
>>  	new_slave->last_arp_rx = jiffies -
>>  		(msecs_to_jiffies(bond->params.arp_interval) + 1);
>> +	for (i = 0; i < BOND_MAX_ARP_TARGETS; i++)
>> +		new_slave->target_last_arp_rx[i] = jiffies;
>>
>>  	if (bond->params.miimon && !bond->params.use_carrier) {
>>  		link_reporting = bond_check_dev_link(bond, slave_dev, 1);
>
>For cards with slow initial negotiation, this can cause a down -> up ->
>down -> up flap on enslaving. This is why initial walue of last_arp_rx
>was modified in commit f31c7937. Is there a reason not to initialize
>target_last_arp_rx[i] to the same value?

Yep, I've seen this commit, however I didn't really understand it.

My logic is:

1) on enslaving, we suppose that the new slave is up and give it a chance
to prove it.
	1.1) if there is no active slave, lets try the new one, anyway
	     we're down.
	1.2) if there is one - nothing changes

2) if, as you've said, it's still initializing - then it basically will just
be marked as down until it finishes the initialization, and after that will
go up. So, it goes up -> down (while initializing) -> up (when arps are
received).

So, by using jiffies, we can start using the slave immediately, without
waiting to receive the confirmation - if we don't have an active one,
obviously. If we have one - nothing changes.

Did I miss something?

Thank you!

>
>                                                        Michal Kubecek
>
