From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 13688] New: backlog parameter of listen is not
 working with TCP
Date: Wed, 1 Jul 2009 11:49:32 -0700
Message-ID: <20090701114932.a2f4a2e4.akpm@linux-foundation.org>
References: <bug-13688-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, florent.cloirec@free.fr
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:43356 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756163AbZGAStc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2009 14:49:32 -0400
In-Reply-To: <bug-13688-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 1 Jul 2009 18:39:07 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=13688
> 
>            Summary: backlog parameter of listen is not working with TCP
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: florent.cloirec@free.fr
>         Regression: No
> 
> 
> Created an attachment (id=22171)
>  --> (http://bugzilla.kernel.org/attachment.cgi?id=22171)
> little test server
> 
> When creating a server I usually create a socket, bind it to any address and
> call listen to limit the queue size, then I call accept in a loop to handle
> clients one by one.
> 
> In a particular case I wanted to serve only 1 client and refuse the other
> connection attempts. I tried any value for the backlog parameter, whatever I
> use the server is not refusing any connection, though the queue should be full.
> The SYN+ACK handshake is completed everytime.
> 
> To be sure this is a bug I checked this with BSD and Windows, I can confirm
> that it refuses connections if the max queue size specified with backlog is
> reached (Note that backlog is not exactly the queue size with these systems,
> there is a 3/2 factor, I don't know why).
> 
> Maybe this implementation for linux kernel is wanted even if it is not posix
> compliant, but I did not find anywhere why this is working like this. If this
> is not a bug, could someone explain me the usefullness of the backlog
> parameter?
> 
> I attached a little test program with which anyone should be able to test this
> by connecting multiple telnet to.
> 

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>
#include <fcntl.h>
#include <netinet/in.h>
#include <netinet/ip.h>


int main(void)
{
   int servsock = 0;
   int clientsock = 0;
   struct sockaddr_in servaddr;
   struct sockaddr_in clientaddr;
   socklen_t clientaddrlen;
   struct in_addr client_addr;

   servsock = socket(AF_INET, SOCK_STREAM, 0);

   //fcntl(servsock, F_SETFL, O_NONBLOCK);

   if(servsock != -1)
   {
      servaddr.sin_family = AF_INET;
      servaddr.sin_port = htons(6256);
      inet_aton("0.0.0.0", &client_addr);
      servaddr.sin_addr = client_addr;

      if(bind(servsock, &servaddr, sizeof(servaddr)) != -1)
      {
         if(listen(servsock, 0) != -1)
         {
            while(1)
            {
               printf("waiting for clients\n");
               clientsock = accept(servsock, &clientaddr, &clientaddrlen);
               if(clientsock != -1)
               {
                  printf("client accepted, now sleep 60 sec\n");
                  sleep(60);
                  printf("60 sec have elapsed, closing connection\n");
                  close(clientsock);
               }
               else
               {
                  printf("accept error: retrying in 1 sec...\n");
                  sleep(1);
               }
            }
         }
         else
         {
            printf("listen failed\n");
         }
      }
      else
      {
         printf("bind failed\n");
      }

   }
   else
   {
      printf("socket creation failed\n");
   }


   return 0;
}

