From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH v2 net-next 06/12] bonding: document the new _arp options
 for arp_validate
Date: Mon, 17 Feb 2014 14:36:07 +0100
Message-ID: <20140217133607.GB13038@redhat.com>
References: <1389977940-17084-1-git-send-email-vfalico@redhat.com>
 <1389977940-17084-7-git-send-email-vfalico@redhat.com>
 <32051.1389991108@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23672 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752348AbaBQNgT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Feb 2014 08:36:19 -0500
Content-Disposition: inline
In-Reply-To: <32051.1389991108@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 17, 2014 at 12:38:28PM -0800, Jay Vosburgh wrote:
>Veaceslav Falico <vfalico@redhat.com> wrote:
>
>>CC: Jay Vosburgh <fubar@us.ibm.com>
>>CC: Andy Gospodarek <andy@greyhouse.net>
>>Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
>>---
>> Documentation/networking/bonding.txt | 34 ++++++++++++++++++++++++++++++----
>> 1 file changed, 30 insertions(+), 4 deletions(-)
>>
>>diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
>>index 3620690..a0c1bca2 100644
>>--- a/Documentation/networking/bonding.txt
>>+++ b/Documentation/networking/bonding.txt
>>@@ -279,19 +279,45 @@ arp_validate
>>
>> 	none or 0
>>
>>-		No validation is performed.  This is the default.
>>+		No validation is performed.  This is the default. Any arriving
>>+		traffic (arp or non-arp) is considered a proof that the slave
>>+		is up.
>>
>> 	active or 1
>>
>>-		Validation is performed only for the active slave.
>>+		Validation is performed only for the active slave. Only ARPs
>>+		that arrive from any arp_ip_target are considered legit. The
>>+		backup slave still does no validation (as if arp_validate=0).
>>
>> 	backup or 2
>>
>>-		Validation is performed only for backup slaves.
>>+		Validation is performed only for backup slaves. Only ARPs
>>+		that arrive from any arp_ip_target are considered legit. The
>>+		active slave still has no validation (as if arp_validate=0).
>>
>> 	all or 3
>>
>>-		Validation is performed for all slaves.
>>+		Validation is performed for all slaves. Only ARPs
>>+		that arrive from any arp_ip_target are considered legit.
>>+
>>+	arp or 4
>>+
>>+		Any arp packet is accepted as a proof that any slave is up,
>>+		but no IP-based validation is made.
>>+
>>+	active_arp or 5
>>+
>>+		Validation is performed only for the active slave. Only ARPs
>>+		that arrive from any arp_ip_target are considered legit. The
>>+		backup slave validates only arp packets, but doesn't check the
>>+		source (as if arp_validate=4).
>>+
>>+	backup_any or 6
>>+
>>+		Validation is performed only for backup slaves. Only ARPs
>>+		that arrive from any arp_ip_target are considered legit. The
>>+		active slave validates only arp packets, but doesn't check the
>>+		source (as if arp_validate=4).

Hi Jay,

Sorry for taking it so long - however I didn't manage to update/re-send the
patchset before the net-next closure, so sending it now. Few comments
below, though.

>
>	I think that, for the last three options, saying that
>"validation is performed" is not quite right, since the next paragraph
>goes on to explain what "validation" is (that the incoming ARP came from
>us or was a response to ours), and these options don't really validate
>in that sense, but merely filter anything that's not an ARP.

