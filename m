From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Kernel crash while using tc script
Date: Tue, 19 May 2015 13:11:59 -0700
Message-ID: <CAGK4HS_cCQPJwXVoCuZAa2zHtPnXO+ar5Wpg_azyxc5Efv4Mwg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev <netdev@vger.kernel.org>, tgraf <tgraf@suug.ch>,
	Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f176.google.com ([209.85.160.176]:34695 "EHLO
	mail-yk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751004AbbESUSA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 16:18:00 -0400
Received: by ykft189 with SMTP id t189so9161817ykf.1
        for <netdev@vger.kernel.org>; Tue, 19 May 2015 13:17:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

It seems latest net-next kernel crashes while unloading modules.
Please see simple script below to reproduce the crash.

===============================

#!/bin/bash

while true; do

# modules will be loaded automatically

tc qdisc add dev eth1 root handle 1: prio

tc filter add dev eth1 parent 1: u32 match u32 0 0  flowid 1


tc qdisc del dev eth1 root

rmmod cls_u32

rmmod sch_prio


done

=========================

It seems there is some refcounting or locking issue issue. I am unable
to easily post the dump but sometimes it points to crashes in various
functions in prio_class_ops  (sch_prio.c), such as prio_walk(),
prio_dump_class etc. Probably, sch_prio call back functions are
invoked when they should not be.


I bisected this down to following commit:

commit 78fd1d0ab072d4d9b5f0b7c14a1516665170b565
Author: Thomas Graf <tgraf@suug.ch>
Date:   Tue Oct 21 22:05:38 2014 +0200
netlink: Re-add locking to netlink_lookup() and seq walker

If there are suggestions for me to try or you need more info, let me know.

Thanks,
Vijay
