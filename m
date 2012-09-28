From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] net/key/af_key.c: add range checks on ->sadb_x_policy_len
Date: Fri, 28 Sep 2012 11:21:19 +0300
Message-ID: <20120928082119.GA32008@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:20449 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753038Ab2I1IVd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2012 04:21:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Because sizeof() is size_t then if "len" is negative, it counts as a
large positive value.

The call tree looks like:
pfkey_sendmsg()
-> pfkey_process()
   -> pfkey_spdadd()
      -> parse_ipsecrequests()

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
This is a static checker fix.  I'm not very familiar with this code.
I think if we were to hit this then we would try to parse invalid data
and it would return -EINVAL or similar error code pretty quickly.

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 2ca7d7f..7714df0 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1923,6 +1923,9 @@ parse_ipsecrequests(struct xfrm_policy *xp, struct sadb_x_policy *pol)
 	int len = pol->sadb_x_policy_len*8 - sizeof(struct sadb_x_policy);
 	struct sadb_x_ipsecrequest *rq = (void*)(pol+1);
 
+	if (pol->sadb_x_policy_len * 8 < sizeof(struct sadb_x_policy))
+		return -EINVAL;
+
 	while (len >= sizeof(struct sadb_x_ipsecrequest)) {
 		if ((err = parse_ipsecrequest(xp, rq)) < 0)
 			return err;
