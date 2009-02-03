From: Kenny Chang <kchang@athenacr.com>
Subject: Re: Multicast packet loss
Date: Tue, 03 Feb 2009 12:34:54 -0500
Message-ID: <4988803E.2020009@athenacr.com>
References: <49833DBC.7040607@athenacr.com> <20090130200330.GA12659@hmsreliant.think-freely.org> <49837F56.2020502@athenacr.com> <49838213.90700@cosmosbay.com> <49859847.9010206@cosmosbay.com> <20090202134523.GA13369@hmsreliant.think-freely.org> <498725F4.2010205@cosmosbay.com> <20090202182212.GA17950@hmsreliant.think-freely.org> <loom.20090202T194942-55@post.gmane.org> <498757AA.8010101@cosmosbay.com> <4987610D.6040902@athenacr.com> <4987663D.6080802@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020409020405010405070609"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.95.46.209] ([64.95.46.209]:1278 "EHLO
	sprinkles.inp.in.athenacr.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751134AbZBCRe7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2009 12:34:59 -0500
Received: from [192.168.14.21] (fiji.em.in.athenacr.com [192.168.14.21])
	by sprinkles.inp.in.athenacr.com (Postfix) with ESMTP id F0A6B4D542
	for <netdev@vger.kernel.org>; Tue,  3 Feb 2009 12:34:54 -0500 (EST)
In-Reply-To: <4987663D.6080802@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020409020405010405070609
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit

