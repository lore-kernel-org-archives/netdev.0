From: Xin Long <lucien.xin@gmail.com>
Subject: Re: WARNING in refcount_sub_and_test
Date: Fri, 27 Oct 2017 02:39:29 +0800
Message-ID: <CADvbK_c=KtKtUTW+XkyBo52D2-Bqge--z_MBOhaFqEGUoayGVA@mail.gmail.com>
References: <001a11441d867b940f055c4c0b40@google.com> <CAOm2TWwoJhsT==euSyC0EDCbWXzTVWBBmvbX8HgmdjxvW0wVbw@mail.gmail.com>
 <CACT4Y+bWsMoMOY6A5f0RLqRBGKwmELCrQUJhxPzkpHasdrn=5A@mail.gmail.com>
 <CADvbK_eHVY8LvSReDiXmt3qxOWdLgQQ1ugkZi6C3DrskuUoBtg@mail.gmail.com>
 <CACT4Y+YegVs8c75nJ5caFPiz8wctj_7n-C3F=RC5PVE1R2uDOQ@mail.gmail.com> <CADvbK_dNGc5K1+Ne-JWaLGn1o4EsmEw60GLk92jJ2C3DWuqdpA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: ChunYu Wang <chunwang@redhat.com>,
        syzbot
        <bot+a004c8dcbae7c160bf1bbd6e6af2e9cf4fa54f84@syzkaller.appspotmail.com>,
        David Miller <davem@davemloft.net>,
        LKML <linux-kernel@vger.kernel.org>, linux-sctp@vger.kernel.org,
        netdev <netdev@vger.kernel.org>,
        Neil Horman <nhorman@tuxdriver.com>,
        syzkaller-bugs@googlegroups.com,
        Vladislav Yasevich <vyasevich@gmail.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CADvbK_dNGc5K1+Ne-JWaLGn1o4EsmEw60GLk92jJ2C3DWuqdpA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 27, 2017 at 12:56 AM, Xin Long <lucien.xin@gmail.com> wrote:
> On Fri, Oct 27, 2017 at 12:13 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
>> On Thu, Oct 26, 2017 at 5:49 PM, Xin Long <lucien.xin@gmail.com> wrote:
>>> On Thu, Oct 26, 2017 at 10:49 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
>>>> On Thu, Oct 26, 2017 at 10:53 AM, ChunYu Wang <chunwang@redhat.com> wrote:
>>>>> Hi all,
>>>>>
>>>>> I am failed to reproduce it on target kernel with the reproducer file
>>>>> or replaying the target syzkaller description log file, do I made
>>>>> something wrong or there exists more subjects then the line in
>>>>> repro.txt:
>>>>>
>>>>> #{Threaded:true Collide:true Repeat:false Procs:1 Sandbox:namespace
>>>>> Fault:false FaultCall:-1 FaultNth:0 EnableTun:false UseTmpDir:true
>>>>> HandleSegv:false WaitRepeat:false Debug:false Repro:false}
>>>>
>>>>
>>>> Hi ChunYu,
>>>>
>>>> I've just re-tested the C repro and was able to trigger the bug in a second.
>>>> I've checked out 49ca1943a7adb429b11b8e05d81bc821694b76c7, copied the
>>>> provided config, run make olddefconfig, built with gcc-7 (you can get
>>>> the exact one here
>>>> https://storage.googleapis.com/syzkaller/gcc-7.tar.gz). Then run in
>>>> qemu (most of the flags are probably irrelevant):
>>>>
>>>> qemu-system-x86_64 -hda wheezy.img -net
>>>> user,host=10.0.2.10,hostfwd=tcp::10022-:22 -net nic -nographic -kernel
>>>> arch/x86/boot/bzImage -append "kvm-intel.nested=1
>>>> kvm-intel.unrestricted_guest=1 kvm-intel.ept=1
>>>> kvm-intel.flexpriority=1 kvm-intel.vpid=1
>>>> kvm-intel.emulate_invalid_guest_state=1 kvm-intel.eptad=1
>>>> kvm-intel.enable_shadow_vmcs=1 kvm-intel.pml=1
>>>> kvm-intel.enable_apicv=1 console=ttyS0 root=/dev/sda
>>>> earlyprintk=serial slub_debug=UZ vsyscall=native rodata=n oops=panic
>>>> panic_on_warn=1 panic=86400" -enable-kvm -pidfile vm_pid -m 2G -smp 4
>>>> -cpu host -usb -usbdevice mouse -usbdevice tablet -soundhw all
>>> Just wondering where we can get wheezy.img, if I can't download
>>> somewhere, can you provide one if possible ?
>>>
>>> I made some imgs before, with kernel built with the .config mail-list
>>> usually gave, the guest always failed to boot.
>>
>> Makes sense. Added image/key links here:
>> https://github.com/google/syzkaller/blob/master/docs/syzbot.md#crash-does-not-reproduce
>>
>> Here are commands to start qemu, ssh into the VM. This just worked for
>> me to reproduce the crash.
>>
>> qemu-system-x86_64 -hda wheezy.img -net
>> user,host=10.0.2.10,hostfwd=tcp::10022-:22 -net nic -nographic -kernel
>> arch/x86/boot/bzImage -append "kvm-intel.nested=1
>> kvm-intel.unrestricted_guest=1 kvm-intel.ept=1
>> kvm-intel.flexpriority=1 kvm-intel.vpid=1
>> kvm-intel.emulate_invalid_guest_state=1 kvm-intel.eptad=1
>> kvm-intel.enable_shadow_vmcs=1 kvm-intel.pml=1
>> kvm-intel.enable_apicv=1 console=ttyS0 root=/dev/sda
>> earlyprintk=serial vsyscall=native rodata=n oops=panic panic_on_warn=1
>> panic=86400" -enable-kvm -m 2G -smp 4 -cpu host -usb -usbdevice mouse
>> -usbdevice tablet -soundhw all
>>
>> ssh -i wheezy.img.key -p 10022 -o UserKnownHostsFile=/dev/null -o
>> StrictHostKeyChecking=no -o IdentitiesOnly=yes root@localhost
> Works, and be able to reproduce the issue. Thanks Dmitry.
Fix for this crash:
@@ -8276,6 +8279,7 @@ static void sctp_sock_migrate(struct sock
*oldsk, struct sock *newsk,
        struct sk_buff *skb, *tmp;
        struct sctp_ulpevent *event;
        struct sctp_bind_hashbucket *head;
+       struct sctp_chunk *chunk;

        /* Migrate socket buffer sizes and all the socket level options to the
         * new socket.
@@ -8379,7 +8383,12 @@ static void sctp_sock_migrate(struct sock
*oldsk, struct sock *newsk,
         * paths won't try to lock it and then oldsk.
         */
        lock_sock_nested(newsk, SINGLE_DEPTH_NESTING);
+        list_for_each_entry(chunk, &assoc->outqueue.out_chunk_list, list)
+               skb_orphan(chunk->skb);
+
        sctp_assoc_migrate(assoc, newsk);
+        list_for_each_entry(chunk, &assoc->outqueue.out_chunk_list, list)
+               sctp_set_owner_w(chunk);


Other lists in assoc->outqueue probably need to do the similar, will
check for sure later.
