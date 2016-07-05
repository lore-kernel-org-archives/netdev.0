From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 1/2] ipnetns: Move NETNS_RUN_DIR into it's own propagation group
Date: Tue,  5 Jul 2016 16:42:52 +0200
Message-ID: <1467729773-16751-2-git-send-email-phil@nwl.cc>
References: <1467729773-16751-1-git-send-email-phil@nwl.cc>
Cc: "Eric W . Biederman" <ebiederm@xmission.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:44541 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932976AbcGEOnT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jul 2016 10:43:19 -0400
In-Reply-To: <1467729773-16751-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On systems where the parent mount point is shared, NETNS_RUN_DIR
inherits the parent's propagation group. This leads to netns mount
points being propagated to the parent and thus showing up twice in the
output of 'mount'.

By making the newly mounted NETNS_RUN_DIR private first, then shared
again, it will move to it's own propagation group which will still allow
for netns mounts to propagate between mount namespaces but gets rid of
the double netns entry at the same time.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ipnetns.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index b3ee23c23aaa2..1cefe73c68bfc 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -650,6 +650,11 @@ static int netns_add(int argc, char **argv)
 				NETNS_RUN_DIR, NETNS_RUN_DIR, strerror(errno));
 			return -1;
 		}
+		if (mount("", NETNS_RUN_DIR, "none", MS_PRIVATE, NULL)) {
+			fprintf(stderr, "mount --make-private %s failed: %s\n",
+				NETNS_RUN_DIR, strerror(errno));
+			return -1;
+		}
 		made_netns_run_dir_mount = 1;
 	}
 
-- 
2.8.2
