From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: [RFC PATCH v3 5/5] perf:add a script shows a process of packet
Date: Tue, 20 Jul 2010 09:50:29 +0900
Message-ID: <4C44F2D5.3020509@jp.fujitsu.com>
References: <4C44F12F.5090908@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	kaneshige.kenji@jp.fujitsu.com, izumi.taku@jp.fujitsu.com,
	kosaki.motohiro@jp.fujitsu.com, nhorman@tuxdriver.com,
	laijs@cn.fujitsu.com, scott.a.mcmillan@intel.com,
	rostedt@goodmis.org, eric.dumazet@gmail.com, fweisbec@gmail.com,
	mathieu.desnoyers@polymtl.ca
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C44F12F.5090908@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a perf script which shows a process of packets and processed time.
It helps us to investigate networking or network device.

If you want to use it, install perf and record perf.data like following.

#perf trace record netdev-times [script]

If you set script, perf gathers records until it ends.
If not, you must Ctrl-C to stop recording.

And if you want a report from record,

#perf trace report netdev-times [options]

If you use some options, you can limit an output.
Option is below.

tx: show only process of tx packets
rx: show only process of rx packets
dev=: show a process specified with this option
debug: work with debug mode. It shows buffer status.

For example, if you want to show a process of received packets associated
with eth3,

#perf trace report netdev-times rx dev=eth3
79074.756672832sec cpu=1
irq_entry(+0.000000msec,irq=77:eth3)
         |------------softirq_raise(+0.001277msec)
