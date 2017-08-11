From: "Yang, Yi" <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v2] openvswitch: enable NSH support
Date: Fri, 11 Aug 2017 16:47:23 +0800
Message-ID: <20170811084722.GA19968@cran64.bj.intel.com>
References: <1502371275-52446-1-git-send-email-yi.y.yang@intel.com>
	<20170811102418.6b1be4f7@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170811102418.6b1be4f7@griffin>
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

On Fri, Aug 11, 2017 at 10:24:18AM +0200, Jiri Benc wrote:
> On Thu, 10 Aug 2017 21:21:15 +0800, Yi Yang wrote:
> > OVS master and 2.8 branch has merged NSH userspace
> > patch series, this patch is to enable NSH support
> > in kernel data path in order that OVS can support
> > NSH in 2.8 release in compat mode by porting this.
> 
> Please include changelog when posting a new version of a patch.
> 
> > +static inline u16
> > +nsh_hdr_len(const struct nsh_hdr *nsh)
> 
> Single line, please. And all other instances of this in nsh.h, too.

Thanks Jiri, I'll change these in next version.

> 
> > --- a/include/uapi/linux/openvswitch.h
> > +++ b/include/uapi/linux/openvswitch.h
> > @@ -333,6 +333,7 @@ enum ovs_key_attr {
> >  	OVS_KEY_ATTR_CT_LABELS,	/* 16-octet connection tracking label */
> >  	OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV4,   /* struct ovs_key_ct_tuple_ipv4 */
> >  	OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV6,   /* struct ovs_key_ct_tuple_ipv6 */
> > +	OVS_KEY_ATTR_NSH,                  /* struct ovs_key_nsh */
> >  
> >  #ifdef __KERNEL__
> >  	OVS_KEY_ATTR_TUNNEL_INFO,  /* struct ip_tunnel_info */
> > @@ -491,6 +492,15 @@ struct ovs_key_ct_tuple_ipv6 {
> >  	__u8   ipv6_proto;
> >  };
> >  
> > +struct ovs_key_nsh {
> > +	__u8 flags;
> > +	__u8 mdtype;
> > +	__u8 np;
> > +	__u8 pad;
> > +	__be32 path_hdr;
> > +	__be32 c[4];
> 
> I still don't like the "c" name. Please change it to something
> descriptive. This is uAPI and can't be changed later.

is "__be32 context[4]" ok?

> 
> And I still don't see my comment about this not being extensible for
> MD type 2 addressed. Please understand this is uAPI and it is set in
> stone once it is merged into the kernel. It's very important we get
> this right since the beginning.

I understood it, but I don't know how I can do this per your comments,

Per Ben's comments,

PUSH_NSH message looks like

PUSH_NSH begin
    nsh base header
    MD type 1
PUSH_NSH end

or 

PUSH_NSH begin
    nsh base header
    MD type 2
PUSH_NSH end

If so, I think we don't need struct ovs_action_push_nsh at all, just as
_CT action did, treat it as a variable data buffer.

So define three new netlink attributes

OVS_ACTION_ATTR_NSH_BASE_HEADER
OVS_ACTION_ATTR_NSH_MD1_DATA
OVS_ACTION_ATTR_NSH_MD2_DATA

OVS_ACTION_ATTR_PUSH_NSH is nested netlink attribute, it will nest
OVS_ACTION_ATTR_NSH_BASE_HEADER and OVS_ACTION_ATTR_NSH_MD1_DATA for MD
type 1, it will nest OVS_ACTION_ATTR_NSH_BASE_HEADER and
OVS_ACTION_ATTR_NSH_MD2_DATA for MD type 2. I'll compeletely remove struct
ovs_action_push_nsh, is it ok?

> 
> > +struct ovs_action_push_nsh {
> > +	__u8 flags;
> > +	__u8 mdtype;
> > +	__u8 mdlen;
> > +	__u8 np;
> > +	__be32 path_hdr;
> > +	__u8 metadata[];
> > +};
> 
> This is not how netlink attributes work. Please reread Ben Pfaff's
> explanation on how this needs to be structured (Message-ID:
> <20170809180912.GU6175-LZ6Gd1LRuIk@public.gmane.org>) and rework the patch. I 100% agree
> with what he wrote, his proposal is very clean and matches how netlink
> is designed.
> 
> > @@ -835,6 +866,8 @@ enum ovs_action_attr {
> >  	OVS_ACTION_ATTR_TRUNC,        /* u32 struct ovs_action_trunc. */
> >  	OVS_ACTION_ATTR_PUSH_ETH,     /* struct ovs_action_push_eth. */
> >  	OVS_ACTION_ATTR_POP_ETH,      /* No argument. */
> > +	OVS_ACTION_ATTR_PUSH_NSH,     /* struct ovs_action_push_nsh. */
> > +	OVS_ACTION_ATTR_POP_NSH,      /* No argument. */
> 
> Thank you for changing this to push/pop, it looks much cleaner now.
> 
> > +static int parse_nsh(struct sk_buff *skb, struct sw_flow_key *key)
> > +{
> > +	struct nsh_hdr *nsh = (struct nsh_hdr *)skb_network_header(skb);
> > +	u16 ver_flags_len;
> > +	u8 version, length;
> > +	u32 path_hdr;
> > +	int i;
> > +
> > +	memset(&key->nsh, 0, sizeof(struct ovs_key_nsh));
> > +	ver_flags_len = ntohs(nsh->ver_flags_len);
> > +	version = (ver_flags_len & NSH_VER_MASK) >> NSH_VER_SHIFT;
> > +	length = (ver_flags_len & NSH_LEN_MASK) >> NSH_LEN_SHIFT;
> 
> A nit: the operation to get/set version, length and flags from the NSH
> header seems to be repeated enough to warrant helper functions in
> include/net/nsh.h. Something like:
> 
> static inline u8 nsh_get_version(const struct nsh_hdr *nsh)
> {
> 	return (ntohs(nsh->ver_flags_len) & NSH_VER_MASK) >> NSH_VER_SHIFT;
> }
> 
> etc.
> 
> Not a blocker, though, it may be done later if needed.

Ok, will change it.

> 
> > @@ -76,9 +77,11 @@ static bool actions_may_change_flow(const struct nlattr *actions)
> >  
> >  		case OVS_ACTION_ATTR_CT:
> >  		case OVS_ACTION_ATTR_HASH:
> > +		case OVS_ACTION_ATTR_POP_NSH:
> >  		case OVS_ACTION_ATTR_POP_ETH:
> >  		case OVS_ACTION_ATTR_POP_MPLS:
> >  		case OVS_ACTION_ATTR_POP_VLAN:
> > +		case OVS_ACTION_ATTR_PUSH_NSH:
> >  		case OVS_ACTION_ATTR_PUSH_ETH:
> >  		case OVS_ACTION_ATTR_PUSH_MPLS:
> >  		case OVS_ACTION_ATTR_PUSH_VLAN:
> 
> Alphabetical order, please.

Ok, will change.
> 
> Thanks,
> 
>  Jiri
