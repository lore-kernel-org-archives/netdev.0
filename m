From: Jiannan Ouyang <ouyangj-b10kYP2dOMg@public.gmane.org>
Subject: Re: [PATCH net-next v1 2/3] gtp: Support creating
 flow-based gtp net_device
Date: Fri, 14 Jul 2017 01:01:34 +0000
Message-ID: <FFC0D5B5-37F4-4DD0-B294-FE3074EA9017@fb.com>
References: <20170713004455.3946570-1-ouyangj@fb.com>
	<20170713004455.3946570-3-ouyangj@fb.com>
	<20170713073540.q4tqqawhxwzqrzsv@nataraja>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"osmocom-net-gprs-qjLDD68F18N4m7O/Vxda39i2O/JbrIOy@public.gmane.org" <osmocom-net-gprs-qjLDD68F18N4m7O/Vxda39i2O/JbrIOy@public.gmane.org>,
	"pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org" <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
To: Harald Welte <laforge-TgoAw6mPHtdg9hUCZPvPmw@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20170713073540.q4tqqawhxwzqrzsv@nataraja>
Content-Language: en-US
Content-ID: <5138DB046C19FF4994BDA52596DEF76A-JGF9Izt3QrScE4WynfumptQqCkab/8FMAL8bYrjMMd8@public.gmane.org>
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Harald,

> On 7/13/17, 12:35 AM, "Harald Welte" <laforge-TgoAw6mPHtdg9hUCZPvPmw@public.gmane.org> wrote:
> 
> > +static int gtp_dev_open(struct net_device *dev)
> > +{
> > +	struct gtp_dev *gtp = netdev_priv(dev);
> > +	struct net *net = gtp->net;
> > +	struct socket *sock1u;
> > +	struct socket *sock0;
> > +	struct udp_tunnel_sock_cfg tunnel_cfg;
> > +	struct udp_port_cfg udp_conf;
> > +	int err;
> > +
> > +	memset(&udp_conf, 0, sizeof(udp_conf));
> > +
> > +	udp_conf.family = AF_INET;
> > +	udp_conf.local_ip.s_addr = htonl(INADDR_ANY);
> > +	udp_conf.local_udp_port = htons(GTP1U_PORT);
> > +
> > +	err = udp_sock_create(gtp->net, &udp_conf, &sock1u);
> > +	if (err < 0)
> > +		return err;
> > +
> > +	udp_conf.local_udp_port = htons(GTP0_PORT);
> > +	err = udp_sock_create(gtp->net, &udp_conf, &sock0);
> > +	if (err < 0)
> > +		return err;
> 
> you're unconditionally binding to both GTP0 and GTP1 UDP ports.  This is
> done selectively based on netlink attributes in the existing "normal"
> non-OVS kernel code, i.e. the control is left to the user.
> 
> Is this function is only called/used in the context of OVS?  If so,
> since you explicitly implement only GTPv1, why bind to GTPv0 port?
> 

I had doubts on how this flow-based GTPv1 code path should fit in, which is why
the GTPv0 and the GTPv1 code pieces are mixed in my changes. Should I
explicitly claim that the flow-based change is for GTPv1 only?

> > +	setup_udp_tunnel_sock(net, sock1u, &tunnel_cfg);
> 
> even here, you're only setting up the v1 and not v0.
> 

same reason as above.

> > +	/* Assume largest header, ie. GTPv0. */
> > +	dev->needed_headroom	= LL_MAX_HEADER +
> > +		sizeof(struct iphdr) +
> > +		sizeof(struct udphdr) +
> > +		sizeof(struct gtp0_header);
> 
> ... and here you're using headroom for a GTPv0 header, despite (I think)
> only supporting GTPv1 from this configuration?

Yes, only GTPv1 is supported.

> 
> > +	err = gtp_hashtable_new(gtp, GTP_PDP_HASHSIZE); // JO: when to free??
> 
> I think that question about when to free needs to be resolved before any
> merge.  Did you check that it persists even after the device is
> closed/removed?

I didn't investigate it. What do you mean by persist?

Thanks
-Jiannan
