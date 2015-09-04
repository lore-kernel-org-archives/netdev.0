From: Sasha Levin <sasha.levin@oracle.com>
Subject: Re: [PATCH] RDS: verify the underlying transport exists before creating
 a connection
Date: Fri, 04 Sep 2015 15:44:24 -0400
Message-ID: <55E9F498.5000402@oracle.com>
References: <1441385019-27019-1-git-send-email-sasha.levin@oracle.com> <55E9D59E.4080103@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: rds-devel@oss.oracle.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: santosh shilimkar <santosh.shilimkar@oracle.com>,
	chien.yen@oracle.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55E9D59E.4080103@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/04/2015 01:32 PM, santosh shilimkar wrote:
> Sasha,
> 
> On 9/4/2015 9:43 AM, Sasha Levin wrote:
>> There was no verification that an underlying transport exists when creating
>> a connection, this would cause dereferencing a NULL ptr.
>>
>> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
>> ---
>>   net/rds/connection.c |    6 ++++++
>>   1 file changed, 6 insertions(+)
>>
>> diff --git a/net/rds/connection.c b/net/rds/connection.c
>> index a50e652..0218d81 100644
>> --- a/net/rds/connection.c
>> +++ b/net/rds/connection.c
>> @@ -189,6 +189,12 @@ new_conn:
>>           }
>>       }
>>
>> +    if (trans == NULL) {
>> +        kmem_cache_free(rds_conn_slab, conn);
>> +        conn = ERR_PTR(-ENODEV);
>> +        goto out;
>> +    }
>> +
> 
> Did you see the NULL oops in any tests ? The reason
> am asking this because callers of '__rds_conn_create()'
> are not passing the trans as null so that leaves with
> only the loopback case. In that case as well,
> rds_loop_transport is never going to be null.
> 
> The check is good but am curious whether we have a
> case which will hit this scenario.

This is the trace I have:


