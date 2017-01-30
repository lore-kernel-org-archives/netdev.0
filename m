From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH net-next 1/3] trace: add variant without spacing in
 trace_print_hex_seq
Date: Mon, 30 Jan 2017 15:44:25 -0500
Message-ID: <20170130154425.581bf631@gandalf.local.home>
References: <cover.1485306168.git.daniel@iogearbox.net>
        <f860273ed9fd0c423f4d1ee2ab93565992d76ff4.1485306168.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ast@kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Arnaldo Carvalho de Melo <acme@redhat.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <f860273ed9fd0c423f4d1ee2ab93565992d76ff4.1485306168.git.daniel@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 25 Jan 2017 02:28:16 +0100
Daniel Borkmann <daniel@iogearbox.net> wrote:

> For upcoming tracepoint support for BPF, we want to dump the program's
> tag. Format should be similar to __print_hex(), but without spacing.
> Add a __print_hex_str() variant for exactly that purpose that reuses
> trace_print_hex_seq().
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Steven Rostedt <rostedt@goodmis.org>
> Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
> ---
>  include/linux/trace_events.h | 3 ++-
>  include/trace/trace_events.h | 8 +++++++-
>  kernel/trace/trace_output.c  | 7 ++++---
>  3 files changed, 13 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/trace_events.h b/include/linux/trace_events.h
> index be00761..cfa475a 100644
> --- a/include/linux/trace_events.h
> +++ b/include/linux/trace_events.h
> @@ -33,7 +33,8 @@ const char *trace_print_bitmask_seq(struct trace_seq *p, void *bitmask_ptr,
>  				    unsigned int bitmask_size);
>  
>  const char *trace_print_hex_seq(struct trace_seq *p,
> -				const unsigned char *buf, int len);
> +				const unsigned char *buf, int len,
> +				bool spacing);

Hmm, "spacing" doesn't really mean much. What about the invert of it,
and have "concatenate"?

>  
>  const char *trace_print_array_seq(struct trace_seq *p,
>  				   const void *buf, int count,
> diff --git a/include/trace/trace_events.h b/include/trace/trace_events.h
> index 467e12f..9f68462 100644
> --- a/include/trace/trace_events.h
> +++ b/include/trace/trace_events.h
> @@ -297,7 +297,12 @@
>  #endif
>  
>  #undef __print_hex
> -#define __print_hex(buf, buf_len) trace_print_hex_seq(p, buf, buf_len)
> +#define __print_hex(buf, buf_len)					\
> +	trace_print_hex_seq(p, buf, buf_len, true)
> +
> +#undef __print_hex_str
> +#define __print_hex_str(buf, buf_len)					\
> +	trace_print_hex_seq(p, buf, buf_len, false)
>  
>  #undef __print_array
>  #define __print_array(array, count, el_size)				\
> @@ -711,6 +716,7 @@
>  #undef __print_flags
>  #undef __print_symbolic
>  #undef __print_hex
> +#undef __print_hex_str
>  #undef __get_dynamic_array
>  #undef __get_dynamic_array_len
>  #undef __get_str
> diff --git a/kernel/trace/trace_output.c b/kernel/trace/trace_output.c
> index 5d33a73..30a144b1 100644
> --- a/kernel/trace/trace_output.c
> +++ b/kernel/trace/trace_output.c
> @@ -163,14 +163,15 @@ enum print_line_t trace_print_printk_msg_only(struct trace_iterator *iter)
>  EXPORT_SYMBOL_GPL(trace_print_bitmask_seq);
>  

With the addition of this boolean parameter, this function shold
probably have a kernel doc header, that can explain the parameters.

-- Steve

>  const char *
> -trace_print_hex_seq(struct trace_seq *p, const unsigned char *buf, int buf_len)
> +trace_print_hex_seq(struct trace_seq *p, const unsigned char *buf, int buf_len,
> +		    bool spacing)
>  {
>  	int i;
>  	const char *ret = trace_seq_buffer_ptr(p);
>  
>  	for (i = 0; i < buf_len; i++)
> -		trace_seq_printf(p, "%s%2.2x", i == 0 ? "" : " ", buf[i]);
> -
> +		trace_seq_printf(p, "%s%2.2x", !spacing || i == 0 ? "" : " ",
> +				 buf[i]);
>  	trace_seq_putc(p, 0);
>  
>  	return ret;
