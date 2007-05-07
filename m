From: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
Subject: Re: [PATCH 6/6] [IPV4] SNMP: Display new statistics at
 /proc/net/snmp
Date: Mon, 7 May 2007 20:29:05 +0900
Message-ID: <20070507202905.e101d8cc.mitch@linux.vnet.ibm.com>
References: <20070427164630.3160ded5.mitch@linux.vnet.ibm.com>
	<20070430.005014.09663543.davem@davemloft.net>
	<20070502100513.033aecd7.mitch@linux.vnet.ibm.com>
	<20070503.031546.83595703.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:45269 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933158AbXEGLbA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 May 2007 07:31:00 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l47BV0Kl003280
	for <netdev@vger.kernel.org>; Mon, 7 May 2007 07:31:00 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l47BV0dL200524
	for <netdev@vger.kernel.org>; Mon, 7 May 2007 05:31:00 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l47BUxZV015855
	for <netdev@vger.kernel.org>; Mon, 7 May 2007 05:30:59 -0600
In-Reply-To: <20070503.031546.83595703.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 03 May 2007 03:15:46 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
> Date: Wed, 2 May 2007 10:05:13 +0900
> 
> > [IPV4] SNMP: Display new statistics at /proc/net/netstat
> > 
> > This displays the statistics specified in the updated IP-MIB RFC
> > (RFC4293) in /proc/net/netstat. The reason why these are not added
> > to /proc/net/snmp is that some existing utilities are developed under
> > the assumption that ipstat items in /proc/net/snmp is unchanged.
> > 
> > Signed-off-by: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
> 
> Magic constant "17" is not the best, somebody will break this
> next time this table it touched.
> 
> Why not use another sentinel, or something like that, to mark
> the entry groups?

Excuse me, but I can't catch why this magic constant is not good.
When we don't increase the number of entries in /proc/net/snmp,
I think the start number of new entries which is displayed in
/proc/net/netstat would be fixed value.

I came up with an idea in order to reduce the patch size.
But it still has a magic constant which points to the start of
new entries. If such a magic constant is not acceptable, I will
create another patch based on this. It will skip the exiting
entry by for() loop:

| @@ -348,11 +348,13 @@ static int netstat_seq_show(struct seq_f
|                                            snmp4_net_list[i].entry));
|  
|         seq_puts(seq, "\nIpExt:");
| -       for (i = IPSTATS_RFC4293_START; snmp4_ipstats_list[i].name != NULL; i++)
| +       for (i = 0; snmp4_ipstats_list[i].name != NULL; i++);
| +       for (i++; snmp4_ipstats_list[i].name != NULL; i++)
|                 seq_printf(seq, " %s", snmp4_ipstats_list[i].name);


I think it will cost a bit. Is it acceptable?



[IPV4] SNMP: Display new statistics at /proc/net/netstat

This displays the statistics specified in the updated IP-MIB RFC
(RFC4293) in /proc/net/netstat. The reason why these are not displayed
in /proc/net/snmp is some existing utilities are developed under the
assumption that ipstat items in /proc/net/snmp is unchanged.

Signed-off-by: Mitsuru Chinen <mitch@linux.vnet.ibm.com>


---

 net/ipv4/proc.c |   19 +++++++++++++++++++
 1 files changed, 19 insertions(+), 0 deletions(-)

bbc05691d2dbd8bce7d6b5ae1c0ba0074ecef5e4
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 37ab580..11dfa96 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -88,6 +88,7 @@ static const struct file_operations sock
 };
 
 /* snmp items */
+#define IPSTATS_RFC4293_START 18
 static const struct snmp_mib snmp4_ipstats_list[] = {
 	SNMP_MIB_ITEM("InReceives", IPSTATS_MIB_INRECEIVES),
 	SNMP_MIB_ITEM("InHdrErrors", IPSTATS_MIB_INHDRERRORS),
@@ -106,6 +107,14 @@ static const struct snmp_mib snmp4_ipsta
 	SNMP_MIB_ITEM("FragOKs", IPSTATS_MIB_FRAGOKS),
 	SNMP_MIB_ITEM("FragFails", IPSTATS_MIB_FRAGFAILS),
 	SNMP_MIB_ITEM("FragCreates", IPSTATS_MIB_FRAGCREATES),
+	SNMP_MIB_SENTINEL,
+	/* Following RFC4293 items are displayed in /proc/net/netstat */
+	SNMP_MIB_ITEM("InNoRoutes", IPSTATS_MIB_INNOROUTES),
+	SNMP_MIB_ITEM("InTruncatedPkts", IPSTATS_MIB_INTRUNCATEDPKTS),
+	SNMP_MIB_ITEM("InMcastPkts", IPSTATS_MIB_INMCASTPKTS),
+	SNMP_MIB_ITEM("OutMcastPkts", IPSTATS_MIB_OUTMCASTPKTS),
+	SNMP_MIB_ITEM("InBcastPkts", IPSTATS_MIB_INBCASTPKTS),
+	SNMP_MIB_ITEM("OutBcastPkts", IPSTATS_MIB_OUTBCASTPKTS),
 	SNMP_MIB_SENTINEL
 };
 
@@ -338,6 +347,16 @@ static int netstat_seq_show(struct seq_f
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

