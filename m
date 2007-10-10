From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH] ip_local_port_range low > high check
Date: Wed, 10 Oct 2007 18:15:30 +0400
Message-ID: <20071010141530.GA10661@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: aarapov@redhat.com, netdev@vger.kernel.org, den@openvz.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:61151 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751037AbXJJOOF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2007 10:14:05 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds check low > high for ip_local_port_range.

Signed-off-by: Denis V. Lunev <den@openvz.org>

diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 53ef0f4..686c0a4 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -186,6 +186,61 @@ static int strategy_allowed_congestion_control(ctl_table *table, int __user *nam
 
 }
 
+static int proc_port_range(ctl_table *table, int write, struct file *filp,
+		    void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	int ret;
+	ctl_table tbl = {
+		.maxlen		= sizeof(sysctl_local_port_range),
+		.extra1		= ip_local_port_range_min,
+		.extra2		= ip_local_port_range_max
+	};
+	tbl.data = kmalloc(tbl.maxlen, GFP_USER);
+	if (tbl.data == NULL)
+		return -ENOMEM;
+	memcpy(tbl.data, sysctl_local_port_range, tbl.maxlen);
+
+	ret = proc_dointvec_minmax(&tbl, write, filp, buffer, lenp, ppos);
+	if (write && ret == 0) {
+		int *data = (int *)tbl.data;
+		if (data[0] > data[1])
+			ret = -EINVAL;
+		else
+			memcpy(sysctl_local_port_range, data,
+					sizeof(sysctl_local_port_range));
+	}
+	kfree(tbl.data);
+	return ret;
+}
+
+int sysctl_strategy_port_range(ctl_table *table, int __user *name, int nlen,
+		void __user *oldval, size_t __user *oldlenp,
+		void __user *newval, size_t newlen)
+{
+	int ret;
+	ctl_table tbl = {
+		.maxlen		= sizeof(sysctl_local_port_range),
+		.extra1		= ip_local_port_range_min,
+		.extra2		= ip_local_port_range_max
+	};
+	tbl.data = kmalloc(tbl.maxlen, GFP_USER);
+	if (tbl.data == NULL)
+		return -ENOMEM;
+	memcpy(tbl.data, sysctl_local_port_range, tbl.maxlen);
+
+	ret = sysctl_intvec(&tbl, name, nlen, oldval, oldlenp, newval, newlen);
+	if (ret == 0 && newval && newlen) {
+		int *data = (int *)tbl.data;
+		if (data[0] > data[1])
+			ret = -EINVAL;
+		else
+			memcpy(sysctl_local_port_range, data,
+					sizeof(sysctl_local_port_range));
+	}
+	kfree(tbl.data);
+	return ret;
+}
+
 ctl_table ipv4_table[] = {
 	{
 		.ctl_name	= NET_IPV4_TCP_TIMESTAMPS,
@@ -427,8 +482,8 @@ ctl_table ipv4_table[] = {
 		.data		= &sysctl_local_port_range,
 		.maxlen		= sizeof(sysctl_local_port_range),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= &proc_port_range,
+		.strategy	= &sysctl_strategy_port_range,
 		.extra1		= ip_local_port_range_min,
 		.extra2		= ip_local_port_range_max
 	},
Warning: 1 path touched but unmodified. Consider running git-status.
