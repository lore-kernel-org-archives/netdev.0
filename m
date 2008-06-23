From: Patrick McHardy <kaber@trash.net>
Subject: Re: tc regression?
Date: Mon, 23 Jun 2008 15:59:18 +0200
Message-ID: <485FAC36.4040706@trash.net>
References: <485FA55A.4070107@bigtelecom.ru> <485FAAF1.6060304@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020009060706010006060802"
Cc: netdev@vger.kernel.org
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51556 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751756AbYFWN7X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 09:59:23 -0400
In-Reply-To: <485FAAF1.6060304@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020009060706010006060802
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> Badalian Vyacheslav wrote:
>> Hello all.
>>
>> Ditrib: Gentoo (i hope its not gentoo bug...)
>>
>> I try update package to "sys-apps/iproute2-2.6.25.20080417" and see 
>> that filter can't del filter...
>>
>> # tc filter show dev eth1 | grep 4:29:d1
>> filter parent 1: protocol ip pref 5 u32 fh 4:29:d1 order 209 key ht 4 
>> bkt 29 flowid 1:b7aa
>>
>> # tc filter del dev eth1 parent 1: pref 5 handle 4:29:d1 u32
>> RTNETLINK answers: Invalid argument
>> We have an error talking to the kernel
>>
>> after rollback to package"sys-apps/iproute2-2.6.24.20080108" all 
>> deleted normal...
> 
> The current iproute version uses "protocol all" by default
> if its not specified. This is actually only useful for creating
> new filters, on deletion an unset protocol is treated as wildcard.
> 
> Does this patch fix it?

Oops, buggy patch. This one should work.


--------------020009060706010006060802
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/tc/tc_filter.c b/tc/tc_filter.c
index db44dec..880b887 100644
--- a/tc/tc_filter.c
+++ b/tc/tc_filter.c
@@ -54,7 +54,7 @@ int tc_filter_modify(int cmd, unsigned flags, int argc, char **argv)
 	} req;
 	struct filter_util *q = NULL;
 	__u32 prio = 0;
-	__u32 protocol = ETH_P_ALL;
+	__u32 protocol = 0;
 	int protocol_set = 0;
 	char *fhandle = NULL;
 	char  d[16];
@@ -72,6 +72,9 @@ int tc_filter_modify(int cmd, unsigned flags, int argc, char **argv)
 	req.n.nlmsg_type = cmd;
 	req.t.tcm_family = AF_UNSPEC;
 
+	if (cmd == RTM_NEWTFILTER && flags & NLM_F_CREATE)
+		protocol = ETH_P_ALL;
+
 	while (argc > 0) {
 		if (strcmp(*argv, "dev") == 0) {
 			NEXT_ARG();

--------------020009060706010006060802--
