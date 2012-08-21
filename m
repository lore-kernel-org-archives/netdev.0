From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC PATCH 1/1] fair.c: Add/Export find_idlest_perfer_cpu API
Date: Tue, 21 Aug 2012 09:07:00 +0200
Message-ID: <1345532820.23018.81.camel@twins>
References: <1345232770.16533.234.camel@oc3660625478.ibm.com>
	 <1345464035.23018.38.camel@twins>
	 <1345501041.6378.10.camel@oc3660625478.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org, mingo@redhat.com,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	sri@us.ibm.com, vivek@us.ibm.com
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37880 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753318Ab2HUHHM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2012 03:07:12 -0400
In-Reply-To: <1345501041.6378.10.camel@oc3660625478.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-08-20 at 15:17 -0700, Shirley Ma wrote:
> On Mon, 2012-08-20 at 14:00 +0200, Peter Zijlstra wrote:
> > On Fri, 2012-08-17 at 12:46 -0700, Shirley Ma wrote:
> > > Add/Export a new API for per-cpu thread model networking device
> > driver
> > > to choose a preferred idlest cpu within allowed cpumask.
> > > 
> > > The receiving CPUs of a networking device are not under cgroup
> > controls.
> > > Normally the receiving work will be scheduled on the cpu on which
> > the
> > > interrupts are received. When such a networking device uses per-cpu
> > > thread model, the cpu which is chose to process the packets might
> > not be
> > > part of cgroup cpusets without using such an API here. 
> > > 
> > > On NUMA system, by using the preferred cpumask from the same NUMA
> > node
> > > would help to reduce expensive cross memory access to/from the other
> > > NUMA node.
> > > 
> > > KVM per-cpu vhost will be the first one to use this API. Any other
> > > device driver which uses per-cpu thread model and has cgroup cpuset
> > > control will use this API later.
> > 
> > How often will this be called and how do you obtain the cpumasks
> > provided to the function? 
> 
> It depends. It might be called pretty often if the user keeps changing
> cgroups control cpuset. It might be less called if the cgroups control
> cpuset is stable, and the host scheduler always schedules the work on
> the same NUMA node.

This just doesn't make any sense, you're scanning for the least loaded
cpu, this is unrelated to a change in cpuset. So tying the scan
frequency to changes in configuration is just broken.

> The preferred cpumasks are obtained from local numa node.

So why pass it as argument at all? Also, who says the current node is
the right one? It might just be running there temporarily.

>  The allowed
> cpumasks are obtained from caller's task allowed cpumasks (cgroups
> control cpuset).

task->cpus_allowed != cpusets.. Also, since you're using
task->cpus_allowed, pass a task_struct *, not a cpumask.
