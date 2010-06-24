From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: [RFC PATCH v2 5/5] perf:add a script shows a process of packet
Date: Thu, 24 Jun 2010 17:21:48 +0900
Message-ID: <4C23159C.5020604@jp.fujitsu.com>
References: <4C2312A8.9060903@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, scott.a.mcmillan@intel.com,
	kaneshige.kenji@jp.fujitsu.com, izumi.taku@jp.fujitsu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail6.fujitsu.co.jp ([192.51.44.36]:55945 "EHLO
	fgwmail6.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754225Ab0FXIWL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jun 2010 04:22:11 -0400
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5O8M8kf006568
	for <netdev@vger.kernel.org> (envelope-from sanagi.koki@jp.fujitsu.com);
	Thu, 24 Jun 2010 17:22:08 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 74AFC45DE57
	for <netdev@vger.kernel.org>; Thu, 24 Jun 2010 17:22:08 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 50A7B45DE51
	for <netdev@vger.kernel.org>; Thu, 24 Jun 2010 17:22:08 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 34CC11DB803A
	for <netdev@vger.kernel.org>; Thu, 24 Jun 2010 17:22:08 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B77E61DB803F
	for <netdev@vger.kernel.org>; Thu, 24 Jun 2010 17:22:04 +0900 (JST)
In-Reply-To: <4C2312A8.9060903@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This perf script shows a time-chart of process of packet.
Patch 0/5 shows an output of this.
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

In the future, I want src/dst IP(v6) address filter option. 
It's now under consideration/construction.

For example, if you want to show a process of received packets associated
with eth3,

#perf trace report netdev-times rx dev=eth3
79074.756672832sec cpu=1
irq_entry(+0.000000msec,irq=77:eth3)
         |------------softirq_raise(+0.001277msec)
irq_exit (+0.002278msec)     |
                             |
                      softirq_entry(+0.003562msec)
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
 tools/perf/scripts/python/bin/netdev-times-record |    7 +
 tools/perf/scripts/python/bin/netdev-times-report |    5 +
 tools/perf/scripts/python/netdev-times.py         |  495 +++++++++++++++++++++
 3 files changed, 507 insertions(+), 0 deletions(-)

diff --git a/tools/perf/scripts/python/bin/netdev-times-record b/tools/perf/scripts/python/bin/netdev-times-record
new file mode 100644
index 0000000..1dfa8d5
--- /dev/null
+++ b/tools/perf/scripts/python/bin/netdev-times-record
@@ -0,0 +1,7 @@
+#!/bin/bash
+perf record -c 1 -f -R -a -e net:net_dev_xmit -e net:net_dev_queue	\
+		-e net:net_dev_receive -e skb:consume_skb		\
+		-e skb:dev_kfree_skb_irq -e napi:napi_poll		\
+		-e irq:irq_handler_entry -e irq:irq_handler_exit	\
+		-e irq:softirq_entry -e irq:softirq_exit		\
+		-e irq:softirq_raise -e skb:skb_copy_datagram_iovec $@
diff --git a/tools/perf/scripts/python/bin/netdev-times-report b/tools/perf/scripts/python/bin/netdev-times-report
new file mode 100644
index 0000000..ecc8122
--- /dev/null
+++ b/tools/perf/scripts/python/bin/netdev-times-report
@@ -0,0 +1,5 @@
+#!/bin/bash
+# description: displayi a process of packet and processing time
+# args: tx rx dev src dst
+
+perf trace -s ~/libexec/perf-core/scripts/python/netdev-times.py $@
diff --git a/tools/perf/scripts/python/netdev-times.py b/tools/perf/scripts/python/netdev-times.py
new file mode 100644
index 0000000..5e68be4
--- /dev/null
+++ b/tools/perf/scripts/python/netdev-times.py
@@ -0,0 +1,495 @@
+# Display process of packets and processed time.
+# It helps you to investigate networking.
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
+receive_skb_list = []; # received packet list for matching
+		       # skb_copy_datagram_iovec
+
+queue_list = []; # list of packets which pass through dev_queue_xmit
+xmit_list = [];  # list of packets which pass through dev_hard_start_xmit
+free_list = [];  # list of packets which is freed
+
+show_tx = 0;
+show_rx = 0;
+dev = 0; # store a name of device specified by option "dev="
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
+# Display a process of received packets and interrputs associated with
+# a NET_RX softirq
+def print_receive(hunk):
+	show_hunk = 0
+	if 'irq_list' not in hunk.keys() \
+	or len(hunk['irq_list']) == 0:
+		return
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
+		print "irq_entry(+%fmsec,irq=%d:%s)" % \
+			(diff_msec(base_t, irq_list[i]['irq_ent_t']),
+			irq_list[i]['irq'], irq_list[i]['name'])
+
+		if 'sirq_raise_t' in irq_list[i].keys():
+			print "         |------------" \
+			      "softirq_raise(+%fmsec)" % \
+				diff_msec(base_t, irq_list[i]['sirq_raise_t'])
+
+		if 'irq_ext_t' in irq_list[i].keys():
+			print "irq_exit (+%fmsec)     |" % \
+				diff_msec(base_t, irq_list[i]['irq_ext_t'])
+
+		print "                             |"
+
+	if 'sirq_ent_t' not in hunk.keys():
+		print 'maybe softirq_entry is dropped'
+		return
+	print "                      " \
+		"softirq_entry(+%fmsec)\n" \
+		"                      " \
+		"       |" % \
+		diff_msec(base_t, hunk['sirq_ent_t'])
+	event_list = hunk['event_list']
+	for i in range(len(event_list)):
+		event = event_list[i]
+		if event['event_name'] == 'napi_poll':
+			print "                      " \
+			      "napi_poll_exit(+%fmsec, %s)" % \
+			(diff_msec(base_t, event['event_t']), event['dev'])
+			print "                      " \
+			      "       |"
+		elif 'comm' in event.keys():
+			print "                      " \
+				"       |---netif_receive_skb" \
+				"(+%fmsec,len=%d)\n" \
+				"                      " \
+				"       |            |\n" \
+				"                      " \
+				"       |   skb_copy_datagram_iovec" \
+				"(+%fmsec, %d:%s)\n" \
+				"                      " \
+				"       |" % \
+			(diff_msec(base_t, event['event_t']),
+			event['len'],
+			diff_msec(base_t, event['comm_t']),
+			event['pid'], event['comm'])
+		else:
+			print "                      " \
+				"       |---netif_receive_skb" \
+				"(+%fmsec,len=%d)\n" \
+				"                      " \
+				"       |" % \
+				(diff_msec(base_t, event['event_t']),
+					event['len'])
+
+	print "                      " \
+	      "softirq_exit(+%fmsec)\n" % \
+		 diff_msec(base_t, hunk['sirq_ext_t'])
+
+def trace_begin():
+	global show_tx
+	global show_rx
+	global dev
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
+	if show_tx == 0  and show_rx == 0:
+		show_tx = 1
+		show_rx = 1
+
+def trace_end():
+	global show_tx
+	global show_rx
+	# order all events in time
+	all_event_list.sort(lambda a,b :cmp(a['time'], b['time']))
+	# process all events
+	for i in range(len(all_event_list)):
+		event = all_event_list[i]
+		event_name = event['event_name']
+		if event_name == 'irq__softirq_exit':
+			handle_irq_softirq_exit(event['event_name'],
+				event['context'], event['common_cpu'],
+				event['common_pid'], event['common_comm'],
+				event['time'], event['vec'])
+		elif event_name == 'irq__softirq_entry':
+			handle_irq_softirq_entry(event['event_name'],
+				event['context'], event['common_cpu'],
+				event['common_pid'], event['common_comm'],
+				event['time'],event['vec'])
+		elif event_name == 'irq__softirq_raise':
+			handle_irq_softirq_raise(event['event_name'],
+				event['context'], event['common_cpu'],
+				event['common_pid'], event['common_comm'],
+				event['time'], event['vec'])
+		elif event_name == 'irq__irq_handler_entry':
+			handle_irq_handler_entry(event['event_name'],
+				event['context'], event['common_cpu'],
+				event['common_pid'], event['common_comm'],
+				event['time'], event['irq'], event['name'])
+		elif event_name == 'irq__irq_handler_exit':
+			handle_irq_handler_exit(event['event_name'],
+				event['context'], event['common_cpu'],
+				event['common_pid'], event['common_comm'],
+				event['time'], event['irq'], event['ret'])
+		elif event_name == 'napi__napi_poll':
+			handle_napi_poll(event['event_name'],
+				event['context'], event['common_cpu'],
+				event['common_pid'], event['common_comm'],
+				event['time'], event['napi'],
+				event['dev_name'])
+		elif event_name == 'net__net_dev_receive':
+			handle_net_dev_receive(event['event_name'],
+				event['context'], event['common_cpu'],
+				event['common_pid'], event['common_comm'],
+				event['time'], event['skbaddr'],
+				event['skblen'], event['name'])
+		elif event_name == 'skb__skb_copy_datagram_iovec':
+			handle_skb_copy_datagram_iovec(event['event_name'],
+				event['context'], event['common_cpu'],
+				event['common_pid'], event['common_comm'],
+				event['time'], event['skbaddr'],
+				event['skblen'])
+		elif event_name == 'net__net_dev_queue':
+			handle_net_dev_queue(event['event_name'],
+				event['context'], event['common_cpu'],
+				event['common_pid'], event['common_comm'],
+				event['time'], event['skbaddr'],
+				event['skblen'], event['name'])
+		elif event_name == 'net__net_dev_xmit':
+			handle_net_dev_xmit(event['event_name'],
+				event['context'], event['common_cpu'],
+				event['common_pid'], event['common_comm'],
+				event['time'], event['skbaddr'],
+				event['skblen'], event['rc'], event['name'])
+		elif event_name == 'skb__dev_kfree_skb_irq':
+			handle_dev_kfree_skb_irq(event['event_name'],
+				event['context'], event['common_cpu'],
+				event['common_pid'], event['common_comm'],
+				event['time'], event['skbaddr'])
+		elif event_name == 'skb__consume_skb':
+			handle_consume_skb(event['event_name'],
+				event['context'], event['common_cpu'],
+				event['common_pid'], event['common_comm'],
+				event['time'], event['skbaddr'])
+	# display receive hunks
+	if show_rx == 1:
+		for i in range(len(receive_hunk_list)):
+			print_receive(receive_hunk_list[i])
+	# display transmit hunks
+	if show_tx == 1:
+		print "   dev    len      dev_queue_xmit|----------|" \
+			"dev_hard_start_xmit|-----|free_skb"
+		print "                         |             |" \
+			"                           |"
+		for i in range(len(free_list)):
+			print_transmit(free_list[i])
+
+def irq__softirq_exit(event_name, context, common_cpu,
+	common_secs, common_nsecs, common_pid, common_comm,
+	vec):
+	if symbol_str("irq__softirq_entry", "vec", vec) != "NET_RX":
+		return
+	event_data = {'event_name':event_name, 'context':context,
+		'common_cpu':common_cpu, 'common_pid':common_pid,
+		'common_comm':common_comm,'time':nsecs(common_secs,
+							common_nsecs),
+		'vec':vec}
+	all_event_list.append(event_data)
+
+def handle_irq_softirq_exit(event_name, context, common_cpu,
+	common_pid, common_comm, time,
+	vec):
+	rec_data = {'sirq_ext_t':time}
+	if common_cpu in irq_dic.keys():
+		rec_data.update({'irq_list':irq_dic[common_cpu]})
+		del irq_dic[common_cpu]
+	if common_cpu in net_rx_dic.keys():
+		rec_data.update({
+		    'event_list':net_rx_dic[common_cpu]['event_list'],
+		    'sirq_ent_t':net_rx_dic[common_cpu]['sirq_ent_t']})
+		del net_rx_dic[common_cpu]
+	# merge information realted to a NET_RX softirq
+	receive_hunk_list.append(rec_data)
+
+def irq__softirq_entry(event_name, context, common_cpu,
+	common_secs, common_nsecs, common_pid, common_comm,
+	vec):
+	if symbol_str("irq__softirq_entry", "vec", vec) != "NET_RX":
+		return
+	event_data = {'event_name':event_name, 'context':context,
+		'common_cpu':common_cpu, 'common_pid':common_pid,
+		'common_comm':common_comm,'time':nsecs(common_secs,
+							common_nsecs),
+		'vec':vec}
+	all_event_list.append(event_data)
+
+def handle_irq_softirq_entry(event_name, context, common_cpu,
+	common_pid, common_comm, time,
+	vec):
+		net_rx_dic[common_cpu] = {'event_list':[],
+					  'sirq_ent_t':time}
+
+def irq__softirq_raise(event_name, context, common_cpu,
+	common_secs, common_nsecs, common_pid, common_comm,
+	vec):
+	if symbol_str("irq__softirq_entry", "vec", vec) != "NET_RX":
+		return
+	event_data = {'event_name':event_name, 'context':context,
+		'common_cpu':common_cpu, 'common_pid':common_pid,
+		'common_comm':common_comm,'time':nsecs(common_secs,
+							common_nsecs),
+		'vec':vec}
+	all_event_list.append(event_data)
+
+def handle_irq_softirq_raise(event_name, context, common_cpu,
+	common_pid, common_comm, time,
+	vec):
+	if common_cpu not in irq_dic.keys() \
+	or len(irq_dic[common_cpu]) == 0:
+		return
+	irq = irq_dic[common_cpu].pop()
+	# put a time to prev irq on the same cpu
+	irq.update({'sirq_raise_t':time})
+	irq_dic[common_cpu].append(irq)
+
+def irq__irq_handler_entry(event_name, context, common_cpu,
+	common_secs, common_nsecs, common_pid, common_comm,
+	irq, name):
+	event_data = {'event_name':event_name, 'context':context,
+		'common_cpu':common_cpu, 'common_pid':common_pid,
+		'common_comm':common_comm,'time':nsecs(common_secs,
+							common_nsecs),
+		'irq':irq, 'name':name}
+	all_event_list.append(event_data)
+
+def handle_irq_handler_entry(event_name, context, common_cpu,
+	common_pid, common_comm, time,
+	irq, name):
+	if common_cpu not in irq_dic.keys():
+		irq_dic[common_cpu] = []
+	irq_record = {'irq':irq,
+		      'name':name,
+		      'cpu':common_cpu,
+		      'irq_ent_t':time}
+	irq_dic[common_cpu].append(irq_record)
+
+def irq__irq_handler_exit(event_name, context, common_cpu,
+	common_secs, common_nsecs, common_pid, common_comm,
+	irq, ret):
+	event_data = {'event_name':event_name, 'context':context,
+		'common_cpu':common_cpu, 'common_pid':common_pid,
+		'common_comm':common_comm,'time':nsecs(common_secs,
+							common_nsecs),
+		'irq':irq, 'ret':ret}
+	all_event_list.append(event_data)
+
+def handle_irq_handler_exit(event_name, context, common_cpu,
+	common_pid, common_comm, time,
+	irq, ret):
+	if common_cpu not in irq_dic.keys():
+		return
+	irq_record = irq_dic[common_cpu].pop()
+	irq_record.update({'irq_ext_t':time})
+	# if an irq doesn't include NET_RX softirq, drop.
+	if 'sirq_raise_t' in irq_record.keys():
+		irq_dic[common_cpu].append(irq_record)
+
+def napi__napi_poll(event_name, context, common_cpu,
+	common_secs, common_nsecs, common_pid, common_comm,
+	napi, dev_name):
+	event_data = {'event_name':event_name, 'context':context,
+		'common_cpu':common_cpu, 'common_pid':common_pid,
+		'common_comm':common_comm,'time':nsecs(common_secs,
+							common_nsecs),
+		'napi':napi, 'dev_name':dev_name}
+	all_event_list.append(event_data)
+
+def handle_napi_poll(event_name, context, common_cpu,
+	common_pid, common_comm, time,
+	napi, dev_name):
+	if common_cpu in net_rx_dic.keys():
+		event_list = net_rx_dic[common_cpu]['event_list']
+		rec_data = {'event_name':'napi_poll',
+			    'dev':dev_name,
+			    'event_t':time}
+		event_list.append(rec_data)
+
+def net__net_dev_receive(event_name, context, common_cpu,
+	common_secs, common_nsecs, common_pid, common_comm,
+	skbaddr,skblen, name):
+	event_data = {'event_name':event_name, 'context':context,
+		'common_cpu':common_cpu, 'common_pid':common_pid,
+		'common_comm':common_comm,'time':nsecs(common_secs,
+							common_nsecs),
+		'skbaddr':skbaddr, 'skblen':skblen, 'name':name}
+	all_event_list.append(event_data)
+
+def handle_net_dev_receive(event_name, context, common_cpu,
+	ccommon_pid, common_comm, time,
+	skbaddr, skblen, name):
+	if common_cpu in net_rx_dic.keys():
+		rec_data = {'event_name':'netif_receive_skb',
+			    'event_t':time,
+			    'skbaddr':skbaddr,
+			    'len':skblen}
+		event_list = net_rx_dic[common_cpu]['event_list']
+		event_list.append(rec_data)
+		receive_skb_list.insert(0, rec_data)
+
+def skb__skb_copy_datagram_iovec(event_name, context, common_cpu,
+	common_secs, common_nsecs, common_pid, common_comm,
+	skbaddr, skblen):
+	event_data = {'event_name':event_name, 'context':context,
+		'common_cpu':common_cpu, 'common_pid':common_pid,
+		'common_comm':common_comm,'time':nsecs(common_secs,
+							common_nsecs),
+		'skbaddr':skbaddr, 'skblen':skblen}
+	all_event_list.append(event_data)
+
+def handle_skb_copy_datagram_iovec(event_name, context, common_cpu,
+	common_pid, common_comm, time,
+	skbaddr, skblen):
+	for i in range(len(receive_skb_list)):
+		rec_data = receive_skb_list[i]
+		if skbaddr == rec_data['skbaddr'] and \
+			'comm' not in rec_data.keys():
+			rec_data.update({'comm':common_comm,
+					 'pid':common_pid,
+					 'comm_t':time})
+			del receive_skb_list[i]
+			break
+
+def net__net_dev_queue(event_name, context, common_cpu,
+	common_secs, common_nsecs, common_pid, common_comm,
+	skbaddr, skblen, name):
+	event_data = {'event_name':event_name, 'context':context,
+		'common_cpu':common_cpu, 'common_pid':common_pid,
+		'common_comm':common_comm,'time':nsecs(common_secs,
+							common_nsecs),
+		'skbaddr':skbaddr, 'skblen':skblen, 'name':name}
+	all_event_list.append(event_data)
+
+def handle_net_dev_queue(event_name, context, common_cpu,
+	common_pid, common_comm, time,
+	skbaddr, skblen, name):
+	skb = {'dev':name,
+	       'skbaddr':skbaddr,
+	       'len':skblen,
+	       'queue_t':time}
+	xmit_list.insert(0, skb)
+
+def net__net_dev_xmit(event_name, context, common_cpu,
+	common_secs, common_nsecs, common_pid, common_comm,
+	skbaddr, skblen, rc, name):
+	event_data = {'event_name':event_name, 'context':context,
+		'common_cpu':common_cpu, 'common_pid':common_pid,
+		'common_comm':common_comm,'time':nsecs(common_secs,
+							common_nsecs),
+		'skbaddr':skbaddr, 'skblen':skblen, 'rc':rc, 'name':name}
+	all_event_list.append(event_data)
+
+def handle_net_dev_xmit(event_name, context, common_cpu,
+	common_pid, common_comm, time,
+	skbaddr, skblen, rc, name):
+	if rc == 0: # NETDEV_TX_OK
+		for i in range(len(xmit_list)):
+			skb = xmit_list[i]
+			if skb['skbaddr'] == skbaddr:
+				skb['xmit_t'] = time
+				queue_list.insert(0, skb)
+				del xmit_list[i]
+				break
+
+def free_skb(event_name, context, common_cpu,
+	common_pid, common_comm, time,
+	skbaddr):
+	for i in range(len(queue_list)):
+		skb = queue_list[i]
+		if skb['skbaddr'] ==skbaddr:
+			skb['free_t'] = time
+			free_list.append(skb)
+			del queue_list[i]
+			break
+
+def skb__dev_kfree_skb_irq(event_name, context, common_cpu,
+	common_secs, common_nsecs, common_pid, common_comm,
+	skbaddr):
+	event_data = {'event_name':event_name, 'context':context,
+		'common_cpu':common_cpu, 'common_pid':common_pid,
+		'common_comm':common_comm,'time':nsecs(common_secs,
+							common_nsecs),
+		'skbaddr':skbaddr}
+	all_event_list.append(event_data)
+
+def handle_dev_kfree_skb_irq(event_name, context, common_cpu,
+	common_pid, common_comm, time,
+	skbaddr):
+	free_skb(event_name, context, common_cpu,
+		common_pid, common_comm, time,
+		skbaddr)
+
+def skb__consume_skb(event_name, context, common_cpu,
+	common_secs, common_nsecs, common_pid, common_comm,
+	skbaddr):
+	event_data = {'event_name':event_name, 'context':context,
+		'common_cpu':common_cpu, 'common_pid':common_pid,
+		'common_comm':common_comm,'time':nsecs(common_secs,
+							common_nsecs),
+		'skbaddr':skbaddr}
+	all_event_list.append(event_data)
+
+def handle_consume_skb(event_name, context, common_cpu,
+	common_pid, common_comm, time,
+	skbaddr):
+	free_skb(event_name, context, common_cpu,
+		common_pid, common_comm, time,
+		skbaddr)

