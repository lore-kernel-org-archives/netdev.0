From: "Kanevsky, Arkady" <Arkady.Kanevsky@netapp.com>
Subject: RE: [ofa-general] [PATCH v3] iw_cxgb3: Support "iwarp-only"
	interfacesto avoid 4-tuple conflicts.
Date: Thu, 27 Sep 2007 14:56:17 -0400
Message-ID: <C98692FD98048C41885E0B0FACD9DFB805187514@exnane01.hq.netapp.com>
References: <20070923203649.8324.64524.stgit@dell3.ogc.int>
	<46FBF8AF.9040700@ichips.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, rdreier@cisco.com, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: "Sean Hefty" <mshefty@ichips.intel.com>,
	"Steve Wise" <swise@opengridcomputing.com>
Return-path: <general-bounces@lists.openfabrics.org>
Content-class: urn:content-classes:message
In-Reply-To: <46FBF8AF.9040700@ichips.intel.com>
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

Sean,
What is the model on how client connects, say for iSCSI,
when client and server both support, iWARP and 10GbE or 1GbE,
and would like to setup "most" performant "connection" for ULP?
Thanks,

Arkady Kanevsky                       email: arkady@netapp.com
Network Appliance Inc.               phone: 781-768-5395
1601 Trapelo Rd. - Suite 16.        Fax: 781-895-1195
Waltham, MA 02451                   central phone: 781-768-5300
=20

