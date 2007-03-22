From: "Nikolaos D. Bougalis" <nikb@webmaster.com>
Subject: RFC: Established connections hash function
Date: Thu, 22 Mar 2007 08:39:04 -0700
Message-ID: <10189ABA61CF4D5AB3881F96C9CACE87@XEON>
Reply-To: nikb@webmaster.com
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.webmaster.com ([216.152.64.169]:4888 "EHLO
	mail1.webmaster.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933325AbXCVPoq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2007 11:44:46 -0400
Received: from XEON by webmaster.com
	(Cipher TLSv1:RC4-MD5:128) (MDaemon.PRO.v8.1.3.R)
	with ESMTP id md50001457151.msg
	for <netdev@vger.kernel.org>; Thu, 22 Mar 2007 08:39:21 -0800
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

    Hello,

    I have noticed that the hash function that the kernel uses for
established TCP/IP connections is rather simplistic, specifically:

    h = (local address ^ local_port) ^ (remote_address ^ remote_port);
    h ^= h >> 16;
    h ^= h >> 8;

    Now, simple is great, but this has a number of issues, not the least of
which is that an attacker can very easily cause collisions and force
extremely long chain lengths, a situation that becomes worse the more
distinct IP addresses and listening ports a box has.

    Consider, for example, a box that has 20 ports open and 4 consecutive IP
addresses. An attacker that has an entire class C available can create
24,576 connections that hash to the same value, resulting in a ridiculously
overlong chain. With servers that do virtual hosting and have dozens of IPs,
the situation can become much worse very fast.

    This particular hash seems to be the odd-man out, since most other
network related hashes in the kernel seem to be Jenkins-based, and some use
tagged hashing to defeat algorithmic complexity attacks. For example, the
route hash uses this:

static unsigned int rt_hash_rnd;

static unsigned int rt_hash_code(u32 daddr, u32 saddr)
{
        return (jhash_2words(daddr, saddr, rt_hash_rnd)
                & rt_hash_mask);
}

    With this in mind, I propose the following replacement for inet_ehashfn,
which defeats algorithmic complexity attacks and achieves excellent
distribution:

unsigned int inet_ehashfn(const __be32 laddr, const __u16 lport,
                          const __be32 faddr, const __be16 fport)
{
    return jhash_3words((__force __u32)faddr, (__force __u32)laddr,
                        (((__force __u32)fport) << 16) + lport,
                        inet_ehash_rnd);
}

    where inet_ehash_rnd is initialized once in tcp_init to a random 32-bit
value.

    I will be more than happy to provide a patch for this, but I figured I
would solicit some input first.

    Nik B.


