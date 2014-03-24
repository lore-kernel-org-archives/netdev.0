From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] drivers/net: Use RCU_INIT_POINTER(x, NULL) in tun.c
Date: Mon, 24 Mar 2014 08:22:25 +0200
Message-ID: <20140324062225.GA22338@redhat.com>
References: <1395599552-7486-1-git-send-email-monamagarwal123@gmail.com>
 <20140323194113.GA13633@redhat.com>
 <1395604457.9117.21.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140323213349.GA8832@redhat.com>
 <20140323221256.GG4405@linux.vnet.ibm.com>
 <20140324050939.GB8832@redhat.com>
 <1395638727.9117.55.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Monam Agarwal <monamagarwal123@gmail.com>, davem@davemloft.net,
	jasowang@redhat.com, xemul@parallels.com, wuzhy@linux.vnet.ibm.com,
	therbert@google.com, yamato@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1395638727.9117.55.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 23, 2014 at 10:25:27PM -0700, Eric Dumazet wrote:
> On Mon, 2014-03-24 at 07:09 +0200, Michael S. Tsirkin wrote:
> 
> > Seems an incredibly strict requirement for something that just
> > silences a warning.
> > What exactly should I test?
> > I intended to just verify this produces same code as before
> > d322f45ceed525daa under a recent gcc.
> 
> Thats because many rcu_assign_pointer(X, NULL) were already converted to
> RCU_INIT_POINTER(X, NULL)
> 
> Quite frankly I don't know why you bother at all.
> 
> Adding back the lazy test in rcu_assign_pointer() doesn't help to make
> the API cleaner and easier to understand.
> 
> People are usually using RCU API without really understanding
> all the issues. They tend to add superfluous barriers because they feel
> better. 

Cute.  This is exactly what d322f45ceed525daa did actually -
made the barrier unconditional even when not needed.

> Having separate RCU_INIT_POINTER() and rcu_assign_pointer() serve as
> better documentation of the code, I find it more easier to immediately
> check what is going on while reviewing stuff.
> 
> Presumably, checkpatch.pl could be augmented to suggest to use
> RCU_INIT_POINTER(X, NULL) instead of rcu_assign_pointer(X, NULL)
> 
> 


What happens if someone then changes that NULL to something else?
Things will start to break in subtle way, won't they?

To me RCU_INIT_POINTER seems to say "safe to use when initializing
pointer field when no one can access the structure".
The patch that started it all changed a path that clearly
does not satisfy this: it is mutating a field not initializing
it before use. After looking at the implementation, it does
seem safe.  So if some people actually like this API, I don't mind.
A matter of taste I guess.

If someone still wants to make rcu_assign_pointer more optimal, without
a warning, I see a cleaner way to do this now, below.
Lightly tested - if someone sees value in this but requires more testing, let me know,
if no one responds I'll just drop the whole thing.

--->

rcu: optimize rcu_assign_pointer with NULL

The rcu_assign_pointer() dropped __builtin_constant_p check to
avoid a compiler warning, but we can actually work around it
using an inline wrapper, without adding code.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

---

diff --git a/include/linux/rcupdate.h b/include/linux/rcupdate.h
index 72bf3a0..0d45b6d 100644
--- a/include/linux/rcupdate.h
+++ b/include/linux/rcupdate.h
@@ -585,9 +585,18 @@ static inline void rcu_preempt_sleep_check(void)
  * please be careful when making changes to rcu_assign_pointer() and the
  * other macros that it invokes.
  */
+/* The inline wrapper is here to prevent gcc from emitting a warning when
+ * passed a pointer to a variable.
+ */
+static inline _rcu_safe_smp_wmb_unless_null(const void *v)
+{
+	if (!__builtin_constant_p(v) || ((v) != NULL))
+		smp_wmb();
+}
+
 #define rcu_assign_pointer(p, v) \
 	do { \
-		smp_wmb(); \
+		_rcu_safe_smp_wmb_unless_null((__force const void *)(v)); \
 		ACCESS_ONCE(p) = RCU_INITIALIZER(v); \
 	} while (0)
 
