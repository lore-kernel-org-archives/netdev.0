From: john@screen.lv
Subject: strange tcp behavior
Date: Thu, 2 Aug 2007 09:19:06 +0300 (EEST)
Message-ID: <56697.212.93.96.73.1186035546.squirrel@mail.screen.lv>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.getwildcash.com ([213.180.119.146]:56146 "EHLO
	mail.potentialcash.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751847AbXHBGZp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2007 02:25:45 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

1186035057.207629    127.0.0.1 -> 127.0.0.1    TCP 50000 > smtp [SYN]
Seq=0 Len=0
1186035057.207632    127.0.0.1 -> 127.0.0.1    TCP smtp > 50000 [SYN, ACK]
Seq=0 Ack=1 Win=32792 Len=0 MSS=16396
1186035057.207666    127.0.0.1 -> 127.0.0.1    TCP 50000 > smtp [ACK]
Seq=1 Ack=1 Win=1500 Len=0
1186035057.207699    127.0.0.1 -> 127.0.0.1    SMTP Command: EHLO localhost
1186035057.207718    127.0.0.1 -> 127.0.0.1    TCP smtp > 50000 [ACK]
Seq=1 Ack=17 Win=32792 Len=0
1186035057.207736    127.0.0.1 -> 127.0.0.1    TCP 50000 > smtp [RST]
Seq=17 Len=0
1186035057.223934    127.0.0.1 -> 127.0.0.1    TCP 33787 > 50000 [RST,
ACK] Seq=0 Ack=0 Win=32792 Len=0



Can someone please comment as to why, tcp  stack sends rst packet from the
wrong source port in this situation.

This is the same problem that was described in my first two posts, witch 
unfortunately nobody seemed to notice.

Here is source code witch can reproduce the behavior described, the client
side code is a complete mess but with a little bit it works.

Server:

#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <poll.h>
#include <fcntl.h>

void main(void) {
        int ms;
        int ss;
        struct sockaddr_in sa;
        char *str = "HELLO FRIEND";
        struct pollfd fd;
        int flags;

        ms = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
        flags = fcntl(ms, F_GETFL, 0);
        fcntl(ms, F_SETFL, flags | O_NONBLOCK);

        memset(&sa, 0, sizeof(sa));
        sa.sin_family = AF_INET;
        sa.sin_addr.s_addr = htonl(INADDR_ANY);
        sa.sin_port = htons(25);

        bind(ms, (struct sockaddr *) &sa, sizeof(sa));

        listen(ms, 0);

        fd.fd = ms;
        fd.events = POLLIN;

        while(poll(&fd, 1, -1)) {
                ss = accept(ms, NULL, NULL);

                usleep(10000);
                send(ss, str, strlen(str), MSG_NOSIGNAL);
                close(ss);

                memset(&fd, 0, sizeof(fd));
                fd.fd = ms;
                fd.events = POLLIN;
        }
}

Client:


#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <linux/if_ether.h>
//#include <arpa/inet.h>

//#include <linux/if_ether.h>

struct sockaddr_in localaddr;
struct sockaddr_in remoteaddr;

struct sockaddr rawaddr;

int sdl, sdr;

struct tcphdr header;

struct pheader_t {
        uint32_t saddr;
        uint32_t daddr;
        uint8_t r;
        uint8_t protocol;
        uint16_t length;
};

struct pheader_t pheader;

unsigned short tbuf[2048];
unsigned char buf[2048];

char *msg = "EHLO localhost\r\n";

unsigned char *p;

char *src_addr = "127.0.0.1";
char *dst_addr = "127.0.0.1";

unsigned short sprt = 50000;
unsigned short dprt = 25;


struct timeval tv;

unsigned seq, ack_seq;

int data;

void mysend(void) {
        int i, sum;
        int len;

        if(data) {
                len = strlen(msg);
                memcpy((char *) tbuf + sizeof(pheader) + sizeof(header),
msg, len);
        } else
                len = 0;

        bzero(&pheader, sizeof(pheader));
        pheader.saddr = (in_addr_t) inet_addr(src_addr);
        pheader.daddr = (in_addr_t) inet_addr(dst_addr);
        pheader.protocol = 6;
        pheader.length = htons(sizeof(header) + len);

        memcpy(tbuf, &pheader, sizeof(pheader));
        memcpy((char *) tbuf + sizeof(pheader), &header, sizeof(header));



        sum = 0;

        for(i = 0; i < (sizeof(pheader) + sizeof(header)) / 2 + len / 2;
i++) {
                sum += tbuf[i];
                sum = (sum & 0x0000ffff) + (sum >> 16);
        }

        header.check = ~sum;

        memcpy((char *) tbuf + sizeof(pheader), &header, sizeof(header));

        sendto(sdr,  (char *) tbuf + sizeof(pheader), sizeof(header) +
len, 0, (struct sockaddr *) &remoteaddr, sizeof(remoteaddr));
}


void main(void)
{
        gettimeofday(&tv, NULL);
        srand(tv.tv_sec & tv.tv_usec);

        remoteaddr.sin_family = AF_INET;
        remoteaddr.sin_addr.s_addr = (in_addr_t) inet_addr(dst_addr);


        sdl = socket(PF_INET, SOCK_PACKET, htons(ETH_P_ALL));
        strcpy(rawaddr.sa_data, "lo");
        bind(sdl, (struct sockaddr *) &rawaddr, sizeof(rawaddr));

        sdr = socket(AF_INET, SOCK_RAW, IPPROTO_TCP);


        bzero(&header, sizeof(header));
        header.source = htons(sprt);
        header.dest = htons(dprt);

        seq = rand();
        ack_seq = 0;

        header.seq = htonl(seq);
        header.ack_seq = htonl(ack_seq);

        header.doff = sizeof(header) / 4;

        header.syn = 1;

        header.window = htons(1500);

        mysend();

        while(1) {
                recvfrom(sdl, buf, sizeof(buf), 0, NULL, NULL);
//              p = buf + (*buf & 0x0f) * 4;
                p = (buf + 14) + (*(buf + 14) & 0x0f) * 4;
                if(ntohs(((struct tcphdr *)p)->source) == dprt &&
ntohs(((struct tcphdr *)p)->dest) == sprt && ((struct
tcphdr *)p)->syn == 1 && ((struct tcphdr *)p)->ack == 1)
                        break;
        }


        bzero(&header, sizeof(header));
        header.source = htons(sprt);
        header.dest = htons(dprt);

        seq = ntohl(((struct tcphdr *)p)->ack_seq);
        ack_seq = ntohl(((struct tcphdr *)p)->seq) + 1;

        header.seq = htonl(seq);
        header.ack_seq = htonl(ack_seq);

        header.doff = sizeof(header) / 4;

        header.ack = 1;

        header.window = htons(1500);

        mysend();


        bzero(&header, sizeof(header));
        header.source = htons(sprt);
        header.dest = htons(dprt);

        header.seq = htonl(seq);
        header.ack_seq = htonl(ack_seq);

        header.doff = sizeof(header) / 4;

        header.ack = 1;
        header.psh = 1;

        header.window = htons(1500);

        data = 1;
        mysend();
        data = 0;

//      usleep(300);


        bzero(&header, sizeof(header));
        header.source = htons(sprt);
        header.dest = htons(dprt);

        seq += strlen(msg);

        header.seq = htonl(seq);
        header.ack_seq = htonl(ack_seq);

        header.doff = sizeof(header) / 4;

        header.rst = 1;

        header.window = htons(1500);

        mysend();
}




I traced this behavior way back to 2.4.0-test9-pre3 kernel.
