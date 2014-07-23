From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH RFC v2 net-next 13/16] tracing: allow eBPF programs to be
 attached to events
Date: Wed, 23 Jul 2014 16:46:43 -0700
Message-ID: <CAGXu5jJyw19h0+AwZEWSJt7hGnkRHAsf8fYim=XLzA-LH=svjw@mail.gmail.com>
References: <1405657206-12060-1-git-send-email-ast@plumgrid.com>
	<1405657206-12060-14-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405657206-12060-14-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 17, 2014 at 9:20 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> User interface:
> fd = open("/sys/kernel/debug/tracing/__event__/filter")
>
> write(fd, "bpf_123")
>
> where 123 is process local FD associated with eBPF program previously loaded.
> __event__ is static tracepoint event.
> (kprobe events will be supported in the future patches)
> Once program is successfully attached to tracepoint event, the tracepoint
> will be auto-enabled
>
> close(fd)
> auto-disables tracepoint event and detaches eBPF program from it
>
> eBPF programs can call in-kernel helper functions to:
> - lookup/update/delete elements in maps
> - memcmp
> - trace_printk
> - load_pointer
> - dump_stack

Ah, this must be the pointer leaking you mentioned. :)

>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> ---
>  include/linux/ftrace_event.h       |    5 +
>  include/trace/bpf_trace.h          |   29 +++++
>  include/trace/ftrace.h             |   10 ++
>  include/uapi/linux/bpf.h           |    5 +
>  kernel/trace/Kconfig               |    1 +
>  kernel/trace/Makefile              |    1 +
>  kernel/trace/bpf_trace.c           |  212 ++++++++++++++++++++++++++++++++++++
>  kernel/trace/trace.h               |    3 +
>  kernel/trace/trace_events.c        |   36 +++++-
>  kernel/trace/trace_events_filter.c |   72 +++++++++++-
>  10 files changed, 372 insertions(+), 2 deletions(-)
>  create mode 100644 include/trace/bpf_trace.h
>  create mode 100644 kernel/trace/bpf_trace.c
>
> diff --git a/include/linux/ftrace_event.h b/include/linux/ftrace_event.h
> index cff3106ffe2c..de313bd9a434 100644
> --- a/include/linux/ftrace_event.h
> +++ b/include/linux/ftrace_event.h
> @@ -237,6 +237,7 @@ enum {
>         TRACE_EVENT_FL_WAS_ENABLED_BIT,
>         TRACE_EVENT_FL_USE_CALL_FILTER_BIT,
>         TRACE_EVENT_FL_TRACEPOINT_BIT,
> +       TRACE_EVENT_FL_BPF_BIT,
>  };
>
>  /*
> @@ -259,6 +260,7 @@ enum {
>         TRACE_EVENT_FL_WAS_ENABLED      = (1 << TRACE_EVENT_FL_WAS_ENABLED_BIT),
>         TRACE_EVENT_FL_USE_CALL_FILTER  = (1 << TRACE_EVENT_FL_USE_CALL_FILTER_BIT),
>         TRACE_EVENT_FL_TRACEPOINT       = (1 << TRACE_EVENT_FL_TRACEPOINT_BIT),
> +       TRACE_EVENT_FL_BPF              = (1 << TRACE_EVENT_FL_BPF_BIT),
>  };
>
>  struct ftrace_event_call {
> @@ -536,6 +538,9 @@ event_trigger_unlock_commit_regs(struct ftrace_event_file *file,
>                 event_triggers_post_call(file, tt);
>  }
>
> +struct bpf_context;
> +void trace_filter_call_bpf(struct event_filter *filter, struct bpf_context *ctx);
> +
>  enum {
>         FILTER_OTHER = 0,
>         FILTER_STATIC_STRING,
> diff --git a/include/trace/bpf_trace.h b/include/trace/bpf_trace.h
> new file mode 100644
> index 000000000000..2122437f1317
> --- /dev/null
> +++ b/include/trace/bpf_trace.h
> @@ -0,0 +1,29 @@
> +/* Copyright (c) 2011-2014 PLUMgrid, http://plumgrid.com
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of version 2 of the GNU General Public
> + * License as published by the Free Software Foundation.
> + */
> +#ifndef _LINUX_KERNEL_BPF_TRACE_H
> +#define _LINUX_KERNEL_BPF_TRACE_H
> +
> +/* For tracing filters save first six arguments of tracepoint events.
> + * On 64-bit architectures argN fields will match one to one to arguments passed
> + * to tracepoint events.
> + * On 32-bit architectures u64 arguments to events will be seen into two
> + * consecutive argN, argN+1 fields. Pointers, u32, u16, u8, bool types will
> + * match one to one
> + */
> +struct bpf_context {
> +       unsigned long arg1;
> +       unsigned long arg2;
> +       unsigned long arg3;
> +       unsigned long arg4;
> +       unsigned long arg5;
> +       unsigned long arg6;
> +};
> +
> +/* call from ftrace_raw_event_*() to copy tracepoint arguments into ctx */
> +void populate_bpf_context(struct bpf_context *ctx, ...);
> +
> +#endif /* _LINUX_KERNEL_BPF_TRACE_H */
> diff --git a/include/trace/ftrace.h b/include/trace/ftrace.h
> index 26b4f2e13275..ad4987ac68bb 100644
> --- a/include/trace/ftrace.h
> +++ b/include/trace/ftrace.h
> @@ -17,6 +17,7 @@
>   */
>
>  #include <linux/ftrace_event.h>
> +#include <trace/bpf_trace.h>
>
>  /*
>   * DECLARE_EVENT_CLASS can be used to add a generic function
> @@ -634,6 +635,15 @@ ftrace_raw_event_##call(void *__data, proto)                               \
>         if (ftrace_trigger_soft_disabled(ftrace_file))                  \
>                 return;                                                 \
>                                                                         \
> +       if (unlikely(ftrace_file->flags & FTRACE_EVENT_FL_FILTERED) &&  \
> +           unlikely(ftrace_file->event_call->flags & TRACE_EVENT_FL_BPF)) { \
> +               struct bpf_context __ctx;                               \
> +                                                                       \
> +               populate_bpf_context(&__ctx, args, 0, 0, 0, 0, 0);      \
> +               trace_filter_call_bpf(ftrace_file->filter, &__ctx);     \
> +               return;                                                 \
> +       }                                                               \
> +                                                                       \
>         __data_size = ftrace_get_offsets_##call(&__data_offsets, args); \
>                                                                         \
>         entry = ftrace_event_buffer_reserve(&fbuffer, ftrace_file,      \
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index 06e0f63055fb..cedcf9a0db53 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -370,6 +370,7 @@ enum bpf_prog_attributes {
>  enum bpf_prog_type {
>         BPF_PROG_TYPE_UNSPEC,
>         BPF_PROG_TYPE_SOCKET_FILTER,
> +       BPF_PROG_TYPE_TRACING_FILTER,
>  };
>
>  /* integer value in 'imm' field of BPF_CALL instruction selects which helper
> @@ -380,6 +381,10 @@ enum bpf_func_id {
>         BPF_FUNC_map_lookup_elem, /* void *map_lookup_elem(map_id, void *key) */
>         BPF_FUNC_map_update_elem, /* int map_update_elem(map_id, void *key, void *value) */
>         BPF_FUNC_map_delete_elem, /* int map_delete_elem(map_id, void *key) */
> +       BPF_FUNC_load_pointer,    /* void *bpf_load_pointer(void *unsafe_ptr) */
> +       BPF_FUNC_memcmp,          /* int bpf_memcmp(void *unsafe_ptr, void *safe_ptr, int size) */
> +       BPF_FUNC_dump_stack,      /* void bpf_dump_stack(void) */
> +       BPF_FUNC_printk,          /* int bpf_printk(const char *fmt, int fmt_size, ...) */
>         __BPF_FUNC_MAX_ID,
>  };
>
> diff --git a/kernel/trace/Kconfig b/kernel/trace/Kconfig
> index d4409356f40d..e36d42876634 100644
> --- a/kernel/trace/Kconfig
> +++ b/kernel/trace/Kconfig
> @@ -80,6 +80,7 @@ config FTRACE_NMI_ENTER
>
>  config EVENT_TRACING
>         select CONTEXT_SWITCH_TRACER
> +       depends on NET
>         bool
>
>  config CONTEXT_SWITCH_TRACER
> diff --git a/kernel/trace/Makefile b/kernel/trace/Makefile
> index 2611613f14f1..a0fcfd97101d 100644
> --- a/kernel/trace/Makefile
> +++ b/kernel/trace/Makefile
> @@ -52,6 +52,7 @@ obj-$(CONFIG_EVENT_TRACING) += trace_event_perf.o
>  endif
>  obj-$(CONFIG_EVENT_TRACING) += trace_events_filter.o
>  obj-$(CONFIG_EVENT_TRACING) += trace_events_trigger.o
> +obj-$(CONFIG_EVENT_TRACING) += bpf_trace.o

