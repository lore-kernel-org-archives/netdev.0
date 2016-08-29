From: Kirill Tkhai <ktkhai@virtuozzo.com>
Subject: [PATCH RFC 0/2] net: Iterate over cpu_present_mask during
 calculation of percpu statistics
Date: Mon, 29 Aug 2016 22:03:48 +0300
Message-ID: <147249730528.18175.4772805024092024580.stgit@pro>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <yoshfuji@linux-ipv6.org>, <jmorris@namei.org>,
        <davem@davemloft.net>, <peterz@infradead.org>,
        <edumazet@google.com>, <mingo@redhat.com>, <kaber@trash.net>,
        <ktkhai@virtuozzo.com>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Many variables of statistics type are made percpu in kernel. This allows
to do not make them atomic or to do not use synchronization. The result
value is calculated as sum of values on every possible cpu.

The problem is this scales bad. The calculations may took a lot of time.
For example, some machine configurations have many possible cpus like below:

"smpboot: Allowing 192 CPUs, 160 hotplug CPUs"

There are only 32 real cpus, but 192 possible cpus.

I had a report about very slow getifaddrs() on older kernel, when there are
possible only 590 getifaddrs calls/second on Xeon(R) CPU E5-2667 v3 @ 3.20GHz.

The patchset aims to begin solving of this problem. It makes possible to
iterate over present cpus mask instead of possible. When cpu is going down,
a statistics is being moved to an alive cpu. It's made in CPU_DYING callback,
which happens when machine is stopped. So, iteration  over present cpus mask
is safe under preemption disabled.

Patchset could exclude even offline cpus, but I didn't do that, because
the main problem seems to be possible cpus. Also, this would require to
do some changes in kernel/cpu.c, so I'd like to hear people opinion about
expediency of this before.

One more question is whether the whole kernel needs the same possibility
and the patchset should be more generic.

Please, comment!

For the above configuration the patchset improves the below test in 2.9 times:

#define _GNU_SOURCE     /* To get defns of NI_MAXSERV and NI_MAXHOST */
#include <arpa/inet.h>
#include <sys/socket.h>
#include <netdb.h>
#include <ifaddrs.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <linux/if_link.h>

int do_gia()
{
   struct ifaddrs *ifaddr, *ifa;
   int family, s, n;
   char host[NI_MAXHOST];

   if (getifaddrs(&ifaddr) == -1) {
           perror("getifaddrs");
           exit(EXIT_FAILURE);
   }

   /* touch the data  */
   for (ifa = ifaddr, n = 0; ifa != NULL; ifa = ifa->ifa_next, n++) {
           if (ifa->ifa_addr == NULL)
                   continue;
           family = ifa->ifa_addr->sa_family;
   }
   freeifaddrs(ifaddr);
}

int main(int argc, char *argv[])
{
        int i;
        for(i=0; i<10000; i++)
           do_gia();
}

---

Kirill Tkhai (2):
      net: Implement net_stats callbacks
      net: Iterate over present cpus only during ipstats calculation


 include/net/stats.h |    9 ++++++
 net/core/Makefile   |    1 +
 net/core/stats.c    |   83 +++++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv6/addrconf.c |    4 ++
 net/ipv6/af_inet6.c |   56 ++++++++++++++++++++++++++++++++++
 5 files changed, 152 insertions(+), 1 deletion(-)
 create mode 100644 include/net/stats.h
 create mode 100644 net/core/stats.c

--
Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
