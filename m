From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 1/3] bpf: introduce current->pid, tgid, uid,
 gid, comm accessors
Date: Fri, 12 Jun 2015 15:44:43 -0700
Message-ID: <557B60DB.5030200@plumgrid.com>
References: <1434145226-17892-1-git-send-email-ast@plumgrid.com> <1434145226-17892-2-git-send-email-ast@plumgrid.com> <CALCETrUidQ9ig-xZrAFX8_==aVbDNKU-GfeYNMsT6uHugqSydg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Wang Nan <wangnan0@huawei.com>, Li Zefan <lizefan@huawei.com>,
	Daniel Wagner <daniel.wagner@bmw-carit.de>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALCETrUidQ9ig-xZrAFX8_==aVbDNKU-GfeYNMsT6uHugqSydg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/12/15 3:08 PM, Andy Lutomirski wrote:
> On Fri, Jun 12, 2015 at 2:40 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
>> eBPF programs attached to kprobes need to filter based on
>> current->pid, uid and other fields, so introduce helper functions:
>>
>> u64 bpf_get_current_pid_tgid(void)
>> Return: current->tgid << 32 | current->pid
>>
>> u64 bpf_get_current_uid_gid(void)
>> Return: current_gid << 32 | current_uid
>
> How does this work wrt namespaces,

from_kuid(current_user_ns(), uid)

 > and why the weird packing?

to minimize number of calls.

We've considered several alternatives.
1. 5 different helpers
   Cons: every call adds performance overhead

2a: single helper that populates 'struct bpf_task_info'
   and uses 'flags' with bit per field.
+struct bpf_task_info {
+       __u32 pid;
+       __u32 tgid;
+       __u32 uid;
+       __u32 gid;
+       char comm[16];
+};
bpf_get_current_task_info(task_info, size, flags)
bit 0 - fill in pid
bit 1 - fill in tgid
   Pros: single helper
   Cons: ugly to use and a lot of compares in the helper
   itself (two compares for each field)

2b. single helper that populates 'struct bpf_task_info'
   and uses 'size' to tell how many fields to fill in.
bpf_get_current_task_info(task_info, size);
+       if (size >= offsetof(struct bpf_task_info, pid) + sizeof(info->pid))
+               info->pid = task->pid;
+       if (size >= offsetof(struct bpf_task_info, tgid) + 
sizeof(info->tgid))
+               info->tgid = task->tgid;

   Pros: single call (with single compare per field).
   Cons: still hard to use when only uid is needed.

These three helpers looked as the best balance between
performance and usability.
