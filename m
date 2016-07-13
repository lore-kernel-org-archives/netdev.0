From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH net-next 1/2] devlink: fix build error for CONFIG_MODULES=n
Date: Wed, 13 Jul 2016 23:03:37 +0200
Message-ID: <20160713210338.1647521-1-arnd@arndb.de>
Cc: netdev@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>,
	Ingo Molnar <mingo@redhat.com>,
	"David S . Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>
To: Jiri Pirko <jiri@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.24]:51079 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750960AbcGMVEt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2016 17:04:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A driver calling trace_devlink_hwmsg cannot be built when modules are disabled:

include/trace/events/devlink.h: In function 'trace_event_get_offsets_devlink_hwmsg':
include/trace/events/devlink.h:25:51: error: dereferencing pointer to incomplete type 'struct module'
   __string(owner_name, devlink->dev->driver->owner->name)

This changes the code to only print the module name when modules are actually
enabled, otherwise we hardcode the string "built-in".

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: e5224f0fe2ac ("devlink: add hardware messages tracing facility")
---
 include/trace/events/devlink.h | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/include/trace/events/devlink.h b/include/trace/events/devlink.h
index 333c32ac9bfa..26f92d3c7e9c 100644
--- a/include/trace/events/devlink.h
+++ b/include/trace/events/devlink.h
@@ -22,7 +22,11 @@ TRACE_EVENT(devlink_hwmsg,
 	TP_STRUCT__entry(
 		__string(bus_name, devlink->dev->bus->name)
 		__string(dev_name, dev_name(devlink->dev))
+#ifdef CONFIG_MODULES
 		__string(owner_name, devlink->dev->driver->owner->name)
+#else
+		__string(owner_name, "built-in")
+#endif
 		__field(bool, incoming)
 		__field(unsigned long, type)
 		__dynamic_array(u8, buf, len)
@@ -32,7 +36,11 @@ TRACE_EVENT(devlink_hwmsg,
 	TP_fast_assign(
 		__assign_str(bus_name, devlink->dev->bus->name);
 		__assign_str(dev_name, dev_name(devlink->dev));
+#ifdef CONFIG_MODULES
 		__assign_str(owner_name, devlink->dev->driver->owner->name);
+#else
+		__assign_str(owner_name, "built-in");
+#endif
 		__entry->incoming = incoming;
 		__entry->type = type;
 		memcpy(__get_dynamic_array(buf), buf, len);
-- 
2.9.0
