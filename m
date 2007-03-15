From: Samir Bellabes <sam@synack.fr>
Subject: Re: [RFC] [PATCH] Network Events Connector
Date: Thu, 15 Mar 2007 01:48:27 +0100
Message-ID: <m24pon72n8.fsf@cerbere.dyndns.info>
References: <m2irecym8t.fsf@cerbere.dyndns.info>
	<20070217163422.GB22369@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 119.235.97-84.rev.gaoland.net ([84.97.235.119]:43313 "EHLO
	cerbere.dyndns.info" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422801AbXCOAs3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2007 20:48:29 -0400
In-Reply-To: <20070217163422.GB22369@2ka.mipt.ru> (Evgeniy Polyakov's message
	of "Sat, 17 Feb 2007 19:34:22 +0300")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov <johnpol@2ka.mipt.ru> writes:

> On Fri, Feb 09, 2007 at 05:43:14AM +0100, Samir Bellabes (sam@synack.fr) wrote:
>> Hi,
>> 
>> Here is a new feature which can help firewalls to be more application
>> aware, so more useful for people.
>> 
>> Our previous discussion about cn_net and firewalls:
>> http://marc2.theaimsgroup.com/?t=115976957500002&r=1&w=2
>> 
>> Please, I would really like to have feedback and comments on that tool,
>> in order to improve it.
>
> Technical side does have problems.
> 2. initialization path has problems - hash is allocated after securty
> hooks and connector moduler are registered.

I see. Here is a patch, to apply on top of previous.

commit 7c89bcb9cc07b02023c9a43b80ff1df7cb07b900
Author: Samir Bellabes <sam@synack.fr>
Date:   Mon Feb 19 15:16:05 2007 +0100

    [PATCH] cn_net: fix initialization path
    
    'hash' is allocated after the registration of security hooks and
    connector callback.
    
    Noticed by Evgeniy Polyakov <johnpol@2ka.mipt.ru>
    
    Signed-off-by: Samir Bellabes <sam@synack.fr>

diff --git a/drivers/connector/cn_net.c b/drivers/connector/cn_net.c
index 1f681f6..c9eb53e 100644
--- a/drivers/connector/cn_net.c
+++ b/drivers/connector/cn_net.c
@@ -537,13 +537,22 @@ static struct security_operations cn_net
 };
 
 static int __init init(void) {
-	int err, i;
+	int err = 0, i = 0;
 
-	err = cn_add_callback(&cn_net_event_id, cn_net_event_name, &cn_net_ctl);
+	hash = kzalloc(sizeof(struct list_head) * hash_size, GFP_KERNEL);
+	if (!hash) {
+		printk(KERN_WARNING "cn_net: Failure can't alloc memory for hash\n");
+		err = -ENOMEM;
+		goto out;
+	}
+	
+	for (i = 0; i < hash_size; i++)
+		INIT_LIST_HEAD(&(hash[i]));
 
+	err = cn_add_callback(&cn_net_event_id, cn_net_event_name, &cn_net_ctl);
 	if (err) {
 		printk(KERN_WARNING "cn_net: Failure add connector callback\n");
-		goto out;
+		goto out_callback;
 	}
 
 	if (register_security(&cn_net_security_ops)) {
@@ -558,33 +567,15 @@ static int __init init(void) {
 		secondary = 1;
 	}
 
-
-	hash = kzalloc(sizeof(struct list_head) * hash_size, GFP_KERNEL);
-	if (!hash)
-		goto out_nomem_hash;
-	
-	for (i = 0; i < hash_size; i++)
-		INIT_LIST_HEAD(&(hash[i]));
-
-	printk(KERN_INFO "cn_net: module loaded\n");
-
+	printk(KERN_INFO "cn_net: network events module loaded\n");
 	return 0;
 
-out_nomem_hash:
-	err = -ENOMEM;
-
-	if (secondary) {
-		if (mod_unreg_security(MY_NAME, &cn_net_security_ops))
-			printk(KERN_INFO "cn_net: Failure unregistering with"
-			       " primary security module\n");
-	} else {
-		if (unregister_security(&cn_net_security_ops))
-			printk(KERN_INFO "cn_net: Failure unregistering with "
-			       "kernel\n");
-	}
-
 out_security:
 	cn_del_callback(&cn_net_event_id);
+
+out_callback:
+	kfree(hash);
+
 out:
 	return err;
 }

