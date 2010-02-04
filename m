From: Octavian Purdila <opurdila-+zzKsuq53OdBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC Patch] net: reserve ports for applications using fixed port numbers
Date: Thu, 4 Feb 2010 20:15:51 +0200
Message-ID: <201002042015.51092.opurdila@ixiacom.com>
References: <201002031312.48531.opurdila@ixiacom.com> <201002041444.01897.opurdila@ixiacom.com> <20100204.094110.64247447.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100204.094110.64247447.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thursday 04 February 2010 19:41:10 you wrote:

> From: Octavian Purdila <opurdila-+zzKsuq53OdBDgjK7y7TUQ@public.gmane.org>
> Date: Thu, 4 Feb 2010 14:44:01 +0200
> 
> > My concern is that we can have multiple applications that require a
> > fixed port and if those ports are significantly apart we will
> > decrease the port range available for connect. And that will hurt
> > the rate of which new connections can be opened.
> 
> I'm already uneasy about adding the simple check every time
> we loop around in the bind port allocator.
> 
> Adding an LSM hook to this spot?  I absolutely refuse to allow
> that, it will completely kill bind performance.
> 

I think Tetsuo was proposing the LSM hook, so I'll leave him the daunting task 
of convincing you of the benefit of that :) - I have no opinion on this due to 
massive lack of knowledge.

I was just proposing to use a discrete set of ports instead of a range. The 
check in the current patch:

int inet_is_reserved_local_port(int port)
{
       int min, max;

       inet_get_local_reserved_ports(&min, &max);
       if (min && max)
               return (port >= min && port <= max);
       return 0;
}

would become:

int inet_is_reserved_local_port(int port)
{
	if (test_bit(port, reserved_ports))
		return 1;
	return 0;
}

In theory it might be slower because of the reserved_ports bitmap will have a 
larger memory footprint than just a min/max, especially with random port 
allocation. But is this an issue in practice?
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
