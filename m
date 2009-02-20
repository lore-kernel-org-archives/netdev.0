From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/3] netns: Fix icmp shutdown.
Date: Fri, 20 Feb 2009 07:52:36 -0800
Message-ID: <m1bpsxhzqz.fsf@fess.ebiederm.org>
References: <m1ocwxi00a.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Containers <containers@lists.osdl.org>,
	<netdev@vger.kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>,
	"Denis V. Lunev" <den@openvz.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:53163 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752695AbZBTPwN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2009 10:52:13 -0500
In-Reply-To: <m1ocwxi00a.fsf@fess.ebiederm.org> (Eric W. Biederman's message of "Fri\, 20 Feb 2009 07\:47\:01 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Recently I had a kernel panic in icmp_send during a network namespace
cleanup.  There were packets in the arp queue that failed to be sent
and we attempted to generate an ICMP host unreachable message, but
failed because icmp_sk_exit had already been called.

The network devices are removed from a network namespace and their
arp queues are flushed before we do attempt to shutdown subsystems
so this error should have been impossible.

It turns out icmp_init is using register_pernet_device instead
of register_pernet_subsys.  Which resulted in icmp being shut down
while we still had the possibility of packets in flight, making
a nasty NULL pointer deference in interrupt context possible.

Changing this to register_pernet_subsys fixes the problem in
my testing.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 net/ipv4/icmp.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 382800a..3f50807 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -1207,7 +1207,7 @@ static struct pernet_operations __net_initdata icmp_sk_ops = {
 
 int __init icmp_init(void)
 {
-	return register_pernet_device(&icmp_sk_ops);
+	return register_pernet_subsys(&icmp_sk_ops);
 }
 
 EXPORT_SYMBOL(icmp_err_convert);
-- 
1.6.1.2.350.g88cc

