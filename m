From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net: rcu warnings in ip6fl_get_first
Date: Fri, 8 Feb 2013 01:38:29 +0000 (UTC)
Message-ID: <kf1kul$699$2@ger.gmane.org>
References: <51140154.9040901@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:33120 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751537Ab3BHBjz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Feb 2013 20:39:55 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1U3cwe-0001K7-Sl
	for netdev@vger.kernel.org; Fri, 08 Feb 2013 02:40:04 +0100
Received: from 14.205.20.175 ([14.205.20.175])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 08 Feb 2013 02:40:04 +0100
Received: from xiyou.wangcong by 14.205.20.175 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 08 Feb 2013 02:40:04 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 07 Feb 2013 at 19:32 GMT, Sasha Levin <sasha.levin@oracle.com> wrote:
> Hi guys,
>
> I got the following while fuzzing with trinity inside a KVM tools guest:
>
> [   51.680236] ===============================
> [   51.681914] [ INFO: suspicious RCU usage. ]
> [   51.683610] 3.8.0-rc6-next-20130206-sasha-00028-g83214f7-dirty #276 Tainted: G        W
> [   51.686703] -------------------------------
> [   51.688281] net/ipv6/ip6_flowlabel.c:671 suspicious rcu_dereference_check() usage!
> [   51.691345]

It should use rcu_dereference_bh()...

diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index ea42bf4..c50080f 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -65,13 +65,13 @@ static DEFINE_SPINLOCK(ip6_fl_lock);
 static DEFINE_SPINLOCK(ip6_sk_fl_lock);
 
 #define for_each_fl_rcu(hash, fl)				\
-	for (fl = rcu_dereference(fl_ht[(hash)]);		\
+	for (fl = rcu_dereference_bh(fl_ht[(hash)]);		\
 	     fl != NULL;					\
-	     fl = rcu_dereference(fl->next))
+	     fl = rcu_dereference_hb(fl->next))
 #define for_each_fl_continue_rcu(fl)				\
-	for (fl = rcu_dereference(fl->next);			\
+	for (fl = rcu_dereference_bh(fl->next);			\
 	     fl != NULL;					\
-	     fl = rcu_dereference(fl->next))
+	     fl = rcu_dereference_bh(fl->next))
 
 #define for_each_sk_fl_rcu(np, sfl)				\
 	for (sfl = rcu_dereference_bh(np->ipv6_fl_list);	\
