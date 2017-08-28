From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] bridge: fdb add and delete tracepoints
Date: Sun, 27 Aug 2017 19:11:26 -0700
Message-ID: <592631a3-6a80-407a-f087-37f7f04417d2@gmail.com>
References: <1503869593-30165-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com,
        bridge@lists.linux-foundation.org, Andrew Lunn <andrew@lunn.ch>
To: Roopa Prabhu <roopa@cumulusnetworks.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:37202 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751701AbdH1CLa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Aug 2017 22:11:30 -0400
Received: by mail-oi0-f67.google.com with SMTP id b184so4416321oih.4
        for <netdev@vger.kernel.org>; Sun, 27 Aug 2017 19:11:30 -0700 (PDT)
In-Reply-To: <1503869593-30165-1-git-send-email-roopa@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/27/2017 02:33 PM, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> Tracepoints to trace bridge forwarding database updates.

Thanks for adding this!

> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
>  include/trace/events/bridge.h | 98 +++++++++++++++++++++++++++++++++++++++++++
>  net/bridge/br_fdb.c           |  7 ++++
>  net/core/net-traces.c         |  6 +++
>  3 files changed, 111 insertions(+)
>  create mode 100644 include/trace/events/bridge.h
> 
> diff --git a/include/trace/events/bridge.h b/include/trace/events/bridge.h
> new file mode 100644
> index 0000000..e2d52cf
> --- /dev/null
> +++ b/include/trace/events/bridge.h
> @@ -0,0 +1,98 @@
> +#undef TRACE_SYSTEM
> +#define TRACE_SYSTEM bridge
> +
> +#if !defined(_TRACE_BRIDGE_H) || defined(TRACE_HEADER_MULTI_READ)
> +#define _TRACE_BRIDGE_H
> +
> +#include <linux/netdevice.h>
> +#include <linux/tracepoint.h>
> +
> +#include "../../../net/bridge/br_private.h"
> +
> +TRACE_EVENT(br_fdb_add,
> +
> +	TP_PROTO(struct ndmsg *ndm, struct net_device *dev,
> +		 const unsigned char *addr, u16 vid, u16 nlh_flags),
> +
> +	TP_ARGS(ndm, dev, addr, vid, nlh_flags),
> +
> +	TP_STRUCT__entry(
> +		__field(u8, ndm_flags)
> +		__string(dev, dev->name)
> +		__array(unsigned char, addr, 6)

Can you use ETH_ALEN instead of 6 here?

> +		__field(u16, vid)
> +		__field(u16, nlh_flags)
> +	),
> +
> +	TP_fast_assign(
> +		__assign_str(dev, dev->name);
> +		memcpy(__entry->addr, addr, 6);

Likewise

> +		__entry->vid = vid;
> +		__entry->nlh_flags = nlh_flags;
> +		__entry->ndm_flags = ndm->ndm_flags;
> +	),
> +
> +	TP_printk("dev %s addr %02x:%02x:%02x:%02x:%02x:%02x vid %u nlh_flags %x ndm_flags = %x",

I wonder if we could make %pM work for TP_printk() as this would
simplify the argument list a bitt. Can you use %04x for vid, nlh_flags
and %02x for ndm_flags?

> +		  __get_str(dev), __entry->addr[0], __entry->addr[1],
> +		  __entry->addr[2], __entry->addr[3], __entry->addr[4],
> +		  __entry->addr[5], __entry->vid,
> +		  __entry->nlh_flags, __entry->ndm_flags)
> +);
> +
> +TRACE_EVENT(br_fdb_external_learn_add,
> +
> +	TP_PROTO(struct net_bridge *br, struct net_bridge_port *p,
> +		 const unsigned char *addr, u16 vid),
> +
> +	TP_ARGS(br, p, addr, vid),
> +
> +	TP_STRUCT__entry(
> +		__string(br_dev, br->dev->name)
> +		__string(dev, p->dev->name)
> +		__array(unsigned char, addr, 6)
> +		__field(u16, vid)
> +	),
> +
> +	TP_fast_assign(
> +		__assign_str(br_dev, br ? br->dev->name : "null");
> +		__assign_str(dev, p ? p->dev->name : "null");
> +		memcpy(__entry->addr, addr, 6);
> +		__entry->vid = vid;
> +	),
> +
> +	TP_printk("br_dev %s port %s addr %02x:%02x:%02x:%02x:%02x:%02x vid %u",
> +		  __get_str(br_dev), __get_str(dev), __entry->addr[0],
> +		  __entry->addr[1], __entry->addr[2], __entry->addr[3],
> +		  __entry->addr[4], __entry->addr[5], __entry->vid)
> +);
> +
> +TRACE_EVENT(fdb_delete,
> +
> +	TP_PROTO(struct net_bridge *br, struct net_bridge_fdb_entry *f),
> +
> +	TP_ARGS(br, f),
> +
> +	TP_STRUCT__entry(
> +		__string(br_dev, br->dev->name)
> +		__string(dev, f->dst ? f->dst->dev->name : "null")
> +		__array(unsigned char, addr, 6)

Same here, using ETH_ALEN would be clearer.

> +		__field(u16, vid)
> +	),
> +

Thanks!
-- 
Florian
