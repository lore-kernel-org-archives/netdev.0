From: linux@horizon.com
Subject: Re: [PATCH 1/3] drivers/net/ipg.c: Fix skbuff leak
Date: 8 Jan 2008 19:38:40 -0500
Message-ID: <20080109003840.22917.qmail@science.horizon.com>
References: <20080108213640.GC4450@electric-eye.fr.zoreil.com>
Cc: akpm@linux-foundation.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: linux@horizon.com, romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from science.horizon.com ([192.35.100.1]:13028 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752163AbYAIAim (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 19:38:42 -0500
In-Reply-To: <20080108213640.GC4450@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Can you try the patch below ?

Testing now... (I presume you noticed the one-character typo in my
earlier patch.  That should be "mc = mc->next", not "mv = mc->next".)

That doesn't seem to do it.  Not entirely, at least.  After downloading
and partially re-uploading an 800M file, slabtop reports:

  OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME
341576 341574  99%    0.50K  42697        8    170788K kmalloc-512
342006 341953  99%    0.19K  16286       21     65144K kmalloc-192
 30592  30575  99%    2.00K   7648        4     61184K kmalloc-2048
 30213  30193  99%    0.44K   3357        9     13428K skbuff_fclone_cache
  7650   7643  99%    0.08K    150       51       600K sysfs_dir_cache
  4000   3938  98%    0.12K    125       32       500K kmalloc-128
   258    258 100%    1.15K     43        6       344K raid5-md5
   232    221  95%    1.00K     58        4       232K kmalloc-1024
  3136   3110  99%    0.06K     49       64       196K kmalloc-64
   264     80  30%    0.68K     24       11       192K ext3_inode_cache

The "kmalloc-2048" was down in the noise before the upload started.
This is in single-user mode, after sync and echo 3 > /proc/sys/vm/drop_caches.


I'll have to try this after this evening's social plans, but I'm thinking
of implementing more rapid bug detection: explicitly zero the sp->TxBuff
slot when the skb is freed, and check that it is zero before putting
anything else in there.  (And likewise for RxBuff.)

That way, I don't have to use up a noticeable amount of memory to see
the bug and reboot to clear up the damage each test cycle.
