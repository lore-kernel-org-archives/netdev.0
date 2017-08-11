From: Jan Scheurich <jan.scheurich-IzeFyvvaP7pWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH net-next v2] openvswitch: enable NSH support
Date: Fri, 11 Aug 2017 10:09:36 +0000
Message-ID: <CFF8EF42F1132E4CBE2BF0AB6C21C58D7273679A@ESESSMB107.ericsson.se>
References: <1502371275-52446-1-git-send-email-yi.y.yang@intel.com>
	<20170811102418.6b1be4f7@griffin>
	<20170811084722.GA19968@cran64.bj.intel.com>
	<20170811111055.482bd42b@griffin>
	<79BBBFE6CB6C9B488C1A45ACD284F51961C427FE@SHSMSX103.ccr.corp.intel.com>
	<20170811114449.745c49c5@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Yang, Yi Y" <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20170811114449.745c49c5@griffin>
Content-Language: en-US
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

> -----Original Message-----
> From: Jiri Benc [mailto:jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org]
> Sent: Friday, 11 August, 2017 11:45
> 
> The context field does not apply to MD type 2. It looks wrong for the
> context field to be included in netlink attribute for anything other
> than MD type 1. Perhaps it needs to be put into a separate attribute,
> too?
> 
> Note that I'm talking only about the uAPI. Internally, ovs can use
> struct ovs_key_nsh that is MD type 1 only, there's no problem changing
> that later. But for the user space interface, this needs to be clean.
> This can be solved for example this way:
> 
> In include/uapi/linux/openvswitch.h:
> 
> struct ovs_key_nsh_base {
> 	__u8 flags;
> 	__u8 mdtype;
> 	__u8 np;
> 	__u8 pad;
> 	__be32 path_hdr;
> };
> 
> + one more netlink attribute carrying MD type 1 info. Will probably
> require to change OVS_KEY_ATTR_NSH to a nested attribute etc.
> 
> In net/openvswitch/flow.h (or perhaps a different header would be more
> appropriate?):
> 
> struct ovs_key_nsh {
> 	struct ovs_key_nsh_base base;
> 	__be32 context[4];
> };
> 
> Plus needed conversions between OVS_KEY_ATTR_NSH and struct ovs_key_nsh
> when interfacing between the kernel and user space.
> 
> That way, we can have MD type 1 support only for now while still being
> allowed to redesign things in whatever way later.
> 
>  Jiri

For the OVS_KEY_ATTR_NSH I agree to move the fixed size MD1 context headers from nsh_base to a separate struct and use nested netlink attributes.

For OVS_ACTION_ATTR_PUSH_NSH attribute any metadata included is opaque to the datapath and should be copied as is into the packet header. I doubt that there is any benefit to model this with nested attributes for MD1 or MD2. This just adds complexity on sender and receiver side and requires updates in case there should be other MD types added later on.

Unless someone can explain to me why the datapath should understand the internal structure/format of metadata in push_nsh, I would strongly vote to keep the metadata as variable length octet sequence in the non-structured OVS_ACTION_ATTR_PUSH_NSH

BR, Jan
