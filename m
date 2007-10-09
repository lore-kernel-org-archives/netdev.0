From: Jeff Garzik <jeff@garzik.org>
Subject: [ofa-general] Re: parallel networking
Date: Mon, 08 Oct 2007 21:53:25 -0400
Message-ID: <470ADF15.2090100@garzik.org>
References: <20071007.215124.85709188.davem@davemloft.net>	<1191850490.4352.41.camel@localhost>	<470A3D24.3050803@garzik.org>
	<20071008.141154.107706003.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: randy.dunlap@oracle.com, Robert.Olsson@data.slu.se, gaagaan@gmail.com,
	kumarkr@linux.ibm.com, peter.p.waskiewicz.jr@intel.com,
	shemminger@linux-foundation.org, johnpol@2ka.mipt.ru,
	herbert@gondor.apana.org.au, rdreier@cisco.com,
	general@lists.openfabrics.org, mingo@elte.hu, sri@us.ibm.com,
	jagana@us.ibm.com, hadi@cyberus.ca, mchan@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tgraf@suug.ch, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20071008.141154.107706003.davem@davemloft.net>
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

David Miller wrote:
> From: Jeff Garzik <jeff@garzik.org>
> Date: Mon, 08 Oct 2007 10:22:28 -0400
> 
>> In terms of overall parallelization, both for TX as well as RX, my gut 
>> feeling is that we want to move towards an MSI-X, multi-core friendly 
>> model where packets are LIKELY to be sent and received by the same set 
>> of [cpus | cores | packages | nodes] that the [userland] processes 
>> dealing with the data.
> 
> The problem is that the packet schedulers want global guarantees
> on packet ordering, not flow centric ones.
> 
> That is the issue Jamal is concerned about.

Oh, absolutely.

I think, fundamentally, any amount of cross-flow resource management 
done in software is an obstacle to concurrency.

That's not a value judgement, just a statement of fact.

"traffic cops" are intentional bottlenecks we add to the process, to 
enable features like priority flows, filtering, or even simple socket 
fairness guarantees.  Each of those bottlenecks serves a valid purpose, 
but at the end of the day, it's still a bottleneck.

So, improving concurrency may require turning off useful features that 
nonetheless hurt concurrency.


> The more I think about it, the more inevitable it seems that we really
> might need multiple qdiscs, one for each TX queue, to pull this full
> parallelization off.
> 
> But the semantics of that don't smell so nice either.  If the user
> attaches a new qdisc to "ethN", does it go to all the TX queues, or
> what?
> 
> All of the traffic shaping technology deals with the device as a unary
> object.  It doesn't fit to multi-queue at all.

Well the easy solutions to networking concurrency are

* use virtualization to carve up the machine into chunks

* use multiple net devices

Since new NIC hardware is actively trying to be friendly to 
multi-channel/virt scenarios, either of these is reasonably 
straightforward given the current state of the Linux net stack.  Using 
multiple net devices is especially attractive because it works very well 
with the existing packet scheduling.

Both unfortunately impose a burden on the developer and admin, to force 
their apps to distribute flows across multiple [VMs | net devs].


The third alternative is to use a single net device, with SMP-friendly 
packet scheduling.  Here you run into the problems you described "device 
as a unary object" etc. with the current infrastructure.

With multiple TX rings, consider that we are pushing the packet 
scheduling from software to hardware...  which implies
* hardware-specific packet scheduling
* some TC/shaping features not available, because hardware doesn't 
support it

	Jeff
