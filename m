From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: Bug w/ (policy) routing
Date: Mon, 2 Jan 2017 09:48:12 -0700
Message-ID: <c59bcb99-39d1-3b47-7787-dd4d805eb4f6@cumulusnetworks.com>
References: <20161231000006.17677918@jjacky.com>
 <3575dc1f-d536-20d2-24b9-a1e95a5c795b@cumulusnetworks.com>
 <20170101205238.426803f4@jjacky.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alexander Duyck <alexander.duyck@gmail.com>
To: Olivier Brunel <jjk@jjacky.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:33480 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755938AbdABQsT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2017 11:48:19 -0500
Received: by mail-pg0-f52.google.com with SMTP id g1so166176475pgn.0
        for <netdev@vger.kernel.org>; Mon, 02 Jan 2017 08:48:18 -0800 (PST)
In-Reply-To: <20170101205238.426803f4@jjacky.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/1/17 12:52 PM, Olivier Brunel wrote:
> Indeed, if I first delete the rule for lookup local and recreate it
> w/ higher prio than my "lookup 50", then no more issue.

After the unshare or when creating a new network namespace, bringing the lo device up will create the local table and the rest of the commands will work properly. ie., instead of moving the local rule you can run:

unshare -n bash

ip li set lo up
ip rule add table 50 prio 50
ip link add test type veth peer name test2
...

-----

Alex: 

The order of commands is influencing whether the unmerge succeeds or not which is wrong. I took a quick look and I don't see a simple solution to this. Effectively:

Adding a rule before bringing up any interface does not unmerge the tables:
$ unshare -n bash
$ ip rule add table 50 prio 50
$ ip li set lo up

In fib_unmerge(), fib_new_table(net, RT_TABLE_LOCAL) returns null.


Where the reverse order works:
$ unshare -n bash
$ ip li set lo up
$ ip rule add table 50 prio 50

David
