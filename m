From: Vincent Li <vincent.mc.li@gmail.com>
Subject: RFC: configurable tcp timewait timeout sysctl kernel knob ?
Date: Fri, 19 Jul 2013 08:59:54 -0700
Message-ID: <CAK3+h2xK0UpkGofhqK3nsvR-3MLk81TxrWfpSiM6GbAgPRhrqA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f50.google.com ([209.85.219.50]:47395 "EHLO
	mail-oa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750794Ab3GSP7z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 11:59:55 -0400
Received: by mail-oa0-f50.google.com with SMTP id k7so6234037oag.23
        for <netdev@vger.kernel.org>; Fri, 19 Jul 2013 08:59:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

there is sysctl tcp_fin_timeout to tune FIN_WAIT2 timeout, I couldn't
find a sysctl to tune TIME_WAIT timeout and it is hard coded to 60
seconds, we have a situation we need to either reduce the timewait
timeout value or recycle the timewait socket that is to use
tcp_tw_recycle and tcp_tw_reuse, is a sysctl to tune timewait value
good idea or bad idea that no one bothered to write one?

I have  a dirty hack patch to do that, but I think it may be  broken
to screw something I couldn't think of.

diff --git a/include/net/tcp.h b/include/net/tcp.h
index d198005..d1df673 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -245,6 +245,7 @@ extern int sysctl_tcp_timestamps;
 extern int sysctl_tcp_window_scaling;
 extern int sysctl_tcp_sack;
 extern int sysctl_tcp_fin_timeout;
+extern int sysctl_tcp_timewait_timeout;
 extern int sysctl_tcp_keepalive_time;
 extern int sysctl_tcp_keepalive_probes;
 extern int sysctl_tcp_keepalive_intvl;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index b2c123c..15a0056 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -412,6 +412,13 @@ static struct ctl_table ipv4_table[] = {
                .mode           = 0644,
                .proc_handler   = proc_dointvec_jiffies,
        },
+       {
+               .procname       = "tcp_timewait_timeout",
+               .data           = &sysctl_tcp_timewait_timeout,
+               .maxlen         = sizeof(int),
+               .mode           = 0644,
+               .proc_handler   = proc_dointvec_jiffies,
+       },
 #ifdef CONFIG_SYN_COOKIES
        {
                .procname       = "tcp_syncookies",
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 46ed9af..6df2a9c 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -282,6 +282,7 @@
 #include <net/ll_poll.h>

 int sysctl_tcp_fin_timeout __read_mostly = TCP_FIN_TIMEOUT;
+int sysctl_tcp_timewait_timeout __read_mostly = TCP_TIMEWAIT_LEN;

 struct percpu_counter tcp_orphan_count;
 EXPORT_SYMBOL_GPL(tcp_orphan_count);
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index ab1c086..9c2befc 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -332,6 +332,10 @@ void tcp_time_wait(struct sock *sk, int state, int timeo)

                if (recycle_ok) {
                        tw->tw_timeout = rto;
+               } else if (sysctl_tcp_timewait_timeout) {
+                       tw->tw_timeout = sysctl_tcp_timewait_timeout;
+                       if (state == TCP_TIME_WAIT)
+                               timeo = sysctl_tcp_timewait_timeout;
                } else {
                        tw->tw_timeout = TCP_TIMEWAIT_LEN;
                        if (state == TCP_TIME_WAIT)
