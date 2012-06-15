From: Li Yu <raise.sail@gmail.com>
Subject: [RFC] Introduce to batch variants of accept() and epoll_ctl() syscall
Date: Fri, 15 Jun 2012 12:13:06 +0800
Message-ID: <4FDAB652.6070201@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	davidel@xmailserver.org
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:52353 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750759Ab2FOENS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jun 2012 00:13:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

  We encounter a performance problem in a large scale computer
cluster, which needs to handle a lot of incoming concurrent TCP
connection requests.

  The top shows the kernel is most cpu hog, the testing is simple,
just a accept() -> epoll_ctl(ADD) loop, the ratio of cpu util sys% to
si% is about 2:5.

  I also asked some experienced webserver/proxy developers in my team
for suggestions, it seem that behavior of many userland programs already
called accept() multiple times after it is waked up by
epoll_wait(). And the common action is adding the fd that accept()
return into epoll interface by epoll_ctl() syscall then.

  Therefore, I think that we'd better to introduce to batch variants of
accept() and epoll_ctl() syscall, just like sendmmsg() or recvmmsg().

  For accept(), we may need a new syscall, it may like this,

  struct accept_result {
      int fd;
      struct sockaddr addr;
      socklen_t addr_len;
  };

  int maccept4(int fd, int flags, int nr_accept_result, struct
accept_result *results);

  For epoll_ctl(), there are two means to extend it, I prefer to extend
current interface instead of introduce to new syscall. We may introduce
to a new flag EPOLL_CTL_BATCH. If userland call epoll_ctl() with this
flag set, the meaning of last two arguments of epoll_ctl() change, .e.g:

  struct batch_epoll_event batch_event[] = {
         {
              .fd = a_newsock_fd;
              .epoll_event = { ... };
         },
         ...
  };

  ret = epoll_ctl(fd, EPOLL_CTL_ADD|EPOLL_CTL_BATCH, nr_batch_events,
batch_events);

  Thanks.

Yu
