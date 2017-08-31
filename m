From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH net-next] bridge: add tracepoint in br_fdb_update
Date: Thu, 31 Aug 2017 15:56:57 -0300
Message-ID: <20170831185657.GC2252@redhat.com>
References: <1504156693-24692-1-git-send-email-roopa@cumulusnetworks.com>
 <20170831143814.68709334@redhat.com>
 <CAJieiUjZ5dTNpBFb8c2KMRgjXRCKVGhJsTfQcpiw+p6fyNVwDw@mail.gmail.com>
 <a9349049-bfd7-b6c0-d1c7-2f70b0b0ab11@gmail.com>
 <20170831182012.5d321c6a@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Ahern <dsahern@gmail.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        bridge@lists.linux-foundation.org,
        Peter Zijlstra <peterz@infradead.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53122 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750996AbdHaS5E (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 31 Aug 2017 14:57:04 -0400
Content-Disposition: inline
In-Reply-To: <20170831182012.5d321c6a@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Thu, Aug 31, 2017 at 06:20:12PM +0200, Jesper Dangaard Brouer escreveu:
> On Thu, 31 Aug 2017 09:30:05 -0600 David Ahern <dsahern@gmail.com> wrote:
> > > On Thu, Aug 31, 2017 at 5:38 AM, Jesper Dangaard Brouer <brouer@redhat.com> wrote:  
> > > These bridge tracepoints in context are primarily for debugging fdb
> > > updates only, not for every packet and hence not in the performance
> > > path.
> > > In large scale deployments with thousands of bridge ports and fdb
> > > entries, dev->name will definately make it easier to trouble-shoot.
> > > So, I did like to leave these with dev->name unless there are strong objections.  

> > +1 for user friendliness for debugging tracepoints. The device name is
> > also more user friendly when adding filters to the data collection.

> > Being able to add bpf everywhere certainly changes the game a bit, but
> > we should not relinquish ease of use and understanding for the potential
> > that someone might want to put a bpf program on the tracepoint and want
> > to maintain high performance.
 
> (Cc. Acme and Peterz)
> I wonder if we can create a special perf-tracepoint type for ifindex'es
> and the tool reading (e.g. perf-script) can perform the name lookup in
> userspace (calling if_indextoname(3)) ?
 
> I don't know the perf tools well enough to know if this is possible?

Yeah, there are libtraceevent plugins, and that gets used by trace-cmd
and perf script, perf trace.

[root@jouet ~]# ls -la ~/.traceevent/plugins/
total 192
drwxr-xr-x. 2 acme acme  4096 Aug 31 15:29 .
drwxr-xr-x. 3 acme acme  4096 Jan 27  2017 ..
-rwxr-xr-x. 1 acme acme 13744 Aug 31 15:29 plugin_cfg80211.so
-rwxr-xr-x. 1 acme acme 20192 Aug 31 15:29 plugin_function.so
-rwxr-xr-x. 1 acme acme 13680 Aug 31 15:29 plugin_hrtimer.so
-rwxr-xr-x. 1 acme acme 13760 Aug 31 15:29 plugin_jbd2.so
-rwxr-xr-x. 1 acme acme 13704 Aug 31 15:29 plugin_kmem.so
-rwxr-xr-x. 1 acme acme 28568 Aug 31 15:29 plugin_kvm.so
-rwxr-xr-x. 1 acme acme 14184 Aug 31 15:29 plugin_mac80211.so
-rwxr-xr-x. 1 acme acme 14424 Aug 31 15:29 plugin_sched_switch.so
-rwxr-xr-x. 1 acme acme 20136 Aug 31 15:29 plugin_scsi.so
-rwxr-xr-x. 1 acme acme 14504 Aug 31 15:29 plugin_xen.so
[root@jouet ~]#

But... that index is something that is mutable, i.e. you'd have to
somehow record all the assignments of an index to an interface and then,
when processing the events, get from that state the mapping you want.

So you don't store the device name by doing lookups at each of those
high volume tracepoints, store just the index, but then, when
establishing the mapping, collect that as well and we come up with some
infrastructure to get that mapping in a place where a plugin can do the
lookups at post processing time.

For instance, the hrtimer plugin will get an address from the kernel,
and, from a state recorded at the same time as the trace file, will
lookup elf symbol tables for the kernel or modules and resolve that
symbol, etc.

- Arnaldo
