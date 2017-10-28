From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [PATCH v2 net-next 3/3] mlxsw: spectrum_router: Return extack
 message on abort due to fib rules
Date: Sat, 28 Oct 2017 17:03:25 +0300
Message-ID: <20171028140325.GB25120@splinter>
References: <1509151034-28278-1-git-send-email-dsahern@gmail.com>
 <1509151034-28278-4-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jiri@mellanox.com, idosch@mellanox.com,
        johannes.berg@intel.com, petrm@mellanox.com
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:52285 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751189AbdJ1OD1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 10:03:27 -0400
Content-Disposition: inline
In-Reply-To: <1509151034-28278-4-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 27, 2017 at 05:37:14PM -0700, David Ahern wrote:
> Adding a FIB rule on a spectrum platform silently aborts FIB offload:
>     $ ip ru add pref 99 from all to 192.168.1.1 table 10
>     $ dmesg -c
>     [  623.144736] mlxsw_spectrum 0000:03:00.0: FIB abort triggered. Note that FIB entries are no longer being offloaded to this device.
> 
> This patch reworks FIB rule handling to return a message to the user:
>     $ ip ru add pref 99 from all to 8.8.8.8 table 11
>     Error: spectrum: FIB rules not supported. Aborting offload.
> 
> spectrum currently only checks whether the fib rule is a default rule or
> an l3mdev rule, both of which it knows how to handle. Any other it aborts
> FIB offload. Move the processing to check the rule type inline with the
> user request. If the rule is an unsupported one, then a work queue entry
> is used to abort the offload. Change the rule delete handling to just
> return since it does nothing at the moment.
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>

Reviewed-by: Ido Schimmel <idosch@mellanox.com>

I'll follow-up with a patch to notify about IPv6 source-specific routes
that also trigger abort.

Another possible use case for this, is something Petr is working on. We
currently assume IP-in-IP tunnel parameters don't change after creation,
but Petr has a patchset that adds support for NETDEV_CHANGE events in
mlxsw.

It's possible that after parameters are changed, we can no longer
offload the tunnel (for example, because user enabled sequence
counters). With this infrastructure, we can let the user know about it.

Thanks!
