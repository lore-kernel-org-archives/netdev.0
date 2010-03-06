From: Samir Bellabes <sam@synack.fr>
Subject: Re: [RFC v2 00/10] snet: Security for NETwork syscalls
Date: Sat, 06 Mar 2010 19:16:26 +0100
Message-ID: <m2eijxqps5.fsf@ssh.synack.fr>
References: <1267561394-13626-1-git-send-email-sam@synack.fr>
	<201003030156.o231udx1023055@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, hadi@cyberus.ca, kaber@trash.net,
	zbr@ioremap.net, nhorman@tuxdriver.com, root@localdomain.pl,
	linux-security-module@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201003030156.o231udx1023055@www262.sakura.ne.jp> (Tetsuo Handa's
	message of "Wed, 03 Mar 2010 10:56:39 +0900")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> writes:

> Regarding [RFC v2 04/10] snet: introduce snet_core
> +static __init int snet_init(void)
> +{
> +	int ret;
> +
> +	pr_debug("initializing: event_hash_size=%u "
> +		 "verdict_hash_size=%u verdict_delay=%usecs "
> +		 "default_policy=%s\n",
> +		 snet_evh_size, snet_vdh_size, snet_verdict_delay,
> +		 snet_verdict_name(snet_verdict_policy));
>
> Why not to stop here if snet_evh_size == 0 or snet_vdh_size == 0 in order to
> avoid "division by 0".

indeed. I applied this patch 

>From 593614c92a1f2058c014fa674c67f434b24b26e4 Mon Sep 17 00:00:00 2001
From: Samir Bellabes <sam@synack.fr>
Date: Sat, 6 Mar 2010 17:32:51 +0100
Subject: [PATCH 2/3] snet: adding checks for bad configuration values

this patch adds some checks on boot parameters and runtime configurations for:
 - snet_verdict_policy, snet_verdict_delay and snet_vdh_size
 - snet_evh_size
 - snet_ticket_delay and snet_ticket_mode

Noticed by Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Signed-off-by: Samir Bellabes <sam@synack.fr>
---
 include/linux/snet.h         |    1 +
 security/snet/snet_core.c    |    6 ++++++
 security/snet/snet_event.c   |    6 ++++++
 security/snet/snet_netlink.c |   27 ++++++++++++++++++++-------
 security/snet/snet_ticket.c  |   12 ++++++++++++
 security/snet/snet_verdict.c |   12 ++++++++++++
 6 files changed, 57 insertions(+), 7 deletions(-)

diff --git a/include/linux/snet.h b/include/linux/snet.h
index 739601d..e6e2d52 100644
--- a/include/linux/snet.h
+++ b/include/linux/snet.h
@@ -41,6 +41,7 @@ enum snet_ticket_mode {
 	SNET_TICKET_OFF = 0,
 	SNET_TICKET_FIX,
 	SNET_TICKET_EXTEND,
+	SNET_TICKET_INVALID,
 };
 
 /* genetlink commands */
diff --git a/security/snet/snet_core.c b/security/snet/snet_core.c
index 9f2eb2e..949ecaa 100644
--- a/security/snet/snet_core.c
+++ b/security/snet/snet_core.c
@@ -42,6 +42,12 @@ static __init int snet_init(void)
 		 snet_evh_size, snet_vdh_size, snet_verdict_delay,
 		 snet_verdict_name(snet_verdict_policy));
 
+	if (snet_verdict_policy >= SNET_VERDICT_INVALID) {
+		printk(KERN_ERR "snet: bad snet_verdict_policy\n");
+		ret = -EINVAL;
+		goto event_failed;
+	}
+
 	ret = snet_event_init();
 	if (ret < 0)
 		goto event_failed;
