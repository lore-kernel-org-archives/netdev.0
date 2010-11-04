From: Jesse Gross <jesse@nicira.com>
Subject: Re: [RFC][net-next-2.6 PATCH 2/4] net: 8021Q consolidate header_ops routines
Date: Wed, 3 Nov 2010 17:47:11 -0700
Message-ID: <AANLkTi=pObCfPHkPCUxD8yicZL3pyTwm9s_z4KKda62k@mail.gmail.com>
References: <20101021221004.22906.58438.stgit@jf-dev1-dcblab>
	<20101021221010.22906.60238.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:59918 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754128Ab0KDArL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Nov 2010 20:47:11 -0400
Received: by mail-ww0-f44.google.com with SMTP id 13so70446wwb.1
        for <netdev@vger.kernel.org>; Wed, 03 Nov 2010 17:47:11 -0700 (PDT)
In-Reply-To: <20101021221010.22906.60238.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 21, 2010 at 3:10 PM, John Fastabend
<john.r.fastabend@intel.com> wrote:
> The only thing the 8021Q header ops routines are required
> for is the VLAN_FLAG_REORDER_HDR otherwise by the time
> the VLAN tag has been added the packet is already on
> its way down the stack. In this case using the Ethernet
> ops works OK.
>
> At present the VLAN_FLAG_REORDER_HDR flag does not work
> with vlan offloads. As I understand the flag the intent
> is to allow taps on the vlan device and possibly the
> QOS layer to see the vlan tag info.
>
> By inserting the tag in vlan_tci any taps or QOS policies
> should be able to retrieve the vlan info. This allows
> the flag to work the same in both the offload case and
> non-offloaded case. And allows us to use the underlying
> ethernet ops.
>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

I noticed that you dropped this patch from your most recent series, so
I went back to take a look at it.  I realized that it probably works
inconsistently since header caching doesn't take into account
skb->vlan_tci, so whether you see the tag depends on the state of the
cache.

It would be really good to have this type of code consolidation, both
for the sake of sanity and to eliminate the inconsistent behavior.  We
could do that by either not using header caching or making it work
with vlan offloading somehow.  However, I'm not sure that there's
really much point in that.  VLAN_FLAG_REORDER_HDR doesn't work with
cards that do vlan offloading, which is a pretty significant number of
them.  It similarly works inconsistently on the rx side.  So it's
broken most of the time and worse, the behavior changes depending on
the NIC (and now the ethtool setting).  Can we just eliminate it?
