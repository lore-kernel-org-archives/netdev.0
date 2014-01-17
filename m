From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH v2 net-next 05/12] bonding: extend arp_validate to be able to receive unvalidated arp-only traffic
Date: Fri, 17 Jan 2014 12:41:29 -0800
Message-ID: <32086.1389991289@death.nxdomain>
References: <1389977940-17084-1-git-send-email-vfalico@redhat.com> <1389977940-17084-6-git-send-email-vfalico@redhat.com>
Cc: netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:44255 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752926AbaAQUld (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jan 2014 15:41:33 -0500
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Fri, 17 Jan 2014 15:41:33 -0500
Received: from b01cxnp23033.gho.pok.ibm.com (b01cxnp23033.gho.pok.ibm.com [9.57.198.28])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id E95676E8047
	for <netdev@vger.kernel.org>; Fri, 17 Jan 2014 15:41:26 -0500 (EST)
Received: from d01av05.pok.ibm.com (d01av05.pok.ibm.com [9.56.224.195])
	by b01cxnp23033.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0HKfUFU8716772
	for <netdev@vger.kernel.org>; Fri, 17 Jan 2014 20:41:30 GMT
Received: from d01av05.pok.ibm.com (localhost [127.0.0.1])
	by d01av05.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0HKfU5s015453
	for <netdev@vger.kernel.org>; Fri, 17 Jan 2014 15:41:30 -0500
In-reply-to: <1389977940-17084-6-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Veaceslav Falico <vfalico@redhat.com> wrote:

>Currently we can either receive any traffic as a proff of slave being up,
>or only *validated* arp traffic (i.e. with src/dst ip checked).
>
>Add an option to be able to specify if we want to receive non-validated arp
>traffic only.
>
>CC: Jay Vosburgh <fubar@us.ibm.com>
>CC: Andy Gospodarek <andy@greyhouse.net>
>Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
>---
> drivers/net/bonding/bond_main.c |  3 +++
> drivers/net/bonding/bonding.h   | 11 +++++++++++
> 2 files changed, 14 insertions(+)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 07ae82d..532a452 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -246,6 +246,9 @@ const struct bond_parm_tbl arp_validate_tbl[] = {
> {	"active",		BOND_ARP_VALIDATE_ACTIVE},
> {	"backup",		BOND_ARP_VALIDATE_BACKUP},
> {	"all",			BOND_ARP_VALIDATE_ALL},
>+{	"arp",			BOND_ARP_VALIDATE_ARP},
>+{	"active_arp",		BOND_ARP_VALIDATE_ACTIVE_ARP},
>+{	"backup_arp",		BOND_ARP_VALIDATE_BACKUP_ARP},
> {	NULL,			-1},
> };
>
>diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
>index 955dc48..1fbbf04 100644
>--- a/drivers/net/bonding/bonding.h
>+++ b/drivers/net/bonding/bonding.h
>@@ -318,6 +318,11 @@ static inline bool bond_is_active_slave(struct slave *slave)
> #define BOND_ARP_VALIDATE_BACKUP	(1 << BOND_STATE_BACKUP)
> #define BOND_ARP_VALIDATE_ALL		(BOND_ARP_VALIDATE_ACTIVE | \
> 					 BOND_ARP_VALIDATE_BACKUP)
>+#define BOND_ARP_VALIDATE_ARP		(BOND_ARP_VALIDATE_ALL + 1)
>+#define BOND_ARP_VALIDATE_ACTIVE_ARP	(BOND_ARP_VALIDATE_ACTIVE | \
>+					 BOND_ARP_VALIDATE_ARP)
>+#define BOND_ARP_VALIDATE_BACKUP_ARP	(BOND_ARP_VALIDATE_BACKUP | \
>+					 BOND_ARP_VALIDATE_ARP)

	If you go with my suggestion to call the new thing "filtering,"
I'd change these option names, labels, and the function
"slave_do_arp_validate_only" names.  The function name seems kind of
confusing in particular. I think it'd be clearer to replace the
"validate" stuff with "filter."

	-J

> static inline int slave_do_arp_validate(struct bonding *bond,
> 					struct slave *slave)
>@@ -325,6 +330,12 @@ static inline int slave_do_arp_validate(struct bonding *bond,
> 	return bond->params.arp_validate & (1 << bond_slave_state(slave));
> }
>
>+static inline int slave_do_arp_validate_only(struct bonding *bond,
>+					     struct slave *slave)
>+{
>+	return bond->params.arp_validate & BOND_ARP_VALIDATE_ARP;
>+}
>+
> /* Get the oldest arp which we've received on this slave for bond's
>  * arp_targets.
>  */
>-- 
>1.8.4
>

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
