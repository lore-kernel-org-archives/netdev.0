From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Linux 2.6.35/TIPC 2.0 ABI breaking changes
Date: Tue, 19 Oct 2010 16:18:41 -0400
Message-ID: <20101019201841.GC14410@hmsreliant.think-freely.org>
References: <4CBCD429.8090306@windriver.com>
	<20101018234547.GA5703@hmsreliant.think-freely.org>
	<20101019021657.GZ8781@llucax.com.ar>
	<20101019.011649.71113115.davem@davemloft.net>
	<20101019110452.GA14410@hmsreliant.think-freely.org>
	<20101019131936.GB8781@llucax.com.ar>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, paul.gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net, David Miller <davem@davemloft.net>
To: Leandro Lucarella <luca@llucax.com.ar>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20101019131936.GB8781@llucax.com.ar>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, Oct 19, 2010 at 10:19:36AM -0300, Leandro Lucarella wrote:
> Neil Horman, el 19 de octubre a las 07:04 me escribiste:
> > On Tue, Oct 19, 2010 at 01:16:49AM -0700, David Miller wrote:
> > > From: Leandro Lucarella <luca@llucax.com.ar>
> > > Date: Mon, 18 Oct 2010 23:16:57 -0300
> > > =

> > > > =

> > > > The problem is not between the tipc stacks in different hosts, is
> > > > between the tipc stack and the applications using it (well, maybe
> > > > there is a problem somewhere else too).
> > > > =

> > > > This was a deliberate API change, not a subtle bug...
> > > =

> > > Neil et al., if these packets live only between the kernel stack
> > > and the userspace API layer, we should not be byte-swapping this
> > > stuff and we need to fix this fast.
> > > =

> > Copy that Dave.  I think I see the problem.  The subscription code hand=
les
> > messages both off the wire and from local user space.  The off the wire=
 case
> > should work because the subscription code assumes that all the incommin=
g data is
> > in network byte order, but user space is an exception to that rule as i=
ts in
> > local byte order.  I'll have a patch together for Leandro to test soon.
> > Neil
> =

> Thank you very much. Bare in mind that the byte order is just one of the
> problems, the other problem is the change in the value of
> TIPC_SUB_SERVICE from 2 to 0. That too is breaking the API/ABI, as
> a message with a filter value of 2 is rejected by TIPC 2.0/2.6.35+.
> =

> -- =

> Leandro Lucarella (AKA luca)                     http://llucax.com.ar/
> ----------------------------------------------------------------------
> GPG Key: 5F5A8D05 (F8CD F9A7 BF00 5431 4145  104C 949E BFB6 5F5A 8D05)
> ----------------------------------------------------------------------
> Dentro de 30 a=F1os Argentina va a ser un gran supermercado con 15
> changuitos, porque esa va a ser la cantidad de gente que va a poder
> comprar algo.
> 	-- Sidharta Wiki
> =



Hey all-
	Heres what I have so far.  Dave as a heads up please don't apply this
yet.  I'd like to go over it a bit more and be sure of the implications here
before I post it for inclusion officially.  I wanted Leandro to have a copy
though so he could confirm functionality for us.  Leandro, This patch lets =
me
pass the tipc test code for TIPC 1.6 that you posted earlier this morning. =
 If
you could confirm that it works for you that would be grand.  While your do=
ing
that, I want to read over the spec for TIPC and make sure that I'm not brea=
king
anything new with this patch.

Thanks!
Neil


diff --git a/include/linux/tipc.h b/include/linux/tipc.h
index 181c8d0..d8de884 100644
--- a/include/linux/tipc.h
+++ b/include/linux/tipc.h
@@ -127,9 +127,10 @@ static inline unsigned int tipc_node(__u32 addr)
  * TIPC topology subscription service definitions
  */
 =

-#define TIPC_SUB_SERVICE     	0x00  	/* Filter for service availability   =
 */
-#define TIPC_SUB_PORTS     	0x01  	/* Filter for port availability  */
+#define TIPC_SUB_SERVICE     	0x01  	/* Filter for service availability   =
 */
+#define TIPC_SUB_PORTS     	0x02  	/* Filter for port availability  */
 #define TIPC_SUB_CANCEL         0x04    /* Cancel a subscription         */
+#define TIPC_SUB_MASK		(TIPC_SUB_SERVICE|TIPC_SUB_PORTS|TIPC_SUB_CANCEL)
 =

 #define TIPC_WAIT_FOREVER	~0	/* timeout for permanent subscription */
 =

diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index 18813ac..06682e1 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -75,6 +75,17 @@ struct top_srv {
 =

 static struct top_srv topsrv =3D { 0 };
 =

+/*
+ * Detect the need for an endian swap.
+ * user space sends subscriber info in =

+ * host byte order while the kernel expects
+ * it in network byte order.  To correct this
+ * lets check the filter bits, if there in the =

+ * right place we know this is in network byte order
+ * otherwise it needs swapping around to maintain compatibility
+ */
+#define tipc_need_endian_swap(s) (!((s)->filter & TIPC_SUB_MASK))
+
 /**
  * subscr_send_event - send a message containing a tipc_event to the subsc=
riber
  *
@@ -279,11 +290,21 @@ static void subscr_cancel(struct tipc_subscr *s,
 =

 	/* Find first matching subscription, exit if not found */
 =

-	type =3D ntohl(s->seq.type);
-	lower =3D ntohl(s->seq.lower);
-	upper =3D ntohl(s->seq.upper);
-	timeout =3D ntohl(s->timeout);
-	filter =3D ntohl(s->filter) & ~TIPC_SUB_CANCEL;
+	if (tipc_need_endian_swap(s)) {
+		printk(KERN_CRIT "Swapping endianess in subscr_cancel\n");
+		type =3D ntohl(s->seq.type);
+		lower =3D ntohl(s->seq.lower);
+		upper =3D ntohl(s->seq.upper);
+		timeout =3D ntohl(s->timeout);
+		filter =3D ntohl(s->filter) & ~TIPC_SUB_CANCEL;
+	} else {
+		printk(KERN_CRIT "NOT Swapping endianess in subscr_cancel\n");
+		type =3D s->seq.type;
+		lower =3D s->seq.lower;
+		upper =3D s->seq.upper;
+		timeout =3D s->timeout;
+		filter =3D s->filter & ~TIPC_SUB_CANCEL;
+	}
 =

 	list_for_each_entry_safe(sub, sub_temp, &subscriber->subscription_list,
 				 subscription_list) {
@@ -325,10 +346,19 @@ static struct subscription *subscr_subscribe(struct t=
ipc_subscr *s,
 					     struct subscriber *subscriber)
 {
 	struct subscription *sub;
+	__u32 filter;
 =

 	/* Detect & process a subscription cancellation request */
 =

-	if (ntohl(s->filter) & TIPC_SUB_CANCEL) {
+	if (tipc_need_endian_swap(s)) {
+		printk(KERN_CRIT "Swapping endianess in subscr_subscribe\n");
+		filter =3D ntohl(s->filter);
+	} else {
+		printk(KERN_CRIT "NOT Swapping endianess in subscr_subscribe\n");
+		filter =3D s->filter;
+	}
+
+	if (filter & TIPC_SUB_CANCEL) {
 		subscr_cancel(s, subscriber);
 		return NULL;
 	}
@@ -353,11 +383,22 @@ static struct subscription *subscr_subscribe(struct t=
ipc_subscr *s,
 =

 	/* Initialize subscription object */
 =

-	sub->seq.type =3D ntohl(s->seq.type);
-	sub->seq.lower =3D ntohl(s->seq.lower);
-	sub->seq.upper =3D ntohl(s->seq.upper);
-	sub->timeout =3D ntohl(s->timeout);
-	sub->filter =3D ntohl(s->filter);
+	if (tipc_need_endian_swap(s)) {
+		printk(KERN_CRIT "Swapping endianess in subscr_subscribe\n");
+		sub->seq.type =3D ntohl(s->seq.type);
+		sub->seq.lower =3D ntohl(s->seq.lower);
+		sub->seq.upper =3D ntohl(s->seq.upper);
+		sub->timeout =3D ntohl(s->timeout);
+		sub->filter =3D ntohl(s->filter);
+	} else {
+		printk(KERN_CRIT "NOT Swapping endianess in subscr_subscribe\n");
+		sub->seq.type =3D s->seq.type;
+		sub->seq.lower =3D s->seq.lower;
+		sub->seq.upper =3D s->seq.upper;
+		sub->timeout =3D s->timeout;
+		sub->filter =3D s->filter;
+	}
+
 	if ((sub->filter && (sub->filter !=3D TIPC_SUB_PORTS)) ||
 	    (sub->seq.lower > sub->seq.upper)) {
 		warn("Subscription rejected, illegal request\n");

---------------------------------------------------------------------------=
---
Download new Adobe(R) Flash(R) Builder(TM) 4
The new Adobe(R) Flex(R) 4 and Flash(R) Builder(TM) 4 (formerly =

Flex(R) Builder(TM)) enable the development of rich applications that run
across multiple browsers and platforms. Download your free trials today!
http://p.sf.net/sfu/adobe-dev2dev
