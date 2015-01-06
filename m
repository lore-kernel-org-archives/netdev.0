From: Gleb Natapov <gleb@cloudius-systems.com>
Subject: Re: [PATCH net-next v3 0/5]: ixgbevf: Allow querying VFs RSS
 indirection table and key
Date: Tue, 6 Jan 2015 20:04:55 +0200
Message-ID: <20150106180455.GB29721@cloudius-systems.com>
References: <1420467311-6680-1-git-send-email-vladz@cloudius-systems.com>
 <CALgkqUojkfTwhsoAnPZdJv-oMg7PMB5m8Q2=k5=QqXKxSJgq7w@mail.gmail.com>
 <20150106065535.GM29889@cloudius-systems.com>
 <54ABBFEB.9010105@cloudius-systems.com>
 <CALgkqUqh4uMxhnTA9yOm2m0Z3tOZ1E2+Z8Y68Kv5HJ6vP=Fk2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Zolotarov <vladz@cloudius-systems.com>,
	netdev@vger.kernel.org, Avi Kivity <avi@cloudius-systems.com>,
	jeffrey.t.kirsher@intel.com
To: Greg Rose <gvrose8192@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:35451 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752047AbbAFSMI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 13:12:08 -0500
Received: by mail-wi0-f175.google.com with SMTP id l15so5895875wiw.8
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 10:12:07 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CALgkqUqh4uMxhnTA9yOm2m0Z3tOZ1E2+Z8Y68Kv5HJ6vP=Fk2A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 06, 2015 at 08:59:41AM -0800, Greg Rose wrote:
> On Tue, Jan 6, 2015 at 2:58 AM, Vlad Zolotarov
> <vladz@cloudius-systems.com> wrote:
> >
> > On 01/06/15 08:55, Gleb Natapov wrote:
> >>
> >> On Mon, Jan 05, 2015 at 03:54:52PM -0800, Greg Rose wrote:
> >>>
> >>> On Mon, Jan 5, 2015 at 6:15 AM, Vlad Zolotarov
> >>> <vladz@cloudius-systems.com> wrote:
> >>>>
> >>>> Add the ethtool ops to VF driver to allow querying the RSS indirection
> >>>> table
> >>>> and RSS Random Key.
> >>>>
> >>>>   - PF driver: Add new VF-PF channel commands.
> >>>>   - VF driver: Utilize these new commands and add the corresponding
> >>>>                ethtool callbacks.
> >>>>
> >>>> New in v3:
> >>>>     - Added a missing support for x550 devices.
> >>>>     - Mask the indirection table values according to PSRTYPE[n].RQPL.
> >>>>     - Minimized the number of added VF-PF commands.
> >>>>
> >>>> New in v2:
> >>>>     - Added a detailed description to patches 4 and 5.
> >>>>
> >>>> New in v1 (compared to RFC):
> >>>>     - Use "if-else" statement instead of a "switch-case" for a single
> >>>> option case.
> >>>>       More specifically: in cases where the newly added API version is
> >>>> the only one
> >>>>       allowed. We may consider using a "switch-case" back again when the
> >>>> list of
> >>>>       allowed API versions in these specific places grows up.
> >>>>
> >>>> Vlad Zolotarov (5):
> >>>>    ixgbe: Add a RETA query command to VF-PF channel API
> >>>>    ixgbevf: Add a RETA query code
> >>>>    ixgbe: Add GET_RSS_KEY command to VF-PF channel commands set
> >>>>    ixgbevf: Add RSS Key query code
> >>>>    ixgbevf: Add the appropriate ethtool ops to query RSS indirection
> >>>>      table and key
> >>>>
> >>>>   drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h      |  10 ++
> >>>>   drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    |  91
> >>>> +++++++++++++++
> >>>>   drivers/net/ethernet/intel/ixgbevf/ethtool.c      |  43 +++++++
> >>>>   drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   4 +-
> >>>>   drivers/net/ethernet/intel/ixgbevf/mbx.h          |  10 ++
> >>>>   drivers/net/ethernet/intel/ixgbevf/vf.c           | 132
> >>>> ++++++++++++++++++++++
> >>>>   drivers/net/ethernet/intel/ixgbevf/vf.h           |   2 +
> >>>>   7 files changed, 291 insertions(+), 1 deletion(-)
> >>>
> >>> I've given this code a review and I don't see a way to
> >>> set a policy in the PF driver as to whether this request should be
> >>> allowed or not.  We cannot enable this query by default - it is a
> >>> security risk. To make this acceptable you need to do a
> >>> couple of things.
> >>>
> >> Can you please elaborate on the security risk this information poses?
> >> Is toeplitz hash function cryptographically strong enough so that VF
> >> cannot reconstruct the hash key from hash result provided in packet
> >> descriptor? The abstract of this paper [1] claims it is not, but I do
> >> not have access to the full article unfortunately hence the question.
> >>
> >> [1]
> >> http://ieeexplore.ieee.org/xpl/login.jsp?tp=&arnumber=5503170&url=http%3A%2F%2Fieeexplore.ieee.org%2Fxpls%2Fabs_all.jsp%3Farnumber%3D5503170
> >
> >
> > I agree with Gleb here: when we started with just thinking about the idea of
> > this patch the possible security issue was the first thing that came into
> > our minds.
> > But eventually we couldn't come up with any security risk or attack example
> > that is exclusively caused by the fact that VF knows the indirection table
> > and/or RSS hash key of the PF.
> >
> > So, Greg, if we have missed anything and your have such an example could you
> > share it here, please?
> 
> I don't have any examples and that is not my area of expertise.  But
> just because we can't think of a security risk or attack example
> doesn't mean there isn't one.
> 
Is RSS hash security feature at all? Against what kind of attack? It
looks like some drivers (igb among them) use non random value for the key.

> Just add a policy hook so that the system admin can decide whether
> this information should be shared with the VFs and then we're covered
> for cases of both known and unknown exploits, risks, etc.
> 
Default off means that it will stay that way for most installations and
information will not be available for "cloud" users. It is hard to get
proper support on public cloud for less trivial issues than changing
host HW configuration.

--
			Gleb.
