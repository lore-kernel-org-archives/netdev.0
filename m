From: Alexandre Cassen <Alexandre.Cassen@wanadoo.fr>
Subject: [PATCH] IPVS syncd zombies fixe
Date: Tue, 17 Aug 2004 21:44:19 +0200
Sender: lvs-users-bounces@LinuxVirtualServer.org
Message-ID: <6.0.1.1.2.20040817210751.01b951f0@mail>
Reply-To: "LinuxVirtualServer.org users mailing list." <lvs-users@LinuxVirtualServer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: lvs-users@linuxvirtualserver.org
Return-path: <lvs-users-bounces@LinuxVirtualServer.org>
To: Wensong Zhang <wensong@linux-vs.org>
Cc: netdev@oss.sgi.com
Cc: keepalived-devel@lists.sourceforge.net
List-Unsubscribe: <http://www.in-addr.de/mailman/listinfo/lvs-users>,
	<mailto:lvs-users-request@LinuxVirtualServer.org?subject=unsubscribe>
List-Archive: <http://www.in-addr.de/pipermail/lvs-users>
List-Post: <mailto:lvs-users@LinuxVirtualServer.org>
List-Help: <mailto:lvs-users-request@LinuxVirtualServer.org?subject=help>
List-Subscribe: <http://www.in-addr.de/mailman/listinfo/lvs-users>,
	<mailto:lvs-users-request@LinuxVirtualServer.org?subject=subscribe>
Errors-To: lvs-users-bounces@LinuxVirtualServer.org
List-Id: netdev.vger.kernel.org

Hello Wensong,

I received since last few months lot of bug report from Keepalived users 
using VRRP with ipvs syncd option. Finally today, I found time to look at 
this issue and have a patch for syncd code.

While starting a kernel syncd thread, we must reap the fork_sync_thread 
since this will produce zombies while returning to main calling point. 
Since syncd parent is the init process, we don't need to reap it during the 
syncd shutdown but we must reap it at starting time.

You will find bellow a patch to fixe this and a quick trash C code to argue 
and highlight the need. The patch is against 2.6.7, same patch must be 
applied to 2.4 branch.

Best regards,
Alexandre



--[ Patch: Begin Snip ]--

diff -urN linux-2.6.7.orig/net/ipv4/ipvs/ip_vs_sync.c 
linux-2.6.7/net/ipv4/ipvs/ip_vs_sync.c
--- linux-2.6.7.orig/net/ipv4/ipvs/ip_vs_sync.c 2004-06-16 
07:18:38.000000000 +0200
+++ linux-2.6.7/net/ipv4/ipvs/ip_vs_sync.c      2004-08-17 
18:30:36.143940704 +0200
@@ -18,9 +18,11 @@
   *                                     messages filtering.
   */

+#define __KERNEL_SYSCALLS__            /*  for waitpid */
+
  #include <linux/module.h>
  #include <linux/slab.h>
-#include <linux/net.h>
+#include <linux/unistd.h>
  #include <linux/completion.h>

  #include <linux/skbuff.h>
@@ -612,6 +614,7 @@
         return len;
  }

+static int errno;

  static DECLARE_WAIT_QUEUE_HEAD(sync_wait);
  static pid_t sync_master_pid = 0;
