From: "Yang, Yi" <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v4] openvswitch: enable NSH support
Date: Mon, 21 Aug 2017 17:15:42 +0800
Message-ID: <20170821091541.GA75219@cran64.bj.intel.com>
References: <1503041071-68753-1-git-send-email-yi.y.yang@intel.com>
	<20170818152601.3760aaec@griffin>
	<20170821061109.GA72656@cran64.bj.intel.com>
	<20170821101925.3f9b36a1@griffin>
	<20170821083900.GA74649@cran64.bj.intel.com>
	<20170821111854.42dece9f@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "e@erig.me" <e@erig.me>
To: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170821111854.42dece9f@griffin>
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

On Mon, Aug 21, 2017 at 11:18:54AM +0200, Jiri Benc wrote:
> On Mon, 21 Aug 2017 16:39:01 +0800, Yang, Yi wrote:
> > Anyway, we need to keep the code in userspace consistent with the one in
> > kernel as possible as, otherwise it will be a burden for developer, I
> > know userspace has different coding standard from kernel, this will make
> > developer painful if we have two sets of code although they have same
> > functionality.
> 
> I'm sorry, I don't get this. What's wrong with having __u8[] as the
> last member of the struct? That's C99. It's 18 years old standard.
> We're using that throughout our uAPI. Why that should be a problem for
> any user space program?

The issue is it is used union in

struct nsh_hdr {
    ovs_be16 ver_flags_ttl_len;
    uint8_t md_type;
    uint8_t next_proto;
    ovs_16aligned_be32 path_hdr;
    union {
        struct nsh_md1_ctx md1;
        struct nsh_md2_tlv md2;
    };
};

in Linux kernel build, it complained it, I changed it to

struct nsh_hdr {
    ovs_be16 ver_flags_ttl_len;
    uint8_t md_type;
    uint8_t next_proto;
    ovs_16aligned_be32 path_hdr;
    union {
        struct nsh_md1_ctx md1;
        struct nsh_md2_tlv md2[0];
    };
};

It is ok, but for Microsoft compiler, it isn't allowed there is struct
nsh_md2_tlv md2[0] in a union, that is Ben Pfaff's hack :-)

> 
> > > MPLS supports GSO and needs this for segmentation. I don't see anything
> > > GSO related in this patch.
> > > 
> > > How do you plan to address GSO, anyway?
> > 
> > No plan to do that, I'm not an expert on this, we can remove it if
> > you're very sure it is necessary.
> 
> Without GSO, I don't see any use for inner_protocol.
> 
> However, don't you need to software segment the packet if it's GSO
> before pushing the NSH header?
> 
> And wouldn't it be better to implement GSO for NSH, anyway?

I don't know how we can support this, is it a must-have thing?

> 
> > To make sure we make agreement, please confirm if this one is ok?
> > 
> > struct nsh_hdr {
> >     ovs_be16 ver_flags_ttl_len;
> >     uint8_t mdtype;
> >     uint8_t np;
> >     ovs_16aligned_be32 path_hdr;
> >     union {
> >         struct nsh_md1_ctx md1;
> >         struct nsh_md2_tlv md2;
> >     };
> > };
> > 
> > Or it will be better if you can provide your preferred version here.
> 
> I don't really care that much about the names if it's clear what they
> mean. I was merely commenting on the inconsistency which looked weird.
> Whether it's md_type or mdtype, I don't have a preference (does not
> mean others won't, though :-)). Just pick one and stick to it, as far
> as I'm concerned.

But struct nsh_hdr had different struct from struct ovs_key_nsh, we
have no way to make them completely same, do you mean we should use the
same name if they are same fields and represent the same thing?

> 
>  Jiri
