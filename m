From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: net/can: warning in bcm_connect/proc_register
Date: Mon, 24 Oct 2016 20:23:21 +0200
Message-ID: <4b87d6d7-94cc-e8d1-62cd-200444413fd9@hartkopp.net>
References: <CAAeHK+x6w+Lg1GoCZXdjPtM6n72dpUbF_Bvtg80YNK-Wh8YJ4w@mail.gmail.com>
 <CAM_iQpUAw6R1P-CQ-YJAYzb-HJXqUKAhJ5rLwp1L-ie3VkprSQ@mail.gmail.com>
 <CAAeHK+xPUAcao+xufvBfLRZcCR4oDY-WfV-CJspYqArh0cqYUg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
        "David S. Miller" <davem@davemloft.net>, linux-can@vger.kernel.org,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>,
        Kostya Serebryany <kcc@google.com>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Andrey Konovalov <andreyknvl@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+xPUAcao+xufvBfLRZcCR4oDY-WfV-CJspYqArh0cqYUg@mail.gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Andrey, hello Cong,

thanks for catching this issue.

I added lock_sock() and a check for a failing proc_create_data() below.

Can you please check if it solved the issue?
I tested the patched version with the stress tool as advised by Andrey 
and did not see any problems in dmesg anymore.
If ok I can provide a proper patch.

Many thanks,
Oliver


diff --git a/net/can/bcm.c b/net/can/bcm.c
index 8e999ff..8af9d25 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -1549,24 +1549,31 @@ static int bcm_connect(struct socket *sock, 
struct sockaddr *uaddr, int len,
  	struct sockaddr_can *addr = (struct sockaddr_can *)uaddr;
  	struct sock *sk = sock->sk;
  	struct bcm_sock *bo = bcm_sk(sk);
+	int ret = 0;

  	if (len < sizeof(*addr))
  		return -EINVAL;

-	if (bo->bound)
-		return -EISCONN;
+	lock_sock(sk);
+
+	if (bo->bound) {
+		ret = -EISCONN;
+		goto fail;
+	}

  	/* bind a device to this socket */
  	if (addr->can_ifindex) {
  		struct net_device *dev;

  		dev = dev_get_by_index(&init_net, addr->can_ifindex);
-		if (!dev)
-			return -ENODEV;
-
+		if (!dev) {
+			ret = -ENODEV;
+			goto fail;
+		}
  		if (dev->type != ARPHRD_CAN) {
  			dev_put(dev);
-			return -ENODEV;
+			ret = -ENODEV;
+			goto fail;
  		}

  		bo->ifindex = dev->ifindex;
@@ -1577,17 +1584,24 @@ static int bcm_connect(struct socket *sock, 
struct sockaddr *uaddr, int len,
  		bo->ifindex = 0;
  	}

-	bo->bound = 1;
-
  	if (proc_dir) {
  		/* unique socket address as filename */
  		sprintf(bo->procname, "%lu", sock_i_ino(sk));
  		bo->bcm_proc_read = proc_create_data(bo->procname, 0644,
  						     proc_dir,
  						     &bcm_proc_fops, sk);
+		if (!bo->bcm_proc_read) {
+			ret = -ENOMEM;
+			goto fail;
+		}
  	}

-	return 0;
+	bo->bound = 1;
+
+fail:
+	release_sock(sk);
+
+	return ret;
  }

  static int bcm_recvmsg(struct socket *sock, struct msghdr *msg, size_t 
size,


On 10/24/2016 07:31 PM, Andrey Konovalov wrote:
> Hi Cong,
>
> I'm able to reproduce it by running
> https://gist.github.com/xairy/33f2eb6bf807b004e643bae36c3d02d7 in a
> tight parallel loop with stress
> (https://godoc.org/golang.org/x/tools/cmd/stress):
> $ gcc -lpthread tmp.c
> $ ./stress ./a.out
>
> The C program was generated from the following syzkaller prog:
> mmap(&(0x7f0000000000/0x991000)=nil, (0x991000), 0x3, 0x32,
> 0xffffffffffffffff, 0x0)
> socket(0x1d, 0x80002, 0x2)
> r0 = socket(0x1d, 0x80002, 0x2)
> connect$nfc_llcp(r0, &(0x7f000000c000)={0x27, 0x100000000, 0x0, 0x5,
> 0x100000000, 0x1,
> "341b3a01b257849ca1d7d1ff9f999d8127b185f88d1d775d59c88a3aa6a8ddacdf2bdc324ea6578a21b85114610186c3817c34b05eaffd2c3f54f57fa81ba0",
> 0x1ff}, 0x60)
> connect$nfc_llcp(r0, &(0x7f0000991000-0x60)={0x27, 0x100000000, 0x1,
> 0x5, 0xfffffffffffffffd, 0x0,
> "341b3a01b257849ca1d7d1ff9f999d8127b185f88d1d775dbec88a3aa6a8ddacdf2bdc324ea6578a21b85114610186c3817c34b05eaffd2c3f54f57fa81ba0",
> 0x1ff}, 0x60)
>
> Unfortunately I wasn't able to create a simpler reproducer.
>
> Thanks!
>
> On Mon, Oct 24, 2016 at 6:58 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> On Mon, Oct 24, 2016 at 9:21 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
>>> Hi,
>>>
>>> I've got the following error report while running the syzkaller fuzzer:
>>>
>>> WARNING: CPU: 0 PID: 32451 at fs/proc/generic.c:345 proc_register+0x25e/0x300
>>> proc_dir_entry 'can-bcm/249757' already registered
>>> Kernel panic - not syncing: panic_on_warn set ...
>>
>> Looks like we have two problems here:
>>
>> 1) A check for bo->bcm_proc_read != NULL seems missing
>> 2) We need to lock the sock in bcm_connect().
>>
>> I will work on a patch. Meanwhile, it would help a lot if you could provide
>> a reproducer.
>>
>> Thanks!
