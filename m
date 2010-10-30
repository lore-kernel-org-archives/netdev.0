From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: Re: [PATCH 0/1] RFC: poll/select performance on datagram sockets
Date: Sat, 30 Oct 2010 12:34:03 +0100
Message-ID: <20101030123403.5e01540d@chocolatine.cbg.collabora.co.uk>
References: <20101029191857.5f789d56@chocolatine.cbg.collabora.co.uk>
	<1288380431.2680.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cyrill Gorcunov <gorcunov@openvz.org>,
	Alexey Dobriyan <adobriyan@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Pauli Nieminen <pauli.nieminen@collabora.co.uk>,
	Rainer Weikusat <rweikusat@mssgmbh.com>,
	Davide Libenzi <davidel@xmailserver.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([93.93.128.226]:43418 "EHLO
	bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752639Ab0J3Lgq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Oct 2010 07:36:46 -0400
In-Reply-To: <1288380431.2680.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Fri, 29 Oct 2010 21:27:11 +0200,
Eric Dumazet <eric.dumazet@gmail.com> a =C3=A9crit :

> Le vendredi 29 octobre 2010 =C3=A0 19:18 +0100, Alban Crequy a =C3=A9=
crit :
> > Hi,
> >=20
> > When a process calls the poll or select, the kernel calls (struct
> > file_operations)->poll on every file descriptor and returns a mask
> > of events which are ready. If the process is only interested by
> > POLLIN events, the mask is still computed for POLLOUT and it can be
> > expensive. For example, on Unix datagram sockets, a process running
> > poll() with POLLIN will wakes-up when the remote end call read().
> > This is a performance regression introduced when fixing another bug
> > by 3c73419c09a5ef73d56472dbfdade9e311496e9b and
> > ec0d215f9420564fc8286dcf93d2d068bb53a07e.
> >=20
> > The attached program illustrates the problem. It compares the
> > performance of sending/receiving data on an Unix datagram socket an=
d
> > select(). When the datagram sockets are not connected, the
> > performance problem is not triggered, but when they are connected
> > it becomes a lot slower. On my computer, I have the following time:
> >=20
> > Connected datagram sockets: >4 seconds
> > Non-connected datagram sockets: <1 second
> >=20
> > The patch attached in the next email fixes the performance problem:
> > it becomes <1 second for both cases. I am not suggesting the patch
> > for inclusion; I would like to change the prototype of (struct
> > file_operations)->poll instead of adding ->poll2. But there is a
> > lot of poll functions to change (grep tells me 337 functions).
> >=20
> > Any opinions?
>=20
> My opinion would be to use epoll() for this kind of workload.

I found a problem with epoll() with the following program. When there
is several datagram sockets connected to the same server and the
receiving queue is full, epoll(EPOLLOUT) wakes up only the emitter who
has its skb removed from the queue, and not all the emitters. It is
because sock_wfree() runs sk->sk_write_space() only for one emitter.

poll/select do not have this problem.

-----------------------

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <time.h>
#include <sys/epoll.h>

int
main(int argc, char *argv[])
{

// cat /proc/sys/net/unix/max_dgram_qlen
#define NB_CLIENTS (10 + 2)

  int client_fds[NB_CLIENTS];
  int server_fd;
  struct sockaddr_un addr_server;
  int epollfd =3D epoll_create(10);
#define MAX_EVENTS 10
  struct epoll_event ev, events[MAX_EVENTS];
  int i;
  char buffer[1024];

  int trigger =3D atoi(argv[1]);
  printf("trigger =3D %d\n", trigger);

  memset(&addr_server, 0, sizeof(addr_server));
  addr_server.sun_family =3D AF_UNIX;
  addr_server.sun_path[0] =3D '\0';
  strcpy(addr_server.sun_path + 1, "dgram_perfs_server");

  server_fd =3D socket(AF_UNIX, SOCK_DGRAM, 0);
  bind(server_fd, (struct sockaddr*)&addr_server, sizeof(addr_server));

  for (i =3D 0 ; i < NB_CLIENTS ; i++)
    {
      client_fds[i] =3D socket(AF_UNIX, SOCK_DGRAM, 0);
    }

  ev.events =3D EPOLLOUT;
  ev.data.fd =3D client_fds[NB_CLIENTS-1];
  if (epoll_ctl(epollfd, EPOLL_CTL_ADD, client_fds[NB_CLIENTS-1], &ev) =
=3D=3D -1) {
      perror("epoll_ctl: client_fds max");
      exit(EXIT_FAILURE);
  }
  if (trigger =3D=3D 0)
    {
      ev.events =3D EPOLLOUT;
      ev.data.fd =3D client_fds[0];
      if (epoll_ctl(epollfd, EPOLL_CTL_ADD, client_fds[0], &ev) =3D=3D =
-1) {
        perror("epoll_ctl: client_fds 0");
        exit(EXIT_FAILURE);
      }
    }

  for (i =3D 0 ; i < NB_CLIENTS ; i++)
    {
      connect(client_fds[i], (struct sockaddr*)&addr_server, sizeof(add=
r_server));
    }

  if (fork() > 0)
    {
      for (i =3D 0 ; i < NB_CLIENTS - 1 ; i++)
        sendto(client_fds[i], "S", 1, 0, (struct sockaddr*)&addr_server=
, sizeof(addr_server));
      printf("Everything sent successfully. Now epoll_wait...\n");

      epoll_wait(epollfd, events, MAX_EVENTS, -1);
      printf("epoll_wait works fine :-)\n");
      wait(NULL);
      exit(0);
    }

  sleep(1);

  printf("Receiving one buffer...\n");
  recv(server_fd, buffer, 1024, 0);
  printf("One buffer received\n");

  return 0;
}
