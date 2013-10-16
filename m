From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 net 2/4] bridge: Apply the PVID to priority-tagged
 frames
Date: Wed, 16 Oct 2013 08:55:37 -0700
Message-ID: <20131016085537.1cbe9c37@nehalam.linuxnetplumber.net>
References: <1381910836-718-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	<1381910836-718-3-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org,
	Toshiaki Makita <toshiaki.makita1@gmail.com>
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:33270 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753873Ab3JPPzl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 11:55:41 -0400
Received: by mail-pb0-f42.google.com with SMTP id un15so1008114pbc.1
        for <netdev@vger.kernel.org>; Wed, 16 Oct 2013 08:55:41 -0700 (PDT)
In-Reply-To: <1381910836-718-3-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Oct 2013 17:07:14 +0900
Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp> wrote:

> IEEE 802.1Q says that when we receive priority-tagged (VID 0) frames
> use the PVID for the port as its VID.
> (See IEEE 802.1Q-2011 6.9.1 and Table 9-2)
> 
> Apply the PVID to not only untagged frames but also priority-tagged frames.
> 
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> ---
>  net/bridge/br_vlan.c | 27 ++++++++++++++++++++-------
>  1 file changed, 20 insertions(+), 7 deletions(-)
> 
> diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
> index 21b6d21..5a9c44a 100644
> --- a/net/bridge/br_vlan.c
> +++ b/net/bridge/br_vlan.c
> @@ -189,6 +189,8 @@ out:
>  bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
>  			struct sk_buff *skb, u16 *vid)
>  {
> +	int err;
> +
>  	/* If VLAN filtering is disabled on the bridge, all packets are
>  	 * permitted.
>  	 */
> @@ -201,20 +203,31 @@ bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
>  	if (!v)
>  		return false;
>  
> -	if (br_vlan_get_tag(skb, vid)) {
> +	err = br_vlan_get_tag(skb, vid);
> +	if (!*vid) {
>  		u16 pvid = br_get_pvid(v);

Ok, but it looks like br_vlan_get_tag() could be cleaner if it just returned
the tag, and there was another br_vlan_tag_present() function.

Also, does this still work if CONFIG_BRIDGE_VLAN_FILTERING is disabled?
