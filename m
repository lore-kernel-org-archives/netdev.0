From: Vegard Nossum <vegard.nossum@oracle.com>
Subject: Re: [PATCH] inet: sanitize socket() protocol value
Date: Thu, 17 Dec 2015 02:05:01 +0100
Message-ID: <56720A3D.9030002@oracle.com>
References: <1450313821-27217-1-git-send-email-vegard.nossum@oracle.com>
 <CANn89iKbfmFQrQBJ01Q-fz0dF2b+qaztpDt8axh8C8PR2MvmAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANn89iKbfmFQrQBJ01Q-fz0dF2b+qaztpDt8axh8C8PR2MvmAg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/17/2015 02:01 AM, Eric Dumazet wrote:
> On Wed, Dec 16, 2015 at 4:57 PM, Vegard Nossum <vegard.nossum@oracle.com> wrote:
>> If you create a raw socket with a protocol of e.g. 0x10000, then
>> inet_sk(sk)->inet_num will get set to 0 since it only has room for 16
>> bits. This causes problems further down the line as lots of code makes
>> assumptions about ->inet_num, for example connect()...inet_autobind()
>> will attempt to call sk->sk_prot->get_port() which is invalid:
>>
>>    BUG: unable to handle kernel NULL pointer dereference at           (null)
>>    IP: [<          (null)>]           (null)
>>    PGD 19ea0067 PUD 19d3f067 PMD 0
>>    Oops: 0010 [#1] SMP
>>    CPU: 1 PID: 849 Comm: a.out Not tainted 4.4.0-rc4+ #287
>>    task: ffff880019a12640 ti: ffff88000008c000 task.ti: ffff88000008c000
>>    RIP: 0010:[<0000000000000000>]  [<          (null)>]           (null)
>>    RSP: 0018:ffff88000008fe50  EFLAGS: 00010246
>>    RAX: ffffffff81cc61f0 RBX: ffff880019d2ca80 RCX: 0000000000000802
>>    RDX: 0000000000000001 RSI: 0000000000000000 RDI: ffff880019d2ca80
>>    RBP: ffff88000008fe60 R08: 00007f0e6b132e80 R09: ffff880019d2ca80
>>    R10: ffff88001a7a72e0 R11: ffff880019a12640 R12: 000000000000000b
>>    R13: 0000000000400644 R14: 0000000000000000 R15: 0000000000000000
>>    FS:  00007f0e6b355740(0000) GS:ffff88001a900000(0000) knlGS:0000000000000000
>>    CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>>    CR2: 0000000000000000 CR3: 0000000019d3d000 CR4: 00000000001406a0
>>    Stack:
>>     ffffffff815f1c69 ffff880019d2ca80 ffff88000008fe88 ffffffff815f1cde
>>     0000000b0000000b ffff88000008fea0 ffff880019484000 ffff88000008ff38
>>     ffffffff8156f310 0000000000000000 2a2a2a2a2a2a2a2a ffffffff8100002a
>>    Call Trace:
>>     [<ffffffff815f1c69>] ? inet_autobind+0x23/0x50
>>     [<ffffffff815f1cde>] inet_dgram_connect+0x48/0x64
>>     [<ffffffff8156f310>] SYSC_connect+0x84/0xae
>>     [<ffffffff8156f3ed>] ? sock_alloc_file+0xb3/0x108
>>     [<ffffffff81132021>] ? fd_install+0x20/0x22
>>     [<ffffffff815700d2>] ? SYSC_socket+0x62/0x90
>>     [<ffffffff81570318>] SyS_connect+0x9/0xb
>>     [<ffffffff816fb86e>] entry_SYSCALL_64_fastpath+0x12/0x71
>>    Code:  Bad RIP value.
>>    RIP  [<          (null)>]           (null)
>>     RSP <ffff88000008fe50>
>>    CR2: 0000000000000000
>>    ---[ end trace bd60b4fe2edc2537 ]---
>>
>> Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>
>> Cc: Eric Dumazet <edumazet@google.com>
>> Cc: <stable@vger.kernel.org>
>> ---
>>   net/ipv4/af_inet.c | 6 ++++++
>>   1 file changed, 6 insertions(+)
>>
>> diff --git net/ipv4/af_inet.c net/ipv4/af_inet.c
>> index 11c4ca1..4e1583a 100644
>> --- net/ipv4/af_inet.c
>> +++ net/ipv4/af_inet.c
>> @@ -316,6 +316,12 @@ lookup_protocol:
>>
>>          WARN_ON(!answer_prot->slab);
>>
>> +       /* Check that the protocol we were given will actually fit in
>> +        * inet->inet_num. */
>> +       err = -EINVAL;
>> +       if (protocol != (typeof(inet->inet_num)) protocol)
>> +               goto out;
>> +
>>          err = -ENOBUFS;
>>          sk = sk_alloc(net, PF_INET, GFP_KERNEL, answer_prot, kern);
>>          if (!sk)
>> --
>> 1.9.1
>>
>
> It looks already fixed in a better way (IPv6, ...)
>
> http://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=79462ad02e861803b3840cc782248c7359451cd9

Ha, sorry, I missed that!

Thanks for the quick response.


Vegard
