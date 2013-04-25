From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next 2/2] net: Loosen constraints for recalculating
 checksum in skb_segment()
Date: Thu, 25 Apr 2013 16:26:23 +0900
Message-ID: <20130425072623.GB7936@verge.net.au>
References: <1366683556-4956-1-git-send-email-horms@verge.net.au>
 <1366683556-4956-3-git-send-email-horms@verge.net.au>
 <CAEP_g=_nTah2xN2KHxBPtYQyFUWH+8frybGt1Zv=0Q9ButZH5w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>,
	Jarno Rajahalme <jarno.rajahalme@nsn.com>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Maciej =?utf-8?Q?=C5=BBenczykowski?= <maze@google.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:43427 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754032Ab3DYH00 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 03:26:26 -0400
Content-Disposition: inline
In-Reply-To: <CAEP_g=_nTah2xN2KHxBPtYQyFUWH+8frybGt1Zv=0Q9ButZH5w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 23, 2013 at 04:43:58PM -0700, Jesse Gross wrote:
> On Mon, Apr 22, 2013 at 7:19 PM, Simon Horman <horms@verge.net.au> wrote:
> > In the case where a non-MPLS GSO skb becomes an MPLS GSO skb, via
> > Open vSwitch's push MPLS action it is desirable to provide segmentation
> > in software. In this case the original protocol of the skb may have allowed
> > its checksumming to be offloaded but this may no longer be supported now
> > the skb is MPLS. Actually it seems to me that this is the likely case.
> >
> > In order to allow the checksum to be updated in this case loosen
> > the rules for recalculating the checksum on in skb_segment().
> >
> > N.B.: I must confess that I am a little unsure of the details of
> > the implementation of skb_checksum(). But I have observed that this
> > is necessary as skb_checksum() hits the following:
> >
> >                 if (!hsize && i >= nfrags) {
> >                         ...
> >                         fskb = fskb->next;
> >                         ...
> >                 }
> >                 ...
> >                 if (fskb != skb_shinfo(skb)->frag_list)
> >                         ...
> >
> > Signed-off-by: Simon Horman <horms@verge.net.au>
> 
> I'm surprised at the need for changes here since neither vlans nor
> tunneling protocols needed something similar. Do you know what is
> special about MPLS that is triggering this?

After some testing I believe that the answer for GRE is, much to my
surprise, that it doesn't work without this patch. At least not for the
test case I have been using.

To test GRE I set up a machine to receive IP packets and forward them over
a GRE (not TEB) tunnel created using the ip command. In that case I see
incorrect TCP checksums and then retransmissions when GSO segmentation
occurs.  A tcpdump is below.

With this patch applied the checksums are correct.

This seems to be the same behaviour I observed when using Open vSwtich to
output a GSO skb after it had been changed from IPv4/TCP to MPLS with an
IPv4/TCP payload using an MPLS PUSH action. Without this patch the TCP
checksums are incorrect, with it they are calculated correctly.


tcpdump: listening on eth0, link-type EN10MB (Ethernet), capture size 65535 bytes
16:10:54.502631 00:23:7d:e8:5d:a0 > 00:23:7d:e8:dc:8c, ethertype IPv4 (0x0800), length 98: (tos 0x0, ttl 63, id 19650, offset 0, flags [DF], proto GRE (47), length 84)
    10.3.3.149 > 10.3.3.153: GREv0, Flags [none], proto IPv4 (0x0800), length 64
	(tos 0x0, ttl 63, id 19650, offset 0, flags [DF], proto TCP (6), length 60)
    10.3.3.135.54778 > 10.0.98.153.10000: Flags [S], cksum 0x7cb8 (correct), seq 1709735614, win 14560, options [mss 1456,sackOK,TS val 68891260 ecr 0,nop,wscale 7], length 0
16:10:54.502882 00:23:7d:e8:dc:8c > 00:23:7d:e8:5d:a0, ethertype IPv4 (0x0800), length 98: (tos 0x0, ttl 64, id 0, offset 0, flags [DF], proto GRE (47), length 84)
    10.3.3.153 > 10.3.3.149: GREv0, Flags [none], proto IPv4 (0x0800), length 64
	(tos 0x0, ttl 64, id 0, offset 0, flags [DF], proto TCP (6), length 60)
    10.0.98.153.10000 > 10.3.3.135.54778: Flags [S.], cksum 0x2e77 (correct), seq 3486876063, ack 1709735615, win 14240, options [mss 1436,sackOK,TS val 1310203 ecr 68891260,nop,wscale 7], length 0
