From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next 5/6] bonding: don't swap arp's ips on validation
 for backup slave
Date: Wed, 19 Jun 2013 23:31:08 +0200
Message-ID: <20130619213108.GC22345@redhat.com>
References: <1371663286-12518-6-git-send-email-vfalico@redhat.com>
 <27953.1371664886@death.nxdomain>
 <20130619192819.GB22345@redhat.com>
 <28823.1371673172@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, andy@greyhouse.net, davem@davemloft.net,
	linux@8192.net, nicolas.2p.debian@free.fr, rick.jones2@hp.com
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2192 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934936Ab3FSVbf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jun 2013 17:31:35 -0400
Content-Disposition: inline
In-Reply-To: <28823.1371673172@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 19, 2013 at 01:19:32PM -0700, Jay Vosburgh wrote:
>Veaceslav Falico <vfalico@redhat.com> wrote:
>
>>On Wed, Jun 19, 2013 at 11:01:26AM -0700, Jay Vosburgh wrote:
>>>Veaceslav Falico <vfalico@redhat.com> wrote:
>>>
...snip...
>>>
>>>	How does this not break the case when the backup slave only
>>>receives the broadcast ARP request, and does not receive the ARP reply?
>>
>>I don't get why it should break, and nor I can see it through tests. The
>>backup slave remains slave->link == BOND_LINK_DOWN (but the device is
>>actually up) until it can prove to be able to receive arp replies from at
>>least one host in arp_ip_target. Then, if the active slave fails, we verify
>>if the backup interface IS_UP(slave->dev) in bond_ab_arp_probe(), send arp
>>probes from it via bond_arp_send_all() and activate it, so that if an arp
>>reply is received we mark it as slave->link == BOND_LINK_UP.
>>
>>I'm really sorry, I've seen your comment about it in the code and your
>>comments here, however I still don't see what is it supposed to
>>fix/workaround.
>
>	Ok, I think I see the disconnect here.  You're reading it as the
>backup slave must receive traffic directly from an arp_ip_target in
>order to be declared "up," and that's not how it works.
>
>	For the backup slaves, it's really a "best effort" arrangement,
>and the documentation has always explained how it works (although, since
>we're having this conversation, perhaps not in sufficient detail).  It
>works this way because this is the best we can get for the backup slave
>that's in the inactive state (not receiving unicast traffic, etc).
>
>	Second, the main purpose of adding arp_validate was to eliminate
>false "link up" detection for cases wherein multiple systems, each
>running bonding with the ARP monitor, fool one another because each
>system sees the other's ARP requests, even though no replies come from
>the arp_ip_target (e.g., the two bonding systems are on a first switch,
>and the arp_ip_target is on a second switch that has failed).  The false
>"link up" occurs without arp_validate because, in that case, any ARP
>traffic is good enough.
>
>	Third, the "best effort" done now does provide some degree of
>validation that the slave is functional.  Even if it is not actually
>able to reach the arp_ip_target, in most cases receiving the active
>slave's broadcast ARP is good enough to conclude that the slave is up
>and working on the network.  If something in that path should fail, it
>provides some notice that a problem exists, well before a failover takes
>place.

Ok, now I completely get it, thank you. I indeed thought that it was some
sort of a hack/workaround that was needed long ago, however actually it's
just an optimization, which indeed would work in the vast majority of
cases.

Thanks again for taking your time to explain this, I'll drop this patch in
v2 and, instead, update the documentation to reflect it in more detail, so
that even people like me would understand it :).

>
>	With this patch and arp_validate enabled, all backup slaves will
>be down until a failover takes place, and only then would they be
>checked.  In my opinion, this is not an improvement.

I agree, this optimization really works for most cases, and it helps a lot
to reduce downtime on failover.

>
>	I agree that the cyclic failover that can occur is undesirable,
>but I don't think this is the appropriate manner to resolve that.

The main problem for me was this cyclic failover, wrt the next patch, which
brings the slave up if and only if all of arp_ip_targets are available.
However, now I see that this optimization works perfectly even with that
patch - it will first bring up slaves that receive, through the same
broadcast domain, all arp requests.

The cyclic failover, though, is indeed an unpleasant thing, because it
keeps the bond up and cycles through slaves. I'll try to come up with a
solution for this in v2, though I don't promise...

Thanks again for your comments!

