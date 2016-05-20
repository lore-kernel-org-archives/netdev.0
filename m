From: Mateusz Bajorski <mateusz.bajorski@nokia.com>
Subject: ip rule duplicates
Date: Fri, 20 May 2016 14:54:54 +0200
Message-ID: <573F091E.9050205@nokia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="------------000107050001000901070705"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0111.outbound.protection.outlook.com ([157.55.234.111]:44843
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754743AbcETQ0H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 May 2016 12:26:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--------------000107050001000901070705
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

When we add the same rule again with flag NLM_F_EXCL we expect that we 
receive error:
RTNETLINK answers: File exists
This behaviour is already in ip routing part.

I have noticed that iproute2 when adds new rule it attach flag 
NLM_F_EXCL to call.
(see 
http://git.kernel.org/cgit/linux/kernel/git/shemminger/iproute2.git/tree/ip/iprule.c#n334)

Next thing what I found is that this flag is not handled from kernel side.

I implemented this feature and I tested this with qemu x86 on:
linux-4.5.4
linux (git)
linux-stable (git)
Tested with ipv4 and ipv6.

current behaviour with ipv4:
localhost ~ # ip rule
0: from all lookup local
32766: from all lookup main
32767: from all lookup default
localhost ~ # ip rule add from 10.46.177.97 lookup 104 pref 1005
localhost ~ # ip rule add from 10.46.177.97 lookup 104 pref 1005
localhost ~ # ip rule
0: from all lookup local
1005: from 10.46.177.97 lookup 104
1005: from 10.46.177.97 lookup 104
32766: from all lookup main
32767: from all lookup default

expected behavior after patch:
localhost ~ # ip rule
0:    from all lookup local
32766:    from all lookup main
32767:    from all lookup default
localhost ~ # ip rule add from 10.46.177.97 lookup 104 pref 1005
localhost ~ # ip rule add from 10.46.177.97 lookup 104 pref 1005
RTNETLINK answers: File exists
localhost ~ # ip rule
0:    from all lookup local
1005:    from 10.46.177.97 lookup 104
32766:    from all lookup main
32767:    from all lookup default


There was already topic regarding this but I don't see any changes 
merged and problem still occurs.
(see http://marc.info/?l=linux-netdev&m=113577886110391&w=2)

-- 

Best regards,

Mateusz Bajorski

--------------000107050001000901070705
Content-Type: text/x-patch;
	name="0001-Added-NLM_F_EXCL-support-to-fib_nl_newrule.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="0001-Added-NLM_F_EXCL-support-to-fib_nl_newrule.patch"

>From 9c3f80dceec414ff31d0c38d0107dec279fc9894 Mon Sep 17 00:00:00 2001
From: Mateusz Bajorski <mateusz.bajorski@nokia.com>
Date: Fri, 20 May 2016 14:29:56 +0200
Subject: [PATCH] Added NLM_F_EXCL support to fib_nl_newrule

Signed-off-by: Mateusz Bajorski <mateusz.bajorski@nokia.com>
---
 net/core/fib_rules.c | 41 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 41 insertions(+)

diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 840aceb..c1bc07cd 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -291,6 +291,47 @@ static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh)
 	if (err < 0)
 		goto errout;
 
+	if (nlh->nlmsg_flags & NLM_F_EXCL) {
+		list_for_each_entry(rule, &ops->rules_list, list) {
+			if (frh->action && (frh->action != rule->action))
+				continue;
+
+			if (frh_get_table(frh, tb) &&
+				(frh_get_table(frh, tb) != rule->table))
+				continue;
+
+			if (tb[FRA_PRIORITY] &&
+				(rule->pref != nla_get_u32(tb[FRA_PRIORITY])))
+				continue;
+
+			if (tb[FRA_IIFNAME] &&
+				nla_strcmp(tb[FRA_IIFNAME], rule->iifname))
+				continue;
+
+			if (tb[FRA_OIFNAME] &&
+				nla_strcmp(tb[FRA_OIFNAME], rule->oifname))
+				continue;
+
+			if (tb[FRA_FWMARK] &&
+				(rule->mark != nla_get_u32(tb[FRA_FWMARK])))
+				continue;
+
+			if (tb[FRA_FWMASK] &&
+				(rule->mark_mask != nla_get_u32(tb[FRA_FWMASK])))
+				continue;
+
+			if (tb[FRA_TUN_ID] &&
+				(rule->tun_id != nla_get_be64(tb[FRA_TUN_ID])))
+				continue;
+
+			if (!ops->compare(rule, frh, tb))
+				continue;
+
+			err = -EEXIST;
+			goto errout;
+		}
+	}
+
 	rule = kzalloc(ops->rule_size, GFP_KERNEL);
 	if (rule == NULL) {
 		err = -ENOMEM;
-- 
2.6.4


--------------000107050001000901070705--
