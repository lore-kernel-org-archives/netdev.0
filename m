From: Jonathan Woithe <jwoithe@atrad.com.au>
Subject: Re: r8169 regression: UDP packets dropped intermittantly
Date: Fri, 24 Mar 2017 15:35:54 +1030
Message-ID: <20170324050553.GI30415@marvin.atrad.com.au>
References: <20151201235852.GA16429@electric-eye.fr.zoreil.com>
 <20160208023318.GJ9174@marvin.atrad.com.au>
 <20160407024417.GE17921@marvin.atrad.com.au>
 <20160517065231.GO30050@marvin.atrad.com.au>
 <20160518065137.GJ27564@marvin.atrad.com.au>
 <20160601003123.GE3384@marvin.atrad.com.au>
 <20160621032133.GC19735@marvin.atrad.com.au>
 <20160621230957.GA19674@electric-eye.fr.zoreil.com>
 <20160621235938.GB13364@marvin.atrad.com.au>
 <20160622232250.GA26424@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server.atrad.com.au ([150.101.241.2]:52934 "EHLO
        server.atrad.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751552AbdCXFdd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 01:33:33 -0400
Content-Disposition: inline
In-Reply-To: <20160622232250.GA26424@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 23, 2016 at 01:22:50AM +0200, Francois Romieu wrote:
> Jonathan Woithe <jwoithe@atrad.com.au> :
> [...]
> > to mainline (in which case I'll keep watching out for it)?  Or is the
> > out-of-tree workaround mentioned above considered to be the long term
> > fix for those who encounter the problem?
> 
> It's a workaround. Nothing less, nothing more.

Recently I have had a chance to revisit this issue.  I have written a
program (r8196-test, source is included below) which recreates the problem
without requiring our external hardware devices.  That is, this program
triggers the fault when run between two networked computers.  To use, two
PCs are needed.  One (the "master") has an rtl8169 network card fitted (ours
has a Netgear GA311, but the problem has been seen with others too from
memory).  The network hardware of the other computer (the "slave") isn't
important.  First run

  ./r8196-test

on the slave, followed by 

  ./r8196-test <IPv4 address of slave>

on the master.  When running stock kernel version 4.3 the master stops
reliably within a minute or so with a timeout, indicating (in this case)
that the response packet never arrived within the 0.5 second timeout period. 
The ID whose response was never received by the master is reported as having
been seen (and a response sent) by the slave.

If I substitute the forward ported r8169 driver mentioned earlier in this
thread into kernel 4.3, the above program sequence runs seemingly
indefinitely without any timeouts (runtime is beyond two hours as of this
writing, compared to tens of seconds with the standard driver).

This demonstrates that the problem is independent of our custom network
devices and allows the fault to be recreated using commodity hardware.

Does this make it any easier to develop a mainline fix for the regression?

Regards
  jonathan

/*
 * To test, the "master" mode is run on a PC with an RTL-8169 card.
 * The "slave" mode is run on any other PC.  "Master" mode is activated
 * by providing the IP of the slave PC on the command line.  The slave
 * should be started before the master; without a running slave the master
 * will time out.
 *
 * This code is in the public domain.
 */
#include <sys/types.h>
#include <sys/socket.h>
#include <stdio.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>
#include <unistd.h>

#include <errno.h>

unsigned char ping_payload[] = {
    0x00, 0x00,
    0x00, 0x00, 0x00, 0x00,
};

#define PING_PAYLOAD_SIZE 6

unsigned char ack_payload[] = {
    0x12, 0x34,
    0x01, 0x01, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00,
};

#define ACK_PAYLOAD_SIZE 14

#define UDP_PORT 49491

signed int open_udp(const char *target_addr)
{
    struct sockaddr_in local_addr;
    struct timeval tv;
    int sock;

    sock = socket(PF_INET,SOCK_DGRAM, 0);
    if (sock < 0) {
        return -1;
    }

    tv.tv_sec = 0;
    tv.tv_usec = 500000;
    setsockopt(sock, SOL_SOCKET, SO_SNDTIMEO, (char *)&tv, sizeof(tv));
    setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, (char *)&tv, sizeof(tv));

    memset(&local_addr, 0, sizeof(local_addr));
    local_addr.sin_family = AF_INET;
    local_addr.sin_addr.s_addr = INADDR_ANY;
    local_addr.sin_port = htons(49491);
    if (bind(sock, (struct sockaddr *)&local_addr,
             sizeof(struct sockaddr)) < 0) {
        return -1;
    }

    if (target_addr != NULL) {
        struct sockaddr_in dest_addr;
        memset(&dest_addr, 0, sizeof(dest_addr));
        dest_addr.sin_family = AF_INET;
        dest_addr.sin_port = htons(49491);
        if (inet_aton(target_addr, &dest_addr.sin_addr) < 0) {
            return -1;
        }
        if (connect(sock, (struct sockaddr *)&dest_addr,
                    sizeof(dest_addr)) < 0) {
            return -1;
        }
    }
    return sock;
}

void master(const char *target_addr)
{
    signed int id = 0;
    int sock = open_udp(target_addr);

    printf("master()\n");
    if (sock < 0) {
        return;
    }

    for (;; id++) {
        unsigned char buf[1024];
        signed int n;
        ping_payload[0] = id & 0xff;
        if (send(sock, ping_payload, PING_PAYLOAD_SIZE, 0) < 0) {
            break;
        }
        n = recv(sock, buf, sizeof(buf), 0);
        if (n == -1) {
            if (errno == EAGAIN) {
                printf("id 0x%02x: no response received (timeout)\n", 
                       ping_payload[0]);
                break;
            }
        } else {
            printf("id 0x%02x: recv %d\n", buf[0], n);
        }
        usleep(10000);
    }
    close(sock);
}

void slave()
{
    int sock = open_udp(NULL);

    printf("slave()\n");
    if (sock < 0) {
        return;
    }

    for ( ; ; ) {
        struct sockaddr master_addr;
        unsigned char buf[1024];
        signed int n;

        socklen_t len = sizeof(master_addr);
        n = recvfrom(sock, buf, sizeof(buf), 0, &master_addr, &len);
        if (n == PING_PAYLOAD_SIZE) {
            printf("id 0x%02x: recv %d, sending %d\n", buf[0], n,
                   ACK_PAYLOAD_SIZE);
            ack_payload[0] = buf[0];
            sendto(sock, ack_payload, ACK_PAYLOAD_SIZE, 0, &master_addr, len);
        }
    }

    close(sock);
}

int main(int argc, char *argv[]) {
    if (argc > 1) {
        master(argv[1]);
    } else {
        slave();
    }
    return 0;
}
