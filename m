From: Luigi Rizzo <rizzo@iet.unipi.it>
Subject: some questions on virtual machine bridging.
Date: Mon, 28 May 2012 18:13:08 +0200
Message-ID: <20120528161308.GB38291@onelab2.iet.unipi.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from onelab2.iet.unipi.it ([131.114.59.238]:61634 "EHLO
	onelab2.iet.unipi.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754779Ab2E1QAN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 May 2012 12:00:13 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am doing some experiments with implementing a software bridge
between virtual machines, using netmap as the communication API.

I have a first prototype up and running and it is quite fast (10 Mpps
with 60-byte frames, 4 Mpps with 1500 byte frames, compared to the
~500-800Kpps @60 bytes that you get with the tap interface used by
openvswitch or the native linux bridging).

I was wondering if anyone has comments/suggestions on the following:

* what kind of API is used by the various virtualization solution to
  do virtual machine switching ?
  - On linux, kvm seems to rely on "tap" interfaces and native linux
    bridging, which i believe is more or less the same solution used
    by FreeBSD.
  - Slightly less efficient is perhaps the use of a socket
    and multicast packets, or bpf.
  - and of course, using PCI passthrough you get more or less hw speed
    (constrained by the OS), but need support from an external switch
    or the NIC itself to do forwarding between different ports.
  anything else ?

* any high-performance virtual switching solution around ?
  As mentioned, i have measured native linux bridging and in-kernel ovs
  and the numbers are above (not surprising; the tap involves a syscall
  on each packet if i am not mistaken, and internally you need a
  data copy)

* how many ports should i support ?

* the hash function normally used for bridging (both in Linux and
  in FreeBSD -- see the latter below) is one of the Jenkins functions.
  It seems to take about 20ns to compute on my machine, which is a
  non-negligible amount of time (haven't tried to optimize it).
  Any reference on why this is so popular ?

cheers
luigi

--- below, the hash function used by FreeBSD bridging ---
/*
 * The following hash function is adapted from "Hash Functions" by Bob Jenkins
 * ("Algorithm Alley", Dr. Dobbs Journal, September 1997).
 *
 * http://www.burtleburtle.net/bob/hash/spooky.html
 */
#define mix(a, b, c)                                                    \
do {                                                                    \
        a -= b; a -= c; a ^= (c >> 13);                                 \
        b -= c; b -= a; b ^= (a << 8);                                  \
        c -= a; c -= b; c ^= (b >> 13);                                 \
        a -= b; a -= c; a ^= (c >> 12);                                 \
        b -= c; b -= a; b ^= (a << 16);                                 \
        c -= a; c -= b; c ^= (b >> 5);                                  \
        a -= b; a -= c; a ^= (c >> 3);                                  \
        b -= c; b -= a; b ^= (a << 10);                                 \
        c -= a; c -= b; c ^= (b >> 15);                                 \
} while (/*CONSTCOND*/0)

static __inline uint32_t
nm_bridge_rthash(const uint8_t *addr)
{
        uint32_t a = 0x9e3779b9, b = 0x9e3779b9, c = 0; // hask key

        b += addr[5] << 8;
        b += addr[4];
        a += addr[3] << 24;
        a += addr[2] << 16;
        a += addr[1] << 8;
        a += addr[0];

        mix(a, b, c);
#define BRIDGE_RTHASH_MASK      (NM_BDG_HASH-1)
        return (c & BRIDGE_RTHASH_MASK);
}
-----------------------------------------------------------------