>
>	-J
>
>>>>Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
>>>>---
>>>> Documentation/networking/bonding.txt |   24 +++++++++---------------
>>>> drivers/net/bonding/bond_main.c      |   13 +------------
>>>> 2 files changed, 10 insertions(+), 27 deletions(-)
>>>>
>>>>diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
>>>>index e7454fc..84f16c8 100644
>>>>--- a/Documentation/networking/bonding.txt
>>>>+++ b/Documentation/networking/bonding.txt
>>>>@@ -23,7 +23,7 @@ multiple network interfaces into a single logical "bonded" interface.
>>>> The behavior of the bonded interfaces depends upon the mode; generally
>>>> speaking, modes provide either hot standby or load balancing services.
>>>> Additionally, link integrity monitoring may be performed.
>>>>-	
>>>>+
>>>> 	The bonding driver originally came from Donald Becker's
>>>> beowulf patches for kernel 2.0. It has changed quite a bit since, and
>>>> the original tools from extreme-linux and beowulf sites will not work
>>>>@@ -293,15 +293,9 @@ arp_validate
>>>>
>>>> 		Validation is performed for all slaves.
>>>>
>>>>-	For the active slave, the validation checks ARP replies to
>>>>-	confirm that they were generated by an arp_ip_target.  Since
>>>>-	backup slaves do not typically receive these replies, the
>>>>-	validation performed for backup slaves is on the ARP request
>>>>-	sent out via the active slave.  It is possible that some
>>>>-	switch or network configurations may result in situations
>>>>-	wherein the backup slaves do not receive the ARP requests; in
>>>>-	such a situation, validation of backup slaves must be
>>>>-	disabled.
>>>>+	For any eligible slave (active, backup or both) the validation
>>>>+	checks ARP replies to confirm that they were generated by an
>>>>+	arp_ip_target.
>>>>
>>>> 	This option is useful in network configurations in which
>>>> 	multiple bonding hosts are concurrently issuing ARPs to one or
>>>>@@ -2238,7 +2232,7 @@ when they are configured in parallel as part of an isolated network
>>>> between two or more systems, for example:
>>>>
>>>>                        +-----------+
>>>>-                       |  Host A   |
>>>>+                       |  Host A   |
>>>>                        +-+---+---+-+
>>>>                          |   |   |
>>>>                 +--------+   |   +---------+
>>>>@@ -2250,7 +2244,7 @@ between two or more systems, for example:
>>>>                 +--------+   |   +---------+
>>>>                          |   |   |
>>>>                        +-+---+---+-+
>>>>-                       |  Host B   |
>>>>+                       |  Host B   |
>>>>                        +-----------+
>>>>
>>>> 	In this configuration, the switches are isolated from one
>>>>@@ -2478,7 +2472,7 @@ bonding driver.
>>>> (either the internal Ethernet Switch Module, or an external switch) to
>>>> avoid fail-over delay issues when using bonding.
>>>>
>>>>-	
>>>>+
>>>> 15. Frequently Asked Questions
>>>> ==============================
>>>>
>>>>@@ -2515,7 +2509,7 @@ monitored, and should it recover, it will rejoin the bond (in whatever
>>>> manner is appropriate for the mode). See the sections on High
>>>> Availability and the documentation for each mode for additional
>>>> information.
>>>>-	
>>>>+
>>>> 	Link monitoring can be enabled via either the miimon or
>>>> arp_interval parameters (described in the module parameters section,
>>>> above).  In general, miimon monitors the carrier state as sensed by
>>>>@@ -2618,7 +2612,7 @@ be found at:
>>>> http://vger.kernel.org/vger-lists.html#netdev
>>>>
>>>> Donald Becker's Ethernet Drivers and diag programs may be found at :
>>>>- - http://web.archive.org/web/*/http://www.scyld.com/network/
>>>>+ - http://web.archive.org/web/*/http://www.scyld.com/network/
>>>>
>>>> You will also find a lot of information regarding Ethernet, NWay, MII,
>>>> etc. at www.scyld.com.
>>>>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>>>>index 2cfbb2e..3f64607 100644
>>>>--- a/drivers/net/bonding/bond_main.c
>>>>+++ b/drivers/net/bonding/bond_main.c
>>>>@@ -2660,18 +2660,7 @@ static int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond,
>>>> 		 bond->params.arp_validate, slave_do_arp_validate(bond, slave),
>>>> 		 &sip, &tip);
>>>>
>>>>-	/*
>>>>-	 * Backup slaves won't see the ARP reply, but do come through
>>>>-	 * here for each ARP probe (so we swap the sip/tip to validate
>>>>-	 * the probe).  In a "redundant switch, common router" type of
>>>>-	 * configuration, the ARP probe will (hopefully) travel from
>>>>-	 * the active, through one switch, the router, then the other
>>>>-	 * switch before reaching the backup.
>>>>-	 */
>>>>-	if (bond_is_active_slave(slave))
>>>>-		bond_validate_arp(bond, slave, sip, tip);
>>>>-	else
>>>>-		bond_validate_arp(bond, slave, tip, sip);
>>>>+	bond_validate_arp(bond, slave, sip, tip);
>>>>
>>>> out_unlock:
>>>> 	read_unlock(&bond->lock);
>>>>--
>>>>1.7.1
>>>>
>>>>--
>>>
>>>---
>>>	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
>>>
>>
>
