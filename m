From: Andrew <nitr0@seti.kr.ua>
Subject: Re: Kernel 4.1.12 crash
Date: Wed, 25 Nov 2015 00:59:52 +0200
Message-ID: <5654EBE8.9030705@seti.kr.ua>
References: <564F26FF.3040605@seti.kr.ua> <564FA904.7020603@gmail.com>
 <5650287B.9070901@seti.kr.ua> <56514FF5.7060906@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Alexander Duyck <alexander.duyck@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imap.seti.kr.ua ([91.202.132.4]:35237 "EHLO mail.seti.kr.ua"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751702AbbKXW77 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Nov 2015 17:59:59 -0500
In-Reply-To: <56514FF5.7060906@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

I tried to reproduce errors in virtual environment (some VMs on my=20
notebook).

I've tried to create 1000 client PPPoE sessions from this box via scrip=
t:
for i in `seq 1 1000`; do pppd plugin rp-pppoe.so user test password=20
test nodefaultroute maxfail 0 persist nodefaultroute holdoff 1 noauth=20
eth0; done

And on VM that is used as client I've got strange random crashes (that=20
are present only when server is online - so they're network-related):

http://postimg.org/image/ohr2mu3rj/ - crash is here:
(gdb) list *process_one_work+0x32
0xc10607b2 is in process_one_work=20
(/var/testpoint/LEAF/source/i486-unknown-linux-uclibc/linux/linux-4.1/k=
ernel/workqueue.c:1952).
1947    __releases(&pool->lock)
1948    __acquires(&pool->lock)
1949    {
1950        struct pool_workqueue *pwq =3D get_work_pwq(work);
1951        struct worker_pool *pool =3D worker->pool;
1952        bool cpu_intensive =3D pwq->wq->flags & WQ_CPU_INTENSIVE;
1953        int work_color;
1954        struct worker *collision;
1955    #ifdef CONFIG_LOCKDEP
1956        /*


http://postimg.org/image/x9mychssx/ - crash is here (noticed twice):
0xc10658bf is in kthread_data=20
(/var/testpoint/LEAF/source/i486-unknown-linux-uclibc/linux/linux-4.1/k=
ernel/kthread.c:136).
131     * The caller is responsible for ensuring the validity of @task =
when
132     * calling this function.
133     */
134    void *kthread_data(struct task_struct *task)
135    {
136        return to_kthread(task)->data;
137    }

which is leaded by strange place:
(gdb) list *kthread_create_on_node+0x120
0xc1065340 is in kthread=20
(/var/testpoint/LEAF/source/i486-unknown-linux-uclibc/linux/linux-4.1/k=
ernel/kthread.c:176).
171    {
172        __kthread_parkme(to_kthread(current));
173    }
174
175    static int kthread(void *_create)
176    {
177        /* Copy data: it's on kthread's stack */
178        struct kthread_create_info *create =3D _create;
179        int (*threadfn)(void *data) =3D create->threadfn;
180        void *data =3D create->data;

And earlier:
(gdb) list *ret_from_kernel_thread+0x21
0xc13bb181 is at=20
/var/testpoint/LEAF/source/i486-unknown-linux-uclibc/linux/linux-4.1/ar=
ch/x86/kernel/entry_32.S:312.
307        popl_cfi %eax
308        pushl_cfi $0x0202        # Reset kernel eflags
309        popfl_cfi
310        movl PT_EBP(%esp),%eax
311        call *PT_EBX(%esp)
312        movl $0,PT_EAX(%esp)
313        jmp syscall_exit
314        CFI_ENDPROC
315    ENDPROC(ret_from_kernel_thread)
316

Stack corruption?..

I'll try to make test environment on real hardware. And I'll try to tes=
t=20
with older kernels.

22.11.2015 07:17, Alexander Duyck =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On 11/21/2015 12:16 AM, Andrew wrote:
>> Memory corruption, if happens, IMHO shouldn't be a hardware-related =
-=20
>> almost all of these boxes, except H61M-based box from 1st log, works=
=20
>> for a long time with uptime more than year; and only software was=20
>> changed on it; H61M-based box runs memtest86 for a tens of hours w/o=
=20
>> any error. If it was caused by hardware - they should crash even=20
>> earlier.
>
> I wasn't saying it was hardware related.  My thought is that it could=
=20
> be some sort of use after free or double free type issue. Basically=20
> what you end up with is the memory getting corrupted by software that=
=20
> is accessing regions it shouldn't be.
>
>> Rarely on different servers I saw 'zram decompression error' message=
s=20
>> (in this case I've got such message on H61M-based box).
>>
>> Also, other people that uses accel-ppp as BRAS software, have=20
>> different kernel panics/bugs/oopses on fresh kernels.
>>
>> I'll try to apply these patches, and I'll try to switch back to=20
>> kernels that were stable on some boxes.
>
> If you could bisect this it would be useful.  Basically we just need=20
> to determine where in the git history these issues started popping up=
=20
> so that we can then narrow down on the root cause.
>
> - Alex
