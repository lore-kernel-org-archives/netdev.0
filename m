From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: On IP_FREEBIND and IPv6...
Date: Tue, 1 Nov 2011 17:57:07 -0700
Message-ID: <CAHo-Oow3LhhvMEO8ph7ZM2TO48KtTak+VZjY56ceWdhxeyUzgA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Linux NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:45989 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753489Ab1KBA5I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2011 20:57:08 -0400
Received: by qabj40 with SMTP id j40so6313861qab.19
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2011 17:57:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Short summary:
  IPV6 + IP_FREEBIND doesn't work the way IPV4 + IP_FREEBIND does.
  The native IPv6 bind path ignores 'freebind', but honours 'transparent'.
  The native and dual-stack IPv4 bind paths honour both.

Does anyone know if this was a (security?) feature?  Or is this just a bug?

I'll follow this up with a patch to support freebind for v6 bind (and
another one for v6 udp sendmsg).
Unless I hear some compelling story about why stuff is the way it is.

---

Please find test program source later on.

It basically does:
   for test_mode in {native_ipv4, ipv4_on_ipv6_socket, native_ipv6} do:
       create a udp socket
       set IP_FREEBIND=1
       set IP_TRANSPARENT=1 (will fail if not root, ignore failure)
       bind socket to an IP address we don't own (one of: 1.2.3.4,
::FFFF:1.2.3.4, 2001:4860:DEAD:CAFE::6006:13) [fails without root for
native ipv6]
       send a packet to another IP address (one of: 5.6.7.8,
::FFFF:5.6.7.8, 2001:4860:DEAD:BEEF::6006:13)

Running it generates:

$ ./test
setsockopt(TRANSPARENT=1): Operation not permitted [requires root]
setsockopt(TRANSPARENT=1): Operation not permitted [requires root]
setsockopt(TRANSPARENT=1): Operation not permitted [requires root]
bind(): Cannot assign requested address [native ipv6 bind does not
honour IP_FREEBIND, does honour IP{,V6}_TRANSPARENT]
$ sudo ./test
<no errors, everything succeeds, including bind native ipv6>

While running tcpdump shows:
# tcpdump -s 1555 -n -nn -i eth0 port 11111 or port 22222

>From ./a [ie. with IP_FREEBIND=1, IP_TRANSPARENT=0]:

IP 1.2.3.4.11111 > 5.6.7.8.22222: UDP, length 6 [native IPv4]
IP 1.2.3.4.11111 > 5.6.7.8.22222: UDP, length 6 [dual stack IPv4 on IPv6 socket]
IP6 [machines_true_ipv6_address].51912 >
2001:4860:dead:beef::6006:13.22222: UDP, length 6 [native IPv6, wrong
source since bind failed]

>From sudo ./a [ie. with IP_FREEBIND=1, IP_TRANSPARENT=1]:

IP 1.2.3.4.11111 > 5.6.7.8.22222: UDP, length 6 [native IPv4]
IP 1.2.3.4.11111 > 5.6.7.8.22222: UDP, length 6 [dual stack IPv4 on IPv6 socket]
IP6 2001:4860:dead:cafe::6006:13.vce >
2001:4860:dead:beef::6006:13.22222: UDP, length 6 [native IPv6]

This seems to prove that IP_TRANSPARENT requires root - this is as
expected, while IP_FREEBIND does not require root - again as expected.
However, as apparent above, we are successfully spoofing outgoing
source address on IPv4 UDP (whether native IPv4 or dual-stack IPv4
doesn't matter),
but there doesn't seem to be a way to do this with native IPv6.

ie. the native IPv6 bind path ignores the "freebind" setting, but does
honour the "transparent", while the IPv4 code paths honour both.

- Maciej

---
#include <string.h>
#include <stdio.h>

#include <sys/types.h>
#include <sys/socket.h>

#include <netinet/in.h>
#include <arpa/inet.h>

#define NATIVE_IPv4 0
#define DUAL_STACK  1
#define NATIVE_IPv6 2

int main(int argc, char const * argv[], char const * envp[]) {
  struct sockaddr_in saddr4, daddr4;
  struct sockaddr_in6 saddr6, daddr6;
  int fd, rv, v, mode;

  for (mode = 0; mode <= 2; ++mode) {

    if (mode == NATIVE_IPv4) {
      fd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
      if (fd < 0) perror("socket(IPv4 UDP)");
    } else {
      fd = socket(AF_INET6, SOCK_DGRAM, IPPROTO_UDP);
      if (fd < 0) perror("socket(IPv6 UDP)");
    }

    v = 1;
    rv = setsockopt(fd, SOL_IP, IP_FREEBIND, &v, sizeof(v));
    if (rv < 0) perror("setsockopt(FREEBIND=1)");

    v = 1;
    rv = setsockopt(fd, SOL_IP, IP_TRANSPARENT, &v, sizeof(v));
    if (rv < 0) perror("setsockopt(TRANSPARENT=1)");

    if (mode == NATIVE_IPv4) {
      memset(&saddr4, 0, sizeof(saddr4));
      memset(&daddr4, 0, sizeof(daddr4));
      saddr4.sin_family = AF_INET;
      daddr4.sin_family = AF_INET;
      saddr4.sin_port = htons(11111);
      daddr4.sin_port = htons(22222);
      inet_pton(AF_INET, "1.2.3.4", &saddr4.sin_addr.s_addr);
      inet_pton(AF_INET, "5.6.7.8", &daddr4.sin_addr.s_addr);

      rv = bind(fd, (struct sockaddr const *)&saddr4, sizeof(saddr4));
      if (rv < 0) perror("bind()");

      rv = sendto(fd, "Hello!", 6, 0, (struct sockaddr const
*)&daddr4, sizeof(daddr4));
      if (rv < 0) perror("write");
    } else {
      memset(&saddr6, 0, sizeof(saddr6));
      memset(&daddr6, 0, sizeof(daddr6));
      saddr6.sin6_family = AF_INET6;
      daddr6.sin6_family = AF_INET6;
      saddr6.sin6_port = htons(11111);
      daddr6.sin6_port = htons(22222);
      //saddr6.sin6_flowinfo = 0;
      //daddr6.sin6_flowinfo = 0;
      if (mode == DUAL_STACK) {
        inet_pton(AF_INET6, "::FFFF:1.2.3.4", &saddr6.sin6_addr);
        inet_pton(AF_INET6, "::FFFF:5.6.7.8", &daddr6.sin6_addr);
      } else {
        inet_pton(AF_INET6, "2001:4860:DEAD:CAFE::6006:0013",
&saddr6.sin6_addr);
        inet_pton(AF_INET6, "2001:4860:DEAD:BEEF::6006:0013",
&daddr6.sin6_addr);
      }
      //saddr6.sin6_scope_id = 0;
      //daddr6.sin6_scope_id = 0;

      rv = bind(fd, (struct sockaddr const *)&saddr6, sizeof(saddr6));
      if (rv < 0) perror("bind()");

      rv = sendto(fd, "Hello!", 6, 0, (struct sockaddr const
*)&daddr6, sizeof(daddr6));
      if (rv < 0) perror("write");
    }

    rv = close(fd);
    if (rv < 0) perror("close");
  }

  return 0;
}
