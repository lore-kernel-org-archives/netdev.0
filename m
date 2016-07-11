From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 1/2] devlink: add hardware messages tracing
 facility
Date: Mon, 11 Jul 2016 20:38:09 +0200
Message-ID: <20160711183809.GA1876@nanopsycho.orion>
References: <1468243128-6669-1-git-send-email-jiri@resnulli.us>
 <20160711120814.504c20cb@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	yotamg@mellanox.com, eladr@mellanox.com, nogahf@mellanox.com,
	ogerlitz@mellanox.com, ivecera@redhat.com, mingo@redhat.com,
	jolsa@kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:32963 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752316AbcGKSiN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 14:38:13 -0400
Received: by mail-wm0-f68.google.com with SMTP id o80so5157412wme.0
        for <netdev@vger.kernel.org>; Mon, 11 Jul 2016 11:38:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160711120814.504c20cb@gandalf.local.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jul 11, 2016 at 06:08:14PM CEST, rostedt@goodmis.org wrote:
>On Mon, 11 Jul 2016 15:18:47 +0200
>Jiri Pirko <jiri@resnulli.us> wrote:
>
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> Define a tracepoint and allow user to trace messages going to and from
>> hardware associated with devlink instance.
>> 
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> ---
>>  include/net/devlink.h          |  8 +++++++
>>  include/trace/events/devlink.h | 49 ++++++++++++++++++++++++++++++++++++++++++
>>  net/core/devlink.c             |  9 ++++++++
>>  3 files changed, 66 insertions(+)
>>  create mode 100644 include/trace/events/devlink.h
>> 
>> diff --git a/include/net/devlink.h b/include/net/devlink.h
>> index c99ffe8..865ade6 100644
>> --- a/include/net/devlink.h
>> +++ b/include/net/devlink.h
>> @@ -115,6 +115,8 @@ struct devlink *devlink_alloc(const struct devlink_ops *ops, size_t priv_size);
>>  int devlink_register(struct devlink *devlink, struct device *dev);
>>  void devlink_unregister(struct devlink *devlink);
>>  void devlink_free(struct devlink *devlink);
>> +void devlink_trace_hwmsg(const struct devlink *devlink, bool incoming,
>> +			 unsigned long type, const u8 *buf, size_t len);
>>  int devlink_port_register(struct devlink *devlink,
>>  			  struct devlink_port *devlink_port,
>>  			  unsigned int port_index);
>> @@ -154,6 +156,12 @@ static inline void devlink_free(struct devlink *devlink)
>>  	kfree(devlink);
>>  }
>>  
>> +static inline void devlink_trace_hwmsg(const struct devlink *devlink,
>> +				       bool incoming, unsigned long type,
>> +				       const u8 *buf, size_t len);
>> +{
>> +}
>> +
>>  static inline int devlink_port_register(struct devlink *devlink,
>>  					struct devlink_port *devlink_port,
>>  					unsigned int port_index)
>> diff --git a/include/trace/events/devlink.h b/include/trace/events/devlink.h
>> new file mode 100644
>> index 0000000..7918c57
>> --- /dev/null
>> +++ b/include/trace/events/devlink.h
>> @@ -0,0 +1,49 @@
>> +#undef TRACE_SYSTEM
>> +#define TRACE_SYSTEM devlink
>> +
>> +#if !defined(_TRACE_DEVLINK_H) || defined(TRACE_HEADER_MULTI_READ)
>> +#define _TRACE_DEVLINK_H
>> +
>> +#include <linux/device.h>
>> +#include <net/devlink.h>
>> +#include <linux/tracepoint.h>
>> +
>> +/*
>> + * Tracepoint for devlink hardware message:
>> + */
>> +TRACE_EVENT(devlink_hwmsg,
>> +	TP_PROTO(const struct devlink *devlink, bool incoming,
>> +		 unsigned long type, const u8 *buf, size_t len),
>> +
>> +	TP_ARGS(devlink, incoming, type, buf, len),
>> +
>> +	TP_STRUCT__entry(
>> +		__string(bus_name, devlink->dev->bus->name)
>> +		__string(dev_name, dev_name(devlink->dev))
>> +		__string(owner_name, devlink->dev->driver->owner->name)
>> +		__field(bool, incoming)
>> +		__field(unsigned long, type)
>> +		__dynamic_array(u8, buf, len)
>> +		__field(size_t, len)
>> +	),
>> +
>> +	TP_fast_assign(
>> +		__assign_str(bus_name, devlink->dev->bus->name);
>> +		__assign_str(dev_name, dev_name(devlink->dev));
>> +		__assign_str(owner_name, devlink->dev->driver->owner->name);
>> +		__entry->incoming = incoming;
>> +		__entry->type = type;
>> +		memcpy(__get_dynamic_array(buf), buf, len);
>> +		__entry->len = len;
>> +	),
>> +
>> +	TP_printk("bus_name=%s dev_name=%s owner_name=%s incoming=%d type=%lu buf=0x[%*phD] len=%lu",
>> +		  __get_str(bus_name), __get_str(dev_name),
>> +		  __get_str(owner_name), __entry->incoming, __entry->type,
>> +		  (int) __entry->len, __get_dynamic_array(buf), __entry->len)
>> +);
>> +
>> +#endif /* _TRACE_DEVLINK_H */
>> +
>> +/* This part must be outside protection */
>> +#include <trace/define_trace.h>
>> diff --git a/net/core/devlink.c b/net/core/devlink.c
>> index b2e592a..8cfa3b0 100644
>> --- a/net/core/devlink.c
>> +++ b/net/core/devlink.c
>> @@ -26,6 +26,8 @@
>>  #include <net/net_namespace.h>
>>  #include <net/sock.h>
>>  #include <net/devlink.h>
>> +#define CREATE_TRACE_POINTS
>> +#include <trace/events/devlink.h>
>>  
>>  static LIST_HEAD(devlink_list);
>>  
>> @@ -1679,6 +1681,13 @@ void devlink_free(struct devlink *devlink)
>>  }
>>  EXPORT_SYMBOL_GPL(devlink_free);
>>  
>> +void devlink_trace_hwmsg(const struct devlink *devlink, bool incoming,
>> +			 unsigned long type, const u8 *buf, size_t len)
>> +{
>> +	trace_devlink_hwmsg(devlink, incoming, type, buf, len);
>> +}
>> +EXPORT_SYMBOL_GPL(devlink_trace_hwmsg);
>> +
>
>Instead of having a function that always gets called even when tracing
>isn't enabled, why not have the caller call the trace_devlink_hwmsg()
>directly?

That's what David already pointed at. I like to have a simple wrapper
function with "devlink_" prefix.


>
>In the trace/devlink.h file you could encapsulate it with:
>
>#if IS_ENABLED(CONFIG_NET_DEVLINK)
>
>[...]
>
>#else
>static inline void trace_devlink_hwmsg(const struct devlink *devlink,
>				       bool incoming, unsigned long type,
>				       const u8 *buf, size_t len);
>{
>}
>#endif
>
>-- Steve
>
>>  /**
>>   *	devlink_port_register - Register devlink port
>>   *
>
