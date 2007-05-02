From: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
Subject: Re: [PATCH 6/6] [IPV4] SNMP: Display new statistics at
 /proc/net/snmp
Date: Wed, 2 May 2007 10:05:13 +0900
Message-ID: <20070502100513.033aecd7.mitch@linux.vnet.ibm.com>
References: <20070417200944.bd82ded2.mitch@linux.vnet.ibm.com>
	<20070417201436.ab8f3f7a.mitch@linux.vnet.ibm.com>
	<20070427164630.3160ded5.mitch@linux.vnet.ibm.com>
	<20070430.005014.09663543.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:45356 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946095AbXEBBFW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2007 21:05:22 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4215L89012715
	for <netdev@vger.kernel.org>; Tue, 1 May 2007 21:05:21 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4215LDj156704
	for <netdev@vger.kernel.org>; Tue, 1 May 2007 19:05:21 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4215LQY021157
	for <netdev@vger.kernel.org>; Tue, 1 May 2007 19:05:21 -0600
In-Reply-To: <20070430.005014.09663543.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 30 Apr 2007 00:50:14 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
> Date: Fri, 27 Apr 2007 16:46:30 +0900
> 
> > On Tue, 17 Apr 2007 20:14:36 +0900
> > Mitsuru Chinen <mitch@linux.vnet.ibm.com> wrote:
> > 
> > > This displays the statistics specified in the updated IP-MIB RFC
> > > (RFC4293) at /proc/net/snmp. As new statistics are placed as the
> > > last elements, this change wouldn't affect netstat, net-snmp, etc.
> > 
> > I'm sorry. I found adding new entries to /proc/net/snmp affects
> > net-snmp. I'm ashamed of my inadequate investigation.
> > 
> > However the other patches to support new statistics will be useful.
> > Could you pick up 1st to 5th patches?
> 
> You could display them on a new line of /proc/net/netstat, which
> we currently use to display extensions to the TCP snmp variables.
> 
> It is just one idea.

Thanks for your proposal! I created a patch based on your idea.
How about this?


[IPV4] SNMP: Display new statistics at /proc/net/netstat

This displays the statistics specified in the updated IP-MIB RFC
(RFC4293) in /proc/net/netstat. The reason why these are not added
to /proc/net/snmp is that some existing utilities are developed under
the assumption that ipstat items in /proc/net/snmp is unchanged.

Signed-off-by: Mitsuru Chinen <mitch@linux.vnet.ibm.com>


---

 net/ipv4/proc.c |   22 ++++++++++++++++++++--
 1 files changed, 20 insertions(+), 2 deletions(-)

7d86d2fc56dee38e18b4c8b3d2dc15d7d27f8a09
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 37ab580..38f24f9 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -88,6 +88,7 @@ static const struct file_operations sock
 };
 
 /* snmp items */
+#define IPSTATS_RFC4293_START 17
 static const struct snmp_mib snmp4_ipstats_list[] = {
 	SNMP_MIB_ITEM("InReceives", IPSTATS_MIB_INRECEIVES),
 	SNMP_MIB_ITEM("InHdrErrors", IPSTATS_MIB_INHDRERRORS),
@@ -106,6 +107,13 @@ static const struct snmp_mib snmp4_ipsta
 	SNMP_MIB_ITEM("FragOKs", IPSTATS_MIB_FRAGOKS),
 	SNMP_MIB_ITEM("FragFails", IPSTATS_MIB_FRAGFAILS),
 	SNMP_MIB_ITEM("FragCreates", IPSTATS_MIB_FRAGCREATES),
+	/* Following RFC4293 items are displayed in /proc/net/netstat */
+	SNMP_MIB_ITEM("InNoRoutes", IPSTATS_MIB_INNOROUTES),
+	SNMP_MIB_ITEM("InTruncatedPkts", IPSTATS_MIB_INTRUNCATEDPKTS),
+	SNMP_MIB_ITEM("InMcastPkts", IPSTATS_MIB_INMCASTPKTS),
+	SNMP_MIB_ITEM("OutMcastPkts", IPSTATS_MIB_OUTMCASTPKTS),
+	SNMP_MIB_ITEM("InBcastPkts", IPSTATS_MIB_INBCASTPKTS),
+	SNMP_MIB_ITEM("OutBcastPkts", IPSTATS_MIB_OUTBCASTPKTS),
 	SNMP_MIB_SENTINEL
 };
 
@@ -245,13 +253,13 @@ static int snmp_seq_show(struct seq_file
 
 	seq_puts(seq, "Ip: Forwarding DefaultTTL");
 
-	for (i = 0; snmp4_ipstats_list[i].name != NULL; i++)
+	for (i = 0; i < IPSTATS_RFC4293_START; i++)
 		seq_printf(seq, " %s", snmp4_ipstats_list[i].name);
 
 	seq_printf(seq, "\nIp: %d %d",
 			ipv4_devconf.forwarding ? 1 : 2, sysctl_ip_default_ttl);
 
-	for (i = 0; snmp4_ipstats_list[i].name != NULL; i++)
+	for (i = 0; i < IPSTATS_RFC4293_START; i++)
 		seq_printf(seq, " %lu",
 			   snmp_fold_field((void **)ip_statistics,
 					   snmp4_ipstats_list[i].entry));
@@ -338,6 +346,16 @@ static int netstat_seq_show(struct seq_f
 			   snmp_fold_field((void **)net_statistics,
 					   snmp4_net_list[i].entry));
 
+	seq_puts(seq, "\nIpExt:");
+	for (i = IPSTATS_RFC4293_START; snmp4_ipstats_list[i].name != NULL; i++)
+		seq_printf(seq, " %s", snmp4_ipstats_list[i].name);
+
+	seq_puts(seq, "\nIpExt:");
+	for (i = IPSTATS_RFC4293_START; snmp4_ipstats_list[i].name != NULL; i++)
+		seq_printf(seq, " %lu",
+			   snmp_fold_field((void **)ip_statistics,
+					   snmp4_ipstats_list[i].entry));
+
 	seq_putc(seq, '\n');
 	return 0;
 }
-- 
1.3.3

