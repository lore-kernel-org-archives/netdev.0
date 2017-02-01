From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net: suspicious RCU usage in nf_hook
Date: Wed, 01 Feb 2017 13:16:10 -0800
Message-ID: <1485983770.6360.158.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CACT4Y+bpmwj1WH7g6inQBm+7PvHepv9tTmYBUqkJYFvquGDYCQ@mail.gmail.com>
         <1485560124.6360.74.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpVvBPhP4q=Egsaoqf8ym-73jLZow8xDMbOq9RhYmL5XAQ@mail.gmail.com>
         <1485567090.6360.92.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpXiQMH1zMJM6sYFNUySUYjaHnLZ3T2d34GwCMQ9u6RkwQ@mail.gmail.com>
         <1485877498.6360.115.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpWnJbN=65D8PAxe7B_kBf7+Ay2M59T8brF0aXkfEbgnPg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Vyukov <dvyukov@google.com>,
        David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Eric Dumazet <edumazet@google.com>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        netfilter-devel@vger.kernel.org,
        syzkaller <syzkaller@googlegroups.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpWnJbN=65D8PAxe7B_kBf7+Ay2M59T8brF0aXkfEbgnPg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-02-01 at 12:51 -0800, Cong Wang wrote:
> On Tue, Jan 31, 2017 at 7:44 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Mon, 2017-01-30 at 22:19 -0800, Cong Wang wrote:
> >
> >>
> >> The context is process context (TX path before hitting qdisc), and
> >> BH is not disabled, so in_interrupt() doesn't catch it. Hmm, this
> >> makes me thinking maybe we really need to disable BH in this
> >> case for nf_hook()? But it is called in RX path too, and BH is
> >> already disabled there.
> >
> > ipt_do_table() and similar netfilter entry points disable BH.
> >
> > Maybe it is done too late.
> 
> I think we need a fix like the following one for minimum impact.
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 727b6fd..eee7d63 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1720,12 +1720,10 @@ EXPORT_SYMBOL(net_enable_timestamp);
>  void net_disable_timestamp(void)
>  {
>  #ifdef HAVE_JUMP_LABEL
> -       if (in_interrupt()) {
> -               atomic_inc(&netstamp_needed_deferred);
> -               return;
> -       }
> -#endif
> +       atomic_inc(&netstamp_needed_deferred);
> +#else
>         static_key_slow_dec(&netstamp_needed);
> +#endif
>  }
>  EXPORT_SYMBOL(net_disable_timestamp);

This would permanently leave the kernel in the netstamp_needed state.

I would prefer the patch using a process context to perform the
cleanup ? Note there is a race window, but probably not a big deal.

 net/core/dev.c |   30 ++++++++++--------------------
 1 file changed, 10 insertions(+), 20 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 7f218e095361520d11c243d650e053321ea7274f..1cae681b6cfd1cf2c9bee7072eb8af9cf79cced8 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1695,37 +1695,27 @@ EXPORT_SYMBOL_GPL(net_dec_egress_queue);
 
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
 
 void net_disable_timestamp(void)
 {
-#ifdef HAVE_JUMP_LABEL
-	if (in_interrupt()) {
-		atomic_inc(&netstamp_needed_deferred);
-		return;
-	}
-#endif
-	static_key_slow_dec(&netstamp_needed);
+	atomic_inc(&netstamp_needed_deferred);
+	schedule_work(&netstamp_work);
 }
 EXPORT_SYMBOL(net_disable_timestamp);
 
