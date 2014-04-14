From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH] seccomp: fix populating a0-a5 syscall args in 32-bit
 x86 BPF
Date: Mon, 14 Apr 2014 13:13:45 -0700
Message-ID: <534C4179.7070704@amacapital.net>
References: <1397502179-15029-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	torvalds@linux-foundation.org,
	Alexei Starovoitov <ast@plumgrid.com>,
	Eric Paris <eparis@redhat.com>,
	James Morris <james.l.morris@oracle.com>,
	Kees Cook <keescook@chromium.org>
To: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1397502179-15029-1-git-send-email-dborkman@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/14/2014 12:02 PM, Daniel Borkmann wrote:
> Linus reports that on 32-bit x86 Chromium throws the following seccomp
> resp. audit log messages:
> 
>   audit: type=1326 audit(1397359304.356:28108): auid=500 uid=500
> gid=500 ses=2 subj=unconfined_u:unconfined_r:chrome_sandbox_t:s0-s0:c0.c1023
> pid=3677 comm="chrome" exe="/opt/google/chrome/chrome" sig=0
> syscall=172 compat=0 ip=0xb2dd9852 code=0x30000
> 
>   audit: type=1326 audit(1397359304.356:28109): auid=500 uid=500
> gid=500 ses=2 subj=unconfined_u:unconfined_r:chrome_sandbox_t:s0-s0:c0.c1023
> pid=3677 comm="chrome" exe="/opt/google/chrome/chrome" sig=0 syscall=5
> compat=0 ip=0xb2dd9852 code=0x50000
> 
> These audit messages are being triggered via audit_seccomp() through
> __secure_computing() in seccomp mode (BPF) filter with seccomp return
> codes 0x30000 (== SECCOMP_RET_TRAP) and 0x50000 (== SECCOMP_RET_ERRNO)
> during filter runtime. Moreover, Linus reports that x86_64 Chromium
> seems fine.
> 
> The underlying issue that explains this is that the implementation of
> populate_seccomp_data() is wrong. Our seccomp data structure sd that
> is being shared with user ABI is:
> 
>   struct seccomp_data {
>     int nr;
>     __u32 arch;
>     __u64 instruction_pointer;
>     __u64 args[6];
>   };
> 
> Therefore, a simple cast to 'unsigned long *' for storing the value of
> the syscall argument via syscall_get_arguments() is just wrong as on
> 32-bit x86 (or any other 32bit arch), it would result in storing a0-a5
> at wrong offsets in args[] member, and thus i) could leak stack memory
> to user space and ii) tampers with the logic of seccomp BPF programs
> that read out and check for syscall arguments:
> 
>   syscall_get_arguments(task, regs, 0, 1, (unsigned long *) &sd->args[0]);

I think this description is wrong.  (unsigned long *) &sd->args[1] is
the right location, at least on 32-bit little-endian architectures.
((unsigned long *) &sd->args)[1] would be wrong, as I think you've
described, but that's not what the code does.

I think the real problem is that 32-bit BE is hosed, and on 32-bit LE,
the high bits aren't getting cleared.

I would make this change conditional on BITS_PER_LONG != 8, since this
probably severely pessimizes architectures like ia-64.

> 
> Tested on 32-bit x86 with Google Chrome, unfortunately only via remote
> test machine through slow ssh X forwarding, but it fixes the issue on
> my side. So fix it up by storing args in type correct variables, gcc
> is clever and optimizes the copy away in other cases, e.g. x86_64.
> 
> Fixes: bd4cf0ed331a ("net: filter: rework/optimize internal BPF interpreter's instruction set")
> Reported-and-bisected-by: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Eric Paris <eparis@redhat.com>
> Cc: James Morris <james.l.morris@oracle.com>
> Cc: Kees Cook <keescook@chromium.org>
> ---
>  Dave, do you want to pick this up?
> 
>  kernel/seccomp.c | 17 ++++++++---------
>  1 file changed, 8 insertions(+), 9 deletions(-)
> 
> diff --git a/kernel/seccomp.c b/kernel/seccomp.c
> index d8d046c..590c379 100644
> --- a/kernel/seccomp.c
> +++ b/kernel/seccomp.c
> @@ -69,18 +69,17 @@ static void populate_seccomp_data(struct seccomp_data *sd)
>  {
>  	struct task_struct *task = current;
>  	struct pt_regs *regs = task_pt_regs(task);
> +	unsigned long args[6];
>  
>  	sd->nr = syscall_get_nr(task, regs);
>  	sd->arch = syscall_get_arch();
> -
> -	/* Unroll syscall_get_args to help gcc on arm. */
> -	syscall_get_arguments(task, regs, 0, 1, (unsigned long *) &sd->args[0]);
> -	syscall_get_arguments(task, regs, 1, 1, (unsigned long *) &sd->args[1]);
> -	syscall_get_arguments(task, regs, 2, 1, (unsigned long *) &sd->args[2]);
> -	syscall_get_arguments(task, regs, 3, 1, (unsigned long *) &sd->args[3]);
> -	syscall_get_arguments(task, regs, 4, 1, (unsigned long *) &sd->args[4]);
> -	syscall_get_arguments(task, regs, 5, 1, (unsigned long *) &sd->args[5]);
> -
> +	syscall_get_arguments(task, regs, 0, 6, args);
> +	sd->args[0] = args[0];
> +	sd->args[1] = args[1];
> +	sd->args[2] = args[2];
> +	sd->args[3] = args[3];
> +	sd->args[4] = args[4];
> +	sd->args[5] = args[5];
>  	sd->instruction_pointer = KSTK_EIP(task);
>  }
>  
> 
