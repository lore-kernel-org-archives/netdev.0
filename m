From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: Possible IRDA SKB leaks
Date: Tue, 25 Nov 2003 18:33:58 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031126023358.GA15162@bougret.hpl.hp.com>
References: <20031124193042.2c1013a2.davem@redhat.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: irda-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20031124193042.2c1013a2.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Nov 24, 2003 at 07:30:42PM -0800, David S. Miller wrote:
> 
> Hello Jean, I think I've found some SKB handling bugs in
> the IRDA stack.
> 
> I was verifying all the paths that use sock_queue_rcv_skb().
> If any non-zero value is returned from this function the caller
> must either free the SKB or queue the packet some place else.
> 
> Here is one example where IRDA appears to do the wrong thing.
> In irttp_udata_indication(), we pass the packet down into the
> next layer via self->notify.udata_indication().
> 
> One example implementation of this is af_irda.c:irda_data_indication().
> This calls sock_queue_rcv_skb() and returns any error to the caller.
> 
> Our caller in this case, irttp_udata_indication(), for some reason
> treats -ENOMEM specially.  This is wrong, there are many other errors
> that sock_queue_rcv_skb() can return, for example -EPERM from socket
> filtering.  All such error cases need to cause the SKB to be freed
> or similar, it should not be done only for an error of -ENOMEM.

	I would need to ask Dag to know the real reason. This code was
unchanged since 2.2.X days. What was true for 2.2.X is no longer true.

> I have not done an exhaustive audit of this problem in the IRDA stack.
> But I do suspect there are other places doing something similar.
> 
> If someone could finish the audit and submit a patch to fix this I'd
> really appreciate it.  Thanks a lot.

	I did the audit, and there was not many places to fix. Tested
on 2.6.0-test9 (both data and udata path). Patch is trivial and
attached below.
	Thanks for the heads up !

	Have fun...

	Jean

P.S. : I've got other important IrDA patches, but a freeze is a freeze ;-)

---------------------------------------

diff -u -p linux/net/irda/irttp.d6.c linux/net/irda/irttp.c
--- linux/net/irda/irttp.d6.c	Tue Nov 25 18:12:19 2003
+++ linux/net/irda/irttp.c	Tue Nov 25 18:17:24 2003
@@ -859,10 +859,10 @@ static int irttp_udata_indication(void *
 		err = self->notify.udata_indication(self->notify.instance,
 						    self,skb);
 		/* Same comment as in irttp_do_data_indication() */
-		if (err != -ENOMEM) 
+		if (!err) 
 			return 0;
 	}
-	/* Either no handler, or -ENOMEM */
+	/* Either no handler, or handler returns an error */
 	dev_kfree_skb(skb);
 
 	return 0;
@@ -1620,7 +1620,7 @@ void irttp_do_data_indication(struct tsa
 	 * be difficult, so it can instead just refuse to eat it and just
 	 * give an error back
 	 */
-	if (err == -ENOMEM) {
+	if (err) {
 		IRDA_DEBUG(0, "%s() requeueing skb!\n", __FUNCTION__);
 
 		/* Make sure we take a break */
