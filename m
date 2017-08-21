From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v4] openvswitch: enable NSH support
Date: Mon, 21 Aug 2017 11:47:13 +0200
Message-ID: <20170821114713.7c6ebb9a@griffin>
References: <1503041071-68753-1-git-send-email-yi.y.yang@intel.com>
        <20170818152601.3760aaec@griffin>
        <20170821061109.GA72656@cran64.bj.intel.com>
        <20170821101925.3f9b36a1@griffin>
        <20170821083900.GA74649@cran64.bj.intel.com>
        <20170821111854.42dece9f@griffin>
        <20170821091541.GA75219@cran64.bj.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "dev@openvswitch.org" <dev@openvswitch.org>,
        "blp@ovn.org" <blp@ovn.org>, "e@erig.me" <e@erig.me>,
        "jan.scheurich@ericsson.com" <jan.scheurich@ericsson.com>
To: "Yang, Yi" <yi.y.yang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57942 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751814AbdHUJrR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 05:47:17 -0400
In-Reply-To: <20170821091541.GA75219@cran64.bj.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 21 Aug 2017 17:15:42 +0800, Yang, Yi wrote:
> The issue is it is used union in
> 
> struct nsh_hdr {
>     ovs_be16 ver_flags_ttl_len;
>     uint8_t md_type;
>     uint8_t next_proto;
>     ovs_16aligned_be32 path_hdr;
>     union {
>         struct nsh_md1_ctx md1;
>         struct nsh_md2_tlv md2;
>     };
> };

This should work (modulo the non-kernel type names, of course). Did you
mean to put [] after md2?

> in Linux kernel build, it complained it, I changed it to

What was the error message?

> struct nsh_hdr {
>     ovs_be16 ver_flags_ttl_len;
>     uint8_t md_type;
>     uint8_t next_proto;
>     ovs_16aligned_be32 path_hdr;
>     union {
>         struct nsh_md1_ctx md1;
>         struct nsh_md2_tlv md2[0];
>     };
> };

I wouldn't use this. First, zero length array is a GCC extension. It
would indeed be better not to use that in uAPI. Second, I wouldn't even
use a flexible array member here, see my reply to Jan for the reasons.

Note that I commented on struct nsh_md2_tlv having __u8[] as the last
member which IMHO makes good sense. I'm not entirely sure what C99 says
about flexible array member being part of a struct inside union inside
a struct, though. GCC seems to cope with that just fine but AFAIK it
has some extension over the C standard wrt. flexible array members.

> I don't know how we can support this, is it a must-have thing?

What would happen if you get a GSO packet? Ports of an ovs bridge claim
GSO support, thus they may get a GSO packet. You have to handle it one
way or the other: either software segment the packet before pushing the
header, or implement proper GSO support for NSH.

> But struct nsh_hdr had different struct from struct ovs_key_nsh, we
> have no way to make them completely same, do you mean we should use the
> same name if they are same fields and represent the same thing?

Yes.

Thanks,

 Jiri
