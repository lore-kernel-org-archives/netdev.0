From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH/RFC net-next 0/4] net/sched: cls_flower: avoid false
 matching of truncated packets
Date: Fri, 28 Apr 2017 16:14:15 +0200
Message-ID: <20170428141414.GA11256@vergenet.net>
References: <20170428120035.15984-1-simon.horman@netronome.com>
 <422d55da-f861-1bc6-983d-199fc383c113@mojatatu.com>
 <20170428131155.GA30329@vergenet.net>
 <2c14754a-f3f5-cece-2cd7-361948a00c22@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:36238 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S969469AbdD1OOS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 10:14:18 -0400
Received: by mail-wm0-f41.google.com with SMTP id u65so43472937wmu.1
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2017 07:14:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <2c14754a-f3f5-cece-2cd7-361948a00c22@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 28, 2017 at 09:41:00AM -0400, Jamal Hadi Salim wrote:
> On 17-04-28 09:11 AM, Simon Horman wrote:
> >On Fri, Apr 28, 2017 at 08:52:56AM -0400, Jamal Hadi Salim wrote:
> >>On 17-04-28 08:00 AM, Simon Horman wrote:
> >>>Hi,
> >>>
> >>>this series is intended to avoid false-positives which match
> >>>truncated packets against flower classifiers which match on:
> >>>* zero L4 ports or;
> >
> >How would you describe such a rule? The case that is being dealt with is
> >one where there is a parse error and thus nothing to match on from a flower
> >pov.
> >
> 
> A default lower prio match all on udp or icmp?

I'm certainly not opposed to exploring ideas here.

The way that flower currently works is that a match on ip_proto ==
UDP/TCP/SCTP/ICMP but not fields in the L4 header itself would not result in
the dissector only dissecting the packet's L4 header and thus would not
discover (or as in currently the case, silently ignore) the absence of the
ports/ICMP type and code in the L4 header.

What my patch attempts to do is to describe a policy of what to do if
a given classifier invokes the dissector (to pull out the headers needed for
the match in question) and that dissection fails. Its basically describing
the error-path.

> >>Example what would offloading of
> >>header_parse_err_action mean?
> >
> >Why would it need to differ semantically to the implementation in this
> >patch? I feel that I am missing something.
> >
> 
> Unless I misunderstood:
> Isnt the issue the dissector that confused something missing L4 ports
> and said "port is zero"?
> 
> Unless the hardware has the same "bug" as the dissector seems like would
> be a different semantic in the h/ware.

There are two issues:

1. As things stand, without this patch-set, flower does not differentiate
   between a packet truncated at the end of the IP header and a packet with
   zero ports. Likewise for icmp type and code of zero.

   The first three patches of this series address that so that a match for
   port == zero only matches if ports are present in the packet. Again,
   likewise for ICMP.

   This is a bug-fix to my way of thinking.

2. The behaviour described above, prior to this patchset, might have been
   utilised to f.e. drop packets that are either truncated or have port == 0
   (because flower didn't differentiate between these cases).

   So the question becomes if/how to provide such a feature.
   The last patch is my attempt to answer that question.
