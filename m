From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net: __skb_flow_dissect() must cap its return value
Date: Wed, 09 Nov 2016 16:04:46 -0800
Message-ID: <1478736286.16809.17.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1477438271.7065.157.camel@edumazet-glaptop3.roam.corp.google.com>
         <1478718427.16809.7.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Yibin Yang <yibyang@cisco.com>, Tom Herbert <tom@herbertland.com>,
        Jojy Varghese <jojvargh@cisco.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35886 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752796AbcKJAEs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 19:04:48 -0500
Received: by mail-pf0-f195.google.com with SMTP id n85so1852826pfi.3
        for <netdev@vger.kernel.org>; Wed, 09 Nov 2016 16:04:48 -0800 (PST)
In-Reply-To: <1478718427.16809.7.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

After Tom patch, thoff field could point past the end of the buffer,
this could fool some callers.

If an skb was provided, skb->len should be the upper limit.
If not, hlen is supposed to be the upper limit.

Fixes: a6e544b0a88b ("flow_dissector: Jump to exit code in __skb_flow_dissect")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Yibin Yang <yibyang@cisco.com
Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
Acked-by: Willem de Bruijn <willemb@google.com>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 net/core/flow_dissector.c |   11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 44e6ba9d3a6b..5a908c534bec 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -122,7 +122,7 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 	struct flow_dissector_key_keyid *key_keyid;
 	bool skip_vlan = false;
 	u8 ip_proto = 0;
-	bool ret = false;
+	bool ret;
 
 	if (!data) {
 		data = skb->data;
@@ -549,12 +549,17 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 out_good:
 	ret = true;
 
-out_bad:
+	key_control->thoff = (u16)nhoff;
+out:
 	key_basic->n_proto = proto;
 	key_basic->ip_proto = ip_proto;
-	key_control->thoff = (u16)nhoff;
 
 	return ret;
+
+out_bad:
+	ret = false;
+	key_control->thoff = min_t(u16, nhoff, skb ? skb->len : hlen);
+	goto out;
 }
 EXPORT_SYMBOL(__skb_flow_dissect);
 
