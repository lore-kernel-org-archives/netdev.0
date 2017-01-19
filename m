From: David Arcari <darcari@redhat.com>
Subject: Re: [PATCH] net: ethtool: avoid allocation failure for dump_regs
Date: Thu, 19 Jan 2017 07:35:22 -0500
Message-ID: <e88b01a6-dae8-a97e-9a8b-8aab030ad099@redhat.com>
References: <1484746445-97920-1-git-send-email-darcari@redhat.com>
 <20170118.114505.1855687422610394730.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58148 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751785AbdASMfW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Jan 2017 07:35:22 -0500
In-Reply-To: <20170118.114505.1855687422610394730.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/18/2017 11:45 AM, David Miller wrote:
> From: David Arcari <darcari@redhat.com>
> Date: Wed, 18 Jan 2017 08:34:05 -0500
>
>> If the user executes 'ethtool -d' for an interface and the associated
>> get_regs_len() function returns 0, the user will see a call trace from
>> the vmalloc() call in ethtool_get_regs().  This patch modifies
>> ethtool_get_regs() to avoid the call to vmalloc when the size is zero.
>>
>> Signed-off-by: David Arcari <darcari@redhat.com>
> I think when the driver indicates this, it is equivalent to saying that
> the operation isn't supported.
>
> Also, this guards us against ->get_regs() methods that don't handle
> zero length requests properly.  I see many which are going to do
> really terrible things in that situation.
>
> Therefore, if get_regs_len() returns zero, treat it the safe as if the
> ethtool operations were NULL.
>
> Thanks.

That was actually the fix that I was originally considering, but it
turns out
there is a problem with it.

I found that the vmalloc error was occurring because
ieee80211_get_regs_len() in
net/mac80211/ethtool.c was returning zero.  The ieee80211_get_regs in
the same
file returns the hw version. It turns out that this information is used
by the
at76c50x-usb driver in the user space ethtool to report which HW variant
is in
use.  Returning an error when regs_len() returns zero would break this
functionality.

-Dave
