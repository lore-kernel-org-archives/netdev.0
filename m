From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH net v2 1/4] net/core: relax BUILD_BUG_ON in
 netdev_stats_to_stats64
Date: Sat, 30 Jan 2016 15:53:05 -0500
Message-ID: <20160130205305.GR59058@redhat.com>
References: <1453996188-29965-1-git-send-email-jarod@redhat.com>
 <1454177982-32870-1-git-send-email-jarod@redhat.com>
 <1454178872.7627.136.camel@edumazet-glaptop2.roam.corp.google.com>
 <20160130203900.GQ59058@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160130203900.GQ59058@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 30, 2016 at 03:39:01PM -0500, Jarod Wilson wrote:
> On Sat, Jan 30, 2016 at 10:34:32AM -0800, Eric Dumazet wrote:
> > On Sat, 2016-01-30 at 13:19 -0500, Jarod Wilson wrote:
> > > The netdev_stats_to_stats64 function copies the deprecated
> > > net_device_stats format stats into rtnl_link_stats64 for legacy support
> > > purposes, but with the BUILD_BUG_ON as it was, it wasn't possible to
> > > extend rtnl_link_stats64 without also extending net_device_stats. Relax
> > > the BUILD_BUG_ON to only require that rtnl_link_stats64 is larger, and
> > > zero out all the stat counters that aren't present in net_device_stats.
> > > 
> > > CC: Eric Dumazet <edumazet@google.com>
> > > CC: netdev@vger.kernel.org
> > > Signed-off-by: Jarod Wilson <jarod@redhat.com>
> > > ---
> > > Re-re-sending, hopefully getting the patch to the right list this time.
> > > 
> > >  net/core/dev.c | 13 +++++++++----
> > >  1 file changed, 9 insertions(+), 4 deletions(-)
> > > 
> > > diff --git a/net/core/dev.c b/net/core/dev.c
> > > index 8cba3d8..575a7df 100644
> > > --- a/net/core/dev.c
> > > +++ b/net/core/dev.c
> > > @@ -7253,25 +7253,30 @@ void netdev_run_todo(void)
> > >  	}
> > >  }
> > >  
> > > -/* Convert net_device_stats to rtnl_link_stats64.  They have the same
> > > - * fields in the same order, with only the type differing.
> > > +/* Convert net_device_stats to rtnl_link_stats64. rtnl_link_stats64 has
> > > + * all the same fields in the same order as net_device_stats, with only
> > > + * the type differing, but rtnl_link_stats64 may have additional fields
> > > + * at the end for newer counters.
> > >   */
> > >  void netdev_stats_to_stats64(struct rtnl_link_stats64 *stats64,
> > >  			     const struct net_device_stats *netdev_stats)
> > >  {
> > >  #if BITS_PER_LONG == 64
> > > -	BUILD_BUG_ON(sizeof(*stats64) != sizeof(*netdev_stats));
> > > +	BUILD_BUG_ON(sizeof(*stats64) < sizeof(*netdev_stats));
> > >  	memcpy(stats64, netdev_stats, sizeof(*stats64));
> > >  #else
> > >  	size_t i, n = sizeof(*stats64) / sizeof(u64);
> > >  	const unsigned long *src = (const unsigned long *)netdev_stats;
> > >  	u64 *dst = (u64 *)stats64;
> > >  
> > > -	BUILD_BUG_ON(sizeof(*netdev_stats) / sizeof(unsigned long) !=
> > > +	BUILD_BUG_ON(sizeof(*netdev_stats) / sizeof(unsigned long) >
> > >  		     sizeof(*stats64) / sizeof(u64));
> > >  	for (i = 0; i < n; i++)
> > >  		dst[i] = src[i];
> > >  #endif
> > > +	/* zero out counters that only exist in rtnl_link_stats64 */
> > > +	memset((char *)stats64 + sizeof(*netdev_stats), 0,
> > > +	       sizeof(*stats64) - sizeof(*netdev_stats));
> > 
> > Are you sure it works on 32bit arches ?
> 
> Ew, no, it won't work correctly on 32-bit. The for loop is going to copy
> data into dst from beyond the end of netdev_stats, and the range looks
> like it won't be right either, only half of the added stats64 space will
> get zeroed out. Okay, I'll fix that up correctly.

Completely untested as of yet, but I think something like the following
looks correct. I'll give it a spin as soon as I can.

diff --git a/net/core/dev.c b/net/core/dev.c
index 8cba3d8..65863e5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -7253,24 +7253,31 @@ void netdev_run_todo(void)
 	}
 }
 
-/* Convert net_device_stats to rtnl_link_stats64.  They have the same
- * fields in the same order, with only the type differing.
+/* Convert net_device_stats to rtnl_link_stats64. rtnl_link_stats64 has
+ * all the same fields in the same order as net_device_stats, with only
+ * the type differing, but rtnl_link_stats64 may have additional fields
+ * at the end for newer counters.
  */
 void netdev_stats_to_stats64(struct rtnl_link_stats64 *stats64,
 			     const struct net_device_stats *netdev_stats)
 {
 #if BITS_PER_LONG == 64
-	BUILD_BUG_ON(sizeof(*stats64) != sizeof(*netdev_stats));
+	BUILD_BUG_ON(sizeof(*stats64) < sizeof(*netdev_stats));
 	memcpy(stats64, netdev_stats, sizeof(*stats64));
+	/* zero out counters that only exist in rtnl_link_stats64 */
+	memset((char *)stats64 + sizeof(*netdev_stats), 0,
+	       sizeof(*stats64) - sizeof(*netdev_stats));
 #else
-	size_t i, n = sizeof(*stats64) / sizeof(u64);
+	size_t i, n = sizeof(*netdev_stats) / sizeof(unsigned long);
 	const unsigned long *src = (const unsigned long *)netdev_stats;
 	u64 *dst = (u64 *)stats64;
 
-	BUILD_BUG_ON(sizeof(*netdev_stats) / sizeof(unsigned long) !=
-		     sizeof(*stats64) / sizeof(u64));
+	BUILD_BUG_ON(n > sizeof(*stats64) / sizeof(u64));
 	for (i = 0; i < n; i++)
 		dst[i] = src[i];
+	/* zero out counters that only exist in rtnl_link_stats64 */
+	memset((char *)stats64 + n * sizeof(u64), 0,
+	       sizeof(*stats64) - n * sizeof(u64));
 #endif
 }
 EXPORT_SYMBOL(netdev_stats_to_stats64);

-- 
Jarod Wilson
jarod@redhat.com
