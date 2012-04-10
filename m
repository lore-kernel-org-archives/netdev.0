From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH 2/2] tools: virtio: add a top-like utility for displaying
	vhost satistics
Date: Tue, 10 Apr 2012 10:58:29 +0800
Message-ID: <20120410025828.49693.70686.stgit@amd-6168-8-1.englab.nay.redhat.com>
References: <20120410025327.49693.93562.stgit@amd-6168-8-1.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org, mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20120410025327.49693.93562.stgit@amd-6168-8-1.englab.nay.redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

This patch adds simple python to display vhost satistics of vhost, the codes
were based on kvm_stat script from qemu. As work function has been recored,
filters could be used to distinguish which kinds of work are being executed or
queued:

vhost statistics

 vhost_virtio_get_vq_desc                   1460997  219682
 vhost_work_execute_start                    101248   12842
 vhost_work_execute_end                      101247   12842
 vhost_work_queue_wakeup                     101263   12841
 vhost_virtio_signal                          68452    8659
 vhost_work_queue_wakeup(rx_net)              51797    6584
 vhost_work_execute_start(rx_net)             51795    6584
 vhost_work_queue_coalesce                    35737    6571
 vhost_work_queue_coalesce(rx_net)            35709    6566
 vhost_virtio_update_avail_event              49512    6271
 vhost_work_execute_start(tx_kick)            49429    6254
 vhost_work_queue_wakeup(tx_kick)             49442    6252
 vhost_work_queue_coalesce(tx_kick)              28	  5
 vhost_work_execute_start(rx_kick)               22	  3
 vhost_work_queue_wakeup(rx_kick)                22	  3
 vhost_poll_start                                 4	  0

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 tools/virtio/vhost_stat |  360 +++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 360 insertions(+), 0 deletions(-)
 create mode 100755 tools/virtio/vhost_stat