[135546.047719] kasan: GPF could be caused by NULL-ptr deref or user memory accessgeneral protection fault: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC KASAN
[135546.051270] Modules linked in:
[135546.051781] CPU: 4 PID: 15650 Comm: trinity-c4 Not tainted 4.2.0-next-20150902-sasha-00041-gbaa1222-dirty #2527
[135546.053217] task: ffff8800835bc000 ti: ffff8800bc708000 task.ti: ffff8800bc708000
[135546.054291] RIP: __rds_conn_create (net/rds/connection.c:194)
[135546.055666] RSP: 0018:ffff8800bc70fab0  EFLAGS: 00010202
[135546.056457] RAX: dffffc0000000000 RBX: 0000000000000f2c RCX: ffff8800835bc000
[135546.057494] RDX: 0000000000000007 RSI: ffff8800835bccd8 RDI: 0000000000000038
[135546.058530] RBP: ffff8800bc70fb18 R08: 0000000000000001 R09: 0000000000000000
[135546.059556] R10: ffffed014d7a3a23 R11: ffffed014d7a3a21 R12: 0000000000000000
[135546.060614] R13: 0000000000000001 R14: ffff8801ec3d0000 R15: 0000000000000000
[135546.061668] FS:  00007faad4ffb700(0000) GS:ffff880252000000(0000) knlGS:0000000000000000
[135546.062836] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[135546.063682] CR2: 000000000000846a CR3: 000000009d137000 CR4: 00000000000006a0
[135546.064723] Stack:
[135546.065048]  ffffffffafe2055c ffffffffafe23fc1 ffffed00493097bf ffff8801ec3d0008
[135546.066247]  0000000000000000 00000000000000d0 0000000000000000 ac194a24c0586342
[135546.067438]  1ffff100178e1f78 ffff880320581b00 ffff8800bc70fdd0 ffff880320581b00
[135546.068629] Call Trace:
[135546.069028] ? __rds_conn_create (include/linux/rcupdate.h:856 net/rds/connection.c:134)
[135546.069989] ? rds_message_copy_from_user (net/rds/message.c:298)
[135546.071021] rds_conn_create_outgoing (net/rds/connection.c:278)
[135546.071981] rds_sendmsg (net/rds/send.c:1058)
[135546.072858] ? perf_trace_lock (include/trace/events/lock.h:38)
[135546.073744] ? lockdep_init (kernel/locking/lockdep.c:3298)
[135546.074577] ? rds_send_drop_to (net/rds/send.c:976)
[135546.075508] ? __might_fault (./arch/x86/include/asm/current.h:14 mm/memory.c:3795)
[135546.076349] ? __might_fault (mm/memory.c:3795)
[135546.077179] ? rds_send_drop_to (net/rds/send.c:976)
[135546.078114] sock_sendmsg (net/socket.c:611 net/socket.c:620)
[135546.078856] SYSC_sendto (net/socket.c:1657)
[135546.079596] ? SYSC_connect (net/socket.c:1628)
[135546.080510] ? trace_dump_stack (kernel/trace/trace.c:1926)
[135546.081397] ? ring_buffer_unlock_commit (kernel/trace/ring_buffer.c:2479 kernel/trace/ring_buffer.c:2558 kernel/trace/ring_buffer.c:2674)
[135546.082390] ? trace_buffer_unlock_commit (kernel/trace/trace.c:1749)
[135546.083410] ? trace_event_raw_event_sys_enter (include/trace/events/syscalls.h:16)
[135546.084481] ? do_audit_syscall_entry (include/trace/events/syscalls.h:16)
[135546.085438] ? trace_buffer_unlock_commit (kernel/trace/trace.c:1749)
[135546.085515] rds_ib_laddr_check(): addr 36.74.25.172 ret -99 node type -1
[135546.087403] ? lock_is_held (kernel/locking/lockdep.c:3666)
[135546.088255] ? rcu_read_lock_sched_held (kernel/rcu/update.c:109)
[135546.089273] SyS_sendto (net/socket.c:1625)
[135546.090112] tracesys_phase2 (arch/x86/entry/entry_64.S:273)
[135546.090934] Code: 03 80 3c 02 00 0f 85 86 0b 00 00 48 8b 45 b8 48 8d 78 38 49 89 86 d8 00 00 00 48 b8 00 00 00 00 00 fc ff df 48 89 fa 48 c1 ea 03 <80> 3c 02 00 0f 85 70 0b 00 00 48 8b 45 b8 4c 89 f7 8b 75 c0 ff
All code
========
   0:   03 80 3c 02 00 0f       add    0xf00023c(%rax),%eax
   6:   85 86 0b 00 00 48       test   %eax,0x4800000b(%rsi)
   c:   8b 45 b8                mov    -0x48(%rbp),%eax
   f:   48 8d 78 38             lea    0x38(%rax),%rdi
  13:   49 89 86 d8 00 00 00    mov    %rax,0xd8(%r14)
  1a:   48 b8 00 00 00 00 00    movabs $0xdffffc0000000000,%rax
  21:   fc ff df
  24:   48 89 fa                mov    %rdi,%rdx
  27:   48 c1 ea 03             shr    $0x3,%rdx
  2b:*  80 3c 02 00             cmpb   $0x0,(%rdx,%rax,1)               <-- trapping instruction
  2f:   0f 85 70 0b 00 00       jne    0xba5
  35:   48 8b 45 b8             mov    -0x48(%rbp),%rax
  39:   4c 89 f7                mov    %r14,%rdi
  3c:   8b 75 c0                mov    -0x40(%rbp),%esi
  3f:   ff 00                   incl   (%rax)

Code starting with the faulting instruction
===========================================
   0:   80 3c 02 00             cmpb   $0x0,(%rdx,%rax,1)
   4:   0f 85 70 0b 00 00       jne    0xb7a
   a:   48 8b 45 b8             mov    -0x48(%rbp),%rax
   e:   4c 89 f7                mov    %r14,%rdi
  11:   8b 75 c0                mov    -0x40(%rbp),%esi
  14:   ff 00                   incl   (%rax)
[135546.095824] RIP __rds_conn_create (net/rds/connection.c:194)
[135546.096728]  RSP <ffff8800bc70fab0>


Thanks,
Sasha
