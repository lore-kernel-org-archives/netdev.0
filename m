From: Martin KaFai Lau <kafai@fb.com>
Subject: [RFC PATCH net-next 2/5] tcp: A perf script for TCP tracepoints
Date: Sun, 14 Dec 2014 17:56:43 -0800
Message-ID: <1418608606-1569264-3-git-send-email-kafai@fb.com>
References: <1418608606-1569264-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Lawrence Brakmo <brakmo@fb.com>, Josef Bacik <jbacik@fb.com>,
	Kernel Team <Kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:14513 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750854AbaLOB5d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Dec 2014 20:57:33 -0500
Received: from pps.filterd (m0004003 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id sBF1rpSx012991
	for <netdev@vger.kernel.org>; Sun, 14 Dec 2014 17:57:32 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1r9b7vstnx-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Sun, 14 Dec 2014 17:57:12 -0800
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 acac9f5483fd11e4995a24be05956610-8d7d5390 for <netdev@vger.kernel.org>;	Sun,
 14 Dec 2014 17:57:07 -0800
In-Reply-To: <1418608606-1569264-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A sample perf script.  It has a simple ip/port filtering and a summary output.

Here is a test with netem delay 100ms loss 0.1% and comparing the tcp-summary
output between reno and cubic.  It was run in a kvm environment:

[root@qemu1-centos65 perf]# sysctl -w net.ipv4.tcp_congestion_control=reno
net.ipv4.tcp_congestion_control = reno
[root@qemu1-centos65 perf]# ./perf record -a -e 'tcp:*' netperf -c -C -H 192.168.168.254 -l 60 -p 8888 -- -s 1M -S 1M -m 64K -P ,8889
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.168.254 () port 8889 AF_INET
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

2097152 425984  65536    60.78         2.91   0.00     0.86     0.000   771.397
[ perf record: Woken up 13 times to write data ]
[ perf record: Captured and wrote 3.231 MB perf.data (~141185 samples) ]
[root@qemu1 perf]# PYTHONPATH="$PYTHONPATH:/root/devhostshare/fb-kernel/linux/tools/perf/scripts/python/Perf-Trace-Util/lib/Perf/Trace" ./perf script -s scripts/python/tcp-summary.py  -- --rport 8889
snd_cwnd(avg/min/max): 27/8/47
segs out: 15290
data segs out: 15275
octets out: 22116754
loss rxmits: 0
other rxmits: 13
rxmits%: 0.085
dup_acks: 402
established: 1
close: 1

[root@qemu1 perf]# sysctl -w net.ipv4.tcp_congestion_control=cubic
net.ipv4.tcp_congestion_control = cubic
[root@qemu1 perf]# ./perf record -a -e 'tcp:*' netperf -c -C -H 192.168.168.254 -l 60 -p 8888 -- -s 1M -S 1M -m 64K -P ,8889
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.168.254 () port 8889 AF_INET
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

2097152 425984  65536    60.25         4.97   0.02     0.86     1.096   454.051
[ perf record: Woken up 21 times to write data ]
[ perf record: Captured and wrote 5.525 MB perf.data (~241393 samples) ]
[root@qemu1 perf]# PYTHONPATH="$PYTHONPATH:/root/devhostshare/fb-kernel/linux/tools/perf/scripts/python/Perf-Trace-Util/lib/Perf/Trace" ./perf script -s scripts/python/tcp-summary.py  -- --rport 8889
snd_cwnd(avg/min/max): 47/10/78
segs out: 25869
data segs out: 25848
octets out: 37426458
loss rxmits: 0
other rxmits: 19
rxmits%: 0.074
dup_acks: 957
established: 1
close: 1

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 tools/perf/scripts/python/tcp-summary.py | 262 +++++++++++++++++++++++++++++++
 1 file changed, 262 insertions(+)
 create mode 100644 tools/perf/scripts/python/tcp-summary.py

diff --git a/tools/perf/scripts/python/tcp-summary.py b/tools/perf/scripts/python/tcp-summary.py
new file mode 100644
index 0000000..fe85a43
--- /dev/null
+++ b/tools/perf/scripts/python/tcp-summary.py
@@ -0,0 +1,262 @@
+import os
+import sys
+import argparse
+import struct
+import socket
+
+sys.path.append(os.environ['PERF_EXEC_PATH'] + \
+	'/scripts/python/Perf-Trace-Util/lib/Perf/Trace')
+
+from perf_trace_context import *
+from Core import *
+
+def ntohip(nip):
+	hip = 0L
+	for i in nip:
+		hip <<= 8
+		hip |= i
+	return hip
+
+def unpack_nip(nip_in_c):
+	fmt = "!" + "B" * len(nip_in_c)
+	return struct.unpack(fmt, nip_in_c)
+
+def unpack_and_hostify_sa(laddr, lport, raddr, rport):
+	return (ntohip(unpack_nip(laddr)), socket.ntohs(lport),
+		ntohip(unpack_nip(raddr)), socket.ntohs(rport))
+
+class SimpleSubnet(object):
+	def _parse_ip4(self):
+		hip = 0L
+		dec_u8 = self.ip_str.split(".")
+		for i in dec_u8:
+			hip = hip << 8
+			hip |= long(i)
+		self.hip = hip
+
+	def _parse_ip6(self):
+		hip = 0L;
+		hex_u16	 = self.ip_str.split(":")
+		if self.ip_str.endswith("::"):
+			if hex_u16.count("") > 2:
+				raise Exception("Error in parsing IPv6")
+			cpz_zeros = 8 - len(hex_u16) + 2
+			hex_u16 = hex_u16[:-1]
+		elif "" in hex_u16:
+			if hex_u16.count("") > 1:
+				raise Exception("Error in parsing IPv6")
+			cpz_zeros = 8 - len(hex_u16) + 1
+		for i in hex_u16:
+			if len(i) == 0:
+				for j in range(cpz_zeros):
+					hip = hip << 16
+			else:
+				hip = hip << 16;
+				hip |= long(i, 16)
+		self.hip = hip
+
+	def _parse_ip(self, ip_str):
+		slash_start = ip_str.find("/")
+		if slash_start == -1:
+			self.ip_str = ip_str
+			self.plen = 0
+		else:
+			self.ip_str = ip_str[0:slash_start]
+			self.plen = int(ip_str[slash_start+1:])
+
+		if ':' in self.ip_str:
+			self._parse_ip6()
+			self.is_ip6 = True
+			if self.plen == 0:
+				self.plen = 128
+			self.netmask = 0xffffffffffffffffffffffffffffffffL >> (128 - self.plen) << (128 - self.plen)
+		else:
+			self._parse_ip4()
+			self.is_ip6 = False
+			if self.plen == 0:
+				self.plen = 32
+			self.netmask = 0xffffffffL >> (32 - self.plen) << (32 - self.plen)
+
+	def _min_ip(self):
+		return self.hip & self.netmask
+
+	def _max_ip(self):
+		if self.is_ip6:
+			return self._min_ip() | (0xffffffffffffffffffffffffffffffffL - self.netmask)
+		else:
+			return self._min_ip() | (0xffffffffL - self.netmask)
+
+	def __contains__(self, hip):
+		return self._min_ip() <= hip <= self._max_ip()
+
+	def __init__(self, ip_str):
+		self._parse_ip(ip_str)
+
+class SimpleFilter(object):
+	def __init__(self, lsn, lhport, rsn, rhport):
+		self.lsn = lsn
+		self.rsn = rsn
+		self.lhport = lhport
+		self.rhport = rhport
+
+	def match(self, lhip, lhport, rhip, rhport):
+		if self.lsn and lhip not in self.lsn:
+			return False
+		if self.rsn and rhip not in self.rsn:
+			return False
+		if self.lhport and self.lhport != lhport:
+			return False
+		if self.rhport and self.rhport != rhport:
+			return False
+
+		return True
+
+class TcpSummary(object):
+	def __init__(self):
+		self.snd_cwnd_sum = 0
+		self.snd_cwnd_count = 0
+		self.max_snd_cwnd = 0
+		self.min_snd_cwnd = 0xffffffff
+		self.segs_out = 0
+		self.data_segs_out = 0
+		self.data_octets_out = 0
+		self.loss_rxmits = 0
+		self.other_rxmits = 0
+		self.dup_acks = 0
+		self.established = 0
+		self.close = 0
+
+	def add_loss_rxmits(self, n):
+		self.loss_rxmits += n
+
+	def add_other_rxmits(self, n):
+		self.other_rxmits += n
+
+	def add_segs_out(self, n):
+		self.segs_out += n
+
+	def add_data_segs_out(self, n):
+		self.data_segs_out += n
+
+	def add_data_octets_out(self, n):
+		self.data_octets_out += n
+
+	def add_snd_cwnd_sample(self, n):
+		self.snd_cwnd_sum += n
+		self.snd_cwnd_count += 1
+		self.min_snd_cwnd = min(self.min_snd_cwnd, n)
+		self.max_snd_cwnd = max(self.max_snd_cwnd, n)
+
+	def inc_dup_acks(self):
+		self.dup_acks += 1
+
+	def inc_established(self):
+		self.established += 1
+
+	def inc_close(self):
+		self.close += 1
+
+	def report(self):
+		if self.snd_cwnd_count == 0:
+			avg_cwnd = 0
+			min_snd_cwnd = 0
+		else:
+			avg_cwnd = self.snd_cwnd_sum / self.snd_cwnd_count
+			min_snd_cwnd = self.min_snd_cwnd
+		rxmit_rate = (self.loss_rxmits + self.other_rxmits) * 100.0 / \
+			     self.data_segs_out if self.data_segs_out else 0
+		print "snd_cwnd(avg/min/max): %u/%u/%u" % (avg_cwnd,
+							   min_snd_cwnd,
+							   self.max_snd_cwnd)
+		print "segs out: %u" % self.segs_out
+		print "data segs out: %u" % self.data_segs_out
+		print "octets out: %u" % self.data_octets_out
+		print "loss rxmits: %u" % self.loss_rxmits
+		print "other rxmits: %u" % self.other_rxmits
+		print "rxmits%%: %.3f" % rxmit_rate
+		print "dup_acks: %u" % self.dup_acks
+		print "established: %u" % self.established
+		print "close: %u" % self.close
+
+parser = argparse.ArgumentParser()
+parser.add_argument("--laddr", help="Local address in IP[/prefix-len]")
+parser.add_argument("--raddr", help="Remote address in IP[/prefix-len]")
+parser.add_argument("--lport", type=int, default=0, help="Local port")
+parser.add_argument("--rport", type=int, default=0, help="Remote port")
+args = parser.parse_args()
+lsn = SimpleSubnet(args.laddr) if args.laddr else None
+rsn = SimpleSubnet(args.raddr) if args.raddr else None
+addr_filter = SimpleFilter(lsn, args.lport, rsn, args.rport)
+tcp_summary = TcpSummary()
+
+def trace_begin():
+	pass
+
+def trace_end():
+	tcp_summary.report();
+
+def tcp__tcp_transmit_skb(event_name, context, common_cpu,
+	common_secs, common_nsecs, common_pid, common_comm,
+	common_callchain, ipv6, laddr, raddr, lport,
+	rport, seq, end_seq, pcount, ca_state,
+	snd_nxt, snd_una, snd_wnd, snd_cwnd, mss_cache,
+	ssthresh, srtt_us, rto_ms):
+
+	if not addr_filter.match(*unpack_and_hostify_sa(laddr, lport,
+							raddr, rport)):
+		return
+
+	tcp_summary.add_segs_out(pcount)
+	if end_seq > seq:
+		tcp_summary.add_snd_cwnd_sample(snd_cwnd)
+		if seq < snd_nxt:
+			if ca_state == 4:
+				tcp_summary.add_loss_rxmits(pcount)
+			else:
+				tcp_summary.add_other_rxmits(pcount)
+		else:
+			tcp_summary.add_data_segs_out(pcount)
+			tcp_summary.add_data_octets_out(end_seq - seq)
+
+def tcp__tcp_rcv_established(event_name, context, common_cpu,
+	common_secs, common_nsecs, common_pid, common_comm,
+	common_callchain, ipv6, laddr, raddr, lport,
+	rport, seq, end_seq, ack_seq, snd_una,
+	rcv_nxt, rcv_wnd):
+	if not addr_filter.match(*unpack_and_hostify_sa(laddr, lport,
+							raddr, rport)):
+		return
+
+	if seq == end_seq and ack_seq == snd_una:
+		tcp_summary.inc_dup_acks()
+
+def tcp__tcp_established(event_name, context, common_cpu,
+	common_secs, common_nsecs, common_pid, common_comm,
+	common_callchain, ipv6, laddr, raddr, lport,
+	rport, snd_cwnd, mss_cache, ssthresh, srtt_us,
+	rto_ms):
+
+	if not addr_filter.match(*unpack_and_hostify_sa(laddr, lport,
+							raddr, rport)):
+		return
+
+	tcp_summary.inc_established()
+
+def tcp__tcp_close(event_name, context, common_cpu,
+	common_secs, common_nsecs, common_pid, common_comm,
+	common_callchain, ipv6, laddr, raddr, lport,
+	rport, snd_cwnd, mss_cache, ssthresh, srtt_us,
+	rto_ms):
+
+	if not addr_filter.match(*unpack_and_hostify_sa(laddr, lport,
+							raddr, rport)):
+		return
+
+	tcp_summary.inc_close()
+
+def trace_unhandled(event_name, context, event_fields_dict):
+	print ' '.join(['%s=%s'%(k,str(v))for k,v in sorted(event_fields_dict.items())])
+
+def print_header(event_name, cpu, secs, nsecs, pid, comm):
+	print "%-20s %5u %05u.%09u %8u %-20s " % \
+	(event_name, cpu, secs, nsecs, pid, comm),
-- 
1.8.1
