From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: [PATCH] dccp: handle invalid feature options length
Date: Fri, 06 May 2011 09:27:18 -0400
Message-ID: <1304688438.29544.16.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, security@kernel.org
To: gerrit@erg.abdn.ac.uk, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A length of zero (after subtracting two for the type and len fields) for
the DCCPO_{CHANGE,CONFIRM}_{L,R} options will cause an underflow due to
the subtraction.  The subsequent code may read past the end of the
options value buffer when parsing.  I'm unsure of what the consequences
of this might be, but it's probably not good.

Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>
Cc: stable@kernel.org
---
 net/dccp/options.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/dccp/options.c b/net/dccp/options.c
index f06ffcf..4b2ab65 100644
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -123,6 +123,8 @@ int dccp_parse_options(struct sock *sk, struct dccp_request_sock *dreq,
 		case DCCPO_CHANGE_L ... DCCPO_CONFIRM_R:
 			if (pkt_type == DCCP_PKT_DATA)      /* RFC 4340, 6 */
 				break;
+			if (len == 0)
+				goto out_invalid_option;
 			rc = dccp_feat_parse_options(sk, dreq, mandatory, opt,
 						    *value, value + 1, len - 1);
 			if (rc)