diff --git a/tools/virtio/vhost_stat b/tools/virtio/vhost_stat
new file mode 100755
index 0000000..b730f3b
--- /dev/null
+++ b/tools/virtio/vhost_stat
@@ -0,0 +1,360 @@
+#!/usr/bin/python
+#
+# top-like utility for displaying vhost statistics
+#
+# Copyright 2012 Red Hat, Inc.
+#
+# Modified from kvm_stat from qemu
+#
+# This work is licensed under the terms of the GNU GPL, version 2.  See
+# the COPYING file in the top-level directory.
+
+import curses
+import sys, os, time, optparse
+
+work_types = {
+    "handle_rx_kick" : "rx_kick",
+    "handle_tx_kick" : "tx_kick",
+    "handle_rx_net" : "rx_net",
+    "handle_tx_net" : "tx_net",
+    "vhost_attach_cgroups_work": "cg_attach"
+    }
+
+addr = {}
+
+kallsyms = file("/proc/kallsyms").readlines()
+for kallsym in kallsyms:
+    entry = kallsym.split()
+    if entry[2] in work_types.keys():
+        addr["0x%s" % entry[0]] = work_types[entry[2]]
+
+filters = {
+    'vhost_work_queue_wakeup': ('function', addr),
+    'vhost_work_queue_coalesce' : ('function', addr),
+    'vhost_work_execute_start' : ('function', addr),
+    'vhost_poll_start' : ('function', addr),
+    'vhost_poll_stop' : ('function', addr),
+}
+
+def invert(d):
+    return dict((x[1], x[0]) for x in d.iteritems())
+
+for f in filters:
+    filters[f] = (filters[f][0], invert(filters[f][1]))
+
+import ctypes, struct, array
+
+libc = ctypes.CDLL('libc.so.6')
+syscall = libc.syscall
+class perf_event_attr(ctypes.Structure):
+    _fields_ = [('type', ctypes.c_uint32),
+                ('size', ctypes.c_uint32),
+                ('config', ctypes.c_uint64),
+                ('sample_freq', ctypes.c_uint64),
+                ('sample_type', ctypes.c_uint64),
+                ('read_format', ctypes.c_uint64),
+                ('flags', ctypes.c_uint64),
+                ('wakeup_events', ctypes.c_uint32),
+                ('bp_type', ctypes.c_uint32),
+                ('bp_addr', ctypes.c_uint64),
+                ('bp_len', ctypes.c_uint64),
+                ]
+def _perf_event_open(attr, pid, cpu, group_fd, flags):
+    return syscall(298, ctypes.pointer(attr), ctypes.c_int(pid),
+                   ctypes.c_int(cpu), ctypes.c_int(group_fd),
+                   ctypes.c_long(flags))
+
+PERF_TYPE_HARDWARE              = 0
+PERF_TYPE_SOFTWARE              = 1
+PERF_TYPE_TRACEPOINT            = 2
+PERF_TYPE_HW_CACHE              = 3
+PERF_TYPE_RAW                   = 4
+PERF_TYPE_BREAKPOINT            = 5
+
+PERF_SAMPLE_IP                  = 1 << 0
+PERF_SAMPLE_TID                 = 1 << 1
+PERF_SAMPLE_TIME                = 1 << 2
+PERF_SAMPLE_ADDR                = 1 << 3
+PERF_SAMPLE_READ                = 1 << 4
+PERF_SAMPLE_CALLCHAIN           = 1 << 5
+PERF_SAMPLE_ID                  = 1 << 6
+PERF_SAMPLE_CPU                 = 1 << 7
+PERF_SAMPLE_PERIOD              = 1 << 8
+PERF_SAMPLE_STREAM_ID           = 1 << 9
+PERF_SAMPLE_RAW                 = 1 << 10
+
+PERF_FORMAT_TOTAL_TIME_ENABLED  = 1 << 0
+PERF_FORMAT_TOTAL_TIME_RUNNING  = 1 << 1
+PERF_FORMAT_ID                  = 1 << 2
+PERF_FORMAT_GROUP               = 1 << 3
+
+import re
+
+sys_tracing = '/sys/kernel/debug/tracing'
+
+class Group(object):
+    def __init__(self, cpu):
+        self.events = []
+        self.group_leader = None
+        self.cpu = cpu
+    def add_event(self, name, event_set, tracepoint, filter = None):
+        self.events.append(Event(group = self,
+                                 name = name, event_set = event_set,
+                                 tracepoint = tracepoint, filter = filter))
+        if len(self.events) == 1:
+            self.file = os.fdopen(self.events[0].fd)
+    def read(self):
+        bytes = 8 * (1 + len(self.events))
+        fmt = 'xxxxxxxx' + 'q' * len(self.events)
+        return dict(zip([event.name for event in self.events],
+                        struct.unpack(fmt, self.file.read(bytes))))
+
+class Event(object):
+    def __init__(self, group, name, event_set, tracepoint, filter = None):
+        self.name = name
+        attr = perf_event_attr()
+        attr.type = PERF_TYPE_TRACEPOINT
+        attr.size = ctypes.sizeof(attr)
+        id_path = os.path.join(sys_tracing, 'events', event_set,
+                               tracepoint, 'id')
+        id = int(file(id_path).read())
+        attr.config = id
+        attr.sample_type = (PERF_SAMPLE_RAW
+                            | PERF_SAMPLE_TIME
+                            | PERF_SAMPLE_CPU)
+        attr.sample_period = 1
+        attr.read_format = PERF_FORMAT_GROUP
+        group_leader = -1
+        if group.events:
+            group_leader = group.events[0].fd
+        fd = _perf_event_open(attr, -1, group.cpu, group_leader, 0)
+        if fd == -1:
+            raise Exception('perf_event_open failed')
+        if filter:
+            import fcntl
+            fcntl.ioctl(fd, 0x40082406, filter)
+        self.fd = fd
+    def enable(self):
+        import fcntl
+        fcntl.ioctl(self.fd, 0x00002400, 0)
+    def disable(self):
+        import fcntl
+        fcntl.ioctl(self.fd, 0x00002401, 0)
+
+class TracepointProvider(object):
+    def __init__(self):
+        path = os.path.join(sys_tracing, 'events', 'vhost')
+        fields = [f
+                  for f in os.listdir(path)
+                  if os.path.isdir(os.path.join(path, f))]
+        extra = []
+        for f in fields:
+            if f in filters:
+                subfield, values = filters[f]
+                for name, number in values.iteritems():
+                    # kvm_exit(MMIO)
+                    extra.append(f + '(' + name + ')')
+        fields += extra
+        self._setup(fields)
+        self.select(fields)
+    def fields(self):
+        return self._fields
+    def _setup(self, _fields):
+        self._fields = _fields
+        cpure = r'cpu([0-9]+)'
+        self.cpus = [int(re.match(cpure, x).group(1))
+                     for x in os.listdir('/sys/devices/system/cpu')
+                     if re.match(cpure, x)]
+        import resource
+        nfiles = len(self.cpus) * 1000
+        resource.setrlimit(resource.RLIMIT_NOFILE, (nfiles, nfiles))
+        events = []
+        self.group_leaders = []
+        for cpu in self.cpus:
+            group = Group(cpu)
+            for name in _fields:
+                tracepoint = name
+                filter = None
+                # for field like kvm_exit(MMIO)
+                m = re.match(r'(.*)\((.*)\)', name)
+                if m:
+                    tracepoint, sub = m.groups()
+                    filter = '%s==%s\0' % (filters[tracepoint][0],
+                                           filters[tracepoint][1][sub])
+                event = group.add_event(name, event_set = 'vhost',
+                                        tracepoint = tracepoint,
+                                        filter = filter)
+            self.group_leaders.append(group)
+    def select(self, fields):
+        for group in self.group_leaders:
+            for event in group.events:
+                if event.name in fields:
+                    event.enable()
+                else:
+                    event.disable()
+    def read(self):
+        from collections import defaultdict
+        ret = defaultdict(int)
+        for group in self.group_leaders:
+            for name, val in group.read().iteritems():
+                ret[name] += val
+        return ret
+
+class Stats:
+    def __init__(self, provider, fields = None):
+        self.provider = provider
+        self.fields_filter = fields
+        self._update()
+    def _update(self):
+        def wanted(key):
+            import re
+            if not self.fields_filter:
+                return True
+            return re.match(self.fields_filter, key) is not None
+        self.values = dict([(key, None)
+                            for key in provider.fields()
+                            if wanted(key)])
+        self.provider.select(self.values.keys())
+    def set_fields_filter(self, fields_filter):
+        self.fields_filter = fields_filter
+        self._update()
+    def get(self):
+        new = self.provider.read()
+        for key in self.provider.fields():
+            oldval = self.values.get(key, (0, 0))
+            newval = new[key]
+            newdelta = None
+            if oldval is not None:
+                newdelta = newval - oldval[0]
+            self.values[key] = (newval, newdelta)
+        return self.values
+
+if not os.access('/sys/kernel/debug', os.F_OK):
+    print 'Please enable CONFIG_DEBUG_FS in your kernel'
+    sys.exit(1)
+if not os.access('/sys/module/vhost_net', os.F_OK):
+    print 'Please make sure vhost module are loaded'
+    sys.exit(1)
+
+label_width = 40
+number_width = 10
+
+def tui(screen, stats):
+    curses.use_default_colors()
+    curses.noecho()
+    drilldown = False
+    fields_filter = stats.fields_filter
+    def update_drilldown():
+        if not fields_filter:
+            if drilldown:
+                stats.set_fields_filter(None)
+            else:
+                stats.set_fields_filter(r'^[^\(]*$')
+    update_drilldown()
+    def refresh(sleeptime):
+        screen.erase()
+        screen.addstr(0, 0, 'vhost statistics')
+        row = 2
+        s = stats.get()
+        def sortkey(x):
+            if s[x][1]:
+                return (-s[x][1], -s[x][0])
+            else:
+                return (0, -s[x][0])
+        for key in sorted(s.keys(), key = sortkey):
+            if row >= screen.getmaxyx()[0]:
+                break
+            values = s[key]
+            if not values[0] and not values[1]:
+                break
+            col = 1
+            screen.addstr(row, col, key)
+            col += label_width
+            screen.addstr(row, col, '%10d' % (values[0],))
+            col += number_width
+            if values[1] is not None:
+                screen.addstr(row, col, '%8d' % (values[1] / sleeptime,))
+            row += 1
+        screen.refresh()
+
+    sleeptime = 0.25
+    while True:
+        refresh(sleeptime)
+        curses.halfdelay(int(sleeptime * 10))
+        sleeptime = 3
+        try:
+            c = screen.getkey()
+            if c == 'x':
+                drilldown = not drilldown
+                update_drilldown()
+            if c == 'q':
+                break
+        except KeyboardInterrupt:
+            break
+        except curses.error:
+            continue
+
+def batch(stats):
+    s = stats.get()
+    time.sleep(1)
+    s = stats.get()
+    for key in sorted(s.keys()):
+        values = s[key]
+        print '%-22s%10d%10d' % (key, values[0], values[1])
+
+def log(stats):
+    keys = sorted(stats.get().iterkeys())
+    def banner():
+        for k in keys:
+            print '%10s' % k[0:9],
+        print
+    def statline():
+        s = stats.get()
+        for k in keys:
+            print ' %9d' % s[k][1],
+        print
+    line = 0
+    banner_repeat = 20
+    while True:
+        time.sleep(1)
+        if line % banner_repeat == 0:
+            banner()
+        statline()
+        line += 1
+
+options = optparse.OptionParser()
+options.add_option('-1', '--once', '--batch',
+                   action = 'store_true',
+                   default = False,
+                   dest = 'once',
+                   help = 'run in batch mode for one second',
+                   )
+options.add_option('-l', '--log',
+                   action = 'store_true',
+                   default = False,
+                   dest = 'log',
+                   help = 'run in logging mode (like vmstat)',
+                   )
+options.add_option('-f', '--fields',
+                   action = 'store',
+                   default = None,
+                   dest = 'fields',
+                   help = 'fields to display (regex)',
+                   )
+(options, args) = options.parse_args(sys.argv)
+
+try:
+    provider = TracepointProvider()
+except:
+    print "Could not initialize tracepoint"
+    sys.exit(1)
+
+stats = Stats(provider, fields = options.fields)
+
+if options.log:
+    log(stats)
+elif not options.once:
+    import curses.wrapper
+    curses.wrapper(tui, stats)
+else:
+    batch(stats)
