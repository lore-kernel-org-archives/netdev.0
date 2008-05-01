From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: State of TCP segmentation offload to NIC in linux
Date: Thu, 1 May 2008 12:39:08 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC3290501C9EA@orsmsx414.amr.corp.intel.com>
References: <49c0ff980805011056q25d24616vf4cea6d8b387b717@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "prodyut hazarika" <prodyuth@gmail.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:21589 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758757AbYEATjI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2008 15:39:08 -0400
Content-class: urn:content-classes:message
In-Reply-To: <49c0ff980805011056q25d24616vf4cea6d8b387b717@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>  I see the define NETIF_F_TSO in the linux kernel, and I see 
> that the e1000 driver is setting this flag in its 
> capabilities list. But for TSO to work, TCP code should send 
> the big segment (say 64K) directly to the NIC, bypassing the 
> IP layer. Else, the IP layer would fragment the packets, and 
> the whole purpose of TSO will be lost. I cannot see any code 
> in tcp layer which bypasses the IP layer and goes directly to 
> the NIC. It seems to me that the TCP/IP stack in Linux always 
> does the segmentation, since there is no code under the 
> NETIF_F_TSO define which bypasses the IP layer. Or am I 
> missing something?

The IP layer does not need to be bypassed.  The TCP layer will set the
proper headers for TSO to work properly and continue sending the skb
down the stack.  IP will not fragment a packet on transmit.  The only
way an skb will be fragmented into smaller chunks is if gso_segment() is
called, which will call the proper upper-layer segmenter routine.  This
case only happens when a packet was coalesced by the TCP layer and sent
to the core stack, which then ran GSO (generic segmentation offload) in
net/core/dev.c, dev_hard_start_xmit(), which would be the case if the
underlying NIC didn't have TSO enabled, but still wanted to have the TCP
layer send larger segments.

> Can anyone please tell me whether the Linux TCP/IP stack 
> support TSO so that TCP segments bigger than MSS is segmented 
> by the NIC, not the software? If not, is there plans to 
> support this, since this is stateless offload?

Yes, TSO is fully supported.  The default is 64k frames, and in the
upstream tree, netif_set_gso_max_size().  I know most 1 GbE and beyond
parts and Linux drivers fully support TSO.

I hope this helps.

Cheers,
-PJ Waskiewicz
