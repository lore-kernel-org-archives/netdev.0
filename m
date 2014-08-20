From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] vhost: Add polling mode
Date: Wed, 20 Aug 2014 12:32:04 +0200
Message-ID: <20140820103204.GB17371@redhat.com>
References: <1407659404-razya@il.ibm.com>
	<20140810083035.0CF58380729@moren.haifa.ibm.com>
	<53F45F3C.5000207@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ERANRA@il.ibm.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org,
	Razya Ladelsky <razya@il.ibm.com>, GLIKSON@il.ibm.com,
	YOSSIKU@il.ibm.com, abel.gordon@gmail.com, JOELN@il.ibm.com,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Christian Borntraeger <borntraeger@de.ibm.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <53F45F3C.5000207@de.ibm.com>
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

On Wed, Aug 20, 2014 at 10:41:32AM +0200, Christian Borntraeger wrote:
> On 10/08/14 10:30, Razya Ladelsky wrote:
> > From: Razya Ladelsky <razya@il.ibm.com>
> > Date: Thu, 31 Jul 2014 09:47:20 +0300
> > Subject: [PATCH] vhost: Add polling mode
> > 
> > When vhost is waiting for buffers from the guest driver (e.g., more packets to
> > send in vhost-net's transmit queue), it normally goes to sleep and waits for the
> > guest to "kick" it. This kick involves a PIO in the guest, and therefore an exit
> > (and possibly userspace involvement in translating this PIO exit into a file
> > descriptor event), all of which hurts performance.
> > 
> > If the system is under-utilized (has cpu time to spare), vhost can continuously
> > poll the virtqueues for new buffers, and avoid asking the guest to kick us.
> > This patch adds an optional polling mode to vhost, that can be enabled via a
> > kernel module parameter, "poll_start_rate".
> > 
> > When polling is active for a virtqueue, the guest is asked to disable
> > notification (kicks), and the worker thread continuously checks for new buffers.
> > When it does discover new buffers, it simulates a "kick" by invoking the
> > underlying backend driver (such as vhost-net), which thinks it got a real kick
> > from the guest, and acts accordingly. If the underlying driver asks not to be
> > kicked, we disable polling on this virtqueue.
> > 
> > We start polling on a virtqueue when we notice it has work to do. Polling on
> > this virtqueue is later disabled after 3 seconds of polling turning up no new
> > work, as in this case we are better off returning to the exit-based notification
> > mechanism. The default timeout of 3 seconds can be changed with the
> > "poll_stop_idle" kernel module parameter.
> > 
> > This polling approach makes lot of sense for new HW with posted-interrupts for
> > which we have exitless host-to-guest notifications. But even with support for
> > posted interrupts, guest-to-host communication still causes exits. Polling adds
> > the missing part.
> > 
> > When systems are overloaded, there won't be enough cpu time for the various
> > vhost threads to poll their guests' devices. For these scenarios, we plan to add
> > support for vhost threads that can be shared by multiple devices, even of
> > multiple vms.
> > Our ultimate goal is to implement the I/O acceleration features described in:
> > KVM Forum 2013: Efficient and Scalable Virtio (by Abel Gordon)
> > https://www.youtube.com/watch?v=9EyweibHfEs
> > and
> > https://www.mail-archive.com/kvm@vger.kernel.org/msg98179.html
> > 
> > I ran some experiments with TCP stream netperf and filebench (having 2 threads
> > performing random reads) benchmarks on an IBM System x3650 M4.
> > I have two machines, A and B. A hosts the vms, B runs the netserver.
> > The vms (on A) run netperf, its destination server is running on B.
> > All runs loaded the guests in a way that they were (cpu) saturated. For example,
> > I ran netperf with 64B messages, which is heavily loading the vm (which is why
> > its throughput is low).
> > The idea was to get it 100% loaded, so we can see that the polling is getting it
> > to produce higher throughput.
> > 
> > The system had two cores per guest, as to allow for both the vcpu and the vhost
> > thread to run concurrently for maximum throughput (but I didn't pin the threads
> > to specific cores).
> > My experiments were fair in a sense that for both cases, with or without
> > polling, I run both threads, vcpu and vhost, on 2 cores (set their affinity that
> > way). The only difference was whether polling was enabled/disabled.
> > 
> > Results:
> > 
> > Netperf, 1 vm:
> > The polling patch improved throughput by ~33% (1516 MB/sec -> 2046 MB/sec).
> > Number of exits/sec decreased 6x.
> > The same improvement was shown when I tested with 3 vms running netperf
> > (4086 MB/sec -> 5545 MB/sec).
> > 
> > filebench, 1 vm:
> > ops/sec improved by 13% with the polling patch. Number of exits was reduced by
> > 31%.
> > The same experiment with 3 vms running filebench showed similar numbers.
> > 
> > Signed-off-by: Razya Ladelsky <razya@il.ibm.com>
> 
> Gave it a quick try on s390/kvm. As expected it makes no difference for big streaming workload like iperf.
> uperf with a 1-1 round robin got indeed faster by about 30%.
> The high CPU consumption is something that bothers me though, as virtualized systems tend to be full.
> 
> 
> > +static int poll_start_rate = 0;
> > +module_param(poll_start_rate, int, S_IRUGO|S_IWUSR);
> > +MODULE_PARM_DESC(poll_start_rate, "Start continuous polling of virtqueue when rate of events is at least this number per jiffy. If 0, never start polling.");
> > +
> > +static int poll_stop_idle = 3*HZ; /* 3 seconds */
> > +module_param(poll_stop_idle, int, S_IRUGO|S_IWUSR);
> > +MODULE_PARM_DESC(poll_stop_idle, "Stop continuous polling of virtqueue after this many jiffies of no work.");
> 
> This seems ridicoudly high. Even one jiffie is an eternity, so setting it to 1 as a default would reduce the CPU overhead for most cases.
> If we dont have a packet in one millisecond, we can surely go back to the kick approach, I think.
> 
> Christian


Seconded.
Could you publish data with different poll_stop_idle values?
Additionally, time in jiffies is not a reasonable userspace
API. Please switch to some reasonable unit, like microseconds.

Thinking more about it, isn't this almost exactly what net.core.busy_poll does?
That one suggests 50usec timeout.

The only difference I see is in poll_start_rate heuristic,
net.core does not have anything like this.
Do you have data to show that it's helpful - as opposed to just
starting polling whenever an event arrives?
If yes, might it be useful for net core as well?

Only setting timeout globally isn't friendly either.
Should be a tun ioctl similar to SO_BUSY_POLL.

-- 
MST
