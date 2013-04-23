From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2.26] datapath: Add basic MPLS support to kernel
Date: Tue, 23 Apr 2013 16:58:19 +0900
Message-ID: <20130423075819.GB25776@verge.net.au>
References: <1366596740-18246-1-git-send-email-horms@verge.net.au>
 <EA113734-1070-43F9-B932-C8AD83CAAFA2@nsn.com>
 <20130423015149.GI12017@verge.net.au>
 <D94DF465-965B-4462-952C-D3A5793DD2B1@nsn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "<dev@openvswitch.org>" <dev@openvswitch.org>,
	"<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
	Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Jesse Gross <jesse@nicira.com>, Ben Pfaff <blp@nicira.com>
To: "Rajahalme, Jarno (NSN - FI/Espoo)" <jarno.rajahalme@nsn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:47298 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755010Ab3DWH6W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 03:58:22 -0400
Content-Disposition: inline
In-Reply-To: <D94DF465-965B-4462-952C-D3A5793DD2B1@nsn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 23, 2013 at 07:41:37AM +0000, Rajahalme, Jarno (NSN - FI/Espoo) wrote:
> 
> On Apr 23, 2013, at 4:51 , ext Simon Horman wrote:
> 
> > On Mon, Apr 22, 2013 at 01:55:43PM +0000, Rajahalme, Jarno (NSN - FI/Espoo) wrote:
> >> 
> >> Here the skb_network_header is changed to point to the L3 header. Is it
> >> significant that in some cases (?) mpls_stack_depth may remain at zero,
> >> even when a MPLS header was in fact added? (See above).
> > 
> > With the current code I believe there are the following cases:
> > 
> > Input: non-MPLS skb: Output: network header and mac_len correspond to the
> >                     beginning of the L3 headers
> > Input: MPLS:         Output: network header and mac_len correspond to the
> >                     end of the L2 headers.
> > 
> > In the case of MPLS output the end of the L2 headers and the beginning
> > of the L3 headers will differ.
> > 
> > 
> > As far as I know the network header and mac_len only need to correspond to
> > the beginning of the L3 header if GSO segmentation will occur (actually,
> > some proposed changes to the network stack are required, see "[PATCH 0/2]
> > Small Modifications to GSO to allow segmentation of MPLS").  That only
> > occurs if the skb is GSO. Which in turn can only occur if the recieved
> > packet is non-MPLS. This is because the linux kernel doesn't support
> > MPLS offloads on receive (or anywhere else for that matter).
> > 
> > In the case that we have a non-MPLS skb the stack depth starts at zero and
> > is tracked. This is used to update the network header and mac_len.
> > Otherwise the stack depth is unknown and the network header and mac_len are
> > left as-is, corresponding to the end of the L2 headers.
> > 
> > Actually, it is possible to tighten up the if clause to be the following,
> > as it is only necessary to update the network header and mac_len for GSO skbs.
> > 
> > 	if (mpls_stack_depth && skb_is_gso(skb)) {
> > 		...
> > 	}
> > 
> > It is possible for us to find and track the MPLS stack depth for all cases
> > and to update the network header and mac_len. However I don't think that
> > there is any run-time benefit and it seems expensive to find out what the
> > original stack depth was - I believe it would require parsing the MPLS
> > entire stack for each packet.
> > 
> 
> Thanks for explaining this.
> 
> I think it would be better to keep updating the the network_header and mac_len for the Non-MPLS input packets regardless of the GSO status of the skb. It would be more consistent and less surprising.

I agree entirely that it would be more consistent and less surprising.
But I'm not sure if the cost is worth it.

Jesse, do you have an opinion on this?