16:10:54.503038 00:23:7d:e8:5d:a0 > 00:23:7d:e8:dc:8c, ethertype IPv4 (0x0800), length 90: (tos 0x0, ttl 63, id 19651, offset 0, flags [DF], proto GRE (47), length 76)
    10.3.3.149 > 10.3.3.153: GREv0, Flags [none], proto IPv4 (0x0800), length 56
	(tos 0x0, ttl 63, id 19651, offset 0, flags [DF], proto TCP (6), length 52)
    10.3.3.135.54778 > 10.0.98.153.10000: Flags [.], cksum 0x9459 (correct), seq 1, ack 1, win 114, options [nop,nop,TS val 68891260 ecr 1310203], length 0
16:10:54.503181 00:23:7d:e8:5d:a0 > 00:23:7d:e8:dc:8c, ethertype IPv4 (0x0800), length 1514: (tos 0x0, ttl 63, id 19652, offset 0, flags [DF], proto GRE (47), length 1500)
    10.3.3.149 > 10.3.3.153: GREv0, Flags [none], proto IPv4 (0x0800), length 1480
	(tos 0x0, ttl 63, id 19652, offset 0, flags [DF], proto TCP (6), length 1476)
    10.3.3.135.54778 > 10.0.98.153.10000: Flags [.], cksum 0x7fd9 (incorrect -> 0x8ec9), seq 1:1425, ack 1, win 114, options [nop,nop,TS val 68891260 ecr 1310203], length 1424
16:10:54.503277 00:23:7d:e8:5d:a0 > 00:23:7d:e8:dc:8c, ethertype IPv4 (0x0800), length 714: (tos 0x0, ttl 63, id 19653, offset 0, flags [DF], proto GRE (47), length 700)
    10.3.3.149 > 10.3.3.153: GREv0, Flags [none], proto IPv4 (0x0800), length 680
	(tos 0x0, ttl 63, id 19653, offset 0, flags [DF], proto TCP (6), length 676)
    10.3.3.135.54778 > 10.0.98.153.10000: Flags [P.], cksum 0x7cb9 (incorrect -> 0x8c51), seq 1425:2049, ack 1, win 114, options [nop,nop,TS val 68891260 ecr 1310203], length 624
16:10:54.503286 00:23:7d:e8:5d:a0 > 00:23:7d:e8:dc:8c, ethertype IPv4 (0x0800), length 90: (tos 0x0, ttl 63, id 19654, offset 0, flags [DF], proto GRE (47), length 76)
    10.3.3.149 > 10.3.3.153: GREv0, Flags [none], proto IPv4 (0x0800), length 56
	(tos 0x0, ttl 63, id 19654, offset 0, flags [DF], proto TCP (6), length 52)
    10.3.3.135.54778 > 10.0.98.153.10000: Flags [F.], cksum 0x8c58 (correct), seq 2049, ack 1, win 114, options [nop,nop,TS val 68891260 ecr 1310203], length 0
16:10:54.503414 00:23:7d:e8:dc:8c > 00:23:7d:e8:5d:a0, ethertype IPv4 (0x0800), length 102: (tos 0x0, ttl 64, id 0, offset 0, flags [DF], proto GRE (47), length 88)
    10.3.3.153 > 10.3.3.149: GREv0, Flags [none], proto IPv4 (0x0800), length 68
	(tos 0x0, ttl 64, id 31835, offset 0, flags [DF], proto TCP (6), length 64)
    10.0.98.153.10000 > 10.3.3.135.54778: Flags [.], cksum 0x84f3 (correct), seq 1, ack 1, win 112, options [nop,nop,TS val 1310203 ecr 68891260,nop,nop,sack 1 {2049:2050}], length 0
