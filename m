From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next 1/2] bridge: use spin_lock_bh() in br_multicast_set_hash_max
Date: Mon, 6 Jan 2014 11:11:45 -0800
Message-ID: <CAHA+R7MB4Pf=eF-7=3gGH-j1mmJLtrjxFqv0bBXF1BBd1D=kuQ@mail.gmail.com>
References: <20140106190032.10912.1521.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	roopa@cumulusnetworks.com, bridge@lists.linux-foundation.org,
	curt@cumulusnetworks.com, shm@cumulusnetworks.com
To: Scott Feldman <sfeldma@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:38463 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753979AbaAFTLr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 14:11:47 -0500
Received: by mail-la0-f51.google.com with SMTP id ec20so10077603lab.38
        for <netdev@vger.kernel.org>; Mon, 06 Jan 2014 11:11:45 -0800 (PST)
In-Reply-To: <20140106190032.10912.1521.stgit@monster-03.cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 6, 2014 at 11:00 AM, Scott Feldman
<sfeldma@cumulusnetworks.com> wrote:
> From: Curt Brune <curt@cumulusnetworks.com>
>
> br_multicast_set_hash_max() is called from process context in
> net/bridge/br_sysfs_br.c by the sysfs store_hash_max() function.
>
> br_multicast_set_hash_max() calls spin_lock(&br->multicast_lock),
> which can deadlock the CPU if a softirq that also tries to take the
> same lock interrupts br_multicast_set_hash_max() while the lock is
> held .  This can happen quite easily when any of the bridge multicast
> timers expire, which try to take the same lock.
>
> The fix here is to use spin_lock_bh(), preventing other softirqs from
> executing on this CPU.
>
> Steps to reproduce:
>
> 1. Create a bridge with several interfaces (I used 4).
> 2. Set the "multicast query interval" to a low number, like 2.
> 3. Enable the bridge as a multicast querier.
> 4. Repeatedly set the bridge hash_max parameter via sysfs.
>
>   # brctl addbr br0
>   # brctl addif br0 eth1 eth2 eth3 eth4
>   # brctl setmcqi br0 2
>   # brctl setmcquerier br0 1
>
>   # while true ; do echo 4096 > /sys/class/net/br0/bridge/hash_max; done
>


I think this should probably go to net instead of net-next,
and -stable too.
