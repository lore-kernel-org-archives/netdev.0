From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [patch net-next v3 1/9] ipv4: fib_rules: Check if rule is a
 default rule
Date: Thu, 16 Mar 2017 09:18:30 -0600
Message-ID: <24ac2262-c47d-3540-b28f-dba612f76f76@cumulusnetworks.com>
References: <1489651700-3586-1-git-send-email-jiri@resnulli.us>
 <1489651700-3586-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        shm@cumulusnetworks.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, lorenzo@google.com,
        mateusz.bajorski@nokia.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f41.google.com ([209.85.214.41]:38379 "EHLO
        mail-it0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751182AbdCPPSd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 11:18:33 -0400
Received: by mail-it0-f41.google.com with SMTP id m27so47433461iti.1
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 08:18:32 -0700 (PDT)
In-Reply-To: <1489651700-3586-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/16/17 2:08 AM, Jiri Pirko wrote:
> From: Ido Schimmel <idosch@mellanox.com>
> 
> Currently, when non-default (custom) FIB rules are used, devices capable
> of layer 3 offloading flush their tables and let the kernel do the
> forwarding instead.
> 
> When these devices' drivers are loaded they register to the FIB
> notification chain, which lets them know about the existence of any
> custom FIB rules. This is done by sending a RULE_ADD notification based
> on the value of 'net->ipv4.fib_has_custom_rules'.
> 
> This approach is problematic when VRF offload is taken into account, as
> upon the creation of the first VRF netdev, a l3mdev rule is programmed
> to direct skbs to the VRF's table.
> 
> Instead of merely reading the above value and sending a single RULE_ADD
> notification, we should iterate over all the FIB rules and send a
> detailed notification for each, thereby allowing offloading drivers to
> sanitize the rules they don't support and potentially flush their
> tables.
> 
> While l3mdev rules are uniquely marked, the default rules are not.
> Therefore, when they are being notified they might invoke offloading
> drivers to unnecessarily flush their tables.
> 
> Solve this by adding an helper to check if a FIB rule is a default rule.
> Namely, its selector should match all packets and its action should
> point to the local, main or default tables.
> 
> As noted by David Ahern, uniquely marking the default rules is
> insufficient. When using VRFs, it's common to avoid false hits by moving
> the rule for the local table to just before the main table:
> 
> Default configuration:
> $ ip rule show
> 0:      from all lookup local
> 32766:  from all lookup main
> 32767:  from all lookup default
> 
> Common configuration with VRFs:
> $ ip rule show
> 1000:   from all lookup [l3mdev-table]
> 32765:  from all lookup local
> 32766:  from all lookup main
> 32767:  from all lookup default
> 
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  include/net/fib_rules.h |  1 +
>  include/net/ip_fib.h    |  7 +++++++
>  net/core/fib_rules.c    | 14 ++++++++++++++
>  net/ipv4/fib_rules.c    | 21 +++++++++++++++++++++
>  4 files changed, 43 insertions(+)
> 

Acked-by: David Ahern <dsa@cumulusnetworks.com>
