From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2.6]: Fix policy update bug when increasing priority of last
 policy
Date: Mon, 18 Oct 2004 22:48:36 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41742C24.6070305@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000009030309030704020409"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000009030309030704020409
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

When the last policy for a direction is replaced by a policy
with equal selector but a higher priority, insertion of the
new policy fails.

in xfrm_policy_insert:

        for (p = &xfrm_policy_list[dir]; (pol=*p)!=NULL; p = &pol->next) {
                if (!delpol && memcmp(&policy->selector, &pol->selector, 
sizeof(pol->selector)) == 0) {
                        if (excl) {
                                write_unlock_bh(&xfrm_policy_lock);
                                return -EEXIST;
                        }
                        *p = pol->next;
                        delpol = pol;
X                       if (policy->priority > pol->priority)
X                                continue;
                } else if (policy->priority >= pol->priority)
                        continue;
                if (!newpos)
                        newpos = p;
                if (delpol)
                        break;
        }

If the new policy has a higher priority than the old one, the
loop will be continued in the lines marked with X, but because
there are no further elements, it will leave the loop without
setting newpos.

The problem can be verified with ip xfrm:
# ip xfrm policy list
# ip xfrm policy update dir fwd src 10.0.0.1 dst 10.0.0.2 action allow 
priority 0
# ip xfrm policy list
src 10.0.0.1/32 dst 10.0.0.2/32
        dir fwd priority 0
# ip xfrm policy update dir fwd src 10.0.0.1 dst 10.0.0.2 action allow 
priority 1
# ip xfrm policy list
#

This patch checks for *p != NULL before continuing the loop.

Regards
Patrick


--------------000009030309030704020409
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/10/18 21:57:18+02:00 kaber@coreworks.de 
#   [XFRM]: Fix policy update bug when increasing priority of last policy
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/xfrm/xfrm_policy.c
#   2004/10/18 21:56:41+02:00 kaber@coreworks.de +1 -1
#   [XFRM]: Fix policy update bug when increasing priority of last policy
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
--- a/net/xfrm/xfrm_policy.c	2004-10-18 21:58:24 +02:00
+++ b/net/xfrm/xfrm_policy.c	2004-10-18 21:58:24 +02:00
@@ -340,7 +340,7 @@
 			}
 			*p = pol->next;
 			delpol = pol;
-			if (policy->priority > pol->priority)
+			if (policy->priority > pol->priority && *p != NULL)
 				continue;
 		} else if (policy->priority >= pol->priority)
 			continue;

--------------000009030309030704020409--
