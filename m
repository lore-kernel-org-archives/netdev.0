From: Harald Welte <laforge-TgoAw6mPHtdg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH net-next v1 2/3] gtp: Support creating
 flow-based gtp net_device
Date: Thu, 13 Jul 2017 09:35:41 +0200
Message-ID: <20170713073540.q4tqqawhxwzqrzsv@nataraja>
References: <20170713004455.3946570-1-ouyangj@fb.com>
	<20170713004455.3946570-3-ouyangj@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	osmocom-net-gprs-qjLDD68F18N4m7O/Vxda39i2O/JbrIOy@public.gmane.org, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org
To: Jiannan Ouyang <ouyangj-b10kYP2dOMg@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170713004455.3946570-3-ouyangj-b10kYP2dOMg@public.gmane.org>
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

Hi Jiannan,

please keep in mind I have zero clue about OVS, so I cannot really
comment on what is customary in that context and what not.  However,
some general review from the GTP point of view below:

On Wed, Jul 12, 2017 at 05:44:54PM -0700, Jiannan Ouyang wrote:
> Add the gtp_create_flow_based_dev() interface to create flow-based gtp
> net_device, which sets gtp->collect_md. Under flow-based mode, UDP sockets are
> created and maintained in kernel.
> 
> Signed-off-by: Jiannan Ouyang <ouyangj-b10kYP2dOMg@public.gmane.org>
> ---
>  drivers/net/gtp.c | 213 +++++++++++++++++++++++++++++++++++++++++++++++++++++-
>  include/net/gtp.h |   8 ++
>  2 files changed, 217 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
> index 5a7b504..09712c9 100644
> --- a/drivers/net/gtp.c
> +++ b/drivers/net/gtp.c
> @@ -642,9 +642,94 @@ static netdev_tx_t gtp_dev_xmit(struct sk_buff *skb, struct net_device *dev)
>  	return NETDEV_TX_OK;
>  }
>  
> +static int gtp_hashtable_new(struct gtp_dev *gtp, int hsize);
> +static void gtp_hashtable_free(struct gtp_dev *gtp);
> +static int gtp_encap_enable(struct gtp_dev *gtp, struct nlattr *data[]);
> +
> +static int gtp_change_mtu(struct net_device *dev, int new_mtu, bool strict)
> +{
> +	int max_mtu = IP_MAX_MTU - dev->hard_header_len - sizeof(struct iphdr)
> +			- sizeof(struct udphdr) - sizeof(struct gtp1_header);
> +
> +	if (new_mtu < ETH_MIN_MTU)
> +		return -EINVAL;
> +
> +	if (new_mtu > max_mtu) {
> +		if (strict)
> +			return -EINVAL;
> +
> +		new_mtu = max_mtu;
> +	}
> +
> +	dev->mtu = new_mtu;
> +	return 0;
> +}
> +
> +static int gtp_dev_open(struct net_device *dev)
> +{
> +	struct gtp_dev *gtp = netdev_priv(dev);
> +	struct net *net = gtp->net;
> +	struct socket *sock1u;
> +	struct socket *sock0;
> +	struct udp_tunnel_sock_cfg tunnel_cfg;
> +	struct udp_port_cfg udp_conf;
> +	int err;
> +
> +	memset(&udp_conf, 0, sizeof(udp_conf));
> +
> +	udp_conf.family = AF_INET;
> +	udp_conf.local_ip.s_addr = htonl(INADDR_ANY);
> +	udp_conf.local_udp_port = htons(GTP1U_PORT);
> +
> +	err = udp_sock_create(gtp->net, &udp_conf, &sock1u);
> +	if (err < 0)
> +		return err;
> +
> +	udp_conf.local_udp_port = htons(GTP0_PORT);
> +	err = udp_sock_create(gtp->net, &udp_conf, &sock0);
> +	if (err < 0)
> +		return err;

you're unconditionally binding to both GTP0 and GTP1 UDP ports.  This is
done selectively based on netlink attributes in the existing "normal"
non-OVS kernel code, i.e. the control is left to the user.

Is this function is only called/used in the context of OVS?  If so,
since you explicitly implement only GTPv1, why bind to GTPv0 port?

> +	setup_udp_tunnel_sock(net, sock1u, &tunnel_cfg);

even here, you're only setting up the v1 and not v0.

> +	/* Assume largest header, ie. GTPv0. */
> +	dev->needed_headroom	= LL_MAX_HEADER +
> +		sizeof(struct iphdr) +
> +		sizeof(struct udphdr) +
> +		sizeof(struct gtp0_header);

... and here you're using headroom for a GTPv0 header, despite (I think)
only supporting GTPv1 from this configuration?

> +	err = gtp_hashtable_new(gtp, GTP_PDP_HASHSIZE); // JO: when to free??

I think that question about when to free needs to be resolved before any
merge.  Did you check that it persists even after the device is
closed/removed?

-- 
- Harald Welte <laforge-TgoAw6mPHtdg9hUCZPvPmw@public.gmane.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)
