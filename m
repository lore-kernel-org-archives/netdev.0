From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: Frequent Oops on Shutdown 2.6.10
Date: Mon, 21 Feb 2005 16:29:49 +0900 (JST)
Message-ID: <20050221.162949.65179228.yoshfuji@linux-ipv6.org>
References: <20050220220304.1f2bd42f.akpm@osdl.org>
	<20050221.162241.24618885.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, davem@davemloft.net, akpm@osdl.org,
        yoshfuji@linux-ipv6.org
To: AndyLiebman@aol.com, terryg@axian.com
In-Reply-To: <20050221.162241.24618885.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20050221.162241.24618885.yoshfuji@linux-ipv6.org> (at Mon, 21 Feb 2005 16:22:41 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> [IPV6] Don't remove dev_snmp6 procfs entry until all users gone.
> 
> Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> 
> ===== net/ipv6/proc.c 1.25 vs edited =====
> --- 1.25/net/ipv6/proc.c	2004-07-08 07:17:29 +09:00
> +++ edited/net/ipv6/proc.c	2005-02-21 16:05:49 +09:00
:
> -	if (!p)
> +	if (!p) {
> +		if (!proc_net_devsnmp6_users)
> +			proc_net_remove("dev_snmp6");
>  		goto err_proc;
> +	}

Oops, sorry, I made a mistake here.
Please try this instead.

Thanks.

------
[IPV6] Don't remove dev_snmp6 procfs entry until all users gone.

Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

===== net/ipv6/proc.c 1.25 vs edited =====
--- 1.25/net/ipv6/proc.c	2004-07-08 07:17:29 +09:00
+++ edited/net/ipv6/proc.c	2005-02-21 16:23:57 +09:00
@@ -31,7 +31,9 @@
 #include <net/ipv6.h>
 
 #ifdef CONFIG_PROC_FS
-static struct proc_dir_entry *proc_net_devsnmp6;
+struct proc_dir_entry *proc_net_devsnmp6;
+static DECLARE_MUTEX(proc_net_devsnmp6_sem);
+static unsigned int proc_net_devsnmp6_users;
 
 static int fold_prot_inuse(struct proto *proto)
 {
@@ -211,13 +213,28 @@
 			   __alignof__(struct icmpv6_mib)) < 0)
 		goto err_icmp;
 
-	if (!proc_net_devsnmp6) {
-		err = -ENOENT;
-		goto err_proc;
+	down(&proc_net_devsnmp6_sem);
+	if (!proc_net_devsnmp6_users) {
+		proc_net_devsnmp6 = proc_mkdir("dev_snmp6", proc_net);
+		if (!proc_net_devsnmp6) {
+			err = -ENOMEM;
+			printk(KERN_ERR "%s(): failed to create dev_snmp6.\n",
+			       __FUNCTION__);
+			goto err_proc;
+		}
 	}
 	p = create_proc_entry(idev->dev->name, S_IRUGO, proc_net_devsnmp6);
-	if (!p)
+	if (!p) {
+		if (!proc_net_devsnmp6_users) {
+			proc_net_remove("dev_snmp6");
+			proc_net_devsnmp6 = NULL;
+		}
 		goto err_proc;
+	}
+
+	proc_net_devsnmp6_users++;
+	up(&proc_net_devsnmp6_sem);
+
 	p->data = idev;
 	p->proc_fops = &snmp6_seq_fops;
 
@@ -225,6 +242,7 @@
 	return 0;
 
 err_proc:
+	up(&proc_net_devsnmp6_sem);
 	snmp6_mib_free((void **)idev->stats.icmpv6);
 err_icmp:
 	return err;
@@ -232,12 +250,23 @@
 
 int snmp6_unregister_dev(struct inet6_dev *idev)
 {
-	if (!proc_net_devsnmp6)
+	down(&proc_net_devsnmp6_sem);
+	if (!proc_net_devsnmp6) {
+		up(&proc_net_devsnmp6_sem);
 		return -ENOENT;
-	if (!idev || !idev->stats.proc_dir_entry)
+	}
+	if (!idev || !idev->stats.proc_dir_entry) {
+		up(&proc_net_devsnmp6_sem);
 		return -EINVAL;
+	}
 	remove_proc_entry(idev->stats.proc_dir_entry->name,
 			  proc_net_devsnmp6);
+	if (!--proc_net_devsnmp6_users) {
+		proc_net_remove("dev_snmp6");
+		proc_net_devsnmp6 = NULL;
+	}
+	up(&proc_net_devsnmp6_sem);
+
 	snmp6_mib_free((void **)idev->stats.icmpv6);
 
 	return 0;
@@ -250,18 +279,12 @@
 	if (!proc_net_fops_create("snmp6", S_IRUGO, &snmp6_seq_fops))
 		goto proc_snmp6_fail;
 
-	proc_net_devsnmp6 = proc_mkdir("dev_snmp6", proc_net);
-	if (!proc_net_devsnmp6)
-		goto proc_dev_snmp6_fail;
-
 	if (!proc_net_fops_create("sockstat6", S_IRUGO, &sockstat6_seq_fops))
 		goto proc_sockstat6_fail;
 out:
 	return rc;
 
 proc_sockstat6_fail:
-	proc_net_remove("dev_snmp6");
-proc_dev_snmp6_fail:
 	proc_net_remove("snmp6");
 proc_snmp6_fail:
 	rc = -ENOMEM;
@@ -271,7 +294,6 @@
 void ipv6_misc_proc_exit(void)
 {
 	proc_net_remove("sockstat6");
-	proc_net_remove("dev_snmp6");
 	proc_net_remove("snmp6");
 }
 

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
