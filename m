From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH 1/4] ipv4: match prefsrc when deleting routes
Date: Sat, 19 Mar 2011 01:13:40 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1103190112040.1678@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:52122 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757493Ab1CRXIa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Mar 2011 19:08:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 	fib_table_delete forgets to match the routes by prefsrc.
Callers can specify known IP in fc_prefsrc and we should remove
the exact route. This is needed for cases when same local or
broadcast addresses are used in different subnets and the
routes differ only in prefsrc. All callers that do not provide
fc_prefsrc will ignore the route prefsrc as before and will
delete the first occurence. That is how the ip route del default
magic works.

 	Current callers are:

- ip_rt_ioctl where rtentry_to_fib_config provides fc_prefsrc only
when the provided device name matches IP label with colon.

- inet_rtm_delroute where RTA_PREFSRC is optional too

- fib_magic which deals with routes when deleting addresses
and where the fc_prefsrc is always set with the primary IP
for the concerned IFA.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

diff -urp net-next-2.6-bef55ae/linux/net/ipv4/fib_trie.c linux/net/ipv4/fib_trie.c
--- net-next-2.6-bef55ae/linux/net/ipv4/fib_trie.c	2011-03-13 01:08:55.000000000 +0200
+++ linux/net/ipv4/fib_trie.c	2011-03-16 09:53:26.824191983 +0200
@@ -1665,6 +1665,8 @@ int fib_table_delete(struct fib_table *t
  		if ((!cfg->fc_type || fa->fa_type == cfg->fc_type) &&
  		    (cfg->fc_scope == RT_SCOPE_NOWHERE ||
  		     fa->fa_scope == cfg->fc_scope) &&
+		    (!cfg->fc_prefsrc ||
+		     fi->fib_prefsrc == cfg->fc_prefsrc) &&
  		    (!cfg->fc_protocol ||
  		     fi->fib_protocol == cfg->fc_protocol) &&
  		    fib_nh_match(cfg, fi) == 0) {
