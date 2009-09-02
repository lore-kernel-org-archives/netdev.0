From: Bill Fink <billfink@mindspring.com>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Wed, 2 Sep 2009 01:11:43 -0400
Message-ID: <20090902011143.89359828.billfink@mindspring.com>
References: <20090814164412.be5daa74.billfink@mindspring.com>
	<20090814232543.GA28599@hmsreliant.think-freely.org>
	<20090820035044.9b70fca6.billfink@mindspring.com>
	<20090820201919.GA20750@localhost.localdomain>
	<20090821001421.214a560b.billfink@mindspring.com>
	<20090821152341.GA2998@localhost.localdomain>
	<20090826031057.375303c9.billfink@mindspring.com>
	<20090826110013.GA10816@hmsreliant.think-freely.org>
	<20090826180811.GB10816@hmsreliant.think-freely.org>
	<20090827134429.ca1ba6bd.billfink@mindspring.com>
	<20090827175151.GC4762@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Network Developers <netdev@vger.kernel.org>, brice@myri.com,
	gallatin@myri.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-kukur.atl.sa.earthlink.net ([209.86.89.65]:47408 "EHLO
	elasmtp-kukur.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754097AbZIBFLr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 01:11:47 -0400
In-Reply-To: <20090827175151.GC4762@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 27 Aug 2009, Neil Horman wrote:

> On Thu, Aug 27, 2009 at 01:44:29PM -0400, Bill Fink wrote:
> > On Wed, 26 Aug 2009, Neil Horman wrote:
> > 
> > > On Wed, Aug 26, 2009 at 07:00:13AM -0400, Neil Horman wrote:
> > > > On Wed, Aug 26, 2009 at 03:10:57AM -0400, Bill Fink wrote:
> > > > 
> > > > > Fortunately, in this specific case, the SuperMicro X8DAH+-F system
> > > > > does have a serial console, and after a fair amount of effort I was
> > > > > able to get it to work as desired, and was able to finally capture
> > > > > a backtrace of the kernel oops.  BTW I believe the reason the
> > > > > kexec/kdump didn't work was probably because it couldn't find
> > > > > a /proc/vmcore file, although I don't know why that would be,
> > > > > and the Fedora 10 /etc/init.d/kdump script will then just boot
> > > > > up normally if it fails to find the /proc/vmcore file (or it's
> > > > > zero size).
> > > > > 
> > > > I take care of kdump for fedora and RHEL.  If you file a bug on this, I'd be
> > > > happy to look into it further.
> > > > 
> > > > > The following shows a simple ping test usage of the skb_sources
> > > > > tracing feature:
> > > > > 
> > > > > [root@xeontest1 tracing]# numactl --membind=1 taskset -c 4 ping -c 5 -s 1472 192.168.1.10
> > > > > PING 192.168.1.10 (192.168.1.10) 1472(1500) bytes of data.
> > > > > 1480 bytes from 192.168.1.10: icmp_seq=1 ttl=64 time=0.139 ms
> > > > > 1480 bytes from 192.168.1.10: icmp_seq=2 ttl=64 time=0.182 ms
> > > > > 1480 bytes from 192.168.1.10: icmp_seq=3 ttl=64 time=0.178 ms
> > > > > 1480 bytes from 192.168.1.10: icmp_seq=4 ttl=64 time=0.188 ms
> > > > > 1480 bytes from 192.168.1.10: icmp_seq=5 ttl=64 time=0.178 ms
> > > > > 
> > > > > --- 192.168.1.10 ping statistics ---
> > > > > 5 packets transmitted, 5 received, 0% packet loss, time 3999ms
> > > > > rtt min/avg/max/mdev = 0.139/0.173/0.188/0.017 ms
> > > > > 
> > > > > [root@xeontest1 tracing]# cat trace
> > > > > # tracer: skb_sources
> > > > > #
> > > > > #       PID     ANID    CNID    IFC     RXQ     CCPU    LEN
> > > > > #        |       |       |       |       |       |       |
> > > > >         4217    1       1       eth2    0       4       1500
> > > > >         4217    1       1       eth2    0       4       1500
> > > > >         4217    1       1       eth2    0       4       1500
> > > > >         4217    1       1       eth2    0       4       1500
> > > > >         4217    1       1       eth2    0       4       1500
> > > > > 
> > > > > All is as was expected.
> > > > > 
> > > > > But if I try an actual nuttcp performance test (even rate limited
> > > > > to 1 Mbps), I get the following kernel oops:
> > > > > 
> > > > thank you, I think I see the problem, I'll have a patch for you in just a bit
> > > > 
> > > > Thanks
> > > > Neil
> > > > 
> > > > > [root@xeontest1 tracing]# numactl --membind=1 nuttcp -In2 -Ri1m -xc4/0 192.168.1.10
> > > > > BUG: unable to handle kernel NULL pointer dereference at 0000000000000038
> > > > > IP: [<ffffffff810b01ab>] probe_skb_dequeue+0xf7/0x152
> > > > > PGD 337d12067 PUD 337d11067 PMD 0
> > > > > Oops: 0000 [#1] SMP
> > > > > last sysfs file: /sys/devices/pci0000:80/0000:80:07.0/0000:8b:00.0/0000:8c:04.0e
> > > > > CPU 4
> > > > > Modules linked in: w83627ehf hwmon_vid coretemp hwmon ipv6 dm_multipath uinput ]
> > > > > Pid: 4222, comm: nuttcp Not tainted 2.6.31-rc6-bf #3 X8DAH
> > > > > RIP: 0010:[<ffffffff810b01ab>]  [<ffffffff810b01ab>] probe_skb_dequeue+0xf7/0x12
> > > > > RSP: 0018:ffff8801a5811a88  EFLAGS: 00010213
> > > > > RAX: 0000000000000000 RBX: ffff88033906d154 RCX: 000000000000000d
> > > > > RDX: 000000000000f88c RSI: 000000000000000b RDI: ffff8803383d3044
> > > > > RBP: ffff8801a5811ab8 R08: 0000000000000001 R09: ffff8801ab311a00
> > > > > R10: 0000000000000005 R11: ffffc9000080e2b0 R12: ffff880337c45400
> > > > > R13: ffff88033906d150 R14: 0000000000000014 R15: ffffffff818bb890
> > > > > FS:  00007fa976d326f0(0000) GS:ffffc90000800000(0000) knlGS:0000000000000000
> > > > > CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > > > > CR2: 0000000000000038 CR3: 000000033801e000 CR4: 00000000000006e0
> > > > > DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > > > > DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> > > > > Process nuttcp (pid: 4222, threadinfo ffff8801a5810000, task ffff8801ab2e5d00)
> > > > > Stack:
> > > > >  ffff8801a5811ab8 ffff8801b35d4ab0 0000000000000014 0000000000000000
> > > > > <0> 0000000000000014 0000000000000014 ffff8801a5811b18 ffffffff81366ae8
> > > > > <0> ffff8801a5811ed8 0000001439084000 ffff880337c45400 00000001001416ef
> > > > > Call Trace:
> > > > >  [<ffffffff81366ae8>] skb_copy_datagram_iovec+0x50/0x1f5
> > > > >  [<ffffffff813ac875>] tcp_rcv_established+0x278/0x6db
> > > > >  [<ffffffff813b3ef5>] tcp_v4_do_rcv+0x1b8/0x366
> > > > >  [<ffffffff8135f99e>] ? release_sock+0xab/0xb4
> > > > >  [<ffffffff8136004d>] ? sk_wait_data+0xc8/0xd6
> > > > >  [<ffffffff813a32d6>] tcp_prequeue_process+0x79/0x8f
> > > > >  [<ffffffff813a455d>] tcp_recvmsg+0x4e8/0xaa0
> > > > >  [<ffffffff8135ec90>] sock_common_recvmsg+0x37/0x4c
> > > > >  [<ffffffff8135cb06>] __sock_recvmsg+0x72/0x7f
> > > > >  [<ffffffff8135cbdd>] sock_aio_read+0xca/0xda
> > > > >  [<ffffffff810d9536>] ? vma_merge+0x2a0/0x318
> > > > >  [<ffffffff810f6d4f>] do_sync_read+0xec/0x132
> > > > >  [<ffffffff81067ddc>] ? autoremove_wake_function+0x0/0x3d
> > > > >  [<ffffffff811b646c>] ? security_file_permission+0x16/0x18
> > > > >  [<ffffffff810f785c>] vfs_read+0xc0/0x107
> > > > >  [<ffffffff810f7971>] sys_read+0x4c/0x75
> > > > >  [<ffffffff81011c82>] system_call_fastpath+0x16/0x1b
> > > > > Code: 44 89 73 30 89 43 14 41 0f b7 84 24 ac 00 00 00 89 43 28 65 8b 04 25 98 e
> > > > > RIP  [<ffffffff810b01ab>] probe_skb_dequeue+0xf7/0x152
> > > > >  RSP <ffff8801a5811a88>
> > > > > CR2: 0000000000000038
> > > 
> > > 
> > > 
> > > Here  you go, I think this will fix your oops.
> > > 
> > > 
> > >     Fix NULL pointer deref in skb sources ftracer
> > >     
> > >     Its possible that skb->sk will be null in this path, so we shouldn't just assume
> > >     we can pass it to sock_net
> > >     
> > >     Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> > > 
> > >  trace_skb_sources.c |    6 ++++--
> > >  1 file changed, 4 insertions(+), 2 deletions(-)
> > > 
> > > diff --git a/kernel/trace/trace_skb_sources.c b/kernel/trace/trace_skb_sources.c
> > > index 40eb071..8bf518f 100644
> > > --- a/kernel/trace/trace_skb_sources.c
> > > +++ b/kernel/trace/trace_skb_sources.c
> > > @@ -29,7 +29,7 @@ static void probe_skb_dequeue(const struct sk_buff *skb, int len)
> > >  	struct ring_buffer_event *event;
> > >  	struct trace_skb_event *entry;
> > >  	struct trace_array *tr = skb_trace;
> > > -	struct net_device *dev;
> > > +	struct net_device *dev = NULL;
> > >  
> > >  	if (!trace_skb_source_enabled)
> > >  		return;
> > > @@ -50,7 +50,9 @@ static void probe_skb_dequeue(const struct sk_buff *skb, int len)
> > >  	entry->event_data.rx_queue = skb->queue_mapping;
> > >  	entry->event_data.ccpu = smp_processor_id();
> > >  
> > > -	dev = dev_get_by_index(sock_net(skb->sk), skb->iif);
> > > +	if (skb->sk)
> > > +		dev = dev_get_by_index(sock_net(skb->sk), skb->iif);
> > > +
> > >  	if (dev) {
> > >  		memcpy(entry->event_data.ifname, dev->name, IFNAMSIZ);
> > >  		dev_put(dev);
> > 
> > 
> > 
> > On the positive side, it did fix the oops.  But the results of the
> > skb_sources tracing was not that useful.
> > 
> > [root@xeontest1 tracing]# numactl --membind=1 nuttcp -In2 -xc4/0 192.168.1.10 & ps ax | grep nuttcp
> >  5521 ttyS0    S      0:00 nuttcp -In2 -xc4/0 192.168.1.10
> > n2: 11819.0786 MB /  10.01 sec = 9905.6427 Mbps 26 %TX 37 %RX 0 retrans 0.18 msRTT
> > 
> > First off, only 10 trace entries were made:
> > 
> > [root@xeontest1 tracing]# wc trace
> > 14 90 334 trace
> > 
> > And here they are:
> > 
> > [root@xeontest1 tracing]# cat trace
> > # tracer: skb_sources
> > #
> > #       PID     ANID    CNID    IFC     RXQ     CCPU    LEN
> > #        |       |       |       |       |       |       |
> >         5521    0       0       Unknown 0       3       888
> >         5521    0       0       Unknown 0       3       896
> >         5521    0       0       Unknown 0       3       20
> >         5521    0       0       Unknown 0       3       888
> >         5521    0       0       Unknown 0       3       896
> >         5521    0       0       Unknown 0       3       20
> >         5521    1       1       Unknown 0       4       20
> >         5521    1       1       Unknown 0       4       11
> >         5521    1       1       Unknown 0       4       540
> >         5521    1       1       Unknown 0       4       0
> > 
> > Even for these 10 entries, why is the IFC Unknown, and the LENs
> > seem to be wrong too.
> > 
> > 						-Bill
> > 
> I'm not sure why you're getting Unknown Interface names.  Nominally that
> indicates that the skb->iif value in the skb was incorrect or otherwise not set,
> which shouldn't be the case.  As for the lengths that just seems wrong.  That
> length value is taken directly from skb->len, so if its not right, it seems like
> its not getting set correctly someplace.
> 
> As you may have seen we're removing the ftrace module, and replacing it with the
> use of raw trace events.  When I have that working, I'll see if I get simmilar
> results.  I never did in my local testing of the ftrace module, but perhaps its
> related to load or something.

IIUC I should keep the first of your original three ftrace patches,
revert all the rest, and then apply your very latest patch that
augments the skb_copy_datagram_iovec TRACE_EVENT.  Do I have that
basically correct?

Then I just need to ask how do I use this new method?

						-Thanks

						-Bill
