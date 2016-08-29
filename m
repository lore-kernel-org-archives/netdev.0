From: Jia He <hejianet@gmail.com>
Subject: [RFC PATCH 0/6] Reduce cache miss for snmp_fold_field
Date: Tue, 30 Aug 2016 00:03:54 +0800
Message-ID: <1472486640-1111-1-git-send-email-hejianet@gmail.com>
Cc: linux-sctp@vger.kernel.org, linux-kernel@vger.kernel.org,
        davem@davemloft.net, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Jia He <hejianet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In a PowerPc server with large cpu number(160), besides commit
a3a773726c9f ("net: Optimize snmp stat aggregation by walking all
the percpu data at once"), I watched several other snmp_fold_field
callsites which will cause high cache miss rate.

#My simple test case, which read from the procfs items endlessly:
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

#compile and run:
gcc test.c -o test

perf stat -d -e cache-misses ./test /proc/net/snmp
perf stat -d -e cache-misses ./test /proc/net/snmp6
perf stat -d -e cache-misses ./test /proc/net/netstat
perf stat -d -e cache-misses ./test /proc/net/sctp/snmp
perf stat -d -e cache-misses ./test /proc/net/xfrm_stat

#test results
I firstly test the correctness of data statistics. 

As for performance, before the patch set:
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

Jia He (6):
  proc: Reduce cache miss in {snmp,netstat}_seq_show
  proc: Reduce cache miss in snmp6_seq_show
  proc: Reduce cache miss in sctp_snmp_seq_show
  proc: Reduce cache miss in xfrm_statistics_seq_show
  ipv6: Remove useless parameter in __snmp6_fill_statsdev
  net: Suppress the "Comparison to NULL could be written" warning

 net/ipv4/proc.c      | 110 ++++++++++++++++++++++++++++++---------------------
 net/ipv6/addrconf.c  |  12 +++---
 net/ipv6/proc.c      |  47 ++++++++++++++++------
 net/sctp/proc.c      |  15 +++++--
 net/xfrm/xfrm_proc.c |  15 +++++--
 5 files changed, 131 insertions(+), 68 deletions(-)

-- 
1.8.3.1
