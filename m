From: Samir Bellabes <sam@synack.fr>
Subject: Re: [RFC 4/9] snet: introduce snet_core.c and snet.h
Date: Thu, 07 Jan 2010 15:53:52 +0100
Message-ID: <m2k4vum0e7.fsf@ssh.synack.fr>
References: <1262437456-24476-1-git-send-email-sam@synack.fr>
	<1262437456-24476-5-git-send-email-sam@synack.fr>
	<4B41FE9D.2070708@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-security-module@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <4B41FE9D.2070708@trash.net> (Patrick McHardy's message of "Mon,
	04 Jan 2010 15:43:41 +0100")
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> writes:

>> +static __init int snet_init(void)
>> +{
>> +	int ret;
>> +
>> +	snet_dbg("initializing: event_hash_size=%u "
>> +		 "verdict_hash_size=%u verdict_delay=%usecs "
>> +		 "default_policy=%s\n",
>> +		 event_hash_size, verdict_hash_size, snet_verdict_delay,
>> +		 snet_verdict_name(snet_verdict_policy));
>> +
>> +	ret = snet_event_init();
>> +	if (ret < 0)
>> +		goto exit;
>> +
>> +	ret = snet_verdict_init();
>> +	if (ret < 0)
>> +		goto exit;
>> +
>> +	ret = snet_hooks_init();
>> +	if (ret < 0)
>> +		goto exit;
>> +
>> +	snet_dbg("started\n");
>> +	return 0;
>> +exit:
>> +	snet_core_exit();
>> +	return ret;
>
> By cleaning up only those parts that were successfully initialized,
> you could avoid things like the verdict_hash check below:
>
>> +int snet_verdict_exit(void)
>> +{
>> +	write_lock_bh(&verdict_hash_lock);
>> +	if (verdict_hash) {
>> +		__snet_verdict_flush();
>> +		kfree(verdict_hash);
>> +		verdict_hash = NULL;
>> +	}
>> +	write_unlock_bh(&verdict_hash_lock);
>> +
>> +	return 0;

true. here is the patch I made to fix this.

Patrick, thanks
sam

commit 76c53bb2e6ac2ff6b8426c9b22c67cde1ae5ac07
Author: Samir Bellabes <sam@synack.fr>
Date:   Thu Jan 7 23:09:17 2010 +0100

    snet: avoid unnecessary checks by fixing initialisation for verdict and event
    
    checking if snet_evh and snet_vdh are NULL is unnecessary if the initalisations
    are sucessfull.
    
    Noticed by Patrick McHardy <kaber@trash.net>
    
    Signed-off-by: Samir Bellabes <sam@synack.fr>

diff --git a/security/snet/snet_core.c b/security/snet/snet_core.c
index 562d986..54fad08 100644
--- a/security/snet/snet_core.c
+++ b/security/snet/snet_core.c
@@ -25,15 +25,6 @@ unsigned int snet_verdict_policy = SNET_VERDICT_GRANT;	/* permissive by default
 module_param(snet_verdict_policy, uint, 0400);
 MODULE_PARM_DESC(snet_verdict_policy, "Set the default verdict");
 
-void snet_core_exit(void)
-{
-	snet_netlink_exit();
-	snet_event_exit();
-	snet_hooks_exit();
-	snet_verdict_exit();
-	pr_debug("stopped\n");
-}
-
 static __init int snet_init(void)
 {
 	int ret;
@@ -46,20 +37,25 @@ static __init int snet_init(void)
 
 	ret = snet_event_init();
 	if (ret < 0)
-		goto exit;
+		goto event_failed;
 
 	ret = snet_verdict_init();
 	if (ret < 0)
-		goto exit;
+		goto verdict_failed;
 
 	ret = snet_hooks_init();
 	if (ret < 0)
-		goto exit;
+		goto hooks_failed;
 
 	pr_debug("started\n");
 	return 0;
-exit:
-	snet_core_exit();
+
+hooks_failed:
+	snet_verdict_exit();
+verdict_failed:
+	snet_event_exit();
+event_failed:
+	pr_debug("stopped\n");
 	return ret;
 }
 
diff --git a/security/snet/snet_event.c b/security/snet/snet_event.c
index cc3b6a2..44155fb 100644
--- a/security/snet/snet_event.c
+++ b/security/snet/snet_event.c
@@ -25,9 +25,6 @@ static struct snet_event_entry *__snet_event_lookup(const enum snet_syscall sysc
 	struct list_head *l;
 	struct snet_event_entry *s;
 
-	if (!snet_evh)
-		return NULL;
-
 	/* computing its hash value */
 	h = jhash_2words(syscall, protocol, 0) % snet_evh_size;
 	l = &snet_evh[h];
@@ -52,9 +49,6 @@ int snet_event_fill_info(struct sk_buff *skb, struct netlink_callback *cb)
 
 	read_lock_bh(&snet_evh_lock);
 
-	if (!snet_evh)
-		goto errout;
-
 	for (i = 0; i < snet_evh_size; i++) {
 		if (i < hashs_to_skip)
 			continue;
@@ -151,11 +145,12 @@ int snet_event_remove(const enum snet_syscall syscall, const u8 protocol)
 }
 
 /* flushing all events */
-void __snet_event_flush(void)
+void snet_event_flush(void)
 {
 	struct snet_event_entry *data = NULL;
 	unsigned int i = 0;
 
+	write_lock_bh(&snet_evh_lock);
 	for (i = 0; i < snet_evh_size; i++) {
 		while (!list_empty(&snet_evh[i])) {
 			data = list_entry(snet_evh[i].next,
@@ -164,14 +159,6 @@ void __snet_event_flush(void)
 			kfree(data);
 		}
 	}
-	return;
-}
-
-void snet_event_flush(void)
-{
-	write_lock_bh(&snet_evh_lock);
-	if (snet_evh)
-		__snet_event_flush();
 	write_unlock_bh(&snet_evh_lock);
 	return;
 }
@@ -200,13 +187,7 @@ out:
 /* exit function */
 int snet_event_exit(void)
 {
-	write_lock_bh(&snet_evh_lock);
-	if (snet_evh) {
-		__snet_event_flush();
-		kfree(snet_evh);
-		snet_evh = NULL;
-	}
-	write_unlock_bh(&snet_evh_lock);
-
+	kfree(snet_evh);
+	snet_evh = NULL;
 	return 0;
 }
diff --git a/security/snet/snet_verdict.c b/security/snet/snet_verdict.c
index 477af3b..78bc882 100644
--- a/security/snet/snet_verdict.c
+++ b/security/snet/snet_verdict.c
@@ -30,9 +30,6 @@ static struct snet_verdict_entry *__snet_verdict_lookup(const u32 verdict_id)
 	struct list_head *l = NULL;
 	struct snet_verdict_entry *s = NULL;
 
-	if (!snet_vdh)
-		return NULL;
-
 	/* computing its hash value */
 	h = jhash_1word(verdict_id, 0) % snet_vdh_size;
 	l = &snet_vdh[h];
@@ -135,24 +132,19 @@ int snet_verdict_insert(void)
 	h = jhash_1word(data->verdict_id, 0) % snet_vdh_size;
 
 	write_lock_bh(&snet_vdh_lock);
-	if (snet_vdh) {
-		list_add_tail(&data->list, &snet_vdh[h]);
-		pr_debug("[%u]=(verdict_id=%u)\n", h, data->verdict_id);
-		write_unlock_bh(&snet_vdh_lock);
-	} else {
-		write_unlock_bh(&snet_vdh_lock);
-		kfree(data);
-		verdict_id = 0;
-	}
+	list_add_tail(&data->list, &snet_vdh[h]);
+	pr_debug("[%u]=(verdict_id=%u)\n", h, data->verdict_id);
+	write_unlock_bh(&snet_vdh_lock);
 
 	return verdict_id;
 }
 
-void __snet_verdict_flush(void)
+void snet_verdict_flush(void)
 {
 	struct snet_verdict_entry *data = NULL;
 	unsigned int i = 0;
 
+	write_lock_bh(&snet_vdh_lock);
 	for (i = 0; i < snet_vdh_size; i++) {
 		while (!list_empty(&snet_vdh[i])) {
 			data = list_entry(snet_vdh[i].next,
@@ -161,15 +153,7 @@ void __snet_verdict_flush(void)
 			kfree(data);
 		}
 	}
-	return;
-}
-
-void snet_verdict_flush(void)
-{
-	write_lock_bh(&snet_vdh_lock);
-	if (snet_vdh)
-		__snet_verdict_flush();
-	write_unlock_bh(&snet_vdh_lock);
+	write_untlock_bh(&snet_vdh_lock);
 	return;
 }
 
@@ -197,13 +181,7 @@ out:
 /* exit function */
 int snet_verdict_exit(void)
 {
-	write_lock_bh(&snet_vdh_lock);
-	if (snet_vdh) {
-		__snet_verdict_flush();
-		kfree(snet_vdh);
-		snet_vdh = NULL;
-	}
-	write_unlock_bh(&snet_vdh_lock);
-
+	kfree(snet_vdh);
+	snet_vdh = NULL;
 	return 0;
 }
