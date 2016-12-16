From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [RFC v2 00/10] HFI Virtual Network Interface Controller (VNIC)
Date: Thu, 15 Dec 2016 21:17:27 -0700
Message-ID: <20161216041727.GA3797@obsidianresearch.com>
References: <1481788782-89964-1-git-send-email-niranjana.vishwanathapura@intel.com>
 <20161215091226.GC811@mtr-leonro.local>
 <20161215145212.GA29116@phlsvsds.ph.intel.com>
 <380b05bf-a18e-1f20-7e8e-10b61f77dec7@redhat.com>
 <20161215170713.GD3264@obsidianresearch.com>
 <4e22bf29-2260-0768-ab17-9a8df6306f37@redhat.com>
 <20161215184837.GA16552@obsidianresearch.com>
 <20161216012404.GD3785@phlsvsds.ph.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: "ira.weiny" <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20161216012404.GD3785-W4f6Xiosr+yv7QzWx2u06xL4W9x8LtSr@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 15, 2016 at 08:24:05PM -0500, ira.weiny wrote:
> > The main share is the 'skb send' part, we've talked about hoisting
> > that out of ipoib in the past anyhow. A generic verb along those lines
> > would probably allow the sdma optimization for hfi for both this new
> > ulp and ipoib without creating such an ugly HFI1 specific interface.
> 
> I'm not sure what you mean about "skb send" being used by ipoib.  Right now
> IPoIB already supplies a "generic skb send" for _Verbs_ in ipoib_send.

Sending a skb is very hard, the boring standard verbs implementation
is slow. Mellanox extended that with some simple offloads, but it is not
enough to get the full performance out of the hardware.

The suggestion is to add a 'skb qp', for lack of a better name, that is
perfectly optimized to delegate working with skbs to the driver. The
driver will then optmize with all possible offloads and bypass the
verbs qp API between netdev and driver.

Look at what is already in patch #2:

+struct hfi_vnic_ops {
+	int (*open)(struct hfi_vnic_port *vport, hfi_vnic_evt_cb_fn cb);
+	void (*close)(struct hfi_vnic_port *vport);
+	int (*put_skb)(struct hfi_vnic_port *vport,
+	           u8 q_idx, struct sk_buff *skb);
+       struct sk_buff *(*get_skb)(struct hfi_vnic_port *vport, u8 q_idx);
+	      u16 (*get_read_avail)(struct hfi_vnic_port *vport, u8 q_idx);
+	bool (*get_write_avail)(struct hfi_vnic_port *vport, u8 q_idx);
+	u8 (*select_queue)(struct hfi_vnic_port *vport, u8 vl, u8 entropy);
+	void (*config_notify)(struct hfi_vnic_port *vport,
+	     			           u8 evt, bool enable);

That is almost what I'm talking about.

A 'vport' is a 'skb qp' that has been made overly specific.

So, clean it up to get rid of all the hfi specific stuff, stop calling
it a port. Get feedback from Mellanox. Refactor ipoib to use it to
show that it works sanely with both drivers.

> I don't know what other devices would do to implement ipoib_send?  To me, it
> seems like the abstraction for IPoIB is at the proper layer now.

An example is multi queue tx with QPN sharing. We don't have anything
like that in verbs. At some point it just doesn't make sense to twist
verbs into knots to do this stuff - a skb qp is much cleaner and
powerful.

> For OPA, te hfi driver supports both IPoIB and VNIC.  So expecting IPoIB and
> VNIC to use a generic "skb send" in ib_device is going to make hfi1 do a lot of
> work to determine which ULP is calling it or make the interface kind
> of ugly.

I don' think it will be that bad at all, the tx path is actually the
same execpt for the header construction. Handling that should not be
ugly, IMHO.

Think of it this way, if you do this you can probably boost the ipoib
performance on hfi as well.

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
