From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] PKT_SCHED: dsmark must take care of shared/cloned skbs
Date: Mon, 20 Dec 2004 00:18:24 +0100
Message-ID: <20041219231824.GS17998@postel.suug.ch>
References: <20041218170017.GH17998@postel.suug.ch> <1103487827.1048.188.camel@jzny.localdomain> <20041219203641.GL17998@postel.suug.ch> <1103496820.1049.204.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1103496820.1049.204.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1103496820.1049.204.camel@jzny.localdomain> 2004-12-19 17:53
> On Sun, 2004-12-19 at 15:36, Thomas Graf wrote:
> > * jamal <1103487827.1048.188.camel@jzny.localdomain> 2004-12-19 15:23
> > > If the qdisc at that level muddies the packet thats fair game - thats
> > > what goes out on the wire. So we should leave the code as is.
> > 
> > Agreed for egress but I think it is needed for stuff like IMQ. It's
> > debatable whether we should take care of IMQ and alike though.
> 
> You are right, it may cause an issue on an IMQ like device when we have
> one in kernel. Hang on to the patch for now is my opinion; "schedulers"
> should probably not be mucking with packets once they are queued in
> (dsmark aint really a scheduler). We should talk to Werner to see if we
> can move that functionality prequeueing ...

Fine with me, we could make the dscp mapping an action. I doubt that
there are many users out there since the ECN bits are still taken
into account which doesn't make much sense. Something like the
following patch would be required to bring back the old behaviour
which relied on the lower two bits being unused.

--- linux-2.6.10-rc3-bk12.orig/net/sched/sch_dsmark.c	2004-12-19 01:31:01.000000000 +0100
+++ linux-2.6.10-rc3-bk12/net/sched/sch_dsmark.c	2004-12-19 01:31:27.000000000 +0100
@@ -14,6 +14,7 @@
 #include <linux/rtnetlink.h>
 #include <net/pkt_sched.h>
 #include <net/dsfield.h>
+#include <net/inet_ecn.h>
 #include <asm/byteorder.h>
 
 
@@ -199,10 +200,12 @@
 		   IP/IPv6 header is always linear --TGR */
 		switch (skb->protocol) {
 			case __constant_htons(ETH_P_IP):
-				skb->tc_index = ipv4_get_dsfield(skb->nh.iph);
+				skb->tc_index = ipv4_get_dsfield(skb->nh.iph)
+					& ~INET_ECN_MASK;
 				break;
 			case __constant_htons(ETH_P_IPV6):
-				skb->tc_index = ipv6_get_dsfield(skb->nh.ipv6h);
+				skb->tc_index = ipv6_get_dsfield(skb->nh.ipv6h)
+					& ~INET_ECN_MASK;
 				break;
 			default:
 				skb->tc_index = 0;
