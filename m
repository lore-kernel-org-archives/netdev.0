From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH iproute2 1/2] tc filters: display handle in events when a filter is deleted
Date: Mon, 17 Oct 2016 05:34:44 -0400
Message-ID: <1476696885-22214-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
        xiyou.wangcong@gmail.com, mrv@mojatatu.com,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35010 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932727AbcJQJe5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 05:34:57 -0400
Received: by mail-it0-f65.google.com with SMTP id 139so2845887itm.2
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 02:34:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

An event being displayed via "tc mon" should display the filter handle.
The filter handle is a required parameter when deleting a filter and
therefore the delete event should mimic/mirror the command sent.
A simple test, run tc monitor on one window, on another try adding
a filter:
..
sudo $TC filter add dev $ETH parent ffff: protocol ip pref 1 \
u32 match ip protocol 1 0xff \
flowid 1:1 \
action ok
..

.. get its handle by dumping ...
sudo $TC -s filter ls dev $ETH parent ffff: protocol ip
... find out the handle (say it was 800::800)
... go delete it..
sudo $TC filter del dev $ETH handle 800::800 parent ffff: \
protocol ip prio 1 u32

now see tc monitor reporting it without handle. After this patch
with a handle.

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 tc/tc_filter.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/tc/tc_filter.c b/tc/tc_filter.c
index 2413cef..4efc44f 100644
--- a/tc/tc_filter.c
+++ b/tc/tc_filter.c
@@ -253,12 +253,13 @@ int print_filter(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	}
 	fprintf(fp, "%s ", rta_getattr_str(tb[TCA_KIND]));
 	q = get_filter_kind(RTA_DATA(tb[TCA_KIND]));
-	if (tb[TCA_OPTIONS]) {
+	if (tb[TCA_OPTIONS] || n->nlmsg_type == RTM_DELTFILTER) {
 		if (q)
 			q->print_fopt(q, fp, tb[TCA_OPTIONS], t->tcm_handle);
 		else
 			fprintf(fp, "[cannot parse parameters]");
 	}
+
 	fprintf(fp, "\n");
 
 	if (show_stats && (tb[TCA_STATS] || tb[TCA_STATS2])) {
-- 
1.9.1
