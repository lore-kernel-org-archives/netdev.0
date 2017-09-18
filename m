From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [RFC net-next 0/5] TSN: Add qdisc-based config interfaces for
 traffic shapers
Date: Mon, 18 Sep 2017 10:02:14 +0200
Message-ID: <20170918080214.yrejz67wwnp2pjzf@localhost>
References: <20170901012625.14838-1-vinicius.gomes@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        jiri@resnulli.us, intel-wired-lan@lists.osuosl.org,
        andre.guedes@intel.com, ivan.briano@intel.com,
        jesus.sanchez-palencia@intel.com, boon.leong.ong@intel.com
To: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f173.google.com ([209.85.128.173]:56122 "EHLO
        mail-wr0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752413AbdIRICU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 04:02:20 -0400
Received: by mail-wr0-f173.google.com with SMTP id l39so5465550wrl.12
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 01:02:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170901012625.14838-1-vinicius.gomes@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 31, 2017 at 06:26:20PM -0700, Vinicius Costa Gomes wrote:
>  * Time-aware shaper (802.1Qbv):

I just posted a working alternative showing how to handle 802.1Qbv and
many other Ethernet field buses.
 
>    The idea we are currently exploring is to add a "time-aware", priority based
>    qdisc, that also exposes the Tx queues available and provides a mechanism for
>    mapping priority <-> traffic class <-> Tx queues in a similar fashion as
>    mqprio. We are calling this qdisc 'taprio', and its 'tc' cmd line would be:
> 
>    $ $ tc qdisc add dev ens4 parent root handle 100 taprio num_tc 4    \
>      	   map 2 2 1 0 3 3 3 3 3 3 3 3 3 3 3 3                         \
> 	   queues 0 1 2 3                                              \
>      	   sched-file gates.sched [base-time <interval>]               \
>            [cycle-time <interval>] [extension-time <interval>]
> 
>    <file> is multi-line, with each line being of the following format:
>    <cmd> <gate mask> <interval in nanoseconds>
> 
>    Qbv only defines one <cmd>: "S" for 'SetGates'
> 
>    For example:
> 
>    S 0x01 300
>    S 0x03 500
> 
>    This means that there are two intervals, the first will have the gate
>    for traffic class 0 open for 300 nanoseconds, the second will have
>    both traffic classes open for 500 nanoseconds.

The idea of the schedule file will not work in practice.  Consider the
fact that the application wants to deliver time critical data in a
particular slot.  How can it find out a) what the time slots are and
b) when the next slot is scheduled?  With this Qdisc, it cannot do
this, AFAICT.  The admin might delete the file after configuring the
Qdisc!

Using the SO_TXTIME option, the application has total control over the
scheduling.  The great advantages of this approach is that we can
support any possible combination of periodic or aperiodic scheduling
and we can support any priority scheme user space dreams up.

For example, one can imaging running two or more loops that only
occasionally collide.  When they do collide, which packet should be
sent first?  Just let user space decide.

Thanks,
Richard
