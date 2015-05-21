From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH v3 04/10] pktgen: document ability to add same device
	to several threads
Date: Thu, 21 May 2015 12:16:40 +0200
Message-ID: <20150521101636.15148.31595.stgit@ivy>
References: <20150521101501.15148.10609.stgit@ivy>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Daniel Borkmann <borkmann@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Robert Olsson <robert@herjulf.se>,
	Ben Greear <greearb@candelatech.com>,
	Cong Wang <cwang@twopensource.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53164 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751856AbbEUKRQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2015 06:17:16 -0400
In-Reply-To: <20150521101501.15148.10609.stgit@ivy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The pktgen.txt documentation still claimed that adding same device to
multiple threads were not supported, but it have been since 2008 via
commit e6fce5b916cd7 ("pktgen: multiqueue etc.").

Document this and describe the naming scheme dev@X, as the procfile name
still need to be unique.

Fixes: e6fce5b916cd7 ("pktgen: multiqueue etc.")
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
---

 Documentation/networking/pktgen.txt |   77 +++++++++++++++++++++++------------
 1 files changed, 50 insertions(+), 27 deletions(-)

diff --git a/Documentation/networking/pktgen.txt b/Documentation/networking/pktgen.txt
index d255434..e7ae8b2 100644
--- a/Documentation/networking/pktgen.txt
+++ b/Documentation/networking/pktgen.txt
@@ -50,16 +50,33 @@ For ixgbe use e.g. "30" resulting in approx 33K interrupts/sec (1/30*10^6):
  # ethtool -C ethX rx-usecs 30
 
 
-Viewing threads
-===============
-/proc/net/pktgen/kpktgend_0
-Running:
-Stopped: eth1
-Result: OK: add_device=eth1
+Kernel threads
+==============
+Pktgen creates a thread for each CPU with affinity to that CPU.
+Which is controlled through procfile /proc/net/pktgen/kpktgend_X.
+
+Example: /proc/net/pktgen/kpktgend_0
+
+ Running:
+ Stopped: eth4@0
+ Result: OK: add_device=eth4@0
+
+Most important are the devices assigned to the thread.
 
-Most important are the devices assigned to the thread.  Note that a
-device can only belong to one thread.
+The two basic thread commands are:
+ * add_device DEVICE@NAME -- adds a single device
+ * rem_device_all         -- remove all associated devices
 
+When adding a device to a thread, a corrosponding procfile is created
+which is used for configuring this device. Thus, device names need to
+be unique.
+
+To support adding the same device to multiple threads, which is useful
+with multi queue NICs, a the device naming scheme is extended with "@":
+ device@something
+
+The part after "@" can be anything, but it is custom to use the thread
+number.
 
 Viewing devices
 ===============
@@ -68,29 +85,32 @@ The Params section holds configured information.  The Current section
 holds running statistics.  The Result is printed after a run or after
 interruption.  Example:
 
-/proc/net/pktgen/eth1
+/proc/net/pktgen/eth4@0
 
-Params: count 10000000  min_pkt_size: 60  max_pkt_size: 60
-     frags: 0  delay: 0  clone_skb: 1000000  ifname: eth1
+ Params: count 100000  min_pkt_size: 60  max_pkt_size: 60
+     frags: 0  delay: 0  clone_skb: 64  ifname: eth4@0
      flows: 0 flowlen: 0
-     dst_min: 10.10.11.2  dst_max: 
-     src_min:   src_max: 
-     src_mac: 00:00:00:00:00:00  dst_mac: 00:04:23:AC:FD:82
-     udp_src_min: 9  udp_src_max: 9  udp_dst_min: 9  udp_dst_max: 9
-     src_mac_count: 0  dst_mac_count: 0 
-     Flags: 
-Current:
-     pkts-sofar: 10000000  errors: 39664
-     started: 1103053986245187us  stopped: 1103053999346329us idle: 880401us
-     seq_num: 10000011  cur_dst_mac_offset: 0  cur_src_mac_offset: 0
-     cur_saddr: 0x10a0a0a  cur_daddr: 0x20b0a0a
-     cur_udp_dst: 9  cur_udp_src: 9
+     queue_map_min: 0  queue_map_max: 0
+     dst_min: 192.168.81.2  dst_max:
+     src_min:   src_max:
+     src_mac: 90:e2:ba:0a:56:b4 dst_mac: 00:1b:21:3c:9d:f8
+     udp_src_min: 9  udp_src_max: 109  udp_dst_min: 9  udp_dst_max: 9
+     src_mac_count: 0  dst_mac_count: 0
+     Flags: UDPSRC_RND  NO_TIMESTAMP  QUEUE_MAP_CPU
+ Current:
+     pkts-sofar: 100000  errors: 0
+     started: 623913381008us  stopped: 623913396439us idle: 25us
+     seq_num: 100001  cur_dst_mac_offset: 0  cur_src_mac_offset: 0
+     cur_saddr: 192.168.8.3  cur_daddr: 192.168.81.2
+     cur_udp_dst: 9  cur_udp_src: 42
+     cur_queue_map: 0
      flows: 0
-Result: OK: 13101142(c12220741+d880401) usec, 10000000 (60byte,0frags)
-  763292pps 390Mb/sec (390805504bps) errors: 39664
+ Result: OK: 15430(c15405+d25) usec, 100000 (60byte,0frags)
+  6480562pps 3110Mb/sec (3110669760bps) errors: 0
+
 
-Configuring threads and devices
-================================
+Configuring devices
+===================
 This is done via the /proc interface, and most easily done via pgset
 as defined in the sample scripts.
 
@@ -221,6 +241,9 @@ Note that when adding devices to a specific CPU it is a good idea to
 also assign /proc/irq/XX/smp_affinity so that the TX interrupts are bound
 to the same CPU.  This reduces cache bouncing when freeing skbs.
 
+Plus using the device flag QUEUE_MAP_CPU, which maps the SKBs TX queue
+to the running threads CPU (directly from smp_processor_id()).
+
 Enable IPsec
 ============
 Default IPsec transformation with ESP encapsulation plus transport mode
