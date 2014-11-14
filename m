From: Panu Matilainen <pmatilai@redhat.com>
Subject: [PATCH net] ipv4: Fix incorrect error code when adding an unreachable route
Date: Fri, 14 Nov 2014 13:14:32 +0200
Message-ID: <beb6c57fb3e1591346d64ac2fcdb354cd87987d4.1415963644.git.pmatilai@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56006 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965131AbaKNLPK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Nov 2014 06:15:10 -0500
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sAEBFAFL028393
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Fri, 14 Nov 2014 06:15:10 -0500
Received: from localhost.localdomain.com (vpn1-6-178.ams2.redhat.com [10.36.6.178])
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sAEBF92p021872
	for <netdev@vger.kernel.org>; Fri, 14 Nov 2014 06:15:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Trying to add an unreachable route incorrectly returns -ESRCH if
if custom FIB rules are present:

[root@localhost ~]# ip route add 74.125.31.199 dev eth0 via 1.2.3.4
RTNETLINK answers: Network is unreachable
[root@localhost ~]# ip rule add to 55.66.77.88 table 200
[root@localhost ~]# ip route add 74.125.31.199 dev eth0 via 1.2.3.4
RTNETLINK answers: No such process
[root@localhost ~]#

Commit 83886b6b636173b206f475929e58fac75c6f2446 ("[NET]: Change "not found"
return value for rule lookup") changed fib_rules_lookup()
to use -ESRCH as a "not found" code internally, but for user space it
should be translated into -ENETUNREACH. Handle the translation centrally in
ipv4-specific fib_lookup(), leaving the DECnet case alone.

On a related note, commit b7a71b51ee37d919e4098cd961d59a883fd272d8
("ipv4: removed redundant conditional") removed a similar translation from
ip_route_input_slow() prematurely AIUI.

Fixes: b7a71b51ee37 ("ipv4: removed redundant conditional")
Signed-off-by: Panu Matilainen <pmatilai@redhat.com>
---
 net/ipv4/fib_rules.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index f2e1573..8f7bd56 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -62,6 +62,10 @@ int __fib_lookup(struct net *net, struct flowi4 *flp, struct fib_result *res)
 	else
 		res->tclassid = 0;
 #endif
+
+	if (err == -ESRCH)
+		err = -ENETUNREACH;
+
 	return err;
 }
 EXPORT_SYMBOL_GPL(__fib_lookup);
-- 
1.9.3
