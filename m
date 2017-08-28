From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [RFC PATCH] net: limit maximum number of packets to mark with
 xmit_more
Date: Mon, 28 Aug 2017 20:56:17 +0000
Message-ID: <02874ECE860811409154E81DA85FBB5882A91059@ORSMSX115.amr.corp.intel.com>
References: <20170825152449.29790-1-jacob.e.keller@intel.com>
 <20170825153418.53864810@cakuba>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:33406 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751182AbdH1U4T (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Aug 2017 16:56:19 -0400
In-Reply-To: <20170825153418.53864810@cakuba>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
> Behalf Of Jakub Kicinski
> Sent: Friday, August 25, 2017 12:34 PM
> To: Keller, Jacob E <jacob.e.keller@intel.com>
> Cc: netdev@vger.kernel.org
> Subject: Re: [RFC PATCH] net: limit maximum number of packets to mark with
> xmit_more
> 
> On Fri, 25 Aug 2017 08:24:49 -0700, Jacob Keller wrote:
> > Under some circumstances, such as with many stacked devices, it is
> > possible that dev_hard_start_xmit will bundle many packets together, and
> > mark them all with xmit_more.
> 
> Excuse my ignorance but what are those stacked devices?  Could they
> perhaps be fixed somehow?  My intuition was that long xmit_more
> sequences can only happen if NIC and/or BQL are back pressuring, and
> therefore we shouldn't be seeing a long xmit_more "train" arriving at
> an empty device ring...

a veth device connecting a VM to the host, then connected to a bridge, which is connected to a vlan interface connected to a bond, which is hooked in active-backup to a physical device.

Sorry if I don't really know the correct way to refer to these, I just think of them as devices stacked on top of each other.

During root cause investigation I found that we (the i40e driver) sometimes received up to 100 or more SKBs in a row with xmit_more set. We were incorrectly also using xmit_more as a hint for not marking packets to get writebacks, which caused significant throughput issues. Additionally there was concern that that many packets in a row without a tail bump would cause latency issues, so I thought maybe it was best to simply guarantee that the stack didn't send us too many packets marked with xmit more at once.

It seems based on discussion that it should be up to the driver to determine exactly how to handle the xmit_more hint and to determine when it actually isn't helpful or not, so I do not think this patch makes sense now.

Thanks,
Jake 
