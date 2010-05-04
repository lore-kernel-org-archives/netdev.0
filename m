From: enh <enh@google.com>
Subject: linux kernel's IPV6_MULTICAST_HOPS default is 64; should be 1?
Date: Mon, 3 May 2010 18:33:46 -0700
Message-ID: <AANLkTikUArEWFhsxpJGCbOPtvQATBKztP0jhZTTsdx7-@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:4432 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751033Ab0EDBdu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 21:33:50 -0400
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [10.3.21.6])
	by smtp-out.google.com with ESMTP id o441Xm9a005933
	for <netdev@vger.kernel.org>; Mon, 3 May 2010 18:33:48 -0700
Received: from ywh1 (ywh1.prod.google.com [10.192.8.1])
	by hpaq6.eem.corp.google.com with ESMTP id o441XkBb007513
	for <netdev@vger.kernel.org>; Mon, 3 May 2010 18:33:47 -0700
Received: by ywh1 with SMTP id 1so2621465ywh.30
        for <netdev@vger.kernel.org>; Mon, 03 May 2010 18:33:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC 3493 (http://tools.ietf.org/rfc/rfc3493.txt) says:

      IPV6_MULTICAST_HOPS

         Set the hop limit to use for outgoing multicast packets.  (Note
         a separate option - IPV6_UNICAST_HOPS - is provided to set the
         hop limit to use for outgoing unicast packets.)

         The interpretation of the argument is the same as for the
         IPV6_UNICAST_HOPS option:

            x < -1:        return an error of EINVAL
            x == -1:       use kernel default
            0 <= x <= 255: use x
            x >= 256:      return an error of EINVAL

            If IPV6_MULTICAST_HOPS is not set, the default is 1
            (same as IPv4 today)

         Argument type: int

but if i create a socket and call getsockopt, i get 64, not 1. this
happens both on Android (2.6.32) and on Ubuntu 8.04 (2.6.24).

actually, i get whatever i've written to
/proc/sys/net/ipv6/conf/all/hop_limit. but afaics, nothing writes that
during init, so i think i'm getting the kernel's fallback default.

anyway, here's a test program you can use to see what i mean. i've
included the ipv4 equivalents, which give the values i'd expect.

/tmp$ cat sock.cpp
/* checkopts.c - based on Stevens */

#include <unistd.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>

struct sock_opts {
  const char	 *opt_str;
  int	 opt_level;
  int	 opt_name;
} sock_opts[] =
  {
    "IP_TTL",		IPPROTO_IP,	IP_TTL,
    "IP_MULTICAST_TTL",		IPPROTO_IP,	IP_MULTICAST_TTL,
    "IPV6_MULTICAST_HOPS",		IPPROTO_IPV6,	IPV6_MULTICAST_HOPS,
    "IPV6_UNICAST_HOPS",		IPPROTO_IPV6,	IPV6_UNICAST_HOPS,
    NULL,		0,		0,
  };

int main(int argc, char* argv[]) {
  int fd4 = socket(AF_INET, SOCK_DGRAM, 0);
  int fd6 = socket(AF_INET6, SOCK_DGRAM, 0);
  for (struct sock_opts* ptr = sock_opts; ptr->opt_str != NULL; ++ptr) {
    int val;
    socklen_t len = sizeof(int);
    int rc = getsockopt(ptr->opt_level == IPPROTO_IP ? fd4 : fd6,
ptr->opt_level, ptr->opt_name, &val, &len);
    printf("%s default = %d\n", ptr->opt_str, val);
  }
  return 0;
}

/tmp$ make sock && ./sock
make: `sock' is up to date.
IP_TTL default = 64
IP_MULTICAST_TTL default = 1
IPV6_MULTICAST_HOPS default = 64
IPV6_UNICAST_HOPS default = 64
/tmp$

is this a bug? is this the right place to report it? thanks!

-- 
Elliott Hughes - http://who/enh - http://jessies.org/~enh/
