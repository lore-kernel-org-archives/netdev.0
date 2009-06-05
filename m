From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [RFC PATCH v2 00/19] virtual-bus
Date: Sat, 6 Jun 2009 00:25:57 +0930
Message-ID: <200906060025.57961.rusty@rustcorp.com.au>
References: <20090409155200.32740.19358.stgit@dev.haskins.net> <200906051425.02924.rusty@rustcorp.com.au> <20090605053010.GD7125@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Gregory Haskins <gregory.haskins@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, Avi Kivity <avi@redhat.com>,
	Gregory Haskins <ghaskins@novell.com>,
	linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, anthony@codemonkey.ws,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	bhutchings@solarflare.com, andi@firstfloor.org, gregkh@suse.de,
	herber@gondor.apana.org.au, chrisw@sous-sol.org,
	shemminger@vyatta.com
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:55226 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752672AbZFEPIV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Jun 2009 11:08:21 -0400
In-Reply-To: <20090605053010.GD7125@linux.vnet.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 5 Jun 2009 03:00:10 pm Paul E. McKenney wrote:
> On Fri, Jun 05, 2009 at 02:25:01PM +0930, Rusty Russell wrote:
> > +	/* lg->eventfds is RCU-protected */
> > +	preempt_disable();
>
> Suggest changing to rcu_read_lock() to match the synchronize_rcu().

Ah yes, much better.  As I was implementing it I warred with myself since
lguest aims for simplicity above all else.  But since we only ever add things
to the array, RCU probably is simpler.

> > +	for (i = 0; i < cpu->lg->num_eventfds; i++) {
> > +		if (cpu->lg->eventfds[i].addr == cpu->pending_notify) {
> > +			eventfd_signal(cpu->lg->eventfds[i].event, 1);
>
> Shouldn't this be something like the following?
>
> 		p = rcu_dereference(cpu->lg->eventfds);
> 		if (p[i].addr == cpu->pending_notify) {
> 			eventfd_signal(p[i].event, 1);

Hmm, need to read num_eventfds first, too.  It doesn't matter if we get the old
->num_eventfds and the new ->eventfds, but the other way around would be bad.

Here's the inter-diff:

diff --git a/drivers/lguest/lguest_user.c b/drivers/lguest/lguest_user.c
--- a/drivers/lguest/lguest_user.c
+++ b/drivers/lguest/lguest_user.c
@@ -39,18 +39,24 @@ static int break_guest_out(struct lg_cpu
 
 bool send_notify_to_eventfd(struct lg_cpu *cpu)
 {
-	unsigned int i;
+	unsigned int i, num;
+	struct lg_eventfds *eventfds;
+
+	/* Make sure we grab the total number before accessing the array. */
+	cpu->lg->num_eventfds = num;
+	rmb();
 
 	/* lg->eventfds is RCU-protected */
 	rcu_read_lock();
-	for (i = 0; i < cpu->lg->num_eventfds; i++) {
-		if (cpu->lg->eventfds[i].addr == cpu->pending_notify) {
-			eventfd_signal(cpu->lg->eventfds[i].event, 1);
+	eventfds = rcu_dereference(cpu->lg->eventfds);
+	for (i = 0; i < num; i++) {
+		if (eventfds[i].addr == cpu->pending_notify) {
+			eventfd_signal(eventfds[i].event, 1);
 			cpu->pending_notify = 0;
 			break;
 		}
 	}
-	preempt_enable();
+	rcu_read_unlock();
 	return cpu->pending_notify == 0;
 }
 
Thanks!
Rusty.
