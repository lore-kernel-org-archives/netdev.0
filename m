From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] ipv4: fib: check forwarding before checking send_redirects
Date: Tue,  8 Apr 2014 12:31:22 -0700
Message-ID: <1396985482-30886-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: davem@davemloft.net, Eric Biederman <ebiederm@xmission.com>,
	Julian Anastasov <ja@ssi.bg>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Cong Wang <cwang@twopensource.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:41538 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932159AbaDHTbx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2014 15:31:53 -0400
Received: by mail-pa0-f52.google.com with SMTP id rd3so1457610pab.25
        for <netdev@vger.kernel.org>; Tue, 08 Apr 2014 12:31:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <cwang@twopensource.com>

We have seen in a weird case we had to disable send_redirects in order
to pass rp filter check even though we don't set forwarding at all.
This looks wrong, at least according to ip-sysctl.txt send_redirects should
only make sense when we enable forwarding.

Cc: Eric Biederman <ebiederm@xmission.com>
Cc: Julian Anastasov <ja@ssi.bg>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: Cong Wang <cwang@twopensource.com>

---
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 1a629f8..3f9e324 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -321,7 +321,8 @@ int fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 	int r = secpath_exists(skb) ? 0 : IN_DEV_RPFILTER(idev);
 
 	if (!r && !fib_num_tclassid_users(dev_net(dev)) &&
-	    (dev->ifindex != oif || !IN_DEV_TX_REDIRECTS(idev))) {
+	    (dev->ifindex != oif || !IN_DEV_FORWARD(idev) ||
+	     !IN_DEV_TX_REDIRECTS(idev))) {
 		*itag = 0;
 		return 0;
 	}
