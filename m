From: David Miller <davem@davemloft.net>
Subject: [PATCH]: Fix for recently introduced rawv6 bug.
Date: Thu, 12 Jun 2008 14:49:33 -0700 (PDT)
Message-ID: <20080612.144933.184241072.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	viro@zeniv.linux.org.uk
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59518
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751846AbYFLVtd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2008 17:49:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Al Viro noticed that we have two assignments to
rawv6_prot.destroy, fix below with more details in
the commit message.

I'll commit this to net-2.6 and push to Linus.

Thanks Al!

ipv6: Fix duplicate initialization of rawv6_prot.destroy

In changeset 22dd485022f3d0b162ceb5e67d85de7c3806aa20
("raw: Raw socket leak.") code was added so that we
flush pending frames on raw sockets to avoid leaks.

The ipv4 part was fine, but the ipv6 part was not
done correctly.  Unlike the ipv4 side, the ipv6 code
already has a .destroy method for rawv6_prot.

So now there were two assignments to this member, and
what the compiler does is use the last one, effectively
making the ipv6 parts of that changeset a NOP.

Fix this by removing the:

	.destroy	   = inet6_destroy_sock,

line, and adding an inet6_destroy_sock() call to the
end of raw6_destroy().

Noticed by Al Viro.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv6/raw.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 8fee9a1..3aee123 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -1169,7 +1169,8 @@ static int raw6_destroy(struct sock *sk)
 	lock_sock(sk);
 	ip6_flush_pending_frames(sk);
 	release_sock(sk);
-	return 0;
+
+	return inet6_destroy_sock(sk);
 }
 
 static int rawv6_init_sk(struct sock *sk)
@@ -1200,7 +1201,6 @@ struct proto rawv6_prot = {
 	.disconnect	   = udp_disconnect,
 	.ioctl		   = rawv6_ioctl,
 	.init		   = rawv6_init_sk,
-	.destroy	   = inet6_destroy_sock,
 	.setsockopt	   = rawv6_setsockopt,
 	.getsockopt	   = rawv6_getsockopt,
 	.sendmsg	   = rawv6_sendmsg,
-- 
1.5.5.1.308.g1fbb5

