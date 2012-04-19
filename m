From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 02/19] net sysctl:  Register an empty /proc/sys/net
Date: Thu, 19 Apr 2012 16:19:46 -0700
Message-ID: <m1zka7gvhp.fsf@fess.ebiederm.org>
References: <m1aa27ia6h.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, "Serge E. Hallyn" <serge@hallyn.com>,
	Gao feng <gaofeng@cn.fujitsu.com>, pablo@netfilter.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	Pavel Emelyanov <xemul@openvz.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:54583 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754028Ab2DSXPq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 19:15:46 -0400
In-Reply-To: <m1aa27ia6h.fsf@fess.ebiederm.org> (Eric W. Biederman's message
	of "Thu, 19 Apr 2012 16:17:10 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Implementation limitations of the sysctl core won't let /proc/sys/net
reside in a network namespace.  /proc/sys/net at least must be registered
as a normal sysctl.  So register /proc/sys/net early as an empty directory
to guarantee we don't violate this constraint and hit bugs in the sysctl
implementation.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/sysctl_net.c |   11 ++++++++++-
 1 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/net/sysctl_net.c b/net/sysctl_net.c
index 3865c4f..2b2986d 100644
--- a/net/sysctl_net.c
+++ b/net/sysctl_net.c
@@ -88,9 +88,18 @@ static struct pernet_operations sysctl_pernet_ops = {
 	.exit = sysctl_net_exit,
 };
 
+static struct ctl_table_header *net_header;
 static __init int net_sysctl_init(void)
 {
-	int ret;
+	static struct ctl_table empty[1];
+	int ret = -ENOMEM;
+	/* Avoid limitations in the sysctl implementation by
+	 * registering "/proc/sys/net" as an empty directory not in a
+	 * network namespace.
+	 */
+	net_header = register_sysctl("net", empty);
+	if (!net_header)
+		goto out;
 	ret = register_pernet_subsys(&sysctl_pernet_ops);
 	if (ret)
 		goto out;
-- 
1.7.2.5
