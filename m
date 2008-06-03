From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: PATCH: fix bridged 802.3ad bonding
Date: Tue, 3 Jun 2008 09:46:04 -0700
Message-ID: <20080603094604.6a7dfe7d@extreme>
References: <20080603132106.GA3256@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54235 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751728AbYFCQra (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 12:47:30 -0400
In-Reply-To: <20080603132106.GA3256@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 3 Jun 2008 15:21:06 +0200
Jiri Bohac <jbohac@suse.cz> wrote:

> Hi,
> 
> Bonding in 802.3ad mode breaks when the bond interface is added
> to a bridge (which makes 802.3ad unusable in XEN, for example).
> 
> The problem is that br_pass_frame_up() will change the skb's dev
> pointer to point to the bridge interface. As a result, the LACP
> packets will not reach the bond_3ad_lacpdu_recv() protocol
> handler registered on the bonding device. Even if they did, the
> handler won't work with the changed skb->dev.
> 
> The following patch fixes the problem.
> 
> Signed-off-by: Jiri Bohac <jbohac@suse.cz>

Agree with Patrick, it might be a real problem but your solution
is doing it in the wrong place. The packets do arrive on the bridge
interface which is an aggregation of all the interfaces in the bridge.

The LACPDU's are received via now on the bond device. If you moved
the packet type handler down to the physical interface, this problem
would go away because the packets would be handled to bond_3ad_lacpdu_recv
prior to being handled by the bridge.  You would still have to handle
cases where bonding device was inactive, but that shouldn't be hard.
