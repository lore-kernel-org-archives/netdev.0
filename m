From: akpm@linux-foundation.org
Subject: [patch 02/28] ip_auto_config fix
Date: Fri, 10 Aug 2007 14:11:49 -0700
Message-ID: <200708102111.l7ALBnLl009370@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	joakim.tjernlund@transmode.se, trond.myklebust@fys.uio.no
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:53554 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S942232AbXHJVMr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 17:12:47 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joakim Tjernlund <joakim.tjernlund@transmode.se>

The following commandline:

 root=/dev/mtdblock6 rw rootfstype=jffs2 ip=192.168.1.10:::255.255.255.0:localhost.localdomain:eth1:off console=ttyS0,115200

makes ip_auto_config fall back to DHCP and complain "IP-Config: Incomplete
network configuration information." depending on if CONFIG_IP_PNP_DHCP is
set or not.

The only way I can make ip_auto_config accept my IP config is to add an
entry for the server IP:

ip=192.168.1.10:192.168.1.15::255.255.255.0:localhost.localdomain:eth1:off

I think this is a bug since I am not using a NFS root FS.

The following patch fixes the above problem.


From: Andrew Morton <akpm@linux-foundation.org>

Davem said (in February!):

  Well, first of all the change in question is not in 2.4.x either.  I just
  checked the current 2.4.x GIT tree and the test is exactly:

	if (ic_myaddr == INADDR_NONE ||
#ifdef CONFIG_ROOT_NFS
	    (MAJOR(ROOT_DEV) == UNNAMED_MAJOR
	     && root_server_addr == INADDR_NONE
	     && ic_servaddr == INADDR_NONE) ||
#endif
	    ic_first_dev->next) {

  which matches 2.6.x

  I even checked 2.4.x when it was branched for 2.5.x and the test was the
  same at the point in time too.

  Looking at the proposed change a bit it appears that it is probably
  correct, as it's trying to check that ROOT_DEV is nfs root.  But if it is
  correct then the UNNAMED_MAJOR comparison in the same code block should be
  removed as it becomes superfluous.

  I'm happy to apply this patch with that modification made.


Signed-off-by: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>

Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/ipv4/ipconfig.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff -puN net/ipv4/ipconfig.c~ip_auto_config-fix net/ipv4/ipconfig.c
--- a/net/ipv4/ipconfig.c~ip_auto_config-fix
+++ a/net/ipv4/ipconfig.c
@@ -1281,9 +1281,9 @@ static int __init ip_auto_config(void)
 	 */
 	if (ic_myaddr == NONE ||
 #ifdef CONFIG_ROOT_NFS
-	    (MAJOR(ROOT_DEV) == UNNAMED_MAJOR
-	     && root_server_addr == NONE
-	     && ic_servaddr == NONE) ||
+	    (root_server_addr == NONE
+	     && ic_servaddr == NONE
+	     && ROOT_DEV == Root_NFS) ||
 #endif
 	    ic_first_dev->next) {
 #ifdef IPCONFIG_DYNAMIC
_
