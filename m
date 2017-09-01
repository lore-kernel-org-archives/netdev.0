From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH iproute2 1/2] iplink: check for message truncation in
 iplink_get()
Date: Fri,  1 Sep 2017 18:39:11 +0200 (CEST)
Message-ID: <b54be39a6f4688613fba5f0b7a1dcad245149b20.1504283683.git.mkubecek@suse.cz>
References: <cover.1504283683.git.mkubecek@suse.cz>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1504283683.git.mkubecek@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If message length exceeds maxlen argument of rtnl_talk(), it is truncated
to maxlen but unlike in the case of truncation to the length of local
buffer in rtnl_talk(), the caller doesn't get any indication of a problem.

In particular, iplink_get() passes the truncated message on and parsing it
results in various warnings and sometimes even a segfault (observed with
"ip link show dev ..." for a NIC with 125 VFs).

Handle message truncation in iplink_get() the same way as truncation in
rtnl_talk() would be handled: return an error.

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 ip/iplink.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/ip/iplink.c b/ip/iplink.c
index 5aff2fde38da..790e3a138bb0 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -1040,6 +1040,11 @@ int iplink_get(unsigned int flags, char *name, __u32 filt_mask)
 
 	if (rtnl_talk(&rth, &req.n, &answer.n, sizeof(answer)) < 0)
 		return -2;
+	if (answer.n.nlmsg_len > sizeof(answer.buf)) {
+		fprintf(stderr, "Message truncated from %u to %lu\n",
+			answer.n.nlmsg_len, sizeof(answer.buf));
+		return -2;
+	}
 
 	if (brief)
 		print_linkinfo_brief(NULL, &answer.n, stdout, NULL);
-- 
2.14.1
