From: Jan Scheurich <jan.scheurich@ericsson.com>
Subject: RE: [PATCH net-next v2] openvswitch: enable NSH support
Date: Mon, 14 Aug 2017 10:35:42 +0000
Message-ID: <CFF8EF42F1132E4CBE2BF0AB6C21C58D727373EA@ESESSMB107.ericsson.se>
References: <1502371275-52446-1-git-send-email-yi.y.yang@intel.com>
        <20170811102418.6b1be4f7@griffin>
        <20170811084722.GA19968@cran64.bj.intel.com>
        <20170811111055.482bd42b@griffin>
        <79BBBFE6CB6C9B488C1A45ACD284F51961C427FE@SHSMSX103.ccr.corp.intel.com>
        <20170811114449.745c49c5@griffin>
        <CFF8EF42F1132E4CBE2BF0AB6C21C58D7273679A@ESESSMB107.ericsson.se>
        <20170811122256.2cec123e@griffin>
        <CFF8EF42F1132E4CBE2BF0AB6C21C58D72736EAE@ESESSMB107.ericsson.se>
 <20170814095117.056fdf96@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Yang, Yi Y" <yi.y.yang@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "dev@openvswitch.org" <dev@openvswitch.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg23.ericsson.net ([193.180.251.37]:45269 "EHLO
        sesbmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752942AbdHNKg3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 06:36:29 -0400
In-Reply-To: <20170814095117.056fdf96@griffin>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Jiri Benc [mailto:jbenc@redhat.com]
> Sent: Monday, 14 August, 2017 09:51
> 
> On Sun, 13 Aug 2017 21:13:57 +0000, Jan Scheurich wrote:
> > Jiri, I am not too familiar with conventions on the OVS netlink
> > interface regarding the handling of variable length fields. What is
> > the benefit of structuring the push_nsh action into
> >
> > OVS_ACTION_ATTR_PUSH_NSH
> > +-- OVS_ACTION_ATTR_NSH_BASE_HEADER
> > +-- OVS_ACTION_ATTR_NSH_MD
> >
> > instead of grouping the base header fields and the variable length MD
> > into a single monolithic attribute OVS_ACTION_ATTR_PUSH_NSH? Is the
> > main concern a potential future need to add additional parameters to
> > the push_nsh datapath action? Are there examples for such structured
> > actions other than OVS_ACTION_ATTR_CT where the need is obvious
> > because it is very polymorphic?
> 
> This is about having the design clean. What would you do if you had two
> variable length fields? Would you still put them in a single structure
> and have a length field in the structure, too? That would be wrong, we
> have length in the attribute header. I doubt you would do that. Which
> indicates that putting variable length fields to an attribute with
> anything other is wrong.
> 
> Also, look at how ugly the code would be. You'd have to subtract the
> base header length from the attribute length to get the variable data
> length. That's not nice at all.
> 
> Think about the netlink in the way that by default, every field should
> have its own attribute. Structures are included only for performance
> reasons where certain fields are always passed in a message and having
> them in separate attributes would be impractical and waste of space.
> Going out of your way to include the context data in the structure thus
> doesn't make sense.
> 
> > BTW:  The name OVS_ACTION_ATTR_NSH_BASE_HEADER is misleading
> because
> > in the NSH draft the term base header is used for the first 32-bit
> > word, whereas here it includes also the 32-bit Service Path header.
> 
> An excellent comment. This means that it's very well possible that
> future NSH versions may not include SP header or may have it of a
> different size. Maybe we should consider putting it into a separate
> attribute, too? Not sure it is needed, though, I don't think it's
> likely to happen.

I think the NSH RFC draft is pretty clear that the NSH header (Version 0) will always contain the Base Header, the Service Header and a (possibly empty) set of Context Headers. The length of the context headers is implied by the total NSH header Length in the Base Header. The internal structure of the context headers, implied by the "MD type" in the base header, is irrelevant for the push_nsh action as it is managed by the ofproto-dpif layer. The current NSH header format simply does not allow for a second variable length section in the header.

Is it worth to speculate on how a hypothetical future NSH version (with a different Version value in the Base header) might look like? If this should ever arise, we could introduce a new push_nsh_v2 action. 

In summary, I'm still not convinced that we gain any significant generality by splitting up the OVS_ACTION_ATTR_PUSH_NSH action into nested attributes. It will only slow down the execution of the action in the datapath (or requires some optimization in the datapath to merge the attributes into a single internal action struct).

Note: For the OVS_KEY_ATTR_NSH we should split up in to OVS_KEY_ATTR_NSH_FIXED_HEADER (covering Base and Service headers) and OVS_KEY_ATTR_NSH_MD1.

Jan
