From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 3/7] net: FIX ipv6_forward sysctl restart
Date: Wed, 13 May 2009 19:58:17 -0700
Message-ID: <m1octwqtkm.fsf_-_@fess.ebiederm.org>
References: <m13ab8s8cr.fsf@fess.ebiederm.org>
	<m1skj8qtm2.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ben Greear <greearb@candelatech.com>,
	Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:52951 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762749AbZENC6T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2009 22:58:19 -0400
In-Reply-To: <m1skj8qtm2.fsf@fess.ebiederm.org> (Eric W. Biederman's message of "Wed\, 13 May 2009 19\:57\:25 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Just returning -ERESTARTSYS without a signal pending is not
good that will just leak it to userspace.  We need return
-ERESTARTNOINTR so we always restart and set signal pending
so that we fall of the fast path of syscall return and setup
the system call restart.

So use restart_syscall() which does all of this for us.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 net/ipv6/addrconf.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index a8218bc..9eb61c7 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -503,7 +503,7 @@ static int addrconf_fixup_forwarding(struct ctl_table *table, int *p, int old)
 		return 0;
 
 	if (!rtnl_trylock())
-		return -ERESTARTSYS;
+		return restart_syscall();
 
 	if (p == &net->ipv6.devconf_all->forwarding) {
 		__s32 newf = net->ipv6.devconf_all->forwarding;
-- 
1.6.0.6

