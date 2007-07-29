From: Satyam Sharma <satyam@infradead.org>
Subject: Re: [PATCH] USB Pegasus driver - avoid a
 potential NULL pointer dereference.
Date: Sun, 29 Jul 2007 23:48:24 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0707292346150.30928@enigma.security.iitk.ac.in>
References: <200707290019.02591.jesper.juhl@gmail.com>
	<a781481a0707281637n5b123e4aib46c4e4b009b0018@mail.gmail.com>
	<9a8748490707281655u66e50bbfqba58687b579a85fe@mail.gmail.com>
	<200707291049.26619.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-usb-devel@lists.sourceforge.net,
	Petko Manolov <petkan@users.sourceforge.net>,
	Greg Kroah-Hartman <greg@kroah.com>,
	Jesper Juhl <jesper.juhl@gmail.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Oliver Neukum <oliver@neukum.org>
Return-path: <linux-usb-devel-bounces@lists.sourceforge.net>
In-Reply-To: <200707291049.26619.oliver@neukum.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-usb-devel>,
	<mailto:linux-usb-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-usb-devel>
List-Post: <mailto:linux-usb-devel@lists.sourceforge.net>
List-Help: <mailto:linux-usb-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-usb-devel>,
	<mailto:linux-usb-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: linux-usb-devel-bounces@lists.sourceforge.net
Errors-To: linux-usb-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org



On Sun, 29 Jul 2007, Oliver Neukum wrote:

> Am Sonntag 29 Juli 2007 schrieb Jesper Juhl:
> > On 29/07/07, Satyam Sharma <satyam.sharma@gmail.com> wrote:
> > > Hi,
> > >
> > > On 7/29/07, Jesper Juhl <jesper.juhl@gmail.com> wrote:
> > > > Hello,
> > > >
> > > > This patch makes sure we don't dereference a NULL pointer in
> > > > drivers/net/usb/pegasus.c::write_bulk_callback() in the initial
> > > > struct net_device *net = pegasus->net; assignment.
> > > > The existing code checks if 'pegasus' is NULL and bails out if
> > > > it is, so we better not touch that pointer until after that check.
> > > > [...]
> > >
> > > Is it really possible that we're called into this function with
> > > urb->context == NULL? If not, I'd suggest let's just get rid of
> > > the check itself, instead.
> > >
> > I'm not sure. I am not very familiar with this code. I just figured
> > that moving the assignment is potentially a little safer and it is
> > certainly no worse than the current code, so that's a safe and
> > potentially benneficial change. Removing the check may be safe but I'm
> > not certain enough to make that call...
> 
> pegasus == NULL there would be a kernel bug. Silently ignoring
> it, like the code now wants to do is bad. As the oops has never been
> reported, I figure turning it into an explicit debugging test is overkill,
> so removal seems to be the best option.

Ok, thanks. Updated patch below.

[PATCH] pegasus: Remove bogus checks in urb->complete() callbacks

urb->complete() callbacks registered in drivers/net/usb/pegasus.c needlessly
check for urb->context != NULL, but that is not possible (the only way that
can be possible would be a kernel bug elsewhere, and these checks would
simply end up hiding that). So let's remove the bogus checks.

Signed-off-by: Satyam Sharma <satyam@infradead.org>

---

 drivers/net/usb/pegasus.c |    9 +--------
 1 files changed, 1 insertions(+), 8 deletions(-)

diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
index a05fd97..439ef9f 100644
--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
@@ -770,9 +770,6 @@ static void write_bulk_callback(struct urb *urb)
 	pegasus_t *pegasus = urb->context;
 	struct net_device *net = pegasus->net;
 
-	if (!pegasus)
-		return;
-
 	if (!netif_device_present(net) || !netif_running(net))
 		return;
 
@@ -805,13 +802,9 @@ static void write_bulk_callback(struct urb *urb)
 static void intr_callback(struct urb *urb)
 {
 	pegasus_t *pegasus = urb->context;
-	struct net_device *net;
+	struct net_device *net = pegasus->net;
 	int status;
 
-	if (!pegasus)
-		return;
-	net = pegasus->net;
-
 	switch (urb->status) {
 	case 0:
 		break;

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
linux-usb-devel@lists.sourceforge.net
To unsubscribe, use the last form field at:
https://lists.sourceforge.net/lists/listinfo/linux-usb-devel
