From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] Network Events Connector
Date: Mon, 2 Oct 2006 13:02:22 +0400
Message-ID: <20061002090222.GA32591@2ka.mipt.ru>
References: <m23ba7gscl.fsf@cerbere.dyndns.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:440 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1750719AbWJBJCY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2006 05:02:24 -0400
To: Samir Bellabes <sbellabes@mandriva.com>
Content-Disposition: inline
In-Reply-To: <m23ba7gscl.fsf@cerbere.dyndns.info>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 02, 2006 at 08:11:06AM +0200, Samir Bellabes (sbellabes@mandriva.com) wrote:
> 
> This patch adds a connector which reports networking's events to
> userspace. It's sending events when a sock has its sk_state changed to :
>   - LISTEN or CLOSE for DCCP and TCP
>   - BIND or CLOSE for UDP.
> 
> With this notification, a userspace tool can ask the user if he want to
> let the local firewall open for the corresponding sport or not, and if
> so open the firewall for the application which get the corresponding sport.
> 
> For people behind a firewall (non-running in the user box) we can have a
> authentification between the user box, which have set the port to state
> TCP_LISTEN for example, and the firewall, in a such way that the
> firewall's router will forward incoming packet for this port to the user
> box.
> 
> It will avoid adding specific rules to the user's firewall-script, and
> let the firewall be more interactive for users.
> 
> Signed-off-by: Samir Bellabes <sbellabes@mandriva.com>

Interesting... Mybe it even prints the name of the application which is
trying to change port state?

I have couple of comments about structures you use, otherwise it looks
good, although I do not know if it is ok or not ok to include it into
mainline tree.
>From one point of view it is small and interesting piece of code, from other
point it is not clear if such functionality is needed...

Btw, you could also create netlink/connector based firewall rules
update, I think people with hundreds of rules in one table will bless
you after that.

> +#ifndef CN_NET_H
> +#define CN_NET_H
> +
> +#include <linux/time.h>
> +#include <linux/ipv6.h>
> +
> +/*
> + * Userspace sends this enum to register with the kernel that it is listening
> + * for events on the connector.
> + */
> +enum cn_net_status {
> +	CN_NET_LISTEN = 1,
> +	CN_NET_IGNORE = 2
> +};
> +
> +struct net_event {
> +	enum event {
> +		NET_EVENT_NONE		= 0x00000000,
> +		NET_EVENT_TCP_LISTEN	= 0x00000001,
> +		NET_EVENT_TCP_CLOSE	= 0x00000002,
> +		NET_EVENT_UDP_BIND	= 0x00000004,
> +		NET_EVENT_UDP_CLOSE	= 0x00000008,
> +		NET_EVENT_DCCP_LISTEN	= 0x00000010,
> +		NET_EVENT_DCCP_CLOSE	= 0x00000020,
> +		NET_EVENT_MAX		= 0x80000000
> +	} event;
> +	struct timespec timestamp;

Doesn't this monster have different size in 64 and 32 bit environments?

> +	union {
> +		struct {
> +			__u32 err;
> +		} ack;
> +		
> +		struct {
> +			unsigned int family;
> +			union {
> +				struct in6_addr ipv6;
> +				unsigned long ipv4;

Please no longs in code which is supposed to be used simultaneously in
32 and 64 bit environments.

> +			} saddr;
> +			unsigned int sport;
> +		} data;
> +	} net_event_data;
> +};

-- 
	Evgeniy Polyakov
