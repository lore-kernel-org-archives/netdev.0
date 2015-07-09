From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [BUG] "$ ss -a" incorrectly displays raw sockets as udp sockets
Date: Thu, 09 Jul 2015 16:50:06 +0200
Message-ID: <559E8A1E.1060002@cumulusnetworks.com>
References: <559E8178.9080808@beyondsemi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080600080103080600080808"
To: Miha Marolt <miham@beyondsemi.com>, netdev@vger.kernel.org,
	vadim4j@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:38102 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751125AbbGIOuz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 10:50:55 -0400
Received: by wicmv11 with SMTP id mv11so3323190wic.1
        for <netdev@vger.kernel.org>; Thu, 09 Jul 2015 07:50:54 -0700 (PDT)
In-Reply-To: <559E8178.9080808@beyondsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080600080103080600080808
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit

On 07/09/2015 04:13 PM, Miha Marolt wrote:
> Hi!
> 
> I hope this is the right place to reports bugs. I apologize if it isn't.
> 
> I have written a C program (see below for source code) that opens a raw socket on CentOS 7.1 Linux and binds it to some address (it doesn't use the port that I supplied, but that is not the point here). The "netstat" program correctly recognizes the socket as "raw", while "ss" program says it is "udp". Here are the relevant lines from the ss and netstat commands:
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
> C source follows. If you store it in "main.c", then compile it with "$ gcc main.c -o main" and then run it by executing "$ sudo ./main".
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
>     // Create a raw socket.
>     int sock = socket(AF_INET, SOCK_RAW, IPPROTO_TCP);
>     if (sock == -1) { perror(NULL); goto exc_cleanup; }
> 
>     // Bind socket to an address.
>     struct sockaddr_in addr;
>     addr.sin_family = AF_INET;
>     inet_pton(AF_INET, "127.0.0.1", &addr.sin_addr);
>     addr.sin_port = htons(27183);
> 
>     int rc = bind(sock, (struct sockaddr*)&addr, sizeof(addr));
>     if (rc != 0) { perror(NULL); goto exc_cleanup; }
> 
>     // Wait until user presses <ENTER>.
>     printf("\nPress <ENTER> to quit the program.\n");
>     getchar();
> 
> exc_cleanup:
>     assert(!close(sock));
> }
> 
> 
> Best regards,
> Miha


Hi,
I think this was changed by commit:
8250bc9ff4e5 ("ss: Unify inet sockets output")
Because dgram_show_line() is used for both UDP and RAW sockets
IPPROTO_UDP is used for both now and proto_name() returns "udp".
CCed the patch author and attached a possible solution.

Cheers,
 Nik

--------------080600080103080600080808
Content-Type: text/x-patch;
 name="ss-raw.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="ss-raw.patch"

diff --git a/misc/ss.c b/misc/ss.c
index 870cad185341..4de77e92c319 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1554,6 +1554,8 @@ out:
 static char *proto_name(int protocol)
 {
 	switch (protocol) {
+	case IPPROTO_RAW:
+		return "raw";
 	case IPPROTO_UDP:
 		return "udp";
 	case IPPROTO_TCP:
@@ -2398,7 +2400,7 @@ static int dgram_show_line(char *line, const struct filter *f, int family)
 	if (n < 9)
 		opt[0] = 0;
 
-	inet_stats_print(&s, IPPROTO_UDP);
+	inet_stats_print(&s, dg_proto == UDP_PROTO ? IPPROTO_UDP : IPPROTO_RAW);
 
 	if (show_details && opt[0])
 		printf(" opt:\"%s\"", opt);

--------------080600080103080600080808--