diff --git a/security/snet/snet_event.c b/security/snet/snet_event.c
index 5f708d0..5693aac 100644
--- a/security/snet/snet_event.c
+++ b/security/snet/snet_event.c
@@ -165,6 +165,12 @@ int snet_event_init(void)
 {
 	int err = 0, i = 0;
 
+	if (snet_evh_size == 0) {
+		printk(KERN_ERR "snet: bad snet_evh_size value\n");
+		err = -EINVAL;
+		goto out;
+	}
+
 	snet_evh = kzalloc(sizeof(struct list_head) * snet_evh_size,
 			     GFP_KERNEL);
 	if (!snet_evh) {
diff --git a/security/snet/snet_netlink.c b/security/snet/snet_netlink.c
index b0dd163..937b0fc 100644
--- a/security/snet/snet_netlink.c
+++ b/security/snet/snet_netlink.c
@@ -363,25 +363,38 @@ out:
 static int snet_nl_config(struct sk_buff *skb,
 			  struct genl_info *info)
 {
-	int ret = -EINVAL;
+	int ret = 0;
 
 	atomic_set(&snet_nl_seq, info->snd_seq);
 
 	if (info->attrs[SNET_A_VERDICT_DELAY]) {
-		snet_verdict_delay = nla_get_u32(info->attrs[SNET_A_VERDICT_DELAY]);
+		unsigned int new = nla_get_u32(info->attrs[SNET_A_VERDICT_DELAY]);
+		if (new == 0) {
+			ret = -EINVAL;
+			goto out;
+		}
+		snet_verdict_delay = new;
 		pr_debug("snet_nl_config: verdict_delay=%u\n", snet_verdict_delay);
-		ret = 0;
 	}
 	if (info->attrs[SNET_A_TICKET_DELAY]) {
-		snet_ticket_delay = nla_get_u32(info->attrs[SNET_A_TICKET_DELAY]);
+		unsigned int new = nla_get_u32(info->attrs[SNET_A_TICKET_DELAY]);
+		if (new == 0) {
+			ret = -EINVAL;
+			goto out;
+		}
+		snet_ticket_delay = new;
 		pr_debug("snet_nl_config: ticket_delay=%u\n", snet_ticket_delay);
-		ret = 0;
 	}
 	if (info->attrs[SNET_A_TICKET_MODE]) {
-		snet_ticket_mode = nla_get_u32(info->attrs[SNET_A_TICKET_MODE]);
+		unsigned int new = nla_get_u32(info->attrs[SNET_A_TICKET_MODE]);
+		if (new >= SNET_TICKET_INVALID) {
+			ret = -EINVAL;
+			goto out;
+		}
+		snet_ticket_mode = new;
 		pr_debug("snet_nl_config: ticket_mode=%u\n", snet_ticket_mode);
-		ret = 0;
 	}
+out:
 	return ret;
 }
 
diff --git a/security/snet/snet_ticket.c b/security/snet/snet_ticket.c
index 62ced7b..80a1b0f 100644
--- a/security/snet/snet_ticket.c
+++ b/security/snet/snet_ticket.c
@@ -158,6 +158,18 @@ int snet_ticket_init(void)
 	struct cred *cred = (struct cred *) current->real_cred;
 	struct snet_task_security *tsec = NULL;
 
+	if (snet_ticket_mode >= SNET_TICKET_INVALID) {
+		printk(KERN_ERR "snet: bad snet_ticket_mode\n");
+		return -EINVAL;
+	}
+
+	if ((snet_ticket_mode == SNET_TICKET_FIX ||
+	    snet_ticket_mode == SNET_TICKET_EXTEND) &&
+	    (snet_ticket_delay == 0)) {
+		printk(KERN_ERR "snet: bad snet_ticket_delay\n");
+		return -EINVAL;
+	}
+
 	tsec = kzalloc(sizeof(struct snet_task_security), GFP_KERNEL);
 	if (tsec == NULL)
 		return -ENOMEM;
diff --git a/security/snet/snet_verdict.c b/security/snet/snet_verdict.c
index 480a7f8..ba35d19 100644
--- a/security/snet/snet_verdict.c
+++ b/security/snet/snet_verdict.c
@@ -156,6 +156,18 @@ int snet_verdict_init(void)
 {
 	int err = 0, i = 0;
 
+	if (snet_vdh_size == 0) {
+		printk(KERN_ERR "snet: bad snet_vdh_size value\n");
+		err = -EINVAL;
+		goto out;
+	}
+
+	if (snet_verdict_delay == 0) {
+		printk(KERN_ERR "snet: bad snet_verdict_delay value\n");
+		err = -EINVAL;
+		goto out;
+	}
+
 	snet_vdh = kzalloc(sizeof(struct list_head) * snet_vdh_size,
 			  GFP_KERNEL);
 	if (!snet_vdh) {
-- 
1.6.3.3
