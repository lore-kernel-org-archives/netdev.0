From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net] netlink: pad nla_memcpy dest buffer with zeroes
Date: Sun, 29 Mar 2015 16:05:28 +0200
Message-ID: <34fc9fcd5e67ad578fc5a1a2eb30cf52ffbba082.1427637780.git.jbenc@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44698 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752682AbbC2OFx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Mar 2015 10:05:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is especially important in cases where the kernel allocs a new
structure and expects a field to be set from a netlink attribute. If such
attribute is shorter than expected, the rest of the field is left containing
previous data. When such field is read back by the user space, kernel memory
content is leaked.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---

Alternatively, we may audit all callers of nla_memcpy; at least
nf_nat_ipv6_nlattr_to_range, ip_vs_genl_parse_service,
ieee802154_add_iface, ieee802154_llsec_parse_key and vxlan_nla_get_addr seem
possible to suffer from this by a quick glance. However, the notion of
"shorter attribute is understood as padded by zeroes" seems sensible to me.
---
 lib/nlattr.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/lib/nlattr.c b/lib/nlattr.c
index 76a1b59523ab..f5907d23272d 100644
--- a/lib/nlattr.c
+++ b/lib/nlattr.c
@@ -279,6 +279,8 @@ int nla_memcpy(void *dest, const struct nlattr *src, int count)
 	int minlen = min_t(int, count, nla_len(src));
 
 	memcpy(dest, nla_data(src), minlen);
+	if (count > minlen)
+		memset(dest + minlen, 0, count - minlen);
 
 	return minlen;
 }
-- 
1.8.3.1
