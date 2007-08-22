From: Nick Bowler <nbowler@ellipticsemi.com>
Subject: [PATCH] AH4: Update IPv4 options handling to conform to RFC 4302.
Date: Wed, 22 Aug 2007 10:22:53 -0400
Message-ID: <20070822142253.GA14870@totient.ellipticsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tor.primus.ca ([216.254.136.21]:47301 "EHLO
	mail-09.primus.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758686AbXHVOWy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 10:22:54 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I was asked to resend my message here, so here it is.
Please CC me on replies.
---
In testing our ESP/AH offload hardware, I discovered an issue with how AH
handles mutable fields in IPv4.  RFC 4302 (AH) states the following on the
subject:

        For IPv4, the entire option is viewed as a unit; so even
        though the type and length fields within most options are immutable
        in transit, if an option is classified as mutable, the entire option
        is zeroed for ICV computation purposes.

The current implementation does not zero the type and length fields, resulting
in authentication failures when communicating with hosts that do (i.e. FreeBSD).

I have tested record route and timestamp options (ping -R and ping -T) on a
small network involving Windows XP, FreeBSD 6.2, and Linux hosts, with one
router.  In the presence of these options, the FreeBSD and Linux hosts (with
the patch or with the hardware) can communicate.  The Windows XP host simply
fails to accept these packets with or without the patch.

I have also been trying to test source routing options (using traceroute -g),
but haven't had much luck getting this option to work *without* AH, let alone
with.

Signed-off-by: Nick Bowler <nbowler@ellipticsemi.com>
---
 net/ipv4/ah4.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index 7a23e59..39f6211 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -46,7 +46,7 @@ static int ip_clear_mutable_options(struct iphdr *iph, __be32 *daddr)
 			memcpy(daddr, optptr+optlen-4, 4);
 			/* Fall through */
 		default:
-			memset(optptr+2, 0, optlen-2);
+			memset(optptr, 0, optlen);
 		}
 		l -= optlen;
 		optptr += optlen;
-- 
1.5.2.2

-- 
Nick Bowler, Elliptic Semiconductor (http://www.ellipticsemi.com/)

