From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] "$ ss -a" incorrectly displays raw sockets as udp sockets
Date: Thu, 09 Jul 2015 17:14:13 +0200
Message-ID: <1436454853.24939.31.camel@edumazet-glaptop2.roam.corp.google.com>
References: <559E8178.9080808@beyondsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Vadim Kochan <vadim4j@gmail.com>
To: Miha Marolt <miham@beyondsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:34565 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751296AbbGIPOU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 11:14:20 -0400
Received: by wifm2 with SMTP id m2so21794295wif.1
        for <netdev@vger.kernel.org>; Thu, 09 Jul 2015 08:14:19 -0700 (PDT)
In-Reply-To: <559E8178.9080808@beyondsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-07-09 at 16:13 +0200, Miha Marolt wrote:
> Hi!
> 
> I hope this is the right place to reports bugs. I apologize if it isn't.
> 
> I have written a C program (see below for source code) that opens a raw 
> socket on CentOS 7.1 Linux and binds it to some address (it doesn't use 
> the port that I supplied, but that is not the point here). The "netstat" 
> program correctly recognizes the socket as "raw", while "ss" program 
> says it is "udp". Here are the relevant lines from the ss and netstat 
> commands:
> 
> $ netstat -an
> raw        0      0 127.0.0.1:6             0.0.0.0:* 7
> 
> $ ./ss -an
> udp    UNCONN     21569  0      127.0.0.1:6 *:*
> 
> Here is the version information
> 
> $ netstat --version  # From CentOS 7.1.
> net-tools 2.10-alpha
> 
> $ ./ss --version  # Built from git.
> ss utility, iproute2-ss150626
> 
> 
> C source follows. If you store it in "main.c", then compile it with "$ 
> gcc main.c -o main" and then run it by executing "$ sudo ./main".
> 
> #include <arpa/inet.h>
> #include <assert.h>
> #include <sys/socket.h>
> #include <stdio.h>
> #include <unistd.h>
> 
> 
> int main(void)
> {
>      // Create a raw socket.
>      int sock = socket(AF_INET, SOCK_RAW, IPPROTO_TCP);
>      if (sock == -1) { perror(NULL); goto exc_cleanup; }
> 
>      // Bind socket to an address.
>      struct sockaddr_in addr;
>      addr.sin_family = AF_INET;
>      inet_pton(AF_INET, "127.0.0.1", &addr.sin_addr);
>      addr.sin_port = htons(27183);
> 
>      int rc = bind(sock, (struct sockaddr*)&addr, sizeof(addr));
>      if (rc != 0) { perror(NULL); goto exc_cleanup; }
> 
>      // Wait until user presses <ENTER>.
>      printf("\nPress <ENTER> to quit the program.\n");
>      getchar();
> 
> exc_cleanup:
>      assert(!close(sock));
> }

It is indeed a raw socket on proto TCP.

Note sure if commit 8250bc9ff4e55a3ef397ed8c7612f1392d164295
was really good...


diff --git a/misc/ss.c b/misc/ss.c
index 03f92fa69270..dc61aaa79bca 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2416,7 +2416,7 @@ static int dgram_show_line(char *line, const
struct filter *f, int family)
        if (n < 9)
                opt[0] = 0;
 
-       inet_stats_print(&s, IPPROTO_UDP);
+       inet_stats_print(&s, atoi(line));
 
        if (show_details && opt[0])
                printf(" opt:\"%s\"", opt);

-> 
# ./ss -an | grep 127.0.0.1
tcp    UNCONN     213486 0      127.0.0.1:6                     *:*                  



If I checkout iproute2 tree to db08bdb816d337102c5486744008db9c9faa43bf
(before buggy commit) we indeed had this result :

# ./ss -an | grep 127.0.0.1
raw    UNCONN     213486 0      127.0.0.1:6                     *:*                  
