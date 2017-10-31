From: Stefano Brivio <sbrivio@redhat.com>
Subject: [iproute PATCH v2 3/3] ss: Fix width calculations when Netid or State columns are missing
Date: Tue, 31 Oct 2017 18:47:56 +0100
Message-ID: <307ece856aabf425fe77d389451cfb9d555d24fd.1509471878.git.sbrivio@redhat.com>
References: <cover.1509471877.git.sbrivio@redhat.com>
Cc: netdev@vger.kernel.org, Phil Sutter <phil@nwl.cc>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43634 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932535AbdJaRsn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 13:48:43 -0400
In-Reply-To: <cover.1509471877.git.sbrivio@redhat.com>
In-Reply-To: <cover.1509471877.git.sbrivio@redhat.com>
References: <cover.1509471877.git.sbrivio@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If Netid or State columns are missing, we must not subtract one
for each of these two columns from the remaining screen width,
while distributing available space to columns. This one
character corresponding to one delimiting space has to be
subtracted only if the columns are actually printed.

Further, in the existing implementation, if the screen width is
an odd number, one additional character is added to the width of
one of the two columns.

But if both are not printed, this filling character needs to be
added somewhere else, in order to have the right spacing
allowing us to fill lines completely.

Address and port fields are printed in pairs (local and remote),
so we can't distribute the space to any of them, because it
would be doubled. Instead, print this additional space to the
right of the Send-Q column, to keep code changes to a minimum.

This is particularly visible with 'ss -f netlink -Z'. Before
this patch, with an 80 column terminal, we have:

$ ss -f netlink -Z|head -n3
Recv-Q Send-Q Local Address:Port                 Peer Address:Port
0      0            rtnl:evolution-calen/2049           *                     pr
oc_ctx=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
0      0            rtnl:clock-applet/1944              *                     pr
oc_ctx=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023

and with an 81 column terminal:

$ ss -f netlink -Z|head -n3
Recv-Q Send-Q Local Address:Port                 Peer Address:Port
0      0            rtnl:evolution-calen/2049           *                     pro
c_ctx=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
0      0            rtnl:clock-applet/1944              *                     pro
c_ctx=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023

After this patch, in both cases, the output is:
$ ss -f netlink -Z|head -n3
Recv-Q Send-Q Local Address:Port                 Peer Address:Port
0      0             rtnl:evolution-calen/2049            *
 proc_ctx=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
0      0             rtnl:clock-applet/1944               *
 proc_ctx=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023

Signed-off-by: Stefano Brivio <sbrivio@redhat.com>
---
v2: Add whitespace around '=' in odd_width_pad assignments, replace
    conditional terms in addrp_width adjustment by explicit if clauses

 misc/ss.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index fb80d84122fc..56a9ad415ce1 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -107,6 +107,7 @@ int netid_width;
 int state_width;
 int addr_width;
 int serv_width;
+char *odd_width_pad = "";
 
 static const char *TCP_PROTO = "tcp";
 static const char *SCTP_PROTO = "sctp";
@@ -838,7 +839,7 @@ static void sock_state_print(struct sockstat *s)
 			printf("%-*s ", state_width, sstate_name[s->state]);
 	}
 
-	printf("%-6d %-6d ", s->rq, s->wq);
+	printf("%-6d %-6d %s", s->rq, s->wq, odd_width_pad);
 }
 
 static void sock_details_print(struct sockstat *s)
@@ -4364,8 +4365,10 @@ int main(int argc, char *argv[])
 	}
 
 	addrp_width = screen_width;
-	addrp_width -= netid_width+1;
-	addrp_width -= state_width+1;
+	if (netid_width)
+		addrp_width -= netid_width + 1;
+	if (state_width)
+		addrp_width -= state_width + 1;
 	addrp_width -= 14;
 
 	if (addrp_width&1) {
@@ -4373,6 +4376,8 @@ int main(int argc, char *argv[])
 			netid_width++;
 		else if (state_width)
 			state_width++;
+		else
+			odd_width_pad = " ";
 	}
 
 	addrp_width /= 2;
@@ -4390,7 +4395,7 @@ int main(int argc, char *argv[])
 			printf("%-*s ", netid_width, "Netid");
 		if (state_width)
 			printf("%-*s ", state_width, "State");
-		printf("%-6s %-6s ", "Recv-Q", "Send-Q");
+		printf("%-6s %-6s %s", "Recv-Q", "Send-Q", odd_width_pad);
 	}
 
 	/* Make enough space for the local/remote port field */
-- 
2.9.4
