From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: net/can: warning in bcm_connect/proc_register
Date: Mon, 24 Oct 2016 19:31:49 +0200
Message-ID: <CAAeHK+xPUAcao+xufvBfLRZcCR4oDY-WfV-CJspYqArh0cqYUg@mail.gmail.com>
References: <CAAeHK+x6w+Lg1GoCZXdjPtM6n72dpUbF_Bvtg80YNK-Wh8YJ4w@mail.gmail.com>
 <CAM_iQpUAw6R1P-CQ-YJAYzb-HJXqUKAhJ5rLwp1L-ie3VkprSQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        "David S. Miller" <davem@davemloft.net>, linux-can@vger.kernel.org,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>,
        Kostya Serebryany <kcc@google.com>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpUAw6R1P-CQ-YJAYzb-HJXqUKAhJ5rLwp1L-ie3VkprSQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Cong,

I'm able to reproduce it by running
https://gist.github.com/xairy/33f2eb6bf807b004e643bae36c3d02d7 in a
tight parallel loop with stress
(https://godoc.org/golang.org/x/tools/cmd/stress):
$ gcc -lpthread tmp.c
$ ./stress ./a.out

The C program was generated from the following syzkaller prog:
mmap(&(0x7f0000000000/0x991000)=nil, (0x991000), 0x3, 0x32,
0xffffffffffffffff, 0x0)
socket(0x1d, 0x80002, 0x2)
r0 = socket(0x1d, 0x80002, 0x2)
connect$nfc_llcp(r0, &(0x7f000000c000)={0x27, 0x100000000, 0x0, 0x5,
0x100000000, 0x1,
"341b3a01b257849ca1d7d1ff9f999d8127b185f88d1d775d59c88a3aa6a8ddacdf2bdc324ea6578a21b85114610186c3817c34b05eaffd2c3f54f57fa81ba0",
0x1ff}, 0x60)
connect$nfc_llcp(r0, &(0x7f0000991000-0x60)={0x27, 0x100000000, 0x1,
0x5, 0xfffffffffffffffd, 0x0,
"341b3a01b257849ca1d7d1ff9f999d8127b185f88d1d775dbec88a3aa6a8ddacdf2bdc324ea6578a21b85114610186c3817c34b05eaffd2c3f54f57fa81ba0",
0x1ff}, 0x60)

Unfortunately I wasn't able to create a simpler reproducer.

Thanks!

On Mon, Oct 24, 2016 at 6:58 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Mon, Oct 24, 2016 at 9:21 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
>> Hi,
>>
>> I've got the following error report while running the syzkaller fuzzer:
>>
>> WARNING: CPU: 0 PID: 32451 at fs/proc/generic.c:345 proc_register+0x25e/0x300
>> proc_dir_entry 'can-bcm/249757' already registered
>> Kernel panic - not syncing: panic_on_warn set ...
>
> Looks like we have two problems here:
>
> 1) A check for bo->bcm_proc_read != NULL seems missing
> 2) We need to lock the sock in bcm_connect().
>
> I will work on a patch. Meanwhile, it would help a lot if you could provide
> a reproducer.
>
> Thanks!
