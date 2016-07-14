From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 1/2] devlink: fix build error for
 CONFIG_MODULES=n
Date: Thu, 14 Jul 2016 08:21:11 +0200
Message-ID: <20160714062111.GA2228@nanopsycho.orion>
References: <20160713210338.1647521-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@mellanox.com>, netdev@vger.kernel.org,
	Steven Rostedt <rostedt@goodmis.org>,
	Ingo Molnar <mingo@redhat.com>,
	"David S . Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33713 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751456AbcGNGVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 02:21:14 -0400
Received: by mail-wm0-f67.google.com with SMTP id o80so8302376wme.0
        for <netdev@vger.kernel.org>; Wed, 13 Jul 2016 23:21:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160713210338.1647521-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Jul 13, 2016 at 11:03:37PM CEST, arnd@arndb.de wrote:
>A driver calling trace_devlink_hwmsg cannot be built when modules are disabled:
>
>include/trace/events/devlink.h: In function 'trace_event_get_offsets_devlink_hwmsg':
>include/trace/events/devlink.h:25:51: error: dereferencing pointer to incomplete type 'struct module'
>   __string(owner_name, devlink->dev->driver->owner->name)
>
>This changes the code to only print the module name when modules are actually
>enabled, otherwise we hardcode the string "built-in".
>
>Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>Fixes: e5224f0fe2ac ("devlink: add hardware messages tracing facility")
>---
> include/trace/events/devlink.h | 8 ++++++++
> 1 file changed, 8 insertions(+)
>
>diff --git a/include/trace/events/devlink.h b/include/trace/events/devlink.h
>index 333c32ac9bfa..26f92d3c7e9c 100644
>--- a/include/trace/events/devlink.h
>+++ b/include/trace/events/devlink.h
>@@ -22,7 +22,11 @@ TRACE_EVENT(devlink_hwmsg,
> 	TP_STRUCT__entry(
> 		__string(bus_name, devlink->dev->bus->name)
> 		__string(dev_name, dev_name(devlink->dev))
>+#ifdef CONFIG_MODULES
> 		__string(owner_name, devlink->dev->driver->owner->name)

I think would be better to use driver->name. I looks like it is always
present. I will do some tests and send a patch.


>+#else
>+		__string(owner_name, "built-in")
>+#endif
> 		__field(bool, incoming)
> 		__field(unsigned long, type)
> 		__dynamic_array(u8, buf, len)
>@@ -32,7 +36,11 @@ TRACE_EVENT(devlink_hwmsg,
> 	TP_fast_assign(
> 		__assign_str(bus_name, devlink->dev->bus->name);
> 		__assign_str(dev_name, dev_name(devlink->dev));
>+#ifdef CONFIG_MODULES
> 		__assign_str(owner_name, devlink->dev->driver->owner->name);
>+#else
>+		__assign_str(owner_name, "built-in");
>+#endif
> 		__entry->incoming = incoming;
> 		__entry->type = type;
> 		memcpy(__get_dynamic_array(buf), buf, len);
>-- 
>2.9.0
>