Can the existing tracing mechanisms already expose kernel addresses? I
suspect "yes". So I guess existing limitations on tracing exposure
should already cover access control here? (I'm trying to figure out if
a separate CONFIG is needed -- I don't think so: nothing "new" is
exposed via eBPF, is that right?)

-Kees

>  obj-$(CONFIG_KPROBE_EVENT) += trace_kprobe.o
>  obj-$(CONFIG_TRACEPOINTS) += power-traces.o
>  ifeq ($(CONFIG_PM_RUNTIME),y)
> diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
> new file mode 100644
> index 000000000000..7263491be792
> --- /dev/null
> +++ b/kernel/trace/bpf_trace.c
> @@ -0,0 +1,212 @@
> +/* Copyright (c) 2011-2014 PLUMgrid, http://plumgrid.com
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of version 2 of the GNU General Public
> + * License as published by the Free Software Foundation.
> + */
> +#include <linux/kernel.h>
> +#include <linux/types.h>
> +#include <linux/slab.h>
> +#include <linux/bpf.h>
> +#include <linux/filter.h>
> +#include <linux/uaccess.h>
> +#include <trace/bpf_trace.h>
> +#include "trace.h"
> +
> +/* call from ftrace_raw_event_*() to copy tracepoint arguments into ctx */
> +void populate_bpf_context(struct bpf_context *ctx, ...)
> +{
> +       va_list args;
> +
> +       va_start(args, ctx);
> +
> +       ctx->arg1 = va_arg(args, unsigned long);
> +       ctx->arg2 = va_arg(args, unsigned long);
> +       ctx->arg3 = va_arg(args, unsigned long);
> +       ctx->arg4 = va_arg(args, unsigned long);
> +       ctx->arg5 = va_arg(args, unsigned long);
> +       ctx->arg6 = va_arg(args, unsigned long);
> +
> +       va_end(args);
> +}
> +EXPORT_SYMBOL_GPL(populate_bpf_context);
> +
> +/* called from eBPF program with rcu lock held */
> +static u64 bpf_load_ptr(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
> +{
> +        void *unsafe_ptr = (void *) r1;
> +       void *ptr = NULL;
> +
> +       probe_kernel_read(&ptr, unsafe_ptr, sizeof(void *));
> +       return (u64) (unsigned long) ptr;
> +}
> +
> +static u64 bpf_memcmp(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
> +{
> +        void *unsafe_ptr = (void *) r1;
> +       void *safe_ptr = (void *) r2;
> +       u32 size = (u32) r3;
> +       char buf[64];
> +       int err;
> +
> +       if (size < 64) {
> +               err = probe_kernel_read(buf, unsafe_ptr, size);
> +               if (err)
> +                       return err;
> +               return memcmp(buf, safe_ptr, size);
> +       }
> +       return -1;
> +}
> +
> +static u64 bpf_dump_stack(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
> +{
> +       trace_dump_stack(0);
> +       return 0;
> +}
> +
> +/* limited printk()
> + * only %d %u %x conversion specifiers allowed
> + */
> +static u64 bpf_printk(u64 r1, u64 fmt_size, u64 r3, u64 r4, u64 r5)
> +{
> +       char *fmt = (char *) r1;
> +       int fmt_cnt = 0;
> +       int i;
> +
> +       /* bpf_check() guarantees that fmt points to bpf program stack and
> +        * fmt_size bytes of it were initialized by bpf program
> +        */
> +       if (fmt[fmt_size - 1] != 0)
> +               return -EINVAL;
> +
> +       /* check format string for allowed specifiers */
> +       for (i = 0; i < fmt_size; i++)
> +               if (fmt[i] == '%') {
> +                       if (i + 1 >= fmt_size)
> +                               return -EINVAL;
> +                       if (fmt[i + 1] != 'd' && fmt[i + 1] != 'u' &&
> +                           fmt[i + 1] != 'x')
> +                               return -EINVAL;
> +                       fmt_cnt++;
> +               }
> +
> +       if (fmt_cnt > 3)
> +               return -EINVAL;
> +
> +       return __trace_printk((unsigned long) __builtin_return_address(3), fmt,
> +                             (u32) r3, (u32) r4, (u32) r5);
> +}
> +
> +static struct bpf_func_proto tracing_filter_funcs[] = {
> +       [BPF_FUNC_load_pointer] = {
> +               .func = bpf_load_ptr,
> +               .gpl_only = true,
> +               .ret_type = RET_INTEGER,
> +       },
> +       [BPF_FUNC_memcmp] = {
> +               .func = bpf_memcmp,
> +               .gpl_only = false,
> +               .ret_type = RET_INTEGER,
> +               .arg1_type = ARG_ANYTHING,
> +               .arg2_type = ARG_PTR_TO_STACK,
> +               .arg3_type = ARG_CONST_STACK_SIZE,
> +       },
> +       [BPF_FUNC_dump_stack] = {
> +               .func = bpf_dump_stack,
> +               .gpl_only = false,
> +               .ret_type = RET_VOID,
> +       },
> +       [BPF_FUNC_printk] = {
> +               .func = bpf_printk,
> +               .gpl_only = true,
> +               .ret_type = RET_INTEGER,
> +               .arg1_type = ARG_PTR_TO_STACK,
> +               .arg2_type = ARG_CONST_STACK_SIZE,
> +       },
> +       [BPF_FUNC_map_lookup_elem] = {
> +               .func = bpf_map_lookup_elem,
> +               .gpl_only = false,
> +               .ret_type = RET_PTR_TO_MAP_OR_NULL,
> +               .arg1_type = ARG_CONST_MAP_ID,
> +               .arg2_type = ARG_PTR_TO_MAP_KEY,
> +       },
> +       [BPF_FUNC_map_update_elem] = {
> +               .func = bpf_map_update_elem,
> +               .gpl_only = false,
> +               .ret_type = RET_INTEGER,
> +               .arg1_type = ARG_CONST_MAP_ID,
> +               .arg2_type = ARG_PTR_TO_MAP_KEY,
> +               .arg3_type = ARG_PTR_TO_MAP_VALUE,
> +       },
> +       [BPF_FUNC_map_delete_elem] = {
> +               .func = bpf_map_delete_elem,
> +               .gpl_only = false,
> +               .ret_type = RET_INTEGER,
> +               .arg1_type = ARG_CONST_MAP_ID,
> +               .arg2_type = ARG_PTR_TO_MAP_KEY,
> +       },
> +};
> +
> +static const struct bpf_func_proto *tracing_filter_func_proto(enum bpf_func_id func_id)
> +{
> +       if (func_id < 0 || func_id >= ARRAY_SIZE(tracing_filter_funcs))
> +               return NULL;
> +       return &tracing_filter_funcs[func_id];
> +}
> +
> +static const struct bpf_context_access {
> +       int size;
> +       enum bpf_access_type type;
> +} tracing_filter_ctx_access[] = {
> +       [offsetof(struct bpf_context, arg1)] = {
> +               FIELD_SIZEOF(struct bpf_context, arg1),
> +               BPF_READ
> +       },
> +       [offsetof(struct bpf_context, arg2)] = {
> +               FIELD_SIZEOF(struct bpf_context, arg2),
> +               BPF_READ
> +       },
> +       [offsetof(struct bpf_context, arg3)] = {
> +               FIELD_SIZEOF(struct bpf_context, arg3),
> +               BPF_READ
> +       },
> +       [offsetof(struct bpf_context, arg4)] = {
> +               FIELD_SIZEOF(struct bpf_context, arg4),
> +               BPF_READ
> +       },
> +       [offsetof(struct bpf_context, arg5)] = {
> +               FIELD_SIZEOF(struct bpf_context, arg5),
> +               BPF_READ
> +       },
> +};
> +
> +static bool tracing_filter_is_valid_access(int off, int size, enum bpf_access_type type)
> +{
> +       const struct bpf_context_access *access;
> +
> +       if (off < 0 || off >= ARRAY_SIZE(tracing_filter_ctx_access))
> +               return false;
> +
> +       access = &tracing_filter_ctx_access[off];
> +       if (access->size == size && (access->type & type))
> +               return true;
> +
> +       return false;
> +}
> +
> +static struct bpf_verifier_ops tracing_filter_ops = {
> +       .get_func_proto = tracing_filter_func_proto,
> +       .is_valid_access = tracing_filter_is_valid_access,
> +};
> +
> +static struct bpf_prog_type_list tl = {
> +       .ops = &tracing_filter_ops,
> +       .type = BPF_PROG_TYPE_TRACING_FILTER,
> +};
> +
> +static int __init register_tracing_filter_ops(void)
> +{
> +       bpf_register_prog_type(&tl);
> +       return 0;
> +}
> +late_initcall(register_tracing_filter_ops);
> diff --git a/kernel/trace/trace.h b/kernel/trace/trace.h
> index 9258f5a815db..bb7c6a19ead5 100644
> --- a/kernel/trace/trace.h
> +++ b/kernel/trace/trace.h
> @@ -984,12 +984,15 @@ struct ftrace_event_field {
>         int                     is_signed;
>  };
>
> +struct sk_filter;
> +
>  struct event_filter {
>         int                     n_preds;        /* Number assigned */
>         int                     a_preds;        /* allocated */
>         struct filter_pred      *preds;
>         struct filter_pred      *root;
>         char                    *filter_string;
> +       struct sk_filter        *prog;
>  };
>
>  struct event_subsystem {
> diff --git a/kernel/trace/trace_events.c b/kernel/trace/trace_events.c
> index f99e0b3bca8c..de79c27a0a42 100644
> --- a/kernel/trace/trace_events.c
> +++ b/kernel/trace/trace_events.c
> @@ -1048,6 +1048,26 @@ event_filter_read(struct file *filp, char __user *ubuf, size_t cnt,
>         return r;
>  }
>
> +static int event_filter_release(struct inode *inode, struct file *filp)
> +{
> +       struct ftrace_event_file *file;
> +       char buf[2] = "0";
> +
> +       mutex_lock(&event_mutex);
> +       file = event_file_data(filp);
> +       if (file) {
> +               if (file->event_call->flags & TRACE_EVENT_FL_BPF) {
> +                       /* auto-disable the filter */
> +                       ftrace_event_enable_disable(file, 0);
> +
> +                       /* if BPF filter was used, clear it on fd close */
> +                       apply_event_filter(file, buf);
> +               }
> +       }
> +       mutex_unlock(&event_mutex);
> +       return 0;
> +}
> +
>  static ssize_t
>  event_filter_write(struct file *filp, const char __user *ubuf, size_t cnt,
>                    loff_t *ppos)
> @@ -1071,10 +1091,23 @@ event_filter_write(struct file *filp, const char __user *ubuf, size_t cnt,
>
>         mutex_lock(&event_mutex);
>         file = event_file_data(filp);
> -       if (file)
> +       if (file) {
>                 err = apply_event_filter(file, buf);
> +               if (!err && file->event_call->flags & TRACE_EVENT_FL_BPF)
> +                       /* once filter is applied, auto-enable it */
> +                       ftrace_event_enable_disable(file, 1);
> +       }
> +
>         mutex_unlock(&event_mutex);
>
> +       if (file && file->event_call->flags & TRACE_EVENT_FL_BPF) {
> +               /*
> +                * allocate per-cpu printk buffers, since eBPF program
> +                * might be calling bpf_trace_printk
> +                */
> +               trace_printk_init_buffers();
> +       }
> +
>         free_page((unsigned long) buf);
>         if (err < 0)
>                 return err;
> @@ -1325,6 +1358,7 @@ static const struct file_operations ftrace_event_filter_fops = {
>         .open = tracing_open_generic,
>         .read = event_filter_read,
>         .write = event_filter_write,
> +       .release = event_filter_release,
>         .llseek = default_llseek,
>  };
>
> diff --git a/kernel/trace/trace_events_filter.c b/kernel/trace/trace_events_filter.c
> index 8a8631926a07..a27526fae0fe 100644
> --- a/kernel/trace/trace_events_filter.c
> +++ b/kernel/trace/trace_events_filter.c
> @@ -23,6 +23,9 @@
>  #include <linux/mutex.h>
>  #include <linux/perf_event.h>
>  #include <linux/slab.h>
> +#include <linux/bpf.h>
> +#include <trace/bpf_trace.h>
> +#include <linux/filter.h>
>
>  #include "trace.h"
>  #include "trace_output.h"
> @@ -535,6 +538,16 @@ static int filter_match_preds_cb(enum move_type move, struct filter_pred *pred,
>         return WALK_PRED_DEFAULT;
>  }
>
> +void trace_filter_call_bpf(struct event_filter *filter, struct bpf_context *ctx)
> +{
> +       BUG_ON(!filter || !filter->prog);
> +
> +       rcu_read_lock();
> +       SK_RUN_FILTER(filter->prog, (void *) ctx);
> +       rcu_read_unlock();
> +}
> +EXPORT_SYMBOL_GPL(trace_filter_call_bpf);
> +
>  /* return 1 if event matches, 0 otherwise (discard) */
>  int filter_match_preds(struct event_filter *filter, void *rec)
>  {
> @@ -794,6 +807,8 @@ static void __free_filter(struct event_filter *filter)
>         if (!filter)
>                 return;
>
> +       if (filter->prog)
> +               sk_unattached_filter_destroy(filter->prog);
>         __free_preds(filter);
>         kfree(filter->filter_string);
>         kfree(filter);
> @@ -1898,6 +1913,48 @@ static int create_filter_start(char *filter_str, bool set_str,
>         return err;
>  }
>
> +static int create_filter_bpf(char *filter_str, struct event_filter **filterp)
> +{
> +       struct event_filter *filter;
> +       struct sk_filter *prog;
> +       long ufd;
> +       int err = 0;
> +
> +       *filterp = NULL;
> +
> +       filter = __alloc_filter();
> +       if (!filter)
> +               return -ENOMEM;
> +
> +       err = replace_filter_string(filter, filter_str);
> +       if (err)
> +               goto free_filter;
> +
> +       err = kstrtol(filter_str + 4, 0, &ufd);
> +       if (err)
> +               goto free_filter;
> +
> +       err = -ESRCH;
> +       prog = bpf_prog_get(ufd);
> +       if (!prog)
> +               goto free_filter;
> +
> +       filter->prog = prog;
> +
> +       err = -EINVAL;
> +       if (prog->info->prog_type != BPF_PROG_TYPE_TRACING_FILTER)
> +               /* prog_id is valid, but it's not a tracing filter program */
> +               goto free_filter;
> +
> +       *filterp = filter;
> +
> +       return 0;
> +
> +free_filter:
> +       __free_filter(filter);
> +       return err;
> +}
> +
>  static void create_filter_finish(struct filter_parse_state *ps)
>  {
>         if (ps) {
> @@ -2007,7 +2064,20 @@ int apply_event_filter(struct ftrace_event_file *file, char *filter_string)
>                 return 0;
>         }
>
> -       err = create_filter(call, filter_string, true, &filter);
> +       /*
> +        * 'bpf_123' string is a request to attach eBPF program with id == 123
> +        * also accept 'bpf 123', 'bpf.123', 'bpf-123' variants
> +        */
> +       if (memcmp(filter_string, "bpf", 3) == 0 && filter_string[3] != 0 &&
> +           filter_string[4] != 0) {
> +               err = create_filter_bpf(filter_string, &filter);
> +               if (!err)
> +                       call->flags |= TRACE_EVENT_FL_BPF;
> +       } else {
> +               err = create_filter(call, filter_string, true, &filter);
> +               if (!err)
> +                       call->flags &= ~TRACE_EVENT_FL_BPF;
> +       }
>
>         /*
>          * Always swap the call filter with the new filter
> --
> 1.7.9.5
>



-- 
Kees Cook
Chrome OS Security
