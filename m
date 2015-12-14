From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [RFCv4 bluetooth-next 0/2] 6lowpan: 6co and stateful compression support
Date: Mon, 14 Dec 2015 15:00:52 +0100
Message-ID: <1450101654-22633-1-git-send-email-alex.aring@gmail.com>
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, mcr-SWp7JaYWvAQV+D8aMU/kSg@public.gmane.org, lukasz.duda-hR+23Fw+YnFSHonuZl5R5Q@public.gmane.org,
	martin.gergeleit-6wGqcYweBVc@public.gmane.org, Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

this patch series adds stateful compression support and add 6co option as a new
userspace option for processing RA messages inside userspace.

I am not sure if "6CO" handling inside userspace is the best option here.

I will send also "radvd" patches which introduce a very "basic" support for
processing(non 6LBR)/manage(6LBR) 6CO option fields. These patches doesn't
support lifetime handling of contexts. There exists the question as well if
we should handle the lifetime handling inside userspace or kernelspace.

I am currently follow this approach:
If we doesn't need it inside the kernelspace, then we should handle it in
userspace.

It's difficult to figure out if we really can it handle inside userspace only.

RFC6775 describes some different roles inside the network:

 - 6LN (6LoWPAN Node)
 - 6LR (Router inside 6LoWPAN network)
 - 6LBR ($IP_NETWORK <-> 6LoWPAN network)

Processing ICMPv6 (RA/RS, NA/NS) messages may be different for each role. I
currently have not the full overlook inside RFC6775 and sometimes (as example
of ABRO field, another Option-Field for 6LoWPAN) says:

8.1.3.  Routers Processing Router Advertisements
Note: (I suppose this is for 6LR only!)
If a received RA does not contain an ABRO, then the RA MUST be silently
ignored.

---

For my knowledge such handling need to be inside kernelspace. This is filter
functionality only, processing can be handled inside userspace (which needs ABRO
also as userspace option at first), but then the kernel need to know which "role
(6LN, 6LR, 6LBR)" the interface has.

- Alex

changes since v4:
 - remove patches for adding debugfs which are already upstream.
 - add "ipv6: add 6co as icmpv6 userspace option"
 - fix transmit check on (cid) instead (sci || dci) for adding CID inline
   data. If CID is zero it will be compressed.
 - remove "dci_table, sci_table, mcast_table" we have "ctx_table" only.
 - Change enabled with "u32 flags" since we need more information than
   "enabled" only. We handle also "compression flag" now.

Alexander Aring (2):
  6lowpan: iphc: add support for stateful compression
  ipv6: add 6co as icmpv6 userspace option

 include/net/6lowpan.h |  31 ++++
 include/net/ndisc.h   |   1 +
 net/6lowpan/core.c    |   6 +-
 net/6lowpan/debugfs.c |  97 ++++++++++++
 net/6lowpan/iphc.c    | 420 +++++++++++++++++++++++++++++++++++++++++++-------
 net/ipv6/ndisc.c      |   3 +-
 6 files changed, 499 insertions(+), 59 deletions(-)

-- 
2.6.1
