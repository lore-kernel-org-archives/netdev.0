From: Kenny Chang <kchang@athenacr.com>
Subject: Re: Multicast packet loss
Date: Fri, 30 Jan 2009 17:29:42 -0500
Message-ID: <49837F56.2020502@athenacr.com>
References: <49833DBC.7040607@athenacr.com> <20090130200330.GA12659@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080607080904060209030803"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.95.46.209] ([64.95.46.209]:1998 "EHLO
	sprinkles.inp.in.athenacr.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752325AbZA3W3r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 17:29:47 -0500
Received: from [192.168.14.21] (fiji.em.in.athenacr.com [192.168.14.21])
	by sprinkles.inp.in.athenacr.com (Postfix) with ESMTP id 44AAEF68CC
	for <netdev@vger.kernel.org>; Fri, 30 Jan 2009 17:29:44 -0500 (EST)
In-Reply-To: <20090130200330.GA12659@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080607080904060209030803
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Ah, sorry, here's the test program attached.

We've tried 2.6.28.1, but no, we haven't tried the 2.6.28.2 or the 
2.6.29.-rcX.

Right now, we are trying to step through the kernel versions until we 
see where the performance drops significantly.  We'll try 2.6.29-rc soon 
and post the result.

Neil Norman wrote:

1) Determine if its a rx or tx packet loss.  From your comments above it sounds
like this is an rx side issue

   We're pretty sure it's an rx issue.  Other machines receiving at the 
same time will
   get all the packets.

I'll gather the information mentioned and summarize in a subsequent email.

Thanks!
Kenny

