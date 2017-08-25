From: David Ahern <dsahern@gmail.com>
Subject: mlxsw and rtnl lock
Date: Fri, 25 Aug 2017 13:26:07 -0700
Message-ID: <dccefbeb-b5c3-14ed-05d3-07d464989708@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jiri Pirko <jiri@resnulli.us>, Ido Schimmel <idosch@idosch.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:35434 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755222AbdHYU0J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 16:26:09 -0400
Received: by mail-pg0-f45.google.com with SMTP id 63so4490857pgc.2
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 13:26:09 -0700 (PDT)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri / Ido:

I was looking at the mlxsw driver and the places it holds the rtnl lock.
There are a lot of them and from an admittedly short review it seems
like the rtnl is protecting changes to mlxsw data structures as opposed
to calling into the core networking stack. This is going to have huge
impacts on scalability when both the kernel programming (user changes)
and the hardware programming require the rtnl.

With regards to the FIB notifier, why add the fib events to a work queue
that is processed asynchronously if processing the work queue requires
the rtnl lock? What is gained by deferring the work since a major side
effect of the work queue is the loss of error propagation back to the
user on the a failure. That is, if the FIB add/replace/append fails in
the h/w for any reason, offload is silently aborted (an entry in the
kernel log is still a silent abort).

Code in question:

fib_table_insert
- call_fib_entry_notifiers
  ...
    + mlxsw_sp_router_fib_event
      * allocate work entry
      * copy fib change data to it
      * take a reference on fib info / rt
      * schedule work

<some time later>

mlxsw_sp_router_fib{4,6}_event_work
- rtnl_lock

- mlxsw_sp_router_fib{4,6}_add
  if (err)
      mlxsw_sp_router_fib_abort    <----- not propagated to the user

- fib_info_put / rt6_release

David
