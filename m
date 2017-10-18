From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v6 1/5] bpf: Add file mode configuration into
 bpf maps
Date: Wed, 18 Oct 2017 15:52:24 +0200
Message-ID: <59E75C98.5080603@iogearbox.net>
References: <20171016191135.8046-1-chenbofeng.kernel@gmail.com> <20171016191135.8046-2-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeffrey Vander Stoep <jeffv@google.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        lorenzo@google.com, Stephen Smalley <sds@tycho.nsa.gov>,
        James Morris <james.l.morris@oracle.com>,
        Paul Moore <paul@paul-moore.com>,
        Chenbo Feng <fengc@google.com>
To: Chenbo Feng <chenbofeng.kernel@gmail.com>, netdev@vger.kernel.org,
        SELinux <Selinux@tycho.nsa.gov>,
        linux-security-module@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20171016191135.8046-2-chenbofeng.kernel@gmail.com>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey Chenbo,

there's still one thing I noticed later one; would have sent a
follow-up, but as you need to respin anyway for the build issue,
here's what is still missing uapi-wise:

On 10/16/2017 09:11 PM, Chenbo Feng wrote:
[...]
> +int bpf_get_file_flag(int flags)
> +{
> +	if ((flags & BPF_F_RDONLY) && (flags & BPF_F_WRONLY))
> +		return -EINVAL;
> +	if (flags & BPF_F_RDONLY)
> +		return O_RDONLY;
> +	if (flags & BPF_F_WRONLY)
> +		return O_WRONLY;
> +	return O_RDWR;
>   }
[...]
> -#define BPF_OBJ_LAST_FIELD bpf_fd
> +#define BPF_OBJ_LAST_FIELD file_flags
>
>   static int bpf_obj_pin(const union bpf_attr *attr)
>   {
> -	if (CHECK_ATTR(BPF_OBJ))
> +	if (CHECK_ATTR(BPF_OBJ) || attr->file_flags != 0)
>   		return -EINVAL;
>
>   	return bpf_obj_pin_user(attr->bpf_fd, u64_to_user_ptr(attr->pathname));
> @@ -1126,7 +1184,8 @@ static int bpf_obj_get(const union bpf_attr *attr)
>   	if (CHECK_ATTR(BPF_OBJ) || attr->bpf_fd != 0)

Here, we also need to check and bail out on ...

attr->file_flags & ~(BPF_F_RDONLY | BPF_F_WRONLY)

... otherwise we cannot extend it with more flags in future. Basically
same principle for mask check you do on map creation, but not yet here.

The same is needed in bpf_map_get_fd_by_id(), too.

The bpf_prog_get_fd_by_id() is covered since BPF_PROG_GET_FD_BY_ID_LAST_FIELD
still points to prog_id, so ok.

>   		return -EINVAL;
> -	return bpf_obj_get_user(u64_to_user_ptr(attr->pathname));
> +	return bpf_obj_get_user(u64_to_user_ptr(attr->pathname),
> +				attr->file_flags);
>   }
>
