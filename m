From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: take#2 [PATCH 06/15] [IRDA]: Use proc_create() to setup ->proc_fops
 first
Date: Fri, 29 Feb 2008 15:10:10 +0800
Message-ID: <47C7AFD2.5080702@cn.fujitsu.com>
References: <47C69367.6000609@cn.fujitsu.com> <20080228.140821.249369808.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54087 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754382AbYB2HMn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Feb 2008 02:12:43 -0500
In-Reply-To: <20080228.140821.249369808.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller said the following on 2008-2-29 6:08:
>>  #ifdef CONFIG_PROC_FS
>> -	{ struct proc_dir_entry *ent;
>> -	ent = create_proc_entry("ircomm", 0, proc_irda);
>> -	if (ent)
>> -		ent->proc_fops = &ircomm_proc_fops;
>> -	}
>> +	struct proc_dir_entry *ent;
>> +	ent = proc_create("ircomm", 0, proc_irda, &ircomm_proc_fops);
>>  #endif /* CONFIG_PROC_FS */
> This is not C++, you therefore cannot declare local variables in
> arbitrary locations of the function body.  That's what the braces
> were there for, to create the necessary new local scope.
> 
> For certain versions of GCC this won't even build, newer versions
> default to c99 or similar and therefore just so happen to work.
> 

Use proc_create() to make sure that ->proc_fops be setup before gluing
PDE to main tree.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 net/irda/ircomm/ircomm_core.c |    8 +++++---
 net/irda/irlan/irlan_common.c |    4 +---
 net/irda/irproc.c             |    8 +++-----
 3 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/net/irda/ircomm/ircomm_core.c b/net/irda/ircomm/ircomm_core.c
index b825399..6eef1f2 100644
--- a/net/irda/ircomm/ircomm_core.c
+++ b/net/irda/ircomm/ircomm_core.c
@@ -76,9 +76,11 @@ static int __init ircomm_init(void)
 
 #ifdef CONFIG_PROC_FS
 	{ struct proc_dir_entry *ent;
-	ent = create_proc_entry("ircomm", 0, proc_irda);
-	if (ent)
-		ent->proc_fops = &ircomm_proc_fops;
+	ent = proc_create("ircomm", 0, proc_irda, &ircomm_proc_fops);
+	if (!ent) {
+		printk(KERN_ERR "ircomm_init: can't create /proc entry!\n");
+		return -ENODEV;
+	}
 	}
 #endif /* CONFIG_PROC_FS */
 
diff --git a/net/irda/irlan/irlan_common.c b/net/irda/irlan/irlan_common.c
index a4b56e2..1eb4bbc 100644
--- a/net/irda/irlan/irlan_common.c
+++ b/net/irda/irlan/irlan_common.c
@@ -128,13 +128,11 @@ static int __init irlan_init(void)
 
 #ifdef CONFIG_PROC_FS
 	{ struct proc_dir_entry *proc;
-	proc = create_proc_entry("irlan", 0, proc_irda);
+	proc = proc_create("irlan", 0, proc_irda, &irlan_fops);
 	if (!proc) {
 		printk(KERN_ERR "irlan_init: can't create /proc entry!\n");
 		return -ENODEV;
 	}
-
-	proc->proc_fops = &irlan_fops;
 	}
 #endif /* CONFIG_PROC_FS */
 
diff --git a/net/irda/irproc.c b/net/irda/irproc.c
index cae24fb..88e80a3 100644
--- a/net/irda/irproc.c
+++ b/net/irda/irproc.c
@@ -72,11 +72,9 @@ void __init irda_proc_register(void)
 		return;
 	proc_irda->owner = THIS_MODULE;
 
-	for (i=0; i<ARRAY_SIZE(irda_dirs); i++) {
-		d = create_proc_entry(irda_dirs[i].name, 0, proc_irda);
-		if (d)
-			d->proc_fops = irda_dirs[i].fops;
-	}
+	for (i = 0; i < ARRAY_SIZE(irda_dirs); i++)
+		d = proc_create(irda_dirs[i].name, 0, proc_irda,
+				irda_dirs[i].fops);
 }
 
 /*
-- 
WCN

