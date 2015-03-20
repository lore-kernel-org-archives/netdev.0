From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net-next] vxlan: fix possible use of uninitialized in vxlan_igmp_{join,leave}
Date: Fri, 20 Mar 2015 10:26:21 -0300
Message-ID: <1426857981-17946-1-git-send-email-marcelo.leitner@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52171 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751585AbbCTN03 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2015 09:26:29 -0400
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t2KDQSOk004235
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Fri, 20 Mar 2015 09:26:29 -0400
Received: from localhost.localdomain.com ([10.3.113.11])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t2KDQR9C029977
	for <netdev@vger.kernel.org>; Fri, 20 Mar 2015 09:26:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Test robot noticed that we check the return of vxlan_igmp_join and leave
but inside them there was a path that it could be used initialized.

It's not really possible because those if() inside these igmp functions
would always match as we can't have sockets of other type in there, but
this way we keep the compiler happy.

Fixes: 56ef9c909b40 ("vxlan: Move socket initialization to within rtnl scope")
Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 drivers/net/vxlan.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 5f749a51f35624c3375ea536270faaf56c955e16..e75e4b2e6031578918e578a652a0ad6c578bade4 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1093,7 +1093,7 @@ static int vxlan_igmp_join(struct vxlan_dev *vxlan)
 	struct sock *sk = vs->sock->sk;
 	union vxlan_addr *ip = &vxlan->default_dst.remote_ip;
 	int ifindex = vxlan->default_dst.remote_ifindex;
-	int ret;
+	int ret = -EINVAL;
 
 	lock_sock(sk);
 	if (ip->sa.sa_family == AF_INET) {
@@ -1121,7 +1121,7 @@ static int vxlan_igmp_leave(struct vxlan_dev *vxlan)
 	struct sock *sk = vs->sock->sk;
 	union vxlan_addr *ip = &vxlan->default_dst.remote_ip;
 	int ifindex = vxlan->default_dst.remote_ifindex;
-	int ret;
+	int ret = -EINVAL;
 
 	lock_sock(sk);
 	if (ip->sa.sa_family == AF_INET) {
-- 
2.1.0
