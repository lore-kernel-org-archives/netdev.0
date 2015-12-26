From: Ming Lei <tom.leiming@gmail.com>
Subject: [PATCH 0/3] bpf: hash: use per-bucket spinlock
Date: Sat, 26 Dec 2015 17:31:31 +0800
Message-ID: <1451122294-16524-1-git-send-email-tom.leiming@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:36180 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750913AbbLZJbn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Dec 2015 04:31:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patchset tries to optimize ebpf hash map, and follows
the idea:

	Both htab_map_update_elem() and htab_map_delete_elem()
	can be called from eBPF program, and they may be in kernel
	hot path, it isn't efficient to use a per-hashtable lock
	in this two helpers, so this patch converts the lock into
	per-bucket spinlock.

With this patchset, looks the performance penalty from eBPF
decreased a lot, see the following test:

	1) run 'tools/biolatency' of bcc before running block test;

	2) run fio to test block throught over /dev/nullb0,
	(randread, 16jobs, libaio, 4k bs) and the test box
	is one 24cores(dual sockets) VM server:
        - without patchset:  607K IOPS
        - with this patchset: 1184K IOPS
        - without running eBPF prog: 1492K IOPS

TODO:
	- remove the per-hashtable atomic counter 

 kernel/bpf/hashtab.c | 49 +++++++++++++++++++++++++++++++------------------
 1 file changed, 31 insertions(+), 18 deletions(-)

thanks,
Ming
