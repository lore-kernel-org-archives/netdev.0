From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Subject: [PATCH 9/10][AX25]: Use kmemdup
Date: Fri, 17 Nov 2006 13:19:51 -0200
Message-ID: <20061117151951.GJ17958@mandriva.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.mandriva.com ([212.85.150.183]:2703 "EHLO mx1.mandriva.com")
	by vger.kernel.org with ESMTP id S1755715AbWKQPUF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 10:20:05 -0500
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Code diff stats:

[acme@newtoy net-2.6.20]$ codiff /tmp/ax25.ko.before /tmp/ax25.ko.after
/pub/scm/linux/kernel/git/acme/net-2.6.20/net/ax25/ax25_out.c:
  ax25_send_frame |   -8
 1 function changed, 8 bytes removed

/pub/scm/linux/kernel/git/acme/net-2.6.20/net/ax25/ax25_route.c:
  ax25_rt_autobind |  -15
 1 function changed, 15 bytes removed

/pub/scm/linux/kernel/git/acme/net-2.6.20/net/ax25/af_ax25.c:
  ax25_make_new |  -33
 1 function changed, 33 bytes removed

/pub/scm/linux/kernel/git/acme/net-2.6.20/net/ax25/sysctl_net_ax25.c:
  ax25_register_sysctl |  -21
 1 function changed, 21 bytes removed

/tmp/ax25.ko.after:
 4 functions changed, 77 bytes removed
[acme@newtoy net-2.6.20]$

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/ax25/af_ax25.c         |    6 +++---
 net/ax25/ax25_out.c        |    4 ++--
 net/ax25/ax25_route.c      |    5 +++--
 net/ax25/sysctl_net_ax25.c |    5 +++--
 4 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index 000695c..6cabf6d 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -906,13 +906,13 @@ struct sock *ax25_make_new(struct sock *
 	ax25->source_addr = oax25->source_addr;
 
 	if (oax25->digipeat != NULL) {
-		if ((ax25->digipeat = kmalloc(sizeof(ax25_digi), GFP_ATOMIC)) == NULL) {
+		ax25->digipeat = kmemdup(oax25->digipeat, sizeof(ax25_digi),
+					 GFP_ATOMIC);
+		if (ax25->digipeat == NULL) {
 			sk_free(sk);
 			ax25_cb_put(ax25);
 			return NULL;
 		}
-
-		memcpy(ax25->digipeat, oax25->digipeat, sizeof(ax25_digi));
 	}
 
 	sk->sk_protinfo = ax25;
diff --git a/net/ax25/ax25_out.c b/net/ax25/ax25_out.c
index d7736e5..f84047d 100644
--- a/net/ax25/ax25_out.c
+++ b/net/ax25/ax25_out.c
@@ -70,11 +70,11 @@ ax25_cb *ax25_send_frame(struct sk_buff 
 	ax25->dest_addr   = *dest;
 
 	if (digi != NULL) {
-		if ((ax25->digipeat = kmalloc(sizeof(ax25_digi), GFP_ATOMIC)) == NULL) {
+		ax25->digipeat = kmemdup(digi, sizeof(*digi), GFP_ATOMIC);
+		if (ax25->digipeat == NULL) {
 			ax25_cb_put(ax25);
 			return NULL;
 		}
-		memcpy(ax25->digipeat, digi, sizeof(ax25_digi));
 	}
 
 	switch (ax25->ax25_dev->values[AX25_VALUES_PROTOCOL]) {
diff --git a/net/ax25/ax25_route.c b/net/ax25/ax25_route.c
index 51b7bda..8580356 100644
--- a/net/ax25/ax25_route.c
+++ b/net/ax25/ax25_route.c
@@ -432,11 +432,12 @@ int ax25_rt_autobind(ax25_cb *ax25, ax25
 	}
 
 	if (ax25_rt->digipeat != NULL) {
-		if ((ax25->digipeat = kmalloc(sizeof(ax25_digi), GFP_ATOMIC)) == NULL) {
+		ax25->digipeat = kmemdup(ax25_rt->digipeat, sizeof(ax25_digi),
+					 GFP_ATOMIC);
+		if (ax25->digipeat == NULL) {
 			err = -ENOMEM;
 			goto put;
 		}
-		memcpy(ax25->digipeat, ax25_rt->digipeat, sizeof(ax25_digi));
 		ax25_adjust_path(addr, ax25->digipeat);
 	}
 
diff --git a/net/ax25/sysctl_net_ax25.c b/net/ax25/sysctl_net_ax25.c
index 867d425..d23a27f 100644
--- a/net/ax25/sysctl_net_ax25.c
+++ b/net/ax25/sysctl_net_ax25.c
@@ -209,7 +209,9 @@ void ax25_register_sysctl(void)
 	}
 
 	for (n = 0, ax25_dev = ax25_dev_list; ax25_dev != NULL; ax25_dev = ax25_dev->next) {
-		ctl_table *child = kmalloc(sizeof(ax25_param_table), GFP_ATOMIC);
+		struct ctl_table *child = kmemdup(ax25_param_table,
+						  sizeof(ax25_param_table),
+						  GFP_ATOMIC);
 		if (!child) {
 			while (n--)
 				kfree(ax25_table[n].child);
@@ -217,7 +219,6 @@ void ax25_register_sysctl(void)
 			spin_unlock_bh(&ax25_dev_lock);
 			return;
 		}
-		memcpy(child, ax25_param_table, sizeof(ax25_param_table));
 		ax25_table[n].child = ax25_dev->systable = child;
 		ax25_table[n].ctl_name     = n + 1;
 		ax25_table[n].procname     = ax25_dev->dev->name;
-- 
1.4.2.1.g3d5c

