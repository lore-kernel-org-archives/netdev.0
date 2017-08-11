From: "Yang, Yi" <yi.y.yang@intel.com>
Subject: Re: [PATCH net-next v2] openvswitch: enable NSH support
Date: Fri, 11 Aug 2017 17:54:23 +0800
Message-ID: <20170811095422.GA20986@cran64.bj.intel.com>
References: <1502371275-52446-1-git-send-email-yi.y.yang@intel.com>
 <20170811102418.6b1be4f7@griffin>
 <20170811084722.GA19968@cran64.bj.intel.com>
 <20170811111055.482bd42b@griffin>
 <79BBBFE6CB6C9B488C1A45ACD284F51961C427FE@SHSMSX103.ccr.corp.intel.com>
 <20170811114449.745c49c5@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:16875 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751842AbdHKKIs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 11 Aug 2017 06:08:48 -0400
Content-Disposition: inline
In-Reply-To: <20170811114449.745c49c5@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 11, 2017 at 11:44:49AM +0200, Jiri Benc wrote:
> On Fri, 11 Aug 2017 09:24:25 +0000, Yang, Yi Y wrote:
> > So far, we're not clear how we can support MD type 2 better, as I
> > explained before, we need to reuse tun_metadata in struct flow_tnl
> > which is the thing Geneve is using. Geneve predefined 64 keys for
> > this from tun_metadata0 to tun_metadata63, we will reuse it for MD
> > type 2. But you know NSH is not tunnel, so it has to be changed to
> > support both Geneve and NSH. Anyway, they won't be part of
> > ovs_key_nsh.
> 
> Please do not top post.

Sorry for this inconvenience, I'm using outlook. But now I have to use
mutt to address your concern :-)

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

Yeah, good suggestion, will try to do that way.

> 
>  Jiri
