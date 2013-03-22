From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [RFC][PATCH] iproute: Faster ip link add, set and delete
Date: Fri, 22 Mar 2013 15:23:14 -0700
Message-ID: <87k3ozm5v1.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Serge Hallyn <serge.hallyn@ubuntu.com>,
	Benoit Lourdelet <blourdel@juniper.net>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:43642 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423359Ab3CVWXY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 18:23:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Because ip link add, set, and delete map the interface name to the
interface index by dumping all of the interfaces before performing
their respective commands.  Operations that should be constant time
slow down when lots of network interfaces are in use.  Resulting
in O(N^2) time to work with O(N) devices.

Make the work that iproute does constant time by passing the interface
name to the kernel instead.

In small scale testing on my system this shows dramatic performance
increases of ip link add from 120s to just 11s to add 5000 network
devices.  And from longer than I cared to wait to just 58s to delete
all of those interfaces again.

Cc: Serge Hallyn <serge.hallyn@ubuntu.com>
Reported-by: Benoit Lourdelet <blourdel@juniper.net>
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---

I think I am bungling the case where people specify an ifindex as ifNNNN
but does anyone care?

 ip/iplink.c |   19 +------------------
 1 files changed, 1 insertions(+), 18 deletions(-)

diff --git a/ip/iplink.c b/ip/iplink.c
index ad33611..6dffbf0 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -533,8 +533,6 @@ static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 		}
 	}
 
-	ll_init_map(&rth);
-
 	if (!(flags & NLM_F_CREATE)) {
 		if (!dev) {
 			fprintf(stderr, "Not enough information: \"dev\" "
@@ -542,27 +540,12 @@ static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 			exit(-1);
 		}
 
-		req.i.ifi_index = ll_name_to_index(dev);
-		if (req.i.ifi_index == 0) {
-			fprintf(stderr, "Cannot find device \"%s\"\n", dev);
-			return -1;
-		}
+		name = dev;
 	} else {
 		/* Allow "ip link add dev" and "ip link add name" */
 		if (!name)
 			name = dev;
 
-		if (link) {
-			int ifindex;
-
-			ifindex = ll_name_to_index(link);
-			if (ifindex == 0) {
-				fprintf(stderr, "Cannot find device \"%s\"\n",
-					link);
-				return -1;
-			}
-			addattr_l(&req.n, sizeof(req), IFLA_LINK, &ifindex, 4);
-		}
 	}
 
 	if (name) {
-- 
1.7.5.4
