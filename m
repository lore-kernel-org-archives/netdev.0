From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] flow_dissector: Fix function argument ordering
 dependency
Date: Tue, 01 Sep 2015 18:34:37 -0700
Message-ID: <1441157677.12163.13.camel@perches.com>
References: <1441156264-38469-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0208.hostedemail.com ([216.40.44.208]:42012 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751144AbbIBBep (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 21:34:45 -0400
In-Reply-To: <1441156264-38469-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-09-01 at 18:11 -0700, Tom Herbert wrote:
> Commit c6cc1ca7f4d70c ("flowi: Abstract out functions to get flow hash
> based on flowi") introduced a bug in __skb_set_sw_hash where we
> require a dependency on evaluating arguments in a function in order.
> There is no such ordering enforced in C, so this incorrect. This
> patch fixes that by splitting out the arguments. This bug was
> found via a compiler warning that keys may be uninitialized.

To help the reader know a bit more about how these
functions operate, perhaps it'd also be useful/better
to mark arguments as const where appropriate.

I didn't look to see if any other functions could
have the flow related args as const.

The __get_hash_from_flowi6 and flow_keys_have_l4
functions could be:
---
 include/net/flow.h           | 2 +-
 include/net/flow_dissector.h | 2 +-
 net/core/flow_dissector.c    | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index dafe97c..96fef26 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -244,7 +244,7 @@ void flow_cache_flush(struct net *net);
 void flow_cache_flush_deferred(struct net *net);
 extern atomic_t flow_cache_genid;
 
-__u32 __get_hash_from_flowi6(struct flowi6 *fl6, struct flow_keys *keys);
+__u32 __get_hash_from_flowi6(const struct flowi6 *fl6, struct flow_keys *keys);
 
 static inline __u32 get_hash_from_flowi6(struct flowi6 *fl6)
 {
diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index 8c8548c..9fdcc3f 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -177,7 +177,7 @@ struct flow_keys_digest {
 void make_flow_keys_digest(struct flow_keys_digest *digest,
 			   const struct flow_keys *flow);
 
-static inline bool flow_keys_have_l4(struct flow_keys *keys)
+static inline bool flow_keys_have_l4(const struct flow_keys *keys)
 {
 	return (keys->ports.ports || keys->tags.flow_label);
 }
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 345a040..ccece96 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -787,7 +787,7 @@ u32 skb_get_poff(const struct sk_buff *skb)
 	return __skb_get_poff(skb, skb->data, &keys, skb_headlen(skb));
 }
 
-__u32 __get_hash_from_flowi6(struct flowi6 *fl6, struct flow_keys *keys)
+__u32 __get_hash_from_flowi6(const struct flowi6 *fl6, struct flow_keys *keys)
 {
 	memset(keys, 0, sizeof(*keys));
 