Yes and no. Indeed, validation is not performed if we use the "filter_all"
option (filter both slaves, don't do any validation). However it's
performed for both filter_active/backup - as in "Validate arp packets on
active/backup, and filter only on the other one".

However your text is really awesome in explaining what is
validating/filtering, so I've included it in the patch with minor
corrections, see below.

>
>	There'a a sentence with a similar problem further down: "Use of
>the arp_validate option can resolve this, as the ARP monitor will only
>consider ARP requests and replies associated with its own instance of
>bonding."  For the three new options, this sentence is not accurate.
>
>	I think I'd rework this whole block something like the following
>(this is a diff against your patched version).  I'm calling the two
>separate things "validation" and "filtering," since the wording you used
>kind of combined things into two styles of validation; I think it's
>clearer to make them discrete things.
>
>	This would also necessitate change the option tag names; I also
>put the "filter" ones into the same order as the "validate" ones
>(active, backup, then all).

I've left the original order, because the "filter" is, actually, bit 4, so
if we want to filter AND validate, we set FITLER | VALIDATE_{ACTIVE,BACKUP},
and this way we get 5 or 6. I've also changed the filter_all to just
"filter", to make it more clear what's happening. Here are the only lines
changed on top of your patch:

         filter or 4

                 Filtering is applied to all slaves. No validation is
                 performed.

         filter_active or 5

                 Filtering is applied to all slaves, validation is performed
                 only for the active slave.

         filter_backup or 6

                 Filtering is applied to all slaves, validation is performed
                 only for backup slaves.

This way we can set any pair of filtering/validation:

No validation + no filtering? none
Validation + no filtering? acitve/backup
No validation + filtering? filter
Validation + filtering? filter_active/backup

I'll send v3 in a few minutes, so that it'll be easier to review (it's also
rebased on top of latest net-next).

Thanks a lot, and sorry for the delay.

>
>	Comments?
>
>diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
>index a0c1bca2..5fd6a6a 100644
>--- a/Documentation/networking/bonding.txt
>+++ b/Documentation/networking/bonding.txt
>@@ -270,80 +270,87 @@ arp_ip_target
> arp_validate
>
> 	Specifies whether or not ARP probes and replies should be
>-	validated in any mode that supports arp monitoring.  This causes
>-	the ARP monitor to examine the incoming ARP requests and replies,
>-	and only consider a slave to be up if it is receiving the
>-	appropriate ARP traffic.
>-
>+	validated in any mode that supports arp monitoring, or whether
>+	non-ARP traffic should be filtered (disregarded) for link
>+	monitoring purposes.
>+	
> 	Possible values are:
>
> 	none or 0
>
>-		No validation is performed.  This is the default. Any arriving
>-		traffic (arp or non-arp) is considered a proof that the slave
>-		is up.
>+		No validation or filtering is performed.
>
> 	active or 1
>
>-		Validation is performed only for the active slave. Only ARPs
>-		that arrive from any arp_ip_target are considered legit. The
>-		backup slave still does no validation (as if arp_validate=0).
>+		Validation is performed only for the active slave.
>
> 	backup or 2
>
>-		Validation is performed only for backup slaves. Only ARPs
>-		that arrive from any arp_ip_target are considered legit. The
>-		active slave still has no validation (as if arp_validate=0).
>+		Validation is performed only for backup slaves.
>
> 	all or 3
>
>-		Validation is performed for all slaves. Only ARPs
>-		that arrive from any arp_ip_target are considered legit.
>-
>-	arp or 4
>-
>-		Any arp packet is accepted as a proof that any slave is up,
>-		but no IP-based validation is made.
>-
>-	active_arp or 5
>-
>-		Validation is performed only for the active slave. Only ARPs
>-		that arrive from any arp_ip_target are considered legit. The
>-		backup slave validates only arp packets, but doesn't check the
>-		source (as if arp_validate=4).
>-
>-	backup_any or 6
>-
>-		Validation is performed only for backup slaves. Only ARPs
>-		that arrive from any arp_ip_target are considered legit. The
>-		active slave validates only arp packets, but doesn't check the
>-		source (as if arp_validate=4).
>-
>-	For the active slave, the validation checks ARP replies to
>-	confirm that they were generated by an arp_ip_target.  Since
>-	backup slaves do not typically receive these replies, the
>-	validation performed for backup slaves is on the ARP request
>-	sent out via the active slave.  It is possible that some
>-	switch or network configurations may result in situations
>-	wherein the backup slaves do not receive the ARP requests; in
>-	such a situation, validation of backup slaves must be
>-	disabled.
>-
>-	The validation of ARP requests on backup slaves is mainly
>-	helping bonding to decide which slaves are more likely to
>-	work in case of the active slave failure, it doesn't really
>-	guarantee that the backup slave will work if it's selected
>-	as the next active slave.
>-
>-	This option is useful in network configurations in which
>-	multiple bonding hosts are concurrently issuing ARPs to one or
>-	more targets beyond a common switch.  Should the link between
>-	the switch and target fail (but not the switch itself), the
>-	probe traffic generated by the multiple bonding instances will
>-	fool the standard ARP monitor into considering the links as
>-	still up.  Use of the arp_validate option can resolve this, as
>-	the ARP monitor will only consider ARP requests and replies
>-	associated with its own instance of bonding.
>+		Validation is performed for all slaves.
>+
>+	filter_active or 4
>+
>+		Filtering is applied to the active slave only.
>+
>+	filter_backup or 5
>+
>+		Filtering is applied to the backup slave(s) only.
>+
>+	filter_all or 6
>+
>+		Filtering is applied to all slaves.
>+
>+	Validation:
>+
>+	Enabling validation causes the ARP monitor to examine the incoming
>+	ARP requests and replies, and only consider a slave to be up if it
>+	is receiving the appropriate ARP traffic.
>+
>+	For an active slave, the validation checks ARP replies to confirm
>+	that they were generated by an arp_ip_target.  Since backup slaves
>+	do not typically receive these replies, the validation performed
>+	for backup slaves is on the broadcast ARP request sent out via the
>+	active slave.  It is possible that some switch or network
>+	configurations may result in situations wherein the backup slaves
>+	do not receive the ARP requests; in such a situation, validation
>+	of backup slaves must be disabled.
>+
>+	The validation of ARP requests on backup slaves is mainly helping
>+	bonding to decide which slaves are more likely to work in case of
>+	the active slave failure, it doesn't really guarantee that the
>+	backup slave will work if it's selected as the next active slave.
>+
>+	Validation is useful in network configurations in which multiple
>+	bonding hosts are concurrently issuing ARPs to one or more targets
>+	beyond a common switch.  Should the link between the switch and
>+	target fail (but not the switch itself), the probe traffic
>+	generated by the multiple bonding instances will fool the standard
>+	ARP monitor into considering the links as still up.  Use of
>+	validation can resolve this, as the ARP monitor will only consider
>+	ARP requests and replies associated with its own instance of
>+	bonding.
>+
>+	Filtering:
>+
>+	Enabling filtering causes the ARP monitor to only use incoming ARP
>+	packets for link availability purposes.  Arriving packets that are
>+	not ARPs are delivered normally, but do not count when determining
>+	if a slave is available.
>+
>+	Filtering operates by only considering the reception of ARP
>+	packets (any ARP packet, regardless of source or destination) when
>+	determining if a slave has received traffic for link availability
>+	purposes.
>+
>+	Filtering is useful in network configurations in which significant
>+	levels of third party broadcast traffic would fool the standard
>+	ARP monitor into considering the links as still up.  Use of
>+	filtering can resolve this, as only ARP traffic is considered for
>+	link availability purposes.
>
> 	This option was added in bonding version 3.1.0.
>
>
>
>---
>	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
>
