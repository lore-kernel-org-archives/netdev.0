From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net] gre: reject GUE and FOU in collect metadata mode
Date: Wed, 27 Apr 2016 14:08:01 +0200
Message-ID: <7280f5aa7ec83653cdf7f0484fb9e696bc8c89e8.1461758705.git.jbenc@redhat.com>
Cc: Pravin Shelar <pshelar@ovn.org>, Thomas Graf <tgraf@suug.ch>,
	Tom Herbert <tom@herbertland.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35714 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752316AbcD0MIk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Apr 2016 08:08:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The collect metadata mode does not support GUE nor FOU. This might be
implemented later; until then, we should reject such config.

I think this is okay to be changed. It's unlikely anyone has such
configuration (as it doesn't work anyway) and we may need a way to
distinguish whether it's supported or not by the kernel later.

For backwards compatibility with iproute2, it's not possible to just check
the attribute presence (iproute2 always includes the attribute), the actual
value has to be checked, too.

Fixes: 2e15ea390e6f4 ("ip_gre: Add support to collect tunnel metadata.")
Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
Discovered this only after I already sent v3 of the previous gre set.
Submitting this patch on its own, it's an indepent fix anyway (though fixing
the same commit).
---
 net/ipv4/ip_gre.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index f973e0a58993..f502d34bcb40 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -948,6 +948,11 @@ static int ipgre_tunnel_validate(struct nlattr *tb[], struct nlattr *data[])
 	if (flags & (GRE_VERSION|GRE_ROUTING))
 		return -EINVAL;
 
+	if (data[IFLA_GRE_COLLECT_METADATA] &&
+	    data[IFLA_GRE_ENCAP_TYPE] &&
+	    nla_get_u16(data[IFLA_GRE_ENCAP_TYPE]) != TUNNEL_ENCAP_NONE)
+		return -EINVAL;
+
 	return 0;
 }
 
-- 
1.8.3.1
