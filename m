From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net repost] ipv4: fix nexthop attlen check in fib_nh_match
Date: Mon, 13 Oct 2014 16:34:10 +0200
Message-ID: <1413210850-14456-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, edumazet@google.com,
	tgraf@suug.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:53477 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752926AbaJMOeN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2014 10:34:13 -0400
Received: by mail-wi0-f173.google.com with SMTP id fb4so7587258wid.6
        for <netdev@vger.kernel.org>; Mon, 13 Oct 2014 07:34:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fib_nh_match does not match nexthops correctly. Example:

ip route add 172.16.10/24 nexthop via 192.168.122.12 dev eth0 \
                          nexthop via 192.168.122.13 dev eth0
ip route del 172.16.10/24 nexthop via 192.168.122.14 dev eth0 \
                          nexthop via 192.168.122.15 dev eth0

Del command is successful and route is removed. After this patch
applied, the route is correctly matched and result is:
RTNETLINK answers: No such process

Please consider this for stable trees as well.

Fixes: 4e902c57417c4 ("[IPv4]: FIB configuration using struct fib_config")
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
Acked-by: Eric Dumazet <edumazet@google.com>
---
reposted with example (it was missing for some reason in the original post)

 net/ipv4/fib_semantics.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 5b6efb3..f99f41b 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -537,7 +537,7 @@ int fib_nh_match(struct fib_config *cfg, struct fib_info *fi)
 			return 1;
 
 		attrlen = rtnh_attrlen(rtnh);
-		if (attrlen < 0) {
+		if (attrlen > 0) {
 			struct nlattr *nla, *attrs = rtnh_attrs(rtnh);
 
 			nla = nla_find(attrs, attrlen, RTA_GATEWAY);
-- 
1.9.3
