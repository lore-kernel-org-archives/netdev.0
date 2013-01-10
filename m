From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] tcp: splice: fix an infinite loop in tcp_read_sock()
Date: Thu, 10 Jan 2013 15:48:47 -0800
Message-ID: <50EF535F.4040905@hp.com>
References: <1357837570.27446.2285.camel@edumazet-glaptop> <20130110230145.GC17390@1wt.eu> <1357859155.27446.2768.camel@edumazet-glaptop> <20130110232153.GE17390@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:2445 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754532Ab3AJXsx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 18:48:53 -0500
In-Reply-To: <20130110232153.GE17390@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/10/2013 03:21 PM, Willy Tarreau wrote:
> On Thu, Jan 10, 2013 at 03:05:55PM -0800, Eric Dumazet wrote:
>> Thats because you splice(    very_large_amount_of_bytes), so you dont
>> hit this bug.
>
> Not always, I use many sizes (from 1k to very large).
>
>> netperf does the splice (    exact_amount_of_bytes ) so hits this pretty
>> fast on loopback at least.
>
> OK I see, if we need an exact size to trigger it, that explains it !

Netperf does not use a specific size all the time - the size it uses on 
the receive will be the "receive_size" calculated the same way it has 
been since the beginning - either a size specified by a test-specific -M 
option, or based on the value of SO_RCVBUF at the time the socket was 
created.

The kernel of the code making the splice calls - recv_data_no_copy() in 
src/nettest_omni.c looks like:

recv_data_no_copy(SOCKET data_socket, struct ring_elt *recv_ring, 
uint32_t bytes_to_recv, struct sockaddr *source, netperf_socklen_t 
*sourcelen, uint32_t flags, uint32_t *num_receives) {

...

   do {

     bytes_recvd = splice(data_socket,
			 NULL,
			 pfd[1],
			 NULL,
			 bytes_left,
			 my_flags);


     if (bytes_recvd > 0) {
       /* per Eric Dumazet, we should just let this second splice call
	 move as many bytes as it can and not worry about how much.
	 this should make the call more robust when made on a system
	 under memory pressure */
       splice(pfd[0], NULL, fdnull, NULL, 1 << 30, my_flags);
       bytes_left -= bytes_recvd;
     }
     else {
       break;
     }
     my_recvs++; /* should the pair of splices count as one? */
   } while ((bytes_left > 0) && (flags & NETPERF_WAITALL));

where NETPERF_WAITALL is only set for an _RR test.  Bytes_left is 
initialized to bytes_to_recv which is the "receive_size." my_flags is 
set to 0x03.

Now, if there are no test-specific -M option (or -s or -S depending on 
the test) netperf will, from run to run use the same receive_size - 
under Linux chances are quite good that will be 87380.

happy benchmarking,

rick jones
