From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH] netconsole: release the spinlock before
 __netpoll_cleanup()
Date: Sun, 10 Mar 2013 16:25:46 +0100
Message-ID: <20130310152546.GA4897@redhat.com>
References: <1362581203-8994-1-git-send-email-vfalico@redhat.com>
 <20130307000824.GA5702@neilslaptop.think-freely.org>
 <20130307100325.GA31105@redhat.com>
 <20130307.161438.396456319050281566.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org, amwang@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35499 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751837Ab3CJP0D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Mar 2013 11:26:03 -0400
Content-Disposition: inline
In-Reply-To: <20130307.161438.396456319050281566.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 07, 2013 at 04:14:38PM -0500, David Miller wrote:
>From: Veaceslav Falico <vfalico@redhat.com>
>Date: Thu, 7 Mar 2013 11:03:25 +0100
>
>> @@ -680,9 +681,21 @@ static int netconsole_netdev_event(struct
>> notifier_block *this,
>>  				 * rtnl_lock already held
>>  				 */
>>  				if (nt->np.dev) {
>> +					/*
>> +					 * we still might sleep in
>> + * __netpoll_cleanup(), so release
>> +					 * the lock and restart
>
>Quite a bit of email corruption of this patch.

Sorry, somehow messed it.

>
>Also, this code block is probably too deeply indented to be sane,
>consider creating a small helper function to call instead.

It gets quite ugly if I try to move it to another function. However, maybe
something like that will work - it's effectively the same code, just that
I've moved the long part out of the if () { } block. Looks a lot more
readable, though one line still breaks 80chars limit. I've reworked the
subject/commit message too.

Subject: [PATCH] netconsole: don't call __netpoll_cleanup() while atomic

__netpoll_cleanup() is called in netconsole_netdev_event() while holding a
spinlock. Release/acquire the spinlock before/after it and restart the
loop.

Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
    drivers/net/netconsole.c |   22 +++++++++++++++-------
    1 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index 37add21..38eaa8c 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -666,6 +666,7 @@ static int netconsole_netdev_event(struct notifier_block *this,
    		goto done;
    
    	spin_lock_irqsave(&target_list_lock, flags);
+restart:
    	list_for_each_entry(nt, &target_list, list) {
    		netconsole_target_get(nt);
    		if (nt->np.dev == dev) {
@@ -679,14 +680,21 @@ static int netconsole_netdev_event(struct notifier_block *this,
    				/*
    				 * rtnl_lock already held
    				 */
-				if (nt->np.dev) {
-					__netpoll_cleanup(&nt->np);
-					dev_put(nt->np.dev);
-					nt->np.dev = NULL;
+				if (!nt->np.dev) {
+					nt->enabled = 0;
+					stopped = true;
+					break;
    				}
-				nt->enabled = 0;
-				stopped = true;
-				break;
+				/*
+				 * we might sleep in __netpoll_cleanup()
+				 */
+				spin_unlock_irqrestore(&target_list_lock, flags);
+				__netpoll_cleanup(&nt->np);
+				spin_lock_irqsave(&target_list_lock, flags);
+				dev_put(nt->np.dev);
+				nt->np.dev = NULL;
+				netconsole_target_put(nt);
+				goto restart;
    			}
    		}
    		netconsole_target_put(nt);
-- 
1.7.1
