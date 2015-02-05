From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [ovs-dev] [RFC: add openvswitch actions using BPF 2/2]
 openvswitch: implements the BPF_PROG action in datapath
Date: Thu, 5 Feb 2015 12:49:35 -0800
Message-ID: <CAADnVQLnXgT4nCJdM9iu77eonAxuEDtPdVMvBJ4Vom_g5Cfb9A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Graf <tgraf@noironetworks.com>,
	"dev@openvswitch.com" <dev@openvswitch.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andy Zhou <azhou@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f170.google.com ([209.85.216.170]:54758 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751331AbbBEUt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 15:49:56 -0500
Received: by mail-qc0-f170.google.com with SMTP id p6so8479647qcv.1
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 12:49:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 5, 2015 at 11:34 AM, Andy Zhou <azhou@nicira.com> wrote:
>>
>> I think it should be doable with BPF to have the verifier accept if
>> a helper is called with less args than expected, to initialize those
>> to 0. This would allow for helpers to support additional arguments.
> I am not sure it is fundamentally better than V2, v3...   On the other hand,
> I agree this looks technically possible.

yes. kinda.
the easiest is just have a flag-like argument in your helper
and as part of the program always pass zero to it initially.
Later when helper function becomes more advanced it will
start interpreting flag argument differently.
pretty much the same concept used everywhere else.

The helper functions need to be thought through
just like any other user interface.

>> It seems very doable to also allow for a BPF prog to be registered
>> upon flow table miss.
> Yes, this is possible, but at the cost of flow set up rate. It may
> still be practical
> with some optimization, such as caching action lists so we don't
> regenerate or download
> the same program.

Loading the program as soon as user space got a notification
on flow miss is definitely not efficient and not scalable.
Whereas having already loaded program to be called when
flow-miss happens makes a lot of sense.
In program-as-action proposal there are potentially N number
of programs for N flow rules (unless the same program
is used as action for all rules)
In program-after-flow-miss proposal, there is 1 program per
datapath or may be per-vport (so packets from different VMs
can be processed by different programs)
