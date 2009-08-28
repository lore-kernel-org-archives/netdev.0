From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] skb: Augment skb_copy_datagram_iovec TRACE_EVENT to
	dump more info
Date: Fri, 28 Aug 2009 19:17:09 -0400
Message-ID: <20090828231709.GA14063@hmsreliant.think-freely.org>
References: <20090828203314.GA30417@hmsreliant.think-freely.org> <alpine.DEB.2.00.0908281643190.25717@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, mingo@elte.hu
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:40628 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750921AbZH1XRN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2009 19:17:13 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0908281643190.25717@gandalf.stny.rr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 28, 2009 at 04:50:13PM -0400, Steven Rostedt wrote:
> 
> On Fri, 28 Aug 2009, Neil Horman wrote:
> 
> > Hey all-
> > 	As promised in our previous discussion, I've augmented the
> > skb_copy_datagram_iovec TRACE_EVENT to dump out the info I was previously
> > gathering in the ftrace module thats been removed.  This patch gives me
> > everything I need.  Tested and working by me
> > 
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> 
> Much better :-)
> 
Thanks :)(

> > 
> > 
> >  skb.h |   26 +++++++++++++++++++++++---
> >  1 file changed, 23 insertions(+), 3 deletions(-)
> > 
> > 
> > diff --git a/include/trace/events/skb.h b/include/trace/events/skb.h
> > index 4b2be6d..45b9a3f 100644
> > --- a/include/trace/events/skb.h
> > +++ b/include/trace/events/skb.h
> > @@ -7,6 +7,7 @@
> >  #include <linux/skbuff.h>
> >  #include <linux/netdevice.h>
> >  #include <linux/tracepoint.h>
> > +#include <net/sock.h>
> >  
> >  /*
> >   * Tracepoint for free an sk_buff:
> > @@ -42,16 +43,35 @@ TRACE_EVENT(skb_copy_datagram_iovec,
> >  	TP_ARGS(skb, len),
> >  
> >  	TP_STRUCT__entry(
> > -		__field(	const void *,		skbaddr		)
> > +		__field(	const struct sk_buff *,	skb		)
> >  		__field(	int,			len		)
> > +		__field(	int,			anid		)
> > +		__field(	int,			cnid		)
> > +		__field(	int,			rx_queue	)
> > +		__dynamic_array(char,		name,	IFNAMSIZ	)
> 
> For string fields we have a __string macro:
> 
> 		__string(	char,			name		)
> 
Yeah, I was going to use that, but I ran into an issue, in that the __string
macro expects, as its second of two arguments, a pointer to a string with witch
to determine the dynamic arrays size.  The problem is that, if I'm to provide
that, I need to point it to skb->dev->name, and there is no guarantee that
skb->dev isn't NULL, at which point I think the use of string breaks down.  Note
below that I obtain the dev pointer by other means and check its validity prior
to assigning it.  If theres a better way to do this, please let me know.
 
> >  	),
> >  
> >  	TP_fast_assign(
> > -		__entry->skbaddr = skb;
> > +		struct net_device *dev = NULL;
> > +		__entry->skb = skb;
> >  		__entry->len = len;
> > +		__entry->anid = page_to_nid(virt_to_page(skb->data));
> > +		__entry->cnid = cpu_to_node(smp_processor_id());
> > +		__entry->rx_queue = skb->queue_mapping;
> > +		if (skb->sk) {
> > +			dev = dev_get_by_index(sock_net(skb->sk), skb->iif);
> > +		}
> 
> Nitpick, but this should still use normal Linux styling:
> 
> 		if (skb->sk)
> 			dev = dev_get_by_index(sock_net(skb->sk), skb->iif);
> 
> 
Sure
> > +		if (dev) {
> > +			__assign_str(name, dev->name);
> > +			dev_put(dev);
> > +		} else {
> > +			__assign_str(name, "Unknown");
> > +		}
> 
> And remove the extra braces here too.
> 
Sure

> >  	),
> >  
> > -	TP_printk("skbaddr=%p len=%d", __entry->skbaddr, __entry->len)
> > +	TP_printk("skb=%p anid=%d cnid=%d len=%d rx_queue=%d name=%s",
> > +			__entry->skb, __entry->anid, __entry->cnid,
> > +			__entry->len, __entry->rx_queue, __get_str(name))
> >  );
> >  
> >  #endif /* _TRACE_SKB_H */
> > 
> 
> Other than that, this looks good.
> 
> Acked-by: Steven Rostedt <rostedt@goodmis.org>
> 
Thanks, Heres an updated patch with the nits fixed.  If you want to go over a
better way to size strings when the source string isn't immediately available,
I'll send  a subsequent patch to fix that

New version of the patch:

Augment the skb_copy_datagram_iovec TRACE_EVENT to provide same data output as
the ftracer for skb numa node correlation that was recently removed.

Change notes:

1) Cleaned up the nits Steven mentioned above

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 skb.h |   24 +++++++++++++++++++++---
 1 file changed, 21 insertions(+), 3 deletions(-)


diff --git a/include/trace/events/skb.h b/include/trace/events/skb.h
index 4b2be6d..7d57bfa 100644
--- a/include/trace/events/skb.h
+++ b/include/trace/events/skb.h
@@ -7,6 +7,7 @@
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
 #include <linux/tracepoint.h>
+#include <net/sock.h>
 
 /*
  * Tracepoint for free an sk_buff:
@@ -42,16 +43,33 @@ TRACE_EVENT(skb_copy_datagram_iovec,
 	TP_ARGS(skb, len),
 
 	TP_STRUCT__entry(
-		__field(	const void *,		skbaddr		)
+		__field(	const struct sk_buff *,	skb		)
 		__field(	int,			len		)
+		__field(	int,			anid		)
+		__field(	int,			cnid		)
+		__field(	int,			rx_queue	)
+		__dynamic_array(char,		name,	IFNAMSIZ	)
 	),
 
 	TP_fast_assign(
-		__entry->skbaddr = skb;
+		struct net_device *dev = NULL;
+		__entry->skb = skb;
 		__entry->len = len;
+		__entry->anid = page_to_nid(virt_to_page(skb->data));
+		__entry->cnid = cpu_to_node(smp_processor_id());
+		__entry->rx_queue = skb->queue_mapping;
+		if (skb->sk)
+			dev = dev_get_by_index(sock_net(skb->sk), skb->iif);
+		if (dev) {
+			__assign_str(name, dev->name);
+			dev_put(dev);
+		} else
+			__assign_str(name, "Unknown");
 	),
 
-	TP_printk("skbaddr=%p len=%d", __entry->skbaddr, __entry->len)
+	TP_printk("skb=%p anid=%d cnid=%d len=%d rx_queue=%d name=%s",
+			__entry->skb, __entry->anid, __entry->cnid,
+			__entry->len, __entry->rx_queue, __get_str(name))
 );
 
 #endif /* _TRACE_SKB_H */
> 
> 
> 
