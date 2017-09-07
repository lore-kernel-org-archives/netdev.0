From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH v3 0/6] Configuring traffic classes via new hardware
 offload mechanism in tc/mqprio
Date: Thu, 7 Sep 2017 11:34:45 -0700
Message-ID: <3ecacf3d-1f02-fbc6-0e90-8e84dcd15a4e@gmail.com>
References: <150478158684.24662.17975701233699487888.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org
To: Amritha Nambiar <amritha.nambiar@intel.com>,
        intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f182.google.com ([209.85.128.182]:33098 "EHLO
        mail-wr0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751424AbdIGSex (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 14:34:53 -0400
Received: by mail-wr0-f182.google.com with SMTP id a43so973728wrc.0
        for <netdev@vger.kernel.org>; Thu, 07 Sep 2017 11:34:52 -0700 (PDT)
In-Reply-To: <150478158684.24662.17975701233699487888.stgit@anamdev.jf.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/07/2017 04:00 AM, Amritha Nambiar wrote:
> The following series introduces a new hardware offload mode in
> tc/mqprio where the TCs, the queue configurations and
> bandwidth rate limits are offloaded to the hardware. The existing
> mqprio framework is extended to configure the queue counts and
> layout and also added support for rate limiting. This is achieved
> through new netlink attributes for the 'mode' option which takes
> values such as 'dcb' (default) and 'channel' and a 'shaper' option
> for QoS attributes such as bandwidth rate limits in hw mode 1.

So "dcb" defines a default priorities to queue mapping?

> Legacy devices can fall back to the existing setup supporting hw mode
> 1 without these additional options where only the TCs are offloaded
> and then the 'mode' and 'shaper' options defaults to DCB support.

That's the last part that confuses me, see below.

> The i40e driver enables the new mqprio hardware offload mechanism
> factoring the TCs, queue configuration and bandwidth rates by
> creating HW channel VSIs.

I am really confused by what you call hw_mode 1, as I understand it
there are really 3 different modes:

- legacy: you don't define any traffic class mapping, but you can still
chain this scheduler with a match + action (like what
Documentation/networking/multiqueue.txt) you can optionally also add
"shaper" arguments, but there should not be any default DCB queue
mapping either?

- dcb: a default mapping for traffic classes to queues is defined,
optional "shaper" arguments

- channel: (maybe calling that "custom_tc_map" would be clearer?) where
you express the exact traffic classes to queue mapping and optional
"shaper" arguments

I think that's what you are doing, but I just got confused by the cover
letter.

> 
> In this new mode, the priority to traffic class mapping and the
> user specified queue ranges are used to configure the traffic
> class when the 'mode' option is set to 'channel'. This is achieved by
> creating HW channels(VSI). A new channel is created for each of the
> traffic class configuration offloaded via mqprio framework except for
> the first TC (TC0) which is for the main VSI. TC0 for the main VSI is
> also reconfigured as per user provided queue parameters. Finally,
> bandwidth rate limits are set on these traffic classes through the
> shaper attribute by sending these rates in addition to the number of
> TCs and the queue configurations.
> 
> Example:
>     # tc qdisc add dev eth0 root mqprio num_tc 2 map 0 0 0 0 1 1 1 1\
>       queues 4@0 4@4 hw 1 mode channel shaper bw_rlimit\

Do you see a case where you can declare a different number of traffic
classes say 4 and map them onto just 2 hardware queues? If not, it seems
a tiny bit redundant to have to specify both the map and the queue
mapping should be sufficient, right?

>       min_rate 1Gbit 2Gbit max_rate 4Gbit 5Gbit
> 
>     To dump the bandwidth rates:
> 
>     # tc qdisc show dev eth0
> 
>     qdisc mqprio 804a: root  tc 2 map 0 0 0 0 1 1 1 1 0 0 0 0 0 0 0 0
>                  queues:(0:3) (4:7)
>                  mode:channel
>                  shaper:bw_rlimit   min_rate:1Gbit 2Gbit   max_rate:4Gbit 5Gbit

I am not well versed into tc, but being able to specify "shaper"
arguments has actually value outside of just the multiq scheduler and it
could probably be an action on its own?

> 
> ---
> 
> Amritha Nambiar (6):
>       mqprio: Introduce new hardware offload mode and shaper in mqprio
>       i40e: Add macro for PF reset bit
>       i40e: Add infrastructure for queue channel support
>       i40e: Enable 'channel' mode in mqprio for TC configs
>       i40e: Refactor VF BW rate limiting
>       i40e: Add support setting TC max bandwidth rates
> 
> 
>  drivers/net/ethernet/intel/i40e/i40e.h             |   44 +
>  drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |    3 
>  drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |    8 
>  drivers/net/ethernet/intel/i40e/i40e_main.c        | 1463 +++++++++++++++++---
>  drivers/net/ethernet/intel/i40e/i40e_txrx.h        |    2 
>  drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |   50 -
>  include/net/pkt_cls.h                              |    9 
>  include/uapi/linux/pkt_sched.h                     |   32 
>  net/sched/sch_mqprio.c                             |  183 ++-
>  9 files changed, 1551 insertions(+), 243 deletions(-)
> 
> --
> 


-- 
Florian
