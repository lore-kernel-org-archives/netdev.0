From: Greg Rose <gvrose8192@gmail.com>
Subject: Re: [PATCH net-next v3 0/5]: ixgbevf: Allow querying VFs RSS
 indirection table and key
Date: Mon, 5 Jan 2015 15:54:52 -0800
Message-ID: <CALgkqUojkfTwhsoAnPZdJv-oMg7PMB5m8Q2=k5=QqXKxSJgq7w@mail.gmail.com>
References: <1420467311-6680-1-git-send-email-vladz@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, gleb@cloudius-systems.com,
	avi@cloudius-systems.com, jeffrey.t.kirsher@intel.com
To: Vlad Zolotarov <vladz@cloudius-systems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:36938 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753060AbbAEXyx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 18:54:53 -0500
Received: by mail-ob0-f173.google.com with SMTP id uy5so63506834obc.4
        for <netdev@vger.kernel.org>; Mon, 05 Jan 2015 15:54:52 -0800 (PST)
In-Reply-To: <1420467311-6680-1-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 5, 2015 at 6:15 AM, Vlad Zolotarov
<vladz@cloudius-systems.com> wrote:
> Add the ethtool ops to VF driver to allow querying the RSS indirection table
> and RSS Random Key.
>
>  - PF driver: Add new VF-PF channel commands.
>  - VF driver: Utilize these new commands and add the corresponding
>               ethtool callbacks.
>
> New in v3:
>    - Added a missing support for x550 devices.
>    - Mask the indirection table values according to PSRTYPE[n].RQPL.
>    - Minimized the number of added VF-PF commands.
>
> New in v2:
>    - Added a detailed description to patches 4 and 5.
>
> New in v1 (compared to RFC):
>    - Use "if-else" statement instead of a "switch-case" for a single option case.
>      More specifically: in cases where the newly added API version is the only one
>      allowed. We may consider using a "switch-case" back again when the list of
>      allowed API versions in these specific places grows up.
>
> Vlad Zolotarov (5):
>   ixgbe: Add a RETA query command to VF-PF channel API
>   ixgbevf: Add a RETA query code
>   ixgbe: Add GET_RSS_KEY command to VF-PF channel commands set
>   ixgbevf: Add RSS Key query code
>   ixgbevf: Add the appropriate ethtool ops to query RSS indirection
>     table and key
>
>  drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h      |  10 ++
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    |  91 +++++++++++++++
>  drivers/net/ethernet/intel/ixgbevf/ethtool.c      |  43 +++++++
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   4 +-
>  drivers/net/ethernet/intel/ixgbevf/mbx.h          |  10 ++
>  drivers/net/ethernet/intel/ixgbevf/vf.c           | 132 ++++++++++++++++++++++
>  drivers/net/ethernet/intel/ixgbevf/vf.h           |   2 +
>  7 files changed, 291 insertions(+), 1 deletion(-)

I've given this code a review and I don't see a way to
set a policy in the PF driver as to whether this request should be
allowed or not.  We cannot enable this query by default - it is a
security risk. To make this acceptable you need to do a
couple of things.

A) Have the query disabled by default such that when a VF driver
requests the RSS info the request is denied.

B) Add hooks to allow system admins to set the policy in the PF driver
as to whether the RSS info requests from the VFs are allowed or
denied.  Only provide the VF the privilege to request the RSS info if
the system admin has explicitly set the policy to allow it.  All other
times the request should be denied.

As it stands this is a non-starter.  Privileged information cannot be
made available to VFs without a way for the system admin to set
policy as to whether the information should be made available or not.

- Greg Rose
Intel Corp
Networking Division
<gregory.v.rose@intel.com>


>
> --
> 2.1.0
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
