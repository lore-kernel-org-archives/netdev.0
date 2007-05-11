From: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
Subject: Re: [PATCH 6/6] [IPV4] SNMP: Display new statistics at
 /proc/net/snmp
Date: Sat, 12 May 2007 01:10:04 +0900
Message-ID: <20070512011004.e2e3fc7b.mitch@linux.vnet.ibm.com>
References: <20070427164630.3160ded5.mitch@linux.vnet.ibm.com>
	<20070430.005014.09663543.davem@davemloft.net>
	<20070502100513.033aecd7.mitch@linux.vnet.ibm.com>
	<20070503.031546.83595703.davem@davemloft.net>
	<20070507202905.e101d8cc.mitch@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:57389 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756942AbXEKQKP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 May 2007 12:10:15 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4BGAF8N018560
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 12:10:15 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4BGAFEQ535752
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 12:10:15 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4BGAEkb006030
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 12:10:15 -0400
In-Reply-To: <20070507202905.e101d8cc.mitch@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 7 May 2007 20:29:05 +0900
Mitsuru Chinen <mitch@linux.vnet.ibm.com> wrote:

> On Thu, 03 May 2007 03:15:46 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
> > Date: Wed, 2 May 2007 10:05:13 +0900
> > 
> > > [IPV4] SNMP: Display new statistics at /proc/net/netstat
> > > 
> > > This displays the statistics specified in the updated IP-MIB RFC
> > > (RFC4293) in /proc/net/netstat. The reason why these are not added
> > > to /proc/net/snmp is that some existing utilities are developed under
> > > the assumption that ipstat items in /proc/net/snmp is unchanged.
> > > 
> > > Signed-off-by: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
> > 
> > Magic constant "17" is not the best, somebody will break this
> > next time this table it touched.
> > 
> > Why not use another sentinel, or something like that, to mark
> > the entry groups?
> 
> Excuse me, but I can't catch why this magic constant is not good.
> When we don't increase the number of entries in /proc/net/snmp,
> I think the start number of new entries which is displayed in
> /proc/net/netstat would be fixed value.

Thanks to Yoshifuji-san and USAGI guys, I'm able to remove
magic constant totally. How about this?


[IPV4] SNMP: Display new statistics at /proc/net/netstat

This displays the statistics specified in the updated IP-MIB RFC
(RFC4293) in /proc/net/netstat. The reason why these are not displayed
in /proc/net/snmp is that some existing utilities are developed under
the assumption which ipstat items in /proc/net/snmp is unchanged.

Signed-off-by: Mitsuru Chinen <mitch@linux.vnet.ibm.com>


---

 net/ipv4/proc.c |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

fc11ca885424125a2add36ab6ff29aa8e4302d4b
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 37ab580..cdbc6c1 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -109,6 +109,17 @@ static const struct snmp_mib snmp4_ipsta
 	SNMP_MIB_SENTINEL
 };
 
+/* Following RFC4293 items are displayed in /proc/net/netstat */
+static const struct snmp_mib snmp4_ipextstats_list[] = {
+	SNMP_MIB_ITEM("InNoRoutes", IPSTATS_MIB_INNOROUTES),
+	SNMP_MIB_ITEM("InTruncatedPkts", IPSTATS_MIB_INTRUNCATEDPKTS),
+	SNMP_MIB_ITEM("InMcastPkts", IPSTATS_MIB_INMCASTPKTS),
+	SNMP_MIB_ITEM("OutMcastPkts", IPSTATS_MIB_OUTMCASTPKTS),
+	SNMP_MIB_ITEM("InBcastPkts", IPSTATS_MIB_INBCASTPKTS),
+	SNMP_MIB_ITEM("OutBcastPkts", IPSTATS_MIB_OUTBCASTPKTS),
+	SNMP_MIB_SENTINEL
+};
+
 static const struct snmp_mib snmp4_icmp_list[] = {
 	SNMP_MIB_ITEM("InMsgs", ICMP_MIB_INMSGS),
 	SNMP_MIB_ITEM("InErrors", ICMP_MIB_INERRORS),
@@ -338,6 +349,16 @@ static int netstat_seq_show(struct seq_f
 			   snmp_fold_field((void **)net_statistics,
 					   snmp4_net_list[i].entry));
 
+	seq_puts(seq, "\nIpExt:");
+	for (i = 0; snmp4_ipextstats_list[i].name != NULL; i++)
+		seq_printf(seq, " %s", snmp4_ipextstats_list[i].name);
+
+	seq_puts(seq, "\nIpExt:");
+	for (i = 0; snmp4_ipextstats_list[i].name != NULL; i++)
+		seq_printf(seq, " %lu",
+			   snmp_fold_field((void **)ip_statistics,
+					   snmp4_ipextstats_list[i].entry));
+
 	seq_putc(seq, '\n');
 	return 0;
 }
-- 
1.3.3


