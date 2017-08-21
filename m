From: "Yang, Yi" <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v4] openvswitch: enable NSH support
Date: Mon, 21 Aug 2017 19:11:07 +0800
Message-ID: <20170821111106.GA76963@cran64.bj.intel.com>
References: <1503041071-68753-1-git-send-email-yi.y.yang@intel.com>
	<20170818152601.3760aaec@griffin>
	<20170821061109.GA72656@cran64.bj.intel.com>
	<20170821101925.3f9b36a1@griffin>
	<20170821083900.GA74649@cran64.bj.intel.com>
	<20170821111854.42dece9f@griffin>
	<20170821091541.GA75219@cran64.bj.intel.com>
	<20170821114713.7c6ebb9a@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "e@erig.me" <e@erig.me>
To: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170821114713.7c6ebb9a@griffin>
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

On Mon, Aug 21, 2017 at 05:47:13PM +0800, Jiri Benc wrote:
> On Mon, 21 Aug 2017 17:15:42 +0800, Yang, Yi wrote:
> > The issue is it is used union in
> > 
> > struct nsh_hdr {
> >     ovs_be16 ver_flags_ttl_len;
> >     uint8_t md_type;
> >     uint8_t next_proto;
> >     ovs_16aligned_be32 path_hdr;
> >     union {
> >         struct nsh_md1_ctx md1;
> >         struct nsh_md2_tlv md2;
> >     };
> > };
> 
> This should work (modulo the non-kernel type names, of course). Did you
> mean to put [] after md2?

Yes, the original version has [] after md2.

> 
> > in Linux kernel build, it complained it, I changed it to
> 
> What was the error message?

./include/net/nsh.h:213:25: error: flexible array member in union
      struct nsh_md2_tlv md2[];
                         ^

> 
> > struct nsh_hdr {
> >     ovs_be16 ver_flags_ttl_len;
> >     uint8_t md_type;
> >     uint8_t next_proto;
> >     ovs_16aligned_be32 path_hdr;
> >     union {
> >         struct nsh_md1_ctx md1;
> >         struct nsh_md2_tlv md2[0];
> >     };
> > };
> 
> I wouldn't use this. First, zero length array is a GCC extension. It
> would indeed be better not to use that in uAPI. Second, I wouldn't even
> use a flexible array member here, see my reply to Jan for the reasons.
> 
> Note that I commented on struct nsh_md2_tlv having __u8[] as the last
> member which IMHO makes good sense. I'm not entirely sure what C99 says
> about flexible array member being part of a struct inside union inside
> a struct, though. GCC seems to cope with that just fine but AFAIK it
> has some extension over the C standard wrt. flexible array members.

Yes, if struct nsh_md2_tlv has  __u8[] as last field, 

struct nsh_md2_tlv {
        __be16 md_class;
        u8 type;
        u8 length;
        u8 md_value[];
};

struct nsh_hdr {
        __be16 ver_flags_ttl_len;
        u8 md_type;
        u8 next_proto;
        __be32 path_hdr;
        union {
            struct nsh_md1_ctx md1;
            struct nsh_md2_tlv md2;
        };
};

it is ok, so let us use this one.

> 
> > I don't know how we can support this, is it a must-have thing?
> 
> What would happen if you get a GSO packet? Ports of an ovs bridge claim
> GSO support, thus they may get a GSO packet. You have to handle it one
> way or the other: either software segment the packet before pushing the
> header, or implement proper GSO support for NSH.

This is an issue, I'll investigate it and find a way to handle this.

> 
> > But struct nsh_hdr had different struct from struct ovs_key_nsh, we
> > have no way to make them completely same, do you mean we should use the
> > same name if they are same fields and represent the same thing?
> 
> Yes.
> 
> Thanks,
> 
>  Jiri
