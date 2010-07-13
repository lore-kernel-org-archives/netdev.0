From: Dan Carpenter <error27@gmail.com>
Subject: [patch] net/sched: potential data corruption
Date: Tue, 13 Jul 2010 15:21:52 +0200
Message-ID: <20100713132152.GL5658@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	matthew@wil.cx
To: Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:37793 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756615Ab0GMNX3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jul 2010 09:23:29 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The reset_policy() does:
        memset(d->tcfd_defdata, 0, SIMP_MAX_DATA);
        strlcpy(d->tcfd_defdata, defdata, SIMP_MAX_DATA);

In the original code, the size of d->tcfd_defdata wasn't fixed and if
strlen(defdata) was less than 31, reset_policy() would cause memory
corruption.

Please Note:  The original alloc_defdata() assumes defdata is 32
characters and a NUL terminator while reset_policy() assumes defdata is
31 characters and a NUL.  This patch updates alloc_defdata() to match
reset_policy() (ie a shorter string).  I'm not very familiar with this
code so please review carefully.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
index 1b4bc69..4a1d640 100644
--- a/net/sched/act_simple.c
+++ b/net/sched/act_simple.c
@@ -73,10 +73,10 @@ static int tcf_simp_release(struct tcf_defact *d, int bind)
 
 static int alloc_defdata(struct tcf_defact *d, char *defdata)
 {
-	d->tcfd_defdata = kstrndup(defdata, SIMP_MAX_DATA, GFP_KERNEL);
+	d->tcfd_defdata = kzalloc(SIMP_MAX_DATA, GFP_KERNEL);
 	if (unlikely(!d->tcfd_defdata))
 		return -ENOMEM;
-
+	strlcpy(d->tcfd_defdata, defdata, SIMP_MAX_DATA);
 	return 0;
 }
 
