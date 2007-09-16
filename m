From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [ofa-general] Re: [PATCH v2] iw_cxgb3: Support "iwarp-only"
	interfaces to avoid 4-tuple conflicts.
Date: Sun, 16 Sep 2007 18:22:41 +0400
Message-ID: <20070916142241.GA26848@2ka.mipt.ru>
References: <20070913191617.30937.95960.stgit@dell3.ogc.int>
	<20070914130941.GG18517@2ka.mipt.ru>
	<46EC00BE.3020801@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, rdreier@cisco.com, general@lists.openfabrics.org,
	linux-kernel@vger.kernel.org
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <46EC00BE.3020801@opengridcomputing.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Hi Steve.

On Sat, Sep 15, 2007 at 10:56:46AM -0500, Steve Wise (swise@opengridcomputing.com) wrote:
> >>The iWARP driver must translate all listens on address 0.0.0.0 to the
> >>set of rdma-only ip addresses for the device in question.  This prevents
> >>incoming connect requests to the TCP ipaddresses from going up the
> >>rdma stack.
> >
> >If the only solutions to solve a problem with hardware are to steal
> >packets or became a real device, then real device is much more
> >appropriate. Is that correct?
> >
> 
> This is a real device.  I don't understand your question?  Packets 
> aren't being stolen.

I meant port from main network stack. Sorry for confusion.

> >>+static void insert_ifa(struct iwch_dev *rnicp, struct in_ifaddr *ifa)
> >>+{
> >>+	struct iwch_addrlist *addr;
> >>+
> >>+	addr = kmalloc(sizeof *addr, GFP_KERNEL);
> >
> >As a small nitpick: this wants to be sizeof(struct in_ifaddr)
> >
> 
> No, insert_ifa() allocates a struct iwch_addrlist, which has 2 fields: a 
> list_head for linking, and a struct in_ifaddr pointer.

sizeof(struct iwch_addrlist) of course, not (*addr).
To simplify grep.
 
> >>+	if (!addr) {
> >>+		printk(KERN_ERR MOD "%s - failed to alloc memory!\n",
> >>+		       __FUNCTION__);
> >>+		return;
> >>+	}
> >>+	addr->ifa = ifa;
> >>+	mutex_lock(&rnicp->mutex);
> >>+	list_add_tail(&addr->entry, &rnicp->addrlist);
> >>+	mutex_unlock(&rnicp->mutex);
> >>+}
> >
> >What about providing error back to caller and fail to register?
> >
> 
> There are two causes where this is called: 1) during module init to 
> populate the list of iwarp addresses.  If we failed in that case then, I 
> _could_ then not register.  2) we get called via the notifier mechanism 
> when an address is added.  If that fails, the caller doesn't care (since 
> we're on the notifier callout thread).  But the code could perhaps 
> unregister the device.  I prefer just logging an error in case 2.  I'll 
> look into not registering if we cannot get any address due to lack of 
> memory.  But there's another case:  we load the module and the admin 
> hasn't yet created the ethX:iw interface.
> 
> Perhaps I should change the code to only register as a working rdma 
> device _when_ we get at least one ethX:iwY interface created?  Whatchathink?

Does second case ends up with problem you described in the initial
e-mail not being fixed?
 
> >>+static inline int is_iwarp_label(char *label)
> >>+{
> >>+	char *colon;
> >>+
> >>+	colon = strchr(label, ':');
> >>+	if (colon && !strncmp(colon+1, "iw", 2))
> >>+		return 1;
> >>+	return 0;
> >>+}
> >
> >I.e. it is not allowed to create ':iw' alias for anyone else?
> >Well, looks crappy, but if it is the only solution...
> >
> 
> It is kinda crappy.  But I don't see a better solution.  Any ideas?

Does creating the whole new netdevice is a too big overhead, or is it
considered bad idea?

> >>+static struct iwch_listen_entry *alloc_listener(struct iwch_listen_ep 
> >>*ep,
> >>+						  __be32 addr)
> >
> >Do you know, that cxgb3 function names suck? :)
> >Especially get_skb().
> >
> >>+{
> >>+	struct iwch_dev *h = to_iwch_dev(ep->com.cm_id->device);
> >>+	struct iwch_listen_entry *le;
> >>+
> >>+	le = kmalloc(sizeof *le, GFP_KERNEL);
> >
> >Wants to be sizeof(struct iwch_listen_entry) and in other places too.
> >
> 
> Do you mean I shouldn't use sizeof *le, but rather sizeof(struct 
> iwch_listen_entry)?  Is that the preferred coding style?

Yes, exactly.

> >I skipped rdma internals of the patch, since I do not know it enough 
> >to judge, but your approach looks good from core network point of view.
> >Maybe you should automatically create an alias each time new interface
> >is added so that admin would not care about proper aliases?
> >
> 
> That would be much better IMO, but the problem is that I cannot create 
> an alias without an actual ip address.  Unless we change the core 
> services to allow it.
> 
> Thanks for reviewing!
> 
> Steve.
> 

-- 
	Evgeniy Polyakov
