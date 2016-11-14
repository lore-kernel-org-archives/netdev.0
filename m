From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] net/phy: add trace events for mdio accesses
Date: Mon, 14 Nov 2016 10:22:50 -0500
Message-ID: <20161114102250.70370625@gandalf.local.home>
References: <20161114110335.27862-1-uwe@kleine-koenig.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Ingo Molnar <mingo@redhat.com>, netdev@vger.kernel.org
To: Uwe =?UTF-8?B?S2xlaW5lLUvDtm5pZw==?= <uwe@kleine-koenig.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0138.hostedemail.com ([216.40.44.138]:35320 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753689AbcKNP2f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 10:28:35 -0500
Received: from smtprelay.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
        by smtpgrave08.hostedemail.com (Postfix) with ESMTP id EAC34211CE6
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2016 15:22:53 +0000 (UTC)
In-Reply-To: <20161114110335.27862-1-uwe@kleine-koenig.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 14 Nov 2016 12:03:35 +0100
Uwe Kleine-König <uwe@kleine-koenig.org> wrote:

> Make it possible to generate trace events for mdio read and write accesses.
> 
> Signed-off-by: Uwe Kleine-König <uwe@kleine-koenig.org>
> ---
>  drivers/net/phy/mdio_bus.c  | 15 +++++++++++++++
>  include/trace/events/mdio.h | 40 ++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 55 insertions(+)
>  create mode 100644 include/trace/events/mdio.h
> 
> diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
> index 09deef4bed09..0f3f207419f6 100644
> --- a/drivers/net/phy/mdio_bus.c
> +++ b/drivers/net/phy/mdio_bus.c
> @@ -38,6 +38,9 @@
>  
>  #include <asm/irq.h>
>  
> +#define CREATE_TRACE_POINTS
> +#include <trace/events/mdio.h>
> +
>  int mdiobus_register_device(struct mdio_device *mdiodev)
>  {
>  	if (mdiodev->bus->mdio_map[mdiodev->addr])
> @@ -461,6 +464,9 @@ int mdiobus_read_nested(struct mii_bus *bus, int addr, u32 regnum)
>  	retval = bus->read(bus, addr, regnum);
>  	mutex_unlock(&bus->mdio_lock);
>  
> +	if (retval >= 0)
> +		trace_mdio_access(bus, 1, addr, regnum, retval);

These cause branches to be taken when tracing is disabled, breaking the
zero overhead for disabled tracing guideline. As retval is passed to
the tracepoint, please look at TRACE_EVENT_CONDITION() and use that.
It will move the if statement into the enabling of the trace event and
keep the overhead to a minimum when the tracepoint is disabled.

Do the same for the below as well.

-- Steve

> +
>  	return retval;
>  }
>  EXPORT_SYMBOL(mdiobus_read_nested);
> @@ -485,6 +491,9 @@ int mdiobus_read(struct mii_bus *bus, int addr, u32 regnum)
>  	retval = bus->read(bus, addr, regnum);
>  	mutex_unlock(&bus->mdio_lock);
>  
> +	if (retval >= 0)
> +		trace_mdio_access(bus, 1, addr, regnum, retval);
> +
>  	return retval;
>  }
>  EXPORT_SYMBOL(mdiobus_read);
> @@ -513,6 +522,9 @@ int mdiobus_write_nested(struct mii_bus *bus, int addr, u32 regnum, u16 val)
>  	err = bus->write(bus, addr, regnum, val);
>  	mutex_unlock(&bus->mdio_lock);
>  
> +	if (!err)
> +		trace_mdio_access(bus, 0, addr, regnum, val);
> +
>  	return err;
>  }
>  EXPORT_SYMBOL(mdiobus_write_nested);
> @@ -538,6 +550,9 @@ int mdiobus_write(struct mii_bus *bus, int addr, u32 regnum, u16 val)
>  	err = bus->write(bus, addr, regnum, val);
>  	mutex_unlock(&bus->mdio_lock);
>  
> +	if (!err)
> +		trace_mdio_access(bus, 0, addr, regnum, val);
> +
>  	return err;
>  }
>  EXPORT_SYMBOL(mdiobus_write);
> diff --git a/include/trace/events/mdio.h b/include/trace/events/mdio.h
> new file mode 100644
> index 000000000000..dcb2d456a346
> --- /dev/null
> +++ b/include/trace/events/mdio.h
> @@ -0,0 +1,40 @@
> +#undef TRACE_SYSTEM
> +#define TRACE_SYSTEM mdio
> +
> +#if !defined(_TRACE_MDIO_H) || defined(TRACE_HEADER_MULTI_READ)
> +#define _TRACE_MDIO_H
> +
> +#include <linux/tracepoint.h>
> +
> +TRACE_EVENT(mdio_access,
> +
> +	TP_PROTO(struct mii_bus *bus, int read,
> +		 unsigned addr, unsigned regnum, u16 val),
> +
> +	TP_ARGS(bus, read, addr, regnum, val),
> +
> +	TP_STRUCT__entry(
> +		__array(char, busid, MII_BUS_ID_SIZE)
> +		__field(int, read)
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
