From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH] bonding: fix panic if initialization fails
Date: Sat, 9 May 2009 01:21:01 +0200
Message-ID: <20090508232100.GB4881@psychotron.englab.brq.redhat.com>
References: <1241819351-26356-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:47196 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753109AbZEHXVN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 May 2009 19:21:13 -0400
Content-Disposition: inline
In-Reply-To: <1241819351-26356-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, May 08, 2009 at 11:49:11PM CEST, fw@strlen.de wrote:
>If module initialisation failed (e.g. because the bonding sysfs entry
>cannot be created), kernel panics:
> IP: [<ffffffff8024910a>] destroy_workqueue+0x2d/0x146
>Call Trace:
> [<ffffffff808268c4>] bond_destructor+0x28/0x78
> [<ffffffff80b64471>] netdev_run_todo+0x231/0x25a
> [<ffffffff80b6dbcd>] rtnl_unlock+0x9/0xb
> [<ffffffff81567907>] bonding_init+0x83e/0x84a
>
>Remove the calls to bond_work_cancel_all() and destroy_workqueue();
>both are also called/scheduled via bond_free_all().
>
>bond_destroy_sysfs is unecessary because the sysfs entry has
>not been created in the error case.
>
>Signed-off-by: Florian Westphal <fw@strlen.de>
>---
> drivers/net/bonding/bond_main.c |    8 --------
> 1 files changed, 0 insertions(+), 8 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 815191d..56830a4 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -5199,7 +5199,6 @@ static int __init bonding_init(void)
> {
> 	int i;
> 	int res;
>-	struct bonding *bond;
> 
> 	printk(KERN_INFO "%s", version);
> 
>@@ -5228,13 +5227,6 @@ static int __init bonding_init(void)
> 
> 	goto out;
> err:
>-	list_for_each_entry(bond, &bond_dev_list, bond_list) {
>-		bond_work_cancel_all(bond);
>-		destroy_workqueue(bond->wq);
>-	}
This looks correct.

>-
>-	bond_destroy_sysfs();
Why this is not here anymore? I think it should be called in this function.
>-
> 	rtnl_lock();
> 	bond_free_all();
> 	rtnl_unlock();
>-- 
>1.6.0.6
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
