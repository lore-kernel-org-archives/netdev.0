From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [patch net-next v2 1/2] devlink: add hardware messages tracing
 facility
Date: Tue, 12 Jul 2016 12:38:26 -0400
Message-ID: <20160712123826.15a31a41@gandalf.local.home>
References: <1468339504-27580-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	yotamg@mellanox.com, eladr@mellanox.com, nogahf@mellanox.com,
	ogerlitz@mellanox.com, ivecera@redhat.com, mingo@redhat.com,
	jolsa@kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0242.hostedemail.com ([216.40.44.242]:34617 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750897AbcGLQib (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 12:38:31 -0400
In-Reply-To: <1468339504-27580-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 Jul 2016 18:05:03 +0200
Jiri Pirko <jiri@resnulli.us> wrote:

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Define a tracepoint and allow user to trace messages going to and from
> hardware associated with devlink instance.
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
> v1->v2:
> - Use EXPORT_TRACEPOINT_SYMBOL_GPL instead of a wrapper function
>   as suggested by David Ahern and Steven Rostedt

FYI, you can use the Suggested-by: tag too ;-)

> ---
>  include/trace/events/devlink.h | 68 ++++++++++++++++++++++++++++++++++++++++++
>  net/core/devlink.c             |  4 +++
>  2 files changed, 72 insertions(+)
>  create mode 100644 include/trace/events/devlink.h
> 
> diff --git a/include/trace/events/devlink.h b/include/trace/events/devlink.h
> new file mode 100644
> index 0000000..333c32a
> --- /dev/null
> +++ b/include/trace/events/devlink.h
> @@ -0,0 +1,68 @@
> +#if IS_ENABLED(CONFIG_NET_DEVLINK)
> +
> +#undef TRACE_SYSTEM
> +#define TRACE_SYSTEM devlink
> +
> +#if !defined(_TRACE_DEVLINK_H) || defined(TRACE_HEADER_MULTI_READ)
> +#define _TRACE_DEVLINK_H
> +
> +#include <linux/device.h>
> +#include <net/devlink.h>
> +#include <linux/tracepoint.h>
> +
> +/*
> + * Tracepoint for devlink hardware message:
> + */
> +TRACE_EVENT(devlink_hwmsg,
> +	TP_PROTO(const struct devlink *devlink, bool incoming,
> +		 unsigned long type, const u8 *buf, size_t len),
> +
> +	TP_ARGS(devlink, incoming, type, buf, len),
> +
> +	TP_STRUCT__entry(
> +		__string(bus_name, devlink->dev->bus->name)
> +		__string(dev_name, dev_name(devlink->dev))
> +		__string(owner_name, devlink->dev->driver->owner->name)
> +		__field(bool, incoming)
> +		__field(unsigned long, type)
> +		__dynamic_array(u8, buf, len)
> +		__field(size_t, len)
> +	),
> +
> +	TP_fast_assign(
> +		__assign_str(bus_name, devlink->dev->bus->name);
> +		__assign_str(dev_name, dev_name(devlink->dev));
> +		__assign_str(owner_name, devlink->dev->driver->owner->name);
> +		__entry->incoming = incoming;
> +		__entry->type = type;
> +		memcpy(__get_dynamic_array(buf), buf, len);
> +		__entry->len = len;
> +	),
> +
> +	TP_printk("bus_name=%s dev_name=%s owner_name=%s incoming=%d type=%lu buf=0x[%*phD] len=%lu",
> +		  __get_str(bus_name), __get_str(dev_name),
> +		  __get_str(owner_name), __entry->incoming, __entry->type,
> +		  (int) __entry->len, __get_dynamic_array(buf), __entry->len)
> +);
> +
> +#endif /* _TRACE_DEVLINK_H */
> +
> +/* This part must be outside protection */
> +#include <trace/define_trace.h>
> +
> +#else /* CONFIG_NET_DEVLINK */
> +
> +#if !defined(_TRACE_DEVLINK_H)
> +#define _TRACE_DEVLINK_H

Ah, I guess you do need header protection here.

OK, looks good to me.

Acked-by: Steven Rostedt <rostedt@goodmis.org>

-- Steve

> +
> +#include <net/devlink.h>
> +
> +static inline void trace_devlink_hwmsg(const struct devlink *devlink,
> +				       bool incoming, unsigned long type,
> +				       const u8 *buf, size_t len)
> +{
> +}
> +
> +#endif /* _TRACE_DEVLINK_H */
> +
> +#endif
> diff --git a/net/core/devlink.c b/net/core/devlink.c
> index b2e592a..1b50630 100644
> --- a/net/core/devlink.c
> +++ b/net/core/devlink.c
> @@ -26,6 +26,10 @@
>  #include <net/net_namespace.h>
>  #include <net/sock.h>
>  #include <net/devlink.h>
> +#define CREATE_TRACE_POINTS
> +#include <trace/events/devlink.h>
> +
> +EXPORT_TRACEPOINT_SYMBOL_GPL(devlink_hwmsg);
>  
>  static LIST_HEAD(devlink_list);
>  
