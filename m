From: Jesper Dangaard Brouer via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: README: [PATCH RFC 11/11] net/mlx5e: XDP TX xmit
	more
Date: Mon, 12 Sep 2016 10:56:55 +0200
Message-ID: <20160912105655.0cb5607e@redhat.com>
References: <1473252152-11379-1-git-send-email-saeedm@mellanox.com>
	<1473252152-11379-12-git-send-email-saeedm@mellanox.com>
	<20160908101147.1b351432@redhat.com>
	<20160909032202.GA62966@ast-mbp.thefacebook.com>
	<20160909073652.351d76d7@redhat.com>
	<20160909063048.GA67375@ast-mbp.thefacebook.com>
Reply-To: Jesper Dangaard Brouer <brouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>,
	iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>, Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
To: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <20160909063048.GA67375-+o4/htvd0TDFYCXBM6kdu7fOX0fSgVTm@public.gmane.org>
List-Unsubscribe: <https://lists.iovisor.org/mailman/options/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.iovisor.org/pipermail/iovisor-dev/>
List-Post: <mailto:iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Help: <mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=help>
List-Subscribe: <https://lists.iovisor.org/mailman/listinfo/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=subscribe>
Sender: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
Errors-To: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 8 Sep 2016 23:30:50 -0700
Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> On Fri, Sep 09, 2016 at 07:36:52AM +0200, Jesper Dangaard Brouer wrote:
> > > >  Lets do bundling/bulking from the start!    
> > > 
> > > mlx4 already does bulking and this proposed mlx5 set of patches
> > > does bulking as well.
> > > See nothing wrong about it. RX side processes the packets and
> > > when it's done it tells TX to xmit whatever it collected.  
> > 
> > This is doing "hidden" bulking and not really taking advantage of using
> > the icache more effeciently.  
> > 
> > Let me explain the problem I see, little more clear then, so you
> > hopefully see where I'm going.
> > 
> > Imagine you have packets intermixed towards the stack and XDP_TX. 
> > Every time you call the stack code, then you flush your icache.  When
> > returning to the driver code, you will have to reload all the icache
> > associated with the XDP_TX, this is a costly operation.  
> 
> correct. And why is that a problem?

It is good that you can see and acknowledge the I-cache problem.

XDP is all about performance.  What I hear is, that you are arguing
against a model that will yield better performance, that does not make
sense to me.  Let me explain this again, in another way.

This is a mental model switch.  Stop seeing the lowest driver RX as
something that works on a per packet basis.  Maybe is it is easier to
understand if we instead see this as vector processing?  This is about
having a vector of packets, where we apply some action/operation.

This is about using the CPU more efficiently, getting it to do more
instructions per cycle (directly measurable with perf, while I-cache
is not directly measurable).


Lets assume everything fits into the I-cache (XDP+driver code). The
CPU-frontend still have to decode the instructions from the I-cache
into micro-ops.  The next level of optimizations is to reuse the
decoded I-cache by running it on all elements in the packet-vector.

The Intel "64 and IA-32 Architectures Optimization Reference Manual"
(section 3.4.2.6 "Optimization for Decoded ICache"[1][2]), states make
sure each hot code block is less than about 500 instructions.  Thus,
the different "stages" working on the packet-vector, need to be rather
small and compact.

[1] http://www.intel.com/content/www/us/en/architecture-and-technology/64-ia-32-architectures-optimization-manual.html
[2] http://www.intel.com/content/dam/www/public/us/en/documents/manuals/64-ia-32-architectures-optimization-manual.pdf



Notice: The same mental model switch applies to delivery packets to
the regular netstack.  I've brought this up before[3].  Instead of
flushing the drivers I-cache for every packet, by calling the stack,
let instead bundle up N-packets in the driver before calling the
stack.  I showed 10% speedup by a naive implementation of this
approach.  Edward Cree also showed[4] a 10% performance boost, and
went further into the stack, showing a 25% increase.

A goal is also, to make optimizing netstack code-size independent of
the driver code-size, by separating the netstacks I-cache usage from
the drivers.

[3] http://lists.openwall.net/netdev/2016/01/15/51
[4] http://lists.openwall.net/netdev/2016/04/19/89
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
