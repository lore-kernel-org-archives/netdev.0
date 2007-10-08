From: jamal <hadi@cyberus.ca>
Subject: [ofa-general] Re: parallel networking (was Re: [PATCH 1/4]
	[NET_SCHED] explict hold dev tx lock)
Date: Mon, 08 Oct 2007 11:18:29 -0400
Message-ID: <1191856709.4352.124.camel@localhost>
References: <1190674298.4264.24.camel@localhost>
	<D5C1322C3E673F459512FB59E0DDC32903A51462@orsmsx414.amr.corp.intel.com>
	<1190677099.4264.37.camel@localhost>
	<20071007.215124.85709188.davem@davemloft.net>
	<1191850490.4352.41.camel@localhost>  <470A3D24.3050803@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: randy.dunlap@oracle.com, Robert.Olsson@data.slu.se, gaagaan@gmail.com,
	kumarkr@linux.ibm.com, peter.p.waskiewicz.jr@intel.com,
	shemminger@linux-foundation.org, johnpol@2ka.mipt.ru,
	herbert@gondor.apana.org.au, rdreier@cisco.com,
	general@lists.openfabrics.org, Ingo Molnar <mingo@elte.hu>,
	sri@us.ibm.com, jagana@us.ibm.com, mchan@broadcom.com,
	netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>, tgraf@suug.ch, kaber@trash.net
To: Jeff Garzik <jeff@garzik.org>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <470A3D24.3050803@garzik.org>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-08-10 at 10:22 -0400, Jeff Garzik wrote:

> Any chance the NIC hardware could provide that guarantee?

If you can get the scheduling/dequeuing to run on one CPU (as we do
today) it should work; alternatively you can totaly bypass the qdisc
subystem and go direct to the hardware for devices that are capable
and that would work but would require huge changes. 
My fear is there's a mini-scheduler pieces running on multi cpus which
is what i understood as being described.

> 8139cp, for example, has two TX DMA rings, with hardcoded 
> characteristics:  one is a high prio q, and one a low prio q.  The logic 
> is pretty simple:   empty the high prio q first (potentially starving 
> low prio q, in worst case).

sounds like strict prio scheduling to me which says "if low prio starves
so be it"

> In terms of overall parallelization, both for TX as well as RX, my gut 
> feeling is that we want to move towards an MSI-X, multi-core friendly 
> model where packets are LIKELY to be sent and received by the same set 
> of [cpus | cores | packages | nodes] that the [userland] processes 
> dealing with the data.

Does putting things in the same core help? But overall i agree with your
views. 

> There are already some primitive NUMA bits in skbuff allocation, but 
> with modern MSI-X and RX/TX flow hashing we could do a whole lot more, 
> along the lines of better CPU scheduling decisions, directing flows to 
> clusters of cpus, and generally doing a better job of maximizing cache 
> efficiency in a modern multi-thread environment.

I think i see the receive with a lot of clarity, i am still foggy on the
txmit path mostly because of the qos/scheduling issues. 

> IMO the current model where each NIC's TX completion and RX processes 
> are both locked to the same CPU is outmoded in a multi-core world with 
> modern NICs.  :)

Infact even with status quo theres a case that can be made to not bind
to interupts.
In my recent experience with batching, due to the nature of my test app,
if i let the interupts float across multiple cpus i benefit.
My app runs/binds a thread per CPU and so benefits from having more
juice to send more packets per unit of time - something i wouldnt get if
i was always running on one cpu.
But when i do this i found that just because i have bound a thread to
cpu3 doesnt mean that thread will always run on cpu3. If netif_wakeup
happens on cpu1, scheduler will put the thread on cpu1 if it is to be
run. It made sense to do that, it just took me a while to digest.

> But I readily admit general ignorance about the kernel process 
> scheduling stuff, so my only idea about a starting point was to see how 
> far to go with the concept of "skb affinity" -- a mask in sk_buff that 
> is a hint about which cpu(s) on which the NIC should attempt to send and 
> receive packets.  When going through bonding or netfilter, it is trivial 
> to 'or' together affinity masks.  All the various layers of net stack 
> should attempt to honor the skb affinity, where feasible (requires 
> interaction with CFS scheduler?).

There would be cache benefits if you can free the packet on the same cpu
it was allocated; so the idea of skb affinity is useful in the minimal
in that sense if you can pull it. Assuming hardware is capable, even if
you just tagged it on xmit to say which cpu it was sent out on, and made
sure thats where it is freed, that would be a good start. 

Note: The majority of the packet processing overhead is _still_ the
memory subsystem latency; in my tests with batched pktgen improving the 
xmit subsystem meant the overhead on allocing and freeing the packets
went to something > 80%.
So something along the lines of parallelizing based on a split of alloc
free of sksb IMO on more cpus than where xmit/receive run would see
more performance improvements.

> Or maybe skb affinity is a dumb idea.  I wanted to get people thinking 
> on the bigger picture.  Parallelization starts at the user process.


cheers,
jamal
