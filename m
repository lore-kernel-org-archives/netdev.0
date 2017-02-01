From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net: suspicious RCU usage in nf_hook
Date: Wed, 01 Feb 2017 15:59:43 -0800
Message-ID: <1485993583.6360.172.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CACT4Y+bpmwj1WH7g6inQBm+7PvHepv9tTmYBUqkJYFvquGDYCQ@mail.gmail.com>
         <1485560124.6360.74.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpVvBPhP4q=Egsaoqf8ym-73jLZow8xDMbOq9RhYmL5XAQ@mail.gmail.com>
         <1485567090.6360.92.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpXiQMH1zMJM6sYFNUySUYjaHnLZ3T2d34GwCMQ9u6RkwQ@mail.gmail.com>
         <1485877498.6360.115.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpWnJbN=65D8PAxe7B_kBf7+Ay2M59T8brF0aXkfEbgnPg@mail.gmail.com>
         <1485983770.6360.158.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpWSpgNnEOn+euZAMEmdQCfDVcgk9EO=k5-kVEkB+EJrpg@mail.gmail.com>
         <CANn89iJb55jCppc9J=vL9n=7ofr1LSz3d+nKNo4W-BJeoH0m3A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        netfilter-devel@vger.kernel.org,
        syzkaller <syzkaller@googlegroups.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CANn89iJb55jCppc9J=vL9n=7ofr1LSz3d+nKNo4W-BJeoH0m3A@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-02-01 at 15:48 -0800, Eric Dumazet wrote:
> On Wed, Feb 1, 2017 at 3:29 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> 
> > Not sure if it is better. The difference is caught up in net_enable_timestamp(),
> > which is called setsockopt() path and sk_clone() path, so we could be
> > in netstamp_needed state for a long time too until user-space exercises
> > these paths.
> >
> > I am feeling we probably need to get rid of netstamp_needed_deferred,
> > and simply defer the whole static_key_slow_dec(), like the attached patch
> > (compile only).
> >
> > What do you think?
> 
> I think we need to keep the atomic.
> 
> If two cpus call net_disable_timestamp() roughly at the same time, the
> work will be scheduled once.

Updated patch (but not tested yet)

diff --git a/net/core/dev.c b/net/core/dev.c
index 7f218e095361520d11c243d650e053321ea7274f..29101c98399f40b6b8e42c31a255d8f1fb6bd7a1 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1695,24 +1695,19 @@ EXPORT_SYMBOL_GPL(net_dec_egress_queue);
 
 static struct static_key netstamp_needed __read_mostly;
 #ifdef HAVE_JUMP_LABEL
-/* We are not allowed to call static_key_slow_dec() from irq context
- * If net_disable_timestamp() is called from irq context, defer the
- * static_key_slow_dec() calls.
- */
 static atomic_t netstamp_needed_deferred;
-#endif
-
-void net_enable_timestamp(void)
+static void netstamp_clear(struct work_struct *work)
 {
-#ifdef HAVE_JUMP_LABEL
 	int deferred = atomic_xchg(&netstamp_needed_deferred, 0);
 
-	if (deferred) {
-		while (--deferred)
-			static_key_slow_dec(&netstamp_needed);
-		return;
-	}
+	while (deferred--)
+		static_key_slow_dec(&netstamp_needed);
+}
+static DECLARE_WORK(netstamp_work, netstamp_clear);
 #endif
+
+void net_enable_timestamp(void)
+{
 	static_key_slow_inc(&netstamp_needed);
 }
 EXPORT_SYMBOL(net_enable_timestamp);
@@ -1720,12 +1715,12 @@ EXPORT_SYMBOL(net_enable_timestamp);
 void net_disable_timestamp(void)
 {
 #ifdef HAVE_JUMP_LABEL
-	if (in_interrupt()) {
-		atomic_inc(&netstamp_needed_deferred);
-		return;
-	}
-#endif
+	/* net_disable_timestamp() can be called from non process context */
+	atomic_inc(&netstamp_needed_deferred);
+	schedule_work(&netstamp_work);
+#else
 	static_key_slow_dec(&netstamp_needed);
+#endif
 }
 EXPORT_SYMBOL(net_disable_timestamp);
 


