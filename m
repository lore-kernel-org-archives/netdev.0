From: Justin Pettit <jpettit-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: Open vSwitch Design
Date: Fri, 25 Nov 2011 11:52:51 -0800
Message-ID: <2DB44B16-598F-4414-8B35-8E322D705A9A@nicira.com>
References: <CAEP_g=_2L1xFWtDXh_6YyXz1Mt9TR3zvjLzix+SpO6yzeOLsSQ@mail.gmail.com>
	<1322173833.1944.5.camel@mojatatu>
	<20111124212021.2ae2fb7f@s6510.linuxnetplumber.net>
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, Chris Wright <chrisw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org,
	jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org, John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
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

On Nov 24, 2011, at 9:20 PM, Stephen Hemminger wrote:

>> This can be achieved easily with zero changes to the kernel code.
>> You need to have default filters that redirect flows to user space
>> when you fail to match.
> 
> Actually, this is what puts me off on the current implementation.
> I would prefer that the kernel implementation was just a software
> implementation of a hardware OpenFlow switch. That way it would
> be transparent that the control plane in user space was talking to kernel
> or hardware.

A big difficulty is finding an appropriate hardware abstraction.  I've worked on porting Open vSwitch to a few different vendors' switching ASICs, and they've all looked quite different from each other.  Even within a vendor, there can be fairly substantial differences.  Packet processing is broken up into stages (e.g., VLAN preprocessing, ingress ACL processing, L2 lookup, L3 lookup, packet modification, packet queuing, packet replication, egress ACL processing, etc.) and these can be done in different orders and have quite different behaviors.  Also, the size of the various tables varies widely between ASICs--even within the same family.

Hardware typically makes use of TCAMs, which support fast lookups of wildcarded flows.  They're expensive, though, so they're typically limited to entries in the very low thousands.  In software, we can trivially store 100,000s of entries, but supporting wildcarded lookups is very slow.  If we only use exact-match flows in the kernel (and leave the wildcarding in userspace for kernel misses), we can do extremely fast lookups with hashing on what becomes the fastpath.

Using exact-match entries has another big advantage: we can innovate the userspace portion without requiring changes to the kernel.  For example, we recently went from supporting a single OpenFlow table to 255 without any kernel changes.  This has an added benefit that a flow requiring multiple table lookups becomes a single hash lookup in the kernel, which is a huge performance gain in the fastpath.  Another example is our introduction of a number of metadata "registers" between tables that are never seen in the kernel, but open up a lot of interesting applications for OpenFlow controller writers.

If you're interested, we include a porting guide in the distribution that describes how one would go about bringing Open vSwitch to a new hardware or software platform:

	http://openvswitch.org/cgi-bin/gitweb.cgi?p=openvswitch;a=blob;f=PORTING

Obviously, it's not that relevant here, since there's already a port to Linux.  :-)  But we've iterated over a few different designs and worked on other ports, and we've found this hardware/software abstraction layer to work pretty well.  In fact, multiple ports of Open vSwitch have been done by name-brand third party vendors (this is the avenue most vendors use to get their OpenFlow support) and are now shipping.

We're always open to discussing ways that we can improve this interfaces, too, of course!

--Justin
