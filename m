From: John Dykstra <john.dykstra1@gmail.com>
Subject: [PATCH]  Re: IFF_LOWER_UP does not fit in ifr_flags
Date: Fri, 05 Jun 2009 16:24:07 +0000
Message-ID: <1244219047.7969.7.camel@Maple>
References: <89A39FC0957640879F8975880836CF91@edgeware.tv>
	 <20090529205028.3e01786b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Fredrik Arnerup <fredrik.arnerup@edgeware.tv>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.251]:14083 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751736AbZFEQYJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2009 12:24:09 -0400
In-Reply-To: <20090529205028.3e01786b.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-05-29 at 20:50 -0700, Andrew Morton wrote:
> On Thu, 28 May 2009 14:59:05 +0200 "Fredrik Arnerup" <fredrik.arnerup@edgeware.tv> wrote:
> 
> > Documentation/networking/operstates.txt (and netdevice(7)) claims that
> > the flags IFF_LOWER_UP, IFF_DORMANT and IFF_ECHO can be read from user space
> > using ioctl() with SIOCGIFFLAGS. Looking in include/linux/if.h however,
> > the flags are returned in a struct ifreq in the field ifr_flags which
> > is declared as a short, while the flags are defined as:
> > 
> > #define IFF_LOWER_UP    0x10000         /* driver signals L1 up         */
> > #define IFF_DORMANT     0x20000         /* driver signals dormant       */
> > #define IFF_ECHO        0x40000         /* echo sent packets            */

[PATCH] net core: Some interface flags not returned by SIOCGIFFLAGS

Commit b00055aacdb172c05067612278ba27265fcd05ce " [NET] core: add RFC2863 operstate"
defined new interface flag values.  Its documentation specified that these flags
could be accessed from user space via SIOCGIFFLAGS.  However, this does not work
because the new flags do not fit in that ioctl's argument width.

Change the documentation to match the code's behavior.  Also change the source to
explicitly show the truncation.  This _should_ have no effect on executable code, and did
not with gcc 4.2.4 generating x86 code.

A new ioctl could be defined to return all interface flags to user space.  However,
since this has been broken for three years with no one complaining, there doesn't seem much
need.  They are still accessible via netlink.

Reported-by:  "Fredrik Arnerup" <fredrik.arnerup@edgeware.tv>
Signed-off-by: John Dykstra <john.dykstra1@gmail.com>
---
 Documentation/networking/operstates.txt |    3 ---
 net/core/dev.c                          |    2 +-
 2 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/Documentation/networking/operstates.txt b/Documentation/networking/operstates.txt
index c9074f9..1a77a3c 100644
--- a/Documentation/networking/operstates.txt
+++ b/Documentation/networking/operstates.txt
@@ -38,9 +38,6 @@ ifinfomsg::if_flags & IFF_LOWER_UP:
 ifinfomsg::if_flags & IFF_DORMANT:
  Driver has signaled netif_dormant_on()
 
-These interface flags can also be queried without netlink using the
-SIOCGIFFLAGS ioctl.
-
 TLV IFLA_OPERSTATE
 
 contains RFC2863 state of the interface in numeric representation:
diff --git a/net/core/dev.c b/net/core/dev.c
index e2e9e4a..5c7602b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3853,7 +3853,7 @@ static int dev_ifsioc_locked(struct net *net, struct ifreq *ifr, unsigned int cm
 
 	switch (cmd) {
 		case SIOCGIFFLAGS:	/* Get interface flags */
-			ifr->ifr_flags = dev_get_flags(dev);
+			ifr->ifr_flags = (short) dev_get_flags(dev);
 			return 0;
 
 		case SIOCGIFMETRIC:	/* Get the metric on the interface
-- 
1.5.4.3



