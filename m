From: Wang Jian <lark@linux.net.cn>
Subject: Re: [PATCH] improvement on net/sched/cls_fw.c's hash function
Date: Tue, 05 Apr 2005 22:18:53 +0800
Message-ID: <20050405213023.0256.LARK@linux.net.cn>
References: <20050405202039.0250.LARK@linux.net.cn> <1112705689.1088.209.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1112705689.1088.209.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi jamal,


On 05 Apr 2005 08:54:49 -0400, jamal <hadi@cyberus.ca> wrote:

> 
> Why dont you run a quick test? Very easy to do in user space.
> Enter two sets of values using the two different approaches; yours and 
> the current way tc uses nfmark (incremental). And then apply the jenkins
> approach you had to see how well it looks like? I thinkw e know how it
> will look with current hash - but if you can show its not so bad in the
> case of jenkins as well it may be an acceptable approach,
> 

I am not saying that we must use jenkins. We may use a less expensive
hash function than jenkins, but better than & 0xFF.

Anyway, I have done userspace test for jhash. The following test is done
in a AMD Athlon 800MHz without other CPU load.


-- snip jhash_test.c --
typedef unsigned long u32;
typedef unsigned char u8;

#include <linux/jhash.h>
#include <stdlib.h>

int main(void)
{
        u32 i;
        u32 h;

        for (i = 0; i < 10000000; i++) {
                h = jhash_1word(i, 0xF30A7129) & 0xFFL;
                // printf("h is %u\n", h);
        }
        return 0;
}
-- snip --

[root@qos ~]# gcc jhash_test.c 
[root@qos ~]# time ./a.out
0.77user 0.00system 0:00.77elapsed 99%CPU (0avgtext+0avgdata 0maxresident)k
0inputs+0outputs (0major+81minor)pagefaults 0swaps


--snip simple_hash.c --
typedef unsigned long u32;
typedef unsigned char u8;

#include <stdlib.h>

int main(void)
{
        u32 i;
        u32 h;

        for (i = 0; i < 10000000; i++) {
                h = i & 0xFF;
                // printf("h is %u\n", h);
        }
        return 0;
}
-- snip --
[root@qos ~]# gcc simple_hash.c 
[root@qos ~]# time ./a.out
0.02user 0.00system 0:00.02elapsed 96%CPU (0avgtext+0avgdata 0maxresident)k
0inputs+0outputs (0major+81minor)pagefaults 0swaps


The simple method is far better in performance. For extreme situation,
100Mbps ethernet has about 148800 pps for TCP. Replace 10000000 with
150000.

[root@qos ~]# time ./a.out 
0.01user 0.00system 0:00.01elapsed 83%CPU (0avgtext+0avgdata 0maxresident)k
0inputs+0outputs (0major+81minor)pagefaults 0swaps

So use jhash is not big deal at 100Mbps.


For 1000Mbps ethernet, replace 10000000 with 1489000.

[root@qos ~]# time ./a.out 
0.11user 0.00system 0:00.11elapsed 99%CPU (0avgtext+0avgdata 0maxresident)k
0inputs+0outputs (0major+81minor)pagefaults 0swaps

It's expected that a more hot CPU is used for GE, for example, 2.4GHz
CPU. So

0.11 / (2.4/0.8) = 0.04.

This is still not a big problem for a dedicated linux box for qos
control. We know that 500Mbps is already a bottleneck here.



-- 
  lark
