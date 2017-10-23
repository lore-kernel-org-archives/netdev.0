From: Laszlo Toth <laszlth@gmail.com>
Subject: [PATCH v2] sctp: full support for ipv6 ip_nonlocal_bind & IP_FREEBIND
Date: Mon, 23 Oct 2017 19:19:33 +0200
Message-ID: <20171023171933.GA4592@ubuntu-desk-vm>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Xin Long <lucien.xin@gmail.com>
To: Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:55097 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751304AbdJWRTh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 13:19:37 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 9b9742022888 ("sctp: support ipv6 nonlocal bind")
introduced support for the above options as v4 sctp did,
so patched sctp_v6_available().

In the v4 implementation it's enough, because
sctp_inet_bind_verify() just returns with sctp_v4_available().
However sctp_inet6_bind_verify() has an extra check before that
for link-local scope_id, which won't respect the above options.

Added the checks before calling ipv6_chk_addr(), but
not before the validation of scope_id.

before (w/ both options):
 ./v6test fe80::10 sctp
 bind failed, errno: 99 (Cannot assign requested address)
 ./v6test fe80::10 tcp
 bind success, errno: 0 (Success)

after (w/ both options):
 ./v6test fe80::10 sctp
 bind success, errno: 0 (Success)

Signed-off-by: Laszlo Toth <laszlth@gmail.com>
---
changed in v2:
 - fixed indentation

 net/sctp/ipv6.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 51c4887..7fe9e1d1 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -882,8 +882,10 @@ static int sctp_inet6_bind_verify(struct sctp_sock *opt, union sctp_addr *addr)
 			net = sock_net(&opt->inet.sk);
 			rcu_read_lock();
 			dev = dev_get_by_index_rcu(net, addr->v6.sin6_scope_id);
-			if (!dev ||
-			    !ipv6_chk_addr(net, &addr->v6.sin6_addr, dev, 0)) {
+			if (!dev || !(opt->inet.freebind ||
+				      net->ipv6.sysctl.ip_nonlocal_bind ||
+				      ipv6_chk_addr(net, &addr->v6.sin6_addr,
+						    dev, 0))) {
 				rcu_read_unlock();
 				return 0;
 			}
-- 
2.7.4
