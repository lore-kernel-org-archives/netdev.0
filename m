From: Sargun Dhillon <sargun@sargun.me>
Subject: Re: [PATCH 1/1] tracing, bpf: Implement function bpf_probe_write
Date: Sun, 17 Jul 2016 03:19:13 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1607161729010.12799@ircssh.c.rugged-nimbus-611.internal>
References: <CAMp4zn8ygXFg7kvjShm77zmK2dYVMY2zS8i2mUKwhbfXcyVyig@mail.gmail.com> <20160713170849.GA76615@ast-mbp.thefacebook.com> <alpine.DEB.2.02.1607131230210.19550@ircssh.c.rugged-nimbus-611.internal> <20160715054025.GA99435@ast-mbp>
 <alpine.DEB.2.02.1607151552400.24930@ircssh.c.rugged-nimbus-611.internal> <20160716023035.GA19373@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f52.google.com ([209.85.214.52]:36492 "EHLO
	mail-it0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750922AbcGQKTP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jul 2016 06:19:15 -0400
Received: by mail-it0-f52.google.com with SMTP id f6so49909467ith.1
        for <netdev@vger.kernel.org>; Sun, 17 Jul 2016 03:19:14 -0700 (PDT)
In-Reply-To: <20160716023035.GA19373@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, 15 Jul 2016, Alexei Starovoitov wrote:

> On Fri, Jul 15, 2016 at 07:16:01PM -0700, Sargun Dhillon wrote:
>>
>>
>> On Thu, 14 Jul 2016, Alexei Starovoitov wrote:
>>
>>> On Wed, Jul 13, 2016 at 01:31:57PM -0700, Sargun Dhillon wrote:
>>>>
>>>>
>>>> On Wed, 13 Jul 2016, Alexei Starovoitov wrote:
>>>>
>>>>> On Wed, Jul 13, 2016 at 03:36:11AM -0700, Sargun Dhillon wrote:
>>>>>> Provides BPF programs, attached to kprobes a safe way to write to
>>>>>> memory referenced by probes. This is done by making probe_kernel_write
>>>>>> accessible to bpf functions via the bpf_probe_write helper.
>>>>>
>>>>> not quite :)
>>>>>
>>>>>> Signed-off-by: Sargun Dhillon <sargun@sargun.me>
>>>>>> ---
>>>>>> include/uapi/linux/bpf.h  |  3 +++
>>>>>> kernel/trace/bpf_trace.c  | 20 ++++++++++++++++++++
>>>>>> samples/bpf/bpf_helpers.h |  2 ++
>>>>>> 3 files changed, 25 insertions(+)
>>>>>>
>>>>>> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
>>>>>> index 406459b..355b565 100644
>>>>>> --- a/include/uapi/linux/bpf.h
>>>>>> +++ b/include/uapi/linux/bpf.h
>>>>>> @@ -313,6 +313,9 @@ enum bpf_func_id {
>>>>>>  */
>>>>>>  BPF_FUNC_skb_get_tunnel_opt,
>>>>>>  BPF_FUNC_skb_set_tunnel_opt,
>>>>>> +
>>>>>> + BPF_FUNC_probe_write, /* int bpf_probe_write(void *dst, void *src,
>>>>>> int size) */
>>>>>> +
>>>>>
>>>>> the patch is against some old kernel.
>>>>> Please always make the patch against net-next tree and cc netdev list.
>>>>>
>>>> Sorry, I did this against Linus's tree, not net-next. Will fix.
>>>>
>>>>>> +static u64 bpf_probe_write(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
>>>>>> +{
>>>>>> + void *dst = (void *) (long) r1;
>>>>>> + void *unsafe_ptr = (void *) (long) r2;
>>>>>> + int  size = (int) r3;
>>>>>> +
>>>>>> + return probe_kernel_write(dst, unsafe_ptr, size);
>>>>>> +}
>>>>>
>>>>> the patch is whitepsace mangled. Please see Documentation/networking/netdev-FAQ.txt
>>>> Also will fix.
>>>>
>>>>>
>>>>> the main issue though that we cannot simply allow bpf to do probe_write,
>>>>> since it may crash the kernel.
>>>>> What might be ok is to allow writing into memory of current
>>>>> user space process only. This way bpf prog will keep kernel safety guarantees,
>>>>> yet it will be able to modify user process memory when necessary.
>>>>> Since bpf+tracing is root only, it doesn't pose security risk.
>>>>>
>>>>>
>>>>
>>>> Doesn't probe_write prevent you from writing to protected memory and
>>>> generate an EFAULT? Or are you worried about the situation where a bpf
>>>> program writes to some other chunk of kernel memory, or writes bad data
>>>> to said kernel memory?
>>>>
>>>> I guess when I meant "safe" -- it's safer than allowing arbitrary memcpy.
>>>> I don't see a good way to ensure safety otherwise as we don't know
>>>> which registers point to memory that it's reasonable for probes to
>>>> manipulate. It's not like skb_store_bytes where we can check the pointer
>>>> going in is the same pointer that's referenced, and with a super
>>>> restricted datatype.
>>>
>>> exactly. probe_write can write anywhere in the kernel and that
>>> will cause crashes. If we allow that bpf becomes no different than
>>> kernel module.
>>>
>>>> Perhaps, it would be a good idea to describe an example where I used this:
>>>> #include <uapi/linux/ptrace.h>
>>>> #include <net/sock.h>
>>>> #include <bcc/proto.h>
>>>>
>>>>
>>>> int trace_inet_stream_connect(struct pt_regs *ctx)
>>>> {
>>>> 	if (!PT_REGS_PARM2(ctx)) {
>>>> 		return 0;
>>>> 	}
>>>> 	struct sockaddr uaddr = {};
>>>> 	struct sockaddr_in *addr_in;
>>>> 	bpf_probe_read(&uaddr, sizeof(struct sockaddr), (void *)PT_REGS_PARM2(ctx));
>>>> 	if (uaddr.sa_family == AF_INET) {
>>>> 		// Simple cast causes LLVM weirdness
>>>> 		addr_in = &uaddr;
>>>> 		char fmt[] = "Connecting on port: %d\n";
>>>> 		bpf_trace_printk(fmt, sizeof(fmt), ntohs(addr_in->sin_port));
>>>> 		if (ntohs(addr_in->sin_port) == 80) {
>>>> 			addr_in->sin_port = htons(443);
>>>> 			bpf_probe_write((void *)PT_REGS_PARM2(ctx), &uaddr, sizeof(uaddr));
>>>> 		}
>>>> 	}
>>>>        return 0;
>>>> };
>>>>
>>>> There are two reasons I want to do this:
>>>> 1) Debugging - sometimes, it makes sense to divert a program's syscalls in
>>>> order to allow for better debugging
>>>> 2) Network Functions - I wrote a load balancer which intercepts
>>>> inet_stream_connect & tcp_set_state. We can manipulate the destination
>>>> address as neccessary at connect time. This also has the nice side effect
>>>> that getpeername() returns the real IP that a server is connected to, and
>>>> the performance is far better than doing "network load balancing"
>>>>
>>>> (I realize this is a total hack, better approaches would be appreciated)
>>>
>>> nice. interesting idea.
>>> Have you considered ld_preload hack to do port rewrite?
>>>
>> We've thought about it. It wont really work for us, because we're doing this
>> to manipulate 3rd party runtimes, many of which are written in languages
>> that don't play nice with LD_PRELOAD. Go is the primary problem child in
>> this case. We also looked at using SECCOMP + ptrace, but again, not all
>> runtimes play nice with ptrace.
>
> interesting!
> I was about to suggest to hack write support into seccomp, since few
> folks were interested in it as well. Why seccomp won't work?
> You cannot have a centralized daemon that launches all the processes?
>
>>>> If we allowed manipulation of the current task's user memory by exposing
>>>> copy_to_user, that could also work if I attach the probe to sys_connect,
>>>> I could overwrite the address there before it gets copied into
>>>> kernel space, but that could lead to its own weirdness.
>>>
>>> we cannot simply call copy_to_user from the bpf either,
>>> but yeah, something semantically equivalent to copy_to_user should
>>> solve your port rewriting case, right?
>>> Could you explain little bit more on 'syscall divert' ideas?
>>>
>>>
>> If we had a "safe" copy_to_user which checked if BPF programs were running
>> in the user context, that would work right? I mean, you could still make
>> user programs crash, but that's better than making the kernel fall over. We
>> would need both copy_from_user, and copy_to_user. If you look at the example
>> program, it first checks what the user is connecting to -- so it'd have to
>> check the address the user is passing to the syscall.
>
> yep. imo 'safe' copy_to_user is no different in user impact from seccomp.
> Both can make user process inoperable if there is a bug in bpf program,
> but both are always safe from kernel point of view.
> there is no need in copy_from_user. bpf_probe_read can read user memory just
> fine or you actually want to make even safer version of probe_read that
> can only read current task memory instead of any memory?
> Makes sense to me.
>
>> Syscall Divert:
>> The idea here is to try to "lie" to the program about the environment. A
>> specific example is where I want to bypass certain calls like prctl during
>> debugging, to allow certain instructions to execute. I don't always have
>> access to the source of the containerizer I'm running, and it's nice to turn
>> them off during debugging.
>
> makes sense too.
> so seccomp with write support is also not option here, because you actually
> want to divert seccomp itself?
>
>
Yeah, the only difference with seccomp is that the impact is isolated to a 
group of processes versus the entire system. Though, kprobes require root, 
whereas seccomp is accessible to others. It would be really nice to be 
able to call bpf_probe_read from seccomp filters, and be able to filter on 
things like the endpoint that people are connecting to. As it stands right 
now, it would open up seccomp to a TOCTOU attack. I'm not sure


