From: "Bill Rugolsky Jr." <brugolsky@telemetry-investments.com>
Subject: Re: limited number if iptable rules on 64bit hosts
Date: Thu, 3 Feb 2005 16:35:42 -0500
Message-ID: <20050203213542.GC16868@ti64.telemetry-investments.com>
References: <20050202133851.GA9680@suse.de> <20050202222516.GA15440@suse.de>
	<20050202223853.GA29237@ti64.telemetry-investments.com>
	<20050202225258.GA15563@suse.de> <20050203111939.GI31570@suse.de>
	<20050203104822.05be3281.davem@davemloft.net>
	<20050203185928.GA22832@suse.de>
	<20050203110049.6b2d9c64.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: okir@suse.de, netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org,
	Olaf Hering <olh@suse.de>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050203110049.6b2d9c64.davem@davemloft.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 03, 2005 at 11:00:49AM -0800, David S. Miller wrote:
> It might not help for Olaf's 128 cpu box though :-)
> 
> I think reconsider the idea of replicating the rule itself per-cpu.
> Also, this thread should have begun with netfilter-devel at least on
> the CC:, added.

As Olaf Kirch pointed out, an entry is about 150 bytes, while the counters
are two 64-bit ints, and it looks like 'unsigned int comefrom' is set as
the chains are traversed [net/ipv4/netfilter/ip_tables.c]:

	/* Save old back ptr in next entry */
	struct ipt_entry *next
		= (void *)e + e->next_offset;
	next->comefrom
		= (void *)back - table_base;
	/* set back pointer to next entry */
	back = next;

That's 20-24 bytes of state per-entry per-cpu, for a factor of 6-7 savings,
at the expense of hairing up the code slightly to do parallel indexed
access, Fortran style.

If I am understanding the mm code correctly, a single vmalloc() allocation
is currently limited to 64M on a 64-bit platform, but the VMALLOC address
range is much greater, so one might also prefer to do a kmalloc()/vmalloc()
per CPU, perhaps by creating {vmalloc,vfree}_percpu() and using the
percpu interfaces.

	Bill Rugolsky
