From: Ravi Patel <rapatel@apm.com>
Subject: [PATCH V3 1/4] Documentation: mailbox: APM X-Gene SoC QMTM
Date: Fri, 14 Feb 2014 18:21:59 -0800
Message-ID: <1392430922-24643-2-git-send-email-rapatel@apm.com>
References: <1392430922-24643-1-git-send-email-rapatel@apm.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	jcm@redhat.com, patches@apm.com, Ravi Patel <rapatel@apm.com>,
	Keyur Chudgar <kchudgar@apm.com>
To: arnd@arndb.de, gregkh@linuxfoundation.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392430922-24643-1-git-send-email-rapatel@apm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds documentation for APM X-Gene SoC Queue Manager/Traffic Manager.

Signed-off-by: Ravi Patel <rapatel@apm.com>
Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
---
 Documentation/mailbox/apm-xgene-qmtm.txt |  149 ++++++++++++++++++++++++++++++
 1 file changed, 149 insertions(+)
 create mode 100644 Documentation/mailbox/apm-xgene-qmtm.txt

diff --git a/Documentation/mailbox/apm-xgene-qmtm.txt b/Documentation/mailbox/apm-xgene-qmtm.txt
new file mode 100644
index 0000000..2b4ff09
--- /dev/null
+++ b/Documentation/mailbox/apm-xgene-qmtm.txt
@@ -0,0 +1,149 @@
+AppliedMicro X-Gene SOC Queue Manager/Traffic Manager Document
+
+Copyright (c) 2013 Applied Micro Circuits Corporation.
+Author: Ravi Patel <rapatel@apm.com>
+
+This program is free software; you can redistribute it and/or modify it
+under the terms of the GNU General Public License version 2 as published by
+the Free Software Foundation.
+
+This program is distributed in the hope that it will be useful,
+but WITHOUT ANY WARRANTY; without even the implied warranty of
+MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+GNU General Public License for more details.
+
+
+Overview:
+QMTM is a device which interacts with CPU, Ethernet, PktDMA and Security
+subsystems through AXI BUS. Its centralized resource manager/driver exports
+APIs for CPU, Ethernet, PktDMA and Security subsystems to
+1. Initialize & allocate queue & pbn.
+2. Read queue state so that subsystems driver knows how much more work it can
+   offload to its subsystem.
+3. Apply QoS for subsystems on their queues.
+
+Layout:
+The layout represents run-time flow of messages between Ethernet subsystem, CPU
+and QMTM in APM X-Gene SOC. PktDMA and Security subsystems interfaces with QMTM
+in the same way as Ethernet.
+
+
+                          CPU
+              o-------------------------o
+              |                         |
+         +----|[2]                   {5}|----+
+         |    |     [1]         {4}     |    |
+Register |    o------+-----------+------o    | Register
+Write    |    CPU WR |           | CPU RD    | Write
+to start v      MSG  v           ^  MSG      v to notify
+packet   |           |    DDR    |           | packet
+transmit |  o--------+-----o-----+--------o  | received
+         |  | Q0   M . M M | M M . M   Q1 |  |
+         |  | for  S . S S | S S . S  for |  |
+         |  | ETH  G . G G | G G . G  ETH |  |
+         |  | TX   n . 2 1 | 1 2 . n   RX |  |
+         |  o----------+---o---+----------o  |
+         |             |       |             |
+         v             v       ^             v
+         |             |       |             |
+o--------|-------------|-------|-------------|--------o
+|        |             |       |             |        | Coherent
+|        v             v       ^             v        | I/O
+|        |             |       |             |        | BUS
+o--------|-------------|-------|-------------|--------o
+         |         [3] |       | {3}         |
+         v     QMTM RD v       ^ QMTM WR     v
+         |       MSG   |       |   MSG       |
+    o----+----o--------+---o---+--------o----+----o
+    | Queue 0 |            |            | Queue 1 |
+    | Command o ETH PBN 0  o  CPU PBN 0 o Command | Queue Manager/
+    | Register|            |            |Register | Traffic Manager
+    o---------o---+--------o--------+---o---------o
+                  |                 |
+                  v                 ^
+Ethernet RD MSG   | [4]   ETH   {2} |  Ethernet WR MSG
+from its PBN  o---+-----------------+---o to CPU PBN
+              |                         |
+              | Egress MAC  Ingress MAC |
+              |     [5]         {1}     |
+              o------|-----------|------o
+                     v           ^
+                     |           |
+                  TX Data     RX Data
+
+Transmit Flow
+[1] CPU (Ethernet driver) prepares 32 byte Ethernet egress work message and
+    enqueues the message to the queue in DDR.
+[2] CPU (Ethernet driver) notifies QMTM that there is a message enqueued in
+    Ethernet transmit queue (e.g. Q0).
+[3] QMTM prefetches the Ethernet egress work messages into Ethernet PBN
+    (e.g. ETH PBN 0).
+[4] Ethernet reads work messages from its PBN.
+[5] Ethernet DMAs payload from DDR to its egress FIFO and transmits data out.
+
+Receive Flow
+{1} Ethernet receives data and DMAs payload from its ingress FIFO to DDR and
+    prepares a Ethernet ingress work message.
+{2} Ethernet pushes work message to QMTM.
+{3} QMTM prefetches the Ethernet ingress work messages into CPU PBN
+    (e.g. CPU PBN 0) and then interrupts CPU.
+{4} CPU (Ethernet driver) dequeues the 32 bytes Ethernet ingress work message
+    from the queue in DDR.
+{5} CPU (Ethernet driver) notifies QMTM that it dequeued a message from
+    Ethernet receive queue (e.g. Q1).
+
+
+Definition:
+1. QMTM (Queue/Traffic Manager)
+   QMTM manages queues and pbns for CPU, Ethernet, PktDMA and Security
+   Subsystems. It also performs flow control and QoS on queues.
+
+2. Slave/Client/Agent
+   Ethernet, PktDMA (XOR Engine) and Security Engine Subsystems & CPU whose
+   queues and pbn are managed by QMTM are called slave/client/agent.
+
+3. Queue
+   Queue is circular FIFO memory for QMTM hardware in which a 16 bytes,
+   32 bytes or 64 bytes message is dequeued OR enqueued between CPU and
+   Ethernet, PktDMA and Security Engine Subsystems.
+
+4. PB
+   Each subsystem in the APM X-Gene SoC device has a prefetch buffer for
+   storing messages in order to pipeline the QMTM processing latency with the
+   subsystem processing latency. The number of buffers prefetched depends on
+   the QM/TM processing latency and the subsystem data rate.
+
+   There are multiple PB for a subsystem, each PB is assigned a number which is
+   called PBN. Each subsystem and CPU can have max 32 pbns, however QMTM limits
+   how many pbns it supports for each subsystem.
+
+5. Message
+   The subsystems in the APM X-Gene SoC communicate with a central Queue Manager
+   (QM) that manages all the messages queued to the subsystems. The subsystems
+   communicate with the QM using messages that include information about the
+   work to be performed and the location of the buffers or data on which the
+   work is to be performed.
+
+   A message consists of 16, 32 or 64 bytes which resides in a queue. A message
+   which is
+   a. 16 bytes contains information of data buffer, length, etc. allocated by
+      subsystem driver.
+   b. 32 or 64 bytes contains information about the work to be done for a
+      subsystem. Each subsystem defines its own format of work message.
+
+   Each subsystem defines their own format of work message. A message (or queue
+   descriptor) has attribute fields (QMTM specific) which are common for all
+   subsystem work messages. The remaining fields of a message are specific to
+   subsystem. QMTM device doesn't have any knowledge of these subsystems
+   specific fields and the data operation which subsystem is going to perform
+   using these fields.
+
+   e.g.
+   1. Ethernet work message includes data address & length which is used by
+      Ethernet DMA engine for copying the data to/from its internal FIFO.
+   2. PktDMA work message includes multiple data addresses & lengths for
+      doing scatter/gather, XOR operations and result data address/es to give
+      back result to the CPU (driver).
+   3. Security work message includes data address & length for doing encryption
+      or decryption, the type of encryption or decryption and result data
+      address to give back result to the CPU (driver).
-- 
1.7.9.5
