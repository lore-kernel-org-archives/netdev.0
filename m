From: Ben Pfaff <blp-LZ6Gd1LRuIk@public.gmane.org>
Subject: Re: [PATCH net-next] openvswitch: add NSH support
Date: Tue, 8 Aug 2017 19:42:00 -0700
Message-ID: <20170809024200.GG6175@ovn.org>
References: <1502168380-106785-1-git-send-email-yi.y.yang@intel.com>
	<20170808162810.1bab3812@griffin>
	<79BBBFE6CB6C9B488C1A45ACD284F51961C391CA@SHSMSX103.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: "Yang, Yi Y" <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <79BBBFE6CB6C9B488C1A45ACD284F51961C391CA-0J0gbvR4kTggGBtAFL8yw7fspsVTdybXVpNB7YpNyf8@public.gmane.org>
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

To be clear, the OVS implementation is a placeholder.  It will get
replaced by whatever netdev implements, and that's OK.  I didn't focus
on making it perfect because I knew that.  Instead, I just made sure it
was good enough for an internal OVS implementation that doesn't fix any
ABI or API.  OVS can even change the user-visible action names, as long
as we do that soon (and encap/decap versus push/pop doesn't matter to
me).

The considerations for netdev are different and more permanent.

On Wed, Aug 09, 2017 at 02:05:12AM +0000, Yang, Yi Y wrote:
> Hi, Jiri
> 
> Thank you for your comments.
> 
> __be32 c[4] is the name Ben Pfaff suggested, the original name is c1, c2, c3, c4, they are context data, so c seems ok, too :-)
> 
> OVS has merged it and has the same name, maybe the better way is adding comment /* Context data */ after it.
> 
> For MD type 2, struct ovs_key_nsh is very difficult to cover it, so far we don't know how to support MD type 2 better, Geneve defined 64 tun_metadata0-63 to handle this, those keys are parts of struct flow_tnl, the highest possibility is to reuse those keys.
> 
> So for future MD type 2, we will have two parts of keys, one is from struct ovs_key_nsh, another is from struct flow_tnl, this won't break the old uAPI.
> 
> "#define OVS_ENCAP_NSH_MAX_MD_LEN 16" is changed per Ben's comment from 256, Ben thinks 256 is too big but we only support MD type 1 now. We still have ways to extend it, for example:
> 
> struct ovs_action_encap_nsh * oaen = (struct ovs_action_encap_nsh *) malloc (sizeof(struct ovs_action_encap_nsh) + ANY_SIZE);
> 
> nl_msg_put_unspec(actions, OVS_ACTION_ATTR_ENCAP_NSH,
>                           oaen, sizeof(struct ovs_action_encap_nsh) + ANY_SIZE);
> 
> In addition, we also need to consider, OVS userspace code must be consistent with here, so keeping it intact will be better, we have way to support dynamically extension when we add MD type 2 support.
> 
> About action name, unfortunately, userspace data plane has named them as encap_nsh & decap_nsh, Jan, what do you think about Jiri's suggestion?
> 
> But from my understanding, encap_* & decap_* are better because they corresponding to generic encap & decap actions, in addition, encap semantics are different from push, encap just pushed an empty header with default values, users must use set_field to set the content of the header.
> 
> Again, OVS userspace code must be consistent with here, so keeping it intact will be better because OVS userspace code was there.
> 
> 
> -----Original Message-----
> From: netdev-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org [mailto:netdev-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org] On Behalf Of Jiri Benc
> Sent: Tuesday, August 8, 2017 10:28 PM
> To: Yang, Yi Y <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org; davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
> Subject: Re: [PATCH net-next] openvswitch: add NSH support
> 
> On Tue,  8 Aug 2017 12:59:40 +0800, Yi Yang wrote:
> > +struct ovs_key_nsh {
> > +	__u8 flags;
> > +	__u8 mdtype;
> > +	__u8 np;
> > +	__u8 pad;
> > +	__be32 path_hdr;
> > +	__be32 c[4];
> 
> "c" is a very poor name. Please rename it to something that expresses what this field contains.
> 
> Also, this looks like MD type 1 only. How are those fields going to work with MD type 2? I don't think MD type 2 implementation is necessary in this patch but I'd like to know how this is going to work - it's uAPI and thus set in stone once this is merged. The uAPI needs to be designed with future use in mind.
> 
> > +#define OVS_ENCAP_NSH_MAX_MD_LEN 16
> > +/*
> > + * struct ovs_action_encap_nsh - %OVS_ACTION_ATTR_ENCAP_NSH
> > + * @flags: NSH header flags.
> > + * @mdtype: NSH metadata type.
> > + * @mdlen: Length of NSH metadata in bytes.
> > + * @np: NSH next_protocol: Inner packet type.
> > + * @path_hdr: NSH service path id and service index.
> > + * @metadata: NSH metadata for MD type 1 or 2  */ struct 
> > +ovs_action_encap_nsh {
> > +	__u8 flags;
> > +	__u8 mdtype;
> > +	__u8 mdlen;
> > +	__u8 np;
> > +	__be32 path_hdr;
> > +	__u8 metadata[OVS_ENCAP_NSH_MAX_MD_LEN];
> 
> This is wrong. The metadata size is set to a fixed size by this and cannot be ever extended, or at least not easily. Netlink has attributes for exactly these cases and that's what needs to be used here.
> 
> > @@ -835,6 +866,8 @@ enum ovs_action_attr {
> >  	OVS_ACTION_ATTR_TRUNC,        /* u32 struct ovs_action_trunc. */
> >  	OVS_ACTION_ATTR_PUSH_ETH,     /* struct ovs_action_push_eth. */
> >  	OVS_ACTION_ATTR_POP_ETH,      /* No argument. */
> > +	OVS_ACTION_ATTR_ENCAP_NSH,    /* struct ovs_action_encap_nsh. */
> > +	OVS_ACTION_ATTR_DECAP_NSH,    /* No argument. */
> 
> Use "push" and "pop", not "encap" and "decap" to be consistent with the naming in the rest of the file. We use encap and decap for tunnel operations. This code does not use lwtunnels, thus push and pop is more appropriate.
> 
>  Jiri
> _______________________________________________
> dev mailing list
> dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
> https://mail.openvswitch.org/mailman/listinfo/ovs-dev
