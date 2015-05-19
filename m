From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: Kernel crash while using tc script
Date: Tue, 19 May 2015 23:43:14 +0200
Message-ID: <555BAE72.40609@iogearbox.net>
References: <CAGK4HS_cCQPJwXVoCuZAa2zHtPnXO+ar5Wpg_azyxc5Efv4Mwg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, tgraf <tgraf@suug.ch>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:50817 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751257AbbESVnQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 17:43:16 -0400
In-Reply-To: <CAGK4HS_cCQPJwXVoCuZAa2zHtPnXO+ar5Wpg_azyxc5Efv4Mwg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/19/2015 10:11 PM, Vijay Subramanian wrote:
> Hi,
>
> It seems latest net-next kernel crashes while unloading modules.
> Please see simple script below to reproduce the crash.
>
> ===============================
>
> #!/bin/bash
>
> while true; do
>
> # modules will be loaded automatically
>
> tc qdisc add dev eth1 root handle 1: prio
>
> tc filter add dev eth1 parent 1: u32 match u32 0 0  flowid 1
>
>
> tc qdisc del dev eth1 root
>
> rmmod cls_u32
>
> rmmod sch_prio
>
>
> done
>
> =========================
>
> It seems there is some refcounting or locking issue issue. I am unable
> to easily post the dump but sometimes it points to crashes in various
> functions in prio_class_ops  (sch_prio.c), such as prio_walk(),
> prio_dump_class etc. Probably, sch_prio call back functions are
> invoked when they should not be.
>
> I bisected this down to following commit:
>
> commit 78fd1d0ab072d4d9b5f0b7c14a1516665170b565
> Author: Thomas Graf <tgraf@suug.ch>
> Date:   Tue Oct 21 22:05:38 2014 +0200
> netlink: Re-add locking to netlink_lookup() and seq walker
>
> If there are suggestions for me to try or you need more info, let me know.

Hmm, seems rather like the synchronize_net() removal in netlink_release()
must have uncovered a bug elsewhere.
