From: Michael Krause <krause@cup.hp.com>
Subject: Re: [ofa-general] Re: parallel networking
Date: Tue, 09 Oct 2007 07:59:17 -0700
Message-ID: <6.2.0.14.2.20071009073934.02539930@esmail.cup.hp.com>
References: <20071007.215124.85709188.davem@davemloft.net>
	<1191850490.4352.41.camel@localhost> <470A3D24.3050803@garzik.org>
	<20071008.141154.107706003.davem@davemloft.net>
	<470ADF15.2090100@garzik.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0588400607=="
Cc: randy.dunlap@oracle.com, Robert.Olsson@data.slu.se,
	herbert@gondor.apana.org.au, gaagaan@gmail.com,
	kumarkr@linux.ibm.com, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, hadi@cyberus.ca,
	linux-kernel@vger.kernel.org, kaber@trash.net, jagana@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	mingo@elte.hu, johnpol@2ka.mipt.ru,
	shemminger@linux-foundation.org, netdev@vger.kernel.org, sri@us.ibm.com
To: Jeff Garzik <jeff@garzik.org>, David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <470ADF15.2090100@garzik.org>
References: <20071007.215124.85709188.davem@davemloft.net>
	<1191850490.4352.41.camel@localhost> <470A3D24.3050803@garzik.org>
	<20071008.141154.107706003.davem@davemloft.net>
	<470ADF15.2090100@garzik.org>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Mime-version: 1.0
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

--===============0588400607==
Content-Type: multipart/alternative;
	boundary="=====================_-1784332795==.ALT"

--=====================_-1784332795==.ALT
Content-Type: text/plain; charset="us-ascii"; format=flowed

At 06:53 PM 10/8/2007, Jeff Garzik wrote:
>David Miller wrote:
>>From: Jeff Garzik <jeff@garzik.org>
>>Date: Mon, 08 Oct 2007 10:22:28 -0400
>>
>>>In terms of overall parallelization, both for TX as well as RX, my gut 
>>>feeling is that we want to move towards an MSI-X, multi-core friendly 
>>>model where packets are LIKELY to be sent and received by the same set 
>>>of [cpus | cores | packages | nodes] that the [userland] processes 
>>>dealing with the data.
>>The problem is that the packet schedulers want global guarantees
>>on packet ordering, not flow centric ones.
>>That is the issue Jamal is concerned about.
>
>Oh, absolutely.
>
>I think, fundamentally, any amount of cross-flow resource management done 
>in software is an obstacle to concurrency.
>
>That's not a value judgement, just a statement of fact.

Correct.


>"traffic cops" are intentional bottlenecks we add to the process, to 
>enable features like priority flows, filtering, or even simple socket 
>fairness guarantees.  Each of those bottlenecks serves a valid purpose, 
>but at the end of the day, it's still a bottleneck.
>
>So, improving concurrency may require turning off useful features that 
>nonetheless hurt concurrency.

Software needs to get out of the main data path - another fact of life.



>>The more I think about it, the more inevitable it seems that we really
>>might need multiple qdiscs, one for each TX queue, to pull this full
>>parallelization off.
>>But the semantics of that don't smell so nice either.  If the user
>>attaches a new qdisc to "ethN", does it go to all the TX queues, or
>>what?
>>All of the traffic shaping technology deals with the device as a unary
>>object.  It doesn't fit to multi-queue at all.
>
>Well the easy solutions to networking concurrency are
>
>* use virtualization to carve up the machine into chunks
>
>* use multiple net devices
>
>Since new NIC hardware is actively trying to be friendly to 
>multi-channel/virt scenarios, either of these is reasonably 
>straightforward given the current state of the Linux net stack.  Using 
>multiple net devices is especially attractive because it works very well 
>with the existing packet scheduling.
>
>Both unfortunately impose a burden on the developer and admin, to force 
>their apps to distribute flows across multiple [VMs | net devs].

Not the most optimal approach.

>The third alternative is to use a single net device, with SMP-friendly 
>packet scheduling.  Here you run into the problems you described "device 
>as a unary object" etc. with the current infrastructure.
>
>With multiple TX rings, consider that we are pushing the packet scheduling 
>from software to hardware...  which implies
>* hardware-specific packet scheduling
>* some TC/shaping features not available, because hardware doesn't support it

