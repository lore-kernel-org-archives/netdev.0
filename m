From: "Yang, Yi" <yi.y.yang@intel.com>
Subject: Re: [PATCH v3] openvswitch: enable NSH support
Date: Thu, 17 Aug 2017 07:37:04 +0800
Message-ID: <20170816233703.GA123125@cran64.bj.intel.com>
References: <1502861730-76203-1-git-send-email-yi.y.yang@intel.com>
 <20170816111921.7a039be5@griffin>
 <20170816093129.GA112234@cran64.bj.intel.com>
 <20170816160322.6a0def09@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dev@openvswitch.org, e@erig.me
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:20605 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752358AbdHPXvg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 16 Aug 2017 19:51:36 -0400
Content-Disposition: inline
In-Reply-To: <20170816160322.6a0def09@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 16, 2017 at 10:03:22PM +0800, Jiri Benc wrote:
> On Wed, 16 Aug 2017 17:31:30 +0800, Yang, Yi wrote:
> > On Wed, Aug 16, 2017 at 11:19:21AM +0200, Jiri Benc wrote:
> > > > --- a/include/uapi/linux/openvswitch.h
> > > > +++ b/include/uapi/linux/openvswitch.h
> > > [...]
> > > > +#define NSH_MD1_CONTEXT_SIZE 4
> > > 
> > > Please move this to nsh.h and use it there, too, instead of the open
> > > coded 4.
> > 
> > ovs code is very ugly, it will convert array[4] in
> > datapath/linux/compat/include/linux/openvswitch.h to other struct, I
> > have to change context[4] to such format :-), we can use 4 here for
> > Linux kernel.
> 
> Oh, right, this is uAPI and nsh.h is kernel internal. My suggestion was
> nonsense, let's keep it as it was in your patch.
> 
> > > > +	case OVS_KEY_ATTR_NSH: {
> > > > +		struct ovs_key_nsh nsh;
> > > > +		struct ovs_key_nsh nsh_mask;
> > > > +		size_t size = nla_len(a) / 2;
> > > > +		struct nlattr attr[1 + DIV_ROUND_UP(sizeof(struct ovs_key_ipv6)
> > > > +						    , sizeof(struct nlattr))];
> > > > +		struct nlattr mask[1 + DIV_ROUND_UP(sizeof(struct ovs_key_ipv6)
> > > > +						    , sizeof(struct nlattr))];
> > > > +
> > > > +		attr->nla_type = nla_type(a);
> > > > +		mask->nla_type = attr->nla_type;
> > > > +		attr->nla_len = NLA_HDRLEN + size;
> > > > +		mask->nla_len = attr->nla_len;
> > > > +		memcpy(attr + 1, (char *)(a + 1), size);
> > > > +		memcpy(mask + 1, (char *)(a + 1) + size, size);
> > > 
> > > This is too hacky. Please find a better way to handle this.
> > > 
> > > One option is to create a struct with struct nlattr as the first member
> > > followed by a char buffer. Still not nice but at least it's clear
> > > what's the intent.
> > 
> > The issue is nested attributes only can use this way, nested attribute
> > for SET_MASKED is very special, we have to handle it specially.
> 
> I'm not sure you understood what I meant. Let me explain in code:
> 
> 	struct {
> 		struct nlattr attr;
> 		struct ovs_key_ipv6 data;
> 	} attr, mask;
> 
> 	attr->attr.nla_type = nla_type(a);
> 	attr->attr.nl_len = NLA_HDRLEN + size;
> 	memcpy(&attr->data, a + 1, size);
> 
> It's much less hacky and doing the same thing.
> 
> I'm not sure we don't need verification of size not overflowing the
> available buffer. Is it checked beforehand elsewhere?
> 
> I also spotted one more bug: the 'mask' variable is not used anywhere.
> The second call of nsh_key_from_nlattr should use mask, not attr.
>

I have verified it in my real sfc test environment, but it is indeed
a bug, because mask and attr are same, so the result is still attr.

But here attr and mask shoud be of "struct nlattr attr", I'll polish it.
 
> > > > +	key->nsh.path_hdr = nsh->path_hdr;
> > > > +	switch (key->nsh.mdtype) {
> > > > +	case NSH_M_TYPE1:
> > > > +		if ((length << 2) != NSH_M_TYPE1_LEN)
> > > 
> > > Why length << 2?
> > 
> > len in NSH header is number of 4 octets, so need to multiply 4.
> 
> Should nsh_get_len take care of that, then?
> 

There are two helpers for this, nsh_hdr_len gets actual length,
nsh_get_len gets "len" field in nsh header.

> Thanks,
> 
>  Jiri