Eric Dumazet wrote:
> Wes Chow a écrit :
>   
>> Eric Dumazet wrote:
>>     
>>> Wes Chow a écrit :
>>>       
>>>> (I'm Kenny's colleague, and I've been doing the kernel builds)
>>>>
>>>> First I'd like to note that there were a lot of bnx2 NAPI changes
>>>> between 2.6.21 and 2.6.22. As a reminder, 2.6.21 shows tiny amounts
>>>> of packet loss,
>>>> whereas loss in 2.6.22 is significant.
>>>>
>>>> Second, some CPU affinity info: if I do like Eric and pin all of the
>>>> apps onto a single CPU, I see no packet loss. Also, I do *not* see
>>>> ksoftirqd show up on top at all!
>>>>
>>>> If I pin half the processes on one CPU and the other half on another
>>>> CPU, one ksoftirqd processes shows up in top and completely pegs one
>>>> CPU. My packet loss
>>>> in that case is significant (25%).
>>>>
>>>> Now, the strange case: if I pin 3 processes to one CPU and 1 process
>>>> to another, I get about 25% packet loss and ksoftirqd pins one CPU.
>>>> However, one
>>>> of the apps takes significantly less CPU than the others, and all
>>>> apps lose the
>>>> *exact same number of packets*. In all other situations where we see
>>>> packet
>>>> loss, the actual number lost per application instance appears random.
>>>>         
>>> You see same number of packet lost because they are lost at NIC level
>>>       
>> Understood.
>>
>> I have a new observation: if I pin processes to just CPUs 0 and 1, I see
>> no packet loss. Pinning to 0 and 2, I do see packet loss. Pinning 2 and
>> 3, no packet loss. 4 & 5 - no packet loss, 6 & 7 - no packet loss. Any
>> other combination appears to produce loss (though I have not tried all
>> 28 combinations, this seems to be the case).
>>
>> At first I thought maybe it had to do with processes pinned to the same
>> CPU, but different cores. The machine is a dual quad core, which means
>> that CPUs 0-3 should be a physical CPU, correct? Pinning to 0/2 and 0/3
>> produce packet loss.
>>     
>
> a quad core is really a 2 x 2 core
>
> L2 cache is splited on two blocks, one block used by CPU0/1, other by CPU2/3 
>
> You are at the limit of the machine with such workload, so as soon as your
> CPUs have to transfert 64 bytes lines between those two L2 blocks, you loose.
>
>
>   
>> I've also noticed that it does not matter which of the working pairs I
>> pin to. For example, pinning 5 processes in any combination on either
>> 0/1 produce no packet loss, pinning all 5 to just CPU 0 also produces no
>> packet loss.
>>
>> The failures are also sudden. In all of the working cases mentioned
>> above, I don't see ksoftirqd on top at all. But when I run 6 processes
>> on a single CPU, ksoftirqd shoots up to 100% and I lose a huge number of
>> packets.
>>
>>     
>>> Normaly, softirq runs on same cpu (the one handling hard irq)
>>>       
>> What determines which CPU the hard irq occurs on?
>>
>>     
>
> Check /proc/irq/{irqnumber}/smp_affinity
>
> If you want IRQ16 only served by CPU0 :
>
> echo 1 >/proc/irq/16/smp_affinity
>
>   
Hi everyone,

First, thanks for all the effort so far, I think we've learned so much 
more about the problem in the last couple of days than we had previously 
in a month.

Just to summarize where we are:

* pinning processes to specific cores/CPUs alleviate the problem
* issues exist from 2.6.22 up to 2.6.29-rc3
* issue does not appear to be isolated to 64-bit, 32-bits have problems 
too.
* I'm attaching an updated test program with the PR_SET_TIMERSTACK call 
added.
* on troubled machines, we are seeing high number of context switches 
and interrupts.
* we've ordered an Intel card to try in our machine to see if we can 
circumvent the issue with a different driver.

Kernel Version         Has Problem?     Notes
----------             ----------       ----------
2.6.15.x                N    
2.6.16.x                -
2.6.17.x                -               Doesn't build on Hardy
2.6.18.x                -               Doesn't boot (kernel panic)
2.6.19.7                N               ksoftirqd is up there, but not 
pegging a CPU.
                                        Takes roughly same amount of CPU 
as the other
                                        processes, all of which are from 
20-40%
2.6.20.21               N
2.6.21.7                N               sort of lopsided load, but no 
load from
                                        ksoftirqd -- strange
2.6.22.19               Y               First broken kernel
2.6.23.x                -
2.6.24-19               Y               (from Hardy)
2.6.25.x                -
2.6.26.x                -
2.6.27.x                Y               (from Intrepid)
2.6.28.1                Y
2.6.29-rc               Y


Correct me if I'm wrong, from what we've seen, it looks like its 
pointing to some inefficiency in the softirq handling.  The question is 
whether it's something in the driver or the kernel.  If we can isolate 
that, maybe we can take some action to have it fixed.

Kenny

--------------020409020405010405070609
Content-Type: text/x-csrc;
 name="mcasttest.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mcasttest.c"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <arpa/inet.h>
#include <sys/epoll.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/select.h>
#include <unistd.h>

#ifndef PR_SET_TIMERSLACK
#define PR_SET_TIMERSLACK 29
#endif

const char *g_mcastaddr = "239.100.0.99";
int g_port = 10100;

void error(const char *s)
{
    fprintf(stderr, "%s\n", s);
    exit(1);
}

void check(int v)
{
    int myerr = errno;
    char *myerrstr = strerror(myerr);
    if(!v)
        error("bad return code");
}

int main(int argc, char **argv)
{
    if(argc != 2)
        error("usage: mcasttest (server|client)");
    if(strcmp(argv[1], "client") == 0)
    {
        /*
         * Client program: subscribes to a multicast group, receives messages
         * and prints a count of messages received once it's done.
         */
        int s = socket(AF_INET, SOCK_DGRAM, 0);
        check(s > 0);
        int val = 1;
        check(setsockopt(s, SOL_SOCKET, SO_REUSEADDR, &val, sizeof(val)) == 0);

        struct sockaddr_in addr;
        memset(&addr, 0, sizeof(addr));
        addr.sin_family = AF_INET;
        addr.sin_port = htons(g_port);
        addr.sin_addr.s_addr = htonl(INADDR_ANY);
        check(bind(s, (struct sockaddr *) &addr, sizeof(addr)) == 0);

        struct ip_mreqn mreq;
        memset(&mreq, 0, sizeof(mreq));
        check(inet_pton(AF_INET, g_mcastaddr, &mreq.imr_multiaddr));
        mreq.imr_address.s_addr = htonl(INADDR_ANY);
        mreq.imr_ifindex = 0;
        check(setsockopt(s, IPPROTO_IP, IP_ADD_MEMBERSHIP, &mreq, sizeof(mreq)) == 0);

        int bufSz;
        socklen_t len = sizeof(bufSz);
        getsockopt(s, SOL_SOCKET, SO_RCVBUF, (char*)(&bufSz), &len);
        printf("bufsz: %d\n", bufSz);

        int npackets = 0;
        char buf[1000];
        memset(buf, 0, sizeof(buf));
        while(1)
        {
            struct sockaddr_in from;
            socklen_t fromlen = sizeof(from);
            check(recvfrom(s, buf, 1000, 0, (struct sockaddr*)&from, &fromlen) == 100);
            ++npackets;
            if(buf[0] == 1) // exit message
                break;
        }
        printf("received %d packets\n", npackets);
    }
    else if(strcmp(argv[1], "server") == 0)
    {
        /*
         * Setup a timer resolution of 1000 ns : 1 us
         */
        prctl(PR_SET_TIMERSLACK, 1000); 

        /*
         * Server program: sends 50,000 packets per second to a multicast address,
         * for 10 seconds.
         */
        int s = socket(AF_INET, SOCK_DGRAM, 0);
        int val = 1;
        int i = 1;
        check(s > 0);

        struct sockaddr_in addr;
        memset(&addr, 0, sizeof(addr));
        addr.sin_family = AF_INET;
        addr.sin_port = htons(g_port);
        check(inet_pton(AF_INET, g_mcastaddr, &addr.sin_addr.s_addr));
        check(connect(s, (struct sockaddr *) &addr, sizeof(addr)) == 0);

        int npackets = 500000;
        char buf[100];
        memset(buf, 0, sizeof(buf));
        for(i = 1; i < npackets; ++i)
        {
            check(send(s, buf, sizeof(buf), 0) > 0);
            usleep(20); // 50,000 messages per second
        }

        buf[0] = 1;
        for(i = 1; i < 5; ++i)
        {
            check(send(s, buf, sizeof(buf), 0) > 0);
            sleep(1);
        }
    }
    else
        error("unknown mode");
    return 0;
}

--------------020409020405010405070609--
