From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net] vxlan: re-ignore EADDRINUSE from igmp_join
Date: Tue, 25 Aug 2015 20:22:35 -0300
Message-ID: <78f32de72ff150f6a1260f44a409cfed915a17e1.1440544648.git.marcelo.leitner@gmail.com>
References: <55DCB958.3080904@gmail.com>
Cc: John Nielsen <lists@jnielsen.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53582 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755927AbbHYXXD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2015 19:23:03 -0400
In-Reply-To: <55DCB958.3080904@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before 56ef9c909b40[1] it used to ignore all errors from igmp_join().
That commit enhanced that and made it error out whatever error happened
with igmp_join(), but that's not good because when using multicast
groups vxlan will try to join it multiple times if the socket is reused
and then the 2nd and further attempts will fail with EADDRINUSE.

As we don't track to which groups the socket is already subscribed, it's
okay to just ignore that error.

Fixes: 56ef9c909b40 ("vxlan: Move socket initialization to within rtnl scope")
Reported-by: John Nielsen <lists@jnielsen.net>
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---

John, please see how this goes for you. It worked in here.

Dave, please consider this for stable trees. At least 4.1 is affected.

Thanks.

 drivers/net/vxlan.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 61b457b9ec00517037e4833790bea97ac53aa832..b0a2da5d4e57e602c915b65abd34a83939c4c473 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2279,6 +2279,8 @@ static int vxlan_open(struct net_device *dev)
 
 	if (vxlan_addr_multicast(&vxlan->default_dst.remote_ip)) {
 		ret = vxlan_igmp_join(vxlan);
+		if (ret == -EADDRINUSE)
+			ret = 0;
 		if (ret) {
 			vxlan_sock_release(vs);
 			return ret;
-- 
2.4.3
