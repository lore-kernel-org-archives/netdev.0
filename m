From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: query: adding a sysctl
Date: Fri, 02 Oct 2009 00:00:05 -0400
Message-ID: <4AC57AC5.3080703@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040706050308070603060406"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.221.174]:33012 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750854AbZJBEAE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 00:00:04 -0400
Received: by qyk4 with SMTP id 4so686334qyk.33
        for <netdev@vger.kernel.org>; Thu, 01 Oct 2009 21:00:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040706050308070603060406
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

[My first post here, hopefully not a FAQ, as I've googled it, but cannot find
the definitive answer.]

I've been trying to add a sysctl, and I've noticed this message:

sysctl table check failed: /net/ipv4/tcp_cookie_size .3.5.126 Unknown sysctl binary path

I modeled the code on sysctl_tcp_syncookies, and apparently I'm missing some
additional magic?  Or does something need to be done other than C?

--------------040706050308070603060406
Content-Type: text/plain;
 name="sysctl_tcp_cookie_size.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sysctl_tcp_cookie_size.txt"

diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index e76d3b2..8c74bec 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -435,6 +435,7 @@ enum
 	NET_TCP_ALLOWED_CONG_CONTROL=123,
 	NET_TCP_MAX_SSTHRESH=124,
 	NET_TCP_FRTO_RESPONSE=125,
+	NET_TCP_COOKIE_SIZE=126,
 };
 
 enum {
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 4710d21..e6174c9 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -340,6 +340,16 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec_jiffies,
 		.strategy	= sysctl_jiffies
 	},
+#ifdef CONFIG_TCP_OPT_COOKIE_EXTENSION
+	{
+		.ctl_name	= NET_TCP_COOKIE_SIZE,
+		.procname	= "tcp_cookie_size",
+		.data		= &sysctl_tcp_cookie_size,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+#endif
 #ifdef CONFIG_SYN_COOKIES
 	{
 		.ctl_name	= NET_TCP_SYNCOOKIES,
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 56b7602..a53b2a8 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -208,6 +214,7 @@ extern int sysctl_tcp_synack_retries;
 extern int sysctl_tcp_retries1;
 extern int sysctl_tcp_retries2;
 extern int sysctl_tcp_orphan_retries;
+extern int sysctl_tcp_cookie_size;
 extern int sysctl_tcp_syncookies;
 extern int sysctl_tcp_retrans_collapse;
 extern int sysctl_tcp_stdurg;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 5200aab..afbdc30 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -59,6 +59,14 @@ int sysctl_tcp_base_mss __read_mostly = 512;
 /* By default, RFC2861 behavior.  */
 int sysctl_tcp_slow_start_after_idle __read_mostly = 1;
 
+#ifdef CONFIG_SYSCTL
+/* By default, let the user enable it. */
+int sysctl_tcp_cookie_size __read_mostly = 0;
+#else
+int sysctl_tcp_cookie_size __read_mostly = TCP_COOKIE_MAX;
+#endif
+
+
 /* Account for new data that has been sent to the network. */
 static void tcp_event_new_data_sent(struct sock *sk, struct sk_buff *skb)
 {

--------------040706050308070603060406--
