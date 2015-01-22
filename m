From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net 2/2] net: cls_bpf: fix auto generation of per list handles
Date: Thu, 22 Jan 2015 10:41:02 +0100
Message-ID: <1421919662-21066-3-git-send-email-dborkman@redhat.com>
References: <1421919662-21066-1-git-send-email-dborkman@redhat.com>
Cc: jiri@resnulli.us, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35589 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751533AbbAVJlL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2015 04:41:11 -0500
In-Reply-To: <1421919662-21066-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When creating a bpf classifier in tc with priority collisions and
invoking automatic unique handle assignment, cls_bpf_grab_new_handle()
will return a wrong handle id which in fact is non-unique. Usually
altering of specific filters is being addressed over major id, but
in case of collisions we result in a filter chain, where handle ids
address individual cls_bpf_progs inside the classifier.

Issue is, in cls_bpf_grab_new_handle() we probe for head->hgen handle
in cls_bpf_get() and in case we found a free handle, we're supposed
to use exactly head->hgen. In case of insufficient numbers of handles,
we bail out later as handle id 0 is not allowed.

Fixes: 7d1d65cb84e1 ("net: sched: cls_bpf: add BPF-based classifier")
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Acked-by: Jiri Pirko <jiri@resnulli.us>
---
 net/sched/cls_bpf.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 49e5fa8..f59adf8 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -220,15 +220,21 @@ static u32 cls_bpf_grab_new_handle(struct tcf_proto *tp,
 				   struct cls_bpf_head *head)
 {
 	unsigned int i = 0x80000000;
+	u32 handle;
 
 	do {
 		if (++head->hgen == 0x7FFFFFFF)
 			head->hgen = 1;
 	} while (--i > 0 && cls_bpf_get(tp, head->hgen));
-	if (i == 0)
+
+	if (unlikely(i == 0)) {
 		pr_err("Insufficient number of handles\n");
+		handle = 0;
+	} else {
+		handle = head->hgen;
+	}
 
-	return i;
+	return handle;
 }
 
 static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
-- 
1.7.11.7
