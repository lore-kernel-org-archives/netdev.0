From: Paul Moore <pmoore@redhat.com>
Subject: [PATCH] cipso: handle CIPSO options correctly when NetLabel is
 disabled
Date: Thu, 31 May 2012 16:09:23 -0400
Message-ID: <20120531200922.6265.81763.stgit@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-security-module@vger.kernel.org, stable@kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When NetLabel is not enabled, e.g. CONFIG_NETLABEL=n, and the system
receives a CIPSO tagged packet it is dropped (cipso_v4_validate()
returns non-zero).  In most cases this is the correct and desired
behavior, however, in the case where we are simply forwarding the
traffic, e.g. acting as a network bridge, this becomes a problem.

This patch fixes the forwarding problem by providing the basic CIPSO
validation code directly in ip_options_compile() without the need for
the NetLabel or CIPSO code.  The new validation code can not perform
any of the CIPSO option label/value verification that
cipso_v4_validate() does, but it can verify the basic CIPSO option
format.

The behavior when NetLabel is enabled is unchanged.

Signed-off-by: Paul Moore <pmoore@redhat.com>
---
 net/ipv4/ip_options.c |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index 708b994..ca2c919 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -439,10 +439,30 @@ int ip_options_compile(struct net *net,
 				goto error;
 			}
 			opt->cipso = optptr - iph;
+#ifndef CONFIG_NETLABEL
+			if (optlen < 8) {
+				pp_ptr = optptr + 1;
+				goto error;
+			}
+			if (get_unaligned_be32(&optptr[2]) != 0) {
+				unsigned int iter;
+				for (iter = 6; iter < optlen;) {
+					if (optptr[iter+1] > (optlen - iter)) {
+						pp_ptr = optptr + iter;
+						goto error;
+					}
+					iter += optptr[iter + 1];
+				}
+			} else {
+				pp_ptr = optptr + 2;
+				goto error;
+			}
+#else
 			if (cipso_v4_validate(skb, &optptr)) {
 				pp_ptr = optptr;
 				goto error;
 			}
+#endif /* CONFIG_NETLABEL */
 			break;
 		      case IPOPT_SEC:
 		      case IPOPT_SID:

