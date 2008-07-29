From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [Patch] fix ia64 build failure when CONFIG_SFC=m
Date: Tue, 29 Jul 2008 18:48:41 +0100
Message-ID: <20080729174839.GG10471@solarflare.com>
References: <20080729013650.GH9663@sgi.com> <57C9024A16AD2D4C97DC78E552063EA3080BA318@orsmsx505.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "jgarzik@redhat.com" <jgarzik@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"matthew@wil.cx" <matthew@wil.cx>, Robin Holt <holt@sgi.com>,
	linux-net-drivers <linux-net-drivers@solarflare.com>
To: "Luck, Tony" <tony.luck@intel.com>
Return-path: <linux-ia64-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <57C9024A16AD2D4C97DC78E552063EA3080BA318@orsmsx505.amr.corp.intel.com>
Sender: linux-ia64-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Luck, Tony wrote:
> > CONFIG_SFC=m uses topology_core_siblings() which, for ia64, expects
> > cpu_core_map to be exported.  It is not.  This patch exports the needed
> > symbol.
> 
> Ben,
> 
> Before I rush to apply this (or one of the other identical patches that
> I've received) ... I'd like to ponder on whether this is the right thing
> to do.
> 
> Looking at the code in drivers/net/sfc/efx.c I see that you are using
> this to compute the number of RX queues based on the number of packages
> with the git commit comment saying:
> 
>     Using multiple cores in the same package to handle received traffic
>     does not appear to provide a performance benefit.  Therefore use CPU
>     topology information to count CPU packages and use that as the default
>     number of RX queues and interrupts.  We rely on interrupt balancing to
>     spread the interrupts across packages.
> 
> I have some questions on this:
> 
> 1) Did you measure on FSB based systems? ... It's kind of sad that the extra
> cores are not helping and I wonder why. Do AMD and QPI based systems have
> this same limitation?

This heuristic has been in the out-of-tree driver for some time, mostly
based on experience with Intel x86 systems but apparently resulting in good
performance on both Intel and AMD multi-core systems tested here.  We do not
have any IA64 multi-core systems.  I think a single core in each package can
generally saturate the memory bus and this is why spreading the load wider
is not useful.

> 2) Should Linux have an API to give you a useful number of threads, rather
> than make you dig through the topology data structures? At some point cpumask_t
> data structure is going to be too big for the kernel stack.

Since that's all we want to know, it would certainly simplify this driver
and might be useful to others that implement RSS.

> 3) Does interrupt balancing always do the right thing to spread your interrupts
> across packages?

No, if we want to be sure then we do interrupt pinning afterwards.

> 4) In a hotplug system would you want to adjust the number of threads if cpus
> were added or removed?

That would make sense, but I don't think it can be done without disrupting
network traffic.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
