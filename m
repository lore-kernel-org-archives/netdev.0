From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: problem with MPLS and TSO/GSO
Date: Mon, 8 Aug 2016 11:48:55 -0600
Message-ID: <ffef54f4-4e4c-9125-6e3a-fc566d2869ec@cumulusnetworks.com>
References: <20160725163915.GE10080@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34988 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752387AbcHHRs7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 13:48:59 -0400
Received: by mail-pa0-f50.google.com with SMTP id iw10so115791535pac.2
        for <netdev@vger.kernel.org>; Mon, 08 Aug 2016 10:48:58 -0700 (PDT)
In-Reply-To: <20160725163915.GE10080@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/25/16 10:39 AM, Lennert Buytenhek wrote:
> Hi!
> 
> I am seeing pretty horrible TCP transmit performance (anywhere between
> 1 and 10 Mb/s, on a 10 Gb/s interface) when traffic is sent out over a
> route that involves MPLS labeling, and this seems to be due to an
> interaction between MPLS and TSO/GSO that causes all segmentable TCP
> frames that are MPLS-labeled to be dropped on egress.
> 
> I initially ran into this issue with the ixgbe driver, but it is easily
> reproduced with veth interfaces, and the script attached below this
> email reproduces the issue.  The script configures three network
> namespaces: one that transmits TCP data (netperf) with MPLS labels,
> one that takes the MPLS traffic and pops the labels and forwards the
> traffic on, and one that receives the traffic (netserver).  When not
> using MPLS labeling, I get ~30000 Mb/s single-stream TCP performance
> in this setup on my test box, and with MPLS labeling, I get ~2 Mb/s.
> 
> Some investigating shows that egress TCP frames that need to be
> segmented are being dropped in validate_xmit_skb(), which calls
> skb_gso_segment() which calls skb_mac_gso_segment() which returns
> -EPROTONOSUPPORT because we apparently didn't have the right kernel
> module (mpls_gso) loaded.
> 
> (It's somewhat poor design, IMHO, to degrade network performance by
> 15000x if someone didn't load a kernel module they didn't know they
> should have loaded, and in a way that doesn't log any warnings or
> errors and can only be diagnosed by adding printk calls to net/core/
> and recompiling your kernel.)
> 
> (Also, I'm not sure why mpls_gso is needed when ixgbe seems to be
> able to natively do TSO on MPLS-labeled traffic, maybe because ixgbe
> doesn't advertise the necessary features in ->mpls_features?  But
> adding those bits doesn't seem to change much.)
> 
> But, loading mpls_gso doesn't change much -- skb_gso_segment() then
> starts return -EINVAL instead, which is due to the
> skb_network_protocol() call in skb_mac_gso_segment() returning zero.
> And looking at skb_network_protocol(), I don't see how this is
> supposed to work -- skb->protocol is 0 at this point, and there is no
> way to figure out that what we are encapsulating is IP traffic, because
> unlike what is the case with VLAN tags, MPLS labels aren't followed by
> an inner ethertype that says what kind of traffic is in here, you have
> to have explicit knowledge of the payload type for MPLS.
> 
> Any ideas?

Something is up with the skb manipulations or settings by mpls. With the inner protocol set in mpls_output:

skb_set_inner_protocol(skb, skb->protocol);

I get EINVAL failures from inet_gso_segment because the iphdr is not proper (ihl is 0 and version is 0).


Thanks for the script to repro with namespaces; much simpler to debug.
