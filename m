From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH] lib: test_bpf: purge CPP register redefinitions
Date: Mon, 22 Jun 2015 09:10:51 +0200
Message-ID: <5587B4FB.3040609@nod.at>
References: <87twu0df3k.fsf@gmail.com> <20150622060523.GA16156@Alexeis-MacBook-Pro.local> <5587B0C7.8090507@nod.at>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070900040409070207060008"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, daniel@iogearbox.net
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Nicolai Stange <nicstange@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.ns.miles-group.at ([95.130.255.143]:65276 "EHLO radon.swed.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753790AbbFVHK4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jun 2015 03:10:56 -0400
In-Reply-To: <5587B0C7.8090507@nod.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070900040409070207060008
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit

Am 22.06.2015 um 08:52 schrieb Richard Weinberger:
> Am 22.06.2015 um 08:05 schrieb Alexei Starovoitov:
>> to get rid of warning you proposing to do 1k line renames?!
>> Just add:
>> +#undef R8
>> +#undef R9
>> +#undef R10
>>  #define R0             BPF_REG_0
> 
> This would be also just another hack.
> 
>> Though I think the better fix woud be to clean up:
>> arch/x86/include/uapi/asm/ptrace-abi.h
>> What's the point of:
>> #define R8 72
>> from 'uapi' point of view?
> 
> To query cpu registers using ptrace(2).
> 
>> Look like kernel details that shouldn't be exposed in uapi.
> 
> These are not kernel details.
> 
> Actually the problem is the other way around.
> UML is Linux ported to it's own userspace ABI.
> Hence, the arch/um and arch/x86/um use uapi header files.
> 
> Maybe we can rework UML's header files such that
> no uapi header pollutes the kernel namespace.

While riding the bus to my office I've materialized that idea.
Nicolai, can you please give the attached patch a try?

Thanks,
//richard

--------------070900040409070207060008
Content-Type: text/x-patch;
 name="ptrace_abi.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="ptrace_abi.diff"

diff --git a/arch/um/include/asm/ptrace-generic.h b/arch/um/include/asm/ptrace-generic.h
index cb9b3c4..7485162 100644
--- a/arch/um/include/asm/ptrace-generic.h
+++ b/arch/um/include/asm/ptrace-generic.h
@@ -8,7 +8,6 @@
 
 #ifndef __ASSEMBLY__
 
-#include <asm/ptrace-abi.h>
 #include <sysdep/ptrace.h>
 
 struct pt_regs {
diff --git a/arch/um/kernel/ptrace.c b/arch/um/kernel/ptrace.c
index 174ee50..7a0b2d9 100644
--- a/arch/um/kernel/ptrace.c
+++ b/arch/um/kernel/ptrace.c
@@ -8,6 +8,7 @@
 #include <linux/sched.h>
 #include <linux/tracehook.h>
 #include <asm/uaccess.h>
+#include <asm/ptrace-abi.h>
 
 void user_enable_single_step(struct task_struct *child)
 {
diff --git a/arch/x86/um/ptrace_32.c b/arch/x86/um/ptrace_32.c
index ce3dd4f..a29756f 100644
--- a/arch/x86/um/ptrace_32.c
+++ b/arch/x86/um/ptrace_32.c
@@ -6,6 +6,7 @@
 #include <linux/mm.h>
 #include <linux/sched.h>
 #include <asm/uaccess.h>
+#include <asm/ptrace-abi.h>
 #include <skas.h>
 
 extern int arch_switch_tls(struct task_struct *to);
diff --git a/arch/x86/um/ptrace_64.c b/arch/x86/um/ptrace_64.c
index 3b52bf0..a629694 100644
--- a/arch/x86/um/ptrace_64.c
+++ b/arch/x86/um/ptrace_64.c
@@ -11,6 +11,7 @@
 #define __FRAME_OFFSETS
 #include <asm/ptrace.h>
 #include <asm/uaccess.h>
+#include <asm/ptrace-abi.h>
 
 /*
  * determines which flags the user has access to.
diff --git a/arch/x86/um/tls_32.c b/arch/x86/um/tls_32.c
index 80ffa5b..48e3858 100644
--- a/arch/x86/um/tls_32.c
+++ b/arch/x86/um/tls_32.c
@@ -7,6 +7,7 @@
 #include <linux/sched.h>
 #include <linux/syscalls.h>
 #include <asm/uaccess.h>
+#include <asm/ptrace-abi.h>
 #include <os.h>
 #include <skas.h>
 #include <sysdep/tls.h>
diff --git a/arch/x86/um/tls_64.c b/arch/x86/um/tls_64.c
index d22363c..3ad7143 100644
--- a/arch/x86/um/tls_64.c
+++ b/arch/x86/um/tls_64.c
@@ -1,4 +1,5 @@
 #include <linux/sched.h>
+#include <asm/ptrace-abi.h>
 
 void clear_flushed_tls(struct task_struct *task)
 {

--------------070900040409070207060008--
