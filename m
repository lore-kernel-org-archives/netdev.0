From: Jia He <hejianet@gmail.com>
Subject: [PATCH v5 0/7] Reduce cache miss for snmp_fold_field
Date: Wed, 28 Sep 2016 14:22:21 +0800
Message-ID: <1475043748-18161-1-git-send-email-hejianet@gmail.com>
Cc: linux-sctp@vger.kernel.org, linux-kernel@vger.kernel.org,
        davem@davemloft.net, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        marcelo.leitner@gmail.com, Jia He <hejianet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:33336 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751500AbcI1GWk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 02:22:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In a PowerPc server with large cpu number(160), besides commit
a3a773726c9f ("net: Optimize snmp stat aggregation by walking all
the percpu data at once"), I watched several other snmp_fold_field
callsites which would cause high cache miss rate.

test source code:
================
My simple test case, which read from the procfs items endlessly:
/***********************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#define LINELEN  2560
int main(int argc, char **argv)
{
        int i;
        int fd = -1 ;
        int rdsize = 0;
        char buf[LINELEN+1];

        buf[LINELEN] = 0;
        memset(buf,0,LINELEN);

        if(1 >= argc) {
                printf("file name empty\n");
                return -1;
        }

        fd = open(argv[1], O_RDWR, 0644);
        if(0 > fd){
                printf("open error\n");
                return -2;
        }

        for(i=0;i<0xffffffff;i++) {
                while(0 < (rdsize = read(fd,buf,LINELEN))){
                        //nothing here
                }

                lseek(fd, 0, SEEK_SET);
        }

        close(fd);
        return 0;
}
/**********************************************************/

compile and run:
================
gcc test.c -o test

perf stat -d -e cache-misses ./test /proc/net/snmp
perf stat -d -e cache-misses ./test /proc/net/snmp6
perf stat -d -e cache-misses ./test /proc/net/sctp/snmp
perf stat -d -e cache-misses ./test /proc/net/xfrm_stat

before the patch set:
====================
 Performance counter stats for 'system wide':

         355911097      cache-misses                                                 [40.08%]
        2356829300      L1-dcache-loads                                              [60.04%]
         355642645      L1-dcache-load-misses     #   15.09% of all L1-dcache hits   [60.02%]
         346544541      LLC-loads                                                    [59.97%]
            389763      LLC-load-misses           #    0.11% of all LL-cache hits    [40.02%]

       6.245162638 seconds time elapsed

After the patch set:
===================
 Performance counter stats for 'system wide':

         194992476      cache-misses                                                 [40.03%]
        6718051877      L1-dcache-loads                                              [60.07%]
         194871921      L1-dcache-load-misses     #    2.90% of all L1-dcache hits   [60.11%]
         187632232      LLC-loads                                                    [60.04%]
            464466      LLC-load-misses           #    0.25% of all LL-cache hits    [39.89%]

       6.868422769 seconds time elapsed
The cache-miss rate can be reduced from 15% to 2.9%

changelog
=========
v5:
- order local variables from longest to shortest line
v4:
- move memset into one block of if statement in snmp6_seq_show_item
- remove the changes in netstat_seq_show considerred the stack usage is too large
v3:
- introduce generic interface (suggested by Marcelo Ricardo Leitner)
- use max_t instead of self defined macro (suggested by David Miller)
v2:
- fix bug in udplite statistics.
- snmp_seq_show is split into 2 parts

Jia He (7):
  net:snmp: Introduce generic interfaces for snmp_get_cpu_field{,64}
  proc: Reduce cache miss in snmp_seq_show
  proc: Reduce cache miss in snmp6_seq_show
  proc: Reduce cache miss in sctp_snmp_seq_show
  proc: Reduce cache miss in xfrm_statistics_seq_show
  ipv6: Remove useless parameter in __snmp6_fill_statsdev
  net: Suppress the "Comparison to NULL could be written" warnings

 include/net/ip.h     |  23 ++++++++++++
 net/ipv4/proc.c      | 100 +++++++++++++++++++++++++++++++--------------------
 net/ipv6/addrconf.c  |  12 +++----
 net/ipv6/proc.c      |  32 ++++++++++++-----
 net/sctp/proc.c      |  12 ++++---
 net/xfrm/xfrm_proc.c |  12 +++++--
 6 files changed, 131 insertions(+), 60 deletions(-)

-- 
2.5.5