irq_exit (+0.002278msec)     |
                      softirq_entry(+0.003562msec
                             |
                             |---netif_receive_skb(+0.006279msec,len=100)
                             |            |
                             |   skb_copy_datagram_iovec(+0.038778msec, 2285:sshd)
                             |
                      napi_poll_exit(+0.017160msec, eth3)
                             |
                      softirq_exit(+0.018248msec)


This perf script helps us to analyze a process time of transmit/receive
sequence.

Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
---
 tools/perf/scripts/python/bin/netdev-times-record |    8 +
 tools/perf/scripts/python/bin/netdev-times-report |    5 +
 tools/perf/scripts/python/netdev-times.py         |  478 +++++++++++++++++++++
 3 files changed, 491 insertions(+), 0 deletions(-)

diff --git a/tools/perf/scripts/python/bin/netdev-times-record b/tools/perf/scripts/python/bin/netdev-times-record
new file mode 100644
index 0000000..12da07e
--- /dev/null
+++ b/tools/perf/scripts/python/bin/netdev-times-record
@@ -0,0 +1,8 @@
+#!/bin/bash
+perf record -c 1 -f -R -a -e net:net_dev_xmit -e net:net_dev_queue	\
+		-e net:net_dev_receive -e skb:consume_skb		\
+		-e skb:kfree_skb -e skb:skb_free_datagram_locked	\
+		-e skb:dev_kfree_skb_irq -e napi:napi_poll		\
+		-e irq:irq_handler_entry -e irq:irq_handler_exit	\
+		-e irq:softirq_entry -e irq:softirq_exit		\
+		-e irq:softirq_raise -e skb:skb_copy_datagram_iovec $@
diff --git a/tools/perf/scripts/python/bin/netdev-times-report b/tools/perf/scripts/python/bin/netdev-times-report
new file mode 100644
index 0000000..c3d0a63
--- /dev/null
+++ b/tools/perf/scripts/python/bin/netdev-times-report
@@ -0,0 +1,5 @@
+#!/bin/bash
+# description: display a process of packet and processing time
+# args: [tx] [rx] [dev=] [debug]
+
+perf trace -s ~/libexec/perf-core/scripts/python/netdev-times.py $@
diff --git a/tools/perf/scripts/python/less b/tools/perf/scripts/python/less
new file mode 100644
index 0000000..e69de29
diff --git a/tools/perf/scripts/python/netdev-times.py b/tools/perf/scripts/python/netdev-times.py
new file mode 100644
index 0000000..486f16e
--- /dev/null
+++ b/tools/perf/scripts/python/netdev-times.py
@@ -0,0 +1,478 @@
+# Display a process of packets and processed time.
+# It helps us to investigate networking or network device.
+#
+# options
+# tx: show only tx chart
+# rx: show only rx chart
+# dev=: show only thing related to specified device
+# debug: work with debug mode. It shows buffer status.
+
+import os
+import sys
+
+sys.path.append(os.environ['PERF_EXEC_PATH'] + \
+	'/scripts/python/Perf-Trace-Util/lib/Perf/Trace')
+
+from perf_trace_context import *
+from Core import *
+from Util import *
+
+all_event_list = []; # insert all tracepoint event related with this script
+irq_dic = {}; # key is cpu and value is a list which stacks irqs
+              # which raise NET_RX softirq
+net_rx_dic = {}; # key is cpu and value include time of NET_RX softirq-entry
+		 # and a list which stacks receive
+receive_hunk_list = []; # a list which include a sequence of receive events
+rx_skb_list = []; # received packet list for matching
+		       # skb_copy_datagram_iovec
+
+buffer_budget = 65536; # the budget of rx_skb_list, tx_queue_list and
+		       # tx_xmit_list
+of_count_rx_skb_list = 0; # overflow count
+
+tx_queue_list = []; # list of packets which pass through dev_queue_xmit
+of_count_tx_queue_list = 0; # overflow count
+
+tx_xmit_list = [];  # list of packets which pass through dev_hard_start_xmit
+of_count_tx_xmit_list = 0; # overflow count
+
+tx_free_list = [];  # list of packets which is freed
+
+# options
+show_tx = 0;
+show_rx = 0;
+dev = 0; # store a name of device specified by option "dev="
+debug = 0;
+
+# indices of event_info tuple
+EINFO_IDX_NAME=   0
+EINFO_IDX_CONTEXT=1
+EINFO_IDX_CPU=    2
+EINFO_IDX_TIME=   3
+EINFO_IDX_PID=    4
+EINFO_IDX_COMM=   5
+
+# Calculate a time interval(msec) from src(nsec) to dst(nsec)
+def diff_msec(src, dst):
+	return (dst - src) / 1000000.0
+
+# Display a process of transmitting a packet
+def print_transmit(hunk):
+	if dev != 0 and hunk['dev'].find(dev) < 0:
+		return
+	print "%7s %5d %6d.%09dsec %12.6fmsec      %12.6fmsec" % \
+		(hunk['dev'], hunk['len'],
+		nsecs_secs(hunk['queue_t']),
+		nsecs_nsecs(hunk['queue_t']),
+		diff_msec(hunk['queue_t'], hunk['xmit_t']),
+		diff_msec(hunk['xmit_t'], hunk['free_t']))
+
+PF_IRQ_ENTRY= "irq_entry(+%fmsec,irq=%d:%s)"
+PF_IRQ_EXIT=  "irq_exit (+%fmsec)     |"
+PF_SOFT_RAISE="         |------------softirq_raise(+%fmsec)"
+PF_SOFT_ENTRY="                      softirq_entry(+%fmsec)"
+PF_SOFT_EXIT= "                      softirq_exit (+%fmsec)\n"
+PF_NAPI_POLL= "                      napi_poll_exit(+%fmsec, %s)"
+PF_JOINT=     "                             |"
+PF_WJOINT=    "                             |            |"
+PF_NET_RECV=  "                             |---netif_receive_skb" \
+				"(+%fmsec,len=%d)"
+PF_CPY_DGRAM= "                             |   skb_copy_datagram_iovec" \
+				"(+%fmsec, %d:%s)"
+PF_FREE_DGRAM="                             |   skb_free_datagram_locked" \
+				"(+%fmsec)"
+PF_KFREE_SKB= "                             |   kfree_skb" \
+				"(+%fmsec)"
+PF_CONS_SKB=  "                             |   consume_skb" \
+				"(+%fmsec)"
+
+# Display a process of received packets and interrputs associated with
+# a NET_RX softirq
+def print_receive(hunk):
+	show_hunk = 0
+	irq_list = hunk['irq_list']
+	cpu = irq_list[0]['cpu']
+	base_t = irq_list[0]['irq_ent_t']
+	# check if this hunk should be showed
+	if dev != 0:
+		for i in range(len(irq_list)):
+			if irq_list[i]['name'].find(dev) >= 0:
+				show_hunk = 1
+				break
+	else:
+		show_hunk = 1
+	if show_hunk == 0:
+		return
+
+	print "%d.%09dsec cpu=%d" % \
+		(nsecs_secs(base_t), nsecs_nsecs(base_t), cpu)
+	for i in range(len(irq_list)):
+		print PF_IRQ_ENTRY % \
+			(diff_msec(base_t, irq_list[i]['irq_ent_t']),
+			irq_list[i]['irq'], irq_list[i]['name'])
+
+		if 'sirq_raise_t' in irq_list[i].keys():
+			print PF_SOFT_RAISE % \
+				diff_msec(base_t, irq_list[i]['sirq_raise_t'])
+
+		if 'irq_ext_t' in irq_list[i].keys():
+			print PF_IRQ_EXIT % \
+				diff_msec(base_t, irq_list[i]['irq_ext_t'])
+	if 'sirq_ent_t' not in hunk.keys():
+		print 'maybe softirq_entry is dropped'
+		return
+	print PF_SOFT_ENTRY % \
+		diff_msec(base_t, hunk['sirq_ent_t'])
+	print PF_JOINT
+	event_list = hunk['event_list']
+	for i in range(len(event_list)):
+		event = event_list[i]
+		if event['event_name'] == 'napi_poll':
+			print PF_NAPI_POLL % \
+			    (diff_msec(base_t, event['event_t']), event['dev'])
+		else:
+			print PF_NET_RECV % \
+			    (diff_msec(base_t, event['event_t']), event['len'])
+			if 'comm' in event.keys():
+				print PF_WJOINT
+				print PF_CPY_DGRAM % \
+					(diff_msec(base_t, event['comm_t']),
+					event['pid'], event['comm'])
+			elif 'handle' in event.keys():
+				print PF_WJOINT
+				if event['handle'] == \
+				    "skb_free_datagram_locked":
+					print PF_FREE_DGRAM % \
+						diff_msec(base_t,
+							event['comm_t'])
+				elif event['handle'] == "kfree_skb":
+					print PF_KFREE_SKB % \
+						diff_msec(base_t,
+							event['comm_t'])
+				elif event['handle'] == "consume_skb":
+					print PF_CONS_SKB % \
+						diff_msec(base_t,
+							event['comm_t'])
+		print PF_JOINT
+	print PF_SOFT_EXIT % diff_msec(base_t, hunk['sirq_ext_t'])
+
+def trace_begin():
+	global show_tx
+	global show_rx
+	global dev
+	global debug
+
+	for i in range(len(sys.argv)):
+		if i == 0:
+			continue
+		arg = sys.argv[i]
+		if arg == 'tx':
+			show_tx = 1
+		elif arg =='rx':
+			show_rx = 1
+		elif arg.find('dev=',0, 4) >= 0:
+			dev = arg[4:]
+		elif arg == 'debug':
+			debug = 1
+	if show_tx == 0  and show_rx == 0:
+		show_tx = 1
+		show_rx = 1
+
+def trace_end():
+	# order all events in time
+	all_event_list.sort(lambda a,b :cmp(a[EINFO_IDX_TIME],
+					    b[EINFO_IDX_TIME]))
+	# process all events
+	for i in range(len(all_event_list)):
+		event_info = all_event_list[i]
+		name = event_info[EINFO_IDX_NAME]
+		if name == 'irq__softirq_exit':
+			handle_irq_softirq_exit(event_info)
+		elif name == 'irq__softirq_entry':
+			handle_irq_softirq_entry(event_info)
+		elif name == 'irq__softirq_raise':
+			handle_irq_softirq_raise(event_info)
+		elif name == 'irq__irq_handler_entry':
+			handle_irq_handler_entry(event_info)
+		elif name == 'irq__irq_handler_exit':
+			handle_irq_handler_exit(event_info)
+		elif name == 'napi__napi_poll':
+			handle_napi_poll(event_info)
+		elif name == 'net__net_dev_receive':
+			handle_net_dev_receive(event_info)
+		elif name == 'skb__skb_copy_datagram_iovec':
+			handle_skb_copy_datagram_iovec(event_info)
+		elif name == 'net__net_dev_queue':
+			handle_net_dev_queue(event_info)
+		elif name == 'net__net_dev_xmit':
+			handle_net_dev_xmit(event_info)
+		elif name == 'skb__kfree_skb':
+			handle_kfree_skb(event_info)
+		elif name == 'skb__dev_kfree_skb_irq':
+			handle_dev_kfree_skb_irq(event_info)
+		elif name == 'skb__consume_skb':
+			handle_consume_skb(event_info)
+		elif name == 'skb__skb_free_datagram_locked':
+			handle_skb_free_datagram_locked(event_info)
+	# display receive hunks
+	if show_rx:
+		for i in range(len(receive_hunk_list)):
+			print_receive(receive_hunk_list[i])
+	# display transmit hunks
+	if show_tx:
+		print "   dev    len      Qdisc        " \
+			"       netdevice             free"
+		for i in range(len(tx_free_list)):
+			print_transmit(tx_free_list[i])
+	if debug:
+		print "debug buffer status"
+		print "----------------------------"
+		print "xmit Qdisc:remain:%d overflow:%d" % \
+			(len(tx_queue_list), of_count_tx_queue_list)
+		print "xmit netdevice:remain:%d overflow:%d" % \
+			(len(tx_xmit_list), of_count_tx_xmit_list)
+		print "receive:remain:%d overflow:%d" % \
+			(len(rx_skb_list), of_count_rx_skb_list)
+
+# called from perf, when it finds a correspoinding event
+def irq__softirq_entry(name, context, cpu, sec, nsec, pid, comm, vec):
+	if symbol_str("irq__softirq_entry", "vec", vec) != "NET_RX":
+		return
+	event_info = (name, context, cpu, nsecs(sec, nsec), pid, comm, vec)
+	all_event_list.append(event_info)
+
+def irq__softirq_exit(name, context, cpu, sec, nsec, pid, comm, vec):
+	if symbol_str("irq__softirq_entry", "vec", vec) != "NET_RX":
+		return
+	event_info = (name, context, cpu, nsecs(sec, nsec), pid, comm, vec)
+	all_event_list.append(event_info)
+
+def irq__softirq_raise(name, context, cpu, sec, nsec, pid, comm, vec):
+	if symbol_str("irq__softirq_entry", "vec", vec) != "NET_RX":
+		return
+	event_info = (name, context, cpu, nsecs(sec, nsec), pid, comm, vec)
+	all_event_list.append(event_info)
+
+def irq__irq_handler_entry(name, context, cpu, sec, nsec, pid, comm,
+			irq, irq_name):
+	event_info = (name, context, cpu, nsecs(sec, nsec), pid, comm,
+			irq, irq_name)
+	all_event_list.append(event_info)
+
+def irq__irq_handler_exit(name, context, cpu, sec, nsec, pid, comm, irq, ret):
+	event_info = (name, context, cpu, nsecs(sec, nsec), pid, comm, irq, ret)
+	all_event_list.append(event_info)
+
+def napi__napi_poll(name, context, cpu, sec, nsec, pid, comm, napi, dev_name):
+	event_info = (name, context, cpu, nsecs(sec, nsec), pid, comm,
+			napi, dev_name)
+	all_event_list.append(event_info)
+
+def net__net_dev_receive(name, context, cpu, sec, nsec, pid, comm, skbaddr,
+			skblen, dev_name):
+	event_info = (name, context, cpu, nsecs(sec, nsec), pid, comm,
+			skbaddr, skblen, dev_name)
+	all_event_list.append(event_info)
+
+def net__net_dev_queue(name, context, cpu, sec, nsec, pid, comm,
+			skbaddr, skblen, dev_name):
+	event_info = (name, context, cpu, nsecs(sec, nsec), pid, comm,
+			skbaddr, skblen, dev_name)
+	all_event_list.append(event_info)
+
+def net__net_dev_xmit(name, context, cpu, sec, nsec, pid, comm,
+			skbaddr, skblen, rc, dev_name):
+	event_info = (name, context, cpu, nsecs(sec, nsec), pid, comm,
+			skbaddr, skblen, rc ,dev_name)
+	all_event_list.append(event_info)
+
+def skb__kfree_skb(name, context, cpu, sec, nsec, pid, comm,
+			skbaddr, protocol, location):
+	event_info = (name, context, cpu, nsecs(sec, nsec), pid, comm,
+			skbaddr, protocol, location)
+	all_event_list.append(event_info)
+
+def skb__skb_free_datagram_locked(name, context, cpu, sec, nsec, pid, comm,
+			skbaddr):
+	event_info = (name, context, cpu, nsecs(sec, nsec), pid, comm,
+			skbaddr)
+	all_event_list.append(event_info)
+
+def skb__dev_kfree_skb_irq(name, context, cpu, sec, nsec, pid, comm, skbaddr):
+	event_info = (name, context, cpu, nsecs(sec, nsec), pid, comm,
+			skbaddr)
+	all_event_list.append(event_info)
+
+def skb__consume_skb(name, context, cpu, sec, nsec, pid, comm, skbaddr):
+	event_info = (name, context, cpu, nsecs(sec, nsec), pid, comm,
+			skbaddr)
+	all_event_list.append(event_info)
+
+def skb__skb_copy_datagram_iovec(name, context, cpu, sec, nsec, pid, comm,
+	skbaddr, skblen):
+	event_info = (name, context, cpu, nsecs(sec, nsec), pid, comm,
+			skbaddr, skblen)
+	all_event_list.append(event_info)
+
+def handle_irq_softirq_exit(event_info):
+	(name, context, cpu, time, pid, comm, vec) = event_info
+	irq_list = []
+	event_list = 0
+	if cpu in irq_dic.keys():
+		irq_list = irq_dic[cpu]
+		del irq_dic[cpu]
+	if cpu in net_rx_dic.keys():
+		sirq_ent_t = net_rx_dic[cpu]['sirq_ent_t']
+		event_list = net_rx_dic[cpu]['event_list']
+		del net_rx_dic[cpu]
+	if irq_list == [] or event_list == 0:
+		return
+	rec_data = {'sirq_ent_t':sirq_ent_t, 'sirq_ext_t':time,
+		    'irq_list':irq_list, 'event_list':event_list}
+	# merge information realted to a NET_RX softirq
+	receive_hunk_list.append(rec_data)
+
+def handle_irq_softirq_entry(event_info):
+	(name, context, cpu, time, pid, comm, vec) = event_info
+	net_rx_dic[cpu] = {'sirq_ent_t':time, 'event_list':[]}
+
+def handle_irq_softirq_raise(event_info):
+	(name, context, cpu, time, pid, comm, vec) = event_info
+	if cpu not in irq_dic.keys() \
+	or len(irq_dic[cpu]) == 0:
+		return
+	irq = irq_dic[cpu].pop()
+	# put a time to prev irq on the same cpu
+	irq.update({'sirq_raise_t':time})
+	irq_dic[cpu].append(irq)
+
+def handle_irq_handler_entry(event_info):
+	(name, context, cpu, time, pid, comm, irq, irq_name) = event_info
+	if cpu not in irq_dic.keys():
+		irq_dic[cpu] = []
+	irq_record = {'irq':irq, 'name':irq_name, 'cpu':cpu, 'irq_ent_t':time}
+	irq_dic[cpu].append(irq_record)
+
+def handle_irq_handler_exit(event_info):
+	(name, context, cpu, time, pid, comm, irq, ret) = event_info
+	if cpu not in irq_dic.keys():
+		return
+	irq_record = irq_dic[cpu].pop()
+	if irq != irq_record['irq']:
+		return
+	irq_record.update({'irq_ext_t':time})
+	# if an irq doesn't include NET_RX softirq, drop.
+	if 'sirq_raise_t' in irq_record.keys():
+		irq_dic[cpu].append(irq_record)
+
+def handle_napi_poll(event_info):
+	(name, context, cpu, time, pid, comm, napi, dev_name) = event_info
+	if cpu in net_rx_dic.keys():
+		event_list = net_rx_dic[cpu]['event_list']
+		rec_data = {'event_name':'napi_poll',
+				'dev':dev_name, 'event_t':time}
+		event_list.append(rec_data)
+
+def handle_net_dev_receive(event_info):
+	global of_count_rx_skb_list
+
+	(name, context, cpu, time, pid, comm,
+		skbaddr, skblen, dev_name) = event_info
+	if cpu in net_rx_dic.keys():
+		rec_data = {'event_name':'netif_receive_skb',
+			    'event_t':time, 'skbaddr':skbaddr, 'len':skblen}
+		event_list = net_rx_dic[cpu]['event_list']
+		event_list.append(rec_data)
+		rx_skb_list.insert(0, rec_data)
+		if len(rx_skb_list) > buffer_budget:
+			rx_skb_list.pop()
+			of_count_rx_skb_list += 1
+
+def handle_net_dev_queue(event_info):
+	global of_count_tx_queue_list
+
+	(name, context, cpu, time, pid, comm,
+		skbaddr, skblen, dev_name) = event_info
+	skb = {'dev':dev_name, 'skbaddr':skbaddr, 'len':skblen, 'queue_t':time}
+	tx_xmit_list.insert(0, skb)
+	if len(tx_xmit_list) > buffer_budget:
+		tx_xmit_list.pop()
+		of_count_tx_xmit_list += 1
+
+def handle_net_dev_xmit(event_info):
+	global of_count_tx_queue_list
+
+	(name, context, cpu, time, pid, comm,
+		skbaddr, skblen, rc, dev_name) = event_info
+	if rc == 0: # NETDEV_TX_OK
+		for i in range(len(tx_xmit_list)):
+			skb = tx_xmit_list[i]
+			if skb['skbaddr'] == skbaddr:
+				skb['xmit_t'] = time
+				tx_queue_list.insert(0, skb)
+				del tx_xmit_list[i]
+				if len(tx_queue_list) > buffer_budget:
+					tx_queue_list.pop()
+					of_count_tx_queue_list += 1
+				return
+
+def handle_kfree_skb(event_info):
+	(name, context, cpu, time, pid, comm,
+		skbaddr, protocol, location) = event_info
+	for i in range(len(tx_queue_list)):
+		skb = tx_queue_list[i]
+		if skb['skbaddr'] == skbaddr:
+			del tx_queue_list[i]
+			return
+	for i in range(len(tx_xmit_list)):
+		skb = tx_xmit_list[i]
+		if skb['skbaddr'] == skbaddr:
+			del tx_xmit_list[i]
+			return
+	for i in range(len(rx_skb_list)):
+		rec_data = rx_skb_list[i]
+		if rec_data['skbaddr'] == skbaddr:
+			rec_data.update({'handle':"kfree_skb",
+					'comm':comm, 'pid':pid, 'comm_t':time})
+			del rx_skb_list[i]
+			return
+
+def handle_dev_kfree_skb_irq(event_info):
+	(name, context, cpu, time, pid, comm, skbaddr) = event_info
+	for i in range(len(tx_queue_list)):
+		skb = tx_queue_list[i]
+		if skb['skbaddr'] == skbaddr:
+			skb['free_t'] = time
+			tx_free_list.append(skb)
+			del tx_queue_list[i]
+			return
+
+def handle_consume_skb(event_info):
+	(name, context, cpu, time, pid, comm, skbaddr) = event_info
+	for i in range(len(tx_queue_list)):
+		skb = tx_queue_list[i]
+		if skb['skbaddr'] == skbaddr:
+			skb['free_t'] = time
+			tx_free_list.append(skb)
+			del tx_queue_list[i]
+			return
+
+def handle_skb_free_datagram_locked(event_info):
+	(name, context, cpu, time, pid, comm, skbaddr) = event_info
+	for i in range(len(rx_skb_list)):
+		rec_data = rx_skb_list[i]
+		if skbaddr == rec_data['skbaddr']:
+			rec_data.update({'handle':"skb_free_datagram_locked",
+					'comm':comm, 'pid':pid, 'comm_t':time})
+			del rx_skb_list[i]
+			return
+
+def handle_skb_copy_datagram_iovec(event_info):
+	(name, context, cpu, time, pid, comm, skbaddr, skblen) = event_info
+	for i in range(len(rx_skb_list)):
+		rec_data = rx_skb_list[i]
+		if skbaddr == rec_data['skbaddr']:
+			rec_data.update({'handle':"skb_copy_datagram_iovec",
+					'comm':comm, 'pid':pid, 'comm_t':time})
+			del rx_skb_list[i]
+			return