16:10:54.704485 00:23:7d:e8:5d:a0 > 00:23:7d:e8:dc:8c, ethertype IPv4 (0x0800), length 1514: (tos 0x0, ttl 63, id 19655, offset 0, flags [DF], proto GRE (47), length 1500)
    10.3.3.149 > 10.3.3.153: GREv0, Flags [none], proto IPv4 (0x0800), length 1480
	(tos 0x0, ttl 63, id 19655, offset 0, flags [DF], proto TCP (6), length 1476)
    10.3.3.135.54778 > 10.0.98.153.10000: Flags [.], cksum 0x8e96 (correct), seq 1:1425, ack 1, win 114, options [nop,nop,TS val 68891311 ecr 1310203], length 1424
16:10:54.704666 00:23:7d:e8:dc:8c > 00:23:7d:e8:5d:a0, ethertype IPv4 (0x0800), length 102: (tos 0x0, ttl 64, id 0, offset 0, flags [DF], proto GRE (47), length 88)
    10.3.3.153 > 10.3.3.149: GREv0, Flags [none], proto IPv4 (0x0800), length 68
	(tos 0x0, ttl 64, id 31836, offset 0, flags [DF], proto TCP (6), length 64)
    10.0.98.153.10000 > 10.3.3.135.54778: Flags [.], cksum 0x7ee8 (correct), seq 1, ack 1425, win 134, options [nop,nop,TS val 1310253 ecr 68891311,nop,nop,sack 1 {2049:2050}], length 0
16:10:54.704817 00:23:7d:e8:5d:a0 > 00:23:7d:e8:dc:8c, ethertype IPv4 (0x0800), length 714: (tos 0x0, ttl 63, id 19656, offset 0, flags [DF], proto GRE (47), length 700)
    10.3.3.149 > 10.3.3.153: GREv0, Flags [none], proto IPv4 (0x0800), length 680
	(tos 0x0, ttl 63, id 19656, offset 0, flags [DF], proto TCP (6), length 676)
    10.3.3.135.54778 > 10.0.98.153.10000: Flags [P.], cksum 0x8bec (correct), seq 1425:2049, ack 1, win 114, options [nop,nop,TS val 68891311 ecr 1310253], length 624
16:10:54.704961 00:23:7d:e8:dc:8c > 00:23:7d:e8:5d:a0, ethertype IPv4 (0x0800), length 90: (tos 0x0, ttl 64, id 0, offset 0, flags [DF], proto GRE (47), length 76)
    10.3.3.153 > 10.3.3.149: GREv0, Flags [none], proto IPv4 (0x0800), length 56
	(tos 0x0, ttl 64, id 31837, offset 0, flags [DF], proto TCP (6), length 52)
    10.0.98.153.10000 > 10.3.3.135.54778: Flags [.], cksum 0x8bc9 (correct), seq 1, ack 2050, win 156, options [nop,nop,TS val 1310253 ecr 68891311], length 0
16:10:54.704990 00:23:7d:e8:dc:8c > 00:23:7d:e8:5d:a0, ethertype IPv4 (0x0800), length 90: (tos 0x0, ttl 64, id 0, offset 0, flags [DF], proto GRE (47), length 76)
    10.3.3.153 > 10.3.3.149: GREv0, Flags [none], proto IPv4 (0x0800), length 56
	(tos 0x0, ttl 64, id 31838, offset 0, flags [DF], proto TCP (6), length 52)
    10.0.98.153.10000 > 10.3.3.135.54778: Flags [F.], cksum 0x8bc8 (correct), seq 1, ack 2050, win 156, options [nop,nop,TS val 1310253 ecr 68891311], length 0
16:10:54.705164 00:23:7d:e8:5d:a0 > 00:23:7d:e8:dc:8c, ethertype IPv4 (0x0800), length 90: (tos 0x0, ttl 63, id 20581, offset 0, flags [DF], proto GRE (47), length 76)
    10.3.3.149 > 10.3.3.153: GREv0, Flags [none], proto IPv4 (0x0800), length 56
	(tos 0x0, ttl 63, id 0, offset 0, flags [DF], proto TCP (6), length 52)
    10.3.3.135.54778 > 10.0.98.153.10000: Flags [.], cksum 0x8bf2 (correct), seq 2050, ack 2, win 114, options [nop,nop,TS val 68891311 ecr 1310253], length 0
