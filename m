From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v2 net-next 1/2] lib: introduce strncpy_from_unsafe()
Date: Fri, 28 Aug 2015 17:48:13 -0400
Message-ID: <20150828174813.23e6e78b@gandalf.local.home>
References: <1440791509-5450-1-git-send-email-ast@plumgrid.com>
	<1440791509-5450-2-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	Wang Nan <wangnan0@huawei.com>, He Kuang <hekuang@huawei.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440791509-5450-2-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 28 Aug 2015 12:51:48 -0700
Alexei Starovoitov <ast@plumgrid.com> wrote:

>  EXPORT_SYMBOL(strncpy_from_user);
> +
> +/**
> + * strncpy_from_unsafe: - Copy a NUL terminated string from unsafe address.
> + * @dst:   Destination address, in kernel space.  This buffer must be at
> + *         least @count bytes long.
> + * @src:   Unsafe address.
> + * @count: Maximum number of bytes to copy, including the trailing NUL.
> + *
> + * Copies a NUL-terminated string from unsafe address to kernel buffer.
> + *
> + * On success, returns the length of the string (not including the trailing
> + * NUL).

I think it includes the NUL.

> + *
> + * If access fails, returns -EFAULT (some data may have been copied).
> + *
> + * If @count is smaller than the length of the string, copies @count bytes
> + * and returns @count.
> + */
> +long strncpy_from_unsafe(char *dst, const void *unsafe_addr, long count)
> +{
> +	mm_segment_t old_fs = get_fs();
> +	const void *src = unsafe_addr;

src = unsafe_addr = 0x100;

*unsafe_addr = "1\0";

> +	long ret;
> +
> +	if (unlikely(count <= 0))
> +		return 0;
> +
> +	set_fs(KERNEL_DS);
> +	pagefault_disable();
> +
> +	do {
> +		ret = __copy_from_user_inatomic(dst++,
> +						(const void __user __force *)src++, 1);

First loop:

  dst[-1] = '1'
  src = 0x101

Second loop:

  dst[-1] = '\0'
  src = 0x102


> +	} while (dst[-1] && ret == 0 && src - unsafe_addr < count);
> +
> +	dst[-1] = '\0';
> +	pagefault_enable();
> +	set_fs(old_fs);
> +
> +	return ret < 0 ? ret : src - unsafe_addr;

  src - unsafe_addr = 0x102 - 0x100 = 2

Included the NUL.

-- Steve

> +}
