From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/4] Netfilter: Merge ipt_LOG and ip6_LOG into xt_LOG
Date: Sun, 4 Mar 2012 12:32:50 +0100
Message-ID: <20120304113250.GA22781@1984>
References: <1328400892-22409-1-git-send-email-richard@nod.at>
 <1328400892-22409-3-git-send-email-richard@nod.at>
 <20120301112732.GA6806@1984>
 <4F4FEC83.6090504@nod.at>
 <20120302164945.GA13723@1984>
 <4F50FAE2.4080903@nod.at>
 <20120304111211.GA22592@1984>
 <4F535161.1010407@nod.at>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="DKU6Jbt7q3WqK7+M"
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, eric.dumazet@gmail.com,
	jengelh@medozas.de, rostedt@goodmis.org
To: Richard Weinberger <richard@nod.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49446 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753059Ab2CDLcx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Mar 2012 06:32:53 -0500
Content-Disposition: inline
In-Reply-To: <4F535161.1010407@nod.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--DKU6Jbt7q3WqK7+M
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sun, Mar 04, 2012 at 12:26:25PM +0100, Richard Weinberger wrote:
> Am 04.03.2012 12:12, schrieb Pablo Neira Ayuso:
> > On Fri, Mar 02, 2012 at 05:52:50PM +0100, Richard Weinberger wrote:
> >> Am 02.03.2012 17:49, schrieb Pablo Neira Ayuso:
> >>> On Thu, Mar 01, 2012 at 10:39:15PM +0100, Richard Weinberger wrote:
> >>>> Am 01.03.2012 12:27, schrieb Pablo Neira Ayuso:
> >>>>> While merging ipt_LOG and ip6t_LOG, you introduced some bug that
> >>>>> corrupts the log line. Note the extra PROTO=, I don't have any UDPLITE
> >>>>> traffic here.
> >>>>>
> >>>>> Looks like a missing break in one switch.
> >>>>
> >>>> I got confused by my own logic. :-\
> >>>> Does the attached patch fix the issue?
> >>>> It's based on "Netfilter: xt_LOG: Add timestamp support"
> >>>
> >>> This patch lacks of description. If you don't make it myself, I have
> >>> to do it for you :-(
> >>>
> >>> Please, send me patches following the standard format next time.
> >>
> >> It was a "does this patch solve the problem"-Patch.
> >> Does it fix the problem?
> >>
> >> If so, I'll send an official one...
> > 
> > Sorry, that's too much overhead. I don't mind testing it, but I want
> > to apply it as soon as it fixes the problem ;-)
> > 
> 
> I'll try to reproduce your problem and test the fix for my own.

Here it works fine, but double test it fine, thanks.

Here's the patch, I added the description.

--DKU6Jbt7q3WqK7+M
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-netfilter-xt_LOG-fix-bogus-extra-layer-4-logging-inf.patch"

>From 0bfff14a7d9b81dc2ddf5d7ea08d3fb11d0f67a9 Mon Sep 17 00:00:00 2001
From: Richard Weinberger <richard@nod.at>
Date: Thu, 1 Mar 2012 11:39:15 +0000
Subject: [PATCH] netfilter: xt_LOG: fix bogus extra layer-4 logging
 information

In 16059b5 netfilter: merge ipt_LOG and ip6_LOG into xt_LOG, we have
merged ipt_LOG and ip6t_LOG.

However:

IN=wlan0 OUT= MAC=xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx
SRC=213.150.61.61 DST=192.168.1.133 LEN=40 TOS=0x00 PREC=0x00 TTL=117
ID=10539 DF PROTO=TCP SPT=80 DPT=49013 WINDOW=0 RES=0x00 ACK RST
URGP=0 PROTO=UDPLITE SPT=80 DPT=49013 LEN=45843 PROTO=ICMP TYPE=0
       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Several missing break in the code led to including bogus layer-4
information. This patch fixes this problem.

Signed-off-by: Richard Weinberger <richard@nod.at>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_LOG.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/xt_LOG.c b/net/netfilter/xt_LOG.c
index 1595608..f99f8de 100644
--- a/net/netfilter/xt_LOG.c
+++ b/net/netfilter/xt_LOG.c
@@ -216,12 +216,14 @@ static void dump_ipv4_packet(struct sbuff *m,
 				    ntohs(ih->frag_off) & IP_OFFSET,
 				    iphoff+ih->ihl*4, logflags))
 			return;
+		break;
 	case IPPROTO_UDP:
 	case IPPROTO_UDPLITE:
 		if (dump_udp_header(m, skb, ih->protocol,
 				    ntohs(ih->frag_off) & IP_OFFSET,
 				    iphoff+ih->ihl*4))
 			return;
+		break;
 	case IPPROTO_ICMP: {
 		struct icmphdr _icmph;
 		const struct icmphdr *ich;
@@ -649,10 +651,12 @@ static void dump_ipv6_packet(struct sbuff *m,
 		if (dump_tcp_header(m, skb, currenthdr, fragment, ptr,
 		    logflags))
 			return;
+		break;
 	case IPPROTO_UDP:
 	case IPPROTO_UDPLITE:
 		if (dump_udp_header(m, skb, currenthdr, fragment, ptr))
 			return;
+		break;
 	case IPPROTO_ICMPV6: {
 		struct icmp6hdr _icmp6h;
 		const struct icmp6hdr *ic;
-- 
1.7.7.3


--DKU6Jbt7q3WqK7+M--
