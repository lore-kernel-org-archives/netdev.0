From: "Yang, Yi" <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v2] openvswitch: enable NSH support
Date: Tue, 15 Aug 2017 08:39:41 +0800
Message-ID: <20170815003940.GA86193@cran64.bj.intel.com>
References: <1502371275-52446-1-git-send-email-yi.y.yang@intel.com>
	<20170814160914.GC27729@dev-rhel7>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: Eric Garver <e@erig.me>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170814160914.GC27729@dev-rhel7>
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

On Tue, Aug 15, 2017 at 12:09:14AM +0800, Eric Garver wrote:
> On Thu, Aug 10, 2017 at 09:21:15PM +0800, Yi Yang wrote:
> 
> Hi Yi,
> 
> In general I'd like to echo Jiri's comments on the netlink attributes.
> I'd like to see the metadata separate.
> 
> I have a few other comments below.
> 
> Thanks.
> Eric.
> 
> [..]

Thanks Eric, I'm doing this and it is almost done, there is still an
issue to fix.

> > +{
> > +	return 4 * (ntohs(nsh->ver_flags_len) & NSH_LEN_MASK) >> NSH_LEN_SHIFT;
> 
> This is doing the multiplication before the shift. It works only because
> the shift is 0.
> 

Thank you for catching this, the right one:

((ntohs(nsh->ver_flags_len) & NSH_LEN_MASK) >> NSH_LEN_SHIFT) << 2

> > +static int push_nsh(struct sk_buff *skb, struct sw_flow_key *key,
> > +		    const struct ovs_action_push_nsh *oapn)
> > +{
> > +	struct nsh_hdr *nsh;
> > +	size_t length = NSH_BASE_HDR_LEN + oapn->mdlen;
> > +	u8 next_proto;
> > +
> > +	if (key->mac_proto == MAC_PROTO_ETHERNET) {
> > +		next_proto = NSH_P_ETHERNET;
> > +	} else {
> > +		switch (ntohs(skb->protocol)) {
> > +		case ETH_P_IP:
> > +			next_proto = NSH_P_IPV4;
> > +			break;
> > +		case ETH_P_IPV6:
> > +			next_proto = NSH_P_IPV6;
> > +			break;
> > +		case ETH_P_NSH:
> > +			next_proto = NSH_P_NSH;
> > +			break;
> > +		default:
> > +			return -ENOTSUPP;
> > +		}
> > +	}
> > +
> >
> 
> I believe you need to validate that oapn->mdlen is a multiple of 4.
>

I'll add this check.

> > +	switch (nsh->md_type) {
> > +	case NSH_M_TYPE1:
> > +		nsh->md1 = *(struct nsh_md1_ctx *)oapn->metadata;
> > +		break;
> > +	case NSH_M_TYPE2: {
> > +		/* The MD2 metadata in oapn is already padded to 4 bytes. */
> > +		size_t len = DIV_ROUND_UP(oapn->mdlen, 4) * 4;
> > +
> > +		memcpy(nsh->md2, oapn->metadata, len);
> 
> I don't see any validation of oapn->mdlen. Normally this happens in
> __ovs_nla_copy_actions(). It will be made easier if you add a separate
> MD attribute as Jiri has suggested.
>

Got it, will include this in next version.
