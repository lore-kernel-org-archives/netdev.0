From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-next 4/6][IP6FRAGS]: Handle error, returned from register_pernet_subsys.
Date: Mon, 19 May 2008 20:02:25 +0400
Message-ID: <4831A491.2020009@openvz.org>
References: <4831A1D6.4090503@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:56937 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760888AbYESQEw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 May 2008 12:04:52 -0400
In-Reply-To: <4831A1D6.4090503@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The error code is ignored now, but ipv6 is a module and one can
be loaded under memory pressure, so the error may occur (in theory).

Besides, I'm going to handle error returned from registering a
read-only part of the table, so ignoring this one, while handing
the other one would look strange.

(However, this possibility of error is rather small, so I'm not 
 sure whether this is a candidate for current net tree).

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv6/reassembly.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 7e008de..130d6f6 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -750,7 +750,9 @@ int __init ipv6_frag_init(void)
 	if (ret)
 		goto out;
 
-	register_pernet_subsys(&ip6_frags_ops);
+	ret = register_pernet_subsys(&ip6_frags_ops);
+	if (ret)
+		goto err_pernet;
 
 	ip6_frags.hashfn = ip6_hashfn;
 	ip6_frags.constructor = ip6_frag_init;
@@ -763,6 +765,10 @@ int __init ipv6_frag_init(void)
 	inet_frags_init(&ip6_frags);
 out:
 	return ret;
+
+err_pernet:
+	inet6_del_protocol(&frag_protocol, IPPROTO_FRAGMENT);
+	goto out;
 }
 
 void ipv6_frag_exit(void)
-- 
1.5.3.4

