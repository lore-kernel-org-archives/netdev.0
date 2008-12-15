From: Ben Mansell <ben@zeus.com>
Subject: Mysterious network delays when using splice()
Date: Mon, 15 Dec 2008 14:30:38 +0000
Message-ID: <49466A0E.7040406@zeus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailin.zeus.com ([212.44.21.7]:9558 "EHLO mailin.zeus.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753217AbYLOOpx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Dec 2008 09:45:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Originally posted to linux-net, but apparently this is the more
appropriate list. Sorry if it is the wrong place!)

I've been investigating using splice() to proxy data from one  TCP
socket to another. I know that splice() can't directly handle data
between two sockets, so I'm using pipes in-between:

clientsock -> pipe1 -> serversock
serversock -> pipe2 -> clientsock

All data transfer is done using splice() between the sockets and pipes.

However, while this does work, I get mysterious delays between some of
the splices, which just aren't present if I use read() and write() in
their place. I've put together a simple program that demonstrates the issue.

Here's an editted 'strace -tt' of my splice program when proxying a HTTP
request on to a local web server:

10:08:47.626093 accept(3, {sa_family=0x15c8 /* AF_??? */,
sa_data="\350\362n\177\0\0\200\20@\0\0\0\0\0"}, [16]) = 4
10:08:48.812077 socket(PF_INET, SOCK_STREAM, IPPROTO_TCP) = 5
10:08:48.812242 connect(5, {sa_family=AF_INET, sin_port=htons(6789),
sin_addr=inet_addr("10.100.1.215")}, 16) = 0
10:08:48.812710 pipe([6, 7])            = 0
10:08:48.812821 pipe([8, 9])            = 0
10:08:48.812923 setsockopt(4, SOL_TCP, TCP_NODELAY, [1], 4) = 0
10:08:48.813029 setsockopt(5, SOL_TCP, TCP_NODELAY, [1], 4) = 0
10:08:48.813173 fstat(1, {st_mode=S_IFCHR|0620, st_rdev=makedev(136, 6),
...}) = 0
10:08:48.813325 mmap(NULL, 4096, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f6ef33fe000
10:08:48.813615 poll([{fd=4, events=POLLIN, revents=POLLIN}, {fd=5,
events=POLLIN}, {fd=6, events=POLLIN}, {fd=8, events=POLLIN}], 4, 300) = 1
10:08:48.813891 splice(0x4, 0, 0x7, 0, 0x1000, 0x1) = 46
(splice request from socket -> pipe)
10:08:48.814123 poll([{fd=4, events=POLLIN}, {fd=5, events=POLLIN},
{fd=6, events=POLLIN, revents=POLLIN}, {fd=8, events=POLLIN}], 4, 300) = 1
10:08:48.814364 splice(0x6, 0, 0x5, 0, 0x1000, 0x1) = 46
(splice from pipe -> server socket)
10:08:48.814599 poll([{fd=4, events=POLLIN}, {fd=5, events=POLLIN,
revents=POLLIN}, {fd=6, events=POLLIN}, {fd=8, events=POLLIN}], 4, 300) = 1
(Note the ~200ms delay here between these syscalls)
10:08:49.023988 splice(0x5, 0, 0x9, 0, 0x1000, 0x1) = 1290
(reply from server)
10:08:49.024218 poll([{fd=4, events=POLLIN}, {fd=5, events=POLLIN},
{fd=6, events=POLLIN}, {fd=8, events=POLLIN, revents=POLLIN}], 4, 300) = 1
10:08:49.024455 splice(0x8, 0, 0x4, 0, 0x1000, 0x1) = 1290
10:08:49.024683 poll([{fd=4, events=POLLIN}, {fd=5, events=POLLIN,
revents=POLLIN}, {fd=6, events=POLLIN}, {fd=8, events=POLLIN}], 4, 300) = 1
10:08:49.025227 splice(0x5, 0, 0x9, 0, 0x1000, 0x1) = 0
10:08:49.025481 exit_group(0)           = ?

tcpdump of the proxied data transfer (proxy<->server):

10:08:48.812339 IP 10.100.1.215.35439 > 10.100.1.215.6789: S
1699343421:1699343421(0) win 32792 <mss 16396,sackOK,timestamp 38995817
0,nop,wscale 7>
10:08:48.812416 IP 10.100.1.215.6789 > 10.100.1.215.35439: S
1699931900:1699931900(0) ack 1699343422 win 32768 <mss
16396,sackOK,timestamp 38995817 38995817,nop,wscale 7>
10:08:48.812457 IP 10.100.1.215.35439 > 10.100.1.215.6789: . ack 1 win
257 <nop,nop,timestamp 38995817 38995817>
10:08:49.017169 IP 10.100.1.215.35439 > 10.100.1.215.6789: P 1:47(46)
ack 1 win 257 <nop,nop,timestamp 38995869 38995817>

The last line is the first part of the HTTP request being sent to the
server. What is odd is that, according to the strace, this data was
splice()d into the socket at 10:08:48.814364. So why is there a delay in
writing it out onto the network?

My test program, if given an extra argument, can replace the splice()
calls with read() and write(). When I do this, the proxied HTTP request
is always sent out immediately.

Am I using splice() wrongly here, or missing out any options to force
the splice() data onto the wire? Or is this perhaps a bug? I'm running
my tests on Ubuntu 8.10 (kernel 2.6.27-9-generic)

My test code follows. In my example, I was running:
./splice 5678 10.100.1.215 6789
(listen on port 5678, proxy data to 10.100.1.215, port 6789).
To emulate splice() with read() and write(), run as:
./splice 5678 10.100.1.215 6789 1


Ben


/**
  * Really simple splice demo.
  * Proxies a connection to a remote server.
  *
  * Usage: splice listen_port dst_ip dst_port [emulate splice]
  */

#define _GNU_SOURCE

#include <stdio.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <netdb.h>
#include <stdlib.h>
#include <poll.h>
#include <fcntl.h>

#define CHUNK_SIZE 4096


int use_splice = 1;



/* splice data from one FD to another. One of the FDs is a pipe */
void send_data( int from, int to )
{
    char buffer[ CHUNK_SIZE ];
    int r;
    printf( "%s data from %d to %d\n",
            use_splice ? "Splicing" : "r/w", from, to );

    if( use_splice ) {
       r = splice( from, NULL, to, NULL, CHUNK_SIZE, SPLICE_F_MOVE );
    } else {
       /* Fake the splice() using read() and write() */
       r = read( from, buffer, CHUNK_SIZE );
    }

    if( r > 0 ) {
       printf( "%s returned %d\n", use_splice ? "splice()" : "read()", r );
       if( !use_splice ) {
          /* We should really check that all the data gets written... */
          int w = write( to, buffer, r );
          if( w < 0 ) {
             perror( "write" );
             exit( 1 );
          }
       }
    } else if( r == 0 ) {
       /* good enough for us, even though splice()=0 may mean other stuff */
       printf( "connection closed\n" );
       exit( 0 );
    } else {
       if( use_splice ) perror( "splice" ); else perror( "read" );
       exit( 1 );
    }
}


int main( int argc, char *argv[] )
{
    int listenfd, clientfd, serverfd, client_size;
    int listen_port, dst_port;
    struct sockaddr_in listen_addr, client_addr, server_addr;
    struct iovec vector[ 2 ];
    int c2s[2], s2c[2];
    const int one = 1;
    struct hostent *serverip;

    if( argc < 4 ) {
       printf( "Usage: %s listen_port dst_ip dst_port [emulate]\n",
argv[0] );
       exit( 1 );
    }
    if( argc > 4 ) use_splice = 0;

    listen_port = atoi( argv[1] );
    dst_port = atoi( argv[3] );

    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons( dst_port );
    if( !inet_aton( argv[2], &server_addr.sin_addr )) {
       printf( "Invalid IP '%s'\n", argv[2] );
       exit( 1 );
    }

    listenfd = socket( PF_INET, SOCK_STREAM, 0 );
    listen_addr.sin_family = AF_INET;
    listen_addr.sin_addr.s_addr = htonl( INADDR_ANY );
    listen_addr.sin_port = htons( listen_port );

    setsockopt( listenfd, SOL_SOCKET, SO_REUSEADDR, (char *)&one,
sizeof(int));

    if( bind( listenfd, ( struct sockaddr * ) &listen_addr,
              sizeof( listen_addr )) ) {
       perror( "bind" );
       exit( 1 );
    }

    listen( listenfd, 10 );
    clientfd = accept( listenfd, ( struct sockaddr * ) &client_addr,
                       &client_size );

    serverfd = socket( AF_INET, SOCK_STREAM, IPPROTO_TCP );
    if( serverfd < 0 ) {
       perror( "socket" );
       exit( 1 );
    }
    if( connect( serverfd, (struct sockaddr *)&server_addr,
                 sizeof( server_addr ))) {
       perror( "connect" );
       exit( 1 );
    }

    /* Two pipes, one for client->server and the other for server->client */
    if( pipe( c2s ) || pipe( s2c )) {
       perror( "pipe" );
       exit( 1 );
    }

    /* Turn off Nagle to stop it delaying any data */
    setsockopt( clientfd, IPPROTO_TCP, TCP_NODELAY, &one, sizeof( int ));
    setsockopt( serverfd, IPPROTO_TCP, TCP_NODELAY, &one, sizeof( int ));

    printf( "Client on %d, server on %d, c2s on %d->%d, s2c on %d->%d\n",
            clientfd, serverfd, c2s[0], c2s[1], s2c[0], s2c[1] );

    /* Just read from either socket and write to the other one.
     * All the code is blocking I/O just to keep things simple. */
    for(;;) {
       struct pollfd events[4] = {{ clientfd, POLLIN },
                                  { serverfd, POLLIN },
                                  { c2s[0], POLLIN },
                                  { s2c[0], POLLIN }};
       int p = poll( events, 4, 300 );
       if( events[0].revents ) send_data( clientfd, c2s[1] );
       if( events[1].revents ) send_data( serverfd, s2c[1] );
       if( events[2].revents ) send_data( c2s[0], serverfd );
       if( events[3].revents ) send_data( s2c[0], clientfd );
    }
}

