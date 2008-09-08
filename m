From: Greg KH <gregkh@suse.de>
Subject: Re: Linux 2.6.26.4
Date: Mon, 8 Sep 2008 09:38:01 -0700
Message-ID: <20080908163801.GA13827@suse.de>
References: <20080908143625.GC7311@suse.de> <20080908081253.d3100d88.randy.dunlap@oracle.com> <20080908152114.GA8941@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, davem@davemloft.net,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org, stable@kernel.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:60148 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752078AbYIHQil (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Sep 2008 12:38:41 -0400
Content-Disposition: inline
In-Reply-To: <20080908152114.GA8941@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 08, 2008 at 08:21:14AM -0700, Greg KH wrote:
> On Mon, Sep 08, 2008 at 08:12:53AM -0700, Randy Dunlap wrote:
> > On Mon, 8 Sep 2008 07:36:25 -0700 Greg KH wrote:
> > 
> > > We (the -stable team) are announcing the release of the 2.6.26.4
> > > kernel.
> > > 
> > > It contains lots of bugfixes, all over the map.  Any users of the 2.6.26
> > > kernel series should upgrade to this version.  For details on the fixes,
> > > see the changelog entries and the diffstat below.
> > > 
> > > I'll also be replying to this message with a copy of the patch between
> > > 2.6.26.3 and 2.6.26.4
> > > 
> > > The updated 2.6.26.y git tree can be found at:
> > >         git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-2.6.26.y.git
> > > and can be browsed at the normal kernel.org git web browser:
> > >         http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.26.y.git;a=summary
> > 
> > >  include/linux/pim.h                |   45 -----------------
> > 
> > That file is still used by ./net/ipv6/ip6mr.c:#include <linux/pim.h>
> > so there are build errors...
> 
> Crap, I messed up, David sent me the fixed patch and I forgot it.

Randy, does the patch below fix the problem?  It's an interdiff between
what I applied and what David sent me as the correct patch.

thanks,

greg k-h

-------------

diff -u b/include/linux/mroute.h b/include/linux/mroute.h
--- b/include/linux/mroute.h
+++ b/include/linux/mroute.h
@@ -2,7 +2,10 @@
 #define __LINUX_MROUTE_H
 
 #include <linux/sockios.h>
+#include <linux/types.h>
+#ifdef __KERNEL__
 #include <linux/in.h>
+#endif
 
 /*
  *	Based on the MROUTING 3.5 defines primarily to keep
@@ -126,6 +129,7 @@
  */
 
 #ifdef __KERNEL__
+#include <linux/pim.h>
 #include <net/sock.h>
 
 #ifdef CONFIG_IP_MROUTE
@@ -210,27 +214,6 @@
 #define IGMPMSG_WHOLEPKT	3		/* For PIM Register processing */
 
 #ifdef __KERNEL__
-
-#define PIM_V1_VERSION		__constant_htonl(0x10000000)
-#define PIM_V1_REGISTER		1
-
-#define PIM_VERSION		2
-#define PIM_REGISTER		1
-
-#define PIM_NULL_REGISTER	__constant_htonl(0x40000000)
-
-/* PIMv2 register message header layout (ietf-draft-idmr-pimvsm-v2-00.ps */
-
-struct pimreghdr
-{
-	__u8	type;
-	__u8	reserved;
-	__be16	csum;
-	__be32	flags;
-};
-
-extern int pim_rcv_v1(struct sk_buff *);
-
 struct rtmsg;
 extern int ipmr_get_route(struct sk_buff *skb, struct rtmsg *rtm, int nowait);
 #endif
diff -u /dev/null b/include/linux/pim.h
--- /dev/null
+++ b/include/linux/pim.h
@@ -0,0 +1,27 @@
+#ifndef __LINUX_PIM_H
+#define __LINUX_PIM_H
+
+#include <asm/byteorder.h>
+
+/* Message types - V1 */
+#define PIM_V1_VERSION		__constant_htonl(0x10000000)
+#define PIM_V1_REGISTER		1
+
+/* Message types - V2 */
+#define PIM_VERSION		2
+#define PIM_REGISTER		1
+
+#define PIM_NULL_REGISTER	__constant_htonl(0x40000000)
+
+/* PIMv2 register message header layout (ietf-draft-idmr-pimvsm-v2-00.ps */
+struct pimreghdr
+{
+	__u8	type;
+	__u8	reserved;
+	__be16	csum;
+	__be32	flags;
+};
+
+struct sk_buff;
+extern int pim_rcv_v1(struct sk_buff *);
+#endif
only in patch2:
unchanged:
--- a/include/linux/mroute6.h
+++ b/include/linux/mroute6.h
@@ -115,6 +115,7 @@ struct sioc_mif_req6
 
 #ifdef __KERNEL__
 
+#include <linux/pim.h>
 #include <linux/skbuff.h>	/* for struct sk_buff_head */
 
 #ifdef CONFIG_IPV6_MROUTE
