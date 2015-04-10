From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: [PATCH iproute2] [PATCH iproute2 v2] iproute2: unify naming for entries offloaded to hardware
Date: Fri, 10 Apr 2015 16:50:40 -0400
Message-ID: <1428699040-2071-1-git-send-email-gospo@cumulusnetworks.com>
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"John W. Linville" <linville@tuxdriver.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f170.google.com ([209.85.220.170]:32815 "EHLO
	mail-qk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753252AbbDJUvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 16:51:14 -0400
Received: by qkx62 with SMTP id 62so45439744qkx.0
        for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 13:51:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The kernel now has the capability to offload FDB and FIB entries to hardware.
It is important to let users know if table entries are also offloaded to
hardware.  Currently offloaded FDB entries are indicated by the existence of
the flag 'external' on the entry as of the following commit:

commit 28467b7f3facd6114b2fbe0c9fecf57adbd52e12
Author: Scott Feldman <sfeldma@gmail.com>
Date:   Thu Dec 4 09:57:15 2014 +0100

    bridge/fdb: add flag/indication for FDB entry synced from offload device

When the patch to add support for indicating that FIB entries were also
offloaded as posted to netdev by Scott Feldman it became clear that 'external'
would not be an ideal name for routes.  There could definitely be confusion
about what this might mean since many routes are to external networks -- a
collision/confusion that did not happen with FDB.

Scott Feldman asked me to check with others and build concensus around a name.
After speaking with several people about this I am proposing we refer to both
FDB and FIB entries that are currently backed by hardware (based on the work
done in rocker) with the flag 'offload' appended to the end ofthe entry.

Some people liked the string 'external,' others liked 'hardware,' but the point
is to communicate that these routes are available to something that will will
offload the forwarding normally done by the kernel.  Since the term 'offload'
is used so frequently it seems appropriate to use the same language in
ip/bridge output.

The term 'offload' also seems to resonate with many of the people who have
responded on Scott's original thread or to those who I reached out to directly
and did respond to my query, so it seems we have reached consensus that it
should be the term used going forward.

v2: rebased against net-next branch

Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
CC: Jamal Hadi Salim <jhs@mojatatu.com>
CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: Jiri Pirko <jiri@resnulli.us>
CC: John W. Linville <linville@tuxdriver.com>
CC: Roopa Prabhu <roopa@cumulusnetworks.com>
CC: Scott Feldman <sfeldma@gmail.com>
CC: Stephen Hemminger <stephen@networkplumber.org>
---
 bridge/fdb.c | 2 +-
 ip/iproute.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/bridge/fdb.c b/bridge/fdb.c
index 3c33e22..e34933b 100644
--- a/bridge/fdb.c
+++ b/bridge/fdb.c
@@ -159,7 +159,7 @@ int print_fdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	if (r->ndm_flags & NTF_ROUTER)
 		fprintf(fp, "router ");
 	if (r->ndm_flags & NTF_EXT_LEARNED)
-		fprintf(fp, "external ");
+		fprintf(fp, "offload ");
 
 	fprintf(fp, "%s\n", state_n2a(r->ndm_state));
 	return 0;
diff --git a/ip/iproute.c b/ip/iproute.c
index 132a83a..e0a6159 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -448,7 +448,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	if (r->rtm_flags & RTNH_F_PERVASIVE)
 		fprintf(fp, "pervasive ");
 	if (r->rtm_flags & RTNH_F_EXTERNAL)
-		fprintf(fp, "external ");
+		fprintf(fp, "offload ");
 	if (r->rtm_flags & RTM_F_NOTIFY)
 		fprintf(fp, "notify ");
 	if (tb[RTA_MARK]) {
-- 
1.9.3
