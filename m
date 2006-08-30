From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH v5 1/2] iWARP Connection Manager.
Date: Wed, 30 Aug 2006 12:52:27 -0500
Message-ID: <1156960347.8973.16.camel@trinity.ogc.int>
References: <20060803210238.16228.47335.stgit@dell3.ogc.int>
	 <20060803210240.16228.18429.stgit@dell3.ogc.int>
	 <adafyfem8il.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Steve Wise <swise@opengridcomputing.com>,
	openib-general@openib.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-153-218-104.sw.biz.rr.com ([24.153.218.104]:11396 "EHLO
	dell3.ogc.int") by vger.kernel.org with ESMTP id S1751261AbWH3Rw2
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Aug 2006 13:52:28 -0400
To: Roland Dreier <rdreier@cisco.com>
In-Reply-To: <adafyfem8il.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-08-30 at 10:35 -0700, Roland Dreier wrote:
> OK, getting closer to finishing the merge...
> 
> anyway, why is iw_cm_private.h in include/rdma where it is visible
> everywhere?  As far as I can tell drivers/infiniband/core/iwcm.c is
> the only place it's included.  So why not just put this stuff in
> drivers/infiniband/core/iwcm.h and do

The data structures really belong in iwcm.c...but I have a KDB module
that dumps IB data structures. So when I was writing the IWCM, I pulled
them out where I could see them without include gymnastics. It seems
pretty dumb though to have header files called *private.h in a public
directory. Putting them in iwcm.h is fine with me... 

Here's a patch for the KDB code if anyone is interested...

KDB module for dumping OpenFabrics stack data types

From: Tom Tucker <tom@opengridcomputing.com>


---

 kdb/kdbmain.c                  |    2 
 kdb/modules/Makefile           |    3 
 kdb/modules/kdbm_openfabrics.c |  372
++++++++++++++++++++++++++++++++++++++++
 3 files changed, 375 insertions(+), 2 deletions(-)

diff --git a/kdb/kdbmain.c b/kdb/kdbmain.c
index 931b643..b35139a 100644
--- a/kdb/kdbmain.c
+++ b/kdb/kdbmain.c
@@ -1154,8 +1154,8 @@ kdb_quiet(int reason)
  *	none
  */
 
+void kdba_cpu_up(void) {};
 extern char kdb_prompt_str[];
-
 static int
 kdb_local(kdb_reason_t reason, int error, struct pt_regs *regs,
kdb_dbtrap_t db_result)
 {
diff --git a/kdb/modules/Makefile b/kdb/modules/Makefile
index ae2ac53..fbf05e1 100644
--- a/kdb/modules/Makefile
+++ b/kdb/modules/Makefile
@@ -6,7 +6,8 @@ #
 # Copyright (c) 1999-2006 Silicon Graphics, Inc.  All Rights Reserved.
 #
 
-obj-$(CONFIG_KDB_MODULES) += kdbm_pg.o kdbm_task.o kdbm_vm.o
kdbm_sched.o
+obj-$(CONFIG_KDB_MODULES) += kdbm_pg.o kdbm_task.o kdbm_vm.o
kdbm_sched.o \
+				kdbm_openfabrics.o
 ifdef CONFIG_X86
 ifndef CONFIG_X86_64
 obj-$(CONFIG_KDB_MODULES) += kdbm_x86.o
diff --git a/kdb/modules/kdbm_openfabrics.c
b/kdb/modules/kdbm_openfabrics.c
new file mode 100644
index 0000000..fdf204b
--- /dev/null
+++ b/kdb/modules/kdbm_openfabrics.c
@@ -0,0 +1,372 @@
+/*
+ * Copyright (c) 2006 Tom Tucker, Open Grid Computing, Inc. 
+ */
+
+#include <linux/kdb.h>
+#include <linux/kdbprivate.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/sched.h>
+#include <rdma/ib_verbs.h>
+#include <rdma/rdma_cm.h>
+#include <rdma/iw_cm.h>
+#include <rdma/iw_cm_private.h>
+#include "../drivers/infiniband/hw/amso1100/c2_provider.h"
+
+MODULE_AUTHOR("Tom Tucker");
+MODULE_DESCRIPTION("Debug RDMA");
+MODULE_LICENSE("Dual BSD/GPL");
+
+static const char *wc_status_str[] = {
+	"SUCCESS",
+	"LOC_LEN_ERR",
+	"LOC_QP_OP_ERR",
+	"LOC_EEC_OP_ERR",
+	"LOC_PROT_ERR",
+	"WR_FLUSH_ERR",
+	"MW_BIND_ERR",
+	"BAD_RESP_ERR",
+	"LOC_ACCESS_ERR",
+	"REM_INV_REQ_ERR",
+	"REM_ACCESS_ERR",
+	"REM_OP_ERR",
+	"RETRY_EXC_ERR",
+	"RNR_RETRY_EXC_ERR",
+	"LOC_RDD_VIOL_ERR",
+	"REM_INV_RD_REQ_ERR",
+	"REM_ABORT_ERR",
+	"INV_EECN_ERR",
+	"INV_EEC_STATE_ERR",
+	"FATAL_ERR",
+	"RESP_TIMEOUT_ERR",
+	"GENERAL_ERR"
+};
+
+static inline const char *wc_status_to_str(int status)
+{
+	if (status > (sizeof(wc_status_str) / sizeof(wc_status_str[0])))
+		return "<bad status>";
+
+	return wc_status_str[status];
+}
+
+static const char *wc_opcode_str[] = {
+	"SEND",
+	"RDMA_WRITE",
+	"RDMA_READ",
+	"COMP_SWAP",
+	"FETCH_ADD",
+	"BIND_MW",
+	"RECV",
+	"RECV_RDMA_WITH_IMM",
+};
+
+static inline const char* wc_opcode_to_str(int op) 
+{
+	
+	if (op > 129)
+		return "<bad opcode>";
+	else if (op >= 128)
+		op -= 122;
+	return wc_opcode_str[op];
+}
+
+static int
+print_ib_wc(int argc, const char **argv, const char **envp,
+	    struct pt_regs *regs)
+{
+	int ret = 0;
+
+	if (argc == 1) {
+		kdb_machreg_t addr;
+		int nextarg = 1;
+		long offset = 0;
+		struct ib_wc wc;
+
+		ret = kdbgetaddrarg(argc, argv, &nextarg, &addr, 
+				    &offset, NULL, regs);
+		if (ret) 
+			return ret;
+
+		kdb_printf("struct ib_wc [%p]\n", (void*)addr);
+		ret = kdb_getarea_size((void*)&wc, (unsigned long)addr, 
+				       sizeof wc);
+		if (ret)
+			return ret;
+
+		kdb_printf("  wr_id          : %llx\n", wc.wr_id);
+		kdb_printf("  status         : \"%s\"\n",
wc_status_to_str(wc.status));
+		kdb_printf("  opcode         : %s\n", wc_opcode_to_str(wc.opcode));
+		kdb_printf("  vendor_err     : %d\n", wc.vendor_err);
+		kdb_printf("  byte_len       : %d\n", wc.byte_len);
+		kdb_printf("  imm_data       : %d\n", wc.imm_data);
+		kdb_printf("  qp_num         : %d\n", wc.qp_num);
+		kdb_printf("  src_qp         : %d\n", wc.src_qp);
+		kdb_printf("  wc_flags       : %x\n", wc.wc_flags);
+		kdb_printf("  pkey_index     : %d\n", wc.pkey_index);
+		kdb_printf("  slid           : %d\n", wc.slid);
+		kdb_printf("  sl             : %d\n", wc.sl);
+		kdb_printf("  dlid_path_bits : %d\n", wc.dlid_path_bits);
+		kdb_printf("  port_num       : %d\n", wc.port_num);
+	} else {
+		/* More than one arg */
+		kdb_printf("Specify address of ib_wc to dump\n");
+		return KDB_ARGCOUNT;
+	}
+	return ret;
+}
+
+static kdb_machreg_t sge_addr;
+static kdb_machreg_t addr;
+static int sge_no;
+
+static int
+print_ib_sge(int argc, const char **argv, const char **envp,
+	    struct pt_regs *regs)
+{
+	int ret = 0;
+	struct ib_sge sge;
+
+	if (argc == 1) {
+		int nextarg = 1;
+		long offset = 0;
+
+		sge_no = 0;
+		ret = kdbgetaddrarg(argc, argv, &nextarg, &sge_addr, 
+				    &offset, NULL, regs);
+		if (ret) 
+			return ret;
+
+		ret = kdb_getarea_size((void*)&sge, (unsigned long)sge_addr, 
+				       sizeof(struct ib_sge));
+		if (ret)
+			return ret;
+
+	} 
+	kdb_printf("sge[%d].addr   : %llx\n", sge_no, sge.addr);
+	kdb_printf("sge[%d].length : %d\n", sge_no, sge.length);
+	kdb_printf("sge[%d].lkey   : %08x\n", sge_no, sge.lkey);
+	sge_no += 1;
+	sge_addr = (kdb_machreg_t)
+		((unsigned long)sge_addr + sizeof(struct ib_sge));
+	return ret;
+}
+
+static const char *iwcm_state_str[] = {
+	"IW_CM_STATE_IDLE",
+	"IW_CM_STATE_LISTEN",
+	"IW_CM_STATE_CONN_RECV",
+	"IW_CM_STATE_CONN_SENT",
+	"IW_CM_STATE_ESTABLISHED",
+	"IW_CM_STATE_CLOSING",
+	"IW_CM_STATE_DESTROYING"
+};
+
+static inline const char *to_iwcm_state_str(int state)
+{
+	if (state < 0 || 
+	    state > sizeof(iwcm_state_str)/sizeof(iwcm_state_str[0]))
+		return "<invalid state>";
+
+	
+	return iwcm_state_str[state];
+}
+
+static int
+print_iw_cm_id(int argc, const char **argv, const char **envp,
+	    struct pt_regs *regs)
+{
+	int ret = 0;
+	struct iwcm_id_private id;
+	struct sockaddr_in *sin;
+
+	if (argc == 1) {
+		int nextarg = 1;
+		long offset = 0;
+
+		ret = kdbgetaddrarg(argc, argv, &nextarg, &addr, 
+				    &offset, NULL, regs);
+		if (ret) 
+			return ret;
+
+		ret = kdb_getarea_size((void*)&id, (unsigned long)addr, 
+				       sizeof(struct iwcm_id_private));
+		if (ret)
+			return ret;
+	} 
+	kdb_printf("iw_cm_handler   : %p\n", id.id.cm_handler);
+	kdb_printf("context         : %p\n", id.id.context);
+	sin = (struct sockaddr_in*)&id.id.local_addr;
+	kdb_printf("local_addr      : %d.%d.%d.%d\n", 
+		   NIPQUAD(sin->sin_addr.s_addr));
+	sin = (struct sockaddr_in*)&id.id.remote_addr;
+	kdb_printf("remote_addr     : %d.%d.%d.%d\n", 
+		   NIPQUAD(sin->sin_addr.s_addr));
+	kdb_printf("provider_data   : %p\n", id.id.provider_data);
+	kdb_printf("event_handler   : %p\n", id.id.event_handler);
+	kdb_printf("state           : %s\n", to_iwcm_state_str(id.state));
+	kdb_printf("flags           : %lx\n", id.flags);
+	kdb_printf("qp              : %p\n", id.qp);
+	kdb_printf("refcount        : %d\n", atomic_read(&id.refcount));
+
+	return ret;
+}
+
+
+static int
+print_ib_cq(int argc, const char **argv, const char **envp,
+	    struct pt_regs *regs)
+{
+	int ret = 0;
+	struct ib_cq cq;
+
+	if (argc == 1) {
+		int nextarg = 1;
+		long offset = 0;
+
+		ret = kdbgetaddrarg(argc, argv, &nextarg, &addr, 
+				    &offset, NULL, regs);
+		if (ret) 
+			return ret;
+
+		ret = kdb_getarea_size((void*)&cq, (unsigned long)addr, 
+				       sizeof(struct ib_cq));
+		if (ret)
+			return ret;
+	} 
+
+	kdb_printf("Completion Queue\n"
+		   "----------------------------------------\n");
+	kdb_printf("device		: %p\n",cq.device);
+	kdb_printf("uobject		: %p\n",cq.uobject);
+	kdb_printf("comp_handler	: %p\n",cq.comp_handler);
+	kdb_printf("event_handler	: %p\n",cq.event_handler);
+	kdb_printf("cq_context		: %p\n",cq.cq_context);
+	kdb_printf("cqe			: %d\n",cq.cqe);
+	kdb_printf("usecnt		: %d\n",atomic_read(&cq.usecnt));
+
+	return ret;
+}
+
+static const char *qp_type_str[] = {
+	"IB_QPT_SMI",
+	"IB_QPT_GSI",
+	"IB_QPT_RC",
+	"IB_QPT_UC",
+	"IB_QPT_UD",
+	"IB_QPT_RAW_IPV6",
+	"IB_QPT_RAW_ETY"
+};
+
+static inline const char *qp_type_to_str(int state)
+{
+	if (state < 0 || 
+	    state >= sizeof(qp_type_str)/sizeof(qp_type_str[0]))
+		return "<invalid type>";
+
+	return qp_type_str[state];
+}
+
+static int
+print_ib_qp(int argc, const char **argv, const char **envp,
+	    struct pt_regs *regs)
+{
+	int ret = 0;
+	struct ib_qp qp;
+
+	if (argc == 1) {
+		int nextarg = 1;
+		long offset = 0;
+
+		ret = kdbgetaddrarg(argc, argv, &nextarg, &addr, 
+				    &offset, NULL, regs);
+		if (ret) 
+			return ret;
+
+		ret = kdb_getarea_size((void*)&qp, (unsigned long)addr, 
+				       sizeof(struct ib_qp));
+		if (ret)
+			return ret;
+	} 
+
+	kdb_printf("Queueu Pair\n"
+		   "----------------------------------------\n");
+	kdb_printf("device		: %p\n",qp.device);
+	kdb_printf("pd			: %p\n",qp.pd);
+	kdb_printf("send_cq		: %p\n",qp.send_cq);
+	kdb_printf("recv_cq		: %p\n",qp.recv_cq);
+	kdb_printf("srq			: %p\n",qp.srq);
+	kdb_printf("uobject		: %p\n",qp.uobject);
+	kdb_printf("event_handler	: %p\n",qp.event_handler);
+	kdb_printf("qp_context		: %p\n",qp.qp_context);
+	kdb_printf("qp_num		: %d\n",qp.qp_num);
+	kdb_printf("qp_type		: %s\n",qp_type_to_str(qp.qp_type));
+
+	return ret;
+}
+
+static int
+print_ib_mr(int argc, const char **argv, const char **envp,
+	    struct pt_regs *regs)
+{
+	int ret = 0;
+	struct ib_mr mr;
+
+	if (argc == 1) {
+		int nextarg = 1;
+		long offset = 0;
+
+		ret = kdbgetaddrarg(argc, argv, &nextarg, &addr, 
+				    &offset, NULL, regs);
+		if (ret) 
+			return ret;
+
+		ret = kdb_getarea_size((void*)&mr, (unsigned long)addr, 
+				       sizeof(struct ib_mr));
+		if (ret)
+			return ret;
+	} 
+
+	kdb_printf("Memory Region\n"
+		   "----------------------------------------\n");
+	kdb_printf("device	: %p\n", mr.device);
+	kdb_printf("pd		: %p\n", mr.pd);
+	kdb_printf("uobject	: %p\n", mr.uobject);
+	kdb_printf("lkey	: %08x\n", mr.lkey);
+	kdb_printf("rkey	: %08x\n", mr.rkey);
+	kdb_printf("usecnt	: %d\n", atomic_read(&mr.usecnt));
+
+	return ret;
+}
+
+static int __init rdma_init(void)
+{
+	kdb_register("ib_wc",  
+		     print_ib_wc, "<*ib_wc>", 
+		     "Display the specified IB Work Completion", 0);
+	kdb_register("ib_sge",  
+		     print_ib_sge, "<*ib_sge>", 
+		     "Display the specified IB Scatter Gather Entry", 0);
+	kdb_register("ib_qp",  
+		     print_ib_qp, "<*ib_qp>", 
+		     "Display the specified IB Queue Pair", 0);
+	kdb_register("ib_cq",  
+		     print_ib_cq, "<*ib_cq>", 
+		     "Display the specified IB Completion Queue", 0);
+	kdb_register("ib_mr",  
+		     print_ib_mr, "<*ib_mr>", 
+		     "Display the specified IB Memory Region", 0);
+	kdb_register("iw_cm_id",  
+		     print_iw_cm_id, "<*iw_cm_id>", 
+		     "Display the specified IW CM ID", 0);
+	return 0;
+}
+
+static void __exit rdma_exit(void)
+{
+	kdb_unregister("ib_wc");
+	kdb_unregister("ib_sge");
+}
+
+module_init(rdma_init)
+module_exit(rdma_exit)

> 
> 	#include "iwcm.h"
> 
> Or the file is small enough that maybe it's simpler just to stuff this
> at the top of iwcm.c and kill the include entirely?
> 
>  - R.
> 
>  > --- /dev/null
>  > +++ b/include/rdma/iw_cm_private.h
>  > @@ -0,0 +1,63 @@
>  > +#ifndef IW_CM_PRIVATE_H
>  > +#define IW_CM_PRIVATE_H
>  > +
>  > +#include <rdma/iw_cm.h>
>  > +
>  > +enum iw_cm_state {
>  > +	IW_CM_STATE_IDLE,             /* unbound, inactive */
>  > +	IW_CM_STATE_LISTEN,           /* listen waiting for connect */
>  > +	IW_CM_STATE_CONN_RECV,        /* inbound waiting for user accept */
>  > +	IW_CM_STATE_CONN_SENT,        /* outbound waiting for peer accept */
>  > +	IW_CM_STATE_ESTABLISHED,      /* established */
>  > +	IW_CM_STATE_CLOSING,	      /* disconnect */
>  > +	IW_CM_STATE_DESTROYING        /* object being deleted */
>  > +};
>  > +
>  > +struct iwcm_id_private {
>  > +	struct iw_cm_id	id;
>  > +	enum iw_cm_state state;
>  > +	unsigned long flags;
>  > +	struct ib_qp *qp;
>  > +	struct completion destroy_comp;
>  > +	wait_queue_head_t connect_wait;
>  > +	struct list_head work_list;
>  > +	spinlock_t lock;
>  > +	atomic_t refcount;
>  > +	struct list_head work_free_list;
>  > +};
>  > +#define IWCM_F_CALLBACK_DESTROY   1
>  > +#define IWCM_F_CONNECT_WAIT       2
>  > +
>  > +#endif /* IW_CM_PRIVATE_H */
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

