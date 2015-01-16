From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH v3 2/3] genetlink: disallow subscribing to unknown mcast groups
Date: Fri, 16 Jan 2015 11:37:13 +0100
Message-ID: <1421404634-8973-2-git-send-email-johannes@sipsolutions.net>
References: <1421404634-8973-1-git-send-email-johannes@sipsolutions.net>
Cc: Jeff Layton <jeff.layton@primarydata.com>,
	Sedat Dilek <sedat.dilek@gmail.com>,
	Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:41166 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751778AbbAPKh0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jan 2015 05:37:26 -0500
In-Reply-To: <1421404634-8973-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

Jeff Layton reported that he could trigger the multicast unbind warning
in generic netlink using trinity. I originally thought it was a race
condition between unregistering the generic netlink family and closing
the socket, but there's a far simpler explanation: genetlink currently
allows subscribing to groups that don't (yet) exist, and the warning is
triggered when unsubscribing again while the group still doesn't exist.

Originally, I had a warning in the subscribe case and accepted it out of
userspace API concerns, but the warning was of course wrong and removed
later.

However, I now think that allowing userspace to subscribe to groups that
don't exist is wrong and could possibly become a security problem:
Consider a (new) genetlink family implementing a permission check in
the mcast_bind() function similar to the like the audit code does today;
it would be possible to bypass the permission check by guessing the ID
and subscribing to the group it exists. This is only possible in case a
family like that would be dynamically loaded, but it doesn't seem like a
huge stretch, for example wireless may be loaded when you plug in a USB
device.

To avoid this reject such subscription attempts.

If this ends up causing userspace issues we may need to add a workaround
in af_netlink to deny such requests but not return an error.

Reported-by: Jeff Layton <jeff.layton@primarydata.com>
Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 net/netlink/genetlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 2e11061ef885..c18d3f5624b2 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -985,7 +985,7 @@ static struct genl_multicast_group genl_ctrl_groups[] = {
 
 static int genl_bind(struct net *net, int group)
 {
-	int i, err = 0;
+	int i, err = -ENOENT;
 
 	down_read(&cb_lock);
 	for (i = 0; i < GENL_FAM_TAB_SIZE; i++) {
-- 
2.1.4
