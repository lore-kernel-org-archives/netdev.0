From: Ming Zhao <mingzhao@gmail.com>
Subject: Fwd: EPOLLOUT is triggered after sending data on UDP socket without EAGAIN
Date: Tue, 15 Apr 2014 22:46:53 -0700
Message-ID: <CAN0GiO2M53LV=6wLdvEu=0yoT+nS+tGXPOROJmsQTWH=azdpzQ@mail.gmail.com>
References: <CAN0GiO0GR09a5cU3ALNzbDosmRh8aNoNvQ0meE8nG4e2ikvacQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:49752 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751845AbaDPFqx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2014 01:46:53 -0400
Received: by mail-oa0-f46.google.com with SMTP id i7so11975307oag.33
        for <netdev@vger.kernel.org>; Tue, 15 Apr 2014 22:46:53 -0700 (PDT)
In-Reply-To: <CAN0GiO0GR09a5cU3ALNzbDosmRh8aNoNvQ0meE8nG4e2ikvacQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi there,

I'm not sure whether this is an epoll bug:

- I have a UDP socket which is non-blocking and watched by epoll with
(EPOLLOUT | EPOLLET).
- EPOLLOUT is triggered after registering the file descriptor with
epoll_add, which is expected.
- After calling sendto on the UDP socket with a very small message(5
bytes), sendto returns the exact number of bytes sent and no EAGAIN is
generated.
- *but* calling epoll_wait still returns EPOLLOUT.

Shouldn't that EPOLLOUT be only triggered when an EAGAIN is generated
after any writing operation?

Here is the code I use:
==================
We have very simple wrapper for socket and epoll operations, and you
can easily guess what they're doing

TEST(EpollService, UdpWriteable) {
  Socket client(Socket::UDP());
  Socket server(Socket::UDP());

  // Ask os to pick random port
  CHECK_ERR(server.Bind(SocketAddress(SocketAddress::LOOPBACK, 0)));
  const SocketAddress server_addr(server.GetMyAddress());
  ASSERT_TRUE(SocketOption::SetBlocking(client.fd(), false));

  EpollService eps;
  eps.Add(client.fd(), EPOLLOUT | EPOLLET, NULL);
  epoll_event event;
  // The fd should be writable.
  ASSERT_EQ(1, eps.Wait(&event, 1, 0));
  // No more writable event.
  ASSERT_EQ(0, eps.Wait(&event, 1, 0));

  const char buffer[] = "abcd";
  CHECK_ERR(::sendto(client.fd(), buffer, ARRAYSIZE(buffer), 0,
                     server_addr.addr(), server_addr.length()))1;
  EXPECT_EQ(0, eps.Wait(&event, 1, 0)) << "Got unexpect event " << event.events;
  EXPECT_EQ(0, eps.Wait(&event, 1, 0)) << "Got unexpect event " << event.events;

  client.Close();
  server.Close();
}

And strace output:
===============

write(1, "\33[0;32m[ RUN      ] \33[mEpollServ"..., 49[ RUN      ]
EpollService.UdpWriteable
) = 49
socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) = 4
socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) = 5
bind(5, {sa_family=AF_INET,
sin_port=htons(0),sin_addr=inet_addr("127.0.0.1")}, 16) = 0
getsockname(5, {sa_family=AF_INET,
sin_port=htons(51019),sin_addr=inet_addr("127.0.0.1")}, [16]) = 0
fcntl(4, F_GETFL)                       = 0x2 (flags O_RDWR)
fcntl(4, F_SETFL, O_RDWR|O_NONBLOCK)    = 0
epoll_create(1024)                      = 6
epoll_ctl(6, EPOLL_CTL_ADD, 4, {EPOLLOUT|EPOLLET, {u32=0, u64=0}}) = 0
epoll_wait(6, {{EPOLLOUT, {u32=0, u64=0}}}, 1, 0) = 1
epoll_wait(6, {}, 1, 0)                 = 0
sendto(4, "abcd\0", 5, 0, {sa_family=AF_INET,
sin_port=htons(51019),sin_addr=inet_addr("127.0.0.1")}, 16) = 5
epoll_wait(6, {{EPOLLOUT, {u32=0, u64=0}}}, 1, 0) = 1
write(1, "net/base/eventmanager_test.cc:50"...,99net/base/eventmanager_test.cc:50:
Failure

Value of: eps.Wait(&event, 1, 0)

  Actual: 1

Expected: 0

) = 99

write(1, "Got unexpect event 4\n", 21Got unexpect event 4
)  = 21
epoll_wait(6, {}, 1, 0)                 = 0
close(4)                                = 0
close(5)                                = 0
close(6)                                = 0

write(1, "\33[0;31m[  FAILED  ] \33[mEpollServ"..., 56[  FAILED  ]
EpollService.UdpWriteable (2 ms)

Thank you for your feedback!
