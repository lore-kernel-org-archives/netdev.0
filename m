From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Race with netdevice unregister and dst_dev_event
Date: Tue, 29 Apr 2003 10:15:35 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030429101535.17d97c23.shemminger@osdl.org>
References: <20030428163557.60896645.shemminger@osdl.org>
	<20030428.175719.104057922.davem@redhat.com>
	<20030429091023.3a73beda.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030429091023.3a73beda.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 29 Apr 2003 09:10:23 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> On Mon, 28 Apr 2003 17:57:19 -0700 (PDT)
> "David S. Miller" <davem@redhat.com> wrote:
> 
> >    From: Stephen Hemminger <shemminger@osdl.org>
> >    Date: Mon, 28 Apr 2003 16:35:57 -0700
> > 
> >    So unless dst.c is fixed, there needs to be a rule NEVER use
> >    dev->destructor in network modules.
> > 
> > I don't understand what the problem is.
> > 
> > Look, this code in the DST cache merely puts the device (which is
> > legal from any context) if the device lacks a destructor.
> > 
> > If it has a destructor, it keeps the reference and once the DST entry
> > dies the dst->dev is dev_put().  So it does in fact do the "cleanup"
> > contrary to what you say, this happens during dst entry garbage
> > collection.
> > 
> > If the dst has a dst->dev attached, the device has a reference
> > and thus so does your module which created the device and thus
> > your module cannot be unloaded.
> > 
> > So to reiterate, what exactly is the problem? :-)
> 
> The problem is that the destructor points to code that is in the module,
> and it doesn't get run during unregister but later when the dst cache
> GC timer expores. 
> So it is possible for the module to go away before the DST entry is
> released by dev_put() in the garbage collection (by timer). At that
> point the destructor points to dead memory.
> 

How about this solution, it resolves the problem when
I unload bridge.  It causes the cache to release immediately,
if the device is a module.

diff -Nru a/net/core/dst.c b/net/core/dst.c
--- a/net/core/dst.c	Tue Apr 29 10:12:10 2003
+++ b/net/core/dst.c	Tue Apr 29 10:12:10 2003
@@ -228,7 +228,7 @@
 				   _race_ _condition_.
 				 */
 				if (event!=NETDEV_DOWN &&
-				    dev->destructor == NULL &&
+				    (dev->destructor == NULL  || dev->owner) &&
 				    dst->output == dst_blackhole) {
 					dst->dev = &loopback_dev;
 					dev_put(dev);
