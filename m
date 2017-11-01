From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH net] tun/tap: sanitize TUNSETSNDBUF input
Date: Wed, 1 Nov 2017 19:16:20 +0100
Message-ID: <CAHmME9rpq4-UPnnMQJ966V7jmtrkEvATtLQOtS60vM7b_s0Kwg@mail.gmail.com>
References: <20171030225011.184639-1-kraigatgoog@gmail.com> <20171101.205334.528454363401742419.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Craig Gallek <kraigatgoog@gmail.com>
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:40713 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754899AbdKASQX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Nov 2017 14:16:23 -0400
Received: by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTP id 326513c0
        for <netdev@vger.kernel.org>;
        Wed, 1 Nov 2017 18:13:52 +0000 (UTC)
Received: by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTPSA id 2bf5e4e0 (TLSv1.2:ECDHE-RSA-AES128-GCM-SHA256:128:NO)
        for <netdev@vger.kernel.org>;
        Wed, 1 Nov 2017 18:13:52 +0000 (UTC)
Received: by mail-oi0-f45.google.com with SMTP id m198so5828817oig.5
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 11:16:22 -0700 (PDT)
In-Reply-To: <20171101.205334.528454363401742419.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here's a simple reproducer, in case Skyzaller's case was overcomplicated:

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/ioctl.h>
#include <linux/if.h>
#include <linux/if_tun.h>

int main(int argc, char *argv[])
{
  struct ifreq ifr;
  int fd, sock;

  fd = open("/dev/net/tun", O_RDWR);
  if (fd < 0) {
    perror("open(/dev/net/tun)");
    return 1;
  }

  memset(&ifr, 0, sizeof(ifr));

  ifr.ifr_flags = IFF_TUN;
  strncpy(ifr.ifr_name, "yikes", IFNAMSIZ);

  if (ioctl(fd, TUNSETIFF, &ifr) < 0) {
    perror("TUNSETIFF");
    return 1;
  }

  sock = socket(AF_INET, SOCK_DGRAM, 0);
  if (sock < 0) {
    perror("socket");
    return 1;
  }
  ifr.ifr_flags = IFF_UP;
  if (ioctl(sock, SIOCSIFFLAGS, &ifr) < 0) {
    perror("SIOCSIFFLAGS");
    return 1;
  }
  close(sock);

  sock = -1;
  if (ioctl(fd, TUNSETSNDBUF, &sock)) {
    perror("TUNSETSNDBUF");
    return 1;
  }

  if (write(fd, &fd, sizeof(fd)) < 0) {
    perror("write");
    return 1;
  }

  return 0;
}
