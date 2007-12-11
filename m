From: Joerg Pommnitz <pommnitz@yahoo.com>
Subject: libnl - netlink library: Memory leak in address cache?
Date: Tue, 11 Dec 2007 06:52:19 -0800 (PST)
Message-ID: <62918.538.qm@web51405.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
To: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web51405.mail.re2.yahoo.com ([206.190.38.184]:30651 "HELO
	web51405.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751178AbXLKOwV convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Dec 2007 09:52:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Thomas and all,
sorry for bothering you if this is the wrong place. The following tiny program leaks memory:

#define _GNU_SOURCE
#include <sys/socket.h>
#include <arpa/inet.h>
#include <stdio.h>

#include <netlink-local.h>
#include <netlink/route/addr.h>

static void
nl_addr_cb (struct nl_object *obj, void *userdata)
{
  struct rtnl_addr *addr = (struct rtnl_addr *)obj;
  char buf[100];
  char buf2[100];
  extern char *if_indextoname(unsigned ifindex, char *ifname);

  printf ("interface %s addr: %s\n",
          if_indextoname(rtnl_addr_get_ifindex (addr), buf2),
          inet_ntop(rtnl_addr_get_family (addr), rtnl_addr_get_local (addr)->a_addr, buf, sizeof (buf)));
}

int main(int argc, char *argv[])
{
  struct nl_handle *nlh;
  struct nl_cache *addr_cache;
  struct rtnl_addr *addr;
  int err = 1;

  extern unsigned if_nametoindex(const char *ifname);

  nlh = nl_handle_alloc();
  if (!nlh)
    return -1;

  addr = rtnl_addr_alloc();
  if (!addr)
    goto errout;

  if (nl_connect(nlh, NETLINK_ROUTE) < 0)
    goto errout_free;

  addr_cache = rtnl_addr_alloc_cache(nlh);
  if (!addr_cache)
    goto errout_close;

  rtnl_addr_set_ifindex(addr, if_nametoindex("eth0"));

  nl_cache_foreach_filter(addr_cache, (struct nl_object *)addr, nl_addr_cb, NULL);

  err = 0;

  nl_cache_free(addr_cache);
 errout_close:
  nl_close(nlh);
 errout_free:
  rtnl_addr_put(addr);
 errout:
  return err;
}

The valgrind output:
==29411== 528 (96 direct, 432 indirect) bytes in 1 blocks are definitely lost in loss record 6 of 8
==29411==    at 0x402095F: calloc (vg_replace_malloc.c:279)
==29411==    by 0x403D938: nl_object_alloc (object.c:49)
==29411==    by 0x404233F: rtnl_addr_alloc (addr.c:627)
==29411==    by 0x404236B: addr_msg_parser (addr.c:194)
==29411==    by 0x4037B7D: nl_cache_parse (cache.c:615)
==29411==    by 0x4037CB6: update_msg_parser (cache.c:438)
==29411==    by 0x403CD00: nl_recvmsgs (netlink-local.h:335)
==29411==    by 0x4038238: __cache_pickup (cache.c:461)
==29411==    by 0x40382F6: nl_cache_pickup (cache.c:494)
==29411==    by 0x40386AF: nl_cache_refill (cache.c:671)
==29411==    by 0x40422D0: rtnl_addr_alloc_cache (addr.c:650)
==29411==    by 0x80489DA: main (in /home_crypt/pommnitz/himonn/HiMoNN-1.3-IPv6/xx/nltest/main)

I think the leak comes from addr_msg_parser. The newly created address object gets added to the cache with nl_cache_add wich takes a reference, so the reference in addr_msg_parser should be dropped, e.g. the following patch might be correct:
--- ../../COMMON/libnl/lib/route/addr.c (revision 1380)
+++ ../../COMMON/libnl/lib/route/addr.c (working copy)
@@ -288,7 +288,7 @@
        if (err < 0)
                goto errout_free;

-       return P_ACCEPT;
+       // return P_ACCEPT;

 errout_free:
        rtnl_addr_put(addr);

 
--  
Kind regards
 
       Joerg
 






      Heute schon einen Blick in die Zukunft von E-Mails wagen? www.yahoo.de/mail
