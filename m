From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 2/2] bonding: fix igmp_retrans type and two related races
Date: Thu, 06 Jun 2013 18:00:50 -0700
Message-ID: <4475.1370566850@death.nxdomain>
References: <1370519702-18581-1-git-send-email-nikolay@redhat.com> <1370519702-18581-3-git-send-email-nikolay@redhat.com>
Cc: netdev@vger.kernel.org, andy@greyhouse.net, davem@davemloft.net
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:40417 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754365Ab3FGBA4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jun 2013 21:00:56 -0400
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Thu, 6 Jun 2013 21:00:55 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 4C95EC90042
	for <netdev@vger.kernel.org>; Thu,  6 Jun 2013 21:00:52 -0400 (EDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5710qRN355632
	for <netdev@vger.kernel.org>; Thu, 6 Jun 2013 21:00:52 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5710pYk006020
	for <netdev@vger.kernel.org>; Thu, 6 Jun 2013 19:00:52 -0600
In-reply-to: <1370519702-18581-3-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nikolay@redhat.com wrote:

>From: Nikolay Aleksandrov <nikolay@redhat.com>
>
>First the type of igmp_retrans (which is the actual counter of
>igmp_resend parameter) is changed to u8 to be able to store values up
>to 255 (as per documentation). There are two races that were hidden
>there and which are easy to trigger after the previous fix, the first is
>between bond_resend_igmp_join_requests and bond_change_active_slave
>where igmp_retrans is set and can be altered by the periodic. The second
>race condition is between multiple running instances of the periodic
>(upon execution it can be scheduled again for immediate execution which
>can cause the counter to go < 0 which in the unsigned case leads to
>unnecessary igmp retransmissions).
>Since in bond_change_active_slave bond->lock is held for reading and
>curr_slave_lock for writing, we use curr_slave_lock for mutual
>exclusion. We can't drop them as there're cases where RTNL is not held
>when bond_change_active_slave is called. RCU is unlocked in
>bond_resend_igmp_join_requests before getting curr_slave_lock since we
>don't need it there and it's pointless to delay.

	My first thought is that it would be much simpler to change the
limit in the documentation and code from 255 to 127 and be done with it.
I'm skeptical that anybody uses values for igmp_retrans even as high as
10, much less 100 (which would take 20 seconds to complete at 5 per
second).

	That said, this is technically correct, although I have one
question, below.

>Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
>---
> drivers/net/bonding/bond_main.c | 15 +++++++++++----
> drivers/net/bonding/bonding.h   |  2 +-
> 2 files changed, 12 insertions(+), 5 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 473633a..02d9ae7 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -764,8 +764,8 @@ static void bond_resend_igmp_join_requests(struct bonding *bond)
> 	struct net_device *bond_dev, *vlan_dev, *upper_dev;
> 	struct vlan_entry *vlan;
>
>-	rcu_read_lock();
> 	read_lock(&bond->lock);
>+	rcu_read_lock();
>
> 	bond_dev = bond->dev;
>
>@@ -787,12 +787,19 @@ static void bond_resend_igmp_join_requests(struct bonding *bond)
> 		if (vlan_dev)
> 			__bond_resend_igmp_join_requests(vlan_dev);
> 	}
>+	rcu_read_unlock();
>
>-	if (--bond->igmp_retrans > 0)
>+	/* We use curr_slave_lock to protect against concurrent access to
>+	 * igmp_retrans from multiple running instances of this function and
>+	 * bond_change_active_slave
>+	 */
>+	write_lock_bh(&bond->curr_slave_lock);
>+	if (bond->igmp_retrans > 1) {
>+		bond->igmp_retrans--;
> 		queue_delayed_work(bond->wq, &bond->mcast_work, HZ/5);

	Why split out the -- from the comparison?

	-J
>-
>+	}
>+	write_unlock_bh(&bond->curr_slave_lock);
> 	read_unlock(&bond->lock);
>-	rcu_read_unlock();
> }
>
> static void bond_resend_igmp_join_requests_delayed(struct work_struct *work)
>diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
>index 2baec24..f989e15 100644
>--- a/drivers/net/bonding/bonding.h
>+++ b/drivers/net/bonding/bonding.h
>@@ -225,7 +225,7 @@ struct bonding {
> 	rwlock_t curr_slave_lock;
> 	u8	 send_peer_notif;
> 	s8	 setup_by_slave;
>-	s8       igmp_retrans;
>+	u8       igmp_retrans;
> #ifdef CONFIG_PROC_FS
> 	struct   proc_dir_entry *proc_entry;
> 	char     proc_file_name[IFNAMSIZ];
>-- 
>1.8.1.4
>

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
