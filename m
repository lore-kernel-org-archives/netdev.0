From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net] bonding: Avoid possible de-sync with arp_validate
Date: Fri, 06 Sep 2013 10:56:33 -0700
Message-ID: <7249.1378490193@death.nxdomain>
References: <994d2dc994a801fc3aae7aa912266b09ea45d95c.1378489255.git.mleitner@redhat.com>
Cc: netdev@vger.kernel.org, naleksan@redhat.com, andy@greyhouse.net
To: Marcelo Ricardo Leitner <mleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:40869 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751323Ab3IFR4i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Sep 2013 13:56:38 -0400
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Fri, 6 Sep 2013 11:56:37 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 7421C19D8042
	for <netdev@vger.kernel.org>; Fri,  6 Sep 2013 11:56:35 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r86HuZ1R314480
	for <netdev@vger.kernel.org>; Fri, 6 Sep 2013 11:56:35 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r86HuZ30030791
	for <netdev@vger.kernel.org>; Fri, 6 Sep 2013 11:56:35 -0600
In-reply-to: <994d2dc994a801fc3aae7aa912266b09ea45d95c.1378489255.git.mleitner@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marcelo Ricardo Leitner <mleitner@redhat.com> wrote:

>Hi Dave,
>
>Please queue this one for -stable trees too.
>
>Thanks.
>
>---8<---
>
>As bond_store_arp_validation and bond_store_arp_interval doesn't
>deal with each other, we can't chain both at bond_open, otherwise
>we are open to this de-sync state, steps in sequence:
>- bond is down
>- arp_interval = 0
>- arp_validate = 1 or 2
>- bond is up
>- arp_interval = 1
>
>This would lead to bond issuing ARP requests but never listening
>to the replies, because the tap wasn't attached. After reaching
>this state, while bond is up, setting arp_validate won't help
>as it only acts if needed.

	You need to sign off you patch.

> drivers/net/bonding/bond_main.c | 7 +++----
> 1 file changed, 3 insertions(+), 4 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 39e5b1c..805d098 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -3180,11 +3180,10 @@ static int bond_open(struct net_device *bond_dev)
> 	if (bond->params.miimon)  /* link check interval, in milliseconds. */
> 		queue_delayed_work(bond->wq, &bond->mii_work, 0);
>
>-	if (bond->params.arp_interval) {  /* arp interval, in milliseconds. */
>+	if (bond->params.arp_interval)    /* arp interval, in milliseconds. */
> 		queue_delayed_work(bond->wq, &bond->arp_work, 0);
>-		if (bond->params.arp_validate)
>-			bond->recv_probe = bond_arp_rcv;
>-	}
>+	if (bond->params.arp_validate)
>+		bond->recv_probe = bond_arp_rcv;

	Won't this set the recv_probe when arp_interval is 0 (disabled)?
That's going to make bonding look at a bunch of traffic it's not going
to do anything with.

	Why is this better than having bonding_store_arp_interval set
recv_probe if arp_validate is set when it queues the arp_work?  And,
presumably, clear the recv_probe if arp_interval is being cleared.

	-J

> 	if (bond->params.mode == BOND_MODE_8023AD) {
> 		queue_delayed_work(bond->wq, &bond->ad_work, 0);
>-- 
>1.8.3.1
>

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