> -----Original Message-----
> From: Sean Hefty [mailto:mshefty@ichips.intel.com]=20
> Sent: Thursday, September 27, 2007 2:39 PM
> To: Steve Wise
> Cc: netdev@vger.kernel.org; rdreier@cisco.com;=20
> general@lists.openfabrics.org; linux-kernel@vger.kernel.org
> Subject: Re: [ofa-general] [PATCH v3] iw_cxgb3: Support=20
> "iwarp-only" interfacesto avoid 4-tuple conflicts.
>=20
> > The sysadmin creates "for iwarp use only" alias interfaces=20
> of the form=20
> > "devname:iw*" where devname is the native interface name=20
> (eg eth0) for=20
> > the iwarp netdev device.  The alias label can be anything=20
> starting with "iw".
> > The "iw" immediately after the ':' is the key used by the=20
> iw_cxgb3 driver.
>=20
> I'm still not sure about this, but haven't come up with=20
> anything better myself.  And if there's a good chance of=20
> other rnic's needing the same support, I'd rather see the=20
> common code separated out, even if just encapsulated within=20
> this module for easy re-use.
>=20
> As for the code, I have a couple of questions about whether=20
> deadlock and a race condition are possible, plus a few minor comments.
>=20
> > +static void insert_ifa(struct iwch_dev *rnicp, struct=20
> in_ifaddr *ifa)=20
> > +{
> > +	struct iwch_addrlist *addr;
> > +
> > +	addr =3D kmalloc(sizeof *addr, GFP_KERNEL);
> > +	if (!addr) {
> > +		printk(KERN_ERR MOD "%s - failed to alloc memory!\n",
> > +		       __FUNCTION__);
> > +		return;
> > +	}
> > +	addr->ifa =3D ifa;
> > +	mutex_lock(&rnicp->mutex);
> > +	list_add_tail(&addr->entry, &rnicp->addrlist);
> > +	mutex_unlock(&rnicp->mutex);
> > +}
>=20
> Should this return success/failure?
>=20
> > +static int nb_callback(struct notifier_block *self,=20
> unsigned long event,
> > +		       void *ctx)
> > +{
> > +	struct in_ifaddr *ifa =3D ctx;
> > +	struct iwch_dev *rnicp =3D container_of(self, struct=20
> iwch_dev, nb);
> > +
> > +	PDBG("%s rnicp %p event %lx\n", __FUNCTION__, rnicp, event);
> > +
> > +	switch (event) {
> > +	case NETDEV_UP:
> > +		if (netdev_is_ours(rnicp, ifa->ifa_dev->dev) &&
> > +		    is_iwarp_label(ifa->ifa_label)) {
> > +			PDBG("%s label %s addr 0x%x added\n",
> > +				__FUNCTION__, ifa->ifa_label,=20
> ifa->ifa_address);
> > +			insert_ifa(rnicp, ifa);
> > +			iwch_listeners_add_addr(rnicp,=20
> ifa->ifa_address);
>=20
> If insert_ifa() fails, what will iwch_listeners_add_addr()=20
> do?  (I'm not easily seeing the relationship between the=20
> address list and the listen list at this point.)
>=20
> > +		}
> > +		break;
> > +	case NETDEV_DOWN:
> > +		if (netdev_is_ours(rnicp, ifa->ifa_dev->dev) &&
> > +		    is_iwarp_label(ifa->ifa_label)) {
> > +			PDBG("%s label %s addr 0x%x deleted\n",
> > +				__FUNCTION__, ifa->ifa_label,=20
> ifa->ifa_address);
> > +			iwch_listeners_del_addr(rnicp,=20
> ifa->ifa_address);
> > +			remove_ifa(rnicp, ifa);
> > +		}
> > +		break;
> > +	default:
> > +		break;
> > +	}
> > +	return 0;
> > +}
> > +
> > +static void delete_addrlist(struct iwch_dev *rnicp) {
> > +	struct iwch_addrlist *addr, *tmp;
> > +
> > +	mutex_lock(&rnicp->mutex);
> > +	list_for_each_entry_safe(addr, tmp, &rnicp->addrlist, entry) {
> > +		list_del(&addr->entry);
> > +		kfree(addr);
> > +	}
> > +	mutex_unlock(&rnicp->mutex);
> > +}
> > +
> > +static void populate_addrlist(struct iwch_dev *rnicp) {
> > +	int i;
> > +	struct in_device *indev;
> > +
> > +	for (i =3D 0; i < rnicp->rdev.port_info.nports; i++) {
> > +		indev =3D in_dev_get(rnicp->rdev.port_info.lldevs[i]);
> > +		if (!indev)
> > +			continue;
> > +		for_ifa(indev)
> > +			if (is_iwarp_label(ifa->ifa_label)) {
> > +				PDBG("%s label %s addr 0x%x added\n",
> > +				     __FUNCTION__, ifa->ifa_label,
> > +				     ifa->ifa_address);
> > +				insert_ifa(rnicp, ifa);
> > +			}
> > +		endfor_ifa(indev);
> > +	}
> > +}
> > +
> >  static void rnic_init(struct iwch_dev *rnicp)  {
> >  	PDBG("%s iwch_dev %p\n", __FUNCTION__,  rnicp); @@=20
> -70,6 +187,12 @@=20
> > static void rnic_init(struct iwch_dev *r
> >  	idr_init(&rnicp->qpidr);
> >  	idr_init(&rnicp->mmidr);
> >  	spin_lock_init(&rnicp->lock);
> > +	INIT_LIST_HEAD(&rnicp->addrlist);
> > +	INIT_LIST_HEAD(&rnicp->listen_eps);
> > +	mutex_init(&rnicp->mutex);
> > +	rnicp->nb.notifier_call =3D nb_callback;
> > +	populate_addrlist(rnicp);
> > +	register_inetaddr_notifier(&rnicp->nb);
> > =20
> >  	rnicp->attr.vendor_id =3D 0x168;
> >  	rnicp->attr.vendor_part_id =3D 7;
> > @@ -148,6 +271,8 @@ static void close_rnic_dev(struct t3cdev
> >  	mutex_lock(&dev_mutex);
> >  	list_for_each_entry_safe(dev, tmp, &dev_list, entry) {
> >  		if (dev->rdev.t3cdev_p =3D=3D tdev) {
> > +			unregister_inetaddr_notifier(&dev->nb);
> > +			delete_addrlist(dev);
> >  			list_del(&dev->entry);
> >  			iwch_unregister_device(dev);
> >  			cxio_rdev_close(&dev->rdev);
> > diff --git a/drivers/infiniband/hw/cxgb3/iwch.h=20
> > b/drivers/infiniband/hw/cxgb3/iwch.h
> > index caf4e60..7fa0a47 100644
> > --- a/drivers/infiniband/hw/cxgb3/iwch.h
> > +++ b/drivers/infiniband/hw/cxgb3/iwch.h
> > @@ -36,6 +36,8 @@ #include <linux/mutex.h>  #include=20
> <linux/list.h> =20
> > #include <linux/spinlock.h>  #include <linux/idr.h>
> > +#include <linux/notifier.h>
> > +#include <linux/inetdevice.h>
> > =20
> >  #include <rdma/ib_verbs.h>
> > =20
> > @@ -101,6 +103,11 @@ struct iwch_rnic_attributes {
> >  	u32 cq_overflow_detection;
> >  };
> > =20
> > +struct iwch_addrlist {
> > +	struct list_head entry;
> > +	struct in_ifaddr *ifa;
> > +};
> > +
> >  struct iwch_dev {
> >  	struct ib_device ibdev;
> >  	struct cxio_rdev rdev;
> > @@ -111,6 +118,10 @@ struct iwch_dev {
> >  	struct idr mmidr;
> >  	spinlock_t lock;
> >  	struct list_head entry;
> > +	struct notifier_block nb;
> > +	struct list_head addrlist;
> > +	struct list_head listen_eps;
>=20
> The behavior of the listen lists is similar to what's done in the
> rdma_cm: Wildcard listens are stored in a listen_any_list. =20
> When new devices are added, associated listens are added to=20
> each device.  This is similar, except we're dealing with=20
> devices and addresses.  I'm wondering if we shouldn't mimic=20
> the same behavior and track listens in iwch_addrlist=20
> directly.  (I don't see anything wrong with this approach
> though.)
>=20
> What happens if an address changes between iwarp only and non-iwarp?
>=20
> How are listens on specific addresses handled from an rdma_cm level?=20
> Does the rdma_cm map the address to the device, call the=20
> iw_cm to listen, which in turn calls the device listen=20
> function?  The device then checks that the address has been=20
> marked as iwarp only?  (I'm being too lazy to trace this=20
> through the code, but if you don't know off the top of your=20
> head, I will do that.)
>=20
> > +	struct mutex mutex;
> >  };
> > =20
> >  static inline struct iwch_dev *to_iwch_dev(struct=20
> ib_device *ibdev)=20
> > diff --git a/drivers/infiniband/hw/cxgb3/iwch_cm.c=20
> > b/drivers/infiniband/hw/cxgb3/iwch_cm.c
> > index 1cdfcd4..afc8a48 100644
> > --- a/drivers/infiniband/hw/cxgb3/iwch_cm.c
> > +++ b/drivers/infiniband/hw/cxgb3/iwch_cm.c
> > @@ -1127,23 +1127,149 @@ static int act_open_rpl(struct t3cdev *t
> >  	return CPL_RET_BUF_DONE;
> >  }
> > =20
> > -static int listen_start(struct iwch_listen_ep *ep)
> > +static int wait_for_reply(struct iwch_ep_common *epc) {
> > +	PDBG("%s ep %p waiting\n", __FUNCTION__, epc);
> > +	wait_event(epc->waitq, epc->rpl_done);
> > +	PDBG("%s ep %p done waiting err %d\n", __FUNCTION__,=20
> epc, epc->rpl_err);
> > +	return epc->rpl_err;
> > +}
>=20
> What thread is being blocked here, and what sets the event?
>=20
> > +
> > +static struct iwch_listen_entry *alloc_listener(struct=20
> iwch_listen_ep *ep,
> > +						  __be32 addr)
> > +{
> > +	struct iwch_dev *h =3D to_iwch_dev(ep->com.cm_id->device);
> > +	struct iwch_listen_entry *le;
> > +
> > +	le =3D kmalloc(sizeof *le, GFP_KERNEL);
> > +	if (!le) {
> > +		printk(KERN_ERR MOD "%s - failed to alloc memory!\n",
> > +		       __FUNCTION__);
> > +		return NULL;
> > +	}
> > +	le->stid =3D cxgb3_alloc_stid(h->rdev.t3cdev_p,
> > +				    &t3c_client, ep);
> > +	if (le->stid =3D=3D -1) {
> > +		printk(KERN_ERR MOD "%s - cannot alloc stid.\n",
> > +		       __FUNCTION__);
> > +		kfree(le);
> > +		return NULL;
> > +	}
> > +	le->addr =3D addr;
> > +	PDBG("%s stid %u addr %x port %x\n", __FUNCTION__, le->stid,
> > +	     ntohl(le->addr), ntohs(ep->com.local_addr.sin_port));
> > +	return le;
> > +}
> > +
> > +static void dealloc_listener(struct iwch_listen_ep *ep,
> > +			     struct iwch_listen_entry *le) {
> > +	PDBG("%s stid %u addr %x port %x\n", __FUNCTION__, le->stid,
> > +	     ntohl(le->addr), ntohs(ep->com.local_addr.sin_port));
> > +	cxgb3_free_stid(ep->com.tdev, le->stid);
> > +	kfree(le);
> > +}
> > +
> > +static void dealloc_listener_list(struct iwch_listen_ep *ep) {
> > +	struct iwch_listen_entry *le, *tmp;
> > +	struct iwch_dev *h =3D to_iwch_dev(ep->com.cm_id->device);
> > +
> > +	mutex_lock(&h->mutex);
> > +	list_for_each_entry_safe(le, tmp, &ep->listeners, entry) {
> > +		list_del(&le->entry);
> > +		dealloc_listener(ep, le);
> > +	}
> > +	mutex_unlock(&h->mutex);
> > +}
> > +
> > +static int alloc_listener_list(struct iwch_listen_ep *ep) {
> > +	struct iwch_dev *h =3D to_iwch_dev(ep->com.cm_id->device);
>=20
> nit: in place of 'h' in several places, how about 'rnicp',=20
> which is also used?
>=20
> > +	struct iwch_addrlist *addr;
> > +	struct iwch_listen_entry *le;
> > +	int err =3D 0;
> > +	int added=3D0;
> > +	mutex_lock(&h->mutex);
> > +	list_for_each_entry(addr, &h->addrlist, entry) {
> > +		if (ep->com.local_addr.sin_addr.s_addr =3D=3D 0 ||
> > +		    ep->com.local_addr.sin_addr.s_addr =3D=3D
> > +		    addr->ifa->ifa_address) {
> > +			le =3D alloc_listener(ep, addr->ifa->ifa_address);
> > +			if (!le)
> > +				break;
> > +			list_add_tail(&le->entry, &ep->listeners);
> > +			added++;
> > +		}
> > +	}
> > +	mutex_unlock(&h->mutex);
> > +	if (ep->com.local_addr.sin_addr.s_addr !=3D 0 && !added)
> > +		err =3D -EADDRNOTAVAIL;
> > +	if (!err && !added)
> > +		printk(KERN_WARNING MOD
> > +		       "No RDMA interface found for device %s\n",
> > +		       pci_name(h->rdev.rnic_info.pdev));
> > +	return err;
> > +}
>=20
> Adding some white space would improve readability.
>=20
> > +
> > +static int listen_stop_one(struct iwch_listen_ep  *ep,=20
> unsigned int=20
> > +stid)
> >  {
> >  	struct sk_buff *skb;
> > -	struct cpl_pass_open_req *req;
> > +	struct cpl_close_listserv_req *req;
> > +
> > +	PDBG("%s stid %u\n", __FUNCTION__, stid);
> > +	skb =3D get_skb(NULL, sizeof(*req), GFP_KERNEL);
> > +	if (!skb) {
> > +		printk(KERN_ERR MOD "%s - failed to alloc=20
> skb\n", __FUNCTION__);
> > +		return -ENOMEM;
> > +	}
> > +	req =3D (struct cpl_close_listserv_req *) skb_put(skb,=20
> sizeof(*req));
> > +	req->wr.wr_hi =3D htonl(V_WR_OP(FW_WROPCODE_FORWARD));
> > +	req->cpu_idx =3D 0;
> > +	OPCODE_TID(req) =3D=20
> htonl(MK_OPCODE_TID(CPL_CLOSE_LISTSRV_REQ, stid));
> > +	skb->priority =3D 1;
> > +	ep->com.rpl_err =3D 0;
> > +	ep->com.rpl_done =3D 0;
> > +	cxgb3_ofld_send(ep->com.tdev, skb);
> > +	return wait_for_reply(&ep->com);
> > +}
> > +
> > +static int listen_stop(struct iwch_listen_ep *ep) {
> > +	struct iwch_listen_entry *le;
> > +	struct iwch_dev *h =3D to_iwch_dev(ep->com.cm_id->device);
> > +	int err =3D 0;
> > =20
> >  	PDBG("%s ep %p\n", __FUNCTION__, ep);
> > +	mutex_lock(&h->mutex);
> > +	list_for_each_entry(le, &ep->listeners, entry) {
> > +		err =3D listen_stop_one(ep, le->stid);
>=20
> This ends up blocking while holding a mutex, which looks like=20
> deadlock potential.
>=20
> > +		if (err)
> > +			break;
> > +	}
> > +	mutex_unlock(&h->mutex);
> > +	return err;
> > +}
> > +
> > +static int listen_start_one(struct iwch_listen_ep *ep,=20
> unsigned int stid,
> > +			    __be32 addr, __be16 port)
> > +{
> > +	struct sk_buff *skb;
> > +	struct cpl_pass_open_req *req;
> > +
> > +	PDBG("%s stid %u addr %x port %x\n", __FUNCTION__,=20
> stid, ntohl(addr),
> > +	     ntohs(port));
> >  	skb =3D get_skb(NULL, sizeof(*req), GFP_KERNEL);
> >  	if (!skb) {
> > -		printk(KERN_ERR MOD "t3c_listen_start failed to=20
> alloc skb!\n");
> > +		printk(KERN_ERR MOD "%s - failed to alloc=20
> skb\n", __FUNCTION__);
> >  		return -ENOMEM;
> >  	}
> > =20
> >  	req =3D (struct cpl_pass_open_req *) skb_put(skb, sizeof(*req));
> >  	req->wr.wr_hi =3D htonl(V_WR_OP(FW_WROPCODE_FORWARD));
> > -	OPCODE_TID(req) =3D=20
> htonl(MK_OPCODE_TID(CPL_PASS_OPEN_REQ, ep->stid));
> > -	req->local_port =3D ep->com.local_addr.sin_port;
> > -	req->local_ip =3D ep->com.local_addr.sin_addr.s_addr;
> > +	OPCODE_TID(req) =3D htonl(MK_OPCODE_TID(CPL_PASS_OPEN_REQ, stid));
> > +	req->local_port =3D port;
> > +	req->local_ip =3D addr;
> >  	req->peer_port =3D 0;
> >  	req->peer_ip =3D 0;
> >  	req->peer_netmask =3D 0;
> > @@ -1152,8 +1278,32 @@ static int listen_start(struct iwch_list
> >  	req->opt1 =3D htonl(V_CONN_POLICY(CPL_CONN_POLICY_ASK));
> > =20
> >  	skb->priority =3D 1;
> > +	ep->com.rpl_err =3D 0;
> > +	ep->com.rpl_done =3D 0;
> >  	cxgb3_ofld_send(ep->com.tdev, skb);
> > -	return 0;
> > +	return wait_for_reply(&ep->com);
> > +}
> > +
> > +static int listen_start(struct iwch_listen_ep *ep) {
> > +	struct iwch_listen_entry *le;
> > +	struct iwch_dev *h =3D to_iwch_dev(ep->com.cm_id->device);
> > +	int err =3D 0;
> > +
> > +	PDBG("%s ep %p\n", __FUNCTION__, ep);
> > +	mutex_lock(&h->mutex);
> > +	list_for_each_entry(le, &ep->listeners, entry) {
> > +		err =3D listen_start_one(ep, le->stid, le->addr,
> > +				 ep->com.local_addr.sin_port);
>=20
> Similar to above - blocking while holding a mutex.  There are=20
> a couple of other places where this also occurs.
>=20
> > +		if (err)
> > +			goto fail;
> > +	}
> > +	mutex_unlock(&h->mutex);
> > +	return err;
> > +fail:
> > +	mutex_unlock(&h->mutex);
> > +	listen_stop(ep);
> > +	return err;
> >  }
> > =20
> >  static int pass_open_rpl(struct t3cdev *tdev, struct sk_buff *skb,=20
> > void *ctx) @@ -1170,39 +1320,59 @@ static int=20
> pass_open_rpl(struct t3cdev *
> >  	return CPL_RET_BUF_DONE;
> >  }
> > =20
> > -static int listen_stop(struct iwch_listen_ep *ep) -{
> > -	struct sk_buff *skb;
> > -	struct cpl_close_listserv_req *req;
> > -
> > -	PDBG("%s ep %p\n", __FUNCTION__, ep);
> > -	skb =3D get_skb(NULL, sizeof(*req), GFP_KERNEL);
> > -	if (!skb) {
> > -		printk(KERN_ERR MOD "%s - failed to alloc=20
> skb\n", __FUNCTION__);
> > -		return -ENOMEM;
> > -	}
> > -	req =3D (struct cpl_close_listserv_req *) skb_put(skb,=20
> sizeof(*req));
> > -	req->wr.wr_hi =3D htonl(V_WR_OP(FW_WROPCODE_FORWARD));
> > -	req->cpu_idx =3D 0;
> > -	OPCODE_TID(req) =3D=20
> htonl(MK_OPCODE_TID(CPL_CLOSE_LISTSRV_REQ, ep->stid));
> > -	skb->priority =3D 1;
> > -	cxgb3_ofld_send(ep->com.tdev, skb);
> > -	return 0;
> > -}
> > -
> >  static int close_listsrv_rpl(struct t3cdev *tdev, struct=20
> sk_buff *skb,
> >  			     void *ctx)
> >  {
> >  	struct iwch_listen_ep *ep =3D ctx;
> >  	struct cpl_close_listserv_rpl *rpl =3D cplhdr(skb);
> > =20
> > -	PDBG("%s ep %p\n", __FUNCTION__, ep);
> > +	PDBG("%s ep %p stid %u\n", __FUNCTION__, ep, GET_TID(rpl));
> > +
> >  	ep->com.rpl_err =3D status2errno(rpl->status);
> >  	ep->com.rpl_done =3D 1;
> >  	wake_up(&ep->com.waitq);
> >  	return CPL_RET_BUF_DONE;
> >  }
> > =20
> > +void iwch_listeners_add_addr(struct iwch_dev *rnicp, __be32 addr) {
> > +	struct iwch_listen_ep *listen_ep;
> > +	struct iwch_listen_entry *le;
> > +
> > +	mutex_lock(&rnicp->mutex);
> > +	list_for_each_entry(listen_ep, &rnicp->listen_eps, entry) {
> > +		if (listen_ep->com.local_addr.sin_addr.s_addr)
> > +			continue;
> > +		le =3D alloc_listener(listen_ep, addr);
> > +		if (le) {
> > +			list_add_tail(&le->entry,=20
> &listen_ep->listeners);
> > +			listen_start_one(listen_ep, le->stid, addr,
> > +					=20
> listen_ep->com.local_addr.sin_port);
> > +		}
> > +	}
> > +	mutex_unlock(&rnicp->mutex);
> > +}
> > +
> > +void iwch_listeners_del_addr(struct iwch_dev *rnicp, __be32 addr) {
> > +	struct iwch_listen_ep *listen_ep;
> > +	struct iwch_listen_entry *le, *tmp;
> > +
> > +	mutex_lock(&rnicp->mutex);
> > +	list_for_each_entry(listen_ep, &rnicp->listen_eps, entry) {
> > +		if (listen_ep->com.local_addr.sin_addr.s_addr)
> > +			continue;
> > +		list_for_each_entry_safe(le, tmp, &listen_ep->listeners,
> > +					 entry)
> > +			if (le->addr =3D=3D addr) {
> > +				listen_stop_one(listen_ep, le->stid);
> > +				list_del(&le->entry);
> > +				dealloc_listener(listen_ep, le);
> > +			}
> > +	}
> > +	mutex_unlock(&rnicp->mutex);
> > +}
> > +
> >  static void accept_cr(struct iwch_ep *ep, __be32 peer_ip, struct=20
> > sk_buff *skb)  {
> >  	struct cpl_pass_accept_rpl *rpl;
> > @@ -1767,8 +1937,7 @@ int iwch_accept_cr(struct iw_cm_id *cm_i
> >  		goto err;
> > =20
> >  	/* wait for wr_ack */
> > -	wait_event(ep->com.waitq, ep->com.rpl_done);
> > -	err =3D ep->com.rpl_err;
> > +	err =3D wait_for_reply(&ep->com);
> >  	if (err)
> >  		goto err;
> > =20
> > @@ -1887,31 +2056,23 @@ int iwch_create_listen(struct iw_cm_id *
> >  	ep->com.cm_id =3D cm_id;
> >  	ep->backlog =3D backlog;
> >  	ep->com.local_addr =3D cm_id->local_addr;
> > +	INIT_LIST_HEAD(&ep->listeners);
> > =20
> > -	/*
> > -	 * Allocate a server TID.
> > -	 */
> > -	ep->stid =3D cxgb3_alloc_stid(h->rdev.t3cdev_p, &t3c_client, ep);
> > -	if (ep->stid =3D=3D -1) {
> > -		printk(KERN_ERR MOD "%s - cannot alloc=20
> atid.\n", __FUNCTION__);
> > -		err =3D -ENOMEM;
> > +	err =3D alloc_listener_list(ep);
> > +	if (err)
> >  		goto fail2;
> > -	}
> > =20
> >  	state_set(&ep->com, LISTEN);
> >  	err =3D listen_start(ep);
> > -	if (err)
> > -		goto fail3;
> > =20
> > -	/* wait for pass_open_rpl */
> > -	wait_event(ep->com.waitq, ep->com.rpl_done);
> > -	err =3D ep->com.rpl_err;
> >  	if (!err) {
> >  		cm_id->provider_data =3D ep;
> > +		mutex_lock(&h->mutex);
> > +		list_add_tail(&ep->entry, &h->listen_eps);
> > +		mutex_unlock(&h->mutex);
>=20
> Is there a race between listen_start() being called and=20
> inserting the ep into the list?  Could anything try to find=20
> the ep on the list after listen_start returns?
>=20
> >  		goto out;
> >  	}
> > -fail3:
> > -	cxgb3_free_stid(ep->com.tdev, ep->stid);
> > +	dealloc_listener_list(ep);
> >  fail2:
> >  	cm_id->rem_ref(cm_id);
> >  	put_ep(&ep->com);
> > @@ -1923,18 +2084,20 @@ out:
> >  int iwch_destroy_listen(struct iw_cm_id *cm_id)  {
> >  	int err;
> > +	struct iwch_dev *h =3D to_iwch_dev(cm_id->device);
> >  	struct iwch_listen_ep *ep =3D to_listen_ep(cm_id);
> > =20
> >  	PDBG("%s ep %p\n", __FUNCTION__, ep);
> > =20
> >  	might_sleep();
> > +	mutex_lock(&h->mutex);
> > +	list_del(&ep->entry);
> > +	mutex_unlock(&h->mutex);
> >  	state_set(&ep->com, DEAD);
> >  	ep->com.rpl_done =3D 0;
> >  	ep->com.rpl_err =3D 0;
> >  	err =3D listen_stop(ep);
> > -	wait_event(ep->com.waitq, ep->com.rpl_done);
> > -	cxgb3_free_stid(ep->com.tdev, ep->stid);
> > -	err =3D ep->com.rpl_err;
> > +	dealloc_listener_list(ep);
> >  	cm_id->rem_ref(cm_id);
> >  	put_ep(&ep->com);
> >  	return err;
> > diff --git a/drivers/infiniband/hw/cxgb3/iwch_cm.h=20
> > b/drivers/infiniband/hw/cxgb3/iwch_cm.h
> > index 6107e7c..23e5a22 100644
> > --- a/drivers/infiniband/hw/cxgb3/iwch_cm.h
> > +++ b/drivers/infiniband/hw/cxgb3/iwch_cm.h
> > @@ -162,10 +162,19 @@ struct iwch_ep_common {
> >  	int rpl_err;
> >  };
> > =20
> > -struct iwch_listen_ep {
> > -	struct iwch_ep_common com;
> > +struct iwch_listen_entry {
> > +	struct list_head entry;
> >  	unsigned int stid;
> > +	__be32 addr;
> > +};
> > +
> > +struct iwch_listen_ep {
> > +	struct iwch_ep_common com;	/* Must be first entry! */
> > +	struct list_head entry;
> > +	struct list_head listeners;
> >  	int backlog;
> > +	int listen_count;
>=20
> I didn't notice where this was used.
>=20
> > +	int listen_rpls;
>=20
> or this.
>=20
> >  };
> > =20
> >  struct iwch_ep {
> > @@ -222,6 +231,8 @@ int iwch_resume_tid(struct iwch_ep *ep);  void=20
> > __free_ep(struct kref *kref);  void iwch_rearp(struct=20
> iwch_ep *ep); =20
> > int iwch_ep_redirect(void *ctx, struct dst_entry *old, struct=20
> > dst_entry *new, struct l2t_entry *l2t);
> > +void iwch_listeners_add_addr(struct iwch_dev *rnicp, __be32 addr);=20
> > +void iwch_listeners_del_addr(struct iwch_dev *rnicp, __be32 addr);
> > =20
> >  int __init iwch_cm_init(void);
> >  void __exit iwch_cm_term(void);
> > _______________________________________________
> > general mailing list
> > general@lists.openfabrics.org
> > http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general
> >=20
> > To unsubscribe, please visit=20
> > http://openib.org/mailman/listinfo/openib-general
> >=20
> _______________________________________________
> general mailing list
> general@lists.openfabrics.org
> http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general
>=20
> To unsubscribe, please visit=20
> http://openib.org/mailman/listinfo/openib-general
>=20
