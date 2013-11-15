From: Ben Pfaff <blp@nicira.com>
Subject: Re: [PATCH v2.50 2/6] ofp-actions: Account for OF version when
 enforcing action consistency
Date: Fri, 15 Nov 2013 14:34:14 -0800
Message-ID: <20131115223414.GC32463@nicira.com>
References: <1384506623-18503-1-git-send-email-horms@verge.net.au>
 <1384506623-18503-3-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dev@openvswitch.org, netdev@vger.kernel.org,
	Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Ravi K <rkerur@gmail.com>, Joe Stringer <joe@wand.net.nz>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog101.obsmtp.com ([74.125.149.67]:57239 "HELO
	na3sys009aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751888Ab3KOWeU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Nov 2013 17:34:20 -0500
Received: by mail-qe0-f50.google.com with SMTP id 1so2645449qee.23
        for <netdev@vger.kernel.org>; Fri, 15 Nov 2013 14:34:19 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1384506623-18503-3-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 15, 2013 at 06:10:19PM +0900, Simon Horman wrote:
> The aim of this patch is to provide infrastructure to differentiate
> between OpenFlow1.1 - 1.2 and OpenFlow1.3+ consistency checking. It
> also provides enhanced OpenFlow1.0 consistency checking.
> 
> Some different versions of OpenFlow require different consistency
> checking.
> 
> 1. OpenFlow1.0
> 
>    This variant implicitly pushes a VLAN tag if one doesn't exist
>    and an action to modify a VLAN tag is encountered.
> 
>    MPLS push is supported as a Nicira extension whose behaviour is
>    the same as OpenFlow1.1 - 1.2.
> 
>    In practice Open vSwitch allows inconsistent OpenFlow 1.0 actions so
>    this portion of the change is just for completeness. I do not believe it
>    has any run-time affect. And I would not be opposed to folding this case
>    into the handling of OpenFlow1.1 - 1.2.
> 
> 2. OpenFlow1.1 - 1.2
> 
>    This does not have the implicit VLAN tag push behaviour of OpenFlow1.0.
> 
>    An MPLS push action pushes an MPLS LSE after any VLAN tags that are
>    present. This is pre-OpenFlow1.3 tag ordering.
> 
> 3. OpenFlow1.3+
> 
>    This does not have the implicit VLAN tag push behaviour of OpenFlow1.0.
> 
>    An MPLS push action pushes an MPLS LSE before any VLAN tags that are
>    present. This is OpenFlow1.3+ tag ordering. Its implication
>    is that after an MPLS push action a packet is no longer a VLAN
>    packet as there are no longer any VLAN tags immediately after
>    the ethernet header: there is now an MPLS LSE there.
> 
>    Currently Open vSwitch does not implement OpenFlow1.3+ tag ordering
>    so this patch uses the same consistency checking for OpenFlow1.3+
>    as for OpenFlow1.1 - 1.2.
> 
>    A subsequent patch, which implements OpenFlow1.3+ tag ordering,
>    makes use of the infrastructure provided by this patch to check
>    actions accordingly.
> 
> Unfortunately ofpact_get_SET_VLAN_VID(a)->push_vlan_if_needed and similar
> devices can't be used in order to implement logic as they are not set when
> when ofpact_check__() is called via parse_ofp_str().
> 
> Instead this patch takes the approach of adding an OpenFlow version
> parameter to ofpact_check__().
> 
> A new function ofpact_check_usable_protocols() allows trimming the
> usable_protocols based on action checking.
> 
> The net effect of this change on run-time is only to increase logging under
> some circumstances as ofpacts_check() may now be called up to four times
> instead of up to twice for each invocation of parse_ofp_str__()
> 
> Signed-off-by: Simon Horman <horms@verge.net.au>

I think I have a better way.  I posted patches:
        http://openvswitch.org/pipermail/dev/2013-November/033968.html
        http://openvswitch.org/pipermail/dev/2013-November/033967.html
