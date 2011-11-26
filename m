From: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
Subject: Re: Open vSwitch Design
Date: Fri, 25 Nov 2011 20:11:46 -0500
Message-ID: <1322269906.7338.23.camel@mojatatu>
References: <CAEP_g=_2L1xFWtDXh_6YyXz1Mt9TR3zvjLzix+SpO6yzeOLsSQ@mail.gmail.com>
	<1322173833.1944.5.camel@mojatatu>
	<20111124212021.2ae2fb7f@s6510.linuxnetplumber.net>
	<2DB44B16-598F-4414-8B35-8E322D705A9A@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, Chris Wright <chrisw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Justin Pettit <jpettit-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <2DB44B16-598F-4414-8B35-8E322D705A9A-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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

On Fri, 2011-11-25 at 11:52 -0800, Justin Pettit wrote:
> On Nov 24, 2011, at 9:20 PM, Stephen Hemminger wrote:
> 

> A big difficulty is finding an appropriate hardware abstraction.  I've worked on porting 
> Open vSwitch to a few different vendors' switching ASICs, and they've all looked quite 
> different from each other.  Even within a vendor, there can be fairly substantial differences.  
> Packet processing is broken up into stages (e.g., VLAN preprocessing, ingress ACL processing, 
> L2 lookup, L3 lookup, packet modification, packet queuing, packet replication, egress ACL 
> processing, etc.)
> and these can be done in different orders and have quite different behaviors.

Theres some discussion going on on how to get ASIC support on the
variety of chips with different offloads (qos, L2 etc); you may wanna
share your experiences.

Having said that - in the kernel we have all the mechanisms you describe
above with quiet a good fit. Speaking from experience of working on some
vendors ASICs (of which i am sure at least one you are working on).
As an example, the ACL can be applied before or after L2 or L3. We can
support wildcard matching to user space and exact-matches in the kernel.


> Also, the size of the various tables varies widely between ASICs--even within the same 
> family.
> 
> Hardware typically makes use of TCAMs, which support fast lookups of wildcarded flows.
> They're expensive, though, so they're typically limited to entries in the very low thousands.

Those are problems with most merchant silicon - small tables; but there
are some which are easily expandable via DRAM to support a full BGP
table for example.
 
> In software, we can trivially store 100,000s of entries, but supporting wildcarded lookups 
> is very slow.  If we only use exact-match flows in the kernel (and leave the wildcarding 
> in userspace for kernel misses), we can do extremely fast lookups with hashing on what 
> becomes the fastpath.

Justin - theres nothing new you need in the kernel to have that feature.
Let me rephrase that, that has not been a new feature for at least a
decade in Linux.
Add exact match filters with higher priority. Have the lowest priority
filter to redirect to user space. Let user space lookup some service
rule; have it download to the kernel one or more exact matches.
Let the packet proceed on its way down the kernel to its destination if
thats what is defined.

> Using exact-match entries has another big advantage: we can innovate the userspace portion 
> without requiring changes to the kernel.  For example, we recently went from supporting a 
> single OpenFlow table to 255 without any kernel changes.  This has an added benefit that 
> a flow requiring multiple table lookups becomes a single hash lookup in the kernel, which
> is a huge performance gain in the fastpath.  Another example is our introduction of a number
> of metadata "registers" between tables that are never seen in the kernel, but open up a lot 
> of interesting applications for OpenFlow controller writers.

That bit sounds interesting - I will look at your spec.

> If you're interested, we include a porting guide in the distribution that describes how one 
> would go about bringing Open vSwitch to a new hardware or software platform:
> 
> 	http://openvswitch.org/cgi-bin/gitweb.cgi?p=openvswitch;a=blob;f=PORTING
> 
> Obviously, it's not that relevant here, since there's already a port to Linux.  :-)  

Does this mean i can have a 24x10G switch sitting in hardware with Linux
hardware support if i use your kernel switch? 
Do the vendors agree to some common interface?

> But we've 
> iterated over a few different designs and worked on other ports, and we've found this 
> hardware/software abstraction layer to work pretty well.  In fact, multiple ports of 
> Open vSwitch have been done by name-brand third party vendors (this is the avenue most
> vendors use to get their OpenFlow support) and are now shipping.
> 
> We're always open to discussing ways that we can improve this interfaces, too, of course!

Make these vendor switches work with plain Linux. The Intel folks are
producing interfaces with L2, ACLs, VIs and are putting some effort to
integrate them into plain Linux. I should be able to set the qos rules
with tc on an intel chip.
You guys can still take advantage of all that and still have your nice
control plane.

cheers,
jamal
