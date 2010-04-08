From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: linux-next: powerpc boot failure
Date: Thu, 08 Apr 2010 10:11:47 +0300
Message-ID: <4BBD81B3.3030500@iki.fi>
References: <20100408165848.38f75f40.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100408165848.38f75f40.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Rothwell wrote:
> Today's linux-next (20100408) failed a powerpc boot test like this:
> 
> [While bringing up the network interfaces ...]
> 
> Unable to handle kernel paging request for data at address 0x200000025
> Faulting instruction address: 0xc00000000053d32c
> cpu 0x5: Vector: 300 (Data Access) at [c0000000bb277680]
>     pc: c00000000053d32c: .__xfrm_lookup+0x32c/0x4c0
>     lr: c0000000004e6e10: .ip_route_output_flow+0xb0/0x300
>     sp: c0000000bb277900
>    msr: 8000000000009032
>    dar: 200000025
>  dsisr: 40000000
>   current = 0xc0000000bce55640
>   paca    = 0xc000000007691a00
>     pid   = 4106, comm = ntpdate
> [c0000000bb277a20] c0000000004e6e10 .ip_route_output_flow+0xb0/0x300
> [c0000000bb277ad0] c0000000005158c8 .ip4_datagram_connect+0x1a8/0x2f0
> [c0000000bb277bd0] c000000000523dc0 .inet_dgram_connect+0x80/0x110
> [c0000000bb277c60] c0000000004a6904 .SyS_connect+0xa4/0xf0
> [c0000000bb277d90] c0000000004d5f48 .compat_sys_socketcall+0x128/0x2f0
> [c0000000bb277e30] c00000000000852c syscall_exit+0x0/0x40
> 
> The most obvious suspect is commit
> 80c802f3073e84c956846e921e8a0b02dfa3755f ("xfrm: cache bundles instead of
> policies for outgoing flows") and the couple of commits around that
> (these are new to linux-next today).
> 
> The above pc is in this piece of code (I think - I don't have the actual
> kernel) from __xfrm_lookup (in net/xfrm/xfrm_policy.c):
> 
>         if ((flags & XFRM_LOOKUP_ICMP) &&
>             !(pols[0]->flags & XFRM_POLICY_ICMP)) {
>                 err = -ENOENT;
>                 goto error;
>         }
> 
>         for (i = 0; i < num_pols; i++)
>                 pols[i]->curlft.use_time = get_seconds(); <-------- (line 1845)
> 
> And the 0x200000025 is probably &(pols[i]) (which actually seems unlikely
> since pols is an array on the stack).

What kind of xfrm policies the system has?
