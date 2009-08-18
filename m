From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 3/3] net: skb ftracer - Add actual ftrace code to
	kernel (v3)
Date: Tue, 18 Aug 2009 12:39:58 -0400
Message-ID: <20090818163958.GA2677@localhost.localdomain>
References: <20090807202130.GA26677@hmsreliant.think-freely.org> <20090813145917.GA16521@hmsreliant.think-freely.org> <20090813152356.GC16682@hmsreliant.think-freely.org> <alpine.DEB.2.00.0908171647470.25890@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:60375 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759201AbZHRQkH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2009 12:40:07 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0908171647470.25890@gandalf.stny.rr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 17, 2009 at 04:55:38PM -0400, Steven Rostedt wrote:
> 
> Hi Neil!
> 
> Sorry for the late reply, I've been on vacation for the last week.
> 
> On Thu, 13 Aug 2009, Neil Horman wrote:
> 
> > skb allocation / consumption correlator
> > 
> > Add ftracer module to kernel to print out a list that correlates a process id,
> > an skb it read, and the numa nodes on wich the process was running when it was
> > read along with the numa node the skbuff was allocated on.
> > 
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> > 
> > 
> >  Makefile            |    1 
> >  trace.h             |   19 ++++++
> >  trace_skb_sources.c |  154 ++++++++++++++++++++++++++++++++++++++++++++++++++++
> >  3 files changed, 174 insertions(+)
> > 
> > diff --git a/kernel/trace/Makefile b/kernel/trace/Makefile
> > index 844164d..ee5e5b1 100644
> > --- a/kernel/trace/Makefile
> > +++ b/kernel/trace/Makefile
> > @@ -49,6 +49,7 @@ obj-$(CONFIG_BLK_DEV_IO_TRACE) += blktrace.o
> >  ifeq ($(CONFIG_BLOCK),y)
> >  obj-$(CONFIG_EVENT_TRACING) += blktrace.o
> >  endif
> > +obj-$(CONFIG_SKB_SOURCES_TRACER) += trace_skb_sources.o
> >  obj-$(CONFIG_EVENT_TRACING) += trace_events.o
> >  obj-$(CONFIG_EVENT_TRACING) += trace_export.o
> >  obj-$(CONFIG_FTRACE_SYSCALLS) += trace_syscalls.o
> > diff --git a/kernel/trace/trace.h b/kernel/trace/trace.h
> > index 8b9f4f6..8a6281b 100644
> > --- a/kernel/trace/trace.h
> > +++ b/kernel/trace/trace.h
> > @@ -11,6 +11,7 @@
> >  #include <trace/boot.h>
> >  #include <linux/kmemtrace.h>
> >  #include <trace/power.h>
> > +#include <trace/events/skb.h>
> >  
> >  #include <linux/trace_seq.h>
> >  #include <linux/ftrace_event.h>
> > @@ -40,6 +41,7 @@ enum trace_type {
> >  	TRACE_KMEM_FREE,
> >  	TRACE_POWER,
> >  	TRACE_BLK,
> > +	TRACE_SKB_SOURCE,
> >  
> >  	__TRACE_LAST_TYPE,
> >  };
> > @@ -171,6 +173,21 @@ struct trace_power {
> >  	struct power_trace	state_data;
> >  };
> >  
> > +struct skb_record {
> > +	pid_t pid;		/* pid of the copying process */
> > +	int anid;		/* node where skb was allocated */
> > +	int cnid;		/* node to which skb was copied in userspace */
> > +	char ifname[IFNAMSIZ];	/* Name of the receiving interface */
> > +	int rx_queue;		/* The rx queue the skb was received on */
> > +	int ccpu;		/* Cpu the application got this frame from */
> > +	int len;		/* length of the data copied */
> > +};
> > +
> > +struct trace_skb_event {
> > +	struct trace_entry	ent;
> > +	struct skb_record	event_data;
> > +};
> > +
> >  enum kmemtrace_type_id {
> >  	KMEMTRACE_TYPE_KMALLOC = 0,	/* kmalloc() or kfree(). */
> >  	KMEMTRACE_TYPE_CACHE,		/* kmem_cache_*(). */
> > @@ -323,6 +340,8 @@ extern void __ftrace_bad_type(void);
> >  			  TRACE_SYSCALL_ENTER);				\
> >  		IF_ASSIGN(var, ent, struct syscall_trace_exit,		\
> >  			  TRACE_SYSCALL_EXIT);				\
> > +		IF_ASSIGN(var, ent, struct trace_skb_event,		\
> > +			  TRACE_SKB_SOURCE);				\
> >  		__ftrace_bad_type();					\
> >  	} while (0)
> >  
> > diff --git a/kernel/trace/trace_skb_sources.c b/kernel/trace/trace_skb_sources.c
> > new file mode 100644
> > index 0000000..4ba3671
> > --- /dev/null
> > +++ b/kernel/trace/trace_skb_sources.c
> > @@ -0,0 +1,154 @@
> > +/*
> > + * ring buffer based tracer for analyzing per-socket skb sources
> > + *
> > + * Neil Horman <nhorman@tuxdriver.com> 
> > + * Copyright (C) 2009
> > + *
> > + *
> > + */
> > +
> > +#include <linux/init.h>
> > +#include <linux/debugfs.h>
> > +#include <trace/events/skb.h>
> > +#include <linux/kallsyms.h>
> > +#include <linux/module.h>
> > +#include <linux/hardirq.h>
> > +#include <linux/netdevice.h>
> > +#include <net/sock.h>
> > +
> > +#include "trace.h"
> > +#include "trace_output.h"
> > +
> > +EXPORT_TRACEPOINT_SYMBOL_GPL(skb_copy_datagram_iovec);
> > +
> > +static struct trace_array *skb_trace;
> > +static int __read_mostly trace_skb_source_enabled;
> > +
> > +static void probe_skb_dequeue(const struct sk_buff *skb, int len)
> > +{
> > +	struct ring_buffer_event *event;
> > +	struct trace_skb_event *entry;
> > +	struct trace_array *tr = skb_trace;
> > +	struct net_device *dev;
> > +
> > +	if (!trace_skb_source_enabled)
> > +		return;
> > +
> > +	if (in_interrupt())
> > +		return;
> 
> Is there a reason for not doing this in an interrupt?
> 
Because the idea is to correlate skb consumption to a process.  If we get in
this tracepoint in an interrupt, it doesn't make sense to record.


> > +
> > +	event = trace_buffer_lock_reserve(tr, TRACE_SKB_SOURCE,
> > +					  sizeof(*entry), 0, 0);
> > +	if (!event)
> > +		return;
> > +	entry = ring_buffer_event_data(event);
> > +
> > +	entry->event_data.pid = current->pid;
> 
> Note, the trace_buffer_lock_reserve will record the current pid, thus you 
> do not need to record it here.
> 
> > +	entry->event_data.anid = page_to_nid(virt_to_page(skb->data));
> > +	entry->event_data.cnid = cpu_to_node(smp_processor_id());
> > +	entry->event_data.len = len;
> > +	entry->event_data.rx_queue = skb->queue_mapping;
> > +	entry->event_data.ccpu = smp_processor_id();
> 
> Also, the cpu is recorded in the ring buffer. They are per cpu ring 
> buffers and that determines the cpu it was recorded on.
> 
> > +
> > +	dev = dev_get_by_index(sock_net(skb->sk), skb->iif);
> > +	if (dev) {
> > +		memcpy(entry->event_data.ifname, dev->name, IFNAMSIZ);
> > +		dev_put(dev);
> > +	} else {
> > +		strcpy(entry->event_data.ifname, "Unknown");
> > +	}
> > +
> > +	trace_buffer_unlock_commit(tr, event, 0, 0);
> > +}
> > +
> > +static int tracing_skb_source_register(void)
> > +{
> > +	int ret;
> > +
> > +	ret = register_trace_skb_copy_datagram_iovec(probe_skb_dequeue);
> > +	if (ret)
> > +		pr_info("skb source trace: Couldn't activate dequeue tracepoint");
> > +	
> > +	return ret;
> > +}
> > +
> > +static void start_skb_source_trace(struct trace_array *tr)
> > +{
> > +	trace_skb_source_enabled = 1;
> > +}
> > +
> > +static void stop_skb_source_trace(struct trace_array *tr)
> > +{
> > +	trace_skb_source_enabled = 0;
> > +}
> > +
> > +static void skb_source_trace_reset(struct trace_array *tr)
> > +{
> > +	trace_skb_source_enabled = 0;
> > +	unregister_trace_skb_copy_datagram_iovec(probe_skb_dequeue);
> > +}
> > +
> > +
> > +static int skb_source_trace_init(struct trace_array *tr)
> > +{
> > +	int cpu;
> > +	skb_trace = tr;
> > +
> > +	trace_skb_source_enabled = 1;
> > +	tracing_skb_source_register();
> > +
> > +	for_each_cpu(cpu, cpu_possible_mask)
> > +		tracing_reset(tr, cpu);
> > +	return 0;
> > +}
> > +
> > +static enum print_line_t skb_source_print_line(struct trace_iterator *iter)
> > +{
> > +	int ret = 0;
> > +	struct trace_entry *entry = iter->ent;
> 
> iter->cpu has the cpu that trace was recorded on.
> entry->pid has the pid of the process that did the recording.
> 
ok, I'll clean this up in a subsequent patch, since davem has already rolled
them in.

> > +	struct trace_skb_event *event;
> > +	struct skb_record *record;
> > +	struct trace_seq *s = &iter->seq;
> > +
> > +	trace_assign_type(event, entry);
> > +	record = &event->event_data;
> > +	if (entry->type != TRACE_SKB_SOURCE)
> > +		return TRACE_TYPE_UNHANDLED;
> > +
> > +	ret = trace_seq_printf(s, "	%d	%d	%d	%s	%d	%d	%d\n",
> > +			record->pid,
> > +			record->anid,
> > +			record->cnid,
> > +			record->ifname,
> > +			record->rx_queue,
> > +			record->ccpu,
> > +			record->len);
> > +
> > +	if (!ret)
> > +		return TRACE_TYPE_PARTIAL_LINE;
> > +
> > +	return TRACE_TYPE_HANDLED;
> > +}
> > +
> > +static void skb_source_print_header(struct seq_file *s)
> > +{
> > +	seq_puts(s, "#	PID	ANID	CNID	IFC	RXQ	CCPU	LEN\n");
> > +	seq_puts(s, "#	 |	 |	 |	 |	 |	 |	 |\n");
> > +}
> > +
> > +static struct tracer skb_source_tracer __read_mostly =
> > +{
> > +	.name		= "skb_sources",
> > +	.init		= skb_source_trace_init,
> > +	.start		= start_skb_source_trace,
> > +	.stop		= stop_skb_source_trace,
> > +	.reset		= skb_source_trace_reset,
> > +	.print_line	= skb_source_print_line,
> > +	.print_header	= skb_source_print_header,
> > +};
> > +
> > +static int init_skb_source_trace(void)
> > +{
> > +	return register_tracer(&skb_source_tracer);
> > +}
> > +device_initcall(init_skb_source_trace);
> > 
> 
> BTW, why not just do this as events? Or was this just a easy way to 
> communicate with the user space tools?
> 
Thats exactly why I did it.  the idea is for me to now write a user space tool
that lets me analyze the events and ajust process scheduling to optimize the rx
path.
Neil

> -- Steve
> 
> 
