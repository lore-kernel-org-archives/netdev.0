From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?= <uwe@kleine-koenig.org>
Subject: [PATCH v2] net/phy: add trace events for mdio accesses
Date: Tue, 22 Nov 2016 11:01:27 +0100
Message-ID: <20161122100127.5940-1-uwe@kleine-koenig.org>
References: <20161114110335.27862-1-uwe@kleine-koenig.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>,
        Steven Rostedt <rostedt@goodmis.org>,
        Ingo Molnar <mingo@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:35605 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755819AbcKVKBh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 05:01:37 -0500
In-Reply-To: <20161114110335.27862-1-uwe@kleine-koenig.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make it possible to generate trace events for mdio read and write accesses.

Signed-off-by: Uwe Kleine-König <uwe@kleine-koenig.org>
---
Changes since (implicit) v1:

 - make use of TRACE_EVENT_CONDITION

Alternatively to this patch the condition could be

+	TP_CONDITION(err == 0),

but then we'd need in the read callbacks:

+	trace_mdio_access(bus, 1, addr, regnum, retval, retval < 0 ? retval : 0);

or at least

+	trace_mdio_access(bus, 1, addr, regnum, retval, retval < 0);

which both looks more ugly IMHO.

Best regards
Uwe

 drivers/net/phy/mdio_bus.c  | 11 +++++++++++
 include/trace/events/mdio.h | 42 ++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 53 insertions(+)
 create mode 100644 include/trace/events/mdio.h

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 09deef4bed09..653d076eafe5 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -38,6 +38,9 @@
 
 #include <asm/irq.h>
 
+#define CREATE_TRACE_POINTS
+#include <trace/events/mdio.h>
+
 int mdiobus_register_device(struct mdio_device *mdiodev)
 {
 	if (mdiodev->bus->mdio_map[mdiodev->addr])
@@ -461,6 +464,8 @@ int mdiobus_read_nested(struct mii_bus *bus, int addr, u32 regnum)
 	retval = bus->read(bus, addr, regnum);
 	mutex_unlock(&bus->mdio_lock);
 
+	trace_mdio_access(bus, 1, addr, regnum, retval, retval);
+
 	return retval;
 }
 EXPORT_SYMBOL(mdiobus_read_nested);
@@ -485,6 +490,8 @@ int mdiobus_read(struct mii_bus *bus, int addr, u32 regnum)
 	retval = bus->read(bus, addr, regnum);
 	mutex_unlock(&bus->mdio_lock);
 
+	trace_mdio_access(bus, 1, addr, regnum, retval, retval);
+
 	return retval;
 }
 EXPORT_SYMBOL(mdiobus_read);
@@ -513,6 +520,8 @@ int mdiobus_write_nested(struct mii_bus *bus, int addr, u32 regnum, u16 val)
 	err = bus->write(bus, addr, regnum, val);
 	mutex_unlock(&bus->mdio_lock);
 
+	trace_mdio_access(bus, 0, addr, regnum, val, err);
+
 	return err;
 }
 EXPORT_SYMBOL(mdiobus_write_nested);
@@ -538,6 +547,8 @@ int mdiobus_write(struct mii_bus *bus, int addr, u32 regnum, u16 val)
 	err = bus->write(bus, addr, regnum, val);
 	mutex_unlock(&bus->mdio_lock);
 
+	trace_mdio_access(bus, 0, addr, regnum, val, err);
+
 	return err;
 }
 EXPORT_SYMBOL(mdiobus_write);
diff --git a/include/trace/events/mdio.h b/include/trace/events/mdio.h
new file mode 100644
index 000000000000..468e2d095d19
--- /dev/null
+++ b/include/trace/events/mdio.h
@@ -0,0 +1,42 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM mdio
+
+#if !defined(_TRACE_MDIO_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_MDIO_H
+
+#include <linux/tracepoint.h>
+
+TRACE_EVENT_CONDITION(mdio_access,
+
+	TP_PROTO(struct mii_bus *bus, int read,
+		 unsigned addr, unsigned regnum, u16 val, int err),
+
+	TP_ARGS(bus, read, addr, regnum, val, err),
+
+	TP_CONDITION(err >= 0),
+
+	TP_STRUCT__entry(
+		__array(char, busid, MII_BUS_ID_SIZE)
+		__field(int, read)
+		__field(unsigned, addr)
+		__field(unsigned, regnum)
+		__field(u16, val)
+	),
+
+	TP_fast_assign(
+		strncpy(__entry->busid, bus->id, MII_BUS_ID_SIZE);
+		__entry->read = read;
+		__entry->addr = addr;
+		__entry->regnum = regnum;
+		__entry->val = val;
+	),
+
+	TP_printk("%s %-5s phy:0x%02x reg:0x%02x val:0x%04hx",
+		  __entry->busid, __entry->read ? "read" : "write",
+		  __entry->addr, __entry->regnum, __entry->val)
+);
+
+#endif /* if !defined(_TRACE_MDIO_H) || defined(TRACE_HEADER_MULTI_READ) */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
-- 
2.10.2
