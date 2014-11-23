From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] fix return code from fib_rules_lookup()
Date: Sun, 23 Nov 2014 14:24:38 -0500 (EST)
Message-ID: <20141123.142438.1266838467850561800.davem@davemloft.net>
References: <1416637521-20173-1-git-send-email-ani@arista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maze@google.com, edumazet@google.com, netdev@vger.kernel.org,
	fruggeri@arista.com
To: ani@arista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35125 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751559AbaKWTYk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Nov 2014 14:24:40 -0500
In-Reply-To: <1416637521-20173-1-git-send-email-ani@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ani Sinha <ani@arista.com>
Date: Fri, 21 Nov 2014 22:25:21 -0800

>  fib_lookup() api returns two different types of error
>  codes. When no custom FIB rules are installed and
>  lookup fails, it returns ENETUNREACH. However, when
>  custom rules are installed, __fib_lookup() calls
>  fib_rules_lookup() which returns ESRCH when the rule
>  lookup fails. This patch makes both code paths return
>  identical error codes under lookup failure.
> 
> Signed-off-by: Ani Sinha <ani@arista.com>

How does this relate to the already committed:

commit 49dd18ba4615eaa72f15c9087dea1c2ab4744cf5
Author: Panu Matilainen <pmatilai@redhat.com>
Date:   Fri Nov 14 13:14:32 2014 +0200

    ipv4: Fix incorrect error code when adding an unreachable route
    
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
    Signed-off-by: David S. Miller <davem@davemloft.net>

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
