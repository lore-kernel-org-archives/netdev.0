From: Miha Marolt <miham@beyondsemi.com>
Subject: [BUG] "$ ss -a" incorrectly displays raw sockets as udp sockets
Date: Thu, 09 Jul 2015 16:13:12 +0200
Message-ID: <559E8178.9080808@beyondsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bsemi.com ([84.255.202.183]:42357 "EHLO mail.beyondsemi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751125AbbGIOXN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jul 2015 10:23:13 -0400
Received: from [10.237.2.123] (ariel.bdevices.com [10.237.2.123])
	by mail.beyondsemi.com (Postfix) with ESMTPS id 62B4520819E
	for <netdev@vger.kernel.org>; Thu,  9 Jul 2015 16:13:12 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

I hope this is the right place to reports bugs. I apologize if it isn't.

I have written a C program (see below for source code) that opens a raw 
socket on CentOS 7.1 Linux and binds it to some address (it doesn't use 
the port that I supplied, but that is not the point here). The "netstat" 
program correctly recognizes the socket as "raw", while "ss" program 
says it is "udp". Here are the relevant lines from the ss and netstat 
commands:

$ netstat -an
raw        0      0 127.0.0.1:6             0.0.0.0:* 7

$ ./ss -an
udp    UNCONN     21569  0      127.0.0.1:6 *:*

Here is the version information

$ netstat --version  # From CentOS 7.1.
net-tools 2.10-alpha

$ ./ss --version  # Built from git.
ss utility, iproute2-ss150626


C source follows. If you store it in "main.c", then compile it with "$ 
gcc main.c -o main" and then run it by executing "$ sudo ./main".

#include <arpa/inet.h>
#include <assert.h>
#include <sys/socket.h>
#include <stdio.h>
#include <unistd.h>


int main(void)
{
     // Create a raw socket.
     int sock = socket(AF_INET, SOCK_RAW, IPPROTO_TCP);
     if (sock == -1) { perror(NULL); goto exc_cleanup; }

     // Bind socket to an address.
     struct sockaddr_in addr;
     addr.sin_family = AF_INET;
     inet_pton(AF_INET, "127.0.0.1", &addr.sin_addr);
     addr.sin_port = htons(27183);

     int rc = bind(sock, (struct sockaddr*)&addr, sizeof(addr));
     if (rc != 0) { perror(NULL); goto exc_cleanup; }

     // Wait until user presses <ENTER>.
     printf("\nPress <ENTER> to quit the program.\n");
     getchar();

exc_cleanup:
     assert(!close(sock));
}


Best regards,
Miha
