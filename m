From: "Yang, Yi" <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v3] openvswitch: enable NSH support
Date: Thu, 17 Aug 2017 07:49:41 +0800
Message-ID: <20170816234940.GB123125@cran64.bj.intel.com>
References: <1502861730-76203-1-git-send-email-yi.y.yang@intel.com>
	<20170816151528.GG27729@dev-rhel7>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: Eric Garver <e@erig.me>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170816151528.GG27729@dev-rhel7>
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

On Wed, Aug 16, 2017 at 11:15:28PM +0800, Eric Garver wrote:
> On Wed, Aug 16, 2017 at 01:35:30PM +0800, Yi Yang wrote:
> > +
> > +#define NSH_DST_PORT    4790     /* UDP Port for NSH on VXLAN. */
> > +#define ETH_P_NSH       0x894F   /* Ethertype for NSH. */
> 
> ETH_P_NSH probably belongs in include/uapi/linux/if_ether.h with all the
> other ETH_P_* defines.
> 

Ok, I'll move it to include/uapi/linux/if_ether.h, but in userspace, we
still need to keep it in nsh.h.

> >  
> > +struct ovs_key_nsh {
> > +	__u8 flags;
> > +	__u8 mdtype;
> > +	__u8 np;
> > +	__u8 pad;
> > +	__be32 path_hdr;
> > +	__be32 context[NSH_MD1_CONTEXT_SIZE];
> > +};
> > +
> >  struct sw_flow_key {
> >  	u8 tun_opts[IP_TUNNEL_OPTS_MAX];
> >  	u8 tun_opts_len;
> > @@ -144,6 +154,7 @@ struct sw_flow_key {
> >  			};
> >  		} ipv6;
> >  	};
> > +	struct ovs_key_nsh nsh;         /* network service header */
> 
> Are you intentionally not reserving space in the flow key for
> OVS_NSH_KEY_ATTR_MD2? I know it's not supported yet, but much of the
> code is stubbed out for it - just making sure this wasn't an oversight.
> 

For MD type 2, we'll reuse tun_metedata keys in struct flow_tnl which
will be reworked and it will be shared by NSH and GENEVE, so we won't
have new keys in "struct ovs_key_nsh" for MD type 2.

> >  	struct {
> >  		/* Connection tracking fields not packed above. */
> >  		struct {
> > diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
> > index f07d10a..79059db 100644
> > --- a/net/openvswitch/flow_netlink.c
> > +++ b/net/openvswitch/flow_netlink.c
> > @@ -78,9 +78,11 @@ static bool actions_may_change_flow(const struct nlattr *actions)
> >  		case OVS_ACTION_ATTR_HASH:
> >  		case OVS_ACTION_ATTR_POP_ETH:
> >  		case OVS_ACTION_ATTR_POP_MPLS:
> > +		case OVS_ACTION_ATTR_POP_NSH:
> >  		case OVS_ACTION_ATTR_POP_VLAN:
> >  		case OVS_ACTION_ATTR_PUSH_ETH:
> >  		case OVS_ACTION_ATTR_PUSH_MPLS:
> > +		case OVS_ACTION_ATTR_PUSH_NSH:
> >  		case OVS_ACTION_ATTR_PUSH_VLAN:
> >  		case OVS_ACTION_ATTR_SAMPLE:
> >  		case OVS_ACTION_ATTR_SET:
> > @@ -322,12 +324,22 @@ size_t ovs_tun_key_attr_size(void)
> >  		+ nla_total_size(2);   /* OVS_TUNNEL_KEY_ATTR_TP_DST */
> >  }
> >  
> > +size_t ovs_nsh_key_attr_size(void)
> > +{
> > +	/* Whenever adding new OVS_NSH_KEY_ FIELDS, we should consider
> > +	 * updating this function.
> > +	 */
> > +	return  nla_total_size(8)      /* OVS_NSH_KEY_ATTR_BASE */
> > +		+ nla_total_size(16)   /* OVS_NSH_KEY_ATTR_MD1 */
> > +		+ nla_total_size(248); /* OVS_NSH_KEY_ATTR_MD2 */
> 
> _MD1 and _MD2 are mutually exclusive. You only need the larger of the
> two.
> 
> Maybe use OVS_PUSH_NSH_MAX_MD_LEN instead of 248.

Got it, will use nla_total_size(NSH_M_TYPE2_MAX_LEN - NSH_BASE_HDR_LEN)

> > +
> > +		switch (type) {
> > +		case OVS_NSH_KEY_ATTR_BASE: {
> > +			const struct ovs_nsh_key_base *base =
> > +				(struct ovs_nsh_key_base *)nla_data(a);
> > +			nsh->flags = base->flags;
> > +			nsh->mdtype = base->mdtype;
> > +			nsh->np = base->np;
> > +			nsh->path_hdr = base->path_hdr;
> > +			break;
> > +		}
> > +		case OVS_NSH_KEY_ATTR_MD1: {
> > +			const struct ovs_nsh_key_md1 *md1 =
> > +				(struct ovs_nsh_key_md1 *)nla_data(a);
> > +			memcpy(nsh->context, md1->context, sizeof(*md1));
> > +			break;
> > +		}
> > +		case OVS_NSH_KEY_ATTR_MD2:
> > +			/* Not supported yet */
> > +			break;
> 
> When we encounter these metadata attributes do we need to verify that
> nsh->mdtype is set correctly? Keep in mind we may parse ATTR_MD{1,2}
> before ATTR_BASE.

Good point, will add check code for this.
