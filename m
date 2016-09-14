From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC v3 22/22] samples/landlock: Add sandbox example
Date: Wed, 14 Sep 2016 14:24:43 -0700
Message-ID: <20160914212442.GD57174@ast-mbp.thefacebook.com>
References: <20160914072415.26021-1-mic@digikod.net>
 <20160914072415.26021-23-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Arnd Bergmann <arnd@arndb.de>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>,
        David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        Elena Reshetova <elena.reshetova@intel.com>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Kees Cook <keescook@chromium.org>,
        Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
        Will Drewry <wad@chromium.org>,
        kernel-hardening@lists.openwall.com, linux-api@vger.kernel.org,
        linux-security-module@vger.kern
To: =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:33386 "EHLO
        mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1764218AbcINVYt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 17:24:49 -0400
Content-Disposition: inline
In-Reply-To: <20160914072415.26021-23-mic@digikod.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 14, 2016 at 09:24:15AM +0200, Mickaël Salaün wrote:
> Add a basic sandbox tool to create a process isolated from some part of
> the system. This can depend of the current cgroup.
> 
> Example with the current process hierarchy (seccomp):
> 
>   $ ls /home
>   user1
>   $ LANDLOCK_ALLOWED='/bin:/lib:/usr:/tmp:/proc/self/fd/0' \
>       ./samples/landlock/sandbox /bin/sh -i
>   Launching a new sandboxed process.
>   $ ls /home
>   ls: cannot open directory '/home': Permission denied
> 
> Example with a cgroup:
> 
>   $ mkdir /sys/fs/cgroup/sandboxed
>   $ ls /home
>   user1
>   $ LANDLOCK_CGROUPS='/sys/fs/cgroup/sandboxed' \
>       LANDLOCK_ALLOWED='/bin:/lib:/usr:/tmp:/proc/self/fd/0' \
>       ./samples/landlock/sandbox
>   Ready to sandbox with cgroups.
>   $ ls /home
>   user1
>   $ echo $$ > /sys/fs/cgroup/sandboxed/cgroup.procs
>   $ ls /home
>   ls: cannot open directory '/home': Permission denied
> 
> Changes since v2:
> * use BPF_PROG_ATTACH for cgroup handling
> 
> Signed-off-by: Mickaël Salaün <mic@digikod.net>
...
> +	struct bpf_insn hook_path[] = {
> +		/* specify an option, if any */
> +		BPF_MOV32_IMM(BPF_REG_1, 0),
> +		/* handles to compare with */
> +		BPF_LD_MAP_FD(BPF_REG_2, map_fs),
> +		BPF_MOV64_IMM(BPF_REG_3, BPF_MAP_ARRAY_OP_OR),
> +		/* hook argument (struct file) */
> +		BPF_LDX_MEM(BPF_DW, BPF_REG_4, BPF_REG_6, offsetof(struct
> +					landlock_data, args[0])),
> +		/* checker function */
> +		BPF_EMIT_CALL(BPF_FUNC_landlock_cmp_fs_beneath_with_struct_file),

the example is sweet!
Since only that helper is used, could you skip the other one
from the patches (for now) ?
