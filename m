From: Craig Gallek <kraigatgoog@gmail.com>
Subject: [PATCH v2 net-next] ip6_tunnel: Fix missing tunnel encapsulation limit option
Date: Wed, 26 Apr 2017 14:37:45 -0400
Message-ID: <20170426183745.194717-1-kraigatgoog@gmail.com>
References: <20170426170707.165201-1-kraigatgoog@gmail.com>
Cc: netdev@vger.kernel.org
To: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f175.google.com ([209.85.216.175]:34681 "EHLO
        mail-qt0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965002AbdDZShr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 14:37:47 -0400
Received: by mail-qt0-f175.google.com with SMTP id c45so8292968qtb.1
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 11:37:47 -0700 (PDT)
In-Reply-To: <20170426170707.165201-1-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <cgallek@google.com>

The IPv6 tunneling code tries to insert IPV6_TLV_TNL_ENCAP_LIMIT and
IPV6_TLV_PADN options when an encapsulation limit is defined (the
default is a limit of 4).  An MTU adjustment is done to account for
these options as well.  However, the options are never present in the
generated packets.

The issue appears to be a subtlety between IPV6_DSTOPTS and
IPV6_RTHDRDSTOPTS defined in RFC 3542.  When the IPIP tunnel driver was
written, the encap limit options were included as IPV6_RTHDRDSTOPTS in
dst0opt of struct ipv6_txoptions.  Later, ipv6_push_nfrags_opts was
(correctly) updated to require IPV6_RTHDR options when IPV6_RTHDRDSTOPTS
are to be used.  This caused the options to no longer be included in v6
encapsulated packets.

The fix is to use IPV6_DSTOPTS (in dst1opt of struct ipv6_txoptions)
instead.  IPV6_DSTOPTS do not have the additional IPV6_RTHDR requirement.

Fixes: 1df64a8569c7: ("[IPV6]: Add ip6ip6 tunnel driver.")
Fixes: 333fad5364d6: ("[IPV6]: Support several new sockopt / ancillary data in Advanced API (RFC3542)")
Signed-off-by: Craig Gallek <kraig@google.com>
---

v2: Change tunnel code to use dst1opt rather than making the checks for
    dst0opt more permissive.

 net/ipv6/ip6_tunnel.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index ad15d38b41e8..c81f9541f1f7 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -954,7 +954,7 @@ static void init_tel_txopt(struct ipv6_tel_txoption *opt, __u8 encap_limit)
 	opt->dst_opt[5] = IPV6_TLV_PADN;
 	opt->dst_opt[6] = 1;
 
-	opt->ops.dst0opt = (struct ipv6_opt_hdr *) opt->dst_opt;
+	opt->ops.dst1opt = (struct ipv6_opt_hdr *) opt->dst_opt;
 	opt->ops.opt_nflen = 8;
 }
 
@@ -1176,7 +1176,7 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
 
 	if (encap_limit >= 0) {
 		init_tel_txopt(&opt, encap_limit);
-		ipv6_push_nfrag_opts(skb, &opt.ops, &proto, NULL, NULL);
+		ipv6_push_frag_opts(skb, &opt.ops, &proto);
 	}
 
 	/* Calculate max headroom for all the headers and adjust
-- 
2.13.0.rc0.306.g87b477812d-goog
