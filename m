From: Cosmin Ratiu <cratiu@ixiacom.com>
Subject: inet established hash question
Date: Tue, 04 Mar 2008 21:45:40 +0200
Message-ID: <47CDA6E4.1050505@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Octavian Purdila <opurdila@ixiacom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:1789 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751314AbYCDToa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 14:44:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I work at Ixia (most of you probably heard of it), we do network testing 
using a custom Linux distribution and some specialized hardware. There 
is one scalability issue we ran into a while ago regarding large number 
of tcp connections and although we solved it by changing the established 
hash function, we'd like your opinion on the issue if you're kind enough.

Basically, the situation is as follows:
There is a client machine and a server machine. Both create 15000 
virtual interfaces, open up a socket for each pair of interfaces and do 
SIP traffic. By profiling I noticed that there is a lot of time spent 
walking the established hash chains with this particular setup. We are 
using an old version of the kernel (2.6.7), which was using the 
following hash function:

/static __inline__ int tcp_hashfn(__u32 laddr, __u16 lport,
                 __u32 faddr, __u16 fport)
{
    int h = (laddr ^ lport) ^ (faddr ^ fport);
    h ^= h >> 16;
    h ^= h >> 8;
    return h & (tcp_ehash_size - 1);
}/

The addresses were distributed like this: client interfaces were 
198.18.0.1/16 with increments of 1 and server interfaces were 
198.18.128.1/16 with increments of 1. As I said, there were 15000 
interfaces. Source and destination ports were 5060 for each connection. 
So in this case, ports don't matter for hashing purposes, and the bits 
from the address pairs used cancel each other, meaning there are no 
differences in the whole lot of pairs, so they all end up in the same 
hash chain.

After investigating things, I noticed the hash function has been changed 
in the recent kernels to
/
static inline unsigned int inet_ehashfn(const __be32 laddr, const __u16 
lport,
                    const __be32 faddr, const __be16 fport)
{
    return jhash_2words((__force __u32) laddr ^ (__force __u32) faddr,
                ((__u32) lport) << 16 | (__force __u32)fport,
                inet_ehash_secret);
}
/
We tested with the new function and it seems that the results are the 
same for this case: bits in address pairs cancel each other out and they 
all end up in the same chain.

So I changed the function yet again to stop xor-ing addresses before 
feeding them to the jenkins hash. I got something like:
/
{
    int h = jhash_3words(laddr, faddr, ((__u32)lport) << 16 | fport, 
tcp_ehash_secret);

    return h & (tcp_ehash_size - 1);
}/

This way, connections get distributed properly in this case and other 
cases we tested so far.

So, thanks for reading through all this. My question is whether this is 
a good thing to do or not, as I am not so good with hash functions, so I 
can't say for sure if we won't run into a collision with a different setup.


Thank you,
Cosmin.