@@ -840,6 +843,7 @@
  int start_sync_thread(int state, char *mcast_ifn, __u8 syncid)
  {
         DECLARE_COMPLETION(startup);
+       int waitpid_result;
         pid_t pid;

         if ((state == IP_VS_STATE_MASTER && sync_master_pid) ||
@@ -868,6 +872,15 @@
                 goto repeat;
         }

+       /*
+        * We must reap the fork_sync_thread here. Really needed to not
+        * produce zombies while returning.
+        */
+       if ((waitpid_result = waitpid(pid, NULL, __WCLONE)) != pid) {
+               IP_VS_ERR("%s: waitpid(%d,...) failed, errno %d\n",
+                         __FUNCTION__, pid, -waitpid_result);
+       }
+
         wait_for_completion(&startup);

         return 0;

--[ Patch: End Snip ]--



--[ Quick Code: Begin Snip ]--

/*
  * Soft:        Simple IPVS Syncd probing tool.
  *
  * Compilation: gcc -I/usr/src/linux/include main.c -o syncd_zombies
  *
  * Version:     $Id: main.c,v 0.0.1 2004/08/17 21:35:41 acassen Exp $
  *
  * Authors:     Alexandre Cassen, <acassen@linux-vs.org>
  *
  *              This program is distributed in the hope that it will be 
useful,
  *              but WITHOUT ANY WARRANTY; without even the implied warranty of
  *              MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  *              See the GNU General Public License for more details.
  *
  *              This program is free software; you can redistribute it and/or
  *              modify it under the terms of the GNU General Public License
  *              as published by the Free Software Foundation; either version
  *              2 of the License, or (at your option) any later version.
  *
  * Copyright (C) 2001-2004 Alexandre Cassen, <acassen@linux-vs.org>
  */

#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <net/ip_vs.h>

static struct ip_vs_daemon_user *daemonrule;
static int sockfd = -1;
static void *ipvs_func = NULL;
struct ip_vs_getinfo ipvs_info;
typedef struct ip_vs_daemon_user ipvs_daemon_t;

int
ipvs_init(void)
{
         socklen_t len;

         len = sizeof (ipvs_info);
         if ((sockfd = socket(AF_INET, SOCK_RAW, IPPROTO_RAW)) == -1)
                 return -1;

         if (getsockopt(sockfd, IPPROTO_IP, IP_VS_SO_GET_INFO,
                        (char *) &ipvs_info, &len))
                 return -1;

         return 0;
}

int
ipvs_start_daemon(ipvs_daemon_t * dm)
{
         ipvs_func = ipvs_start_daemon;
         return setsockopt(sockfd, IPPROTO_IP, IP_VS_SO_SET_STARTDAEMON,
                           (char *) dm, sizeof (*dm));
}

extern int
ipvs_stop_daemon(ipvs_daemon_t * dm)
{
         ipvs_func = ipvs_stop_daemon;
         return setsockopt(sockfd, IPPROTO_IP, IP_VS_SO_SET_STOPDAEMON,
                           (char *) dm, sizeof (*dm));
}

static int
modprobe_ipvs(void)
{
         char *argv[] = { "/sbin/modprobe", "-s", "-k", "--", "ip_vs", NULL };
         int child;
         int status;
         int rc;

         if (!(child = fork())) {
                 execv(argv[0], argv);
                 exit(1);
         }

         rc = waitpid(child, &status, 0);
         if (!WIFEXITED(status) || WEXITSTATUS(status))
                 return 1;
         return 0;
}

static void
ipvs_talk(int cmd)
{
         int result = -1;

         switch (cmd) {
         case IP_VS_SO_SET_STARTDAEMON:
                 result = ipvs_start_daemon(daemonrule);
                 break;
         case IP_VS_SO_SET_STOPDAEMON:
                 result = ipvs_stop_daemon(daemonrule);
                 break;
         }
}

static int
ipvs_start(void)
{
         if (ipvs_init()) {
                 if (modprobe_ipvs() || ipvs_init()) {
                         printf("IPVS: Can't initialize IPVS !!!\n");
                         return -1;
                 }
         }
         return 0;
}

int
ipvs_syncd_cmd(int cmd, char *ifname, int state)
{
         memset(daemonrule, 0, sizeof (struct ip_vs_daemon_user));
         daemonrule->state = state;
         strncpy(daemonrule->mcast_ifn, ifname, IP_VS_IFNAME_MAXLEN);
         ipvs_talk(cmd);
         return 0;
}

int
main(int argc, char **argv)
{
         daemonrule = (struct ip_vs_daemon_user *) malloc(sizeof (struct 
ip_vs_daemon_user));

         ipvs_start();
         ipvs_syncd_cmd(IP_VS_SO_SET_STARTDAEMON, "eth0", IP_VS_STATE_MASTER);
         ipvs_syncd_cmd(IP_VS_SO_SET_STOPDAEMON, "eth0", IP_VS_STATE_MASTER);
         ipvs_syncd_cmd(IP_VS_SO_SET_STARTDAEMON, "eth0", IP_VS_STATE_BACKUP);
         ipvs_syncd_cmd(IP_VS_SO_SET_STOPDAEMON, "eth0", IP_VS_STATE_BACKUP);

         free(daemonrule);

         for (;;) { /* Dummy loop */ }
         exit(0);
}

--[ Quick Code: End Snip ]--


_______________________________________________
LinuxVirtualServer.org mailing list - lvs-users@LinuxVirtualServer.org
Send requests to lvs-users-request@LinuxVirtualServer.org
or go to http://www.in-addr.de/mailman/listinfo/lvs-users
