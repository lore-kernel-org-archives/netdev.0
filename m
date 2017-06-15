From: Krister Johansen <kjlx@templeofstupid.com>
Subject: Re: [PATCH iproute/master 2/3] iptunnel: add support for mpls/ip to
 sit tunnels
Date: Thu, 15 Jun 2017 11:31:18 -0700
Message-ID: <20170615183117.GA2704@templeofstupid.com>
References: <1497058292-10099-1-git-send-email-kjlx@templeofstupid.com>
 <1497058292-10099-3-git-send-email-kjlx@templeofstupid.com>
 <20170614100211.1346dc4e@xeon-e3>
 <20170614171119.GB2368@templeofstupid.com>
 <eed46e61-80d0-4c7e-86c7-dc619b849ad8@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krister Johansen <kjlx@templeofstupid.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org, simon.horman@netronome.com
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sub5.mail.dreamhost.com ([208.113.200.129]:35370 "EHLO
        homiemail-a120.g.dreamhost.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751755AbdFOSbW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 14:31:22 -0400
Received: from homiemail-a120.g.dreamhost.com (localhost [127.0.0.1])
        by homiemail-a120.g.dreamhost.com (Postfix) with ESMTP id 08BFE60001006
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 11:31:17 -0700 (PDT)
Received: from kmjvbox (c-174-62-91-145.hsd1.ca.comcast.net [174.62.91.145])
        (using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
        (No client certificate requested)
        (Authenticated sender: kjlx@templeofstupid.com)
        by homiemail-a120.g.dreamhost.com (Postfix) with ESMTPSA id E397A60001002
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 11:31:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <eed46e61-80d0-4c7e-86c7-dc619b849ad8@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 14, 2017 at 11:16:20AM -0600, David Ahern wrote:
> On 6/14/17 11:11 AM, Krister Johansen wrote:
> > I did try to fix this up as part of bringing this patch up to date,
> > since it was one of the concerns that David raised too.  I believe the
> > problem that I ran into was that IPPROTO_MPLS wasn't defined in all
> > versions of the headers where I tried to include them, and by bringing
> > in in.h, I also managed to get a bunch of errors around re-definition of
> > other symbols.
> > 
> > That said, I don't believe that 137 as the IPPROTO_MPLS value should
> > change anytime soon.  It's defined in RFC 4023.
> > 
> > 	https://tools.ietf.org/html/rfc4023
> > 
> > However, if this is still seems problematic, I can take another shot at
> > attempting to clean this up further.
> 
> IPPROTO_MPLS is defined in include/linux/in.h in iproute2.

Right.  I poked at this some more yesterday afternoon.

The IPPROTO enum in include/linux/in.h is wrapped in an #if
__UAPI_DEF_IN_IPPROTO.  That's defined in include/linux/libc-compat.h.
If _NETINET_IN_H is defined, then __UAPI_DEF_IN_IPPROTO is undefined.
In that case, we pick up the the IPPROTO defs from netinet/in.h.  The
addition of IPPROTO_MPLS to utils.h is to cover the case where we're
using a system netinet/in.h that's older and doesn't yet have an
IPPROTO_MPLS defintion.  There seems to be prescedent for this, since
utils.h also includes IPPROTO_ESP, IPPROTO_AH, and IPPROTO_COMP.

I spent some time trying to remove includes of netinet/in.h from the
code in this patch, however, it's also included by other system headers
that are included throughout iproute2.  I'm not saying removing this is
impossible, but it certainly seems like it's beyond the scope of this
particular patch.

-K