Neil Horman wrote:
> On Fri, Jan 30, 2009 at 12:49:48PM -0500, Kenny Chang wrote:
>   
>> Hi all,
>>
>> We've been having some issues with multicast packet loss, we were wondering
>> if anyone knows anything about the behavior we're seeing.
>>
>> Background: we use multicast messaging with lots of messages per sec for our
>> work. We recently transitioned many of our systems from an Ubuntu Dapper Drake
>> ia32 distribution to Ubuntu Hardy Heron x86_64. Since the transition, we've
>> noticed much more multicast packet loss, and we think it's related to the
>> transition. Our particular theory is that it's specifically a 32 vs 64-bit
>> issue.
>>
>> We narrowed the problem down to the attached program (mcasttest.cc).  Run
>> "mcasttest server" on one machine -- it'll send 500,000 messages small message
>> to a multicast group, 50,000 messages per second.  If we run "mcasttest client"
>> on another machine, it'll receive all those messages and print a count at the
>> end of how many messages it sees. It almost never loses any messages. However,
>> if we run 4 copies of the client on the same machine, receiving the same data,
>> then the programs usually sees fewer than 500,000 messages. We're running with:
>>
>> for i in $(seq 1 4); do (./mcasttest client &); done
>>
>> We know this because the program prints a count, but dropped packets also
>> show up in ifconfig's "RX packets" section.
>>
>> Things we're curious about: do other people see similar problems?  The tests
>> we've done: we've tried this program on a bunch of different machines, all of
>> which are running either dapper ia32 or hardy x86_64. Uniformly, the dapper
>> machines have no problems but on certain machines, Hardy shows 
>> significant loss. We did some experiments on a troubled machine, varying 
>> the OS install, including mixed installations where the kernel was 64-bit 
>> and the userspace was
>> 32-bit. This is what we found:
>>
>> On machines that exhibit this problem, the ksoftirqd process seems to be  
>> pegged to 100% CPU when receiving packets.
>>
>> Note: while we're on Ubuntu, we've tried this with other distros and have seen
>> similar results, we just haven't tabulated them.
>>
>>     
>>> ----------------------------------------------------------------------------
>>> userland | userland arch | kernel           | kernel arch | mode        
>>>     
>>> ----------------------------------------------------------------------------
>>> Dapper   |            32 | 2.6.15-28-server |          32 | no packet loss
>>> Dapper   |            32 | 2.6.22-generic   |          32 | no packet 
>>> loss Dapper   |            32 | 2.6.22-server    |          32 | no 
>>> packet loss Hardy    |            32 | 2.6.24-rt        |          32 | 
>>> no packet loss
>>> Hardy    |            32 | 2.6.24-generic   |          32 | ~5% packet loss
>>> Hardy    |            32 | 2.6.24-server    |          32 | ~10% packet loss
>>>       
>>> Hardy    |            32 | 2.6.22-server    |          64 | no packet loss
>>> Hardy    |            32 | 2.6.24-rt        |          64 | no packet loss
>>> Hardy    |            32 | 2.6.24-generic   |          64 | 14% packet loss
>>> Hardy    |            32 | 2.6.24-server    |          64 | 12% packet loss
>>>       
>>> Hardy    |            64 | 2.6.22-vanilla   |          64 | packet loss
>>> Hardy    |            64 | 2.6.24-rt        |          64 | ~5% packet loss
>>> Hardy    |            64 | 2.6.24-server    |          64 | ~30% packet loss
>>> Hardy    |            64 | 2.6.24-generic   |          64 | ~5% packet loss
>>> ----------------------------------------------------------------------------
>>>       
>> It's not exactly clear what exactly the problem is but dapper shows no 
>> issues regardless of what we try. For hardy, userspace seem to matter:  
>> 2.6.24-rt kernel shows no packet loss for 32&64bit kernels, as long as 
>> the userspace is 32-bit.
>>
>> Kernel comments:
>> 2.6.15-28-server: This is Ubuntu Dapper's stock kernel build.
>> 2.6.24-*: This is Ubuntu Hardy's stock kernel.
>> 2.6.22-{generic,server}: This is a custom, in-house kernel build, built for ia32.
>> 2.6.22-vanilla: This is our custom, in-house kernel build, built for x86_64.
>>
>> We don't think it's related to our custom kernels, because the same phenomena
>> show up with the Ubuntu stock kernels.
>>
>> Hardware:
>>
>> The benchmark machine We've been using is an Intel Xeon E5440 @2.83GHz
>> dual-cpu quad-core with Broadcom NetXtreme II BCM5708 bnx2 networking.
>>
>> We've also tried AMD machines, as well as machines with Tigon3
>> partno(BCM95704A6) tg3 network cards, they all show consistent behavior.
>>
>> Our hardy x86_64 server machines all appear to have this problem, new and old.
>>
>> On the other hand, a desktop with Intel Q6600 quad core 2.4GHz and Intel 82566DC GigE
>> seem to work fine.
>>
>> All of the dapper ia32 machines have no trouble, even our older hardware.
>>
>>     
>
> Like Eric mentioned, I'd start with a latest kernel if at all possible.  If it
> doesn't happen there, you're work is half over, you just need to figure out what
> changed, and tell Canonical to backport it.
>
> From there, you can solve this like most packet loss issues are solved:
>
> 1) Determine if its a rx or tx packet loss.  From your comments above it sounds
> like this is an rx side issue
>
> 2) Look at statistics from the hardware to the application.  Use ethtool &
> /proc/net/dev to get hardware packet loss stats, /proc/net/snmp netstat -s to
> get core network loss stats
>
> 3) Use those stats to identify where and why packets are getting dropped.
> Posting some summary of that data here is something we can help with if need be
>
> 4) Determine how to reduce the loss (i.e. code change vs. tuning)
>
> 5) Lather, rinse repeat (given that eliminating a drop cause in one location
> will likely increase througput, potentially putting strain on another location
> in the code path, possibly leading to more drops elsewhere. 
>
>
> You had mentioned that ifconfig was showing rx drops, which indicates that your
> hardware rx buffer is likely overflowing.  Usually the best way to fix that is
> to:
>
> 1) modify any available interrupt coalescing parameters on the driver such that
> interrupts have less latency between packet arrival and assertion
>
> 2) increase (if possible) the napi weight (I think thats still the right term)
> so that each napi poll interation receives more frames on the interface,
> draining that queue more quickly.
>
> Neil
>
>   


--------------080607080904060209030803
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

const char *g_mcastaddr = "239.100.0.99";
int g_port = 10100;

int main(int argc, char **argv)
{
    if(argc != 2)
        error("usage: mcasttest (server|client)");
    if(strcmp(argv[1], "client") == 0)
    {
        // Client program: subscribes to a multicast group, receives messages
        // and prints a count of messages received once it's done.

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
        // Server program: sends 50,000 packets per second to a multicast address,
        // for 10 seconds.
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

--------------080607080904060209030803--
