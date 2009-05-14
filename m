From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 4/7] net: Fix devinet_sysctl_forward
Date: Wed, 13 May 2009 19:59:21 -0700
Message-ID: <m1k54kqtiu.fsf@fess.ebiederm.org>
References: <m13ab8s8cr.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ben Greear <greearb@candelatech.com>,
	Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:53028 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761319AbZENC7Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2009 22:59:25 -0400
In-Reply-To: <m13ab8s8cr.fsf@fess.ebiederm.org> (Eric W. Biederman's message of "Wed\, 13 May 2009 19\:53\:40 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


sysctls are unregistered with the rntl_lock held making
it unsafe to unconditionally grab the the rtnl_lock.  Instead
we need to call rtnl_trylock and restart the system call
if we can not grab it.  Otherwise we could deadlock at unregistration
time.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 net/ipv4/devinet.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 126bb91..3863c3a 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1347,7 +1347,8 @@ static int devinet_sysctl_forward(ctl_table *ctl, int write,
 		struct net *net = ctl->extra2;
 
 		if (valp != &IPV4_DEVCONF_DFLT(net, FORWARDING)) {
-			rtnl_lock();
+			if (!rtnl_trylock())
+				return restart_syscall();
 			if (valp == &IPV4_DEVCONF_ALL(net, FORWARDING)) {
 				inet_forward_change(net);
 			} else if (*valp) {
-- 
1.6.0.6

