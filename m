From: Larry Baker <baker@usgs.gov>
Subject: Re: decnet: /proc/sys/net/decnet sysctl entries disappear
Date: Wed, 13 Feb 2013 16:50:38 -0800
Message-ID: <5AFC1880-0AAB-4255-B77C-BF55534DF9A0@usgs.gov>
References: <FAAC90D7-8126-44CA-AACF-A5F8237C1A8E@usgs.gov> <456F0392-03CE-4207-A092-F890D530B746@usgs.gov> <877gmca8qb.fsf@xmission.com>
Mime-Version: 1.0 (Apple Message framework v1085)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org,
	decnet list <linux-decnet-user@lists.sourceforge.net>
To: Eric Biederman <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gscamnlh01.wr.usgs.gov ([130.118.9.68]:23080 "EHLO
	gscamnlh01.wr.usgs.gov" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753083Ab3BNAuk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2013 19:50:40 -0500
In-Reply-To: <877gmca8qb.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric,

(Sorry for the re-send.  I had to make up a new e-mail address book entry for you without your middle initial to pass through the vger.kernel.org e-mail filters.  Apple Mail shows me the enclosing quotes, but apparently doesn't actually insert them in the SMTP text.)

FYI.  My original post to netdev for this problem is at http://www.spinics.net/lists/netdev/msg225990.html.  Since then, I have focused on reporting and patching only the problem with the disappearing sysctl entries.  My follow-up post with the problem description is at http://www.spinics.net/lists/netdev/msg226123.html.

On 13 Feb 2013, at 1:01 AM, Eric W. Biederman wrote:

> If you send me just the sysctl bits I will be happy to
> double check them and forward them to stable@vger.kernel.org.  Feel free
> to Cc netdev.  For at least the sysctl bits having them pass through me
> and getting my quick review and signed-off-by should help a little
> getting them backported.

Below is my stab at a proper patch for this problem for the 2.6.32.60 stable kernel.  This is the kernel series used by the latest CentOS/Red Hat 6.3.

scripts/checkpatch.pl warns about a couple lines over 80 characters (code motion and the banner), and gives one error:

ERROR: do not initialise statics to 0 or NULL
#53: FILE: net/decnet/dn_dev.c:173:
+static struct ctl_table_header *dn_conf_path = NULL;

I followed the same practice as the code in net/decnet/sysctl_net_decnet.c:

static struct ctl_table_header *dn_table_header = NULL;

I leave it to you to decide if that is a concern.

> For your other changes I can't tell if they are clean-ups or enhancments
> or just unneeded (like updating the banner string). As a cleanup it
> would probably make sense to just delete that silly banner string.

Lots of kernel modules have banner strings.  I find them informative.  I think the version should to be updated when (substantive?) changes are made.

> There are question I have when looking at your patches:
> Does dn_hiord_addr to -> dh_hiord make a difference?
> What is the purpose of all of the code motion?
> Will anyone besides you use the new debug option?  Or would we better to
> just forget that change.

Maybe only your code motion question still applies?  The code motion is required to create the sysctl entries in the correct order:

. Static executor node (host) entries in /proc/sys/net/decnet
. Static empty path entry /proc/sys/net/decnet/conf
. Static template network device entries in /proc/sys/net/decnet/conf/<type>
. Dynamic active DECnet device entries in /proc/sys/net/decnet/conf/<dev-name>

The entries in /proc/sys/net/decnet are created in sysctl_net_decnet.c; the entries in /proc/sys/net/decnet/conf are created in dn_dev.c.  The workaround only works when the empty path entry is created before the entries in /proc/sys/net/decnet.  Thus the code rearrangement.  Even when the workaround can be removed (3.4 and later), I think this is more rational behavior.

> Eric

Thanks again,

Larry Baker
US Geological Survey
650-329-5608
baker@usgs.gov

----------

This is the patch for stable kernel 2.6.32.60.  I tested this on a CentOS 6.3 x86_64 system, which uses a 2.6.32+ kernel.  I installed the 2.6.32.60 kernel, verified the problem in the original decnet module, patched the decnet source, and verified the patched module fixes the problem.

I don't know what is a good subject line.  It is supposed to say "what" and "why".  Should it tie in to the same patches Al made for net/core and net/ipv6?  (Add a reference to those patches in the message body?)  Should it mention the aberrant behavior being fixed?

I tried to pay attention to separating the lines for the changelog from the rest of the description.

Subject line:

Subject: [PATCH] decnet: Fix for sysctl rewrite (stable kernel 2.6.32.x)

Message body:

From: Larry Baker <baker@usgs.gov>

Fixes the problem of disappearing /proc/sys/net/decnet sysctl entries reported in http://www.spinics.net/lists/netdev/msg226123.html.  Applies the same workaround used in net/core/sysctl_net_core.c and net/ipv6/sysctl_net_ipv6.c.

The problem first appeared in kernel 2.6.27.  The later rewrite of sysctl in kernel 3.4 restored the previous behavior and eliminated the need for this workaround. 

Signed-off-by: Larry Baker <baker@usgs.gov>
---

The workaround is to register an empty sysctl path entry before registering any entries beneath it.  For example, the same workaround appears in sysctl_core_init() in net/core/sysctl_net_core.c and ipv6_static_sysctl_register() in net/ipv6/sysctl_net_ipv6.c.

The additional code motion is required to create the sysctl entries in the correct order:

. Static executor node (host) entries in /proc/sys/net/decnet
. Static empty path entry /proc/sys/net/decnet/conf
. Static template network device entries in /proc/sys/net/decnet/conf/<type>
. Dynamic active DECnet device entries in /proc/sys/net/decnet/conf/<dev-name>

The entries in /proc/sys/net/decnet are created in sysctl_net_decnet.c; the entries in /proc/sys/net/decnet/conf are created in dn_dev.c.  The workaround only works when the empty path entry is created before the entries in /proc/sys/net/decnet.  The code rearrangement accomplishes this.

--- original/net/decnet/af_decnet.c
+++ patched/net/decnet/af_decnet.c
@@ -2360,7 +2360,7 @@ MODULE_AUTHOR("Linux DECnet Project Team
MODULE_LICENSE("GPL");
MODULE_ALIAS_NETPROTO(PF_DECnet);

-static char banner[] __initdata = KERN_INFO "NET4: DECnet for Linux: V.2.5.68s (C) 1995-2003 Linux DECnet Project Team\n";
+static char banner[] __initdata = KERN_INFO "DECnet: DECnet for Linux: V.2.6.32 (C) 1995-2013 Linux DECnet Project Team\n";

static int __init decnet_init(void)
{
@@ -2372,6 +2372,8 @@ static int __init decnet_init(void)
	if (rc != 0)
		goto out;

+	dn_register_sysctl();
+
	dn_neigh_init();
	dn_dev_init();
	dn_route_init();
@@ -2382,7 +2384,6 @@ static int __init decnet_init(void)
	register_netdevice_notifier(&dn_dev_notifier);

	proc_net_fops_create(&init_net, "decnet", S_IRUGO, &dn_socket_seq_fops);
-	dn_register_sysctl();
out:
	return rc;

@@ -2401,8 +2402,6 @@ static void __exit decnet_exit(void)
	rtnl_unregister_all(PF_DECnet);
	dev_remove_pack(&dn_dix_packet_type);

-	dn_unregister_sysctl();
-
	unregister_netdevice_notifier(&dn_dev_notifier);

	dn_route_cleanup();
@@ -2410,6 +2409,8 @@ static void __exit decnet_exit(void)
	dn_neigh_cleanup();
	dn_fib_cleanup();

+	dn_unregister_sysctl();
+
	proc_net_remove(&init_net, "decnet");

	proto_unregister(&dn_proto);
--- original/net/decnet/dn_dev.c
+++ patched/net/decnet/dn_dev.c
@@ -170,6 +170,8 @@ static int dn_forwarding_sysctl(ctl_tabl
			void __user *oldval, size_t __user *oldlenp,
			void __user *newval, size_t newlen);

+static struct ctl_table_header *dn_conf_path = NULL;
+
static struct dn_dev_sysctl_table {
	struct ctl_table_header *sysctl_header;
	ctl_table dn_dev_vars[5];
@@ -1436,6 +1438,14 @@ MODULE_PARM_DESC(addr, "The DECnet addre

void __init dn_dev_init(void)
{
+	struct ctl_path dn_conf[] = {
+		{ .procname = "net", .ctl_name = CTL_NET, },
+		{ .procname = "decnet", .ctl_name = NET_DECNET, },
+		{ .procname = "conf", .ctl_name = NET_DECNET_CONF, },
+		{ },
+	};
+	static ctl_table empty[1];
+
	if (addr[0] > 63 || addr[0] < 0) {
		printk(KERN_ERR "DECnet: Area must be between 0 and 63");
		return;
@@ -1448,34 +1458,36 @@ void __init dn_dev_init(void)

	decnet_address = cpu_to_le16((addr[0] << 10) | addr[1]);

-	dn_dev_devices_on();
-
-	rtnl_register(PF_DECnet, RTM_NEWADDR, dn_nl_newaddr, NULL);
-	rtnl_register(PF_DECnet, RTM_DELADDR, dn_nl_deladdr, NULL);
-	rtnl_register(PF_DECnet, RTM_GETADDR, NULL, dn_nl_dump_ifaddr);
-
-	proc_net_fops_create(&init_net, "decnet_dev", S_IRUGO, &dn_dev_seq_fops);
-
#ifdef CONFIG_SYSCTL
+	dn_conf_path = register_sysctl_paths(dn_conf, empty);
	{
		int i;
		for(i = 0; i < DN_DEV_LIST_SIZE; i++)
			dn_dev_sysctl_register(NULL, &dn_dev_list[i]);
	}
#endif /* CONFIG_SYSCTL */
+
+	dn_dev_devices_on();
+
+	rtnl_register(PF_DECnet, RTM_NEWADDR, dn_nl_newaddr, NULL);
+	rtnl_register(PF_DECnet, RTM_DELADDR, dn_nl_deladdr, NULL);
+	rtnl_register(PF_DECnet, RTM_GETADDR, NULL, dn_nl_dump_ifaddr);
+
+	proc_net_fops_create(&init_net, "decnet_dev", S_IRUGO, &dn_dev_seq_fops);
}

void __exit dn_dev_cleanup(void)
{
+	proc_net_remove(&init_net, "decnet_dev");
+
+	dn_dev_devices_off();
+
#ifdef CONFIG_SYSCTL
	{
		int i;
		for(i = 0; i < DN_DEV_LIST_SIZE; i++)
			dn_dev_sysctl_unregister(&dn_dev_list[i]);
	}
+	unregister_sysctl_table(dn_conf_path);
#endif /* CONFIG_SYSCTL */
-
-	proc_net_remove(&init_net, "decnet_dev");
-
-	dn_dev_devices_off();
}
