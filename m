From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH net] net: br: Fix igmp snooping offload with
 CONFIG_BRIDGE_VLAN_FILTERING
Date: Tue, 3 Oct 2017 12:29:56 +0900
Message-ID: <37af5488-a064-37dc-b1ce-373119ae7b05@lab.ntt.co.jp>
References: <1506992111-25004-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:35801 "EHLO
        tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750708AbdJCEeB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 00:34:01 -0400
In-Reply-To: <1506992111-25004-1-git-send-email-andrew@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017/10/03 9:55, Andrew Lunn wrote:
> With CONFIG_BRIDGE_VLAN_FILTERING enabled, but the feature not enabled
> via /sys/class/net/brX/bridge/vlan_filtering, mdb offloaded to the
> kernel have the wrong VID.
> 
> When an interface is added to the bridge, switchdev is first used to
> notify the hardware that a port has joined a bridge. This is
> immediately followed by the default_pvid, 1, being added to the
> interface via another switchdev call.
> 
> The bridge will then perform IGMP snooping, and offload an mdb entries
> to the switch as needed. With vlan filtering disabled, the vid is left
> as 0. This causes the switch to put the static mdb into the wrong
> vlan, and so frames are not forwarded by the mdb entry.
> 
> If vlan filtering is disable, use the default_pvid, not 0.
> 
> Fixes: f1fecb1d10ec ("bridge: Reflect MDB entries to hardware")
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---
>  net/bridge/br_vlan.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
> index 233a30040c91..aa3589891797 100644
> --- a/net/bridge/br_vlan.c
> +++ b/net/bridge/br_vlan.c
> @@ -492,6 +492,7 @@ bool br_allowed_ingress(const struct net_bridge *br,
>  	 */
>  	if (!br->vlan_enabled) {
>  		BR_INPUT_SKB_CB(skb)->vlan_filtered = false;
> +		*vid = br_get_pvid(vg);
>  		return true;
>  	}
>  

This does not look correct.
This will update fdb with vid which is not 0.
Pvid can be different between each port even when vlan_filtering is
disabled so unicast forwarding (fdb learning) will break.
Also, fdb is visible to userspace so this can break userspace which
expects fdb entries with 0 as well.

Why does the switch driver use pvid while vlan_filtering is disabled?
The (software) bridge does not use pvid for forwarding and use fdb/mdb
entires with vid 0 when vlan_filtering is disabled even if pvid has been
configured.

-- 
Toshiaki Makita
