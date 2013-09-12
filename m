From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next v4 1/6] bonding: simplify and use RCU protection
 for 3ad xmit path
Date: Thu, 12 Sep 2013 09:17:33 -0700
Message-ID: <20130912161733.GQ3966@linux.vnet.ibm.com>
References: <52298407.9040103@huawei.com>
 <20130907142041.GA20237@redhat.com>
 <522B3BF1.2020208@redhat.com>
 <20130907150350.GF26163@redhat.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nikolay Aleksandrov <nikolay@redhat.com>,
	Ding Tianhong <dingtianhong@huawei.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:44170 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753577Ab3ILQSF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Sep 2013 12:18:05 -0400
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 12 Sep 2013 12:18:04 -0400
Received: from b01cxnp23034.gho.pok.ibm.com (b01cxnp23034.gho.pok.ibm.com [9.57.198.29])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id D7784C90045
	for <netdev@vger.kernel.org>; Thu, 12 Sep 2013 12:17:59 -0400 (EDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b01cxnp23034.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8CGHxU559834420
	for <netdev@vger.kernel.org>; Thu, 12 Sep 2013 16:17:59 GMT
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r8CGKZ4J021628
	for <netdev@vger.kernel.org>; Thu, 12 Sep 2013 10:20:36 -0600
Content-Disposition: inline
In-Reply-To: <20130907150350.GF26163@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 07, 2013 at 05:03:50PM +0200, Veaceslav Falico wrote:
> On Sat, Sep 07, 2013 at 04:45:05PM +0200, Nikolay Aleksandrov wrote:
> >
> >On 09/07/2013 04:20 PM, Veaceslav Falico wrote:
> >>On Fri, Sep 06, 2013 at 03:28:07PM +0800, Ding Tianhong wrote:
> ...snip...
> >>diff --git a/include/linux/rculist.h b/include/linux/rculist.h
> >>index f4b1001..37b49d1 100644
> >>--- a/include/linux/rculist.h
> >>+++ b/include/linux/rculist.h
> >>@@ -23,6 +23,7 @@
> >>  * way, we must not access it directly
> >>  */
> >> #define list_next_rcu(list)    (*((struct list_head __rcu
> >>**)(&(list)->next)))
> >>+#define list_prev_rcu(list)    (*((struct list_head __rcu
> >>**)(&(list)->prev)))
> >>
> >> /*
> >>  * Insert a new entry between two known consecutive entries.
> >>@@ -271,6 +272,12 @@ static inline void list_splice_init_rcu(struct
> >>list_head *list,
> >>       likely(__ptr != __next) ? container_of(__next, type, member) : NULL; \
> >>     })
> >>
> >>+#define list_last_or_null_rcu(ptr, type, member) \
> >>+    ({struct list_head *__ptr = (ptr); \
> >>+      struct list_head __rcu *__last = list_prev_rcu(__ptr); \
> >>+      likely(__ptr != __last) ? container_of(__prev, type, member) : NULL; \
> >>+    })
> >>+
> >Hi,
> >Actually I don't think you can dereference ->prev and use the standard
> >list_del_rcu because it guarantees only the ->next ptr will be valid and
> >->prev is set to LIST_POISON2.
> >IMO, you'll need something like this: https://lkml.org/lkml/2012/7/25/193
> >with the bidir_del and all that.
> 
> Yeah, right, my bad - we can rely only on the ->next pointer, indeed,
> missed that part. RCU is hard :).
> 
> So it'll be a lot harder to implement bond_last_slave_rcu() in a
> 'straightforward' approach.
> 
> I'd rather go in the opposite direction here - i.e. drop the 'reverse'
> traversal completely, and all the use cases for bond_last_slave_rcu(). I've
> got some patches already - http://patchwork.ozlabs.org/patch/272076/ doing
> that, and hopefully will remove the whole 'backword' traversal completely
> in the future.

If it is important, it would be possible to create an RCU-protected
linked list that allowed readers to go in both directions -- mostly just
leave out the poisoning of the ->prev pointers.  We do -not- want to
do this for the normal RCU-protected linked lists because the poisoning
does find bugs.

However, you would have to be quite careful with a bi-directional
RCU-protected linked list, because p->next->prev will not necessarily
be equal to p, for all the reasons that you guys listed out earlier in
this thread.  So be very careful what you wish for!  ;-)

							Thanx, Paul

> >But in any case I complete agree with Veaceslav here. Read all the
> >documentation carefully :-)
> >
> >Cheers,
> >Nik
> >
> >> /**
> >>  * list_for_each_entry_rcu    -    iterate over rcu list of given type
> >>  * @pos:    the type * to use as a loop cursor.
> >>------- END OF PATCH ------
> >>
> >>Anyway, it's up to you.
> >>
> >>Hope that helps.
> >
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
