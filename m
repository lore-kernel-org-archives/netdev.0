From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net 1/2] net: cls_bpf: fix size mismatch on filter preparation
Date: Thu, 22 Jan 2015 10:41:01 +0100
Message-ID: <1421919662-21066-2-git-send-email-dborkman@redhat.com>
References: <1421919662-21066-1-git-send-email-dborkman@redhat.com>
Cc: jiri@resnulli.us, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35580 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751461AbbAVJlK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2015 04:41:10 -0500
In-Reply-To: <1421919662-21066-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In cls_bpf_modify_existing(), we read out the number of filter blocks,
do some sanity checks, allocate a block on that size, and copy over the
BPF instruction blob from user space, then pass everything through the
classic BPF checker prior to installation of the classifier.

We should reject mismatches here, there are 2 scenarios: the number of
filter blocks could be smaller than the provided instruction blob, so
we do a partial copy of the BPF program, and thus the instructions will
either be rejected from the verifier or a valid BPF program will be run;
in the other case, we'll end up copying more than we're supposed to,
and most likely the trailing garbage will be rejected by the verifier
as well (i.e. we need to fit instruction pattern, ret {A,K} needs to be
last instruction, load/stores must be correct, etc); in case not, we
would leak memory when dumping back instruction patterns. The code should
have only used nla_len() as Dave noted to avoid this from the beginning.
Anyway, lets fix it by rejecting such load attempts.

Fixes: 7d1d65cb84e1 ("net: sched: cls_bpf: add BPF-based classifier")
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Acked-by: Jiri Pirko <jiri@resnulli.us>
---
 net/sched/cls_bpf.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 84c8219..49e5fa8 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -180,6 +180,11 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
 	}
 
 	bpf_size = bpf_len * sizeof(*bpf_ops);
+	if (bpf_size != nla_len(tb[TCA_BPF_OPS])) {
+		ret = -EINVAL;
+		goto errout;
+	}
+
 	bpf_ops = kzalloc(bpf_size, GFP_KERNEL);
 	if (bpf_ops == NULL) {
 		ret = -ENOMEM;
-- 
1.7.11.7
