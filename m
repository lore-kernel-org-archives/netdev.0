From: Jay Smith <jay@kentik.com>
Subject: Re: UDP wierdness around skb_copy_and_csum_datagram_msg()
Date: Mon, 17 Oct 2016 10:10:34 -0700
Message-ID: <87d1iyvr3p.fsf@kentik.com>
References: <CAA3=++__5iwkyyCvSCWJS_b=pBXg=CTYikGgLSh40dkDaY82vg@mail.gmail.com> <3897844.9kvF4Wy8aS@debian64> <87a8epp9ya.fsf@kentik.com> <2193954.GuvoBo3fQP@debian64>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jay Smith <jay@kentik.com>, Alan Curry <rlwinm@sdf.org>,
        Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
        Al Viro <viro@zeniv.linux.org.uk>,
        "davem\@davemloft.net" <davem@davemloft.net>
To: Christian Lamparter <chunkeey@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:36759 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932489AbcJQRLU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 13:11:20 -0400
Received: by mail-pf0-f182.google.com with SMTP id e6so81172956pfk.3
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 10:11:20 -0700 (PDT)
In-reply-to: <2193954.GuvoBo3fQP@debian64>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Trying to revive this thread.

To review:  skb_copy_and_csum_datagram_msg() pretty clearly doesn't do
the right thing since it started using an iov_iter to copy into the
user's iovec.  In particular, if it encounters a datagram that fails the
checksum, the iov_iter continues to point to the end of the failed
datagram's data, and that data makes it out to user-space.

I'd previously sent a test program that consistenly reproduced the UDP(v4)
symptoms of this problem [0].  I've now also taken Christian's netem
suggestion and written a quick program that sends known data over
loopback TCP from one thread and reads it from another.  It optionally
sets up a netem qdisc that corrupts 1% of packets.  As expected, even
with corruption, tcp delivers correct data to the user on pre-3.19
kernels; on 3.19 and later, long transfers usually see corruptions.
(Source for the TCP test program below.)

I've also tried both test programs with the following patch:

