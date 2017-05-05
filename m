From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC net-next v2 3/4] net/sched: cls_flower: do not match if dissection fails
Date: Fri,  5 May 2017 14:47:05 +0200
Message-ID: <1493988426-22854-4-git-send-email-simon.horman@netronome.com>
References: <1493988426-22854-1-git-send-email-simon.horman@netronome.com>
Cc: Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com,
        Benjamin LaHaise <benjamin.lahaise@netronome.com>,
        Simon Horman <simon.horman@netronome.com>
To: Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:37997 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752183AbdEEMrU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 5 May 2017 08:47:20 -0400
Received: by mail-wm0-f54.google.com with SMTP id 142so5223666wma.1
        for <netdev@vger.kernel.org>; Fri, 05 May 2017 05:47:20 -0700 (PDT)
In-Reply-To: <1493988426-22854-1-git-send-email-simon.horman@netronome.com>
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
Reviewed-by: Benjamin LaHaise <benjamin.lahaise@netronome.com>
---
 net/sched/cls_flower.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index ca526c0881bd..90bfd003176b 100644
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
2.1.4
