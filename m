From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] ipv6: set fc_protocol with 0 when rtm_protocol is RTPROT_REDIRECT
Date: Sun, 30 Jul 2017 20:51:37 +0800
Message-ID: <e9342d18b97fc227cacc19db1b43f4c7350eed3f.1501419097.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, grawity@gmail.com
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:37861 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750991AbdG3Mvr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Jul 2017 08:51:47 -0400
Received: by mail-pf0-f194.google.com with SMTP id 72so3584213pfl.4
        for <netdev@vger.kernel.org>; Sun, 30 Jul 2017 05:51:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After commit c2ed1880fd61 ("net: ipv6: check route protocol when
deleting routes"), ipv6 route checks rt protocol when trying to
remove a rt entry.

It introduced a side effect when flushing caches with iproute, in
which all route caches get dumped from kernel then removed one by
one by sending RTM_DELROUTE requests to kernel for each cache.

The thing is iproute sends the request with the cache whose proto
is set with RTPROT_REDIRECT by rt6_fill_node() when kernel dumps
it. But in kernel the rt_cache protocol is still 0, which causes
the cache not to be found and removed.

As rt6_fill_node always sets rtm proto with RTPROT_REDIRECT when
rt cache info goes to rtmsg, the reverse process is needed when
users remove a route cache and rtmsg goes to cfg.

This patch is to fix it by keeping cfg proto as 0 when rtm proto
is REDIRECT. It's a safe fix as rtm proto is set with REDIRECT
only if rt flag has RTF_DYNAMIC which is set when creating a rt
cache in rt6_do_redirect where the cache's proto is always 0.

Note that this issue can also be avoided in iproute by changing
rtm proto back to 0 before sending DELROUTE requests for cache.
But in kernel part, the fix is still necessary as kernel should
do the reverse conversion when rtm goes to cfg.

Fixes: c2ed1880fd61 ("net: ipv6: check route protocol when deleting routes")
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/ipv6/route.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 4d30c96..187580f 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2912,9 +2912,11 @@ static int rtm_to_fib6_config(struct sk_buff *skb, struct nlmsghdr *nlh,
 	cfg->fc_dst_len = rtm->rtm_dst_len;
 	cfg->fc_src_len = rtm->rtm_src_len;
 	cfg->fc_flags = RTF_UP;
-	cfg->fc_protocol = rtm->rtm_protocol;
 	cfg->fc_type = rtm->rtm_type;
 
+	if (rtm->rtm_protocol != RTPROT_REDIRECT)
+		cfg->fc_protocol = rtm->rtm_protocol;
+
 	if (rtm->rtm_type == RTN_UNREACHABLE ||
 	    rtm->rtm_type == RTN_BLACKHOLE ||
 	    rtm->rtm_type == RTN_PROHIBIT ||
-- 
2.1.0
