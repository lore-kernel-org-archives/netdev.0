From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][IPSEC] inter address family IPsec tunnel on the fly
Date: Wed, 05 Mar 2008 13:40:20 -0800 (PST)
Message-ID: <20080305.134020.05696990.davem@davemloft.net>
References: <20080305213727.35f46f2f.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org
To: kazunori@miyazawa.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54946
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762305AbYCEVkX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 16:40:23 -0500
In-Reply-To: <20080305213727.35f46f2f.kazunori@miyazawa.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Date: Wed, 5 Mar 2008 21:37:27 +0900

> Hello David,

Hello,

> This patch fix inter address family ipsec tunneling
> when we install IPsec SA via PF_KEY interface
> because there are no interface to set the selector.
> 
> This patch is for net-2.6
> 
> Signed-off-by: Kazunori MIYAZAWA <miyazawa@linux-ipv6.org>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

It seems quite excessive to grab and release the module reference
count during every packet input/output which happens through IPSEC
tunnels.

The whole reason we store the mode information in the state is so that
we only have to grab the reference during IPSEC rule addition, instead
of during packet processing.

Having to export xfrm_mode_{get,put} from xfrm_state.c is a sure
sign of trouble :-)

Is there some way we can simply propagate the correct setting to
x->inner_mode?

I also wonder if the PF_KEY limitation really exists.  For example we
will set x->sel.family etc. from the SADB_EXT_ADDRESS_PROXY attribute
if present.

Finally, if the determination can be made in the data path, it
by definition could be made during rule insertion which is much
more efficient and appropriate.
