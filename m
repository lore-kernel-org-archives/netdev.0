From: jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>
Subject: Re: Open vSwitch Design
Date: Fri, 25 Nov 2011 06:24:36 -0500
Message-ID: <1322220276.1908.75.camel@mojatatu>
References: <CAEP_g=_2L1xFWtDXh_6YyXz1Mt9TR3zvjLzix+SpO6yzeOLsSQ@mail.gmail.com>
	<1322173833.1944.5.camel@mojatatu>
	<20111124212021.2ae2fb7f@s6510.linuxnetplumber.net>
Reply-To: jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, Chris Wright <chrisw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20111124212021.2ae2fb7f-QE31Isp8l5DVJhW05BI4jyWSNWFUUkiGXqFh9Ls21Oc@public.gmane.org>
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

On Thu, 2011-11-24 at 21:20 -0800, Stephen Hemminger wrote:
> On Thu, 24 Nov 2011 17:30:33 -0500
> jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org> wrote:
> 
 
> > Can you explain why you couldnt use the current bridge code (likely with
> > some mods)? I can see you want to isolate the VMs via the virtual ports;
> > maybe even vlans on the virtual ports - the current bridge code should
> > be able to handle that.
> 
> The way openvswitch works is that the flow table is populated
> by user space. The kernel bridge works completely differently (it learns
> about MAC addresses). 
> 

Most hardware bridges out there support all different modes:
You can have learning in the hardware or defer it to user/control plane
by setting some flags. You can have broadcasting done in hardware or
defer to user space. 
The mods i was thinking of is to bring the Linux bridge to have the 
same behavior. You then need to allow netlink updates of bridge MAC
table from user space. There may be weaknesses with the current bridging
code in relation to Vlans that may need to be addressed.

[But my concern was not so much the bridge - because changes are needed
in that case; it is the "match, actionlist" that is already in place
that got to me.]

> Actually, this is what puts me off on the current implementation.
> I would prefer that the kernel implementation was just a software
> implementation of a hardware OpenFlow switch. That way it would
> be transparent that the control plane in user space was talking to kernel
> or hardware.

Or alternatively, allow the bridge code to support the different modes.
Learning as well as broadcasting mode needs to be settable.
Then you have interesting capability in the kernel that meets the
requirements of an open flow switch (+ anyone who wants to do policy
control in user space with their favorite standard).

> > The tc classifier-action-qdisc infrastructure handles this.
> > The sampler needs a new action defined.
> 
> There are too many damn layers in the software path already.

I think what they are doing in the separation of control and data
is reasonable. The policy and control are in user space. The fastpath
is in the kernel; and it may be in a variety of spots (some arp entry
here, some L3 entry there, a couple of match-action items etc)
the brains which understand the what the different things mean in
aggregation in terms of a service are in user space.

> 
> The problem is that there are two flow classifiers, one in OpenVswitch
> in the kernel, and the other in the user space flow manager. I think the
> issue is that the two have different code.

i see. I can understand having a simple classifier in the kernel and
more complex "consulting" sitting in user space which updates the 
kernel on how to deal with subsequent flow packets.

> Is the kernel/userspace API for OpenVswitch nailed down and documented
> well enough that alternative control plane software could be built?

They do have a generic netlink interface. I would prefer the netlink
interface already in place (which would have worked if they used 
the stuff already in place).


cheers,
jamal
