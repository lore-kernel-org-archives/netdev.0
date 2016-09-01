From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH] softirq: let ksoftirqd do its job
Date: Thu, 1 Sep 2016 15:30:42 +0200
Message-ID: <20160901153042.465b864e@redhat.com>
References: <20160831164216.2901190c@redhat.com>
        <1472661956.14381.335.camel@edumazet-glaptop3.roam.corp.google.com>
        <1472665349.14381.356.camel@edumazet-glaptop3.roam.corp.google.com>
        <20160831214043.2f44cf08@redhat.com>
        <1472676150.14381.363.camel@edumazet-glaptop3.roam.corp.google.com>
        <20160831235116.33b1946b@redhat.com>
        <20160901130231.58355405@redhat.com>
        <20160901115356.GT10153@twins.programming.kicks-ass.net>
        <20160901142925.63a5031b@redhat.com>
        <20160901143859.730826ed@redhat.com>
        <20160901124839.GU10153@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>,
        Rik van Riel <riel@redhat.com>,
        Paolo Abeni <pabeni@redhat.com>,
        Hannes Frederic Sowa <hannes@redhat.com>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        Jonathan Corbet <corbet@lwn.net>, brouer@redhat.com
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160901124839.GU10153@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 1 Sep 2016 14:48:39 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> On Thu, Sep 01, 2016 at 02:38:59PM +0200, Jesper Dangaard Brouer wrote:
> > On Thu, 1 Sep 2016 14:29:25 +0200
> > Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> >   
> > > On Thu, 1 Sep 2016 13:53:56 +0200
> > > Peter Zijlstra <peterz@infradead.org> wrote:
> > >   
> > > > On Thu, Sep 01, 2016 at 01:02:31PM +0200, Jesper Dangaard Brouer wrote:    
> > > > >    PID  S  %CPU     TIME+  COMMAND
> > > > >      3  R  50.0  29:02.23  ksoftirqd/0
> > > > >  10881  R  10.7   1:01.61  udp_sink
> > > > >  10837  R  10.0   1:05.20  udp_sink
> > > > >  10852  S  10.0   1:01.78  udp_sink
> > > > >  10862  R  10.0   1:05.19  udp_sink
> > > > >  10844  S   9.7   1:01.91  udp_sink
> > > > > 
> > > > > This is strange, why is ksoftirqd/0 getting 50% of the CPU time???      
> > > > 
> > > > Do you run your udp_sink thingy in a cpu-cgroup?    
> > > 
> > > That was also Paolo's feedback (IRC).  I'm not aware of it, but it
> > > might be some distribution (Fedora 22) default thing.  
> > 
> > Correction, on the server-under-test, I'm actually running RHEL7.2
> > 
> >   
> > > How do I verify/check if I have enabled a cpu-cgroup?  
> > 
> > Hannes says I can look in "/proc/self/cgroup"
> > 
> >  $ cat /proc/self/cgroup
> >  7:net_cls:/
> >  6:blkio:/
> >  5:devices:/
> >  4:perf_event:/
> >  3:cpu,cpuacct:/
> >  2:cpuset:/
> >  1:name=systemd:/user.slice/user-1000.slice/session-c1.scope
> >  
> > And that "/" indicate I've not enabled cgroups, right?  
> 
> Mostly so. I think RHEL/Fedora has SCHED_AUTOGROUP enabled, and you can
> find that through:
> 
> cat /proc/self/autogroup

$ cat /proc/self/autogroup
/autogroup-88 nice 0

> And disable with the noautogroup boot param, or:
> 
> echo 0 > /proc/sys/kernel/sched_autogroup_enabled

Looks like it is enabled on my system:

$ grep -H . /proc/sys/kernel/sched_autogroup_enabled
/proc/sys/kernel/sched_autogroup_enabled:1


> although this latter will leave the current state intact while avoiding
> creation of any further autogroups iirc.

$ sudo sh -c 'echo 0 > /proc/sys/kernel/sched_autogroup_enabled'
$ grep -H . /proc/sys/kernel/sched_autogroup_enabled
/proc/sys/kernel/sched_autogroup_enabled:0

$ sudo systemctl restart sshd

Starting new SSH login:

$ cat /proc/self/autogroup
/autogroup-153 nice 0

Hmmm, still enabled...

$ sudo systemctl stop sshd
$ sudo systemctl start sshd
$ grep -H . /proc/sys/kernel/sched_autogroup_enabled
/proc/sys/kernel/sched_autogroup_enabled:0
$ cat /proc/self/autogroup
/autogroup-158 nice 0

Still... enabled!
Hmmm.. more idea how to disable this???

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