diff --git a/net/core/datagram.c b/net/core/datagram.c
index b7de71f..61da091 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -730,6 +730,7 @@ int skb_copy_and_csum_datagram_msg(struct sk_buff *skb,
 {
        __wsum csum;
        int chunk = skb->len - hlen;
+       struct iov_iter saved_iter;
 
        if (!chunk)
                return 0;
@@ -741,11 +742,16 @@ int skb_copy_and_csum_datagram_msg(struct sk_buff *skb,
                        goto fault;
        } else {
                csum = csum_partial(skb->data, hlen, skb->csum);
+
+               /* save msg_iter state, so we can revert if csum fails. */
+               saved_iter = msg->msg_iter;
                if (skb_copy_and_csum_datagram(skb, hlen, &msg->msg_iter,
                                               chunk, &csum))
                        goto fault;
-               if (csum_fold(csum))
+               if (csum_fold(csum)) {
+                       msg->msg_iter = saved_iter;
                        goto csum_error;
+               }
                if (unlikely(skb->ip_summed == CHECKSUM_COMPLETE))
                        netdev_rx_csum_fault(skb->dev);
        }


(This is essentially the same fix Alan previously sent [1], except that
it uses struct assignment rather than memcpy'ing the struct iov_iter.)
As expected, both UDP and TCP tests succeed under this fix.

So I've missed whatever conversations happened off-list after Alan's
original report.  But it appears to me that this patch completely
resolves the csum/iov_iter problem for both TCP and UDP; I'm not sure I
see what further problem we'd want to hold the fix off for?

[0] https://www.spinics.net/lists/netdev/msg398026.html
[1] https://patchwork.kernel.org/patch/9260733/


New TCP test program:

#include <unistd.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <pthread.h>

#include <netlink/route/tc.h>
#include <netlink/route/qdisc.h>
#include <netlink/route/qdisc/netem.h>

int bytes = 0;
struct sockaddr_in addr;
socklen_t addrLen = sizeof(addr);  


void *sender(void *ignore)
{
  int send = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
  if (send < 0)
  {
    fprintf(stderr, "failed to create sending socket (err=%d: %s)\n", errno, strerror(errno));
    exit(1);
  }

  int ret = connect(send, (struct sockaddr *) &addr, addrLen);
  if (ret != 0)
  {
    fprintf(stderr, "failed to connect sending socket (err=%d: %s)\n", errno, strerror(errno));
    exit(1);
  }

  int i = 0;
  while (i < bytes)
  {
#define OUT_MESSAGE  "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    int w = write(send, OUT_MESSAGE, strlen(OUT_MESSAGE));
    if (w < 0)
    {
      fprintf(stdout, "failed to write byte %d\n", i);
      exit(1);
    }
    i += w;
  }

  close(send);
}

/* set a qdisc on lo with corruption_probability 1% (or remove if if on==0) */
void setCorrupt(int on)
{
  struct nl_sock *sock;
  struct nl_cache *cache;
  struct rtnl_qdisc *q;
  struct rtnl_link *link;
  int if_index;

  sock = nl_socket_alloc();
  nl_connect(sock, NETLINK_ROUTE);

  rtnl_link_alloc_cache(sock, AF_UNSPEC, &cache);
  link = rtnl_link_get_by_name(cache, "lo");
  if_index = rtnl_link_get_ifindex(link);

  q = rtnl_qdisc_alloc();
  rtnl_tc_set_ifindex(TC_CAST(q), if_index);
  rtnl_tc_set_parent(TC_CAST(q), TC_H_ROOT);
  rtnl_tc_set_handle(TC_CAST(q), TC_HANDLE(1, 0));
  rtnl_tc_set_kind(TC_CAST(q), "netem");
  rtnl_netem_set_corruption_probability(q, 0xffffffff / 100);
  if (on)
  {
    int ret = rtnl_qdisc_add(sock, q, NLM_F_CREATE);
    if (ret < 0)
      {
	fprintf(stderr, "rtnl_qdisc_add error: %s\n", nl_geterror(ret));
	exit(1);
      }
  }
  else
  {
    int ret = rtnl_qdisc_delete(sock, q);
    if (ret < 0)
      {
	fprintf(stderr, "rtnl_qdisc_del error: %s\n", nl_geterror(ret));
	exit(1);
      }
  }

  rtnl_qdisc_put(q);
  nl_socket_free(sock);
  rtnl_link_put(link);
  nl_cache_put(cache);
}


int main(int argc, char **argv)
{
  if (argc < 2)
  {
    fprintf(stderr, "Usage: tcpcsum <number-of-bytes> [corruption-rate]");
    exit(1);
  }

  bytes = atoi(argv[1]);
  int corrupt = argc > 2;

  if (corrupt)
  {
    setCorrupt(1);
  }

  addr.sin_family = AF_INET;
  addr.sin_addr.s_addr = inet_addr("127.0.0.1");
  addr.sin_port = htons(0);

  int l = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
  if (l < 0)
  {
    fprintf(stderr, "failed to create listening socket (err=%d: %s)\n", errno, strerror(errno));
    goto exit;
  }

  int ret = bind(l, (struct sockaddr *) &addr, addrLen);
  if (ret != 0)
  {
    fprintf(stderr, "failed to bind listening socket socket (err=%d: %s)\n", errno, strerror(errno));
    goto exit;
  }

  ret = listen(l, 5);
  if (ret != 0)
  {
    fprintf(stderr, "listen failed (err=%d: %s)\n", errno, strerror(errno));
    goto exit;
  }

  ret = getsockname(l, (struct sockaddr *) &addr, &addrLen);
  if (ret != 0)
  {
    fprintf(stderr, "getsockname failed for listening socket socket (err=%d: %s)\n", errno, strerror(errno));
    goto exit;
  }
  else
  {
    printf("listening on port %d\n", ntohs(addr.sin_port));
  }
  
  // Launch writer thread
  pthread_t t;
  ret = pthread_create(&t, NULL, &sender, NULL);
  if (ret != 0)
  {
    fprintf(stderr, "pthread_create failed: (err=%d: %s)\n", errno, strerror(errno));
    goto exit;
  }

  int recv = accept(l, NULL, NULL);
  if (recv < 0)
  {
    fprintf(stderr, "accept failed: (err=%d: %s)\n", errno, strerror(errno));
    goto exit;
  }
   
#define BUFLEN  16384
  char buf[BUFLEN];
  int total = 0;
  int r = 0;
  while((r = read(recv, buf, BUFLEN)))
  {
    if(r < 0)
    {
      perror("read from socket");
      return 1;
    }

    if (r == 0)
    {
      break;
    }
    
    int i;
    for(i= 0; i < r; i++, total++)
    {
      if (buf[i] != 'a')
      {
	fprintf(stdout, "data corruption found at byte %d: %c\n", total, buf[i]);
	goto exit;
      }
    }
  }

  fprintf(stdout, "read %d bytes without data corruption\n", total);

exit:
  if (corrupt)
  {
    setCorrupt(0);
  }
  exit(0);
}
