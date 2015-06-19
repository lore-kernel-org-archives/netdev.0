From: Daniel Wagner <daniel.wagner@bmw-carit.de>
Subject: [PATCH v1] bpf: BPF based latency tracing
Date: Fri, 19 Jun 2015 15:57:27 +0200
Message-ID: <1434722247-9952-1-git-send-email-daniel.wagner@bmw-carit.de>
Cc: Daniel Wagner <daniel.wagner@bmw-carit.de>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bmw-carit.de ([62.245.222.98]:49492 "EHLO
	linuxmail.bmw-carit.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751883AbbFSN5j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2015 09:57:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BPF offers another way to generate latency histograms. We attach
kprobes at trace_preempt_off and trace_preempt_on and calculate the
time it takes to from seeing the off/on transition.

The first array is used to store the start time stamp. The key is the
CPU id. The second array stores the log2(time diff). We need to use
static allocation here (array and not hash tables). The kprobes
hooking into trace_preempt_on|off should not calling any dynamic
memory allocation or free path. We need to avoid recursivly
getting called. Besides that, it reduces jitter in the measurement.

CPU 0
      latency        : count     distribution
       1 -> 1        : 0        |                                        |
       2 -> 3        : 0        |                                        |
       4 -> 7        : 0        |                                        |
       8 -> 15       : 0        |                                        |
      16 -> 31       : 0        |                                        |
      32 -> 63       : 0        |                                        |
      64 -> 127      : 0        |                                        |
     128 -> 255      : 0        |                                        |
     256 -> 511      : 0        |                                        |
     512 -> 1023     : 0        |                                        |
    1024 -> 2047     : 0        |                                        |
    2048 -> 4095     : 166723   |*************************************** |
    4096 -> 8191     : 19870    |***                                     |
    8192 -> 16383    : 6324     |                                        |
   16384 -> 32767    : 1098     |                                        |
   32768 -> 65535    : 190      |                                        |
   65536 -> 131071   : 179      |                                        |
  131072 -> 262143   : 18       |                                        |
  262144 -> 524287   : 4        |                                        |
  524288 -> 1048575  : 1363     |                                        |
CPU 1
      latency        : count     distribution
       1 -> 1        : 0        |                                        |
       2 -> 3        : 0        |                                        |
       4 -> 7        : 0        |                                        |
       8 -> 15       : 0        |                                        |
      16 -> 31       : 0        |                                        |
      32 -> 63       : 0        |                                        |
      64 -> 127      : 0        |                                        |
     128 -> 255      : 0        |                                        |
     256 -> 511      : 0        |                                        |
     512 -> 1023     : 0        |                                        |
    1024 -> 2047     : 0        |                                        |
    2048 -> 4095     : 114042   |*************************************** |
    4096 -> 8191     : 9587     |**                                      |
    8192 -> 16383    : 4140     |                                        |
   16384 -> 32767    : 673      |                                        |
   32768 -> 65535    : 179      |                                        |
   65536 -> 131071   : 29       |                                        |
  131072 -> 262143   : 4        |                                        |
  262144 -> 524287   : 1        |                                        |
  524288 -> 1048575  : 364      |                                        |
CPU 2
      latency        : count     distribution
       1 -> 1        : 0        |                                        |
       2 -> 3        : 0        |                                        |
       4 -> 7        : 0        |                                        |
       8 -> 15       : 0        |                                        |
      16 -> 31       : 0        |                                        |
      32 -> 63       : 0        |                                        |
      64 -> 127      : 0        |                                        |
     128 -> 255      : 0        |                                        |
     256 -> 511      : 0        |                                        |
     512 -> 1023     : 0        |                                        |
    1024 -> 2047     : 0        |                                        |
    2048 -> 4095     : 40147    |*************************************** |
    4096 -> 8191     : 2300     |*                                       |
    8192 -> 16383    : 828      |                                        |
   16384 -> 32767    : 178      |                                        |
   32768 -> 65535    : 59       |                                        |
   65536 -> 131071   : 2        |                                        |
  131072 -> 262143   : 0        |                                        |
  262144 -> 524287   : 1        |                                        |
  524288 -> 1048575  : 174      |                                        |
CPU 3
      latency        : count     distribution
       1 -> 1        : 0        |                                        |
       2 -> 3        : 0        |                                        |
       4 -> 7        : 0        |                                        |
       8 -> 15       : 0        |                                        |
      16 -> 31       : 0        |                                        |
      32 -> 63       : 0        |                                        |
      64 -> 127      : 0        |                                        |
     128 -> 255      : 0        |                                        |
     256 -> 511      : 0        |                                        |
     512 -> 1023     : 0        |                                        |
    1024 -> 2047     : 0        |                                        |
    2048 -> 4095     : 29626    |*************************************** |
    4096 -> 8191     : 2704     |**                                      |
    8192 -> 16383    : 1090     |                                        |
   16384 -> 32767    : 160      |                                        |
   32768 -> 65535    : 72       |                                        |
   65536 -> 131071   : 32       |                                        |
  131072 -> 262143   : 26       |                                        |
  262144 -> 524287   : 12       |                                        |
  524288 -> 1048575  : 298      |                                        |

All this is based on the trace3 examples written by
Alexei Starovoitov <ast@plumgrid.com>.

Signed-off-by: Daniel Wagner <daniel.wagner@bmw-carit.de>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org
---

Hi Alexei,

Something broke in my toolchain and it took me a while to figure out whats
going on.

With the rebase on net-next no additinal patches are needed and this
thing here runs fine.

cheers,
daniel

changes

v1:	- rebases on net-next

v0:
	- renamed to lathist since there is no direct hw latency involved
	-  use arrays instead of hash tables

samples/bpf/Makefile | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 46c6a8c..4450fed 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -12,6 +12,7 @@ hostprogs-y += tracex2
 hostprogs-y += tracex3
 hostprogs-y += tracex4
 hostprogs-y += tracex5
+hostprogs-y += lathist
 
 test_verifier-objs := test_verifier.o libbpf.o
 test_maps-objs := test_maps.o libbpf.o
@@ -24,6 +25,7 @@ tracex2-objs := bpf_load.o libbpf.o tracex2_user.o
 tracex3-objs := bpf_load.o libbpf.o tracex3_user.o
 tracex4-objs := bpf_load.o libbpf.o tracex4_user.o
 tracex5-objs := bpf_load.o libbpf.o tracex5_user.o
+lathist-objs := bpf_load.o libbpf.o lathist_user.o
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
@@ -36,6 +38,7 @@ always += tracex3_kern.o
 always += tracex4_kern.o
 always += tracex5_kern.o
 always += tcbpf1_kern.o
+always += lathist_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
 
@@ -48,6 +51,7 @@ HOSTLOADLIBES_tracex2 += -lelf
 HOSTLOADLIBES_tracex3 += -lelf
 HOSTLOADLIBES_tracex4 += -lelf -lrt
 HOSTLOADLIBES_tracex5 += -lelf
+HOSTLOADLIBES_lathist += -lelf
 
 # point this to your LLVM backend with bpf support
 LLC=$(srctree)/tools/bpf/llvm/bld/Debug+Asserts/bin/llc
-- 
2.1.0
