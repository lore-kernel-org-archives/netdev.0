From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 8789] New: Error inserting ipt_LOG (mod_path):
 Device or resource busy
Date: Mon, 23 Jul 2007 20:18:55 +0200
Message-ID: <46A4F10F.1050700@trash.net>
References: <bug-8789-10286@http.bugzilla.kernel.org/> <20070721010207.b88e1364.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060909020906080305090005"
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: t.artem@mailcity.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36253 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756435AbXGWSTH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2007 14:19:07 -0400
In-Reply-To: <20070721010207.b88e1364.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060909020906080305090005
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Andrew Morton wrote:
> On Sat, 21 Jul 2007 00:44:08 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:
> 
> 
>>http://bugzilla.kernel.org/show_bug.cgi?id=8789
>>
>>           Summary: Error inserting ipt_LOG (mod_path): Device or resource
>>                    busy
> 
> 
> A 2.6.12 -> 2.6.22 regression.


Crap, that was my fault.

T., can you please test whether this patch fixes it?


--------------060909020906080305090005
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/bridge/netfilter/ebt_log.c b/net/bridge/netfilter/ebt_log.c
index 031bfa4..984e9c6 100644
--- a/net/bridge/netfilter/ebt_log.c
+++ b/net/bridge/netfilter/ebt_log.c
@@ -196,10 +196,8 @@ static int __init ebt_log_init(void)
 	ret = ebt_register_watcher(&log);
 	if (ret < 0)
 		return ret;
-	ret = nf_log_register(PF_BRIDGE, &ebt_log_logger);
-	if (ret < 0 && ret != -EEXIST)
-		ebt_unregister_watcher(&log);
-	return ret;
+	nf_log_register(PF_BRIDGE, &ebt_log_logger);
+	return 0;
 }
 
 static void __exit ebt_log_fini(void)
diff --git a/net/bridge/netfilter/ebt_ulog.c b/net/bridge/netfilter/ebt_ulog.c
index 9411db6..6fec352 100644
--- a/net/bridge/netfilter/ebt_ulog.c
+++ b/net/bridge/netfilter/ebt_ulog.c
@@ -308,12 +308,8 @@ static int __init ebt_ulog_init(void)
 	else if ((ret = ebt_register_watcher(&ulog)))
 		sock_release(ebtulognl->sk_socket);
 
-	if (nf_log_register(PF_BRIDGE, &ebt_ulog_logger) < 0) {
-		printk(KERN_WARNING "ebt_ulog: not logging via ulog "
-		       "since somebody else already registered for PF_BRIDGE\n");
-		/* we cannot make module load fail here, since otherwise
-		 * ebtables userspace would abort */
-	}
+	if (ret == 0)
+		nf_log_register(PF_BRIDGE, &ebt_ulog_logger);
 
 	return ret;
 }
diff --git a/net/ipv4/netfilter/ipt_LOG.c b/net/ipv4/netfilter/ipt_LOG.c
index 5937ad1..127a5e8 100644
--- a/net/ipv4/netfilter/ipt_LOG.c
+++ b/net/ipv4/netfilter/ipt_LOG.c
@@ -479,10 +479,8 @@ static int __init ipt_log_init(void)
 	ret = xt_register_target(&ipt_log_reg);
 	if (ret < 0)
 		return ret;
-	ret = nf_log_register(PF_INET, &ipt_log_logger);
-	if (ret < 0 && ret != -EEXIST)
-		xt_unregister_target(&ipt_log_reg);
-	return ret;
+	nf_log_register(PF_INET, &ipt_log_logger);
+	return 0;
 }
 
 static void __exit ipt_log_fini(void)
diff --git a/net/ipv6/netfilter/ip6t_LOG.c b/net/ipv6/netfilter/ip6t_LOG.c
index b05327e..6ab9900 100644
--- a/net/ipv6/netfilter/ip6t_LOG.c
+++ b/net/ipv6/netfilter/ip6t_LOG.c
@@ -493,10 +493,8 @@ static int __init ip6t_log_init(void)
 	ret = xt_register_target(&ip6t_log_reg);
 	if (ret < 0)
 		return ret;
-	ret = nf_log_register(PF_INET6, &ip6t_logger);
-	if (ret < 0 && ret != -EEXIST)
-		xt_unregister_target(&ip6t_log_reg);
-	return ret;
+	nf_log_register(PF_INET6, &ip6t_logger);
+	return 0;
 }
 
 static void __exit ip6t_log_fini(void)

--------------060909020906080305090005--
