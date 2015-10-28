From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 net-next 0/4] Automatic adjustment of max frame size
Date: Wed, 28 Oct 2015 13:58:20 +0900
Message-ID: <20151028135820.72329de4@samsung9>
References: <1445830859-4651-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	intel-wired-lan@lists.osuosl.org, toshiaki.makita1@gmail.com,
	netdev@vger.kernel.org
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35379 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919AbbJ1E62 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2015 00:58:28 -0400
Received: by pasz6 with SMTP id z6so244337593pas.2
        for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 21:58:27 -0700 (PDT)
In-Reply-To: <1445830859-4651-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 26 Oct 2015 12:40:55 +0900
Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp> wrote:

> This patch set tries to resolve packet drop by oversize error on receiving
> double tagged packets and possibly other encapsulated packets.
> 
> Problem description:
> Currently most NICs have 4 bytes room of receive buffer for vlan header and
> can receive 1522 bytes frame at maximum.
> This is, however, not sufficient once double tagged vlan is used.
> As MEF [1] says, maximum frame size of double tagged packets need to be at
> least 1526 to provide transparent ethernet VPN, and along the same line,
> HW switches send 1526 bytes double tagged packets.
> Thus, double tagged packets are dropped by default in most cases by
> oversize error. NICs need to accept 1526 bytes packets in this situation.
> 
> Approaches:
> To satisfy this requirement, this patch set introduces a way to indicate
> needed extra buffer space to drivers.
> This way can be re-used by other protocols than vlan, like mpls, vxlan, etc.
> 
> Other possible solutions:
> 
> - To adjust mtu automatically when stacked vlan device is created.
>   This is suboptimal because lower device is not necessarily used for only
>   vlan. Sometimes tagged and untagged traffic are both used at the same time.
>   Also, there are devices that already reserve 8 bytes room, in which case mtu
>   adjustment is unnecessary.
> 
> - To reserve more room by default.
>   This is also suboptimal because there are devices that chages behavior
>   when max acceptable frame size gets larger. For exapmle, e1000e enters
>   jumbo frame mode which has some additional ristrictions than normal.
>   Also, this is vlan-specific solution and not reusable by other encapsulation
>   protocols.
> 
> This patch set introduces .ndo_enc_hdr_len() and I chose e1000e as the first
> implementation. Patch 3 makes vlan driver utilize this API and automatically
> expand max frame size of the real device. Patch 4 makes bridge use the API
> in similar way as vlan.
> 
> Challenges:
> - Restore/shrink extra header room after vlan devices are deleted.
>   This will need some additional memory storage.
> - Manual modification of extra buffer size (by iproute2).
> 
> Note:
> - This problem was once discussed in Netdev 0.1 [2].
>   This patch set is based on the conclusion of the discussion.
> 
> Changes:
>  v2: Fixed chackpatch warnings
> 
> [1] https://wiki.mef.net/display/CESG/ENNI+Frame
> [2] https://www.netdev01.org/docs/netdev01_bof_8021ad_makita_150212.pdf
> 
> Toshiaki Makita (4):
>   net: Add ndo_enc_hdr_len to notify extra header room for encapsulated
>     frames
>   e1000e: Add ndo_enc_hdr_len
>   vlan: Notify real device of encap header length
>   bridge: Notify port device of encap header length
> 
>  drivers/net/ethernet/intel/e1000e/netdev.c | 82 ++++++++++++++++++++++--------
>  include/linux/netdevice.h                  |  9 ++++
>  net/8021q/vlan.c                           | 16 +++++-
>  net/8021q/vlan_dev.c                       | 48 +++++++++++++++--
>  net/bridge/br_vlan.c                       | 18 +++++++
>  net/core/dev.c                             | 36 +++++++++++++
>  6 files changed, 180 insertions(+), 29 deletions(-)
> 

The problem is that you require changing network device drivers
and device specific knowledge about what will work or not. Because
of that the modificaton can't be automated.

Also, this effects even more layered devices like tunnels etc.
The problem is quite large, and this patch only begins to address it.

It seems to me that just having the vlan driver to a sane
auto default is the best solution. It might cause a smaller MTU
than ideal, but at least it will still work. Then the user can
manually set a larger MTU if they know their hardware will work.
