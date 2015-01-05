From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [CPSW driver] broadcast ethernet pkg will be dropped?
Date: Mon, 5 Jan 2015 23:56:51 +0530
Message-ID: <54AAD76B.6030508@ti.com>
References: <20141229013606.GR970@techyauld.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Lokesh Vutla <lokeshvutla@ti.com>
To: Zheng Yi <yzheng@techyauld.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:43429 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753364AbbAES1H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jan 2015 13:27:07 -0500
In-Reply-To: <20141229013606.GR970@techyauld.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 29 December 2014 07:06 AM, Zheng Yi wrote:
> Hi Sir
> 
>    I found your mail address from Linux kernel git repo. I think there
>    is a problem in CPSW driver. If it is not your duty to maintain
>    those code, could you please tell me the ones who are in charge of
>    it?
> 
>    I found that when a AM3352 board boot, I use a laptop to send ARP
>    request to it, the board do not reponse. Even ifconfig do not show
>    that there is any pkg sent to the CPSW device. I'm sure that the
>    ARP request PKG received by SoC(confirmed by my oscilloscope).

Can you check the hardware statistics counters in CPSW also?

> 
>    After reading the SoC doc (Tech ref manual) and reading the driver code, i found that:
>    15.3.2.7 Address Lookup Engine (ALE)
>    "Broadcast packets will be dropped unless the broadcast address is entered into the table with the super bit set."
> 
>    and in driver: drivers/net/ether/ti/cpsw_ale.c
> 
>    int cpsw_ale_add_mcast(struct cpsw_ale *ale, u8 *addr, int port_mask,
>                           int flags, u16 vid, int mcast_state)
>    {
>           /* ....... */
> 
>           cpsw_ale_set_super(ale_entry, (flags & ALE_BLOCKED) ? 1 : 0);
> 
>           /* ....... */
>    }
> 
>    I have searched all of the calling of that function, and found no
>    ALE_BLOCKED flag was set.  Especially, in
>    cpsw_add_dual_emac_def_ale_entries(), only ALE_VLAN was provided
>    for the broadcast address.
> 
>    After change the flag(brutally), my board can response to the ARP broadcast requests correctly.
> 
>    Here are some questions I do not found the answer:
>    1. the macro ALE_BLOCKED seems be used uncorrectly.
>       If one want the pkg should be "blocked", the "super" bit should be cleared, not be set.
>       So, in cpsw_ale_add_mcast(), we should do like this:
>           cpsw_ale_set_super(ale_entry, (flags & ALE_BLOCKED) ? 0 : 1);

When Super Bit is set, the packet will never be dropped by any ALE rules
or rate limit. It is made sure that the packet will reach cpu port
irrespective of any rules in the switch. So this is not the correct fix,
need to root cause a bit more.

> 
>       Do you think the current logic is reversed?
> 
>    2. broadcast ethernet pkg from "FF:FF:FF:FF:FF:FF" should be alowed.
>       If by default, it desiged to be filtered out, why not add an interface to support
>       restore it? I do not found any code that can change filtering the broadcast pkg in runtime.

broadcast is not filtered out, it is always allowed to CPU port in CPSW
driver. Can you dump ALE table entry and check whether something else is
not correct in your setup.

Regards
Mugunthan V N
