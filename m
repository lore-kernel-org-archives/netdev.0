From: Olaf Kirch <okir@suse.de>
Subject: Re: limited number if iptable rules on 64bit hosts
Date: Thu, 3 Feb 2005 12:19:39 +0100
Message-ID: <20050203111939.GI31570@suse.de>
References: <20050202133851.GA9680@suse.de> <20050202222516.GA15440@suse.de> <20050202223853.GA29237@ti64.telemetry-investments.com> <20050202225258.GA15563@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Bill Rugolsky Jr." <brugolsky@telemetry-investments.com>,
        netdev@oss.sgi.com
To: Olaf Hering <olh@suse.de>
Content-Disposition: inline
In-Reply-To: <20050202225258.GA15563@suse.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Feb 02, 2005 at 11:52:58PM +0100, Olaf Hering wrote:
> > I don't have time to look now [I'm running for the door],
> > but that's possibly the vmalloc() limit of 64M (67108864) ?
> 
> maybe.
> ->size is a userprovided value, havent looked closely at iptables
> source. It seems we have to live with this limitation.

The problem is two-fold. netfilter tries to allocate some data
per-CPU and does

	vmalloc(sizeof(struct ipt_table_info)
	                + SMP_ALIGN(tmp.size) * NR_CPUS);

At 3445 rules, tmp.size is 524272 (why does it want that much memory? I
would expect the only data that's per-CPU is the packet and byte
counters).

In some of our kernel configurations, NR_CPUS is 128 or even more,
and we run into a vmalloc limit here.

vmalloc wants to allocate an arrays of struct page pointers, and on
a 64bit platform this means you're limited to 131072 / 8 = 16384
pages, or 67108864 bytes. In the example Olaf H posted, we fail at
128 + 524272 * 128 = 67108992 bytes, i.e. 16385 pages.

So I guess it all boils down to why netfilter needs 150-odd bytes
per rule and CPU.

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax
