From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next 5/6] bonding: don't swap arp's ips on validation for backup slave
Date: Wed, 19 Jun 2013 13:19:32 -0700
Message-ID: <28823.1371673172@death.nxdomain>
References: <1371663286-12518-6-git-send-email-vfalico@redhat.com> <27953.1371664886@death.nxdomain> <20130619192819.GB22345@redhat.com>
Cc: netdev@vger.kernel.org, andy@greyhouse.net, davem@davemloft.net,
	linux@8192.net, nicolas.2p.debian@free.fr, rick.jones2@hp.com
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:49473 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934714Ab3FSUUj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jun 2013 16:20:39 -0400
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Wed, 19 Jun 2013 16:20:38 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 78291C9004A
	for <netdev@vger.kernel.org>; Wed, 19 Jun 2013 16:20:34 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5JKJZKB291222
	for <netdev@vger.kernel.org>; Wed, 19 Jun 2013 16:19:35 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5JKJX8e002431
	for <netdev@vger.kernel.org>; Wed, 19 Jun 2013 16:19:34 -0400
In-reply-to: <20130619192819.GB22345@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Veaceslav Falico <vfalico@redhat.com> wrote:

>On Wed, Jun 19, 2013 at 11:01:26AM -0700, Jay Vosburgh wrote:
>>Veaceslav Falico <vfalico@redhat.com> wrote:
>>
>>>Currently, if we catch an arp on a backup slave, we swap the ips before
>>>checking it. It's done so because backup slaves usually don't receive arp
>>>replies and only receive arp requests from the active slave to
>>>arp_ip_targets, thus it's needed to swap the ips in order for the
>>>validation to succeed.
>>>
>>>This breaks the scenario when the backup slave actually receives arp
>>>replies from the target.
>>
>>	Under what circumstances does this (backup slave receiving the
>>unicast ARP reply) happen?
>
>When both (active and passive) slaves are connected to a hub, maybe? I
>agree that it's a really rare topology, though it wasn't the main point.
>
>>
>>	The whole reason the arp validate swaps the IPs is that the
>>backup slaves generally don't receive the unicast ARP reply, because the
>>switch does not deliver it to them.  The backup slaves only receive the
>>broadcast ARP request, hence the swapping, and the limitations on the
>>topology.
>
>I don't understand why it should, in the first place, treat broadcast arp
>requests from an active slave as a sign that that specific arp_ip_target is
>reachable. Sorry if I'm missing something.
>
>>
>>>It's useless when the active and the backup slaves are not in the same arp
>>>broadcast domain (i.e. when it doesn't receive those requests originating
>>>from the active slave).
>>
>>	Agreed, but the common case is that the active and backup slaves
>>are in the same broadcast domain.  What topology are you considering
>>here in which they are not?
>
>The easiest which I can think of - if it's direct-connected to another box,
>and this box is not forwarding arp requests. Or if it's direct-connected
>via two different switches (which actually exists in real world, I think
>:)) - i.e.:
>
>    server1						server2
>bond/slave1		<->	switch1		<->	slave1 \ bridge
>   \slave2		<->	switch2		<->	slave2 /
>
>Anyway, it's also rare and I wouldn't care if this and the top situation
>would be the only ones.
>
>>
>>>And it actually breaks the whole logic of arp_validate - it marks the
>>>backup slave UP even if it can't access the arp_ip_target and is in the
>>>same arp broadcast domain. This means that we can see an endless up/down
>>>loop if the arp_ip_target becomes inaccessible:
>>>
>>>2 slaves, 1 bond:
>>>1) active slave is up, backup slave is up because it receives arp requests
>>>   from the active slave.
>>>2) after delay, arp_ip_target check fails on active slave.
>>>3) failover to the backup slave occurs (which is up), active swaps with
>>>   backup
>>>4) goto 1
>>>
>>>So, don't swap the sip/tip for backup slaves, and verify them as an active
>>>slave. Also, update the documentation to reflect the changes (and remove
>>>some random spaces there).
>>
>>	How does this not break the case when the backup slave only
>>receives the broadcast ARP request, and does not receive the ARP reply?
>
>I don't get why it should break, and nor I can see it through tests. The
>backup slave remains slave->link == BOND_LINK_DOWN (but the device is
>actually up) until it can prove to be able to receive arp replies from at
>least one host in arp_ip_target. Then, if the active slave fails, we verify
>if the backup interface IS_UP(slave->dev) in bond_ab_arp_probe(), send arp
>probes from it via bond_arp_send_all() and activate it, so that if an arp
>reply is received we mark it as slave->link == BOND_LINK_UP.
>
>I'm really sorry, I've seen your comment about it in the code and your
>comments here, however I still don't see what is it supposed to
>fix/workaround.

	Ok, I think I see the disconnect here.  You're reading it as the
backup slave must receive traffic directly from an arp_ip_target in
order to be declared "up," and that's not how it works.  

	For the backup slaves, it's really a "best effort" arrangement,
