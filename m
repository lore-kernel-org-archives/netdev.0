From: Richard Weinberger <rw@linutronix.de>
Subject: Netfilter: New target: RLOG
Date: Wed, 18 Jan 2012 23:43:25 +0100
Message-ID: <1326926610-17830-1-git-send-email-rw@linutronix.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	rostedt@goodmis.org
To: netfilter-devel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RLOG is a new log target, it works like LOG with the exception that it writes to ring buffers.
It makes use of Steven Rostedt's ring_buffer subsystem. 
I've used Steve's ring buffer because it allows concurrent writes. IOW it's very fast.
For more details see: Documentation/trace/ring-buffer-design.txt.

Each ring buffer is represented as a pipe-like file in /proc/net/netfilter/xt_RLOG/.
You can read from it with and program you like (cat, syslog, etc...).
The default size is 1MiB. With this size it can store approximately 5000 messages.

- Why not LOG?
I like the LOG target a lot but I really hat it when it floods my kernel syslog.
dmesg becomes useless.
Writing all log messages to a file using syslogd also not always the best solution.
Most of the time my firewall logs just waste disk space.

Compared with Steve's ring_buffer, the kernel syslog is rather slow.
Especially when the firewall logs very much syslog becomes a bottleneck.
As we all know printk() is not fast.

- Why not ULOG/NFLOG?
Because it cannot replace LOG.
Details like PHYSIN and PHYSOUT are not available form the packet headers.
Also on many Linux systems ulogd is not available/supported.  

- Why RLOG?
Using RLOG you can have many ring buffers with all kind of logs.
If your firewall goes nuts you don't have to mess you rule-set with adding
new LOG rules to find out what's going on.
Just install a few RLOG rules with small buffer sized and read them if you don't
know what's going on.
If you make you firewall rule-set per default verbose using LOG or NFLOG it will 
generate lot's of useless messages which you'll never ever read.
With RLOG you can bypass this problem.
On my firewall I record only useful data to the disk. Everything else goes into RLOG.

If your firewall is really busy and you want to log nearly everything, c
reate a big ring buffer and read from is using your favorite userspace tool.
In case the buffer fills faster than the userspace consumes it, RLOG will warn you.
I'd also possible to resize the buffer.

- Example

You can use RLOG like LOG.
E.g:
iptables -A INPUT -p icmp -j RLOG
The default name of the ring buffer is "default".
Now you can read your icmp logs from /proc/net/netfilter/default

iptables -A INPUT -p icmp -j RLOG --ring foo
iptables -A INPUT -j RLOG --ring bar --size 4096

This will create two new ring buffers "foo" and "bar".
"bar" has a size of 4MiB.

ICMP logs go now into three ring buffers, "default" and "foo".
Everything else (including ICMP) goes into "bar".
If you don't want to use syslog add "--add-timestamp" to have timestamps in your logs.

Different iptables rules with different RLOG flags can use the same ring buffer.
iptables -A INPUT -p icmp -j RLOG --ring xxx --add-timestamp
iptables -A INPUT -p icmp -j RLOG --ring xxx

Every ICMP packet will show up in "xxx" twice. But the first entry will have a timestamp.


[PATCH 1/5] ring_buffer: Export for_each_buffer_cpu()
Steve, is this path ok for you?

[PATCH 2/5] xt_log: Make printk() in sb_close() optional
[PATCH 3/5] nf_log: Export dump_packet() and dump_mac_header()
RLOG reuses as much code from LOG are possible.
These two patches are needed to export some code to RLOG.
Currently RLOG depends on both ipt_LOG and ip6t_LOG.

[PATCH 4/5] netfilter: Implement xt_RLOG
[PATCH 5/5] xt_RLOG: add userspace-components

Any feedback is welcome!
