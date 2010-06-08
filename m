From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: [RFC PATCH 5/5] perf:add a script shows a process of packet
Date: Tue, 08 Jun 2010 14:31:46 +0900
Message-ID: <4C0DD5C2.4080809@jp.fujitsu.com>
References: <4C0DD43F.9090902@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kaneshige.kenji@jp.fujitsu.com,
	izumi.taku@jp.fujitsu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail7.fujitsu.co.jp ([192.51.44.37]:57819 "EHLO
	fgwmail7.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751571Ab0FHFbh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 01:31:37 -0400
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o585VZl9019379
	for <netdev@vger.kernel.org> (envelope-from sanagi.koki@jp.fujitsu.com);
	Tue, 8 Jun 2010 14:31:35 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 72E5845DE56
	for <netdev@vger.kernel.org>; Tue,  8 Jun 2010 14:31:35 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5569445DE51
	for <netdev@vger.kernel.org>; Tue,  8 Jun 2010 14:31:35 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2959D1DB8014
	for <netdev@vger.kernel.org>; Tue,  8 Jun 2010 14:31:35 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 96ADF1DB801B
	for <netdev@vger.kernel.org>; Tue,  8 Jun 2010 14:31:34 +0900 (JST)
In-Reply-To: <4C0DD43F.9090902@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This perf script show a time-chart of process of packet.
If you want to use it, install perf and

#perf trace record netdev-times

And if you want a result,

#perf trace report netdev-times

Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
---
 tools/perf/scripts/python/bin/netdev-times-record |    7 +
 tools/perf/scripts/python/bin/netdev-times-report |   10 +
 tools/perf/scripts/python/netdev-times.py         |  451 +++++++++++++++++++++
 3 files changed, 468 insertions(+), 0 deletions(-)

diff --git a/tools/perf/scripts/python/bin/netdev-times-record b/tools/perf/scripts/python/bin/netdev-times-record
new file mode 100644
index 0000000..c6a54fd
--- /dev/null
+++ b/tools/perf/scripts/python/bin/netdev-times-record
@@ -0,0 +1,7 @@
+#!/bin/bash
+perf record -c 1 -f -R -a -e net:net_dev_xmit -e net:net_dev_queue	\
+		-e net:net_dev_receive -e skb:consume_skb		\
+		-e skb:dev_kfree_skb_irq -e napi:napi_poll		\
+		-e irq:irq_handler_entry -e irq:irq_handler_exit	\
+		-e irq:softirq_entry -e irq:softirq_exit		\
+		-e irq:softirq_raise -e skb:skb_copy_datagram_iovec
diff --git a/tools/perf/scripts/python/bin/netdev-times-report b/tools/perf/scripts/python/bin/netdev-times-report
new file mode 100644
index 0000000..5d24c3d
--- /dev/null
+++ b/tools/perf/scripts/python/bin/netdev-times-report
@@ -0,0 +1,10 @@
+#!/bin/bash
+# description: displayi a process of packet and processing time
+# args: [comm]
+if [ $# -gt 0 ] ; then
+    if ! expr match "$1" "-" > /dev/null ; then
+	comm=$1
+	shift
+    fi
+fi
+perf trace $@ -s ~/libexec/perf-core/scripts/python/netdev-times.py $comm
diff --git a/tools/perf/scripts/python/netdev-times.py b/tools/perf/scripts/python/netdev-times.py
new file mode 100644
index 0000000..e7b47c7
--- /dev/null
+++ b/tools/perf/scripts/python/netdev-times.py
@@ -0,0 +1,451 @@
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
+# Calculate a time interval(msec) from src(nsec) to dst(nsec)
+def diff_msec(src, dst):
+	return (dst - src) / 1000000.0
+
+# Display a process of transmitting a packet
+def print_transmit(hunk):
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
+	if 'irq_list' not in hunk.keys() \
+	or len(hunk['irq_list']) == 0:
+		return
+	irq_list = hunk['irq_list']
+	cpu = irq_list[0]['cpu']
+	base_t = irq_list[0]['irq_ent_t']
+	print "%d.%09dsec cpu=%d" % \
+		(nsecs_secs(base_t), nsecs_nsecs(base_t), cpu)
+	for i in range(len(irq_list)):
+		print "irq_entry(+%fmsec,irq=%d:%s)" % \
+			(diff_msec(base_t, irq_list[i]['irq_ent_t']),
+			irq_list[i]['irq'], irq_list[i]['name'])
+
+		print "         |------------" \
+		      "softirq_raise(+%fmsec)" % \
+			diff_msec(base_t, irq_list[i]['sirq_raise_t'])
+
+		print "irq_exit (+%fmsec)     |" % \
+			diff_msec(base_t, irq_list[i]['irq_ext_t'])
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
+def trace_end():
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
+	for i in range(len(receive_hunk_list)):
+		print_receive(receive_hunk_list[i])
+	# display transmit hunks
+	print "   dev    len      dev_queue_xmit|----------|" \
+		"dev_hard_start_xmit|-----|free_skb"
+	print "                         |             |" \
+		"                           |"
+	for i in range(len(free_list)):
+		print_transmit(free_list[i])
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

