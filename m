From: Alex Rosenbaum <alexr@mellanox.com>
Subject: Re: [PATCH v3 net-next 0/4] net: low latency Ethernet device polling
Date: Tue, 21 May 2013 15:06:07 +0300
Message-ID: <519B632F.7040202@mellanox.com>
References: <20130520101552.14133.45953.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave Miller <davem@davemloft.net>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	<e1000-devel@lists.sourceforge.net>,
	Willem de Bruijn <willemb@google.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130520101552.14133.45953.stgit@ladj378.jer.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/20/2013 1:15 PM, Eliezer Tamir wrote:
> updated with the comments I got so far.
>
> Thanks,
> Eliezer
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Hello Eliezer,

I am working in Mellanox on a low latency user space offload technology=
=20
and there are some similarities between the user space and your kernel=20
implementation.

We have experience in similar =E2=80=98infinite polling=E2=80=99 issues=
 in respect to=20
the real applications.

I am coming in a little late here but wanted to check that:

1. It seem this patch does not cover epoll/select and such IO muxing AP=
Is?

Most real application will be based on epoll or select, not like netper=
f=20
which is a simple send/recv per thread based network test. If you take=20
memcached application you have epoll per thread with few sockets in eac=
h=20
running on each core.

In the IO mux cases you need to poll multiple driver rings while also=20
polling other non-network fd=E2=80=99s (files, pipes,..) and not to hur=
t their=20
latency response.

2. How is the logic aware of RSS and RFS?

With TCP sockets, the driver knows the specific ring it need to poll so=
=20
this should be mapped and provide the best latency.

=46or UDP (unicast and multicast) you can have all rings delivering=20
packets to a single receive socket, is ndo_ll_poll expected to scan=20
driver rings?

3. I could not find any reference to multi-thread on single core logic.=
=20
This can causes the opposite effect and create contentions and higher=20
latency=E2=80=99s.

Maybe you should ref_count the number of threads per core going into=20
ndo_ll_poll. If the second+ threads want to go down to ndo_ll_poll you=20
should block (sleep) them instead of creating contention.

In this mode at least the first thread will get very good latency and=20
the others will not get hurt.

Or if they move to a different core they should go down to the driver=20
for polling the ring.

Thanks,

Alex Rosenbaum

Director R&D Application Acceleration

Mellanox Technologies
