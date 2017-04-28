From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC net-next 3/4] net/sched: cls_flower: do not match if dissection fails
Date: Fri, 28 Apr 2017 14:00:34 +0200
Message-ID: <20170428120035.15984-4-simon.horman@netronome.com>
References: <20170428120035.15984-1-simon.horman@netronome.com>
Cc: Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>
To: Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:37267 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1425804AbdD1MBe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 08:01:34 -0400
Received: by mail-wm0-f46.google.com with SMTP id m123so44611245wma.0
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2017 05:01:28 -0700 (PDT)
In-Reply-To: <20170428120035.15984-1-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the flow skb_flow_dissect() returns an error it indicates that
dissection was incomplete for some reason. Matching using the result of an
incomplete dissection may cause unexpected results. For example:

* A match on zero layer 4 ports will also match packets truncated at
  the end of the IP header; that is packets where ports are missing are
  treated the same way as packets with zero ports.
* Likewise, a match on zero ICMP code or type will also match packets
  truncated at the end of the IP header; that is packets where the ICMP
  type and code are missing will be treated the same way as packets with
  zero ICMP code and type.

Separate patches to the flow dissector are required in order for it to
return errors in the above cases.

Fixes: 77b9900ef53a ("tc: introduce Flower classifier")
Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 net/sched/cls_flower.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 3ecf07666df3..cc6b3e7cf03b 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -187,7 +187,8 @@ static int fl_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 	 * so do it rather here.
 	 */
 	skb_key.basic.n_proto = skb->protocol;
-	skb_flow_dissect(skb, &head->dissector, &skb_key, 0);
+	if (!skb_flow_dissect(skb, &head->dissector, &skb_key, 0))
+		return -1;
 
 	fl_set_masked_key(&skb_mkey, &skb_key, &head->mask);
 
-- 
2.12.2.816.g2cccc81164
