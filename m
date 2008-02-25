From: "Hawkes Steve-FSH016" <Steve.Hawkes@motorola.com>
Subject: RE: printk_ratelimit and net_ratelimit conflict and tunable behavior
Date: Mon, 25 Feb 2008 09:47:11 -0600
Message-ID: <7BFDACCD6948EF4D8FE8F4888A91596A016371FA@tx14exm60.ds.mot.com>
References: <7BFDACCD6948EF4D8FE8F4888A91596A016371E8@tx14exm60.ds.mot.com> <20080220.223219.165157596.davem@davemloft.net> <1203577246.7181.241.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: "Joe Perches" <joe@perches.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757393AbYBYPrc@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <1203577246.7181.241.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches wrote:
> 
> On Wed, 2008-02-20 at 22:32 -0800, David Miller wrote:
> > > +		if (lost) {
> > > +			printk(KERN_WARNING
> > > +			       "printk: %d %s%smessage%s suppressed.\n",
> > > +			       lost,
> > > +			       (state->facility == 0 ? "" :
> > > state->facility),
> > > +			       (state->facility == 0 ? "" : " "),
> > > +			       (lost > 1 ? "s" : ""));
> > > +		}
> > >  		return 1;
> > >  	}
> 
> This compares a pointer to 0.
> 
> How about something like:
> 
> 	if (lost)
> 		pr_warn("printk: %s suppressed message count: %d\n",
> 			state->facility ? : "ratelimit", lost);
> 
> > > -	missed++;
> > > +	state->missed++;
> > >  	spin_unlock_irqrestore(&ratelimit_lock, flags);
> > >  	return 0;
> > >  }
> > > @@ -1280,8 +1290,18 @@ int printk_ratelimit_burst = 10;
> > >  
> > >  int printk_ratelimit(void)
> > >  {
> > > +	static struct printk_ratelimit_state limit_state = {
> > > +		.toks          = 10 * 5 * HZ,
> > > +		.last_jiffies  = 0,
> > > +		.missed        = 0,
> > > +		.limit_jiffies = 5 * HZ,
> > > +		.limit_burst   = 10,
> > > +		.facility      = 0
> > > +	};
> > > +
> 
> .facility = NULL

How about this?

Signed-off-by: Steve Hawkes <steve.hawkes@motorola.com> 

diff -uprN linux-2.6.24/include/linux/kernel.h
linux-2.6.24-printk_ratelimit/include/linux/kernel.h
--- linux-2.6.24/include/linux/kernel.h 2008-01-24 16:58:37.000000000
-0600
+++ linux-2.6.24-printk_ratelimit/include/linux/kernel.h
2008-02-21 11:20:41.751197312 -0600
@@ -196,8 +196,19 @@ static inline int log_buf_copy(char *des
 
 unsigned long int_sqrt(unsigned long);
 
+struct printk_ratelimit_state
+{
+       unsigned long toks;
+       unsigned long last_jiffies;
+       int missed;
+       int limit_jiffies;
+       int limit_burst;
+       char const *facility;
+};
+
 extern int printk_ratelimit(void);
-extern int __printk_ratelimit(int ratelimit_jiffies, int
ratelimit_burst);
+extern int __printk_ratelimit(int ratelimit_jiffies, int
ratelimit_burst,
+                               struct printk_ratelimit_state *state);
 extern bool printk_timed_ratelimit(unsigned long *caller_jiffies,
                                unsigned int interval_msec);
 
diff -uprN linux-2.6.24/kernel/printk.c
linux-2.6.24-printk_ratelimit/kernel/printk.c
--- linux-2.6.24/kernel/printk.c        2008-01-24 16:58:37.000000000
-0600
+++ linux-2.6.24-printk_ratelimit/kernel/printk.c       2008-02-21
11:22:27.442319625 -0600
@@ -1238,35 +1238,41 @@ void tty_write_message(struct tty_struct
 /*
  * printk rate limiting, lifted from the networking subsystem.
  *
- * This enforces a rate limit: not more than one kernel message
- * every printk_ratelimit_jiffies to make a denial-of-service
- * attack impossible.
+ * This enforces a rate limit to mitigate denial-of-service attacks:
+ * not more than ratelimit_burst messages every ratelimit_jiffies.
  */
-int __printk_ratelimit(int ratelimit_jiffies, int ratelimit_burst)
+int __printk_ratelimit(int ratelimit_jiffies,
+                       int ratelimit_burst,
+                       struct printk_ratelimit_state *state)
 {
        static DEFINE_SPINLOCK(ratelimit_lock);
-       static unsigned long toks = 10 * 5 * HZ;
-       static unsigned long last_msg;
-       static int missed;
        unsigned long flags;
        unsigned long now = jiffies;
 
        spin_lock_irqsave(&ratelimit_lock, flags);
-       toks += now - last_msg;
-       last_msg = now;
-       if (toks > (ratelimit_burst * ratelimit_jiffies))
-               toks = ratelimit_burst * ratelimit_jiffies;
-       if (toks >= ratelimit_jiffies) {
-               int lost = missed;
-
-               missed = 0;
-               toks -= ratelimit_jiffies;
+       state->toks += now - state->last_jiffies;
+       /* Reset limiting if tunables changed */
+       if ((state->limit_jiffies != ratelimit_jiffies) ||
+           (state->limit_burst != ratelimit_burst)) {
+               state->toks = ratelimit_burst * ratelimit_jiffies;
+               state->limit_jiffies = ratelimit_jiffies;
+               state->limit_burst = ratelimit_burst;
+       }
+       state->last_jiffies = now;
+       if (state->toks > (ratelimit_burst * ratelimit_jiffies))
+               state->toks = ratelimit_burst * ratelimit_jiffies;
+       if (state->toks >= ratelimit_jiffies) {
+               int lost = state->missed;
+               state->missed = 0;
+               state->toks -= ratelimit_jiffies;
                spin_unlock_irqrestore(&ratelimit_lock, flags);
-               if (lost)
-                       printk(KERN_WARNING "printk: %d messages
suppressed.\n", lost);
+               if (lost) {
+                       pr_warning("%s ratelimit suppressed message
count: %d\n",
+                               state->facility, lost);
+               }
                return 1;
        }
-       missed++;
+       state->missed++;
        spin_unlock_irqrestore(&ratelimit_lock, flags);
        return 0;
 }
@@ -1280,8 +1286,17 @@ int printk_ratelimit_burst = 10;
 
 int printk_ratelimit(void)
 {
+       static struct printk_ratelimit_state limit_state = {
+               .toks          = 10 * 5 * HZ,
+               .last_jiffies  = 0,
+               .missed        = 0,
+               .limit_jiffies = 5 * HZ,
+               .limit_burst   = 10,
+               .facility      = "printk"
+       };
+
        return __printk_ratelimit(printk_ratelimit_jiffies,
-                               printk_ratelimit_burst);
+                               printk_ratelimit_burst, &limit_state);
 }
 EXPORT_SYMBOL(printk_ratelimit);
 
diff -uprN linux-2.6.24/net/core/utils.c
linux-2.6.24-printk_ratelimit/net/core/utils.c
--- linux-2.6.24/net/core/utils.c       2008-01-24 16:58:37.000000000
-0600
+++ linux-2.6.24-printk_ratelimit/net/core/utils.c      2008-02-21
11:03:44.644337698 -0600
@@ -41,7 +41,16 @@ EXPORT_SYMBOL(net_msg_warn);
  */
 int net_ratelimit(void)
 {
-       return __printk_ratelimit(net_msg_cost, net_msg_burst);
+       static struct printk_ratelimit_state limit_state = {
+               .toks          = 10 * 5 * HZ,
+               .last_jiffies  = 0,
+               .missed        = 0,
+               .limit_jiffies = 5 * HZ,
+               .limit_burst   = 10,
+               .facility      = "net"
+       };
+
+       return __printk_ratelimit(net_msg_cost, net_msg_burst,
&limit_state);
 }
 EXPORT_SYMBOL(net_ratelimit);
  
