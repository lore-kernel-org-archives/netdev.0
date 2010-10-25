From: Jesse Gross <jesse@nicira.com>
Subject: Re: [RFC][net-next-2.6 PATCH 3/4] ethtool: set hard_header_len using ETH_FLAG_{TX|RX}VLAN
Date: Mon, 25 Oct 2010 15:45:01 -0700
Message-ID: <AANLkTikJpsFC=ZsTWtxwSp-aQRDoZ9fy1p-ZxR+v8jVm@mail.gmail.com>
References: <20101021221004.22906.58438.stgit@jf-dev1-dcblab>
	<20101021221015.22906.3516.stgit@jf-dev1-dcblab>
	<1287752416.2316.2.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: John Fastabend <john.r.fastabend@intel.com>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:38560 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753922Ab0JYWpC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 18:45:02 -0400
Received: by gyg4 with SMTP id 4so2471456gyg.19
        for <netdev@vger.kernel.org>; Mon, 25 Oct 2010 15:45:02 -0700 (PDT)
In-Reply-To: <1287752416.2316.2.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 22, 2010 at 6:00 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Thu, 2010-10-21 at 15:10 -0700, John Fastabend wrote:
>> Toggling the vlan tx|rx hw offloads needs to set the hard_header_len
>> as well otherwise we end up using LL_RESERVED_SPACE incorrectly.
>> This results in pskb_expand_head() being used unnecessarily.
>>
>> This add a check in ethtool_op_set_flags to catch the ETH_FLAG_TXVLAN
>> flag and set the header length.
> [...]
>
> Note that not every driver that implements the set_flags operation calls
> back to ethtool_op_set_flags().

Currently all of the drivers that support toggling this using ethtool
call into ethtool_op_set_flags.  Even if they don't, things will
continue to work correctly, albeit with a performance hit, so it's not
a catastrophe.

This does assume that drivers which support offloading will start with
it enabled.  If they don't and just use the non-vlan header length
then this will drop the header length down even further when
offloading is enabled.  All current drivers that support toggling do
start with offloading enabled, so maybe it's not that big a deal.

Another issue is that cards that don't support vlan offloading at all
probably won't take the header into account, so they'll get hit every
time.

When we are using vlan devices we also manually add the vlan header
length but it doesn't update if we change the underlying device.  It
seems a little redundant to have to do it in both places.

I like that this is generic and independent of vlan devices.
Hopefully we can figure out these corner cases (or maybe decide that
they're not important or this is strictly an improvement).
