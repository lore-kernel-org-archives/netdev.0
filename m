From: Anton Blanchard <anton@samba.org>
Subject: some TSO analysis
Date: Thu, 11 Nov 2004 16:06:08 +1100
Message-ID: <20041111050608.GG1922@krispykreme.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,

Some web server benchmarking on recent 2.6 shows TSO not to be the gain
it was in earlier kernels. I took a quick look at varying
tcp_tso_win_divisor, below are the results. 

Each line is one packet, with the size of each component of the packet
logged. Note the 4 byte packets at the end are a workaround for an e1000
bug. The MTU is 1500 bytes. The kernel is BK from today. The test does
64kB writes or sendfiles.

I noticed a few things:

- In the normal copy case, it looks like we split the first page between
  the skb->data and the first frag. eg:

  data: 1634 frags: 1408 4096 4096 4096 2108 4

  Is there a reason why the remaining 1408 bytes cant be stuffed into
  skb->data? Or is that an issue with MTU sized buffers?

- TSO really doesnt come into play until we set tcp_tso_win_divisor to
  2. BTW In this setup I am talking to a 2.4 machine on the same gigabit
  switch. At 4 the normal copy case sees some gains, but interestingly
  the zero copy does not.

Anton


tcp_tso_win_divisor = 8 (default)
normal copy:
data: 442 frags: 
data: 1634 frags: 2772 4 
data: 1634 frags: 896 1876 4 
data: 1634 frags: 2176 596 4 
data: 1634 frags: 2772 4 
data: 1634 frags: 640 2132 4 
data: 1634 frags: 1920 852 4 
data: 1634 frags: 2772 4 
data: 1634 frags: 384 2388 4 
data: 1634 frags: 1664 1108 4 

zero copy:
data: 66 frags: 1448 
data: 66 frags: 1200 248 
data: 66 frags: 1448 
data: 66 frags: 1448 
data: 66 frags: 952 
data: 66 frags: 1448 
data: 66 frags: 1448 
data: 66 frags: 1200 248 
data: 66 frags: 1448 
data: 66 frags: 1448 


tcp_tso_win_divisor = 4
normal copy:
data: 1634 frags: 2176 4096 844 4 
data: 1634 frags: 3200 3916 4 
data: 1634 frags: 128 3020 4 
data: 1634 frags: 1024 4096 1996 4 
data: 1634 frags: 2048 4096 972 4 
data: 1634 frags: 3072 4044 4 
data: 1634 frags: 4096 3020 4 
data: 1634 frags: 1024 4096 1996 4 
data: 1634 frags: 2048 4096 972 4 
data: 1634 frags: 3072 4044 4 

zero copy:
data: 66 frags: 1448 
data: 66 frags: 1448 
data: 66 frags: 1200 248 
data: 66 frags: 1448 
data: 66 frags: 1448 
data: 66 frags: 952 
data: 66 frags: 1448 
data: 66 frags: 1448 
data: 66 frags: 1200 248 
data: 66 frags: 1448 


tcp_tso_win_divisor = 2
normal copy:
data: 1634 frags: 1408 4096 4096 4096 2108 4 
data: 1634 frags: 1920 4096 4096 4096 1596 4 
data: 1634 frags: 2432 4096 4096 4096 1084 4 
data: 1634 frags: 2944 4096 4096 4096 572 4 
data: 1634 frags: 3456 4096 4096 4096 60 4 
data: 1634 frags: 3968 4096 4096 3644 4 
data: 1634 frags: 384 4096 4096 4096 3132 4 
data: 1634 frags: 896 4096 4096 4096 2620 4 
data: 1634 frags: 2432 4096 4096 4096 1084 4 

zero copy:
data: 66 frags: 2304 4096 4096 4096 2780 4 
data: 66 frags: 1312 4096 4096 4096 3772 4 
data: 66 frags: 320 4096 4096 4096 4096 668 4 
data: 66 frags: 3424 4096 4096 4096 1660 4 
data: 66 frags: 2432 4096 4096 4096 2652 4 
data: 66 frags: 1440 4096 4096 4096 3644 4 
data: 66 frags: 448 4096 4096 4096 4096 540 4 
data: 66 frags: 3552 4096 4096 4096 1532 4 
data: 66 frags: 2560 4096 4096 4096 2524 4 
data: 66 frags: 1568 4096 4096 4096 3516 4 
