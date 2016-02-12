From: Nicolas Cavallari <nicolas.cavallari@green-communications.fr>
Subject: [PATCH iproute2] netns: Fix an off-by-one strcpy() in netns_map_add().
Date: Fri, 12 Feb 2016 14:47:39 +0100
Message-ID: <1455284859-31210-1-git-send-email-nicolas.cavallari@green-communications.fr>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([217.72.192.73]:49953 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752424AbcBLNrr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2016 08:47:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netns_map_add() does a malloc of (sizeof (struct nsid_cache) +
strlen(name)) and then proceed with strcpy() of name into the
zero-length member at the end of the nsid_cache structure.  The
nul-terminator is written outside of the allocated memory and may
overwrite the allocator's internal structure.

This can trigger a segmentation fault on i386 uclibc with names of size 8:
after the corruption occurs, the call to closedir() on netns_map_init()
crashes while freeing the DIR structure.

Here is the relevant valgrind output:

==1251== Memcheck, a memory error detector
==1251== Copyright (C) 2002-2015, and GNU GPL'd, by Julian Seward et al.
==1251== Using Valgrind-3.11.0 and LibVEX; rerun with -h for copyright
info
==1251== Command: ./ip netns
==1251==
==1251== Invalid write of size 1
==1251==    at 0x4011975: strcpy (in
/usr/lib/valgrind/vgpreload_memcheck-x86-linux.so)
==1251==    by 0x8058B00: netns_map_add (ipnetns.c:181)
==1251==    by 0x8058E2A: netns_map_init (ipnetns.c:226)
==1251==    by 0x8058E79: do_netns (ipnetns.c:776)
==1251==    by 0x804D9FF: do_cmd (ip.c:110)
==1251==    by 0x804D814: main (ip.c:300)
---
 ip/ipnetns.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index 088096f..4ce5989 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -172,7 +172,7 @@ static int netns_map_add(int nsid, const char *name)
 	if (netns_map_get_by_nsid(nsid) != NULL)
 		return -EEXIST;
 
-	c = malloc(sizeof(*c) + strlen(name));
+	c = malloc(sizeof(*c) + strlen(name) + 1);
 	if (c == NULL) {
 		perror("malloc");
 		return -ENOMEM;
-- 
2.7.0