If seccomp had full eBPF, and write support that'd solve most of my use 
cases. As far as diverting diverting future syscall behaviour, if I could 
just intercept those, and rewrite seccomp filters that'd solve the problem 
too.

I'm thinking of submitting something along the lines of the following 
patch [WIP]. What do you think?
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index c4d9224..d435f7c 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -364,6 +364,17 @@ enum bpf_func_id {
  	 */
  	BPF_FUNC_get_current_task,

+	/**
+	 * copy_to_user(to, from, len) - Copy a block of data into user 
space.
+	 * @to: destination address in userspace
+	 * @from: source address on stack
+	 * @len: number of bytes to copy
+	 * Return:
+	 *   Returns number of bytes that could not be copied.
+	 *   On success, this will be zero
+	 */
+	BPF_FUNC_copy_to_user,
+
  	__BPF_FUNC_MAX_ID,
  };

diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index ebfbb7d..be89c148 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -81,6 +81,30 @@ static const struct bpf_func_proto bpf_probe_read_proto 
= {
  	.arg3_type	= ARG_ANYTHING,
  };

+static u64 bpf_copy_to_user(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	void *to = (void *) (long) r1;
+	void *from = (void *) (long) r2;
+	int  size = (int) r3;
+
+	/* check if we're in a user context */
+	if (unlikely(in_interrupt()))
+		return -EINVAL;
+	if (unlikely(!current->pid))
+		return -EINVAL;
+
+	return copy_to_user(to, from, size);
+}
+
+static const struct bpf_func_proto bpf_copy_to_user_proto = {
+	.func = bpf_copy_to_user,
+	.gpl_only = false,
+	.ret_type = RET_INTEGER,
+	.arg1_type = ARG_ANYTHING,
+	.arg2_type = ARG_PTR_TO_RAW_STACK,
+	.arg3_type = ARG_CONST_STACK_SIZE,
+};
+
  /*
   * limited trace_printk()
   * only %d %u %x %ld %lu %lx %lld %llu %llx %p %s conversion specifiers 
allowed
@@ -360,6 +384,8 @@ static const struct bpf_func_proto 
*tracing_func_proto(enum bpf_func_id func_id)
  		return &bpf_get_smp_processor_id_proto;
  	case BPF_FUNC_perf_event_read:
  		return &bpf_perf_event_read_proto;
+	case BPF_FUNC_copy_to_user:
+		return &bpf_copy_to_user_proto;
  	default:
  		return NULL;
  	}
diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index a98b780..be2bab9 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -14,6 +14,7 @@ hostprogs-y += tracex3
  hostprogs-y += tracex4
  hostprogs-y += tracex5
  hostprogs-y += tracex6
+hostprogs-y += tracex7
  hostprogs-y += trace_output
  hostprogs-y += lathist
  hostprogs-y += offwaketime
@@ -35,6 +36,7 @@ tracex3-objs := bpf_load.o libbpf.o tracex3_user.o
  tracex4-objs := bpf_load.o libbpf.o tracex4_user.o
  tracex5-objs := bpf_load.o libbpf.o tracex5_user.o
  tracex6-objs := bpf_load.o libbpf.o tracex6_user.o
+tracex7-objs := bpf_load.o libbpf.o tracex7_user.o
  trace_output-objs := bpf_load.o libbpf.o trace_output_user.o
  lathist-objs := bpf_load.o libbpf.o lathist_user.o
  offwaketime-objs := bpf_load.o libbpf.o offwaketime_user.o
@@ -54,6 +56,7 @@ always += tracex3_kern.o
  always += tracex4_kern.o
  always += tracex5_kern.o
  always += tracex6_kern.o
+always += tracex7_kern.o
  always += trace_output_kern.o
  always += tcbpf1_kern.o
  always += lathist_kern.o
@@ -78,6 +81,7 @@ HOSTLOADLIBES_tracex3 += -lelf
  HOSTLOADLIBES_tracex4 += -lelf -lrt
  HOSTLOADLIBES_tracex5 += -lelf
  HOSTLOADLIBES_tracex6 += -lelf
+HOSTLOADLIBES_tracex7 += -lelf
  HOSTLOADLIBES_trace_output += -lelf -lrt
  HOSTLOADLIBES_lathist += -lelf
  HOSTLOADLIBES_offwaketime += -lelf
diff --git a/samples/bpf/bpf_helpers.h b/samples/bpf/bpf_helpers.h
index 84e3fd9..a54a26c 100644
--- a/samples/bpf/bpf_helpers.h
+++ b/samples/bpf/bpf_helpers.h
@@ -41,6 +41,8 @@ static int (*bpf_perf_event_output)(void *ctx, void 
*map, int index, void *data,
  	(void *) BPF_FUNC_perf_event_output;
  static int (*bpf_get_stackid)(void *ctx, void *map, int flags) =
  	(void *) BPF_FUNC_get_stackid;
+static int (*bpf_copy_to_user)(void *to, void *from, int size) =
+	(void *) BPF_FUNC_copy_to_user;

  /* llvm builtin functions that eBPF C program may use to
   * emit BPF_LD_ABS and BPF_LD_IND instructions
diff --git a/samples/bpf/tracex7_kern.c b/samples/bpf/tracex7_kern.c
new file mode 100644
index 0000000..c341a0a
--- /dev/null
+++ b/samples/bpf/tracex7_kern.c
@@ -0,0 +1,53 @@
+/* Copyright (c) 2013-2015 PLUMgrid, http://plumgrid.com
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <uapi/linux/bpf.h>
+#include <linux/version.h>
+#include "bpf_helpers.h"
+
+
+struct bpf_map_def SEC("maps") dnat_map = {
+	.type = BPF_MAP_TYPE_HASH,
+	.key_size = sizeof(struct sockaddr_in),
+	.value_size = sizeof(struct sockaddr_in),
+	.max_entries = 256,
+};
+
+
+/* kprobe is NOT a stable ABI
+ * kernel functions can be removed, renamed or completely change 
semantics.
+ * Number of arguments and their positions can change, etc.
+ * In such case this bpf+kprobe example will no longer be meaningful
+ *
+ * This example sits on a syscall, and the syscall ABI is relatively 
stable
+ * of course, across platforms, and over time, the ABI may change.
+ */
+SEC("kprobe/sys_connect")
+int bpf_prog1(struct pt_regs *ctx)
+{
+	struct sockaddr_in new_addr, orig_addr = {};
+	struct sockaddr_in *mapped_addr;
+	void *sockaddr_arg = (void *)PT_REGS_PARM2(ctx);
+	int sockaddr_len = (int)PT_REGS_PARM3(ctx);
+
+	if (sockaddr_len > sizeof(orig_addr))
+		return 0;
+
+	if (bpf_probe_read(&orig_addr, sizeof(orig_addr), sockaddr_arg) != 
0)
+		return 0;
+
+	mapped_addr = bpf_map_lookup_elem(&dnat_map, &orig_addr);
+	if (mapped_addr != NULL) {
+		memcpy(&new_addr, mapped_addr, sizeof(new_addr));
+		bpf_copy_to_user(sockaddr_arg, &new_addr, 
sizeof(new_addr));
+	}
+	return 0;
+}
+
+char _license[] SEC("license") = "GPL";
+u32 _version SEC("version") = LINUX_VERSION_CODE;
diff --git a/samples/bpf/tracex7_user.c b/samples/bpf/tracex7_user.c
new file mode 100644
index 0000000..167ee40
--- /dev/null
+++ b/samples/bpf/tracex7_user.c
@@ -0,0 +1,76 @@
+#include <stdio.h>
+#include <assert.h>
+#include <linux/bpf.h>
+#include <unistd.h>
+#include "libbpf.h"
+#include "bpf_load.h"
+#include <sys/socket.h>
+#include <string.h>
+#include <netinet/in.h>
+#include <arpa/inet.h>
+
+int main(int ac, char **argv)
+{
+	int serverfd, serverconnfd, clientfd;
+	socklen_t sockaddr_len;
+	struct sockaddr serv_addr, mapped_addr, tmp_addr;
+	struct sockaddr_in *serv_addr_in, *mapped_addr_in, *tmp_addr_in;
+	char filename[256];
+	char *ip;
+
+	serv_addr_in = (struct sockaddr_in *)&serv_addr;
+	mapped_addr_in = (struct sockaddr_in *)&mapped_addr;
+	tmp_addr_in = (struct sockaddr_in *)&tmp_addr;
+
+	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
+
+	if (load_bpf_file(filename)) {
+		printf("%s", bpf_log_buf);
+		return 1;
+	}
+
+	assert((serverfd = socket(AF_INET, SOCK_STREAM, 0)) > 0);
+	assert((clientfd = socket(AF_INET, SOCK_STREAM, 0)) > 0);
+
+	/* Bind server to ephemeral port on lo */
+	memset(&serv_addr, 0, sizeof(serv_addr));
+	serv_addr_in->sin_family = AF_INET;
+	serv_addr_in->sin_port = 0;
+	serv_addr_in->sin_addr.s_addr = htonl(INADDR_LOOPBACK);
+
+	assert(bind(serverfd, &serv_addr, sizeof(serv_addr)) == 0);
+
+	sockaddr_len = sizeof(serv_addr);
+	assert(getsockname(serverfd, &serv_addr, &sockaddr_len) == 0);
+	ip = inet_ntoa(serv_addr_in->sin_addr);
+	printf("Server bound to: %s:%d\n", ip, 
ntohs(serv_addr_in->sin_port));
+
+	memset(&mapped_addr, 0, sizeof(mapped_addr));
+	mapped_addr_in->sin_family = AF_INET;
+	mapped_addr_in->sin_port = htons(5555);
+	mapped_addr_in->sin_addr.s_addr = htonl(INADDR_LOOPBACK);
+
+	assert(bpf_update_elem(map_fd[0], &mapped_addr, &serv_addr,
+		BPF_ANY) == 0);
+
+	assert(listen(serverfd, 5) == 0);
+
+	ip = inet_ntoa(mapped_addr_in->sin_addr);
+	printf("Client connecting to: %s:%d\n", ip,
+		ntohs(mapped_addr_in->sin_port));
+	assert(connect(clientfd, &mapped_addr, sizeof(mapped_addr)) == 0);
+
+	sockaddr_len = sizeof(tmp_addr);
+	ip = inet_ntoa(tmp_addr_in->sin_addr);
+	assert((serverconnfd = accept(serverfd, &tmp_addr, &sockaddr_len)) 
> 0);
+	printf("Server received connection from: %s:%d\n", ip,
+		ntohs(tmp_addr_in->sin_port));
+
+	sockaddr_len = sizeof(tmp_addr);
+	assert(getpeername(clientfd, &tmp_addr, &sockaddr_len) == 0);
+	ip = inet_ntoa(tmp_addr_in->sin_addr);
+	printf("Client's peer address: %s:%d\n", ip,
+		ntohs(tmp_addr_in->sin_port));
+
+	return 0;
+}
