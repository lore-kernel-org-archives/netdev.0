From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v2] net/phy: add trace events for mdio accesses
Date: Tue, 22 Nov 2016 09:55:21 -0500
Message-ID: <20161122095521.73d9c746@gandalf.local.home>
References: <20161114110335.27862-1-uwe@kleine-koenig.org>
        <20161122100127.5940-1-uwe@kleine-koenig.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Ingo Molnar <mingo@redhat.com>, netdev@vger.kernel.org
To: Uwe =?UTF-8?B?S2xlaW5lLUvDtm5pZw==?= <uwe@kleine-koenig.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0064.hostedemail.com ([216.40.44.64]:51448 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751288AbcKVOza (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 09:55:30 -0500
In-Reply-To: <20161122100127.5940-1-uwe@kleine-koenig.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 22 Nov 2016 11:01:27 +0100
Uwe Kleine-König <uwe@kleine-koenig.org> wrote:

> diff --git a/include/trace/events/mdio.h b/include/trace/events/mdio.h
> new file mode 100644
> index 000000000000..468e2d095d19
> --- /dev/null
> +++ b/include/trace/events/mdio.h
> @@ -0,0 +1,42 @@
> +#undef TRACE_SYSTEM
> +#define TRACE_SYSTEM mdio
> +
> +#if !defined(_TRACE_MDIO_H) || defined(TRACE_HEADER_MULTI_READ)
> +#define _TRACE_MDIO_H
> +
> +#include <linux/tracepoint.h>
> +
> +TRACE_EVENT_CONDITION(mdio_access,
> +
> +	TP_PROTO(struct mii_bus *bus, int read,
> +		 unsigned addr, unsigned regnum, u16 val, int err),
> +
> +	TP_ARGS(bus, read, addr, regnum, val, err),
> +
> +	TP_CONDITION(err >= 0),
> +
> +	TP_STRUCT__entry(
> +		__array(char, busid, MII_BUS_ID_SIZE)
> +		__field(int, read)

read is just a 0 or 1. What about making it a char? That way we can
pack this better. If I'm not mistaken, MII_BUS_ID_SIZE is (20 - 3) or
17. If read is just one byte, then it can fit in one of those three
bytes, and you save 4 extra bytes (assuming addr will be 4 byte
aligned).

-- Steve


> +		__field(unsigned, addr)
> +		__field(unsigned, regnum)
> +		__field(u16, val)
> +	),
> +
> +	TP_fast_assign(
> +		strncpy(__entry->busid, bus->id, MII_BUS_ID_SIZE);
> +		__entry->read = read;
> +		__entry->addr = addr;
> +		__entry->regnum = regnum;
> +		__entry->val = val;
> +	),
> +
> +	TP_printk("%s %-5s phy:0x%02x reg:0x%02x val:0x%04hx",
> +		  __entry->busid, __entry->read ? "read" : "write",
> +		  __entry->addr, __entry->regnum, __entry->val)
> +);
> +
> +#endif /* if !defined(_TRACE_MDIO_H) || defined(TRACE_HEADER_MULTI_READ) */
> +
> +/* This part must be outside protection */
> +#include <trace/define_trace.h>
