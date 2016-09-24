From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH 4/7] ipv6 addrconf: add new sysctl 'router_solicitation_max_interval'
Date: Sat, 24 Sep 2016 09:05:06 -0700
Message-ID: <1474733109-18355-4-git-send-email-zenczykowski@gmail.com>
References: <CAHo-Oozocj2rzY8hTTr1f3roMy9iz50j6X=dBG5qmz4B_LFAFQ@mail.gmail.com>
 <1474733109-18355-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Erik Kline <ek@google.com>,
        Lorenzo Colitti <lorenzo@google.com>
To: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35921 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757775AbcIXQGE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 24 Sep 2016 12:06:04 -0400
Received: by mail-pf0-f195.google.com with SMTP id n24so6707089pfb.3
        for <netdev@vger.kernel.org>; Sat, 24 Sep 2016 09:06:03 -0700 (PDT)
In-Reply-To: <1474733109-18355-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maciej Żenczykowski <maze@google.com>

Accessible via:
  /proc/sys/net/ipv6/conf/*/router_solicitation_max_interval

For now we default it to the same value as the normal interval.

Signed-off-by: Maciej Żenczykowski <maze@google.com>
---
 include/linux/ipv6.h      |  1 +
 include/net/addrconf.h    |  1 +
 include/uapi/linux/ipv6.h |  1 +
 net/ipv6/addrconf.c       | 11 +++++++++++
 4 files changed, 14 insertions(+)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index c6dbcd84a2c7..7e9a789be5e0 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -18,6 +18,7 @@ struct ipv6_devconf {
 	__s32		dad_transmits;
 	__s32		rtr_solicits;
 	__s32		rtr_solicit_interval;
+	__s32		rtr_solicit_max_interval;
 	__s32		rtr_solicit_delay;
 	__s32		force_mld_version;
 	__s32		mldv1_unsolicited_report_interval;
diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 9826d3a9464c..275e5af4c2f4 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -3,6 +3,7 @@
 
 #define MAX_RTR_SOLICITATIONS		3
 #define RTR_SOLICITATION_INTERVAL	(4*HZ)
+#define RTR_SOLICITATION_MAX_INTERVAL	(4*HZ)
 
 #define MIN_VALID_LIFETIME		(2*3600)	/* 2 hours */
 
diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
index 395876060f50..8c2772340c3f 100644
--- a/include/uapi/linux/ipv6.h
+++ b/include/uapi/linux/ipv6.h
@@ -177,6 +177,7 @@ enum {
 	DEVCONF_DROP_UNICAST_IN_L2_MULTICAST,
 	DEVCONF_DROP_UNSOLICITED_NA,
 	DEVCONF_KEEP_ADDR_ON_DOWN,
+	DEVCONF_RTR_SOLICIT_MAX_INTERVAL,
 	DEVCONF_MAX
 };
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 6c63bf06fbcf..255be34cdbce 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -187,6 +187,7 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
 	.dad_transmits		= 1,
 	.rtr_solicits		= MAX_RTR_SOLICITATIONS,
 	.rtr_solicit_interval	= RTR_SOLICITATION_INTERVAL,
+	.rtr_solicit_max_interval = RTR_SOLICITATION_MAX_INTERVAL,
 	.rtr_solicit_delay	= MAX_RTR_SOLICITATION_DELAY,
 	.use_tempaddr		= 0,
 	.temp_valid_lft		= TEMP_VALID_LIFETIME,
@@ -232,6 +233,7 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 	.dad_transmits		= 1,
 	.rtr_solicits		= MAX_RTR_SOLICITATIONS,
 	.rtr_solicit_interval	= RTR_SOLICITATION_INTERVAL,
+	.rtr_solicit_max_interval = RTR_SOLICITATION_MAX_INTERVAL,
 	.rtr_solicit_delay	= MAX_RTR_SOLICITATION_DELAY,
 	.use_tempaddr		= 0,
 	.temp_valid_lft		= TEMP_VALID_LIFETIME,
@@ -4891,6 +4893,8 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 	array[DEVCONF_RTR_SOLICITS] = cnf->rtr_solicits;
 	array[DEVCONF_RTR_SOLICIT_INTERVAL] =
 		jiffies_to_msecs(cnf->rtr_solicit_interval);
+	array[DEVCONF_RTR_SOLICIT_MAX_INTERVAL] =
+		jiffies_to_msecs(cnf->rtr_solicit_max_interval);
 	array[DEVCONF_RTR_SOLICIT_DELAY] =
 		jiffies_to_msecs(cnf->rtr_solicit_delay);
 	array[DEVCONF_FORCE_MLD_VERSION] = cnf->force_mld_version;
@@ -5771,6 +5775,13 @@ static const struct ctl_table addrconf_sysctl[] = {
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
+		.procname	= "router_solicitation_max_interval",
+		.data		= &ipv6_devconf.rtr_solicit_max_interval,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+	},
+	{
 		.procname	= "router_solicitation_delay",
 		.data		= &ipv6_devconf.rtr_solicit_delay,
 		.maxlen		= sizeof(int),
-- 
2.8.0.rc3.226.g39d4020
