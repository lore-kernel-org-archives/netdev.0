From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC] bridging: don't forward EAPOL frames
Date: Mon, 26 Nov 2007 09:36:26 -0800
Message-ID: <20071126093626.08c22a9d@freepuppy.rosehill.pdx.hemminger.net>
References: <1195737808.6323.102.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	bridge <bridge@linux-foundation.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:53444 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755469AbXKZRiw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 12:38:52 -0500
In-Reply-To: <1195737808.6323.102.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 22 Nov 2007 14:23:28 +0100
Johannes Berg <johannes@sipsolutions.net> wrote:

> This patch makes the bridging code drop EAPOL frames as recommended by
> 802.1X-2004 in C.3.3.
> 
> Is this really the right place to put it?
> ---
>  include/linux/if_ether.h |    1 +
>  include/net/ieee80211.h  |    6 ------
>  net/bridge/br_input.c    |    3 +++
>  3 files changed, 4 insertions(+), 6 deletions(-)
> 
> --- everything.orig/include/linux/if_ether.h	2007-11-22 11:47:14.178686360 +0100
> +++ everything/include/linux/if_ether.h	2007-11-22 11:48:21.438679036 +0100
> @@ -74,6 +74,7 @@
>  #define ETH_P_ATMFATE	0x8884		/* Frame-based ATM Transport
>  					 * over Ethernet
>  					 */
> +#define ETH_P_PAE	0x888E		/* Port Access Entity (IEEE 802.1X) */
>  #define ETH_P_AOE	0x88A2		/* ATA over Ethernet		*/
>  #define ETH_P_TIPC	0x88CA		/* TIPC 			*/
>  
> --- everything.orig/include/net/ieee80211.h	2007-11-22 11:46:29.908682888 +0100
> +++ everything/include/net/ieee80211.h	2007-11-22 11:48:51.908679037 +0100
> @@ -183,12 +183,6 @@ const char *escape_essid(const char *ess
>  #endif
>  #include <net/iw_handler.h>	/* new driver API */
>  
> -#ifndef ETH_P_PAE
> -#define ETH_P_PAE 0x888E	/* Port Access Entity (IEEE 802.1X) */
> -#endif				/* ETH_P_PAE */
> -
> -#define ETH_P_PREAUTH 0x88C7	/* IEEE 802.11i pre-authentication */
> -
>  #ifndef ETH_P_80211_RAW
>  #define ETH_P_80211_RAW (ETH_P_ECONET + 1)
>  #endif
> --- everything.orig/net/bridge/br_input.c	2007-11-22 11:54:44.798683106 +0100
> +++ everything/net/bridge/br_input.c	2007-11-22 11:57:23.248680285 +0100
> @@ -145,6 +145,9 @@ struct sk_buff *br_handle_frame(struct n
>  		}
>  	}
>  
> +	if (unlikely(skb->protocol = htons(ETH_P_PAE)))
> +		goto drop;
> +
>  	switch (p->state) {
>  	case BR_STATE_FORWARDING:

Not needed because the bridge is already handling it:

1) If running STP (ie true bridge), then all link local multicast is only received by
the bridge and never forwarded.

2) If not running sTP (ie invisible bridge), then it will be forwarded.

Despite what the standards say, many users are using bridging code for invisible
firewalls etc, and in those cases they want STP and EAPOL frames to be forwarded.


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
