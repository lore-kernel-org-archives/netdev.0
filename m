From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: [PATCH 02/26] rewrite READ_ONCE/WRITE_ONCE
Date: Thu, 2 Mar 2017 17:51:14 +0100
Message-ID: <76790664-a7a9-193c-2e30-edaee1308cb0@de.ibm.com>
References: <20170302163834.2273519-1-arnd@arndb.de>
 <20170302163834.2273519-3-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-media@vger.kernel.org,
        linux-wireless@vger.kernel.org,
        kernel-build-reports@lists.linaro.org,
        "David S . Miller" <davem@davemloft.net>,
        Paul McKenney <paulmck@linux.vnet.ibm.com>
To: Arnd Bergmann <arnd@arndb.de>, kasan-dev@googlegroups.com
Return-path: <linux-media-owner@vger.kernel.org>
In-Reply-To: <20170302163834.2273519-3-arnd@arndb.de>
Sender: linux-media-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/02/2017 05:38 PM, Arnd Bergmann wrote:
> When CONFIG_KASAN is enabled, the READ_ONCE/WRITE_ONCE macros cause
> rather large kernel stacks, e.g.:
> 
> mm/vmscan.c: In function 'shrink_page_list':
> mm/vmscan.c:1333:1: error: the frame size of 3456 bytes is larger than 3072 bytes [-Werror=frame-larger-than=]
> block/cfq-iosched.c: In function 'cfqg_stats_add_aux':
> block/cfq-iosched.c:750:1: error: the frame size of 4048 bytes is larger than 3072 bytes [-Werror=frame-larger-than=]
> fs/btrfs/disk-io.c: In function 'open_ctree':
> fs/btrfs/disk-io.c:3314:1: error: the frame size of 3136 bytes is larger than 3072 bytes [-Werror=frame-larger-than=]
> fs/btrfs/relocation.c: In function 'build_backref_tree':
> fs/btrfs/relocation.c:1193:1: error: the frame size of 4336 bytes is larger than 3072 bytes [-Werror=frame-larger-than=]
> fs/fscache/stats.c: In function 'fscache_stats_show':
> fs/fscache/stats.c:287:1: error: the frame size of 6512 bytes is larger than 3072 bytes [-Werror=frame-larger-than=]
> fs/jbd2/commit.c: In function 'jbd2_journal_commit_transaction':
> fs/jbd2/commit.c:1139:1: error: the frame size of 3760 bytes is larger than 3072 bytes [-Werror=frame-larger-than=]
> 
> This attempts a rewrite of the two macros, using a simpler implementation
> for the most common case of having a naturally aligned 1, 2, 4, or (on
> 64-bit architectures) 8  byte object that can be accessed with a single
> instruction.  For these, we go back to a volatile pointer dereference
> that we had with the ACCESS_ONCE macro.

We had changed that back then because gcc 4.6 and 4.7 had a bug that could
removed the volatile statement on aggregate types like the following one

union ipte_control {
        unsigned long val;
        struct {
                unsigned long k  : 1;
                unsigned long kh : 31;
                unsigned long kg : 32;
        };
};

See https://gcc.gnu.org/bugzilla/show_bug.cgi?id=58145

If I see that right, your __ALIGNED_WORD(x)
macro would say that for above structure  sizeof(x) == sizeof(long)) is true,
so it would fall back to the old volatile cast and might reintroduce the 
old compiler bug?

Could you maybe you fence your simple macro for anything older than 4.9? After
all there was no kasan support anyway on these older gcc version.

Christian
