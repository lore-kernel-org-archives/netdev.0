From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] ebpf: bpf_map_*: fix linker error on avr32 and openrisc arch
Date: Thu,  5 Mar 2015 23:27:51 +0100
Message-ID: <dc0fc4f224a95f2a9813079229cb9cc0ac069d52.1425594286.git.daniel@iogearbox.net>
Cc: fengguang.wu@intel.com, ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44012 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919AbbCEW16 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 17:27:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fengguang reported, that on openrisc and avr32 architectures, we
get the following linker errors on *_defconfig builds that have
no bpf syscall support:

  net/built-in.o:(.rodata+0x1cd0): undefined reference to `bpf_map_lookup_elem_proto'
  net/built-in.o:(.rodata+0x1cd4): undefined reference to `bpf_map_update_elem_proto'
  net/built-in.o:(.rodata+0x1cd8): undefined reference to `bpf_map_delete_elem_proto'

Fix it up by providing built-in weak definitions of the symbols,
so they can be overridden when the syscall is enabled. I think
the issue might be that gcc is not able to optimize all that away.
This patch fixes the linker errors for me, tested with Fengguang's
make.cross [1] script.

  [1] https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Fixes: d4052c4aea0c ("ebpf: remove CONFIG_BPF_SYSCALL ifdefs in socket filter code")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/core.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index a64e7a2..50603ae 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -656,6 +656,11 @@ void bpf_prog_free(struct bpf_prog *fp)
 }
 EXPORT_SYMBOL_GPL(bpf_prog_free);
 
+/* Weak definitions of helper functions in case we don't have bpf syscall. */
+const struct bpf_func_proto bpf_map_lookup_elem_proto __weak;
+const struct bpf_func_proto bpf_map_update_elem_proto __weak;
+const struct bpf_func_proto bpf_map_delete_elem_proto __weak;
+
 /* To execute LD_ABS/LD_IND instructions __bpf_prog_run() may call
  * skb_copy_bits(), so provide a weak definition of it for NET-less config.
  */
-- 
1.9.3