For a number of years now, we have designed interconnects to support a 
reasonable range of arbitration capabilities among hardware resource 
sets.  With reasonable classification by software to identify a hardware 
resource sets (ideally interpretation of the application's view of its 
priority combined with policy management software that determines how that 
should map among competing application views), one can eliminate most of 
the CPU cycles spent into today's implementations.   I and others presented 
a number of these concepts many years ago during the development which 
eventually led to IB and iWARP.

- Each resource set can be assigned to a unique PCIe function or a function 
group to enable function / group arbitration to the PCIe link.

- Each resource set can be assigned to a unique PCIe TC and with improved 
ordering hints (coming soon) can be used to eliminate false ordering 
dependencies.

- Each resource set can be assigned to a unique IB TC / SL or iWARP 802.1p 
to signal priority.  These can then be used to program respective link 
arbitration as well as path selection to enable multi-path load balancing.

- Many IHV have picked up on the arbitration capabilities and extended them 
as shown years ago by a number of us to enable resource set arbitration and 
a variety of QoS based policies.  If software defines a reasonable (i.e. 
small) number of management and control knobs, then these can be easily 
mapped to most h/w implementations.   Some of us are working on how to do 
this for virtualized environments and I expect these to be applicable to 
all environments in the end.

One other key item to keep in mind is that unless there is contention in 
the system, the majority of the QoS mechanisms are meaningless and in a 
very large percentage of customer environments, they simply don't scale 
with device and interconnect performance.   Many applications in fact 
remain processor / memory constrained and therefore do not stress the I/O 
subsystem or the external interconnects making most of the software 
mechanisms rather moot in real customer environments.   Simple truth is it 
is nearly always cheaper to over-provision the I/O / interconnects than to 
use the software approach which while quite applicable in many environments 
for the 1 Gbps and below speeds, generally has less meaning / value in the 
10 moving to 40 moving to 100 Gbps environments.   Does not really matter 
whether one believes in protocol off-load or protocol on-load, the 
interconnects will be able to handle all commercial workloads and perhaps 
all but the most extreme HPC (even there one might contend that any 
software intermediary would be discarded in favor of reducing OS / kernel 
overhead from the main data path).  This isn't to say that software has no 
role to play only that role needs to shift from main data path overhead to 
one of policy shaping and programming of h/w based arbitration.   This will 
hold true for both virtualized and non-virtualized environments.

