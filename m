From: jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>
Subject: Re: Open vSwitch Design
Date: Thu, 24 Nov 2011 17:30:33 -0500
Message-ID: <1322173833.1944.5.camel@mojatatu>
References: <CAEP_g=_2L1xFWtDXh_6YyXz1Mt9TR3zvjLzix+SpO6yzeOLsSQ@mail.gmail.com>
Reply-To: jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, Chris Wright <chrisw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <CAEP_g=_2L1xFWtDXh_6YyXz1Mt9TR3zvjLzix+SpO6yzeOLsSQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Jesse,

I am going to try and respond to your comments below.

On Thu, 2011-11-24 at 12:10 -0800, Jesse Gross wrote:

> 
>  * Switching infrastructure:  As the name implies, Open vSwitch is
> intended to be a network switch, focused on
> virtualization/OpenFlow/software defined networking.  This means that
> what we are modeling is not actually a collection of flows but a
> switch which contains a group of related ports, a software virtual
> device, etc.  The switch model is used in a variety of places, such as
> to measure traffic that actually flows through it in order to
> implement monitoring and sampling protocols.

Can you explain why you couldnt use the current bridge code (likely with
some mods)? I can see you want to isolate the VMs via the virtual ports;
maybe even vlans on the virtual ports - the current bridge code should
be able to handle that.

>  * Flow lookup:  Although used to implement OpenFlow, the kernel flow
> table does not actually directly contain OpenFlow flows.  This is
> because OpenFlow tables can contain wildcards, multiple pipeline
> stages, etc. and we did not want to push that complexity into the
> kernel fast path (nor tie it to a specific version of OpenFlow).
> Instead an exact match flow table is populated on-demand from
> userspace based on the more complex rules stored there.  Although it
> might seem limiting, this design has allowed significant new
> functionality to be added without modifications to the kernel or
> performance impact.

This can be achieved easily with zero changes to the kernel code.
You need to have default filters that redirect flows to user space
when you fail to match.

>  * Packet execution:  Once a flow is matched it can be output,
> enqueued to a particular qdisc, etc.  Some of these operations are
> specific to Open vSwitch, such as sampling, whereas others we leverage
> existing infrastructure (including tc for QoS) by simply marking the
> packet for further processing.

The tc classifier-action-qdisc infrastructure handles this.
The sampler needs a new action defined.

>  * Userspace interfaces:  One of the difficulties of having a
> specialized, exact match flow lookup engine is maintaining
> compatibility across differing kernel/userspace versions.  This
> compatibility shows up heavily in the userspace interfaces and is
> achieved by passing the kernel's version of the flow along with packet
> information.  This allows userspace to install appropriate flows even
> if its interpretation of a packet differs from the kernel's without
> version checks or maintaining multiple implementations of the flow
> extraction code in the kernel.

I didnt quiet follow - are we talking about backward/forward
compatibility?


> It's obviously possible to put this code anywhere, whether it is an
> independent module, in the bridge, or tc.  Regardless, however, it's
> largely new code that is geared towards this particular model so it
> seems better not to add to the complexity of existing components if at
> all possible.

I am still not seeing how this could not be done without the
infrastructure that exists. Granted, the user space brains - thats where
everything else resides - but you are not pushing that i think.

cheers,
jamal
