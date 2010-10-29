From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: [PATCH 0/1] RFC: poll/select performance on datagram sockets
Date: Fri, 29 Oct 2010 19:18:57 +0100
Message-ID: <20101029191857.5f789d56@chocolatine.cbg.collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: Alban Crequy <alban.crequy@collabora.co.uk>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cyrill Gorcuno
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([93.93.128.226]:33841 "EHLO
	bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751516Ab0J2SVi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 14:21:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

When a process calls the poll or select, the kernel calls (struct
file_operations)->poll on every file descriptor and returns a mask of
events which are ready. If the process is only interested by POLLIN
events, the mask is still computed for POLLOUT and it can be expensive.
For example, on Unix datagram sockets, a process running poll() with
POLLIN will wakes-up when the remote end call read(). This is a
performance regression introduced when fixing another bug by
3c73419c09a5ef73d56472dbfdade9e311496e9b and
ec0d215f9420564fc8286dcf93d2d068bb53a07e.

The attached program illustrates the problem. It compares the
performance of sending/receiving data on an Unix datagram socket and
select(). When the datagram sockets are not connected, the performance
problem is not triggered, but when they are connected it becomes a lot
slower. On my computer, I have the following time:

Connected datagram sockets: >4 seconds
Non-connected datagram sockets: <1 second

The patch attached in the next email fixes the performance problem: it
becomes <1 second for both cases. I am not suggesting the patch for
inclusion; I would like to change the prototype of (struct
file_operations)->poll instead of adding ->poll2. But there is a lot of
poll functions to change (grep tells me 337 functions).

Any opinions?

Best regards,
Alban Crequy


---------------
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <time.h>

int
main(int argc, char *argv[])
{
#define NB_CLIENTS 800
  int client_fds[NB_CLIENTS];
  int server_fd;
  int max_fds = 0;
  struct sockaddr_un addr_server;
  struct sockaddr_un addr_client;
  fd_set rfds;
  struct timeval tv;
  int retval;
  int i;
  char buffer[1024];
  int pair[2] = {0,0};
  time_t t1, t2;
  int trigger;

  if (argc != 2)
    exit(1);

  if (strcmp(argv[1], "connected") == 0)
    {
      printf("The performance problem will be triggered\n");
      trigger = 1;
    }
  else
    {
      printf("The performance will be good\n");
      trigger = 0;
    }

  memset(&addr_server, 0, sizeof(addr_server));
  addr_server.sun_family = AF_UNIX;
  addr_server.sun_path[0] = '\0';
  strcpy(addr_server.sun_path + 1, "dgram_perfs_server");

  memset(&addr_client, 0, sizeof(addr_client));
  addr_client.sun_family = AF_UNIX;
  addr_client.sun_path[0] = '\0';
  strcpy(addr_client.sun_path + 1, "dgram_perfs_client");

  server_fd = socket(AF_UNIX, SOCK_DGRAM, 0);
  bind(server_fd, (struct sockaddr*)&addr_server, sizeof(addr_server));

  FD_ZERO(&rfds);
  for (i = 0 ; i < NB_CLIENTS ; i++)
    {
      client_fds[i] = socket(AF_UNIX, SOCK_DGRAM, 0);
      FD_SET(client_fds[i], &rfds);
      if (client_fds[i] > max_fds)
        max_fds = client_fds[i];
    }
  max_fds++;

  /* Do not connect the first one */
  for (i = 1 ; i < NB_CLIENTS ; i++)
    {
      if (trigger)
        connect(client_fds[i], (struct sockaddr*)&addr_server, sizeof(addr_server));
    }
  bind(client_fds[0], (struct sockaddr*)&addr_client, sizeof(addr_client));

  tv.tv_sec = 500;
  tv.tv_usec = 0;

  socketpair(AF_UNIX, SOCK_STREAM, 0, pair);

  if (fork() != 0)
  {
    recv(pair[1], buffer, 1024, 0);
    usleep(1000);
    for (i = 0 ; i < 20000 ; i++)
    {
      sendto(client_fds[0], "S", 1, 0, (struct sockaddr*)&addr_server, sizeof(addr_server));
      recv(server_fd, buffer, 1024, 0);
    }
    sendto(client_fds[0], "Z", 1, 0, (struct sockaddr*)&addr_client, sizeof(addr_client));
    wait(NULL);
    exit(0);
  }

  send(pair[0], "W", 1, 0);
  printf("select: begin\n");
  t1 = time(NULL);
  retval = select(max_fds, &rfds, NULL, NULL, &tv);
  t2 = time(NULL);
  printf("select: end: %d seconds\n", t2 - t1);

  return 0;
}
---------------