Mike 
--=====================_-1784332795==.ALT
Content-Type: text/html; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<html>
<body>
<font size=3D3>At 06:53 PM 10/8/2007, Jeff Garzik wrote:<br>
<blockquote type=3Dcite class=3Dcite cite=3D"">David Miller wrote:<br>
<blockquote type=3Dcite class=3Dcite cite=3D"">From: Jeff Garzik
&lt;jeff@garzik.org&gt;<br>
Date: Mon, 08 Oct 2007 10:22:28 -0400<br><br>
<blockquote type=3Dcite class=3Dcite cite=3D"">In terms of overall
parallelization, both for TX as well as RX, my gut feeling is that we
want to move towards an MSI-X, multi-core friendly model where packets
are LIKELY to be sent and received by the same set of [cpus | cores |
packages | nodes] that the [userland] processes dealing with the
data.</blockquote>The problem is that the packet schedulers want global
guarantees<br>
on packet ordering, not flow centric ones.<br>
That is the issue Jamal is concerned about.</blockquote><br>
Oh, absolutely.<br><br>
I think, fundamentally, any amount of cross-flow resource management done
in software is an obstacle to concurrency.<br><br>
That's not a value judgement, just a statement of
fact.</font></blockquote><br>
Correct.<br><br>
<br>
<blockquote type=3Dcite class=3Dcite cite=3D""><font size=3D3>&quot;traffic
cops&quot; are intentional bottlenecks we add to the process, to enable
features like priority flows, filtering, or even simple socket fairness
guarantees.&nbsp; Each of those bottlenecks serves a valid purpose, but
at the end of the day, it's still a bottleneck.<br><br>
So, improving concurrency may require turning off useful features that
nonetheless hurt concurrency.</font></blockquote><br>
Software needs to get out of the main data path - another fact of
life.<br><br>
<br><br>
<blockquote type=3Dcite class=3Dcite cite=3D"">
<blockquote type=3Dcite class=3Dcite cite=3D""><font size=3D3>The more I thi=
nk
about it, the more inevitable it seems that we really<br>
might need multiple qdiscs, one for each TX queue, to pull this full<br>
parallelization off.<br>
But the semantics of that don't smell so nice either.&nbsp; If the
user<br>
attaches a new qdisc to &quot;ethN&quot;, does it go to all the TX
queues, or<br>
what?<br>
All of the traffic shaping technology deals with the device as a
unary<br>
object.&nbsp; It doesn't fit to multi-queue at all.</blockquote><br>
Well the easy solutions to networking concurrency are<br><br>
* use virtualization to carve up the machine into chunks<br><br>
* use multiple net devices<br><br>
Since new NIC hardware is actively trying to be friendly to
multi-channel/virt scenarios, either of these is reasonably
straightforward given the current state of the Linux net stack.&nbsp;
Using multiple net devices is especially attractive because it works very
well with the existing packet scheduling.<br><br>
Both unfortunately impose a burden on the developer and admin, to force
their apps to distribute flows across multiple [VMs | net
devs].</font></blockquote><br>
Not the most optimal approach.<br><br>
<blockquote type=3Dcite class=3Dcite cite=3D""><font size=3D3>The third
alternative is to use a single net device, with SMP-friendly packet
scheduling.&nbsp; Here you run into the problems you described
&quot;device as a unary object&quot; etc. with the current
infrastructure.<br><br>
With multiple TX rings, consider that we are pushing the packet
scheduling from software to hardware...&nbsp; which implies<br>
* hardware-specific packet scheduling<br>
* some TC/shaping features not available, because hardware doesn't
support it</blockquote><br>
For a number of years now, we have designed interconnects to support a
reasonable range of arbitration capabilities among hardware resource
sets.&nbsp; With reasonable classification by software to identify a
hardware resource sets (ideally interpretation of the application's view
of its priority combined with policy management software that determines
how that should map among competing application views), one can eliminate
most of the CPU cycles spent into today's implementations.&nbsp;&nbsp; I
and others presented a number of these concepts many years ago during the
development which eventually led to IB and iWARP.<br><br>
- Each resource set can be assigned to a unique PCIe function or a
function group to enable function / group arbitration to the PCIe
link.<br><br>
- Each resource set can be assigned to a unique PCIe TC and with improved
ordering hints (coming soon) can be used to eliminate false ordering
dependencies.<br><br>
- Each resource set can be assigned to a unique IB TC / SL or iWARP
802.1p to signal priority.&nbsp; These can then be used to program
respective link arbitration as well as path selection to enable
multi-path load balancing. <br><br>
- Many IHV have picked up on the arbitration capabilities and extended
them as shown years ago by a number of us to enable resource set
arbitration and a variety of QoS based policies.&nbsp; If software
defines a reasonable (i.e. small) number of management and control knobs,
then these can be easily mapped to most h/w implementations.&nbsp;&nbsp;
Some of us are working on how to do this for virtualized environments and
I expect these to be applicable to all environments in the end.<br><br>
One other key item to keep in mind is that unless there is contention in
the system, the majority of the QoS mechanisms are meaningless and in a
very large percentage of customer environments, they simply don't scale
with device and interconnect performance.&nbsp;&nbsp; Many applications
in fact remain processor / memory constrained and therefore do not stress
the I/O subsystem or the external interconnects making most of the
software mechanisms rather moot in real customer
environments.&nbsp;&nbsp; Simple truth is it is nearly always cheaper to
over-provision the I/O / interconnects than to use the software approach
which while quite applicable in many environments for the 1 Gbps and
below speeds, generally has less meaning / value in the 10 moving to 40
moving to 100 Gbps environments.&nbsp;&nbsp; Does not really matter
whether one believes in protocol off-load or protocol on-load, the
interconnects will be able to handle all commercial workloads and perhaps
all but the most extreme HPC (even there one might contend that any
software intermediary would be discarded in favor of reducing OS / kernel
overhead from the main data path).&nbsp; This isn't to say that software
has no role to play only that role needs to shift from main data path
overhead to one of policy shaping and programming of h/w based
arbitration.&nbsp;&nbsp; This will hold true for both virtualized and
non-virtualized environments.<br><br>
Mike</font></body>
</html>

--=====================_-1784332795==.ALT--


--===============0588400607==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============0588400607==--