and the documentation has always explained how it works (although, since
we're having this conversation, perhaps not in sufficient detail).  It
works this way because this is the best we can get for the backup slave
that's in the inactive state (not receiving unicast traffic, etc).

	Second, the main purpose of adding arp_validate was to eliminate
false "link up" detection for cases wherein multiple systems, each
running bonding with the ARP monitor, fool one another because each
system sees the other's ARP requests, even though no replies come from
the arp_ip_target (e.g., the two bonding systems are on a first switch,
and the arp_ip_target is on a second switch that has failed).  The false
"link up" occurs without arp_validate because, in that case, any ARP
traffic is good enough.

	Third, the "best effort" done now does provide some degree of
validation that the slave is functional.  Even if it is not actually
able to reach the arp_ip_target, in most cases receiving the active
slave's broadcast ARP is good enough to conclude that the slave is up
and working on the network.  If something in that path should fail, it
provides some notice that a problem exists, well before a failover takes
place.

	With this patch and arp_validate enabled, all backup slaves will
be down until a failover takes place, and only then would they be
checked.  In my opinion, this is not an improvement.

	I agree that the cyclic failover that can occur is undesirable,
but I don't think this is the appropriate manner to resolve that.

	-J

>>>Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
>>>---
>>> Documentation/networking/bonding.txt |   24 +++++++++---------------
>>> drivers/net/bonding/bond_main.c      |   13 +------------
>>> 2 files changed, 10 insertions(+), 27 deletions(-)
>>>
>>>diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
>>>index e7454fc..84f16c8 100644
>>>--- a/Documentation/networking/bonding.txt
>>>+++ b/Documentation/networking/bonding.txt
>>>@@ -23,7 +23,7 @@ multiple network interfaces into a single logical "bonded" interface.
>>> The behavior of the bonded interfaces depends upon the mode; generally
>>> speaking, modes provide either hot standby or load balancing services.
>>> Additionally, link integrity monitoring may be performed.
>>>-	
>>>+
>>> 	The bonding driver originally came from Donald Becker's
>>> beowulf patches for kernel 2.0. It has changed quite a bit since, and
>>> the original tools from extreme-linux and beowulf sites will not work
>>>@@ -293,15 +293,9 @@ arp_validate
>>>
>>> 		Validation is performed for all slaves.
>>>
>>>-	For the active slave, the validation checks ARP replies to
>>>-	confirm that they were generated by an arp_ip_target.  Since
>>>-	backup slaves do not typically receive these replies, the
>>>-	validation performed for backup slaves is on the ARP request
>>>-	sent out via the active slave.  It is possible that some
>>>-	switch or network configurations may result in situations
>>>-	wherein the backup slaves do not receive the ARP requests; in
>>>-	such a situation, validation of backup slaves must be
>>>-	disabled.
>>>+	For any eligible slave (active, backup or both) the validation
>>>+	checks ARP replies to confirm that they were generated by an
>>>+	arp_ip_target.
>>>
>>> 	This option is useful in network configurations in which
>>> 	multiple bonding hosts are concurrently issuing ARPs to one or
>>>@@ -2238,7 +2232,7 @@ when they are configured in parallel as part of an isolated network
>>> between two or more systems, for example:
>>>
>>>                        +-----------+
>>>-                       |  Host A   |
>>>+                       |  Host A   |
>>>                        +-+---+---+-+
>>>                          |   |   |
>>>                 +--------+   |   +---------+
>>>@@ -2250,7 +2244,7 @@ between two or more systems, for example:
>>>                 +--------+   |   +---------+
>>>                          |   |   |
>>>                        +-+---+---+-+
>>>-                       |  Host B   |
>>>+                       |  Host B   |
>>>                        +-----------+
>>>
>>> 	In this configuration, the switches are isolated from one
>>>@@ -2478,7 +2472,7 @@ bonding driver.
>>> (either the internal Ethernet Switch Module, or an external switch) to
>>> avoid fail-over delay issues when using bonding.
>>>
>>>-	
>>>+
>>> 15. Frequently Asked Questions
>>> ==============================
>>>
>>>@@ -2515,7 +2509,7 @@ monitored, and should it recover, it will rejoin the bond (in whatever
>>> manner is appropriate for the mode). See the sections on High
>>> Availability and the documentation for each mode for additional
>>> information.
>>>-	
>>>+
>>> 	Link monitoring can be enabled via either the miimon or
>>> arp_interval parameters (described in the module parameters section,
>>> above).  In general, miimon monitors the carrier state as sensed by
>>>@@ -2618,7 +2612,7 @@ be found at:
>>> http://vger.kernel.org/vger-lists.html#netdev
>>>
>>> Donald Becker's Ethernet Drivers and diag programs may be found at :
>>>- - http://web.archive.org/web/*/http://www.scyld.com/network/
>>>+ - http://web.archive.org/web/*/http://www.scyld.com/network/
>>>
>>> You will also find a lot of information regarding Ethernet, NWay, MII,
>>> etc. at www.scyld.com.
>>>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>>>index 2cfbb2e..3f64607 100644
>>>--- a/drivers/net/bonding/bond_main.c
>>>+++ b/drivers/net/bonding/bond_main.c
>>>@@ -2660,18 +2660,7 @@ static int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond,
>>> 		 bond->params.arp_validate, slave_do_arp_validate(bond, slave),
>>> 		 &sip, &tip);
>>>
>>>-	/*
>>>-	 * Backup slaves won't see the ARP reply, but do come through
>>>-	 * here for each ARP probe (so we swap the sip/tip to validate
>>>-	 * the probe).  In a "redundant switch, common router" type of
>>>-	 * configuration, the ARP probe will (hopefully) travel from
>>>-	 * the active, through one switch, the router, then the other
>>>-	 * switch before reaching the backup.
>>>-	 */
>>>-	if (bond_is_active_slave(slave))
>>>-		bond_validate_arp(bond, slave, sip, tip);
>>>-	else
>>>-		bond_validate_arp(bond, slave, tip, sip);
>>>+	bond_validate_arp(bond, slave, sip, tip);
>>>
>>> out_unlock:
>>> 	read_unlock(&bond->lock);
>>>--
>>>1.7.1
>>>
>>>--
>>
>>---
>>	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
>>
>
