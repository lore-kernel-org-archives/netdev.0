From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Tue, 27 Oct 2015 17:13:56 -0700
Message-ID: <1445991236.7476.59.camel@edumazet-glaptop2.roam.corp.google.com>
References: <201510220634.t9M6YJLD017883@room101.nl.oracle.com>
	 <20151022172146.GS22011@ZenIV.linux.org.uk>
	 <201510221824.t9MIOp6n003978@room101.nl.oracle.com>
	 <20151022190701.GV22011@ZenIV.linux.org.uk>
	 <201510221951.t9MJp5LC005892@room101.nl.oracle.com>
	 <20151022215741.GW22011@ZenIV.linux.org.uk>
	 <201510230952.t9N9qYZJ021998@room101.nl.oracle.com>
	 <20151024023054.GZ22011@ZenIV.linux.org.uk>
	 <201510270908.t9R9873a001683@room101.nl.oracle.com>
	 <562F577E.6000901@oracle.com> <20151027231702.GA22011@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alan Burlison <Alan.Burlison@oracle.com>, Casper.Dik@oracle.com,
	David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	netdev@vger.kernel.org, dholland-tech@netbsd.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33455 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754046AbbJ1AOA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 20:14:00 -0400
Received: by pabla5 with SMTP id la5so44193508pab.0
        for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 17:14:00 -0700 (PDT)
In-Reply-To: <20151027231702.GA22011@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-10-27 at 23:17 +0000, Al Viro wrote:

> 	* [Linux-specific aside] our __alloc_fd() can degrade quite badly
> with some use patterns.  The cacheline pingpong in the bitmap is probably
> inevitable, unless we accept considerably heavier memory footprint,
> but we also have a case when alloc_fd() takes O(n) and it's _not_ hard
> to trigger - close(3);open(...); will have the next open() after that
> scanning the entire in-use bitmap.  I think I see a way to improve it
> without slowing the normal case down, but I'll need to experiment a
> bit before I post patches.  Anybody with examples of real-world loads
> that make our descriptor allocator to degrade is very welcome to post
> the reproducers...

Well, I do have real-world loads, but quite hard to setup in a lab :(

Note that we also hit the 'struct cred'->usage refcount for every
open()/close()/sock_alloc(), and simply moving uid/gid out of the first
cache line really helps, as current_fsuid() and current_fsgid() no
longer forces a pingpong.

I moved seldom used fields on the first cache line, so that overall
memory usage did not change (192 bytes on 64 bit arches)


diff --git a/include/linux/cred.h b/include/linux/cred.h
index 8d70e1361ecd..460efae83522 100644
--- a/include/linux/cred.h
+++ b/include/linux/cred.h
@@ -124,7 +124,17 @@ struct cred {
 #define CRED_MAGIC     0x43736564
 #define CRED_MAGIC_DEAD        0x44656144
 #endif
-       kuid_t          uid;            /* real UID of the task */
+       struct rcu_head rcu;            /* RCU deletion hook */
+
+       kernel_cap_t    cap_inheritable; /* caps our children can inherit */
+       kernel_cap_t    cap_permitted;  /* caps we're permitted */
+       kernel_cap_t    cap_effective;  /* caps we can actually use */
+       kernel_cap_t    cap_bset;       /* capability bounding set */
+       kernel_cap_t    cap_ambient;    /* Ambient capability set */
+
+       kuid_t          uid ____cacheline_aligned_in_smp;
+                                       /* real UID of the task */
+
        kgid_t          gid;            /* real GID of the task */
        kuid_t          suid;           /* saved UID of the task */
        kgid_t          sgid;           /* saved GID of the task */
@@ -133,11 +143,6 @@ struct cred {
        kuid_t          fsuid;          /* UID for VFS ops */
        kgid_t          fsgid;          /* GID for VFS ops */
        unsigned        securebits;     /* SUID-less security management */
-       kernel_cap_t    cap_inheritable; /* caps our children can inherit */
-       kernel_cap_t    cap_permitted;  /* caps we're permitted */
-       kernel_cap_t    cap_effective;  /* caps we can actually use */
-       kernel_cap_t    cap_bset;       /* capability bounding set */
-       kernel_cap_t    cap_ambient;    /* Ambient capability set */
 #ifdef CONFIG_KEYS
        unsigned char   jit_keyring;    /* default keyring to attach requested
                                         * keys to */
@@ -152,7 +157,6 @@ struct cred {
        struct user_struct *user;       /* real user ID subscription */
        struct user_namespace *user_ns; /* user_ns the caps and keyrings are relative to. */
        struct group_info *group_info;  /* supplementary groups for euid/fsgid */
-       struct rcu_head rcu;            /* RCU deletion hook */
 };
 
 extern void __put_cred(struct cred *);
