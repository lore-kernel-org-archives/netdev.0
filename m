From: Cheng Jin <chengjin@cs.caltech.edu>
Subject: TCP receiver's window calculation problem
Date: Wed, 23 Jun 2004 22:49:54 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0406232228580.29282-100000@orchestra.cs.caltech.edu>
References: <40D9BF6B.4050807@draigBrady.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: fast-support@cs.caltech.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: "netdev@oss.sgi.com" <netdev@oss.sgi.com>
In-Reply-To: <40D9BF6B.4050807@draigBrady.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,

We have been running some iperf experiments over long-latency 
high-capacity networks for protocol testing.  We noticed a strange 
receiver's window limitation of 3,147,776 bytes even when the iperf
server was setup to request 32 MB of socket buffer (for which kernel 
grants twice that).

After doing printk with various window calculation functions at the
receiver, we believe there may be a possible problem with 
tp->rcv_ssthresh calculation in __tcp_grow_window in tcp_input.c.

With input parameters of tcp memory of 64 MB, a jumbo MTU (9000 bytes) 
setting at the receiver, which gives a skb_true_size of 16660 bytes, and a
standard MTU (1500 byte) at the sender side that yields a skb_len of 1448 
bytes. tp->rcv_ssthresh gets stuck at 3,148,472 (see the code segment 
below).  Because the tcp receiver's window needs to be in multiple of mss 
(/1448 then *1448) and  window scaling (>>10 and then <<10), the sender sees
a limit of 3,147,776 bytes.

I include an example code (stripped away the data structs and expanded 
whatever macros there are) that reproduces this problem.  The function
__tcp_grow_window itself may have problems for other combinations of 
input.

#include <stdio.h>
#include <stdlib.h>

typedef unsigned int __u32;

static int
__tcp_grow_window(__u32 rcv_ssthresh, __u32 tcp_full_space,
					__u32 skb_true_size, __u32 skb_len)
{
	int truesize = skb_true_size*3/8;
	int window = tcp_full_space*3/8;

	while ( rcv_ssthresh <= window ) {
		if ( truesize <= skb_len )
			return 2896;

		truesize >>= 1;
		window >>= 1;
	}
	return 0;
}


int main()
{

	__u32 iperf_mem = 64*1024*1024;
	__u32 skb_true_size = 16660;
	__u32 skb_len = 1448;
	__u32 rcv_ssthresh = 3148472;

	int i, incr;

	for (i=0; i<1000; ++i)
	{
		incr = __tcp_grow_window(rcv_ssthresh, iperf_mem, skb_true_size, skb_len);
		printf("i=%d incr=%d\n", i, incr);
	}
}


Cheng

-- 
Lab # 626 395 8820
