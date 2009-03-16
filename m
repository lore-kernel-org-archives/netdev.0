From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC v2 3/7] net: netfilter conntrack - add per-net
	functionality for SCTP protocol
Date: Mon, 16 Mar 2009 21:21:36 +0300
Message-ID: <20090316182136.GF7551@localhost>
References: <20090311205706.141086138@gmail.com> <20090311210817.384140456@gmail.com> <49BE71AF.8050200@trash.net> <20090316154620.GA7551@localhost> <49BE74CC.8060701@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, daniel.lezcano@free.fr,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	xemul@openvz.org, adobriyan@gmail.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.185]:57313 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755660AbZCPSVm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2009 14:21:42 -0400
Content-Disposition: inline
In-Reply-To: <49BE74CC.8060701@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Patrick McHardy - Mon, Mar 16, 2009 at 04:48:28PM +0100]
...
>
>> Give me some time Patrick, will try. Actually initial idea
>> of these macros was to eliminate 'possible' problems caused
>> by for (;;) form (enum could be rearranged and we will fail
>> silently).
>
> The state enums are pretty much set in stone as they're part of the
> userspace ABI.
>
>> So I guess the some 'new' form of template would
>> help (instead of current "ctrl table as a templae"). So
>> will return with new proposal. Thanks for review!
>
> Thanks.
>

After playing a bit with ctrl tables (thought about additional
mapping set or say new sysctl helper structure, or even using
extra1 member from struct ctl_table as temporary index) -- 
you were right in your first propose on this patch. Iterative
fasion is only more or less convenient here indeed :)

Patrick, take a look please on the snippet below (that is how
it looks now).
...

+static __net_init int sctp_net_init(struct net *net)
+{
+	struct sctp_net *sn;
+	int err;
+
+	sn = kmalloc(sizeof(*sn), GFP_KERNEL);
+	if (!sn)
+		return -ENOMEM;
+
+	/* default values */
+	sn->sctp_timeouts[SCTP_CONNTRACK_CLOSED]	= 10 SECS;
+	sn->sctp_timeouts[SCTP_CONNTRACK_COOKIE_WAIT]	= 3 SECS;
+	sn->sctp_timeouts[SCTP_CONNTRACK_COOKIE_ECHOED]	= 3 SECS;
+	sn->sctp_timeouts[SCTP_CONNTRACK_ESTABLISHED]	= 5 DAYS;
+	sn->sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_SENT]	= 300 SECS / 1000;
+	sn->sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_RECD]	= 300 SECS / 1000;
+	sn->sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_ACK_SENT] = 3 SECS;
+
+	err = net_assign_generic(net, sctp_net_id, sn);
+	if (err)
+		goto out;
+
+	/*
+	 * Pin per-net data to sysctl tables
+	 *
+	 * We allocate new ctrl tables from predefined templates
+	 * and then assign .data fields iteratively, we allowed
+	 * to do so since SCTP_CONNTRACK_... enum is a part of
+	 * userspace ABI and it's hardly that the enum entries
+	 * will be rearranged
+	 */
+
 #ifdef CONFIG_SYSCTL
-	.ctl_table_users	= &sctp_sysctl_table_users,
-	.ctl_table_header	= &sctp_sysctl_header,
-	.ctl_table		= sctp_sysctl_table,
+	{
+	int i;
+	err = -ENOMEM;
+	sn->sysctl_table = kmemdup(sctp_sysctl_table,
+			sizeof(sctp_sysctl_table), GFP_KERNEL);
+	if (!sn->sysctl_table)
+		goto out;
+
+	for (i = SCTP_CONNTRACK_CLOSED; i < SCTP_CONNTRACK_MAX; i++)
+		sn->sysctl_table[i - 1].data = &sn->sctp_timeouts[i];
+
+	sn->sysctl_header = register_net_sysctl_table(net,
+			nf_net_netfilter_sysctl_path, sn->sysctl_table);
+	if (!sn->sysctl_header)
+		goto out_free;
+
+#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
+	sn->compat_sysctl_table = kmemdup(sctp_compat_sysctl_table,
+			sizeof(sctp_compat_sysctl_table), GFP_KERNEL);
+	if (!sn->compat_sysctl_table)
+		goto out_sysctl;
+
+	for (i = SCTP_CONNTRACK_CLOSED; i < SCTP_CONNTRACK_MAX; i++)
+		sn->compat_sysctl_table[err - 1].data = &sn->sctp_timeouts[i];
+
+	sn->compat_sysctl_header = register_net_sysctl_table(net,
+			nf_net_ipv4_netfilter_sysctl_path, sn->compat_sysctl_table);
+	if (!sn->compat_sysctl_header)
+		goto out_free_compat;
+#endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
+	}
+#endif /* CONFIG_SYSCTL */
+
+	return 0;
+
+#ifdef CONFIG_SYSCTL
+
+#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
+out_free_compat:
+	kfree(sn->compat_sysctl_table);
+#endif
+out_sysctl:
+	unregister_net_sysctl_table(sn->sysctl_header);
+out_free:
+	kfree(sn->sysctl_table);
+#endif
+
+out:
+	kfree(sn);
+	return err;
+}
...

If such an approach is fine -- I will fix the TCP proto
as well. Btw, this two patches (SCTP and TCP) are only
involved in such a modification, are there some problems
with patches for UDP, UDPlite and ICMP protos?

	- Cyrill -
