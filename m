From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 2/5] flow_dissector: Fix fragment handling for
 header length computation
Date: Wed, 24 Feb 2016 09:29:44 -0800
Message-ID: <20160224172944.12339.62809.stgit@localhost.localdomain>
References: <20160224172644.12339.92679.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net,
	alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:36839 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755564AbcBXR3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 12:29:46 -0500
Received: by mail-pf0-f176.google.com with SMTP id e127so16299148pfe.3
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 09:29:46 -0800 (PST)
In-Reply-To: <20160224172644.12339.92679.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It turns out that for IPv4 we were reporting the ip_proto of the fragment,
and for IPv6 we were not.  This patch updates that behavior so that we
always report the IP protocol of the fragment.  In addition it takes the
steps of updating the payload offset code so that we will determine the
start of the payload not including the L4 header for any fragment after the
first.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 net/core/flow_dissector.c |   10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 1f88f8280280..8bd745f72734 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -448,13 +448,12 @@ ip_proto_again:
 		key_control->flags |= FLOW_DIS_IS_FRAGMENT;
 
 		nhoff += sizeof(_fh);
+		ip_proto = fh->nexthdr;
 
 		if (!(fh->frag_off & htons(IP6_OFFSET))) {
 			key_control->flags |= FLOW_DIS_FIRST_FRAG;
-			if (flags & FLOW_DISSECTOR_F_PARSE_1ST_FRAG) {
-				ip_proto = fh->nexthdr;
+			if (flags & FLOW_DISSECTOR_F_PARSE_1ST_FRAG)
 				goto ip_proto_again;
-			}
 		}
 		goto out_good;
 	}
@@ -741,6 +740,11 @@ u32 __skb_get_poff(const struct sk_buff *skb, void *data,
 {
 	u32 poff = keys->control.thoff;
 
+	/* skip L4 headers for fragments after the first */
+	if ((keys->control.flags & FLOW_DIS_IS_FRAGMENT) &&
+	    !(keys->control.flags & FLOW_DIS_FIRST_FRAG))
+		return poff;
+
 	switch (keys->basic.ip_proto) {
 	case IPPROTO_TCP: {
 		/* access doff as u8 to avoid unaligned access */
