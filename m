From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 1/4] inet6: Return convention in datagram_send_ctl
Date: Sun, 19 Jul 2009 20:23:36 +0200
Message-ID: <1248027819-23959-2-git-send-email-gerrit@erg.abdn.ac.uk>
References: <inet6_minor_cleanups>
 <1248027819-23959-1-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: netdev@vger.kernel.org, Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:54984 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751091AbZGSSiY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Jul 2009 14:38:24 -0400
In-Reply-To: <1248027819-23959-1-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current code has both return conventions for errors
 * set err = 'errval' and then goto exit_f,
 * return 'errval' directly.
This patch reduces the number of alternatives to one.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/ipv6/datagram.c |  156 ++++++++++++++++++---------------------------------
 1 files changed, 55 insertions(+), 101 deletions(-)

--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -505,15 +505,12 @@ int datagram_send_ctl(struct net *net,
 	struct ipv6_rt_hdr *rthdr;
 	struct ipv6_opt_hdr *hdr;
 	int len;
-	int err = 0;
 
 	for (cmsg = CMSG_FIRSTHDR(msg); cmsg; cmsg = CMSG_NXTHDR(msg, cmsg)) {
 		int addr_type;
 
-		if (!CMSG_OK(msg, cmsg)) {
-			err = -EINVAL;
-			goto exit_f;
-		}
+		if (!CMSG_OK(msg, cmsg))
+			return -EINVAL;
 
 		if (cmsg->cmsg_level != SOL_IPV6)
 			continue;
@@ -524,10 +521,8 @@ int datagram_send_ctl(struct net *net,
 		    {
 			struct net_device *dev = NULL;
 
-			if (cmsg->cmsg_len < CMSG_LEN(sizeof(struct in6_pktinfo))) {
-				err = -EINVAL;
-				goto exit_f;
-			}
+			if (cmsg->cmsg_len < CMSG_LEN(sizeof(struct in6_pktinfo)))
+				return -EINVAL;
 
 			src_info = (struct in6_pktinfo *)CMSG_DATA(cmsg);
 
@@ -548,99 +543,76 @@ int datagram_send_ctl(struct net *net,
 
 			if (addr_type != IPV6_ADDR_ANY) {
 				int strict = __ipv6_addr_src_scope(addr_type) <= IPV6_ADDR_SCOPE_LINKLOCAL;
-				if (!ipv6_chk_addr(net, &src_info->ipi6_addr,
-						   strict ? dev : NULL, 0))
-					err = -EINVAL;
-				else
-					ipv6_addr_copy(&fl->fl6_src, &src_info->ipi6_addr);
+				if (!ipv6_chk_addr(net, &src_info->ipi6_addr, strict ? dev : NULL, 0))
+					return -EINVAL;
+				ipv6_addr_copy(&fl->fl6_src, &src_info->ipi6_addr);
 			}
 
 			if (dev)
 				dev_put(dev);
 
-			if (err)
-				goto exit_f;
-
 			break;
 		    }
 
 		case IPV6_FLOWINFO:
-			if (cmsg->cmsg_len < CMSG_LEN(4)) {
-				err = -EINVAL;
-				goto exit_f;
-			}
+			if (cmsg->cmsg_len < CMSG_LEN(4))
+				return -EINVAL;
 
 			if (fl->fl6_flowlabel&IPV6_FLOWINFO_MASK) {
-				if ((fl->fl6_flowlabel^*(__be32 *)CMSG_DATA(cmsg))&~IPV6_FLOWINFO_MASK) {
-					err = -EINVAL;
-					goto exit_f;
-				}
+				if ((fl->fl6_flowlabel^*(__be32 *)CMSG_DATA(cmsg))&~IPV6_FLOWINFO_MASK)
+					return -EINVAL;
 			}
 			fl->fl6_flowlabel = IPV6_FLOWINFO_MASK & *(__be32 *)CMSG_DATA(cmsg);
 			break;
 
 		case IPV6_2292HOPOPTS:
 		case IPV6_HOPOPTS:
-			if (opt->hopopt || cmsg->cmsg_len < CMSG_LEN(sizeof(struct ipv6_opt_hdr))) {
-				err = -EINVAL;
-				goto exit_f;
-			}
+			if (opt->hopopt || cmsg->cmsg_len < CMSG_LEN(sizeof(struct ipv6_opt_hdr)))
+				return -EINVAL;
 
 			hdr = (struct ipv6_opt_hdr *)CMSG_DATA(cmsg);
 			len = ((hdr->hdrlen + 1) << 3);
-			if (cmsg->cmsg_len < CMSG_LEN(len)) {
-				err = -EINVAL;
-				goto exit_f;
-			}
-			if (!capable(CAP_NET_RAW)) {
-				err = -EPERM;
-				goto exit_f;
-			}
+
+			if (cmsg->cmsg_len < CMSG_LEN(len))
+				return -EINVAL;
+			if (!capable(CAP_NET_RAW))
+				return -EPERM;
+
 			opt->opt_nflen += len;
 			opt->hopopt = hdr;
 			break;
 
 		case IPV6_2292DSTOPTS:
-			if (cmsg->cmsg_len < CMSG_LEN(sizeof(struct ipv6_opt_hdr))) {
-				err = -EINVAL;
-				goto exit_f;
-			}
+			if (cmsg->cmsg_len < CMSG_LEN(sizeof(struct ipv6_opt_hdr)))
+				return -EINVAL;
 
 			hdr = (struct ipv6_opt_hdr *)CMSG_DATA(cmsg);
 			len = ((hdr->hdrlen + 1) << 3);
-			if (cmsg->cmsg_len < CMSG_LEN(len)) {
-				err = -EINVAL;
-				goto exit_f;
-			}
-			if (!capable(CAP_NET_RAW)) {
-				err = -EPERM;
-				goto exit_f;
-			}
-			if (opt->dst1opt) {
-				err = -EINVAL;
-				goto exit_f;
-			}
+
+			if (cmsg->cmsg_len < CMSG_LEN(len))
+				return -EINVAL;
+			if (!capable(CAP_NET_RAW))
+				return -EPERM;
+			if (opt->dst1opt)
+				return -EINVAL;
+
 			opt->opt_flen += len;
 			opt->dst1opt = hdr;
 			break;
 
 		case IPV6_DSTOPTS:
 		case IPV6_RTHDRDSTOPTS:
-			if (cmsg->cmsg_len < CMSG_LEN(sizeof(struct ipv6_opt_hdr))) {
-				err = -EINVAL;
-				goto exit_f;
-			}
+			if (cmsg->cmsg_len < CMSG_LEN(sizeof(struct ipv6_opt_hdr)))
+				return -EINVAL;
 
 			hdr = (struct ipv6_opt_hdr *)CMSG_DATA(cmsg);
 			len = ((hdr->hdrlen + 1) << 3);
-			if (cmsg->cmsg_len < CMSG_LEN(len)) {
-				err = -EINVAL;
-				goto exit_f;
-			}
-			if (!capable(CAP_NET_RAW)) {
-				err = -EPERM;
-				goto exit_f;
-			}
+			if (cmsg->cmsg_len < CMSG_LEN(len))
+				return -EINVAL;
+
+			if (!capable(CAP_NET_RAW))
+				return -EPERM;
+
 			if (cmsg->cmsg_type == IPV6_DSTOPTS) {
 				opt->opt_flen += len;
 				opt->dst1opt = hdr;
@@ -652,10 +624,8 @@ int datagram_send_ctl(struct net *net,
 
 		case IPV6_2292RTHDR:
 		case IPV6_RTHDR:
-			if (cmsg->cmsg_len < CMSG_LEN(sizeof(struct ipv6_rt_hdr))) {
-				err = -EINVAL;
-				goto exit_f;
-			}
+			if (cmsg->cmsg_len < CMSG_LEN(sizeof(struct ipv6_rt_hdr)))
+				return -EINVAL;
 
 			rthdr = (struct ipv6_rt_hdr *)CMSG_DATA(cmsg);
 
@@ -663,29 +633,22 @@ int datagram_send_ctl(struct net *net,
 #if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
 			case IPV6_SRCRT_TYPE_2:
 				if (rthdr->hdrlen != 2 ||
-				    rthdr->segments_left != 1) {
-					err = -EINVAL;
-					goto exit_f;
-				}
+				    rthdr->segments_left != 1)
+					return -EINVAL;
 				break;
 #endif
 			default:
-				err = -EINVAL;
-				goto exit_f;
+				return -EINVAL;
 			}
 
 			len = ((rthdr->hdrlen + 1) << 3);
 
-			if (cmsg->cmsg_len < CMSG_LEN(len)) {
-				err = -EINVAL;
-				goto exit_f;
-			}
+			if (cmsg->cmsg_len < CMSG_LEN(len))
+				return -EINVAL;
 
 			/* segments left must also match */
-			if ((rthdr->hdrlen >> 1) != rthdr->segments_left) {
-				err = -EINVAL;
-				goto exit_f;
-			}
+			if ((rthdr->hdrlen >> 1) != rthdr->segments_left)
+				return -EINVAL;
 
 			opt->opt_nflen += len;
 			opt->srcrt = rthdr;
@@ -703,16 +666,12 @@ int datagram_send_ctl(struct net *net,
 
 		case IPV6_2292HOPLIMIT:
 		case IPV6_HOPLIMIT:
-			if (cmsg->cmsg_len != CMSG_LEN(sizeof(int))) {
-				err = -EINVAL;
-				goto exit_f;
-			}
+			if (cmsg->cmsg_len != CMSG_LEN(sizeof(int)))
+				return -EINVAL;
 
 			*hlimit = *(int *)CMSG_DATA(cmsg);
-			if (*hlimit < -1 || *hlimit > 0xff) {
-				err = -EINVAL;
-				goto exit_f;
-			}
+			if (*hlimit < -1 || *hlimit > 0xff)
+				return -EINVAL;
 
 			break;
 
@@ -720,16 +679,13 @@ int datagram_send_ctl(struct net *net,
 		    {
 			int tc;
 
-			err = -EINVAL;
-			if (cmsg->cmsg_len != CMSG_LEN(sizeof(int))) {
-				goto exit_f;
-			}
+			if (cmsg->cmsg_len != CMSG_LEN(sizeof(int)))
+				return -EINVAL;
 
 			tc = *(int *)CMSG_DATA(cmsg);
 			if (tc < -1 || tc > 0xff)
-				goto exit_f;
+				return -EINVAL;
 
-			err = 0;
 			*tclass = tc;
 
 			break;
@@ -737,11 +693,9 @@ int datagram_send_ctl(struct net *net,
 		default:
 			LIMIT_NETDEBUG(KERN_DEBUG "invalid cmsg type: %d\n",
 				       cmsg->cmsg_type);
-			err = -EINVAL;
-			goto exit_f;
+			return -EINVAL;
 		}
 	}
 
-exit_f:
-	return err;
+	return 0;
 }
