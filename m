From: Thomas Graf <tgraf@infradead.org>
Subject: [RFC] random SYN drops causing connect() delays
Date: Mon, 12 Apr 2010 04:06:33 -0400
Message-ID: <20100412080633.GA27418@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:51982 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752641Ab0DLIGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Apr 2010 04:06:34 -0400
Received: from tgr by bombadil.infradead.org with local (Exim 4.69 #1 (Red Hat Linux))
	id 1O1EfB-0007SR-Tv
	for netdev@vger.kernel.org; Mon, 12 Apr 2010 08:06:33 +0000
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I have been tracking down an issue commonly referred to as the 3-sec
connect() delay. It exists since recent 2.6.x kernels and has never
been fixed even though it disappeared in recent releases unless
sched_child_runs_first is set to 1 again.

What happens is that if a client attemps to open many connections to
a socket with only minimal delay inbetween attemps some SYNs are
randomly dropped on the server side causing the client to resend after
the 3 sec TCP timeout and thus causing connect()s to be randomly delayed.

Steps to reproduce:
 1. Compile reproducer attached below
 2. run ./test_delay 127.0.0.1 22 10000 0 > log
 3. awk -F: '{if ($2>2990) print $1 $2;}' log
 4. all listed connection attemps will have been delayed for >3s

Facts:
 - Issue can be reproduced over loopback or real networks.
 - Enabling SO_LINGER on the client side will make the issue disappear!!
 - While the issue is appearing, the acceptq seems to be overflowing. Both
   LISTENOVERFLOWS and LISTENDROPS are increasing although not by the exact
   number of delay occurences. inetdiag reports sk_max_ack_backlog to be 0
   therefore one possibility that comes to mind is that sk_ack_backlog
   underflows due to a race.
 - The issue disappeared in recent kernels, I bisected it down to the following
   commit:
	commit 2bba22c50b06abe9fd0d23933b1e64d35b419262
	Author: Mike Galbraith <efault@gmx.de>
	Date:   Wed Sep 9 15:41:37 2009 +0200

	    sched: Turn off child_runs_first
	    
	    Set child_runs_first default to off.

   Setting kernel.sched_child_runs_first=1 makes the isssue reappear in recent
   kernels.  This hardens the theory of a race condition.
 - It looks like that the issue can only be reproduced if the server
   socket sends out data immediately after the connection has been established
   but I cannot proof this theory.

I will continue to look into the sk_ack_backlog underflow theory but would
appreciate any comments or theories.

Thanks,

Reproducer:

#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <netdb.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <time.h>
#include <sys/time.h>

int main(int argc, char *argv[])
{

        int sock,i;  
        struct timeval tim;
        double start,end;  

        struct hostent *host;
        struct sockaddr_in server_addr, local;
	socklen_t len = sizeof(local);

        char* hostname;
        int port, count, delay;

        if( argc < 3 ){
           printf("Usage:\n\t%s host port [count=1000] [delay=0]\n",argv[0]);
           return 1;
        }

        hostname = argv[1];
        port = atoi(argv[2]);

        if( argc > 3 )
           count = atoi(argv[3]);
	else
           count = 1000;

        if( argc > 4 )
           delay = atoi(argv[4]);
	else
           delay = 0;

        host = gethostbyname(hostname);

        server_addr.sin_family = AF_INET;     
        server_addr.sin_port = htons(port);   
        server_addr.sin_addr = *((struct in_addr *)host->h_addr);
        bzero(&(server_addr.sin_zero),8); 

        for(i=0; i< count; i=i+1){
          gettimeofday(&tim, NULL);
          start=tim.tv_sec*1000+(tim.tv_usec/1000);

          if ((sock = socket(AF_INET, SOCK_STREAM, 0)) == -1) {
            perror("Socket");
            exit(1);
          }

          if (connect(sock, (struct sockaddr *)&server_addr,
                    sizeof(struct sockaddr)) == -1) 
          {
            perror("Connect");
            exit(1);
          }

	  getsockname(sock, (struct sockaddr *) &local, &len);
          close(sock);

          gettimeofday(&tim, NULL);
          end=tim.tv_sec*1000+(tim.tv_usec/1000);
          printf("[%d] %u-> Time to open socket (clock): %d\n",
	  	i, ntohs(local.sin_port), (int)(end - start));
	  usleep(delay*1000);
        }
/*
        printf("Time to open socket (ms): %d\n", ((end - start)*1000)/CLOCKS_PER_SEC);
*/

        return 0;
}


