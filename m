From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 2/5] net: add bind/listen ranges to net cgroup
Date: Fri, 12 Aug 2016 21:29:08 -0700
Message-ID: <20160813042907.GA55856@ast-mbp.thefacebook.com>
References: <1470876798-4024-1-git-send-email-anaravaram@google.com>
 <1470876798-4024-3-git-send-email-anaravaram@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: corbet@lwn.net, tj@kernel.org, lizefan@huawei.com,
	hannes@cmpxchg.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	linux-doc@vger.kernel.org, cgroups@vger.kernel.org,
	netdev@vger.kernel.org, edumazet@google.com, maheshb@google.com,
	weiwan@google.com, tom@herbertland.com
To: Anoop Naravaram <anaravaram@google.com>
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1470876798-4024-3-git-send-email-anaravaram@google.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 10, 2016 at 05:53:15PM -0700, Anoop Naravaram wrote:
> bind port ranges
> ----------------
> This property controls which ports the processes in a cgroup are allowed
> to bind to. If a process in a cgroup tries to bind a socket to a port
> that is not within the range(s) permitted by the cgroup, it will receive an
> EACCES error.
> 
> From userspace, you can get or set the bind port ranges by accessing the
> 'net.bind_port_ranges' file. To set the ranges of a cgroup, write the
> comma-separated ranges to the file, where each range could be either a
> pair of ports separated by a hyphen (-), or just an individual port. For
> example, say you want to allow all the processes in a cgroup to be allowed
> to bind to ports 100 through 200 (inclusive), 300 through 320 (inclusive)
> and 350. Then you can write the string "100-200,300-320,350" to the
> 'net.bind_port_ranges' file. When reading the file, any individual ports
> will be read as a "start-end" range where the start and end are equal.
> The example above would be read as "100-200,300-320,350-350".
...
> +/* Returns true if the range r is a subset of at least one of the ranges in
> + * rs, and returns false otherwise.
> + */
> +static bool range_in_ranges(struct net_range *r, struct net_ranges *rs)
> +{
> +	int ri;
> +
> +	for (ri = 0; ri < rs->num_entries; ri++)
> +		if (r->min_value >= rs->range[ri].min_value &&
> +		    r->max_value <= rs->range[ri].max_value)
> +			return true;
> +
> +	return false;
> +}
> +
> +/* Returns true if all the ranges in rs1 are subsets of at least one of the
> + * ranges in rs2, ans returns false otherwise.
> + */
> +static bool ranges_in_ranges(struct net_ranges *rs1, struct net_ranges *rs2)
> +{
> +	int ri;
> +
> +	for (ri = 0; ri < rs1->num_entries; ri++)
> +		if (!range_in_ranges(&rs1->range[ri], rs2))
> +			return false;
> +
> +	return true;
> +}

This is not a scalable implementation. The next step would be to
do a binary search, hash table or something else here?
I think the root of the problem is in hard coded checks
that quickly become inefficient and inadequate as applicability
of the feature grows.
We already have BPF that can suite this purpose much better
without bloating the kernel code with parsing and matching logic.

