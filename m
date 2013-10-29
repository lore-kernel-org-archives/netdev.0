From: Amos Kong <akong@redhat.com>
Subject: Re: [PATCH] bridge: pass correct vlan id to multicast code
Date: Tue, 29 Oct 2013 10:36:46 +0800
Message-ID: <20131029023646.GA2795@amosk.info>
References: <1382989507-23061-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, shemminger@vyatta.com,
	makita.toshiaki@lab.ntt.co.jp
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1805 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757559Ab3J2ChI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Oct 2013 22:37:08 -0400
Content-Disposition: inline
In-Reply-To: <1382989507-23061-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 28, 2013 at 03:45:07PM -0400, Vlad Yasevich wrote:
> Currently multicast code attempts to extrace the vlan id from
> the skb even when vlan filtering is disabled.  This can lead
> to mdb entries being created with the wrong vlan id.
> Pass the already extracted vlan id to the multicast
> filtering code to make the correct id is used in
> creation as well as lookup.
 
Hi Vlad,

Can we just update br_vlan_get_tag() to set vid to 0 if dev->vlan is
disabled? I guess it would effect br_handle_local_finish().

> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> ---
>  net/bridge/br_device.c    |  2 +-
>  net/bridge/br_input.c     |  2 +-
>  net/bridge/br_multicast.c | 44 +++++++++++++++++++-------------------------
>  net/bridge/br_private.h   |  6 ++++--
>  4 files changed, 25 insertions(+), 29 deletions(-)

...

> diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
> index 8b0b610..686284f 100644
> --- a/net/bridge/br_multicast.c
> +++ b/net/bridge/br_multicast.c
> @@ -947,7 +947,8 @@ void br_multicast_disable_port(struct net_bridge_port *port)
>  
>  static int br_ip4_multicast_igmp3_report(struct net_bridge *br,
>  					 struct net_bridge_port *port,
> -					 struct sk_buff *skb)
> +					 struct sk_buff *skb,
> +					 u16 vid)
>  {
>  	struct igmpv3_report *ih;
>  	struct igmpv3_grec *grec;
> @@ -957,12 +958,10 @@ static int br_ip4_multicast_igmp3_report(struct net_bridge *br,
>  	int type;
>  	int err = 0;
>  	__be32 group;
> -	u16 vid = 0;
>  
>  	if (!pskb_may_pull(skb, sizeof(*ih)))
>  		return -EINVAL;
>  
> -	br_vlan_get_tag(skb, &vid);

After applied the patch, we always use vid in br_dev_xmit()->br_allowed_ingress(),
is it possible that the vlan of bridge is re-enabled when other
changed functions are called?

We can just add a enabled checking before this kind of br_vlan_get_tag()?

if (!br->vlan_enabled)
    br_vlan_get_tag(skb2, &vid);


>  	ih = igmpv3_report_hdr(skb);
>  	num = ntohs(ih->ngrec);
>  	len = sizeof(*ih);

...

-- 
			Amos.
