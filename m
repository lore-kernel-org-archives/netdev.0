From: "Kevin Spiteri" <kspiteri@ieee.org>
Subject: TCP checksum error on local device
Date: Wed, 9 Jul 2008 16:34:32 +0200
Message-ID: <9a6873fa0807090734ge7ef12lf09e78db44ba77f5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.225]:2902 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752295AbYGIOec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 10:34:32 -0400
Received: by rv-out-0506.google.com with SMTP id k40so3580822rvb.1
        for <netdev@vger.kernel.org>; Wed, 09 Jul 2008 07:34:32 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When I send TCP data from localhost to localhost (either on 127.0.0.1
or on the public IP of the machine), the TCP checksum is wrong.

I am using the kernel that came with Xubuntu 8.04, /proc/version:
Linux version 2.6.24-19-generic (buildd@palmer) (gcc version 4.2.3
(Ubuntu 4.2.3-2ubuntu7)) #1 SMP Wed Jun 18 14:43:41 UTC 2008

When I run the sample program below and capture traffic on the lo
device using Wireshark, the TCP segment that contains data has an
incorrect checksum. All other segments have a correct checksum.

#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>

int main(int argc, char **argv)
{
    int fd_srv, fd_s0, fd_s1;
    struct sockaddr_in address;
    socklen_t len = sizeof(address);
    char buffer[1] = {0};

    fd_srv = socket(AF_INET, SOCK_STREAM, 6);
    memset(&address, 0, len);
    address.sin_family = AF_INET;
    address.sin_addr.s_addr = htonl(0x7f000001);
    address.sin_port = htons(12345);
    bind(fd_srv, (struct sockaddr *)(&address), len);
    listen(fd_srv, 0);

    fd_s0 = socket(AF_INET, SOCK_STREAM, 6);
    connect(fd_s0, (struct sockaddr *)(&address), len);

    fd_s1 = accept(fd_srv, (struct sockaddr *)(&address), &len);
    close(fd_srv);

    write(fd_s0, buffer, 1);
    read(fd_s1, buffer, 1);
    close(fd_s0);
    close(fd_s1);

    return 0;
}
