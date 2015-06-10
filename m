From: Madalin Bucur <madalin.bucur@freescale.com>
Subject: [PATCH 11/12] fsl/fman: Add FMan Port Support
Date: Wed, 10 Jun 2015 18:21:49 +0300
Message-ID: <1433949712-5648-10-git-send-email-madalin.bucur@freescale.com>
References: <1433949712-5648-1-git-send-email-madalin.bucur@freescale.com>
 <1433949712-5648-2-git-send-email-madalin.bucur@freescale.com>
 <1433949712-5648-3-git-send-email-madalin.bucur@freescale.com>
 <1433949712-5648-4-git-send-email-madalin.bucur@freescale.com>
 <1433949712-5648-5-git-send-email-madalin.bucur@freescale.com>
 <1433949712-5648-6-git-send-email-madalin.bucur@freescale.com>
 <1433949712-5648-7-git-send-email-madalin.bucur@freescale.com>
 <1433949712-5648-8-git-send-email-madalin.bucur@freescale.com>
 <1433949712-5648-9-git-send-email-madalin.bucur@freescale.com>
Reply-To: <madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <scottwood@freescale.com>,
	Igal Liberman <Igal.Liberman@freescale.com>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linuxppc-dev@lists.ozlabs.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1433949712-5648-9-git-send-email-madalin.bucur@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Igal Liberman <Igal.Liberman@freescale.com>

This patch adds The FMan Port configuration, initialization and
runtime control routines.

Signed-off-by: Igal Liberman <Igal.Liberman@freescale.com>
---
 drivers/net/ethernet/freescale/fman/Makefile       |    2 +-
 drivers/net/ethernet/freescale/fman/fm.c           |  487 ++++++-
 drivers/net/ethernet/freescale/fman/fm_common.h    |  168 +++
 drivers/net/ethernet/freescale/fman/fm_drv.c       |  108 +-
 drivers/net/ethernet/freescale/fman/fm_drv.h       |    2 +
 drivers/net/ethernet/freescale/fman/fm_port_drv.c  |  496 +++++++
 .../net/ethernet/freescale/fman/inc/fm_port_ext.h  |  376 +++++
 .../net/ethernet/freescale/fman/inc/fsl_fman_drv.h |  101 ++
 drivers/net/ethernet/freescale/fman/port/Makefile  |    2 +-
 drivers/net/ethernet/freescale/fman/port/fm_port.c | 1435 ++++++++++++++++++++
 drivers/net/ethernet/freescale/fman/port/fm_port.h |  527 +++++++
 11 files changed, 3700 insertions(+), 4 deletions(-)
 create mode 100644 drivers/net/ethernet/freescale/fman/fm_port_drv.c
 create mode 100644 drivers/net/ethernet/freescale/fman/inc/fm_port_ext.h
 create mode 100644 drivers/net/ethernet/freescale/fman/port/fm_port.c
 create mode 100644 drivers/net/ethernet/freescale/fman/port/fm_port.h

diff --git a/drivers/net/ethernet/freescale/fman/Makefile b/drivers/net/ethernet/freescale/fman/Makefile
index c6c3e24..8d637e2 100644
--- a/drivers/net/ethernet/freescale/fman/Makefile
+++ b/drivers/net/ethernet/freescale/fman/Makefile
@@ -4,7 +4,7 @@ subdir-ccflags-y += -I$(srctree)/drivers/net/ethernet/freescale/fman/flib \
 
 obj-y		+= fsl_fman.o
 
-fsl_fman-objs	:= fman.o fm_muram.o fm.o fm_drv.o
+fsl_fman-objs	:= fman.o fm_muram.o fm.o fm_drv.o fm_port_drv.o
 
 obj-y	+= port/
 obj-y	+= mac/
diff --git a/drivers/net/ethernet/freescale/fman/fm.c b/drivers/net/ethernet/freescale/fman/fm.c
index fd6de5a..8bafab2 100644
--- a/drivers/net/ethernet/freescale/fman/fm.c
+++ b/drivers/net/ethernet/freescale/fman/fm.c
@@ -459,11 +459,36 @@ static void qmi_err_event(struct fm_t *p_fm)
 
 static void dma_err_event(struct fm_t *p_fm)
 {
-	uint32_t status;
+	uint32_t status, com_id;
+	uint8_t tnum;
+	uint8_t port_id;
+	uint8_t relative_port_id;
+	uint16_t liodn;
 	struct fman_dma_regs __iomem *dma_rg = p_fm->p_fm_dma_regs;
 
 	status = fman_get_dma_err_event(dma_rg);
 
+	if (status & DMA_STATUS_BUS_ERR) {
+		com_id = fman_get_dma_com_id(dma_rg);
+		port_id = (uint8_t)(((com_id & DMA_TRANSFER_PORTID_MASK) >>
+						DMA_TRANSFER_PORTID_SHIFT));
+		HW_PORT_ID_TO_SW_PORT_ID(p_fm->p_fm_state_struct->rev_info.
+					 major_rev,
+					 relative_port_id,
+					 port_id);
+		tnum =
+		    (uint8_t)((com_id & DMA_TRANSFER_TNUM_MASK) >>
+			       DMA_TRANSFER_TNUM_SHIFT);
+		liodn = (uint16_t)(com_id & DMA_TRANSFER_LIODN_MASK);
+		ASSERT(p_fm->p_fm_state_struct->
+			    ports_types[port_id] !=
+			    FM_PORT_TYPE_DUMMY);
+		p_fm->f_bus_error(p_fm->h_app,
+				 p_fm->p_fm_state_struct->
+				 ports_types[port_id],
+				 relative_port_id,
+				 fman_get_dma_addr(dma_rg), tnum, liodn);
+	}
 	if (status & DMA_STATUS_FM_SPDAT_ECC)
 		p_fm->f_exception(p_fm->h_app, FM_EX_DMA_SINGLE_PORT_ECC);
 	if (status & DMA_STATUS_READ_ECC)
@@ -764,6 +789,462 @@ uint8_t fm_get_id(struct fm_t *p_fm)
 	return p_fm->p_fm_state_struct->fm_id;
 }
 
+int fm_get_set_port_params(struct fm_t *p_fm,
+			   struct fm_inter_module_port_init_params_t
+			   *p_port_params)
+{
+	int err;
+	unsigned long int_flags;
+	uint8_t port_id = p_port_params->port_id, mac_id;
+	struct fman_rg fman_rg;
+
+	fman_rg.bmi_rg = p_fm->p_fm_bmi_regs;
+	fman_rg.qmi_rg = p_fm->p_fm_qmi_regs;
+	fman_rg.fpm_rg = p_fm->p_fm_fpm_regs;
+	fman_rg.dma_rg = p_fm->p_fm_dma_regs;
+
+	ASSERT(IN_RANGE(1, port_id, 63));
+
+	spin_lock_irqsave(p_fm->spinlock, int_flags);
+
+	p_fm->p_fm_state_struct->ports_types[port_id] =
+	    p_port_params->port_type;
+
+	err =
+	    fm_set_num_of_tasks(p_fm, p_port_params->port_id,
+				&p_port_params->num_of_tasks,
+				&p_port_params->num_of_extra_tasks, true);
+	if (err) {
+		spin_unlock_irqrestore(p_fm->spinlock, int_flags);
+		return err;
+	}
+#ifdef FM_QMI_NO_DEQ_OPTIONS_SUPPORT
+	if (p_fm->p_fm_state_struct->rev_info.major_rev != 4)
+#endif /* FM_QMI_NO_DEQ_OPTIONS_SUPPORT */
+		/* for transmit&O/H ports */
+		if (p_port_params->port_type != FM_PORT_TYPE_RX) {
+			uint8_t enq_th;
+			uint8_t deq_th;
+
+			/* update qmi ENQ/DEQ threshold */
+			p_fm->p_fm_state_struct->accumulated_num_of_deq_tnums +=
+			    p_port_params->deq_pipeline_depth;
+			enq_th = fman_get_qmi_enq_th(fman_rg.qmi_rg);
+			/* if enq_th is too big, we reduce it to the max value
+			 * that is still 0
+			 */
+			if (enq_th >=
+			    (p_fm->intg->qmi_max_num_of_tnums -
+			     p_fm->p_fm_state_struct->
+			     accumulated_num_of_deq_tnums)) {
+				enq_th = (uint8_t)(
+					p_fm->intg->
+						qmi_max_num_of_tnums -
+					p_fm->p_fm_state_struct->
+					accumulated_num_of_deq_tnums - 1);
+				fman_set_qmi_enq_th(fman_rg.qmi_rg, enq_th);
+			}
+
+			deq_th = fman_get_qmi_deq_th(fman_rg.qmi_rg);
+			/* if deq_th is too small, we enlarge it to the min
+			 * value that is still 0.
+			 * depTh may not be larger than 63
+			 * (p_fm->intg->qmi_max_num_of_tnums-1).
+			 */
+			if ((deq_th <=
+				p_fm->p_fm_state_struct->
+						accumulated_num_of_deq_tnums) &&
+				(deq_th <
+					p_fm->intg->
+						qmi_max_num_of_tnums - 1)) {
+					deq_th = (uint8_t)(p_fm->
+						  p_fm_state_struct->
+						  accumulated_num_of_deq_tnums
+						  + 1);
+				fman_set_qmi_deq_th(fman_rg.qmi_rg, deq_th);
+			}
+		}
+#ifdef FM_LOW_END_RESTRICTION
+	if (p_fm->p_fm_state_struct->rev_info.major_rev == 0x4) {
+		if ((port_id == 0x1) || (port_id == 0x29)) {
+			if (p_fm->p_fm_state_struct->low_end_restriction) {
+				spin_unlock_irqrestore(p_fm->spinlock,
+						       int_flags);
+				pr_err("OP#0 can't work with Tx Port1\n");
+				return -EAGAIN;
+			}
+			p_fm->p_fm_state_struct->low_end_restriction = true;
+			}
+		}
+#endif /* FM_LOW_END_RESTRICTION */
+
+	err = fm_set_size_of_fifo(p_fm,
+				  p_port_params->port_id,
+				  &p_port_params->size_of_fifo,
+				  &p_port_params->extra_size_of_fifo, true);
+	if (err) {
+		spin_unlock_irqrestore(p_fm->spinlock, int_flags);
+		return err;
+	}
+
+	err = fm_set_num_of_open_dmas(p_fm,
+				      p_port_params->port_id,
+				      &p_port_params->num_of_open_dmas,
+				      &p_port_params->num_of_extra_open_dmas,
+				      true);
+	if (err) {
+		spin_unlock_irqrestore(p_fm->spinlock,
+				       (unsigned long)int_flags);
+		return err;
+	}
+
+	fman_set_liodn_per_port(&fman_rg,
+				port_id,
+				p_port_params->liodn_base,
+				p_port_params->liodn_offset);
+
+	if (p_fm->p_fm_state_struct->rev_info.major_rev < 6)
+		fman_set_order_restoration_per_port(fman_rg.fpm_rg,
+						    port_id,
+						    !!((p_port_params->
+							 port_type ==
+							 FM_PORT_TYPE_RX)));
+
+	HW_PORT_ID_TO_SW_PORT_ID(p_fm->p_fm_state_struct->rev_info.major_rev,
+				 mac_id,
+				 port_id);
+
+	if (p_port_params->max_frame_length >=
+	    p_fm->p_fm_state_struct->mac_max_frame_lengths[mac_id]) {
+		p_fm->p_fm_state_struct->port_max_frame_lengths[mac_id] =
+					p_port_params->max_frame_length;
+	} else {
+		pr_warn("Port max_frame_length is smaller than MAC current MTU\n");
+		spin_unlock_irqrestore(p_fm->spinlock,
+				       (unsigned long)int_flags);
+		return -EDOM;
+	}
+
+	spin_unlock_irqrestore(p_fm->spinlock, (unsigned long)int_flags);
+
+	return 0;
+}
+
+void fm_free_port_params(struct fm_t *p_fm,
+			 struct fm_inter_module_port_free_params_t
+			 *p_port_params)
+{
+	unsigned long int_flags;
+	uint8_t port_id = p_port_params->port_id;
+	uint8_t num_of_tasks, num_of_dmas, mac_id;
+	uint16_t size_of_fifo;
+	struct fman_qmi_regs __iomem *qmi_rg = p_fm->p_fm_qmi_regs;
+	struct fman_bmi_regs __iomem *bmi_rg = p_fm->p_fm_bmi_regs;
+
+	ASSERT(IN_RANGE(1, port_id, 63));
+
+	spin_lock_irqsave(p_fm->spinlock, int_flags);
+
+	p_fm->p_fm_state_struct->ports_types[port_id] =
+	    FM_PORT_TYPE_DUMMY;
+
+	/* free num_of_tasks */
+	num_of_tasks = fman_get_num_of_tasks(bmi_rg, port_id);
+	ASSERT(p_fm->p_fm_state_struct->accumulated_num_of_tasks >=
+		    num_of_tasks);
+	p_fm->p_fm_state_struct->accumulated_num_of_tasks -= num_of_tasks;
+
+	/* free num_of_open_dmas */
+	num_of_dmas = fman_get_num_of_dmas(bmi_rg, port_id);
+	ASSERT(p_fm->p_fm_state_struct->accumulated_num_of_open_dmas >=
+		    num_of_dmas);
+	p_fm->p_fm_state_struct->accumulated_num_of_open_dmas -= num_of_dmas;
+
+#ifdef FM_HAS_TOTAL_DMAS
+	if (p_fm->p_fm_state_struct->rev_info.major_rev < 6) {
+		/* update total num of DMA's with committed number
+		 * of open DMAS, and max uncommitted pool.
+		 */
+		fman_set_num_of_open_dmas(bmi_rg,
+					  port_id,
+					  1,
+					  0,
+					  (uint8_t)
+					  (p_fm->p_fm_state_struct->
+					   accumulated_num_of_open_dmas +
+						     p_fm->p_fm_state_struct->
+						     extra_open_dmas_pool_size
+						     ));
+	}
+#endif /* FM_HAS_TOTAL_DMAS */
+
+	/* free size_of_fifo */
+	size_of_fifo = fman_get_size_of_fifo(bmi_rg, port_id);
+	ASSERT(p_fm->p_fm_state_struct->accumulated_fifo_size >=
+		(size_of_fifo * BMI_FIFO_UNITS));
+	p_fm->p_fm_state_struct->accumulated_fifo_size -=
+		(size_of_fifo * BMI_FIFO_UNITS);
+
+#ifdef FM_QMI_NO_DEQ_OPTIONS_SUPPORT
+	if (p_fm->p_fm_state_struct->rev_info.major_rev != 4)
+#endif /* FM_QMI_NO_DEQ_OPTIONS_SUPPORT */
+		/* for transmit&O/H ports */
+		if (p_port_params->port_type != FM_PORT_TYPE_RX) {
+			uint8_t enq_th;
+			uint8_t deq_th;
+
+			/* update qmi ENQ/DEQ threshold */
+			p_fm->p_fm_state_struct->accumulated_num_of_deq_tnums -=
+			    p_port_params->deq_pipeline_depth;
+
+			/* p_fm->p_fm_state_struct->
+			 * accumulated_num_of_deq_tnums is now smaller,
+			 * so we can enlarge enq_th
+			 */
+			enq_th =
+			    (uint8_t)(p_fm->intg->qmi_max_num_of_tnums -
+				       p_fm->p_fm_state_struct->
+				       accumulated_num_of_deq_tnums - 1);
+
+			/* p_fm->p_fm_state_struct->
+			 * accumulated_num_of_deq_tnums is now smaller,
+			 * so we can reduce deq_th
+			 */
+			deq_th =
+			    (uint8_t)(p_fm->p_fm_state_struct->
+				       accumulated_num_of_deq_tnums + 1);
+
+			fman_set_qmi_enq_th(qmi_rg, enq_th);
+			fman_set_qmi_deq_th(qmi_rg, deq_th);
+		}
+
+	HW_PORT_ID_TO_SW_PORT_ID(p_fm->p_fm_state_struct->rev_info.major_rev,
+				 mac_id,
+				 port_id);
+
+	p_fm->p_fm_state_struct->port_max_frame_lengths[mac_id] = 0;
+
+#ifdef FM_LOW_END_RESTRICTION
+	if (p_fm->p_fm_state_struct->rev_info.major_rev == 0x4) {
+		if ((port_id == 0x1) || (port_id == 0x29))
+			p_fm->p_fm_state_struct->low_end_restriction = false;
+	}
+#endif /* FM_LOW_END_RESTRICTION */
+	spin_unlock_irqrestore(p_fm->spinlock, int_flags);
+}
+
+int fm_set_size_of_fifo(struct fm_t *p_fm,
+			uint8_t port_id,
+			uint32_t *p_size_of_fifo,
+			uint32_t *p_extra_size_of_fifo,
+			bool initial_config)
+{
+	struct fman_bmi_regs __iomem *bmi_rg = p_fm->p_fm_bmi_regs;
+	uint32_t size_of_fifo = *p_size_of_fifo, extra_size_of_fifo =
+	    *p_extra_size_of_fifo;
+	uint16_t current_val = 0, current_extra_val = 0;
+
+	ASSERT(IN_RANGE(1, port_id, 63));
+
+	if (!initial_config) {
+		/* !initial_config - runtime change of existing value.
+		 * - read the current FIFO and extra FIFO size
+		 */
+		current_extra_val =
+		    fman_get_size_of_extra_fifo(bmi_rg, port_id);
+		current_val = fman_get_size_of_fifo(bmi_rg, port_id);
+	}
+
+	if (extra_size_of_fifo > current_extra_val) {
+		if (extra_size_of_fifo &&
+		    !p_fm->p_fm_state_struct->extra_fifo_pool_size)
+			/* if this is the first time a port
+			 * requires extra_fifo_pool_size,
+			 * the total extra_fifo_pool_size
+			 * must be initialized to 1 buffer per port
+			 */
+			p_fm->p_fm_state_struct->extra_fifo_pool_size =
+			p_fm->intg->num_of_rx_ports * BMI_FIFO_UNITS;
+
+		p_fm->p_fm_state_struct->extra_fifo_pool_size =
+			max(p_fm->p_fm_state_struct->extra_fifo_pool_size,
+			    extra_size_of_fifo);
+	}
+
+	/* check that there are enough uncommitted fifo size */
+	if ((p_fm->p_fm_state_struct->accumulated_fifo_size - current_val +
+	     size_of_fifo) >
+	    (p_fm->p_fm_state_struct->total_fifo_size -
+	     p_fm->p_fm_state_struct->extra_fifo_pool_size)) {
+		pr_err("Requested fifo size and extra size exceed total FIFO size.\n");
+		return -EAGAIN;
+	}
+	/* update accumulated */
+	ASSERT(p_fm->p_fm_state_struct->accumulated_fifo_size >=
+		    current_val);
+	p_fm->p_fm_state_struct->accumulated_fifo_size -= current_val;
+	p_fm->p_fm_state_struct->accumulated_fifo_size += size_of_fifo;
+	fman_set_size_of_fifo(bmi_rg, port_id, size_of_fifo,
+			      extra_size_of_fifo);
+
+	return 0;
+}
+
+int fm_set_num_of_tasks(struct fm_t *p_fm,
+			uint8_t port_id,
+			uint8_t *p_num_of_tasks,
+			uint8_t *p_num_of_extra_tasks, bool initial_config)
+{
+	struct fman_bmi_regs __iomem *bmi_rg = p_fm->p_fm_bmi_regs;
+	uint8_t current_val = 0, current_extra_val = 0, num_of_tasks =
+	    *p_num_of_tasks, num_of_extra_tasks = *p_num_of_extra_tasks;
+
+	ASSERT(IN_RANGE(1, port_id, 63));
+
+	if (!initial_config) {
+		/* !initial_config - runtime change of existing value.
+		 * - read the current number of tasks
+		 */
+		current_val = fman_get_num_of_tasks(bmi_rg, port_id);
+		current_extra_val =
+		    fman_get_num_extra_tasks(bmi_rg, port_id);
+	}
+
+	if (num_of_extra_tasks > current_extra_val)
+		p_fm->p_fm_state_struct->extra_tasks_pool_size =
+		(uint8_t)max(p_fm->p_fm_state_struct->extra_tasks_pool_size,
+			     num_of_extra_tasks);
+
+	/* check that there are enough uncommitted tasks */
+	if ((p_fm->p_fm_state_struct->accumulated_num_of_tasks - current_val +
+	     num_of_tasks) >
+	    (p_fm->p_fm_state_struct->total_num_of_tasks -
+	     p_fm->p_fm_state_struct->extra_tasks_pool_size)) {
+		pr_err("Requested num_of_tasks and extra tasks pool for fm%d exceed total num_of_tasks.\n",
+		       p_fm->p_fm_state_struct->fm_id);
+		return -EAGAIN;
+	}
+	ASSERT(p_fm->p_fm_state_struct->
+		    accumulated_num_of_tasks >=
+		    current_val);
+	/* update accumulated */
+	p_fm->p_fm_state_struct->accumulated_num_of_tasks -=
+	current_val;
+	p_fm->p_fm_state_struct->accumulated_num_of_tasks +=
+	num_of_tasks;
+	fman_set_num_of_tasks(bmi_rg, port_id, num_of_tasks,
+			      num_of_extra_tasks);
+
+	return 0;
+}
+
+int fm_set_num_of_open_dmas(struct fm_t *p_fm,
+			    uint8_t port_id,
+			    uint8_t *p_num_of_open_dmas,
+			    uint8_t *p_num_of_extra_open_dmas,
+			    bool initial_config)
+{
+	struct fman_bmi_regs __iomem *bmi_rg = p_fm->p_fm_bmi_regs;
+	uint8_t num_of_open_dmas = *p_num_of_open_dmas,
+	num_of_extra_open_dmas = *p_num_of_extra_open_dmas;
+	uint8_t total_num_dmas = 0, current_val = 0, current_extra_val = 0;
+
+	ASSERT(IN_RANGE(1, port_id, 63));
+
+	if (!initial_config) {
+		/* !initial_config - runtime change of existing value.
+		* - read the current number of open Dma's
+		*/
+		current_extra_val =
+		    fman_get_num_extra_dmas(bmi_rg, port_id);
+		current_val = fman_get_num_of_dmas(bmi_rg, port_id);
+	}
+
+	/* it's illegal to be in a state where this is
+	 * not the first set and no value is specified
+	 */
+	ASSERT(initial_config || num_of_open_dmas);
+	if (!num_of_open_dmas) {
+		/* !num_of_open_dmas - first configuration according
+		 * to values in regs.- read the current number of
+		 * open Dma's
+		 */
+		current_extra_val =
+		    fman_get_num_extra_dmas(bmi_rg, port_id);
+		current_val = fman_get_num_of_dmas(bmi_rg, port_id);
+		/* This is the first configuration and user did not
+		 * specify value (!num_of_open_dmas), reset values will be used
+		 * and we just save these values for resource management
+		 */
+		p_fm->p_fm_state_struct->extra_open_dmas_pool_size =
+			(uint8_t)max(p_fm->p_fm_state_struct->
+				     extra_open_dmas_pool_size,
+				     current_extra_val);
+		p_fm->p_fm_state_struct->accumulated_num_of_open_dmas +=
+		current_val;
+		*p_num_of_open_dmas = current_val;
+		*p_num_of_extra_open_dmas = current_extra_val;
+		return 0;
+	}
+
+	if (num_of_extra_open_dmas > current_extra_val)
+		p_fm->p_fm_state_struct->extra_open_dmas_pool_size =
+		    (uint8_t)max(p_fm->p_fm_state_struct->
+				 extra_open_dmas_pool_size,
+				 num_of_extra_open_dmas);
+
+#ifdef FM_HAS_TOTAL_DMAS
+	if ((p_fm->p_fm_state_struct->rev_info.major_rev < 6) &&
+	    (p_fm->p_fm_state_struct->accumulated_num_of_open_dmas -
+	     current_val + num_of_open_dmas >
+	     p_fm->p_fm_state_struct->max_num_of_open_dmas)) {
+		pr_err("Requested num_of_open_dmas for fm%d exceeds total num_of_open_dmas.\n",
+		       p_fm->p_fm_state_struct->fm_id);
+		return -EAGAIN;
+	}
+#else
+	if ((p_fm->p_fm_state_struct->rev_info.major_rev >= 6) &&
+	    #ifdef FM_HEAVY_TRAFFIC_SEQUENCER_HANG_ERRATA_FMAN_A006981
+	    !((p_fm->p_fm_state_struct->rev_info.major_rev == 6) &&
+	      (p_fm->p_fm_state_struct->rev_info.minor_rev == 0)) &&
+#endif /* FM_HEAVY_TRAFFIC_SEQUENCER_HANG_ERRATA_FMAN_A006981 */
+	    (p_fm->p_fm_state_struct->accumulated_num_of_open_dmas -
+	     current_val + num_of_open_dmas >
+	     p_fm->intg->dma_thresh_max_commq + 1)) {
+		pr_err("Requested num_of_open_dmas for fm%d exceeds DMA Command queue (%d)\n",
+		       p_fm->p_fm_state_struct->fm_id,
+		       p_fm->intg->dma_thresh_max_commq + 1);
+		return -EAGAIN;
+	}
+#endif /* FM_HAS_TOTAL_DMAS */
+	else {
+		ASSERT(p_fm->p_fm_state_struct->
+			    accumulated_num_of_open_dmas >=
+			    current_val);
+		/* update acummulated */
+		p_fm->p_fm_state_struct->accumulated_num_of_open_dmas -=
+		current_val;
+		p_fm->p_fm_state_struct->accumulated_num_of_open_dmas +=
+		    num_of_open_dmas;
+
+#ifdef FM_HAS_TOTAL_DMAS
+		if (p_fm->p_fm_state_struct->rev_info.major_rev < 6)
+			total_num_dmas =
+			    (uint8_t)(p_fm->p_fm_state_struct->
+				       accumulated_num_of_open_dmas +
+				       p_fm->p_fm_state_struct->
+				       extra_open_dmas_pool_size);
+#endif /* FM_HAS_TOTAL_DMAS */
+		fman_set_num_of_open_dmas(bmi_rg,
+					  port_id,
+					  num_of_open_dmas,
+					  num_of_extra_open_dmas,
+					  total_num_dmas);
+	}
+
+	return 0;
+}
+
 int fm_reset_mac(struct fm_t *p_fm, uint8_t mac_id)
 {
 	int err;
@@ -908,6 +1389,7 @@ static int init_fm_qmi(struct fm_t *p_fm)
 void *fm_config(struct fm_params_t *p_fm_param)
 {
 	struct fm_t *p_fm;
+	uint8_t i;
 	uintptr_t base_addr;
 
 	if (!((p_fm_param->firmware.p_code && p_fm_param->firmware.size) ||
@@ -932,6 +1414,9 @@ void *fm_config(struct fm_params_t *p_fm_param)
 	/* Initialize FM parameters which will be kept by the driver */
 	p_fm->p_fm_state_struct->fm_id = p_fm_param->fm_id;
 
+	for (i = 0; i < FM_MAX_NUM_OF_HW_PORT_IDS; i++)
+		p_fm->p_fm_state_struct->ports_types[i] = FM_PORT_TYPE_DUMMY;
+
 	/* Allocate the FM driver's parameters structure */
 	p_fm->p_fm_drv_param = kzalloc(sizeof(*p_fm->p_fm_drv_param),
 						 GFP_KERNEL);
diff --git a/drivers/net/ethernet/freescale/fman/fm_common.h b/drivers/net/ethernet/freescale/fman/fm_common.h
index 45c450b..af9ba6a 100644
--- a/drivers/net/ethernet/freescale/fman/fm_common.h
+++ b/drivers/net/ethernet/freescale/fman/fm_common.h
@@ -82,6 +82,14 @@
 
 #define CLS_PLAN_NUM_PER_GRP                        8
 
+/* Defines used for manipulation CC and BMI */
+#define UPDATE_NIA_PNEN                         0x80000000
+#define UPDATE_NIA_PNDN                         0x20000000
+#define UPDATE_FMFP_PRC_WITH_ONE_RISC_ONLY      0x10000000
+#define UPDATE_NIA_FENE                         0x04000000
+#define UPDATE_NIA_CMNE                         0x02000000
+#define UPDATE_NIA_FPNE                         0x01000000
+
 /* list_object
  * Macro to get the struct (object) for this entry.
  * type   - The type of the struct (object) this list
@@ -94,6 +102,12 @@
 #define list_object(p_list, type, member) \
 ((type *)((char *)(p_list) - member_offset(type, member)))
 
+#define FM_LIODN_OFFSET_MASK    0x3FF
+
+/* NIA Description */
+/* V3 only */
+#define NIA_FM_CTL_AC_NO_IPACC_PRE_BMI_ENQ_FRAME        0x00000028
+
 /* Enum for inter-module interrupts registration */
 enum fm_event_modules {
 	FM_MOD_PRS = 0,		/* Parser event */
@@ -209,6 +223,59 @@ static inline bool TRY_LOCK(spinlock_t *spinlock, volatile bool *p_flag)
 
 #define FM_LIODN_OFFSET_MASK    0x3FF
 
+/* NIA Description */
+#define NIA_ENG_MASK                0x007C0000
+#define NIA_AC_MASK                 0x0003ffff
+
+#define NIA_ORDER_RESTOR            0x00800000
+#define NIA_ENG_FM_CTL              0x00000000
+#define NIA_ENG_PRS                 0x00440000
+#define NIA_ENG_BMI                 0x00500000
+#define NIA_ENG_QMI_ENQ             0x00540000
+#define NIA_ENG_QMI_DEQ             0x00580000
+
+#define NIA_FM_CTL_AC_HC                        0x0000000C
+#define NIA_FM_CTL_AC_IND_MODE_TX               0x00000008
+#define NIA_FM_CTL_AC_IND_MODE_RX               0x0000000A
+#define NIA_FM_CTL_AC_POP_TO_N_STEP             0x0000000e
+#define NIA_FM_CTL_AC_PRE_BMI_FETCH_HEADER      0x00000010
+#define NIA_FM_CTL_AC_PRE_BMI_FETCH_FULL_FRAME  0x00000018
+#define NIA_FM_CTL_AC_POST_BMI_FETCH            0x00000012
+#define NIA_FM_CTL_AC_PRE_BMI_ENQ_FRAME         0x0000001A
+#define NIA_FM_CTL_AC_PRE_BMI_DISCARD_FRAME     0x0000001E
+#define NIA_FM_CTL_AC_POST_BMI_ENQ_ORR          0x00000014
+#define NIA_FM_CTL_AC_POST_BMI_ENQ              0x00000022
+#define NIA_FM_CTL_AC_POST_TX                   0x00000024
+/* V3 only */
+#define NIA_FM_CTL_AC_NO_IPACC_PRE_BMI_ENQ_FRAME        0x00000028
+#define NIA_FM_CTL_AC_NO_IPACC_PRE_BMI_DISCARD_FRAME    0x0000002A
+#define NIA_FM_CTL_AC_NO_IPACC_POP_TO_N_STEP            0x0000002C
+
+#define NIA_BMI_AC_ENQ_FRAME        0x00000002
+#define NIA_BMI_AC_TX_RELEASE       0x000002C0
+#define NIA_BMI_AC_RELEASE          0x000000C0
+#define NIA_BMI_AC_DISCARD          0x000000C1
+#define NIA_BMI_AC_TX               0x00000274
+#define NIA_BMI_AC_FETCH            0x00000208
+#define NIA_BMI_AC_MASK             0x000003FF
+
+#define NIA_BMI_AC_ENQ_FRAME_WITHOUT_DMA    0x00000202
+
+#define GET_NIA_BMI_AC_ENQ_FRAME(GET_NIA_BMI_AC_ENQ_FRAME, errata_A006675)\
+	(errata_A006675 ?						\
+	((uint32_t)(NIA_ENG_FM_CTL |					\
+		NIA_FM_CTL_AC_NO_IPACC_PRE_BMI_ENQ_FRAME)) :		\
+	((uint32_t)(NIA_ENG_BMI | NIA_BMI_AC_ENQ_FRAME)))
+#define GET_NIA_BMI_AC_DISCARD_FRAME(h_fm_pcd, errata_A006675)	\
+	(errata_A006675 ?						\
+	((uint32_t)(NIA_ENG_FM_CTL |					\
+		NIA_FM_CTL_AC_NO_IPACC_PRE_BMI_DISCARD_FRAME)) :	\
+	((uint32_t)(NIA_ENG_BMI | NIA_BMI_AC_DISCARD)))
+#define GET_NO_PCD_NIA_BMI_AC_ENQ_FRAME(errata_A006675)		\
+	(errata_A006675 ?						\
+	(NIA_ENG_FM_CTL | NIA_FM_CTL_AC_NO_IPACC_PRE_BMI_ENQ_FRAME) :\
+	(NIA_ENG_BMI | NIA_BMI_AC_ENQ_FRAME))
+
 /* Description        CTRL Parameters Page defines */
 #define FM_CTL_PARAMS_PAGE_OP_FIX_EN            0x80000000
 #define FM_CTL_PARAMS_PAGE_ALWAYS_ON            0x00000100
@@ -239,6 +306,20 @@ do {									\
 	}								\
 } while (0)
 
+#define HW_PORT_ID_TO_SW_PORT_ID(major, _mac_id, port_id)		\
+do {									\
+	if (port_id >= BASE_TX_PORTID)					\
+		_mac_id = (uint8_t)(port_id - BASE_TX_PORTID);		\
+	else if (port_id >= BASE_RX_PORTID)				\
+		_mac_id = (uint8_t)(port_id - BASE_RX_PORTID);		\
+	else if (port_id >= BASE_OH_PORTID(major))			\
+		_mac_id = (uint8_t)(port_id - BASE_OH_PORTID(major));	\
+	else {								\
+		_mac_id = (uint8_t)DUMMY_PORT_ID;			\
+		ASSERT(true);						\
+	}								\
+} while (0)
+
 #define BMI_MAX_FIFO_SIZE                   (FM_MURAM_SIZE)
 #define BMI_FIFO_UNITS                      0x100
 
@@ -337,6 +418,53 @@ enum fm_mac_type {
 	FM_MAC_1G	    /* 1G MAC */
 };
 
+/* Description   Structure for port-FM communication
+ * during fm_port_init. Fields commented 'IN' are passed
+ * by the port module to be used by the FM module.
+ * Fields commented 'OUT' will be filled by FM before returning to port.
+ * Some fields are optional (depending on configuration) and
+ * will be analized by the port and FM modules accordingly.
+ */
+struct fm_inter_module_port_init_params_t {
+	uint8_t port_id;
+	/* IN. port Id */
+	enum fm_port_type port_type;
+	/* IN. Port type */
+	enum fm_port_speed port_speed;
+	/* IN. Port speed */
+	/* IN. Port's requested resource*/
+	uint16_t liodn_offset;
+	/* IN. Port's requested resource */
+	uint8_t num_of_tasks;
+	/* IN. Port's requested resource */
+	uint8_t num_of_extra_tasks;
+	/* IN. Port's requested resource */
+	uint8_t num_of_open_dmas;
+	/* IN. Port's requested resource */
+	uint8_t num_of_extra_open_dmas;
+	/* IN. Port's requested resource */
+	uint32_t size_of_fifo;
+	/* IN. Port's requested resource */
+	uint32_t extra_size_of_fifo;
+	/* IN. Port's requested resource */
+	uint8_t deq_pipeline_depth;
+	/* IN. Port's max frame length. */
+	uint16_t max_frame_length;
+	/* IN. Irrelevant for P4080 rev 1.
+	 * LIODN base for this port, to be
+	 * used together with LIODN offset.
+	 */
+	uint16_t liodn_base;
+};
+
+/* Description   Structure for port-FM communication during fm_port_free.*/
+struct fm_inter_module_port_free_params_t {
+	uint8_t port_id;		/* IN. port Id */
+	enum fm_port_type port_type;	/* IN. Port type */
+	enum fm_port_speed port_speed;	/* IN. Port speed */
+	uint8_t deq_pipeline_depth;	/* IN. Port's requested resource */
+};
+
 /* Function      fm_get_muram_pointer
  * Description   Get the pointer of the MURAM from the FM module
  * Param[in]     h_fm            A handle to an FM Module.
@@ -379,6 +507,29 @@ uint16_t fm_get_clock_freq(struct fm_t *p_fm);
  */
 uint8_t fm_get_id(struct fm_t *p_fm);
 
+/* Function      fm_get_set_port_params
+ * Description   Used by FM-PORT driver to pass and receive parameters between
+ *		PORT and FM modules.
+ * Param[in]     h_fm            A handle to an FM Module.
+ * Param[in,out] p_port_params    A structure of FM Port parameters.
+ * Return        0 on success; Error code otherwise.
+ * Cautions      Allowed only following fm_init().
+ */
+int fm_get_set_port_params(struct fm_t *p_fm,
+			   struct fm_inter_module_port_init_params_t
+			   *p_port_params);
+
+/* Function      fm_free_port_params
+ * Description   Used by FM-PORT driver to free port's resources within the FM.
+ * Param[in]     h_fm            A handle to an FM Module.
+ * Param[in,out] p_port_params    A structure of FM Port parameters.
+ * Return        None.
+ * Cautions      Allowed only following fm_init().
+ */
+void fm_free_port_params(struct fm_t *p_fm,
+			 struct fm_inter_module_port_free_params_t
+			 *p_port_params);
+
 #ifdef FM_TX_ECC_FRMS_ERRATA_10GMAC_A004
 int fm_10g_tx_ecc_workaround(struct fm_t *p_fm, uint8_t mac_id);
 #endif /* FM_TX_ECC_FRMS_ERRATA_10GMAC_A004 */
@@ -404,5 +555,22 @@ struct num_of_ports_info_t *fm_get_num_of_ports(struct fm_t *p_fm);
 
 int fm_set_mac_max_frame(struct fm_t *p_fm, enum fm_mac_type type,
 			 uint8_t mac_id, uint16_t mtu);
+int fm_set_num_of_open_dmas(struct fm_t *p_fm,
+			    uint8_t port_id,
+			    uint8_t *p_num_of_open_dmas,
+			    uint8_t *p_num_of_extra_open_dmas,
+			    bool initial_config);
+int fm_set_num_of_tasks(struct fm_t *p_fm,
+			uint8_t port_id,
+			uint8_t *p_num_of_tasks,
+			uint8_t *p_num_of_extra_tasks,
+			bool initial_config);
+int fm_set_size_of_fifo(struct fm_t *p_fm,
+			uint8_t port_id,
+			uint32_t *p_size_of_fifo,
+			uint32_t *p_extra_size_of_fifo,
+			bool initial_config);
+
+uint32_t fm_get_bmi_max_fifo_size(struct fm_t *p_fm);
 
 #endif /* __FM_COMMON_H */
diff --git a/drivers/net/ethernet/freescale/fman/fm_drv.c b/drivers/net/ethernet/freescale/fman/fm_drv.c
index 2c78829..c0a2c70 100644
--- a/drivers/net/ethernet/freescale/fman/fm_drv.c
+++ b/drivers/net/ethernet/freescale/fman/fm_drv.c
@@ -217,6 +217,72 @@ static void destroy_fm_dev(struct fm_drv_t *p_fm_drv)
 	kfree(p_fm_drv);
 }
 
+static int fill_rest_fm_info(struct fm_drv_t *p_fm_drv)
+{
+#define FM_BMI_PPIDS_OFFSET                 0x00080304
+#define FM_DMA_PLR_OFFSET                   0x000c2060
+#define FM_FPM_IP_REV_1_OFFSET              0x000c30c4
+#define DMA_HIGH_LIODN_MASK                 0x0FFF0000
+#define DMA_LOW_LIODN_MASK                  0x00000FFF
+#define DMA_LIODN_SHIFT                     16
+
+/* These need to be moved to FLib: */
+	struct plr_t {
+		uint32_t plr[32];
+	} __attribute__((__packed__));
+
+	struct ppids_t {
+		volatile uint32_t fmbm_ppid[63];
+	} __attribute__((__packed__));
+
+	struct plr_t *p_plr;
+	struct ppids_t *p_ppids;
+	int i;
+	uint32_t fm_rev;
+
+	fm_rev = (uint32_t)(*((volatile uint32_t *)
+				UINT_TO_PTR(p_fm_drv->fm_base_addr +
+					    FM_FPM_IP_REV_1_OFFSET)));
+	fm_rev &= 0xffff;
+
+	p_plr =
+	    (struct plr_t *)UINT_TO_PTR(p_fm_drv->fm_base_addr +
+				  FM_DMA_PLR_OFFSET);
+#ifdef MODULE
+	for (i = 0; i < FM_MAX_NUM_OF_PARTITIONS / 2; i++)
+		p_plr->plr[i] = 0;
+#endif /* MODULE */
+
+	for (i = 0; i < FM_MAX_NUM_OF_PARTITIONS; i++) {
+		uint16_t liodn_base;
+
+		liodn_base = (uint16_t)((i % 2) ?
+				(p_plr->plr[i / 2] & DMA_LOW_LIODN_MASK) :
+				((p_plr->plr[i / 2] & DMA_HIGH_LIODN_MASK) >>
+				DMA_LIODN_SHIFT));
+#ifdef FM_PARTITION_ARRAY
+		p_fm_drv->params.liodn_base_per_port[i] = liodn_base;
+#endif /* FM_PARTITION_ARRAY */
+
+		if (((i >= FIRST_RX_PORT) && (i <= LAST_RX_PORT)) ||
+		    ((i >= FIRST_TX_PORT) && (i <= LAST_TX_PORT)) ||
+		    ((i >= FIRST_OP_PORT(
+			    p_fm_drv->fm_rev_info.major_rev)) &&
+		    (i <= LAST_OP_PORT)))
+			p_fm_drv->ports[i].port_params.liodn_base =
+			liodn_base;
+	}
+
+	p_ppids = (struct ppids_t *)
+		UINT_TO_PTR(p_fm_drv->fm_base_addr + FM_BMI_PPIDS_OFFSET);
+
+	for (i = FIRST_RX_PORT; i <= LAST_RX_PORT; i++)
+		p_fm_drv->ports[i].port_params.specific_params.
+		    rx_params.liodn_offset = (u16)(p_ppids->fmbm_ppid[i - 1]);
+
+	return 0;
+}
+
 /**
 *find_fman_microcode - find the Fman microcode
  *
@@ -542,7 +608,7 @@ static int configure_fm_dev(struct fm_drv_t *p_fm_drv)
 	p_fm_drv->params.f_bus_error = fm_drv_bus_error_cb;
 	p_fm_drv->params.h_app = p_fm_drv;
 
-	return 0;
+	return fill_rest_fm_info(p_fm_drv);
 }
 
 static int init_fm_dev(struct fm_drv_t *p_fm_drv)
@@ -791,6 +857,46 @@ void *fm_get_handle(struct fm *fm)
 EXPORT_SYMBOL(fm_get_handle);
 
 
+struct fm_port_drv_t *fm_port_bind(struct device *fm_port_dev)
+{
+	return (struct fm_port_drv_t *)
+				(dev_get_drvdata(get_device(fm_port_dev)));
+}
+EXPORT_SYMBOL(fm_port_bind);
+
+void fm_port_unbind(struct fm_port_drv_t *p_port)
+{
+	put_device(p_port->dev);
+}
+EXPORT_SYMBOL(fm_port_unbind);
+
+struct fm_port_t *fm_port_drv_handle(const struct fm_port_drv_t *p_port)
+{
+	return p_port->h_dev;
+}
+EXPORT_SYMBOL(fm_port_drv_handle);
+
+void fm_port_get_base_addr(const struct fm_port_drv_t *p_port,
+			   uint64_t *base_addr)
+{
+	*base_addr = p_port->port_params.base_addr;
+}
+EXPORT_SYMBOL(fm_port_get_base_addr);
+
+void fm_port_get_buff_layout_ext_params(struct fm_port_drv_t *p_port,
+					struct fm_port_params *params)
+{
+	/* TODO - Should this function be removed? */
+	params->data_align = 0;
+}
+EXPORT_SYMBOL(fm_port_get_buff_layout_ext_params);
+
+int fm_get_tx_port_channel(struct fm_port_drv_t *p_port)
+{
+	return p_port->tx_ch;
+}
+EXPORT_SYMBOL(fm_get_tx_port_channel);
+
 void fm_mutex_lock(void)
 {
 	mutex_lock(&fm_drv_mutex);
diff --git a/drivers/net/ethernet/freescale/fman/fm_drv.h b/drivers/net/ethernet/freescale/fman/fm_drv.h
index 2acd77b..c26836f 100644
--- a/drivers/net/ethernet/freescale/fman/fm_drv.h
+++ b/drivers/net/ethernet/freescale/fman/fm_drv.h
@@ -35,6 +35,7 @@
 
 #include "service.h"
 #include "fsl_fman_drv.h"
+#include "fm_port_ext.h"
 
 /* FMan Driver Errata */
 #define FM_BCB_ERRATA_BMI_SW001				/* T/B */
@@ -75,6 +76,7 @@ struct fm_port_drv_t {
 	uint64_t phys_base_addr;
 	uint64_t base_addr;	/* Port's *virtual* address */
 	resource_size_t mem_size;
+	struct fm_port_params_t port_params;
 	struct fm_buffer_prefix_content_t buff_prefix_content;
 	struct fm_port_t *h_dev;
 	struct fm_drv_t *p_fm;
diff --git a/drivers/net/ethernet/freescale/fman/fm_port_drv.c b/drivers/net/ethernet/freescale/fman/fm_port_drv.c
new file mode 100644
index 0000000..91a7353
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/fm_port_drv.c
@@ -0,0 +1,496 @@
+/*
+ * Copyright 2008-2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+/*File          fm_port_drv.c
+ *Description   FMan driver - FMan port functions.
+ */
+
+#include <linux/version.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/of_platform.h>
+#include <linux/of_address.h>
+#include <linux/cdev.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+
+#include "fm_common.h"
+#include "fsl_fman_drv.h"
+#include "fm_port_ext.h"
+#include "fm_drv.h"
+
+static struct fm_port_drv_t
+*read_fm_port_dev_tree_node(struct platform_device *of_dev)
+{
+	struct fm_drv_t *p_fm;
+	struct fm_port_drv_t *p_port;
+	struct device_node *fm_node, *port_node;
+	struct resource res;
+	const uint32_t *uint32_prop;
+	int _errno = 0, lenp;
+	enum fm_port_type port_type;
+	enum fm_port_speed port_speed;
+	u8 cell_index;
+
+	port_node = of_node_get(of_dev->dev.of_node);
+
+	/* Get the FM node */
+	fm_node = of_get_parent(port_node);
+	if (unlikely(!fm_node)) {
+		pr_err("of_get_parent() = %d\n", _errno);
+		return NULL;
+	}
+
+	p_fm = dev_get_drvdata(&of_find_device_by_node(fm_node)->dev);
+	of_node_put(fm_node);
+
+	/* if fm_probe() failed, no point in going further with port probing */
+	if (!p_fm)
+		return NULL;
+
+	uint32_prop =
+	    (uint32_t *)of_get_property(port_node, "cell-index", &lenp);
+	if (unlikely(!uint32_prop)) {
+		pr_err("of_get_property(%s, cell-index) failed\n",
+		       port_node->full_name);
+		return NULL;
+	}
+	if (WARN_ON(lenp != sizeof(uint32_t)))
+		return NULL;
+	cell_index = (u8)*uint32_prop;
+
+	p_port = &p_fm->ports[cell_index];
+	p_port->id = cell_index;
+	p_port->port_params.port_id = p_port->id;
+
+	if (of_device_is_compatible(port_node, "fsl,fman-v2-port-oh") ||
+	    of_device_is_compatible(port_node, "fsl,fman-v3-port-oh")) {
+		port_type = FM_PORT_TYPE_OP;
+		port_speed = FM_PORT_SPEED_OP;
+
+	} else if (of_device_is_compatible(port_node, "fsl,fman-v3-port-tx")) {
+		port_type = FM_PORT_TYPE_TX;
+		port_speed = FM_PORT_SPEED_1G;
+		uint32_prop = (uint32_t *)of_get_property(port_node,
+							  "fsl,fman-10g-port",
+							  &lenp);
+		if (uint32_prop)
+			port_speed = FM_PORT_SPEED_10G;
+
+	} else if (of_device_is_compatible(port_node, "fsl,fman-v2-port-tx")) {
+		if (cell_index >= TX_10G_PORT_BASE)
+			port_speed = FM_PORT_SPEED_10G;
+		else
+			port_speed = FM_PORT_SPEED_1G;
+		port_type = FM_PORT_TYPE_TX;
+
+	} else if (of_device_is_compatible(port_node, "fsl,fman-v3-port-rx")) {
+		port_type = FM_PORT_TYPE_RX;
+		port_speed = FM_PORT_SPEED_1G;
+		uint32_prop = (uint32_t *)of_get_property(port_node,
+							  "fsl,fman-10g-port",
+							  &lenp);
+		if (uint32_prop)
+			port_speed = FM_PORT_SPEED_10G;
+
+	} else if (of_device_is_compatible(port_node, "fsl,fman-v2-port-rx")) {
+		if (cell_index >= RX_10G_PORT_BASE)
+			port_speed = FM_PORT_SPEED_10G;
+		else
+			port_speed = FM_PORT_SPEED_1G;
+		port_type = FM_PORT_TYPE_RX;
+
+	}  else {
+		pr_err("Illegal port type\n");
+		return NULL;
+	}
+
+	p_port->port_params.port_type = port_type;
+	p_port->port_params.port_speed = port_speed;
+
+	if (port_type == FM_PORT_TYPE_OP || port_type == FM_PORT_TYPE_TX) {
+		uint32_t qman_channel_id;
+
+		qman_channel_id = get_qman_channel_id(p_fm, cell_index,
+						      port_type, port_speed);
+
+		if (qman_channel_id == 0) {
+			pr_err("incorrect qman-channel-id\n");
+			return NULL;
+		}
+		p_port->tx_ch = qman_channel_id;
+		p_port->port_params.specific_params.non_rx_params.qm_channel =
+			qman_channel_id;
+	}
+
+	_errno = of_address_to_resource(port_node, 0, &res);
+	if (unlikely(_errno < 0)) {
+		pr_err("of_address_to_resource() = %d\n", _errno);
+		return NULL;
+	}
+
+	p_port->dev = &of_dev->dev;
+	p_port->base_addr = 0;
+	p_port->phys_base_addr = res.start;
+	p_port->mem_size = res.end + 1 - res.start;
+	p_port->port_params.h_fm = p_fm->h_dev;
+	p_port->p_fm = (void *)p_fm;
+
+	of_node_put(port_node);
+
+	p_port->active = true;
+
+	return p_port;
+}
+
+static int configure_fm_port_dev(struct fm_port_drv_t *p_port)
+{
+	struct fm_drv_t *p_fm = (struct fm_drv_t *)p_port->p_fm;
+	struct resource *dev_res;
+
+	if (!p_port->active) {
+		pr_err("FM port not configured!!!\n");
+		return -EINVAL;
+	}
+
+	dev_res = __devm_request_region(p_fm->dev, p_fm->res,
+					p_port->phys_base_addr,
+					p_port->mem_size,
+					"fman-port-hc");
+	if (unlikely(!dev_res)) {
+		pr_err("__devm_request_region() failed\n");
+		return -EINVAL;
+	}
+	p_port->base_addr = PTR_TO_UINT(devm_ioremap(p_fm->dev,
+						     p_port->phys_base_addr,
+						     p_port->mem_size));
+	if (unlikely(p_port->base_addr == 0))
+		pr_err("devm_ioremap() failed\n");
+
+	p_port->port_params.base_addr = p_port->base_addr;
+
+	return 0;
+}
+
+static int init_fm_port_dev(struct fm_port_drv_t *p_port)
+{
+	struct fm_drv_t *p_fm = (struct fm_drv_t *)p_port->p_fm;
+
+	if (!p_port->active || p_port->h_dev)
+		return -EINVAL;
+
+	p_port->h_dev = fm_port_config(&p_port->port_params);
+	if (!p_port->h_dev) {
+		pr_err("FM-port\n");
+		return -EINVAL;
+	}
+
+	if (fm_get_revision(p_fm->h_dev, &p_port->fm_rev_info) != 0) {
+		pr_err("FM-port\n");
+		return -EINVAL;
+	}
+
+#ifdef FM_QMI_NO_DEQ_OPTIONS_SUPPORT
+	if ((p_port->fm_rev_info.major_rev != 4) &&
+	    (p_port->port_params.port_type == FM_PORT_TYPE_TX)) {
+		int err_code = 0;
+
+		err_code = fm_port_cfg_deq_high_priority(p_port->h_dev, true);
+		if (err_code != 0)
+			return -err_code;
+		err_code =
+		    fm_port_cfg_deq_prefetch_option(p_port->h_dev,
+						    FM_PORT_DEQ_FULL_PREFETCH);
+		if (err_code != 0)
+			return -err_code;
+	}
+#endif /* !FM_QMI_NO_DEQ_OPTIONS_SUPPORT */
+
+#ifdef FM_BCB_ERRATA_BMI_SW001
+/* Configure BCB workaround on Rx ports, only for B4860 rev1 */
+#define SVR_SECURITY_MASK    0x00080000
+#define SVR_PERSONALITY_MASK 0x0000FF00
+#define SVR_VER_IGNORE_MASK (SVR_SECURITY_MASK | SVR_PERSONALITY_MASK)
+#define SVR_B4860_REV1_VALUE 0x86800010
+
+	if ((p_port->fm_rev_info.major_rev >= 6) &&
+	    (p_port->port_params.port_type == FM_PORT_TYPE_RX)) {
+		unsigned int svr;
+
+		svr = mfspr(SPRN_SVR);
+
+		if ((svr & ~SVR_VER_IGNORE_MASK) == SVR_B4860_REV1_VALUE)
+			fm_port_cfg_bcb_wa(p_port->h_dev);
+	}
+#endif /* FM_BCB_ERRATA_BMI_SW001 */
+
+	fm_port_cfg_buf_prefix_content(p_port->h_dev,
+				       &p_port->buff_prefix_content);
+
+	if (fm_port_init(p_port->h_dev) != 0)
+		return -EINVAL;
+
+/**
+ * FMan Fifo sizes behind the scene":
+ * Using the following formulae (*), under a set of simplifying assumptions (.):
+ * . all ports are configured in Normal Mode (rather than Independent Mode)
+ * . the DPAA Eth driver allocates buffers of size:
+ *     . MAXFRM + NET_IP_ALIGN + DPA_PRIV_DATA_SIZE + DPA_PARSE_RESULTS_SIZE
+ *		 + DPA_HASH_RESULTS_SIZE, i.e.:
+ *       MAXFRM + 2 + 16 + sizeof(fm_prs_result_t) + 16, i.e.:
+ *       MAXFRM + 66
+ * . excessive buffer pools not accounted for
+ *
+ **for Rx ports on P4080:
+ *     . IFSZ = ceil(max(FMBM_EBMPI[PBS]) / 256)*256 + 7*256
+ *     . no internal frame offset (FMBM_RIM[FOF] == 0) - otherwise,
+ *     add up to 256 to the above
+ *
+ **for Rx ports on P1023:
+ *     . IFSZ = ceil(second_largest(FMBM_EBMPI[PBS] / 256))*256 + 7*256,
+ *     if at least 2 bpools are configured
+ *     . IFSZ = 8*256, if only a single bpool is configured
+ *
+ **for Tx ports:
+ *     . IFSZ = ceil(frame_size / 256)*256 + 3*256
+ *			+ FMBM_TFP[DPDE]*256, i.e.:
+ *       IFSZ = ceil(MAXFRM / 256)*256 + 3 x 256 + FMBM_TFP[DPDE]*256
+ *
+ **for OH ports on P4080:
+ *     . IFSZ = ceil(frame_size / 256)*256 + 1*256 + FMBM_PP[MXT]*256
+ **for OH ports on P1023:
+ *     . IFSZ = ceil(frame_size / 256)*256 + 3*256 + FMBM_TFP[DPDE]*256
+ **for both P4080 and P1023:
+ *     . (conservative decisions, assuming that BMI must bring the entire
+ *     frame, not only the frame header)
+ *     . no internal frame offset (FMBM_OIM[FOF] == 0) - otherwise,
+ *     add up to 256 to the above
+ *
+ * . for P4080/P5020/P3041/P2040, DPDE is:
+ *             > 0 or 1, for 1Gb ports, HW default: 0
+ *             > 2..7 (recommended: 3..7) for 10Gb ports, HW default: 3
+ * . for P1023, DPDE should be 1
+ *
+ * . for P1023, MXT is in range (0..31)
+ * . for P4080, MXT is in range (0..63)
+ *
+ */
+	return 0;
+}
+
+void fm_set_rx_port_params(struct fm_port_drv_t *p_port,
+			   struct fm_port_params *params)
+{
+	int i;
+
+	p_port->port_params.specific_params.rx_params.err_fqid = params->errq;
+	p_port->port_params.specific_params.rx_params.dflt_fqid = params->defq;
+	p_port->port_params.specific_params.rx_params.
+	    ext_buf_pools.num_of_pools_used = params->num_pools;
+	for (i = 0; i < params->num_pools; i++) {
+		p_port->port_params.specific_params.rx_params.ext_buf_pools.
+			ext_buf_pool[i].id = params->pool_param[i].id;
+		p_port->port_params.specific_params.rx_params.ext_buf_pools.
+			ext_buf_pool[i].size = params->pool_param[i].size;
+	}
+
+	p_port->buff_prefix_content.priv_data_size = params->priv_data_size;
+	p_port->buff_prefix_content.pass_prs_result = params->parse_results;
+	p_port->buff_prefix_content.pass_hash_result = params->hash_results;
+	p_port->buff_prefix_content.pass_time_stamp = params->time_stamp;
+	p_port->buff_prefix_content.data_align = params->data_align;
+
+	init_fm_port_dev(p_port);
+}
+EXPORT_SYMBOL(fm_set_rx_port_params);
+
+/* this function is called from oh_probe as well, thus it contains oh port
+ * specific parameters (make sure everything is checked)
+ **/
+void fm_set_tx_port_params(struct fm_port_drv_t *p_port,
+			   struct fm_port_params *params)
+{
+	p_port->port_params.specific_params.non_rx_params.err_fqid =
+		params->errq;
+	p_port->port_params.specific_params.non_rx_params.dflt_fqid =
+		params->defq;
+
+	p_port->buff_prefix_content.priv_data_size = params->priv_data_size;
+	p_port->buff_prefix_content.pass_prs_result = params->parse_results;
+	p_port->buff_prefix_content.pass_hash_result = params->hash_results;
+	p_port->buff_prefix_content.pass_time_stamp = params->time_stamp;
+	p_port->buff_prefix_content.data_align = params->data_align;
+
+	init_fm_port_dev(p_port);
+}
+EXPORT_SYMBOL(fm_set_tx_port_params);
+
+static void free_fm_port_dev(struct fm_port_drv_t *p_port)
+{
+	struct fm_drv_t *p_fm = (struct fm_drv_t *)p_port->p_fm;
+
+	if (!p_port->active)
+		return;
+
+	if (p_port->h_dev)
+		fm_port_free(p_port->h_dev);
+
+	devm_iounmap(p_port->dev, UINT_TO_PTR(p_port->base_addr));
+	__devm_release_region(p_fm->dev, p_fm->res, p_port->phys_base_addr,
+			      p_port->mem_size);
+}
+
+static int /*__devinit*/ fm_port_probe(struct platform_device *of_dev)
+{
+	struct fm_port_drv_t *p_port;
+	struct fm_drv_t *p_fm;
+	struct device *dev;
+
+	dev = &of_dev->dev;
+
+	p_port = read_fm_port_dev_tree_node(of_dev);
+	if (!p_port)
+		return -EIO;
+	/* Port can be inactive, thus will not be probed:
+	 * - in performance mode, OH ports are disabled  ...
+	 **/
+	if (!p_port->active)
+		return 0;
+
+	if (configure_fm_port_dev(p_port) != 0)
+		return -EIO;
+
+	dev_set_drvdata(dev, p_port);
+
+	p_fm = (struct fm_drv_t *)p_port->p_fm;
+
+	if (p_port->port_params.port_type == FM_PORT_TYPE_RX) {
+		snprintf(p_port->name, sizeof(p_port->name),
+			 "%s-port-rx%d", p_fm->name, p_port->id);
+	} else if (p_port->port_params.port_type == FM_PORT_TYPE_TX) {
+		snprintf(p_port->name, sizeof(p_port->name),
+			 "%s-port-tx%d", p_fm->name, p_port->id);
+	} else if (p_port->port_params.port_type == FM_PORT_TYPE_OP) {
+		snprintf(p_port->name, sizeof(p_port->name),
+			 "%s-port-oh%d", p_fm->name, p_port->id + 1);
+	}
+#ifdef FM_TX_INVALID_ECC_ERRATA_10GMAC_A009
+	if (p_port->fm_rev_info.major_rev < 6 &&
+	    p_port->fm_rev_info.major_rev != 4)
+		fm_disable_rams_ecc(p_fm->h_dev);
+#endif /* FM_TX_INVALID_ECC_ERRATA_10GMAC_A009 */
+
+	pr_debug("%s probed\n", p_port->name);
+
+	return 0;
+}
+
+static int fm_port_remove(struct platform_device *of_dev)
+{
+	struct fm_port_drv_t *p_port;
+	struct fm_drv_t *p_fm;
+	struct device *dev;
+
+	dev = &of_dev->dev;
+	p_port = dev_get_drvdata(dev);
+
+	p_fm = (struct fm_drv_t *)p_port->p_fm;
+
+	free_fm_port_dev(p_port);
+
+	dev_set_drvdata(dev, NULL);
+
+	return 0;
+}
+
+static const struct of_device_id fm_port_match[] = {
+	{
+	 .compatible = "fsl,fman-v3-port-oh"},
+	{
+	 .compatible = "fsl,fman-v2-port-oh"},
+	{
+	 .compatible = "fsl,fman-v3-port-rx"},
+	{
+	 .compatible = "fsl,fman-v2-port-rx"},
+	{
+	 .compatible = "fsl,fman-v3-port-tx"},
+	{
+	 .compatible = "fsl,fman-v2-port-tx"},
+	{}
+};
+
+#ifndef MODULE
+MODULE_DEVICE_TABLE(of, fm_port_match);
+#endif /* !MODULE */
+
+static struct platform_driver fm_port_driver = {
+	.driver = {
+		   .name = "fsl-fman-port",
+		   .of_match_table = fm_port_match,
+		   },
+	.probe = fm_port_probe,
+	.remove = fm_port_remove
+};
+
+int fm_port_drv_init(void)
+{
+	/* Register to the DTB for basic FM port API */
+	if (platform_driver_register(&fm_port_driver))
+		return -ENODEV;
+
+	return 0;
+}
+
+void fm_port_drv_free(void)
+{
+	platform_driver_unregister(&fm_port_driver);
+}
+
+static int __init __cold fm_port_load(void)
+{
+	if (fm_port_drv_init() != 0) {
+		pr_crit("Failed to init FM Ports wrapper!\n");
+		return -ENODEV;
+	}
+
+	pr_info("Freescale FM Ports module\n");
+
+	return 0;
+}
+
+static void __exit __cold fm_port_unload(void)
+{
+	fm_port_drv_free();
+}
+
+module_init(fm_port_load);
+module_exit(fm_port_unload);
diff --git a/drivers/net/ethernet/freescale/fman/inc/fm_port_ext.h b/drivers/net/ethernet/freescale/fman/inc/fm_port_ext.h
new file mode 100644
index 0000000..0de6801
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/inc/fm_port_ext.h
@@ -0,0 +1,376 @@
+/*
+ * Copyright 2008-2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+/*File          fm_port_ext.h
+ *FM-Port Application Programming Interface.
+ */
+#ifndef __FM_PORT_EXT
+#define __FM_PORT_EXT
+
+#include "service.h"
+#include "fm_ext.h"
+#include "net_ext.h"
+
+/* FMan Port Errata */
+#define FM_HEAVY_TRAFFIC_HANG_ERRATA_FMAN_A005669		/* T/B */
+
+/* FM Port API
+ * The FM uses a general module called "port" to represent a Tx port (MAC),
+ * an Rx port (MAC) or Offline Parsing port.
+ * The number of ports in an FM varies between SOCs.
+ * The SW driver manages these ports as sub-modules of the FM,i.e. after an
+ * FM is initialized, its ports may be initialized and operated upon.
+ * The port is initialized aware of its type, but other functions on a port
+ * may be indifferent to its type. When necessary, the driver verifies
+ * coherence and returns error if applicable.
+ * On initialization, user specifies the port type and it's index (relative
+ * to the port's type) - always starting at 0.
+ */
+
+/* General FM Port defines */
+/* Number of 4 bytes words in parser result */
+#define FM_PORT_PRS_RESULT_NUM_OF_WORDS     8
+/* @} */
+
+/* FM Frame error */
+/* Frame Descriptor errors */
+/* Not for Rx-Port! Unsupported Format */
+#define FM_PORT_FRM_ERR_UNSUPPORTED_FORMAT	FM_FD_ERR_UNSUPPORTED_FORMAT
+/* Not for Rx-Port! Length Error */
+#define FM_PORT_FRM_ERR_LENGTH			FM_FD_ERR_LENGTH
+/* DMA Data error */
+#define FM_PORT_FRM_ERR_DMA			FM_FD_ERR_DMA
+/* non Frame-Manager error; probably come from SEC that was chained to FM */
+#define FM_PORT_FRM_ERR_NON_FM			FM_FD_RX_STATUS_ERR_NON_FM
+ /* IPR error */
+#define FM_PORT_FRM_ERR_IPRE			(FM_FD_ERR_IPR & ~FM_FD_IPR)
+/* IPR non-consistent-sp */
+#define FM_PORT_FRM_ERR_IPR_NCSP		(FM_FD_ERR_IPR_NCSP &	\
+						~FM_FD_IPR)
+
+/* Obsolete; will be removed in the future */
+#define FM_PORT_FRM_ERR_IPFE			0
+
+/* Rx FIFO overflow, FCS error, code error, running disparity
+ * error (SGMII and TBI modes), FIFO parity error.
+ * PHY Sequence error, PHY error control character detected.
+ **/
+#define FM_PORT_FRM_ERR_PHYSICAL                FM_FD_ERR_PHYSICAL
+/* Frame too long OR Frame size exceeds max_length_frame  */
+#define FM_PORT_FRM_ERR_SIZE                    FM_FD_ERR_SIZE
+/* indicates a classifier "drop" operation */
+#define FM_PORT_FRM_ERR_CLS_DISCARD             FM_FD_ERR_CLS_DISCARD
+/* Extract Out of Frame */
+#define FM_PORT_FRM_ERR_EXTRACTION              FM_FD_ERR_EXTRACTION
+/* No Scheme Selected */
+#define FM_PORT_FRM_ERR_NO_SCHEME               FM_FD_ERR_NO_SCHEME
+/* Keysize Overflow */
+#define FM_PORT_FRM_ERR_KEYSIZE_OVERFLOW        FM_FD_ERR_KEYSIZE_OVERFLOW
+/* Frame color is red */
+#define FM_PORT_FRM_ERR_COLOR_RED               FM_FD_ERR_COLOR_RED
+/* Frame color is yellow */
+#define FM_PORT_FRM_ERR_COLOR_YELLOW            FM_FD_ERR_COLOR_YELLOW
+/* Parser Time out Exceed */
+#define FM_PORT_FRM_ERR_PRS_TIMEOUT             FM_FD_ERR_PRS_TIMEOUT
+/* Invalid Soft Parser instruction */
+#define FM_PORT_FRM_ERR_PRS_ILL_INSTRUCT        FM_FD_ERR_PRS_ILL_INSTRUCT
+/* Header error was identified during parsing */
+#define FM_PORT_FRM_ERR_PRS_HDR_ERR             FM_FD_ERR_PRS_HDR_ERR
+/* Frame parsed beyind 256 first bytes */
+#define FM_PORT_FRM_ERR_BLOCK_LIMIT_EXCEEDED    FM_FD_ERR_BLOCK_LIMIT_EXCEEDED
+/* FPM Frame Processing Timeout Exceeded */
+#define FM_PORT_FRM_ERR_PROCESS_TIMEOUT         0x00000001
+
+/* FM Port Initialization Unit */
+struct fm_port_t;
+
+/* A structure for additional Rx port parameters */
+struct fm_port_rx_params_t {
+	uint32_t err_fqid;			/* Error Queue Id. */
+	uint32_t dflt_fqid;			/* Default Queue Id.  */
+	uint16_t liodn_offset;			/* Port's LIODN offset. */
+	/* Which external buffer pools are used
+	 * (up to FM_PORT_MAX_NUM_OF_EXT_POOLS), and their sizes.
+	 */
+	struct fm_ext_pools_t ext_buf_pools;
+};
+
+/* A structure for additional non-Rx port parameters*/
+struct fm_port_non_rx_params_t {
+	/* Error Queue Id. */
+	uint32_t err_fqid;
+	/* For Tx - Default Confirmation queue, 0 means no Tx confirmation
+	 * for processed frames. For OP port - default Rx queue.
+	 */
+	uint32_t dflt_fqid;
+	/* QM-channel dedicated to this port; will be used
+	 * by the FM for dequeue.
+	 */
+	uint32_t qm_channel;
+};
+
+/* A union for additional parameters depending on port type*/
+union fm_port_specific_params_u {
+	/* Rx port parameters structure */
+	struct fm_port_rx_params_t rx_params;
+	/* Non-Rx port parameters structure */
+	struct fm_port_non_rx_params_t non_rx_params;
+};
+
+/* A structure representing FM initialization parameters*/
+struct fm_port_params_t {
+	uintptr_t base_addr;
+	/* Virtual Address of memory mapped FM Port registers.*/
+	void *h_fm;
+	/* A handle to the FM object this port related to */
+	enum fm_port_type port_type;
+	/* Port type */
+	enum fm_port_speed port_speed;
+	/* Port speed */
+	uint8_t port_id;
+	/* Port Id - relative to type;
+	 * NOTE: When configuring Offline Parsing port for FMANv3 devices,
+	 * it is highly recommended NOT to use port_id=0 due to lack of HW
+	 * resources on port_id=0.
+	 */
+	uint16_t liodn_base;
+	/* Irrelevant for P4080 rev 1. LIODN base for this port, to be
+	 * used together with LIODN offset.
+	 */
+	union fm_port_specific_params_u specific_params;
+	/* Additional parameters depending on port type. */
+};
+
+struct fm_port;
+
+/* Function	fm_port_config
+ * Description	Creates a descriptor for the FM PORT module.
+ *		The routine returns a handle (descriptor) to the FM PORT object.
+ *		This descriptor must be passed as first parameter to all other
+ *		FM PORT function calls.
+ *		No actual initialization or configuration of FM hardware is
+ *		done by this routine.
+ * Param[in]	p_fm_port_params - Pointer to data structure of parameters
+ * Retval	Pointer to FM Port object, or NULL for Failure.
+ */
+struct fm_port_t *fm_port_config(struct fm_port_params_t *p_fm_port_params);
+
+/* Function	fm_port_init
+ * Description	Initializes the FM PORT module by defining the
+ *		software structure
+ *		and configuring the hardware registers.
+ * Param[in]	port - A pointer to a FM Port module.
+ * Return	0 on success; Error code otherwise.
+ */
+int fm_port_init(struct fm_port_t *p_fm_port);
+
+/* Function	fm_port_free
+ * Description	Frees all resources that were assigned to FM PORT module.
+ *		Calling this routine invalidates the descriptor.
+ * Param[in]	port - A pointer to a FM Port module.
+ * Return	0 on success; Error code otherwise.
+ */
+int fm_port_free(struct fm_port_t *p_fm_port);
+
+/* Configuration functions used to change default values. */
+
+/* enum for defining QM frame dequeue*/
+enum fm_port_deq_type {
+	/* Dequeue from the SP channel - with priority precedence,
+	 * and Intra-Class Scheduling respected.
+	 */
+	FM_PORT_DEQ_TYPE1,
+	/* Dequeue from the SP channel - with active FQ precedence,
+	 * and Intra-Class Scheduling respected.
+	 */
+	FM_PORT_DEQ_TYPE2,
+	/* Dequeue from the SP channel - with active FQ precedence,
+	 * and override Intra-Class Scheduling
+	 */
+	FM_PORT_DEQ_TYPE3
+};
+
+/* enum for defining QM frame dequeue*/
+enum fm_port_deq_prefetch_option {
+	/* QMI preforms a dequeue action for a single frame only
+	 * when a dedicated portID Tnum is waiting.
+	 */
+	FM_PORT_DEQ_NO_PREFETCH,
+	/* QMI preforms a dequeue action for 3 frames when one
+	 * dedicated port_id tnum is waiting.
+	 */
+	FM_PORT_DEQ_PARTIAL_PREFETCH,
+	/* QMI preforms a dequeue action for 3 frames when
+	 * no dedicated port_id tnums are waiting.
+	 */
+	FM_PORT_DEQ_FULL_PREFETCH
+};
+
+/* enum for defining port default color*/
+enum fm_port_color {
+	FM_PORT_COLOR_GREEN,	    /* Default port color is green */
+	FM_PORT_COLOR_YELLOW,	    /* Default port color is yellow */
+	FM_PORT_COLOR_RED,	    /* Default port color is red */
+	FM_PORT_COLOR_OVERRIDE    /* Ignore color */
+};
+
+/* A structure for defining FM port resources*/
+struct fm_port_rsrc_t {
+	uint32_t num; /* Committed required resource */
+	uint32_t extra; /* Extra (not committed) required resource */
+};
+
+/* Function	fm_port_cfg_deq_high_priority
+ * Description	Calling this routine changes the dequeue priority in the
+ *		internal driver data base from its default configuration
+ *		1G: [DEFAULT_PORT_deq_high_priority_1G]
+ *		10G: [DEFAULT_PORT_deq_high_priority_10G]
+ *		May be used for Non-Rx ports only
+ * Param[in]	port - A pointer to a FM Port module.
+ * Param[in]	high_pri -	true to select high priority, false for
+ *				normal operation.
+ * Return	0 on success; Error code otherwise.
+ * Cautions	Allowed only following fm_port_config() and before
+ *		fm_port_init().
+ */
+int fm_port_cfg_deq_high_priority(struct fm_port_t *p_fm_port, bool high_pri);
+
+/* Function	fm_port_cfg_deq_prefetch_option
+ * Description	Calling this routine changes the dequeue prefetch option
+ *		parameter in the
+ *		internal driver data base from its default configuration
+ *		[DEFAULT_PORT_deq_prefetch_option]
+ *		Note: Available for some chips only
+ *		May be used for Non-Rx ports only
+ * Param[in]	port - A pointer to a FM Port module.
+ * Param[in]	deq_prefetch_option - New option
+ * Return	0 on success; Error code otherwise.
+ * Cautions	Allowed only following fm_port_config() and before
+ *		fm_port_init().
+ */
+int fm_port_cfg_deq_prefetch_option(struct fm_port_t *p_fm_port,
+				    enum fm_port_deq_prefetch_option
+				    deq_prefetch_option);
+
+/* Function	fm_port_cfg_buf_prefix_content
+ * Description	Defines the structure, size and content of the application
+ *		buffer.
+ *		The prefix will
+ *		In Tx ports, if 'pass_prs_result', the application
+ *		should set a value to their offsets in the prefix of
+ *		the FM will save the first 'priv_data_size', than,
+ *		depending on 'pass_prs_result' and 'pass_time_stamp',
+ *		copy parse result and timeStamp, and the packet itself
+ *		(in this order), to the application buffer, and to offset.
+ *		Calling this routine changes the buffer margins definitions
+ *		in the internal driver data base from its default
+ *		configuration:
+ *		Data size:  [DEFAULT_PORT_BUFFER_PREFIX_CONTENT_PRIV_DATA_SIZE]
+ *		Pass Parser result: [DEFAULT_PORT_BUFFER_PREFIX_CONTENT_
+ *		PASS_PRS_RESULT].
+ *		Pass timestamp: [DEFAULT_PORT_BUFFER_PREFIX_CONTENT_PASS_
+ *		TIME_STAMP].
+ *		May be used for all ports
+ * Param[in]		port - A pointer to a FM Port module.
+ * Param[in,out]	p_fm_buffer_prefix_content -
+ *			A structure of parameters describing the
+ *			structure of the buffer.
+ *			Out parameter:
+ *			Start margin - offset of data from start of external
+ *			buffer.
+ * Return	0 on success; Error code otherwise.
+ * Cautions	Allowed only following fm_port_config() and before
+ *		fm_port_init().
+ */
+int fm_port_cfg_buf_prefix_content(struct fm_port_t *p_fm_port,
+				   struct fm_buffer_prefix_content_t
+				   *p_fm_buffer_prefix_content);
+
+#ifdef FM_HEAVY_TRAFFIC_HANG_ERRATA_FMAN_A005669
+/* Function	fm_port_cfg_bcb_wa
+ * Description	Configures BCB errata workaround.
+ *		When BCB errata is applicable, the workaround is always
+ *		performed by FM Controller. Thus, this functions doesn't
+ *		actually enable errata workaround but rather allows driver
+ *		to perform adjustments required due to errata workaround
+ *		execution in FM controller.
+ *		Applying BCB workaround also configures FM_PORT_FRM_ERR_PHYSICAL
+ *		errors to be discarded. Thus FM_PORT_FRM_ERR_PHYSICAL can't be
+ *		set by FM_PORT_SetErrorsRoute() function.
+ * Param[in]	port - A pointer to a FM Port module.
+ * Return	0 on success; Error code otherwise.
+ * Cautions	Allowed only following fm_port_config() and before
+ *		fm_port_init().
+ */
+int fm_port_cfg_bcb_wa(struct fm_port_t *p_fm_port);
+#endif /* FM_HEAVY_TRAFFIC_HANG_ERRATA_FMAN_A005669 */
+
+/* FM Port Runtime control unit API functions, definitions and enums. */
+
+/* Function	fm_port_get_buffer_time_stamp
+ * Description	Returns the time stamp in the data buffer.
+ *		Relevant for Rx ports for getting the buffer time stamp.
+ *		See fm_port_cfg_buf_prefix_content for data buffer prefix
+ *		configuration.
+ * Param[in]	port - A pointer to a FM Port module.
+ * Param[in]	p_data - A pointer to the data buffer.
+ * Return	A pointer to the hash result on success, NULL otherwise.
+ * Cautions	Allowed only following fm_port_init().
+ */
+u64 *fm_port_get_buffer_time_stamp(const struct fm_port_t *p_fm_port,
+				   char *p_data);
+
+/* Function	fm_port_disable
+ * Description  Gracefully disable an FM port. The port will not start new
+ *		tasks after all
+ *		tasks associated with the port are terminated.
+ * Param[in]	port - A pointer to a FM Port module.
+ * Return	0 on success; Error code otherwise.
+ * Cautions	Allowed only following fm_port_init().
+ *		This is a blocking routine, it returns after port is
+ *		gracefully stopped, i.e. the port will not except new frames,
+ *		but it will finish all frames or tasks which were already began
+ */
+int fm_port_disable(struct fm_port_t *p_fm_port);
+
+int fm_port_suspend(struct fm_port_t *p_fm_port);
+/* Function	fm_port_enable
+ * Description	A runtime routine provided to allow disable/enable of port.
+ * Param[in]	port - A pointer to a FM Port module.
+ * Return	0 on success; Error code otherwise.
+ * Cautions	Allowed only following fm_port_init().
+ */
+int fm_port_enable(struct fm_port_t *p_fm_port);
+
+int fm_port_resume(struct fm_port_t *p_fm_port);
+
+#endif /* __FM_PORT_EXT */
diff --git a/drivers/net/ethernet/freescale/fman/inc/fsl_fman_drv.h b/drivers/net/ethernet/freescale/fman/inc/fsl_fman_drv.h
index cfbf462..b0b47b8 100644
--- a/drivers/net/ethernet/freescale/fman/inc/fsl_fman_drv.h
+++ b/drivers/net/ethernet/freescale/fman/inc/fsl_fman_drv.h
@@ -37,10 +37,44 @@
 
 #include <linux/types.h>
 #include <linux/device.h>	/* struct device */
+#include "fm_ext.h"
 
 /* FM device opaque structure used for type checking */
 struct fm;
 
+/* A structure .., */
+struct fm_port_t;
+
+/* A structure of information about each of the external
+ * buffer pools used by the port,
+ */
+struct fm_port_pool_param {
+	uint8_t id;			/* External buffer pool id */
+	uint16_t size;			/* External buffer pool buffer size*/
+};
+
+/* structure for additional port parameters */
+struct fm_port_params {
+	uint32_t errq;	    /* Error Queue Id. */
+	uint32_t defq;	    /* For Tx and HC - Default Confirmation queue,
+			     * 0 means no Tx conf for processed frames.
+			     *  For Rx and OP - default Rx queue.
+			     */
+	uint8_t num_pools;  /* Number of pools use by this port */
+	struct fm_port_pool_param pool_param[FM_PORT_MAX_NUM_OF_EXT_POOLS];
+			    /* Parameters for each pool */
+	uint16_t priv_data_size;  /* Area that user may save for his own
+				   * need (E.g. save the SKB)
+				   */
+	bool parse_results; /* Put the parser-results in the Rx/Tx buffer */
+	bool hash_results;  /* Put the hash-results in the Rx/Tx buffer */
+	bool time_stamp;    /* Put the time-stamp in the Rx/Tx buffer */
+	uint16_t data_align;  /* value for selecting a data alignment
+			       * (must be a power of 2);
+			       * if write optimization is used, must be >= 16.
+			       */
+};
+
 /* fm_bind
  *	Bind to a specific FM device.
  *
@@ -60,6 +94,73 @@ void fm_unbind(struct fm *fm);
 void *fm_get_handle(struct fm *fm);
 struct resource *fm_get_mem_region(struct fm *fm);
 
+/*	fm_port_bind
+ *	Bind to a specific FM-port device (may be Rx or Tx port).
+ *  fm_port_dev - the OF handle of the FM port device.
+ *  Return	A handle of the FM port device.
+ *  Allowed only after the port was created.
+ */
+struct fm_port_drv_t *fm_port_bind(struct device *fm_port_dev);
+
+/*	fm_port_unbind
+ *	Un-bind from a specific FM-port device (may be Rx or Tx port).
+ *  port	- A handle of the FM port device.
+ *  Allowed only after the port was created.
+ */
+void fm_port_unbind(struct fm_port_drv_t *p_port);
+
+/* fm_set_rx_port_params
+ *	Configure parameters for a specific Rx FM-port device.
+ *  port	- A handle of the FM port device.
+ *  params	- Rx port parameters
+ *  Allowed only after the port is binded.
+ */
+void fm_set_rx_port_params(struct fm_port_drv_t *p_port,
+			   struct fm_port_params *params);
+
+/*	fm_port_get_buff_layout_ext_params
+ *	Get data_align from the device tree chosen node if applied.
+ *		This function will only update these two parameters.
+ *		When this port has no such parameters in the device tree
+ *		values will be set to 0.
+ *	port	- A handle of the FM port device.
+ *	params	- PCD port parameters
+ *	Allowed only after the port is binded.
+ */
+void fm_port_get_buff_layout_ext_params(struct fm_port_drv_t *p_port,
+					struct fm_port_params *params);
+
+/*	fm_get_tx_port_channel
+ *	Get qman-channel number for this Tx port.
+ *	port	- A handle of the FM port device.
+ *  Return	qman-channel number for this Tx port.
+ *	Allowed only after the port is binded.
+ */
+int fm_get_tx_port_channel(struct fm_port_drv_t *p_port);
+
+/*	fm_set_tx_port_params
+ *	Configure parameters for a specific Tx FM-port device
+ *	port	- A handle of the FM port device.
+ *	params	- Tx port parameters
+ *	Allowed only after the port is binded.
+ */
+void fm_set_tx_port_params(struct fm_port_drv_t *p_port,
+			   struct fm_port_params *params);
+
+struct fm_port_t *fm_port_drv_handle(const struct fm_port_drv_t *p_port);
+
+/*	fm_port_get_base_address
+ *
+ *	Get base address of this port. Useful for accessing
+ *		port-specific registers (i.e., not common ones).
+ *
+ *	port		- A handle of the FM port device.
+ *
+ *	base_addr	- The port's base addr (virtual address).
+ */
+void fm_port_get_base_addr(const struct fm_port_drv_t *p_port,
+			   uint64_t *base_addr);
+
 /*	fm_mutex_lock
  *
  *   Lock function required before any FMD/LLD call.
diff --git a/drivers/net/ethernet/freescale/fman/port/Makefile b/drivers/net/ethernet/freescale/fman/port/Makefile
index 54b1fa4..55825e3 100644
--- a/drivers/net/ethernet/freescale/fman/port/Makefile
+++ b/drivers/net/ethernet/freescale/fman/port/Makefile
@@ -1,3 +1,3 @@
 obj-y	+= fsl_fman_port.o
 
-fsl_fman_port-objs		:= fman_port.o
+fsl_fman_port-objs		:= fman_port.o fm_port.o
diff --git a/drivers/net/ethernet/freescale/fman/port/fm_port.c b/drivers/net/ethernet/freescale/fman/port/fm_port.c
new file mode 100644
index 0000000..6ac4e55
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/port/fm_port.c
@@ -0,0 +1,1435 @@
+/*
+ * Copyright 2008 - 2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+/* File          fm_port.c
+ * Description   FM driver routines implementation.
+ */
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include "service.h"
+#include "fm_muram_ext.h"
+
+#include "fman_common.h"
+#include "fm_port.h"
+
+#include <linux/string.h>
+#include <linux/slab.h>
+
+/*       static functions               */
+
+static int check_init_parameters(struct fm_port_t *p_fm_port)
+{
+	struct fm_port_drv_param_t *p_params = p_fm_port->p_fm_port_drv_param;
+	struct fman_port_cfg *p_dflt_config = &p_params->dflt_cfg;
+	uint32_t unused_mask;
+
+	/* Rx only */
+	if (p_fm_port->port_type == FM_PORT_TYPE_RX) {
+		/* external buffer pools */
+		if (!p_params->ext_buf_pools.num_of_pools_used) {
+			pr_err("ext_buf_pools.num_of_pools_used=0. At least one buffer pool must be defined\n");
+			return -EDOM;
+		}
+
+		if (fm_sp_check_buf_pools_params(&p_params->ext_buf_pools,
+						 p_params->p_backup_bm_pools,
+			&p_params->buf_pool_depletion,
+			p_fm_port->port_intg->max_num_of_ext_pools,
+			p_fm_port->port_intg->bm_max_num_of_pools) != 0)
+			return -EDOM;
+		/* Check that part of IC that needs copying is small enough
+		 * to enter start margin
+		 */
+		if (p_params->int_context.size &&
+		    (p_params->int_context.size +
+		     p_params->int_context.ext_buf_offset >
+		     p_params->buf_margins.start_margins)) {
+			pr_err("int_context.size is larger than start margins\n");
+			return -EDOM;
+		}
+
+		if ((p_params->liodn_offset != LIODN_DONT_OVERRIDE) &&
+		    (p_params->liodn_offset & ~FM_LIODN_OFFSET_MASK)) {
+			pr_err("liodn_offset is larger than %d\n",
+			       FM_LIODN_OFFSET_MASK + 1);
+		}
+#ifdef FM_NO_BACKUP_POOLS
+		if ((p_fm_port->fm_rev_info.major_rev != 4) &&
+		    (p_fm_port->fm_rev_info.major_rev < 6))
+			if (p_fm_port->p_fm_port_drv_param->
+			    p_backup_bm_pools) {
+				pr_err("BackupBmPools\n");
+				return -EINVAL;
+			}
+#endif /* FM_NO_BACKUP_POOLS */
+	}
+
+	/*   Non Rx ports                       */
+	else {
+		if (p_params->deq_sub_portal >=
+		    p_fm_port->port_intg->fm_max_num_of_sub_portals) {
+			pr_err("deq_sub_portal has to be in the range of 0 - %d\n",
+			       p_fm_port->port_intg->fm_max_num_of_sub_portals);
+			return -EDOM;
+		}
+
+		/* to protect HW internal-context from overwrite */
+		if ((p_params->int_context.size) &&
+		    (p_params->int_context.int_context_offset <
+		     MIN_TX_INT_OFFSET)) {
+			pr_err("non-Rx int_context.int_context_offset can't be smaller than %d\n",
+			       MIN_TX_INT_OFFSET);
+			return -EDOM;
+		}
+
+		if ((p_fm_port->port_type == FM_PORT_TYPE_TX) ||
+		    /* in O/H DEFAULT_NOT_SUPPORTED indicates that
+		     * it is not supported and should not be checked
+		     */
+		    (p_fm_port->p_fm_port_drv_param->dflt_cfg.
+		     tx_fifo_deq_pipeline_depth != DEFAULT_NOT_SUPPORTED)) {
+			/* Check that not larger than 8 */
+			if ((!p_fm_port->p_fm_port_drv_param->dflt_cfg.
+			     tx_fifo_deq_pipeline_depth) ||
+				(p_fm_port->p_fm_port_drv_param->dflt_cfg.
+				tx_fifo_deq_pipeline_depth >
+				MAX_FIFO_PIPELINE_DEPTH)) {
+				pr_err("fifoDeqPipelineDepth can't be larger than %d\n",
+				       MAX_FIFO_PIPELINE_DEPTH);
+				return -EDOM;
+			}
+		}
+	}
+
+	/* Rx Or Offline Parsing */
+	if ((p_fm_port->port_type == FM_PORT_TYPE_RX) ||
+	    (p_fm_port->port_type == FM_PORT_TYPE_OP)) {
+		if (!p_params->dflt_fqid) {
+			pr_err("dflt_fqid must be between 1 and 2^24-1\n");
+			return -EDOM;
+		}
+	}
+
+	/*   All ports                          */
+	/* common BMI registers values */
+	/* Check that Queue Id is not larger than 2^24, and is not 0 */
+	if ((p_params->err_fqid & ~0x00FFFFFF) || !p_params->err_fqid) {
+		pr_err("err_fqid must be between 1 and 2^24-1\n");
+		return -EDOM;
+	}
+	if (p_params->dflt_fqid & ~0x00FFFFFF) {
+		pr_err("dflt_fqid must be between 1 and 2^24-1\n");
+		return -EDOM;
+	}
+
+	/* Rx only */
+	if (p_fm_port->port_type == FM_PORT_TYPE_RX) {
+		if (p_dflt_config->rx_pri_elevation % BMI_FIFO_UNITS) {
+			pr_err("rx_fifo_pri_elevation_level has to be divisible by %d\n",
+			       BMI_FIFO_UNITS);
+			return -EDOM;
+		}
+		if ((p_dflt_config->rx_pri_elevation < BMI_FIFO_UNITS) ||
+		    (p_dflt_config->rx_pri_elevation >
+		     p_fm_port->port_intg->max_port_fifo_size)) {
+			pr_err("rx_fifo_pri_elevation_level not in range of 256 - %d\n",
+			       p_fm_port->port_intg->max_port_fifo_size);
+			return -EDOM;
+		}
+		if (p_dflt_config->rx_fifo_thr % BMI_FIFO_UNITS) {
+			pr_err("rx_fifo_threshold must be div by %d\n",
+			       BMI_FIFO_UNITS);
+			return -EDOM;
+		}
+		if ((p_dflt_config->rx_fifo_thr < BMI_FIFO_UNITS) ||
+		    (p_dflt_config->rx_fifo_thr >
+		     p_fm_port->port_intg->max_port_fifo_size)) {
+			pr_err("rx_fifo_threshold has to be in the range of 256 - %d\n",
+			       p_fm_port->port_intg->max_port_fifo_size);
+			return -EDOM;
+		}
+
+		/* Check that not larger than 16 */
+		if (p_dflt_config->rx_cut_end_bytes > FRAME_END_DATA_SIZE) {
+			pr_err("cut_bytes_from_end can't be larger than %d\n",
+			       FRAME_END_DATA_SIZE);
+			return -EDOM;
+		}
+
+		if (fm_sp_check_buf_margins(&p_params->buf_margins) != 0)
+			return -EDOM;
+
+		/* extra FIFO size (allowed only to Rx ports) */
+		if (p_params->set_size_of_fifo &&
+		    (p_fm_port->fifo_bufs.extra % BMI_FIFO_UNITS)) {
+			pr_err("fifo_bufs.extra has to be divisible by %d\n",
+			       BMI_FIFO_UNITS);
+			return -EDOM;
+		}
+
+		if (p_params->buf_pool_depletion.pools_grp_mode_enable &&
+		    !p_params->buf_pool_depletion.num_of_pools) {
+			pr_err("buf_pool_depletion.num_of_pools can not be 0 when pools_grp_mode_enable=true\n");
+			return -EDOM;
+		}
+#ifdef FM_CSI_CFED_LIMIT
+		if (p_fm_port->fm_rev_info.major_rev == 4) {
+			/* Check that not larger than 16 */
+			if (p_dflt_config->rx_cut_end_bytes +
+			    p_dflt_config->checksum_bytes_ignore >
+			    FRAME_END_DATA_SIZE) {
+				pr_err("cheksum_last_bytes_ignore + cut_bytes_from_end can't be larger than %d\n",
+				       FRAME_END_DATA_SIZE);
+				return -EDOM;
+			}
+		}
+#endif /* FM_CSI_CFED_LIMIT */
+	}
+
+	/* Non Rx ports */
+	/* extra FIFO size (allowed only to Rx ports) */
+	else if (p_fm_port->fifo_bufs.extra) {
+		pr_err(" No fifo_bufs.extra for non Rx ports\n");
+		return -EDOM;
+	}
+
+	/* Tx only */
+	if (p_fm_port->port_type == FM_PORT_TYPE_TX) {
+		if (p_dflt_config->tx_fifo_min_level % BMI_FIFO_UNITS) {
+			pr_err("tx_fifo_min_fill_level has to be divisible by %d\n",
+			       BMI_FIFO_UNITS);
+			return -EDOM;
+		}
+		if (p_dflt_config->tx_fifo_min_level >
+		    (p_fm_port->port_intg->max_port_fifo_size - 256)) {
+			pr_err("tx_fifo_min_fill_level has to be in the range of 0 - %d\n",
+			       (p_fm_port->port_intg->max_port_fifo_size -
+				256));
+			return -EDOM;
+		}
+		if (p_dflt_config->tx_fifo_low_comf_level % BMI_FIFO_UNITS) {
+			pr_err("tx_fifo_low_comf_level has to be divisible by %d\n",
+			       BMI_FIFO_UNITS);
+			return -EDOM;
+		}
+		if ((p_dflt_config->tx_fifo_low_comf_level < BMI_FIFO_UNITS) ||
+		    (p_dflt_config->tx_fifo_low_comf_level >
+		     p_fm_port->port_intg->max_port_fifo_size)) {
+			pr_err("tx_fifo_low_comf_level has to be in the range of 256 - %d\n",
+			       p_fm_port->port_intg->max_port_fifo_size);
+			return -EDOM;
+		}
+		if (p_fm_port->port_speed == FM_PORT_SPEED_1G)
+			if (p_fm_port->p_fm_port_drv_param->dflt_cfg.
+			    tx_fifo_deq_pipeline_depth > 2) {
+				pr_err("fifoDeqPipelineDepth for 1G can't be larger than 2\n");
+				return -EDOM;
+			}
+	}
+
+	/*   Non Tx Ports                       */
+	/* If discard override was selected , no frames may be discarded. */
+	else if (p_dflt_config->discard_override && p_params->
+		 errors_to_discard) {
+		pr_err("errors_to_discard is not empty, but frm_discard_override selected (all discarded frames to be enqueued to error queue).\n");
+		return -EINVAL;
+	}
+
+	/* Rx and Offline parsing */
+	if ((p_fm_port->port_type == FM_PORT_TYPE_RX) ||
+	    (p_fm_port->port_type == FM_PORT_TYPE_OP)) {
+		if (p_fm_port->port_type == FM_PORT_TYPE_OP)
+			unused_mask = BMI_STATUS_OP_MASK_UNUSED;
+		else
+			unused_mask = BMI_STATUS_RX_MASK_UNUSED;
+
+		/* Check that no common bits with BMI_STATUS_MASK_UNUSED */
+		if (p_params->errors_to_discard & unused_mask) {
+			pr_err("errors_to_discard contains undefined bits\n");
+			return -EINVAL;
+		}
+	}
+
+	/* Offline Ports */
+#ifdef FM_OP_OPEN_DMA_MIN_LIMIT
+	if ((p_fm_port->fm_rev_info.major_rev >= 6) &&
+	    (p_fm_port->port_type == FM_PORT_TYPE_OP) &&
+	    p_params->set_num_of_open_dmas &&
+	    (p_fm_port->open_dmas.num < MIN_NUM_OF_OP_DMAS)) {
+		pr_err("For Offline port, open_dmas.num can't be smaller than %d\n",
+		       MIN_NUM_OF_OP_DMAS);
+		return -EDOM;
+	}
+#endif /* FM_OP_OPEN_DMA_MIN_LIMIT */
+
+	/* Offline Ports */
+	if (p_fm_port->port_type == FM_PORT_TYPE_OP) {
+#ifndef FM_FRAME_END_PARAMS_FOR_OP
+		if ((p_fm_port->fm_rev_info.major_rev < 6) &&
+		    (p_fm_port->p_fm_port_drv_param->
+		     cheksum_last_bytes_ignore !=
+		     DEFAULT_NOT_SUPPORTED)) {
+			/* this is an indication that user called config
+			 * for this mode which is not supported in this
+			 * integration
+			 */
+			pr_err("cheksum_last_bytes_ignore is available for Rx&Tx ports only\n");
+			return -EDOM;
+		}
+#endif /* !FM_FRAME_END_PARAMS_FOR_OP */
+
+#ifndef FM_DEQ_PIPELINE_PARAMS_FOR_OP
+		if ((!((p_fm_port->fm_rev_info.major_rev == 4) ||
+		       (p_fm_port->fm_rev_info.major_rev >= 6))) &&
+		    (p_fm_port->p_fm_port_drv_param->dflt_cfg.
+		     tx_fifo_deq_pipeline_depth != DEFAULT_NOT_SUPPORTED)) {
+			/* this is an indication that user called config for
+			 * this mode which is not supported in this integration
+			 **/
+			pr_err("fifoDeqPipelineDepth is available for Tx ports only\n");
+			return -EINVAL;
+		}
+#endif /* !FM_DEQ_PIPELINE_PARAMS_FOR_OP */
+	}
+
+	/*   All ports                          */
+
+	/* Check that not larger than 16 */
+	if ((p_params->cheksum_last_bytes_ignore > FRAME_END_DATA_SIZE) &&
+	    ((p_params->cheksum_last_bytes_ignore != DEFAULT_NOT_SUPPORTED))) {
+		pr_err("cheksum_last_bytes_ignore can't be larger than %d\n",
+		       FRAME_END_DATA_SIZE);
+		return -EDOM;
+	}
+
+	if (fm_sp_check_int_context_params(&p_params->int_context) != 0)
+		return -EDOM;
+
+	/* common BMI registers values */
+	if (p_params->set_num_of_tasks &&
+	    ((!p_fm_port->tasks.num) ||
+	     (p_fm_port->tasks.num > MAX_NUM_OF_TASKS))) {
+		pr_err("tasks.num can't be larger than %d\n",
+		       MAX_NUM_OF_TASKS);
+		return -EDOM;
+	}
+	if (p_params->set_num_of_tasks &&
+	    (p_fm_port->tasks.extra > MAX_NUM_OF_EXTRA_TASKS)) {
+		pr_err("tasks.extra can't be larger than %d\n",
+		       MAX_NUM_OF_EXTRA_TASKS);
+		return -EDOM;
+	}
+	if (p_params->set_num_of_open_dmas &&
+	    ((!p_fm_port->open_dmas.num) ||
+	     (p_fm_port->open_dmas.num > MAX_NUM_OF_DMAS))) {
+		pr_err("open_dmas.num can't be larger than %d\n",
+		       MAX_NUM_OF_DMAS);
+		return -EDOM;
+	}
+	if (p_params->set_num_of_open_dmas &&
+	    (p_fm_port->open_dmas.extra > MAX_NUM_OF_EXTRA_DMAS)) {
+		pr_err("open_dmas.extra can't be larger than %d\n",
+		       MAX_NUM_OF_EXTRA_DMAS);
+		return -EDOM;
+	}
+	if (p_params->set_size_of_fifo &&
+	    (!p_fm_port->fifo_bufs.num || (p_fm_port->fifo_bufs.num >
+	     p_fm_port->port_intg->max_port_fifo_size))) {
+		pr_err("fifo_bufs.num has to be in the range of 256 - %d\n",
+		       p_fm_port->port_intg->max_port_fifo_size);
+		return -EDOM;
+	}
+	if (p_params->set_size_of_fifo &&
+	    (p_fm_port->fifo_bufs.num % BMI_FIFO_UNITS)) {
+		pr_err("fifo_bufs.num has to be divisible by %d\n",
+		       BMI_FIFO_UNITS);
+		return -EDOM;
+	}
+
+#ifdef FM_QMI_NO_DEQ_OPTIONS_SUPPORT
+	if (p_fm_port->fm_rev_info.major_rev == 4)
+		if (p_fm_port->p_fm_port_drv_param->deq_prefetch_option !=
+		    DEFAULT_NOT_SUPPORTED) {
+			/* this is an indication that user called config
+			 * for this mode which is not supported in this
+			 * integration
+			 **/
+			pr_err("deq_prefetch_option\n");
+			return -EINVAL;
+		}
+#endif /* FM_QMI_NO_DEQ_OPTIONS_SUPPORT */
+
+	return 0;
+}
+
+/* Checks if p_fm_port driver parameters were initialized
+ * returns 0 if success else returns error code
+ */
+static int is_init_done(struct fm_port_drv_param_t *p_fm_port_drv_parameters)
+{
+	if (!p_fm_port_drv_parameters)
+		return 0;
+	return -EINVAL;
+}
+
+static int verify_size_of_fifo(struct fm_port_t *p_fm_port)
+{
+	uint32_t min_fifo_size_required = 0, opt_fifo_size_for_b2b = 0;
+
+	/* TX PORTS */
+	if (p_fm_port->port_type == FM_PORT_TYPE_TX) {
+		min_fifo_size_required = (uint32_t)
+		    (ROUND_UP(p_fm_port->max_frame_length,
+			      BMI_FIFO_UNITS) + (3 * BMI_FIFO_UNITS));
+
+		min_fifo_size_required +=
+		    p_fm_port->p_fm_port_drv_param->
+		    dflt_cfg.tx_fifo_deq_pipeline_depth * BMI_FIFO_UNITS;
+
+		opt_fifo_size_for_b2b = min_fifo_size_required;
+
+		/* Add some margin for back-to-back capability to improve
+		 * performance, allows the hardware to pipeline new frame dma
+		 * while the previous frame not yet transmitted.
+		 */
+		if (p_fm_port->port_speed == FM_PORT_SPEED_10G)
+			opt_fifo_size_for_b2b += 3 * BMI_FIFO_UNITS;
+		else
+			opt_fifo_size_for_b2b += 2 * BMI_FIFO_UNITS;
+	}
+
+	/* RX PORTS */
+	else if (p_fm_port->port_type == FM_PORT_TYPE_RX) {
+		if (p_fm_port->fm_rev_info.major_rev == 4) {
+			if (p_fm_port->rx_pools_params.num_of_pools == 1)
+				min_fifo_size_required = 8 * BMI_FIFO_UNITS;
+			else
+				min_fifo_size_required = (uint32_t)
+				    (ROUND_UP
+				     (p_fm_port->
+				      rx_pools_params.second_largest_buf_size,
+				      BMI_FIFO_UNITS) + (7 * BMI_FIFO_UNITS));
+		} else {
+			if (p_fm_port->fm_rev_info.major_rev >= 6)
+				min_fifo_size_required = (uint32_t)
+				(ROUND_UP(p_fm_port->max_frame_length,
+					BMI_FIFO_UNITS) + (5 * BMI_FIFO_UNITS));
+				/* 4 according to spec + 1 for FOF>0 */
+			else
+				min_fifo_size_required = (uint32_t)
+				(ROUND_UP(min(p_fm_port->max_frame_length,
+						p_fm_port->rx_pools_params.
+						largest_buf_size),
+					BMI_FIFO_UNITS) + (7 * BMI_FIFO_UNITS));
+		}
+
+		opt_fifo_size_for_b2b = min_fifo_size_required;
+
+		/* Add some margin for back-to-back capability to improve
+		 * performance,allows the hardware to pipeline new frame dma
+		 * while the previous frame not yet transmitted.
+		 */
+		if (p_fm_port->port_speed == FM_PORT_SPEED_10G)
+			opt_fifo_size_for_b2b += 8 * BMI_FIFO_UNITS;
+		else
+			opt_fifo_size_for_b2b += 3 * BMI_FIFO_UNITS;
+	}
+
+	/* For O/H ports, check fifo size and update if necessary */
+	else if (p_fm_port->port_type == FM_PORT_TYPE_OP) {
+		if (p_fm_port->fm_rev_info.major_rev >= 6) {
+			opt_fifo_size_for_b2b =  (uint32_t)(ROUND_UP(
+				p_fm_port->max_frame_length,
+				BMI_FIFO_UNITS) +
+				((p_fm_port->p_fm_port_drv_param->dflt_cfg.
+				tx_fifo_deq_pipeline_depth + 5) *
+				BMI_FIFO_UNITS));
+			min_fifo_size_required = opt_fifo_size_for_b2b;
+		/* 4 according to spec + 1 for FOF>0 */
+		} else {
+			opt_fifo_size_for_b2b =
+			(uint32_t)((p_fm_port->tasks.num + 2) * BMI_FIFO_UNITS);
+			min_fifo_size_required = opt_fifo_size_for_b2b;
+		}
+	}
+
+	ASSERT(min_fifo_size_required > 0);
+	ASSERT(opt_fifo_size_for_b2b >= min_fifo_size_required);
+
+	/* Verify the size  */
+	if (p_fm_port->fifo_bufs.num < min_fifo_size_required)
+		pr_debug("FIFO size should be enlarged to %d bytes\n",
+			 min_fifo_size_required);
+	else if (p_fm_port->fifo_bufs.num < opt_fifo_size_for_b2b)
+		pr_debug("For b2b processing,FIFO may be enlarged to %d bytes\n",
+			 opt_fifo_size_for_b2b);
+
+	return 0;
+}
+
+static void fm_port_drv_param_free(struct fm_port_t *p_fm_port)
+{
+	kfree(p_fm_port->p_fm_port_drv_param);
+	p_fm_port->p_fm_port_drv_param = NULL;
+}
+
+static int set_ext_buffer_pools(struct fm_port_t *p_fm_port)
+{
+	struct fm_ext_pools_t *p_ext_buf_pools =
+	    &p_fm_port->p_fm_port_drv_param->ext_buf_pools;
+	struct fm_buf_pool_depletion_t *p_buf_pool_depletion =
+	    &p_fm_port->p_fm_port_drv_param->buf_pool_depletion;
+	uint8_t ordered_array[FM_PORT_MAX_NUM_OF_EXT_POOLS];
+	uint16_t sizes_array[BM_MAX_NUM_OF_POOLS];
+	int i = 0, j = 0, err;
+	struct fman_port_bpools bpools;
+
+	memset(&ordered_array, 0,
+	       sizeof(uint8_t) * FM_PORT_MAX_NUM_OF_EXT_POOLS);
+	memset(&sizes_array, 0, sizeof(uint16_t) * BM_MAX_NUM_OF_POOLS);
+	memcpy(&p_fm_port->ext_buf_pools, p_ext_buf_pools,
+	       sizeof(struct fm_ext_pools_t));
+
+	fm_sp_set_buf_pools_in_asc_order_of_buf_sizes(p_ext_buf_pools,
+						      ordered_array,
+						      sizes_array);
+
+	/* Prepare flibs bpools structure */
+	memset(&bpools, 0, sizeof(struct fman_port_bpools));
+	bpools.count = p_ext_buf_pools->num_of_pools_used;
+	bpools.counters_enable = true;
+	for (i = 0; i < p_ext_buf_pools->num_of_pools_used; i++) {
+		bpools.bpool[i].bpid = ordered_array[i];
+		bpools.bpool[i].size = sizes_array[ordered_array[i]];
+		/* functionality available only for some derivatives
+		 * (limited by config)
+		 */
+		if (p_fm_port->p_fm_port_drv_param->p_backup_bm_pools)
+			for (j = 0; j < p_fm_port->p_fm_port_drv_param->
+			     p_backup_bm_pools->num_of_backup_pools; j++)
+				if (ordered_array[i] ==
+				    p_fm_port->p_fm_port_drv_param->
+				    p_backup_bm_pools->pool_ids[j]) {
+					bpools.bpool[i].is_backup = true;
+					break;
+				}
+	}
+
+	/* save pools parameters for later use */
+	p_fm_port->rx_pools_params.num_of_pools =
+	p_ext_buf_pools->num_of_pools_used;
+	p_fm_port->rx_pools_params.largest_buf_size =
+	    sizes_array[ordered_array[p_ext_buf_pools->
+		num_of_pools_used - 1]];
+	p_fm_port->rx_pools_params.second_largest_buf_size =
+	    sizes_array[ordered_array[p_ext_buf_pools->
+		num_of_pools_used - 2]];
+
+	/* FMBM_RMPD reg. - pool depletion */
+	if (p_buf_pool_depletion->pools_grp_mode_enable) {
+		bpools.grp_bp_depleted_num = p_buf_pool_depletion->
+num_of_pools;
+		for (i = 0; i < p_fm_port->port_intg->bm_max_num_of_pools;
+		     i++) {
+			if (p_buf_pool_depletion->pools_to_consider[i]) {
+				for (j = 0; j < p_ext_buf_pools->
+				     num_of_pools_used; j++) {
+					if (i == ordered_array[j]) {
+						bpools.bpool[j].
+						    grp_bp_depleted = true;
+						break;
+					}
+				}
+			}
+		}
+	}
+
+	if (p_buf_pool_depletion->single_pool_mode_enable) {
+		for (i = 0; i < p_fm_port->port_intg->bm_max_num_of_pools;
+		     i++) {
+			if (p_buf_pool_depletion->
+			    pools_to_consider_for_single_mode[i]) {
+				for (j = 0; j < p_ext_buf_pools->
+				     num_of_pools_used; j++) {
+					if (i == ordered_array[j]) {
+						bpools.bpool[j].
+						    single_bp_depleted = true;
+						break;
+					}
+				}
+			}
+		}
+	}
+
+	/* Issue flibs function */
+	err = fman_port_set_bpools(&p_fm_port->port, &bpools);
+	if (err != 0) {
+		pr_err("fman_port_set_bpools\n");
+		return -EDOM;
+	}
+
+	kfree(p_fm_port->p_fm_port_drv_param->p_backup_bm_pools);
+
+	return 0;
+}
+
+static int init_low_level_driver(struct fm_port_t *p_fm_port)
+{
+	struct fm_port_drv_param_t *p_drv_params = p_fm_port->
+	p_fm_port_drv_param;
+	struct fman_port_params port_params;
+	uint32_t tmp_val;
+
+	/* Set up flibs parameters and issue init function */
+
+	memset(&port_params, 0, sizeof(struct fman_port_params));
+	port_params.discard_mask = p_drv_params->errors_to_discard;
+	port_params.dflt_fqid = p_drv_params->dflt_fqid;
+	port_params.err_fqid = p_drv_params->err_fqid;
+	port_params.deq_sp = p_drv_params->deq_sub_portal;
+	port_params.dont_release_buf = p_drv_params->dont_release_buf;
+	switch (p_fm_port->port_type) {
+	case (FM_PORT_TYPE_RX):
+		port_params.err_mask =
+			(RX_ERRS_TO_ENQ & ~port_params.discard_mask);
+		if (p_drv_params->forward_reuse_int_context)
+			p_drv_params->dflt_cfg.rx_fd_bits =
+			    (uint8_t)(BMI_PORT_RFNE_FRWD_RPD >> 24);
+		break;
+
+	case (FM_PORT_TYPE_OP):
+		port_params.err_mask =
+			(OP_ERRS_TO_ENQ & ~port_params.discard_mask);
+		break;
+		break;
+
+	default:
+		break;
+	}
+
+	tmp_val = (uint32_t)((p_fm_port->internal_buf_offset %
+			     OFFSET_UNITS) ? (p_fm_port->
+			     internal_buf_offset / OFFSET_UNITS +
+			      1) : (p_fm_port->internal_buf_offset /
+				    OFFSET_UNITS));
+	p_fm_port->internal_buf_offset = (uint8_t)(tmp_val * OFFSET_UNITS);
+	p_drv_params->dflt_cfg.int_buf_start_margin =
+	    p_fm_port->internal_buf_offset;
+
+	p_drv_params->dflt_cfg.ext_buf_start_margin =
+	    p_drv_params->buf_margins.start_margins;
+	p_drv_params->dflt_cfg.ext_buf_end_margin =
+	    p_drv_params->buf_margins.end_margins;
+
+	p_drv_params->dflt_cfg.ic_ext_offset =
+	    p_drv_params->int_context.ext_buf_offset;
+	p_drv_params->dflt_cfg.ic_int_offset =
+	    p_drv_params->int_context.int_context_offset;
+	p_drv_params->dflt_cfg.ic_size = p_drv_params->int_context.size;
+
+	if (0 !=
+	    fman_port_init(&p_fm_port->port, &p_drv_params->dflt_cfg,
+			   &port_params)) {
+		pr_err("fman_port_init\n");
+		return -ENODEV;
+	}
+
+	/* The code bellow is a trick so the FM will not release the buffer
+	 * to BM nor will try to enqueue the frame to QM
+	 */
+	if (p_fm_port->port_type == FM_PORT_TYPE_TX) {
+		if (!p_drv_params->dflt_fqid && p_drv_params->
+		    dont_release_buf) {
+			/* override fmbm_tcfqid 0 with a false non-0 value.
+			 * This will force FM to act according to tfene.
+			 * Otherwise, if fmbm_tcfqid is 0 the FM will release
+			 * buffers to BM regardless of fmbm_tfene
+			 */
+			WRITE_UINT32(p_fm_port->port.bmi_regs->tx.fmbm_tcfqid,
+				     0xFFFFFF);
+			WRITE_UINT32(p_fm_port->port.bmi_regs->tx.fmbm_tfene,
+				     NIA_ENG_BMI | NIA_BMI_AC_TX_RELEASE);
+		}
+	}
+
+	return 0;
+}
+
+static struct fm_port_intg_t *set_port_intg_params(struct fm_port_t *p_fm_port)
+{
+	struct fm_port_intg_t *intg;
+	uint32_t bmi_max_fifo_size;
+
+	intg = kzalloc(sizeof(*intg), GFP_KERNEL);
+	if (!intg)
+		return NULL;
+
+	bmi_max_fifo_size = fm_get_bmi_max_fifo_size(p_fm_port->h_fm);
+
+	intg->max_port_fifo_size =
+				MAX_PORT_FIFO_SIZE(bmi_max_fifo_size);
+
+	switch (p_fm_port->fm_rev_info.major_rev) {
+	case FM_IP_BLOCK_P2_P3_P5:
+	case FM_IP_BLOCK_P4:
+		intg->max_num_of_ext_pools		= 4;
+		intg->fm_max_num_of_sub_portals		= 12;
+		intg->bm_max_num_of_pools		= 64;
+		break;
+
+	case FM_IP_BLOCK_P1:
+		intg->max_num_of_ext_pools		= 4;
+		intg->fm_max_num_of_sub_portals		= 7;
+		intg->bm_max_num_of_pools		= 8;
+		break;
+
+	case FM_IP_BLOCK_B_T:
+		intg->max_num_of_ext_pools		= 8;
+		intg->fm_max_num_of_sub_portals		= 16;
+		intg->bm_max_num_of_pools		= 64;
+		break;
+
+	default:
+		pr_err("Unsupported FMan version\n");
+		kfree(intg);
+		return NULL;
+	}
+
+	return intg;
+}
+
+/*       API Init unit functions        */
+
+struct fm_port_t *fm_port_config(struct fm_port_params_t *p_fm_port_params)
+{
+	struct fm_port_t *p_fm_port;
+	uintptr_t base_addr = p_fm_port_params->base_addr;
+#ifdef FM_WRONG_RESET_VALUES_ERRATA_FMAN_A005127
+	uint32_t tmp_reg;
+#endif /* FM_WRONG_RESET_VALUES_ERRATA_FMAN_A005127 */
+	enum fman_port_type fman_port_type = E_FMAN_PORT_TYPE_DUMMY;
+
+	/* Allocate FM structure */
+	p_fm_port = kzalloc(sizeof(*p_fm_port), GFP_KERNEL);
+	if (!p_fm_port)
+		return NULL;
+
+	/* Allocate the FM driver's parameters structure */
+	p_fm_port->p_fm_port_drv_param =
+	kzalloc(sizeof(*p_fm_port->p_fm_port_drv_param),
+		GFP_KERNEL);
+	if (!p_fm_port->p_fm_port_drv_param) {
+		kfree(p_fm_port);
+		pr_err("FM Port driver parameters\n");
+		return NULL;
+	}
+
+	/* Initialize FM port parameters which will be kept by the driver */
+	p_fm_port->port_type = p_fm_port_params->port_type;
+	p_fm_port->port_speed = p_fm_port_params->port_speed;
+	p_fm_port->port_id = p_fm_port_params->port_id;
+	p_fm_port->h_fm = p_fm_port_params->h_fm;
+
+	/* get FM revision */
+	fm_get_revision(p_fm_port->h_fm, &p_fm_port->fm_rev_info);
+
+	p_fm_port->port_intg = set_port_intg_params(p_fm_port);
+	if (!p_fm_port->port_intg) {
+			kfree(p_fm_port->p_fm_port_drv_param);
+			kfree(p_fm_port);
+			return NULL;
+	}
+
+	if (p_fm_port->fm_rev_info.major_rev >= 6) {
+		if ((p_fm_port->port_type == FM_PORT_TYPE_OP) &&
+		    (p_fm_port_params->port_id == FM_OH_PORT_ID))
+			pr_debug("Use nonzero portid for OP port\n");
+	}
+
+	/* Set up FM port parameters for initialization phase only */
+
+	/* First, fill in flibs struct */
+	/* In order to be aligned with flib port types, we need to translate
+	 * the port type and speed to fman_port_type
+	 */
+	if (p_fm_port->port_type == FM_PORT_TYPE_OP) {
+		fman_port_type = E_FMAN_PORT_TYPE_OP;
+	} else if (p_fm_port->port_type == FM_PORT_TYPE_TX) {
+		if (p_fm_port->port_speed == FM_PORT_SPEED_10G)
+			fman_port_type = E_FMAN_PORT_TYPE_TX_10G;
+		else
+			fman_port_type = E_FMAN_PORT_TYPE_TX;
+	} else if (p_fm_port->port_type == FM_PORT_TYPE_RX) {
+		if (p_fm_port->port_speed == FM_PORT_SPEED_10G)
+			fman_port_type = E_FMAN_PORT_TYPE_RX_10G;
+		else
+			fman_port_type = E_FMAN_PORT_TYPE_RX;
+	}
+	fman_port_defconfig(&p_fm_port->p_fm_port_drv_param->dflt_cfg,
+			    fman_port_type);
+	/* Overwrite some integration specific parameters */
+	p_fm_port->p_fm_port_drv_param->dflt_cfg.rx_pri_elevation =
+		DFLT_PORT_RX_FIFO_PRI_ELEVATION_LEV(
+				p_fm_port->port_intg->max_port_fifo_size);
+	p_fm_port->p_fm_port_drv_param->dflt_cfg.rx_fifo_thr =
+	p_fm_port->p_fm_port_drv_param->rx_fifo_threshold =
+	DFLT_PORT_RX_FIFO_THRESHOLD(
+				    p_fm_port->fm_rev_info.major_rev,
+				    p_fm_port->port_intg->max_port_fifo_size);
+
+	p_fm_port->p_fm_port_drv_param->dflt_cfg.errata_A006675 = false;
+
+#if defined(FM_OP_NO_VSP_NO_RELEASE_ERRATA_FMAN_A006675) || \
+defined(FM_ERROR_VSP_NO_MATCH_SW006)
+	if (p_fm_port->fm_rev_info.major_rev >= 6)
+		p_fm_port->p_fm_port_drv_param->dflt_cfg.errata_A006675 =
+		true;
+#endif
+	if ((p_fm_port->fm_rev_info.major_rev == 6) &&
+	    ((p_fm_port->fm_rev_info.minor_rev == 0) ||
+	     (p_fm_port->fm_rev_info.minor_rev == 3)))
+		p_fm_port->p_fm_port_drv_param->dflt_cfg.errata_A006320 =
+		true;
+	else
+		p_fm_port->p_fm_port_drv_param->dflt_cfg.errata_A006320 =
+		false;
+
+	/* Excessive Threshold register - exists for pre-FMv3 chips only */
+	if (p_fm_port->fm_rev_info.major_rev < 6) {
+#ifdef FM_NO_RESTRICT_ON_ACCESS_RSRC
+		p_fm_port->p_fm_port_drv_param->dflt_cfg.
+		    excessive_threshold_register = true;
+#endif /* FM_NO_RESTRICT_ON_ACCESS_RSRC */
+		p_fm_port->p_fm_port_drv_param->dflt_cfg.fmbm_rebm_has_sgd =
+		    false;
+		p_fm_port->p_fm_port_drv_param->
+		dflt_cfg.fmbm_tfne_has_features =
+		    false;
+	} else {
+		p_fm_port->p_fm_port_drv_param->dflt_cfg.
+		    excessive_threshold_register = false;
+		p_fm_port->p_fm_port_drv_param->dflt_cfg.fmbm_rebm_has_sgd =
+		true;
+		p_fm_port->p_fm_port_drv_param->
+		dflt_cfg.fmbm_tfne_has_features = true;
+	}
+	if (p_fm_port->fm_rev_info.major_rev == 4)
+		p_fm_port->p_fm_port_drv_param->
+		dflt_cfg.qmi_deq_options_support = false;
+	else
+		p_fm_port->p_fm_port_drv_param->
+		dflt_cfg.qmi_deq_options_support = true;
+
+	/* Continue with other parameters */
+	p_fm_port->p_fm_port_drv_param->base_addr = base_addr;
+	/* set memory map pointers */
+	p_fm_port->p_fm_port_qmi_regs =
+	    (struct fm_port_qmi_regs_t __iomem *)UINT_TO_PTR(base_addr +
+	QMI_PORT_REGS_OFFSET);
+	p_fm_port->p_fm_port_bmi_regs =
+	    (union fm_port_bmi_regs_u __iomem *)UINT_TO_PTR(base_addr +
+	BMI_PORT_REGS_OFFSET);
+
+	p_fm_port->p_fm_port_drv_param->
+	buffer_prefix_content.priv_data_size =
+	    DEFAULT_PORT_BUFFER_PREFIX_CONTENT_PRIV_DATA_SIZE;
+	p_fm_port->p_fm_port_drv_param->
+	buffer_prefix_content.pass_prs_result =
+	    DEFAULT_PORT_BUFFER_PREFIX_CONTENT_PASS_PRS_RESULT;
+	p_fm_port->p_fm_port_drv_param->
+	buffer_prefix_content.pass_time_stamp =
+	    DEFAULT_PORT_BUFFER_PREFIX_CONTENT_PASS_TIME_STAMP;
+	p_fm_port->p_fm_port_drv_param->buffer_prefix_content.data_align =
+	    DEFAULT_PORT_BUFFER_PREFIX_CONTEXT_DATA_ALIGN;
+	p_fm_port->p_fm_port_drv_param->liodn_base =
+	    p_fm_port_params->liodn_base;
+	p_fm_port->p_fm_port_drv_param->cheksum_last_bytes_ignore =
+	    DEFAULT_PORT_CHECKSUM_LAST_BYTES_IGNORE;
+
+	p_fm_port->max_frame_length = DEFAULT_PORT_MAX_FRAME_LENGTH;
+	/* resource distribution. */
+
+	p_fm_port->fifo_bufs.num =
+	DFLT_PORT_NUM_OF_FIFO_BUFS(p_fm_port->fm_rev_info.major_rev,
+				   p_fm_port->port_type,
+				   p_fm_port->port_speed) * BMI_FIFO_UNITS;
+	p_fm_port->fifo_bufs.extra =
+	DFLT_PORT_EXTRA_NUM_OF_FIFO_BUFS * BMI_FIFO_UNITS;
+
+	p_fm_port->open_dmas.num =
+	DFLT_PORT_NUM_OF_OPEN_DMAS(p_fm_port->fm_rev_info.major_rev,
+				   p_fm_port->port_type,
+				   p_fm_port->port_speed);
+	p_fm_port->open_dmas.extra =
+	DFLT_PORT_EXTRA_NUM_OF_OPEN_DMAS(p_fm_port->fm_rev_info.major_rev,
+					 p_fm_port->port_type,
+					 p_fm_port->port_speed);
+	p_fm_port->tasks.num =
+	DFLT_PORT_NUM_OF_TASKS(p_fm_port->fm_rev_info.major_rev,
+			       p_fm_port->port_type,
+			       p_fm_port->port_speed);
+	p_fm_port->tasks.extra =
+	DFLT_PORT_EXTRA_NUM_OF_TASKS(p_fm_port->fm_rev_info.major_rev,
+				     p_fm_port->port_type,
+				     p_fm_port->port_speed);
+
+#ifdef FM_HEAVY_TRAFFIC_SEQUENCER_HANG_ERRATA_FMAN_A006981
+	if ((p_fm_port->fm_rev_info.major_rev == 6) &&
+	    (p_fm_port->fm_rev_info.minor_rev == 0) &&
+	    ((p_fm_port->port_type == FM_PORT_TYPE_OP) ||
+	     ((p_fm_port->port_type == FM_PORT_TYPE_TX) &&
+	     (p_fm_port->port_speed == FM_PORT_SPEED_1G)))) {
+		p_fm_port->open_dmas.num = 16;
+		p_fm_port->open_dmas.extra = 0;
+	}
+#endif /* FM_HEAVY_TRAFFIC_SEQUENCER_HANG_ERRATA_FMAN_A006981 */
+
+	/* Port type specific initialization: */
+	switch (p_fm_port->port_type) {
+	case (FM_PORT_TYPE_RX):
+		/* Initialize FM port parameters for initialization phase only*/
+		p_fm_port->p_fm_port_drv_param->cut_bytes_from_end =
+		    DEFAULT_PORT_CUT_BYTES_FROM_END;
+		p_fm_port->p_fm_port_drv_param->en_buf_pool_depletion = false;
+		p_fm_port->p_fm_port_drv_param->frm_discard_override =
+		    DEFAULT_PORT_FRM_DISCARD_OVERRIDE;
+
+		p_fm_port->p_fm_port_drv_param->rx_fifo_pri_elevation_level =
+		DFLT_PORT_RX_FIFO_PRI_ELEVATION_LEV(p_fm_port->port_intg->
+						    max_port_fifo_size);
+		p_fm_port->p_fm_port_drv_param->rx_fifo_threshold =
+		DFLT_PORT_RX_FIFO_THRESHOLD(p_fm_port->fm_rev_info.major_rev,
+					    p_fm_port->port_intg->
+					    max_port_fifo_size);
+
+		p_fm_port->p_fm_port_drv_param->buf_margins.end_margins =
+		    DEFAULT_PORT_BUF_MARGINS_END_MAARGINS;
+		p_fm_port->p_fm_port_drv_param->errors_to_discard =
+		    DEFAULT_PORT_ERRORS_TO_DISCARD;
+		p_fm_port->p_fm_port_drv_param->forward_reuse_int_context =
+		    DEFAULT_PORT_FORWARD_INT_CONTENT_REUSE;
+		break;
+
+	case (FM_PORT_TYPE_TX):
+		if (p_fm_port->port_speed == FM_PORT_SPEED_1G) {
+			p_fm_port->p_fm_port_drv_param->dont_release_buf =
+			false;
+#ifdef FM_WRONG_RESET_VALUES_ERRATA_FMAN_A005127
+			if (p_fm_port->fm_rev_info.major_rev >= 6) {
+				tmp_reg = 0x00001013;
+				WRITE_UINT32(p_fm_port->p_fm_port_bmi_regs->
+					     tx_port_bmi_regs.fmbm_tfp,
+					     tmp_reg);
+			}
+#endif /* FM_WRONG_RESET_VALUES_ERRATA_FMAN_A005127 */
+		}
+		if (p_fm_port->port_speed == FM_PORT_SPEED_10G) {
+			p_fm_port->p_fm_port_drv_param->tx_fifo_min_fill_level
+			= DFLT_PORT_TX_FIFO_MIN_FILL_LEVEL;
+			p_fm_port->p_fm_port_drv_param->tx_fifo_low_comf_level
+			= DFLT_PORT_TX_FIFO_LOW_COMF_LEVEL;
+
+			p_fm_port->p_fm_port_drv_param->deq_type =
+			DEFAULT_PORT_DEQ_TYPE;
+			p_fm_port->p_fm_port_drv_param->deq_prefetch_option =
+			DEFAULT_PORT_DEQ_PREFETCH_OPT;
+		}
+		p_fm_port->p_fm_port_drv_param->deq_high_priority =
+			DFLT_PORT_DEQ_HIGH_PRIORITY(p_fm_port->port_speed);
+		p_fm_port->p_fm_port_drv_param->deq_byte_cnt =
+			DFLT_PORT_DEQ_BYTE_CNT(p_fm_port->port_speed);
+		p_fm_port->p_fm_port_drv_param->dflt_cfg.
+			tx_fifo_deq_pipeline_depth = (uint8_t)
+			DFLT_PORT_FIFO_DEQ_PIPELINE_DEPTH(
+				     p_fm_port->fm_rev_info.major_rev,
+				     p_fm_port->port_type,
+				     p_fm_port->port_speed);
+		break;
+	case (FM_PORT_TYPE_OP):
+		p_fm_port->p_fm_port_drv_param->errors_to_discard =
+		    DEFAULT_PORT_ERRORS_TO_DISCARD;
+		break;
+
+	default:
+		kfree(p_fm_port->p_fm_port_drv_param);
+		kfree(p_fm_port);
+		pr_err("Invalid port type\n");
+		return NULL;
+	}
+
+#ifdef FM_QMI_NO_DEQ_OPTIONS_SUPPORT
+	if (p_fm_port->fm_rev_info.major_rev == 4)
+		p_fm_port->p_fm_port_drv_param->deq_prefetch_option =
+		    (enum fm_port_deq_prefetch_option)DEFAULT_NOT_SUPPORTED;
+#endif /* FM_QMI_NO_DEQ_OPTIONS_SUPPORT */
+
+	switch (p_fm_port->port_type) {
+	case (FM_PORT_TYPE_RX):
+		/* Initialize FM port parameters for initialization phase only*/
+		memcpy(&p_fm_port->p_fm_port_drv_param->ext_buf_pools,
+		       &p_fm_port_params->
+			specific_params.rx_params.ext_buf_pools,
+		       sizeof(struct fm_ext_pools_t));
+		p_fm_port->p_fm_port_drv_param->err_fqid
+		    = p_fm_port_params->specific_params.rx_params.err_fqid;
+		p_fm_port->p_fm_port_drv_param->dflt_fqid
+		    = p_fm_port_params->specific_params.rx_params.dflt_fqid;
+		p_fm_port->p_fm_port_drv_param->liodn_offset
+		    = p_fm_port_params->specific_params.rx_params.liodn_offset;
+		break;
+	case (FM_PORT_TYPE_OP):
+	case (FM_PORT_TYPE_TX):
+		p_fm_port->p_fm_port_drv_param->err_fqid =
+		    p_fm_port_params->specific_params.non_rx_params.err_fqid;
+		p_fm_port->p_fm_port_drv_param->deq_sub_portal =
+		    (uint8_t)(p_fm_port_params->specific_params.non_rx_params.
+			       qm_channel & QMI_DEQ_CFG_SUBPORTAL_MASK);
+		p_fm_port->p_fm_port_drv_param->dflt_fqid =
+		    p_fm_port_params->specific_params.non_rx_params.dflt_fqid;
+		break;
+	default:
+		kfree(p_fm_port->p_fm_port_drv_param);
+		kfree(p_fm_port);
+		pr_err("Invalid port type\n");
+		return NULL;
+	}
+
+	memset(p_fm_port->name, 0, (sizeof(char)) * MODULE_NAME_SIZE);
+	if (snprintf(p_fm_port->name, MODULE_NAME_SIZE, "FM-%d-port-%s-%d",
+		     fm_get_id(p_fm_port->h_fm),
+		     ((p_fm_port->port_type == FM_PORT_TYPE_OP) ? "OP" :
+		     ((p_fm_port->port_type == FM_PORT_TYPE_TX) ?
+		     ((p_fm_port->port_speed == FM_PORT_SPEED_10G) ? "10g-TX" :
+		     "1g-TX") :
+		     ((p_fm_port->port_speed == FM_PORT_SPEED_10G) ? "10g-RX" :
+		     "1g-RX"))),
+		     p_fm_port->port_id) == 0) {
+		kfree(p_fm_port->p_fm_port_drv_param);
+		kfree(p_fm_port);
+		pr_err("sprintf failed\n");
+		return NULL;
+	}
+
+	p_fm_port->spinlock = kmalloc(sizeof(spinlock_t), GFP_KERNEL);
+	if (!p_fm_port->spinlock) {
+		kfree(p_fm_port->p_fm_port_drv_param);
+		kfree(p_fm_port);
+		pr_err("Spin lock init failed\n");
+		return NULL;
+	}
+
+	spin_lock_init(p_fm_port->spinlock);
+
+	return p_fm_port;
+}
+
+int fm_port_init(struct fm_port_t *p_fm_port)
+{
+	struct fm_port_drv_param_t *p_drv_params;
+	int err_code;
+	struct fm_inter_module_port_init_params_t fm_params;
+	struct fm_revision_info_t rev_info;
+	int ret, ret_err;
+	enum fman_port_type fman_port_type = E_FMAN_PORT_TYPE_DUMMY;
+
+	ret = is_init_done(p_fm_port->p_fm_port_drv_param);
+	if (!ret)
+		return -EINVAL;
+
+	err_code =
+	    fm_sp_build_buffer_structure(&p_fm_port->p_fm_port_drv_param->
+					 int_context,
+					 &p_fm_port->p_fm_port_drv_param->
+					 buffer_prefix_content,
+					 &p_fm_port->p_fm_port_drv_param->
+					 buf_margins,
+					 &p_fm_port->buffer_offsets,
+					 &p_fm_port->internal_buf_offset);
+	if (err_code != 0)
+		return -err_code;
+#ifdef FM_HEAVY_TRAFFIC_HANG_ERRATA_FMAN_A005669
+	if (p_fm_port->fm_rev_info.major_rev >= 6 &&
+	    (p_fm_port->p_fm_port_drv_param->bcb_workaround) &&
+	    ((p_fm_port->port_type == FM_PORT_TYPE_RX) &&
+	    (p_fm_port->port_speed == FM_PORT_SPEED_1G))) {
+		p_fm_port->p_fm_port_drv_param->errors_to_discard |=
+		    FM_PORT_FRM_ERR_PHYSICAL;
+		if (!p_fm_port->fifo_bufs.num)
+			p_fm_port->fifo_bufs.num =
+				DFLT_PORT_NUM_OF_FIFO_BUFS(
+					p_fm_port->fm_rev_info.major_rev,
+					p_fm_port->port_type,
+					p_fm_port->port_speed) *
+					BMI_FIFO_UNITS;
+		p_fm_port->fifo_bufs.num += 4 * 1024;
+	}
+#endif /* FM_HEAVY_TRAFFIC_HANG_ERRATA_FMAN_A005669 */
+
+	ret_err = check_init_parameters(p_fm_port);
+	if (ret_err)
+		return ret_err;
+
+	p_drv_params = p_fm_port->p_fm_port_drv_param;
+
+	/* Set up flibs port structure */
+	memset(&p_fm_port->port, 0, sizeof(struct fman_port));
+	/* In order to be aligned with flib port types, we need to translate
+	 * the port type and speed to fman_port_type
+	 */
+	if (p_fm_port->port_type == FM_PORT_TYPE_OP) {
+		fman_port_type = E_FMAN_PORT_TYPE_OP;
+	} else if (p_fm_port->port_type == FM_PORT_TYPE_TX) {
+		if (p_fm_port->port_speed == FM_PORT_SPEED_10G)
+			fman_port_type = E_FMAN_PORT_TYPE_TX_10G;
+		else
+			fman_port_type = E_FMAN_PORT_TYPE_TX;
+	} else if (p_fm_port->port_type == FM_PORT_TYPE_RX) {
+		if (p_fm_port->port_speed == FM_PORT_SPEED_10G)
+			fman_port_type = E_FMAN_PORT_TYPE_RX_10G;
+		else
+			fman_port_type = E_FMAN_PORT_TYPE_RX;
+	}
+	p_fm_port->port.type = fman_port_type;
+	fm_get_revision(p_fm_port->h_fm, &rev_info);
+	p_fm_port->port.fm_rev_maj = rev_info.major_rev;
+	p_fm_port->port.fm_rev_min = rev_info.minor_rev;
+	p_fm_port->port.bmi_regs = (union fman_port_bmi_regs __iomem *)
+	    UINT_TO_PTR(p_drv_params->base_addr + BMI_PORT_REGS_OFFSET);
+	p_fm_port->port.qmi_regs = (struct fman_port_qmi_regs __iomem *)
+	    UINT_TO_PTR(p_drv_params->base_addr + QMI_PORT_REGS_OFFSET);
+	p_fm_port->port.ext_pools_num =
+	    (uint8_t)((rev_info.major_rev == 4) ? 4 : 8);
+
+	if (p_fm_port->port_type == FM_PORT_TYPE_RX) {
+		/* Call the external Buffer routine which also checks fifo
+		 * size and updates it if necessary
+		 */
+		/* define external buffer pools and pool depletion */
+		err_code = set_ext_buffer_pools(p_fm_port);
+		if (err_code)
+			return -err_code;
+		/* check if the largest external buffer pool is large enough */
+		if (p_drv_params->buf_margins.start_margins +
+		    MIN_EXT_BUF_SIZE +
+		    p_drv_params->buf_margins.end_margins >
+		    p_fm_port->rx_pools_params.largest_buf_size) {
+			pr_err("buf_margins.start_margins (%d) + minimum buf size (64) + buf_margins.end_margins (%d) is larger than maximum external buffer size (%d)\n",
+			       p_drv_params->buf_margins.start_margins,
+			       p_drv_params->buf_margins.end_margins,
+			       p_fm_port->rx_pools_params.largest_buf_size);
+			return -EINVAL;
+		}
+	}
+	if (p_fm_port->port_type == FM_PORT_TYPE_OP) {
+		{
+#ifdef FM_NO_OP_OBSERVED_POOLS
+			struct fm_revision_info_t rev_info;
+
+			fm_get_revision(p_fm_port->h_fm, &rev_info);
+		if ((rev_info.major_rev == 4) &&
+		    (p_drv_params->en_buf_pool_depletion))
+#endif /* FM_NO_OP_OBSERVED_POOLS */
+			{
+				/* define external buffer pools */
+				err_code = set_ext_buffer_pools(p_fm_port);
+				if (err_code)
+					return -err_code;
+			}
+		}
+	}
+
+	/* Call FM module routine for communicating parameters      */
+
+	memset(&fm_params, 0, sizeof(fm_params));
+	fm_params.port_id = p_fm_port->port_id;
+	fm_params.port_type = (enum fm_port_type)p_fm_port->port_type;
+	fm_params.port_speed = (enum fm_port_speed)p_fm_port->port_speed;
+	fm_params.num_of_tasks = (uint8_t)p_fm_port->tasks.num;
+	fm_params.num_of_extra_tasks = (uint8_t)p_fm_port->tasks.extra;
+	fm_params.num_of_open_dmas = (uint8_t)p_fm_port->open_dmas.num;
+	fm_params.num_of_extra_open_dmas = (uint8_t)p_fm_port->open_dmas.extra;
+
+	if (p_fm_port->fifo_bufs.num) {
+		err_code = verify_size_of_fifo(p_fm_port);
+		if (err_code != 0)
+			return -err_code;
+	}
+	fm_params.size_of_fifo = p_fm_port->fifo_bufs.num;
+	fm_params.extra_size_of_fifo = p_fm_port->fifo_bufs.extra;
+	fm_params.liodn_offset = p_drv_params->liodn_offset;
+	fm_params.liodn_base = p_drv_params->liodn_base;
+	fm_params.deq_pipeline_depth =
+	    p_fm_port->p_fm_port_drv_param->
+	    dflt_cfg.tx_fifo_deq_pipeline_depth;
+	fm_params.max_frame_length = p_fm_port->max_frame_length;
+#ifndef FM_DEQ_PIPELINE_PARAMS_FOR_OP
+	if (p_fm_port->port_type == FM_PORT_TYPE_OP) {
+		if (!((p_fm_port->fm_rev_info.major_rev == 4) ||
+		      (p_fm_port->fm_rev_info.major_rev >= 6)))
+			/* OP ports do not have fifoDeqPipelineDepth,
+			 * but it is needed only
+			 *for deq threshold calculation.
+			 */
+			fm_params.deq_pipeline_depth = 2;
+	}
+#endif /* !FM_DEQ_PIPELINE_PARAMS_FOR_OP */
+
+	err_code = fm_get_set_port_params(p_fm_port->h_fm, &fm_params);
+	if (err_code)
+		return -err_code;
+
+	err_code = init_low_level_driver(p_fm_port);
+	if (err_code != 0)
+		return -err_code;
+
+	fm_port_drv_param_free(p_fm_port);
+
+	return 0;
+}
+
+int fm_port_free(struct fm_port_t *p_fm_port)
+{
+	struct fm_inter_module_port_free_params_t fm_params;
+
+	if (p_fm_port->enabled) {
+		if (fm_port_disable(p_fm_port) != 0) {
+			pr_err("fm_port_disable FAILED\n");
+			return -EINVAL;
+		}
+	}
+
+	fm_port_drv_param_free(p_fm_port);
+
+	fm_params.port_id = p_fm_port->port_id;
+	fm_params.port_type = (enum fm_port_type)p_fm_port->port_type;
+	fm_params.deq_pipeline_depth =
+	    p_fm_port->p_fm_port_drv_param->
+	    dflt_cfg.tx_fifo_deq_pipeline_depth;
+
+	fm_free_port_params(p_fm_port->h_fm, &fm_params);
+
+	kfree(p_fm_port->spinlock);
+
+	kfree(p_fm_port);
+
+	return 0;
+}
+
+/*       API Advanced Init unit functions        */
+
+int fm_port_cfg_deq_high_priority(struct fm_port_t *p_fm_port, bool high_pri)
+{
+	int ret;
+
+	ret = is_init_done(p_fm_port->p_fm_port_drv_param);
+	if (!ret)
+		return -EINVAL;
+
+	if (p_fm_port->port_type == FM_PORT_TYPE_RX) {
+		pr_err("not available for Rx ports\n");
+		return -ENOMEM;
+	}
+
+	p_fm_port->p_fm_port_drv_param->dflt_cfg.deq_high_pri = high_pri;
+
+	return 0;
+}
+
+int fm_port_cfg_deq_prefetch_option(struct fm_port_t *p_fm_port,
+				    enum fm_port_deq_prefetch_option
+				    deq_prefetch_option)
+{
+	int ret;
+
+	ret = is_init_done(p_fm_port->p_fm_port_drv_param);
+	if (!ret)
+		return -EINVAL;
+
+	if (p_fm_port->port_type == FM_PORT_TYPE_RX) {
+		pr_err("not available for Rx ports\n");
+		return -ENODEV;
+	}
+	p_fm_port->p_fm_port_drv_param->dflt_cfg.deq_prefetch_opt =
+	    (enum fman_port_deq_prefetch)deq_prefetch_option;
+
+	return 0;
+}
+
+int fm_port_cfg_buf_prefix_content(struct fm_port_t *p_fm_port,
+				   struct fm_buffer_prefix_content_t *
+				   p_fm_buffer_prefix_content)
+{
+	int ret;
+
+	ret = is_init_done(p_fm_port->p_fm_port_drv_param);
+	if (!ret)
+		return -EINVAL;
+
+	memcpy(&p_fm_port->p_fm_port_drv_param->buffer_prefix_content,
+	       p_fm_buffer_prefix_content,
+	       sizeof(struct fm_buffer_prefix_content_t));
+	/* if data_align was not initialized by user,
+	 * we return to driver's default
+	 **/
+	if (!p_fm_port->p_fm_port_drv_param->
+	    buffer_prefix_content.data_align)
+		p_fm_port->p_fm_port_drv_param->
+		buffer_prefix_content.data_align =
+		    DEFAULT_PORT_BUFFER_PREFIX_CONTEXT_DATA_ALIGN;
+
+	return 0;
+}
+
+#ifdef FM_HEAVY_TRAFFIC_HANG_ERRATA_FMAN_A005669
+int fm_port_cfg_bcb_wa(struct fm_port_t *p_fm_port)
+{
+	int ret;
+
+	ret = is_init_done(p_fm_port->p_fm_port_drv_param);
+	if (!ret)
+		return -EINVAL;
+
+	p_fm_port->p_fm_port_drv_param->bcb_workaround = true;
+
+	return 0;
+}
+#endif /* FM_HEAVY_TRAFFIC_HANG_ERRATA_FMAN_A005669 */
+
+/*       API Run-time Control unit functions        */
+
+u64 *fm_port_get_buffer_time_stamp(const struct fm_port_t *p_fm_port,
+				   char *p_data)
+{
+	int ret;
+
+	ret = is_init_done(p_fm_port->p_fm_port_drv_param);
+	if (ret)
+		return NULL;
+
+	if (p_fm_port->buffer_offsets.time_stamp_offset == ILLEGAL_BASE)
+		return NULL;
+
+	return (uint64_t *)PTR_MOVE(p_data,
+				    p_fm_port->
+				    buffer_offsets.time_stamp_offset);
+}
+EXPORT_SYMBOL(fm_port_get_buffer_time_stamp);
+
+int fm_port_disable(struct fm_port_t *p_fm_port)
+{
+	int err, ret;
+
+	ret = is_init_done(p_fm_port->p_fm_port_drv_param);
+	if (ret)
+		return ret;
+
+	err = fman_port_disable(&p_fm_port->port);
+	if (err == -EBUSY) {
+		pr_debug("%s: BMI or QMI is Busy. Port forced down\n",
+			 p_fm_port->name);
+		err = 0;
+	}
+
+	p_fm_port->enabled = false;
+
+	return err;
+}
+EXPORT_SYMBOL(fm_port_disable);
+
+int fm_port_suspend(struct fm_port_t *p_fm_port)
+{
+	int err, ret;
+
+	ret = is_init_done(p_fm_port->p_fm_port_drv_param);
+	if (ret)
+		return ret;
+
+	err = fman_port_disable(&p_fm_port->port);
+	if (err == -EBUSY) {
+		pr_debug("%s: BMI or QMI is Busy. Port forced down\n",
+			 p_fm_port->name);
+		err = 0;
+	}
+
+	p_fm_port->enabled = false;
+
+	return err;
+}
+EXPORT_SYMBOL(fm_port_suspend);
+
+int fm_port_enable(struct fm_port_t *p_fm_port)
+{
+	int err, ret;
+
+	ret = is_init_done(p_fm_port->p_fm_port_drv_param);
+	if (ret)
+		return ret;
+
+	/* Used by fm_port_free routine as indication
+	 * if to disable port. Thus set it to true prior
+	 * to enabling itself. This way if part of enable
+	 * process fails there will be still things
+	 * to disable during Free. For example, if BMI
+	 * enable succeeded but QMI failed, still  BMI
+	 * needs to be disabled by Free.
+	 */
+	p_fm_port->enabled = true;
+
+	err = fman_port_enable(&p_fm_port->port);
+
+	return err;
+}
+EXPORT_SYMBOL(fm_port_enable);
+
+int fm_port_resume(struct fm_port_t *p_fm_port)
+{
+	int err, ret;
+
+	ret = is_init_done(p_fm_port->p_fm_port_drv_param);
+	if (ret)
+		return ret;
+
+	/* Used by fm_port_free routine as indication
+	 * if to disable port. Thus set it to true prior
+	 * to enabling itself. This way if part of enable
+	 * process fails there will be still things
+	 * to disable during Free. For example, if BMI
+	 * enable succeeded but QMI failed, still  BMI
+	 * needs to be disabled by Free.
+	 */
+	p_fm_port->enabled = true;
+
+	err = fman_port_enable(&p_fm_port->port);
+
+	return err;
+}
+EXPORT_SYMBOL(fm_port_resume);
diff --git a/drivers/net/ethernet/freescale/fman/port/fm_port.h b/drivers/net/ethernet/freescale/fman/port/fm_port.h
new file mode 100644
index 0000000..449fce6
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/port/fm_port.h
@@ -0,0 +1,527 @@
+/*
+ * Copyright 2008 - 2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+/* FM Port internal structures and definitions. */
+#ifndef __FM_PORT_H
+#define __FM_PORT_H
+
+#include "service.h"
+
+#include "fm_common.h"
+#include "fm_sp_common.h"
+#include "fsl_fman_sp.h"
+#include "fm_port_ext.h"
+#include "fsl_fman_port.h"
+
+#define LIODN_DONT_OVERRIDE    (-1)
+
+#define MIN_EXT_BUF_SIZE				64
+
+#define MAX_PORT_FIFO_SIZE(bmi_max_fifo_size)	\
+	min((u32)bmi_max_fifo_size, (u32)1024 * BMI_FIFO_UNITS)
+
+/* Memory Map defines */
+#define BMI_PORT_REGS_OFFSET				0
+#define QMI_PORT_REGS_OFFSET				0x400
+
+/* defaults */
+#define DFLT_PORT_DEQ_HIGH_PRIORITY(speed)	\
+	((speed == FM_PORT_SPEED_10G) ? true : false)
+#define DEFAULT_PORT_DEQ_TYPE				FM_PORT_DEQ_TYPE1
+#define DEFAULT_PORT_DEQ_PREFETCH_OPT		\
+	FM_PORT_DEQ_FULL_PREFETCH
+#define DFLT_PORT_DEQ_BYTE_CNT(speed)		\
+	((speed == FM_PORT_SPEED_10G) ? 0x1400 : 0x400)
+#define DEFAULT_PORT_BUFFER_PREFIX_CONTENT_PRIV_DATA_SIZE	\
+	DEFAULT_FM_SP_BUFFER_PREFIX_CONTENT_PRIV_DATA_SIZE
+#define DEFAULT_PORT_BUFFER_PREFIX_CONTENT_PASS_PRS_RESULT	\
+	DEFAULT_FM_SP_BUFFER_PREFIX_CONTENT_PRIV_PASS_PRS_RESULT
+#define DEFAULT_PORT_BUFFER_PREFIX_CONTENT_PASS_TIME_STAMP	\
+	DEFAULT_FM_SP_BUFFER_PREFIX_CONTEXT_PASS_TIME_STAMP
+#define DEFAULT_PORT_BUFFER_PREFIX_CONTEXT_DATA_ALIGN		\
+	DEFAULT_FM_SP_BUFFER_PREFIX_CONTEXT_DATA_ALIGN
+#define DEFAULT_PORT_CHECKSUM_LAST_BYTES_IGNORE	0
+#define DEFAULT_PORT_CUT_BYTES_FROM_END		4
+
+#define DEFAULT_PORT_FRM_DISCARD_OVERRIDE		false
+
+#define DEFAULT_PORT_FORWARD_INT_CONTENT_REUSE		false
+#define DEFAULT_PORT_BUF_MARGINS_END_MAARGINS		0
+#define DEFAULT_PORT_ERRORS_TO_DISCARD		\
+	FM_PORT_FRM_ERR_CLS_DISCARD
+#define DEFAULT_PORT_MAX_FRAME_LENGTH			9600
+
+#define DEFAULT_NOT_SUPPORTED				0xff
+
+#define DFLT_PORT_RX_FIFO_PRI_ELEVATION_LEV(bmi_max_fifo_size)	\
+	MAX_PORT_FIFO_SIZE(bmi_max_fifo_size)
+
+#define DFLT_PORT_RX_FIFO_THRESHOLD(major, bmi_max_fifo_size)	\
+	(major == 6 ?						\
+	MAX_PORT_FIFO_SIZE(bmi_max_fifo_size) :		\
+	(MAX_PORT_FIFO_SIZE(bmi_max_fifo_size) * 3 / 4))	\
+
+#define DFLT_PORT_TX_FIFO_MIN_FILL_LEVEL		0
+#define DFLT_PORT_TX_FIFO_LOW_COMF_LEVEL		(5 * 1024)
+
+/* OP - 2, 10G - 4, 1G (FMAN V3 - 2, FMAN V2 - 1) */
+#define DFLT_PORT_FIFO_DEQ_PIPELINE_DEPTH(major, type, speed)		\
+	((type == FM_PORT_TYPE_OP) ? 2 :				\
+		((speed == FM_PORT_SPEED_10G) ? 4 :			\
+		((major >= 6) ? 2 : 1)))
+
+#define DFLT_PORT_EXTRA_NUM_OF_FIFO_BUFS		0
+
+/* FMAN V3: OP - 6, 10G (RX/TX 16), 1G (RX/TX) 4
+ * FMAN V2: OP - 3, 10G (TX/TX 16), 1G (RX/TX) 3
+ */
+#define DFLT_PORT_NUM_OF_TASKS(major, type, speed)			\
+	((major >= 6) ?							\
+	((type == FM_PORT_TYPE_OP) ? 6 :				\
+		((speed == FM_PORT_SPEED_10G) ? 16 : 4)) :		\
+	((speed == FM_PORT_SPEED_10G) ? 16 : 3))
+
+/* FMAN V3: 0 for all ports
+ * FMAN V2: RX 10G - 8, RX 1G 2, TX/OP - 0
+ */
+#define DFLT_PORT_EXTRA_NUM_OF_TASKS(major, type, speed)		\
+	((major >= 6) ?	 0 :						\
+	((type == FM_PORT_TYPE_RX) ?					\
+	((speed == FM_PORT_SPEED_10G) ? 8 : 2) : 0))
+
+/* FMAN V3: 10G RX - 8, 1G RX - 2, 10G TX - 12, 1G TX 3, OP - 6
+ * FMAN V2: 10G RX/TX - 8, 1G(TX/RX)/OP - 1
+ */
+#define DFLT_PORT_NUM_OF_OPEN_DMAS(major, type, speed)			\
+	((major >= 6) ?							\
+	((type == FM_PORT_TYPE_RX) ?					\
+		((speed == FM_PORT_SPEED_10G) ? 8 : 2) :		\
+		((type == FM_PORT_TYPE_TX) ?				\
+		((speed == FM_PORT_SPEED_10G) ? 12 : 3) : 4)) :	\
+	((speed == FM_PORT_SPEED_10G) ? 8 : 1))
+
+/* FMAN V3: 0 for all ports
+ * FMAN V2: RX 10G - 8, 1G RX/TX & OP - 1
+ */
+#define DFLT_PORT_EXTRA_NUM_OF_OPEN_DMAS(major, type, speed)		\
+	((major >= 6) ?	 0 :						\
+	((speed == FM_PORT_SPEED_10G) ? 8 : 1))
+
+/* FMAN V3: 10G RX - 96, 10G TX 64, 1G/OP 50
+ * FMAN V2: 10G - 48, 1G RX 45, 1G TX 44, OP = 8
+ */
+#define DFLT_PORT_NUM_OF_FIFO_BUFS(major, type, speed)			\
+	(major >= 6 ?							\
+	(((speed == FM_PORT_SPEED_10G) ?				\
+		((type == FM_PORT_TYPE_RX) ? (96) : (64)) : (50))) :	\
+	((speed == FM_PORT_SPEED_10G) ? 48 :				\
+		((type == FM_PORT_TYPE_OP) ? 8 :			\
+		((type == FM_PORT_TYPE_RX) ? 45 : 44))))		\
+
+#define FM_PORT_MAX_NUM_OF_CONGESTION_GRPS_ALL_INTEGRATIONS 256
+
+#define FM_OH_PORT_ID                               1
+
+/* Memory Mapped Registers */
+
+struct fm_port_rx_bmi_regs_t {
+	uint32_t fmbm_rcfg;	/* Rx Configuration */
+	uint32_t fmbm_rst;	/* Rx Status */
+	uint32_t fmbm_rda;	/* Rx DMA attributes*/
+	uint32_t fmbm_rfp;	/* Rx FIFO Parameters*/
+	uint32_t fmbm_rfed;	/* Rx Frame End Data*/
+	uint32_t fmbm_ricp;	/* Rx Internal Context Parameters*/
+	uint32_t fmbm_rim;	/* Rx Internal Buffer Margins*/
+	uint32_t fmbm_rebm;	/* Rx External Buffer Margins*/
+	uint32_t fmbm_rfne;	/* Rx Frame Next Engine*/
+	uint32_t fmbm_rfca;	/* Rx Frame Command Attributes.*/
+	uint32_t fmbm_rfpne;	/* Rx Frame Parser Next Engine*/
+	uint32_t fmbm_rpso;	/* Rx Parse Start Offset*/
+	uint32_t fmbm_rpp;	/* Rx Policer Profile  */
+	uint32_t fmbm_rccb;	/* Rx Coarse Classification Base */
+	uint32_t fmbm_reth;	/* Rx Excessive Threshold */
+	uint32_t reserved1[0x01];
+	/* (0x03C) */
+	uint32_t fmbm_rprai[FM_PORT_PRS_RESULT_NUM_OF_WORDS];
+	/* Rx Parse Results Array Initialization*/
+	uint32_t fmbm_rfqid;	/* Rx Frame Queue ID*/
+	uint32_t fmbm_refqid;	/* Rx Error Frame Queue ID*/
+	uint32_t fmbm_rfsdm;	/* Rx Frame Status Discard Mask*/
+	uint32_t fmbm_rfsem;	/* Rx Frame Status Error Mask*/
+	uint32_t fmbm_rfene;	/* Rx Frame Enqueue Next Engine */
+	uint32_t reserved2[0x02];
+	/* (0x074-0x078) */
+	/* Rx Frame Continuous Mode Next Engine */
+	uint32_t fmbm_rcmne;
+	uint32_t reserved3[0x20];
+	/* (0x080 0x0FF)  */
+	uint32_t fmbm_ebmpi[FM_PORT_MAX_NUM_OF_EXT_POOLS];
+	/* Buffer Manager pool Information-*/
+	uint32_t fmbm_acnt[FM_PORT_MAX_NUM_OF_EXT_POOLS];
+	/* Allocate Counter-*/
+	uint32_t reserved4[0x08];
+	/* 0x130/0x140 - 0x15F reserved -*/
+	uint32_t
+	fmbm_rcgm[FM_PORT_MAX_NUM_OF_CONGESTION_GRPS_ALL_INTEGRATIONS / 32];
+	/* Congestion Group Map*/
+	uint32_t fmbm_rmpd;	/* BM Pool Depletion  */
+	uint32_t reserved5[0x1F];
+	/* (0x184 0x1FF) */
+	uint32_t fmbm_rstc;	/* Rx Statistics Counters*/
+	uint32_t fmbm_rfrc;	/* Rx Frame Counter*/
+	uint32_t fmbm_rfbc;	/* Rx Bad Frames Counter*/
+	uint32_t fmbm_rlfc;	/* Rx Large Frames Counter*/
+	uint32_t fmbm_rffc;	/* Rx Filter Frames Counter*/
+	uint32_t fmbm_rfcd;	/* Rx Frame Discard Counter*/
+	uint32_t fmbm_rfldec;	/* Rx Frames List DMA Error Counter*/
+	uint32_t fmbm_rodc;/* Rx Out of Buffers Discard Counter-*/
+	uint32_t fmbm_rbdc;	/* Rx Buffers Deallocate Counter-*/
+	uint32_t fmbm_rpec;	/* Rx RX Prepare to enqueue Counter-*/
+	uint32_t reserved6[0x16];
+	/* (0x228 0x27F) */
+	uint32_t fmbm_rpc;	/* Rx Performance Counters*/
+	uint32_t fmbm_rpcp;	/* Rx Performance Count Parameters*/
+	uint32_t fmbm_rccn;	/* Rx Cycle Counter*/
+	uint32_t fmbm_rtuc;	/* Rx Tasks Utilization Counter*/
+	uint32_t fmbm_rrquc;/* Rx Receive Queue Utilization Counter*/
+	uint32_t fmbm_rduc;	/* Rx DMA Utilization Counter*/
+	uint32_t fmbm_rfuc;	/* Rx FIFO Utilization Counter*/
+	uint32_t fmbm_rpac;	/* Rx Pause Activation Counter*/
+	uint32_t reserved7[0x18];
+	/* (0x2A0-0x2FF) */
+	uint32_t fmbm_rdcfg[0x3];
+	/* Rx Debug-*/
+	uint32_t fmbm_rgpr;	/* Rx General Purpose Register. */
+	uint32_t reserved8[0x3a];
+	/* (0x310-0x3FF) */
+} __attribute__((__packed__));
+
+struct fm_port_tx_bmi_regs_t {
+	 uint32_t fmbm_tcfg;	/* Tx Configuration */
+	 uint32_t fmbm_tst;	/* Tx Status */
+	 uint32_t fmbm_tda;	/* Tx DMA attributes */
+	 uint32_t fmbm_tfp;	/* Tx FIFO Parameters */
+	 uint32_t fmbm_tfed;	/* Tx Frame End Data */
+	 uint32_t fmbm_ticp;	/* Tx Internal Context Parameters */
+	 uint32_t fmbm_tfdne;	/* Tx Frame Dequeue Next Engine. */
+	 uint32_t fmbm_tfca;	/* Tx Frame Command attribute. */
+	 uint32_t fmbm_tcfqid;	/* Tx Confirmation Frame Queue ID. */
+	 uint32_t fmbm_tfeqid;	/* Tx Frame Error Queue ID */
+	 uint32_t fmbm_tfene;	/* Tx Frame Enqueue Next Engine */
+	 uint32_t fmbm_trlmts;	/* Tx Rate Limiter Scale */
+	 uint32_t fmbm_trlmt;	/* Tx Rate Limiter */
+	 uint32_t fmbm_tccb;	/* Tx Coarse Classification Base */
+	 uint32_t reserved0[0x0e];
+					/* (0x038-0x070) */
+	 uint32_t fmbm_tfne;	/* Tx Frame Next Engine */
+	 uint32_t fmbm_tpfcm[0x02];
+			/* Tx Priority based Flow Control (PFC) Mapping */
+	/* Tx Frame Continuous Mode Next Engine */
+	 uint32_t fmbm_tcmne;
+	 uint32_t reserved2[0x60];
+					/* (0x080-0x200) */
+	 uint32_t fmbm_tstc;	/* Tx Statistics Counters */
+	 uint32_t fmbm_tfrc;	/* Tx Frame Counter */
+	 uint32_t fmbm_tfdc;	/* Tx Frames Discard Counter */
+	 uint32_t fmbm_tfledc;	/* Tx Frame Length error discard counter */
+	/* Tx Frame unsupported format discard Counter */
+	 uint32_t fmbm_tfufdc;
+	 uint32_t fmbm_tbdc;	/* Tx Buffers Deallocate Counter */
+	 uint32_t reserved3[0x1A];
+					/* (0x218-0x280) */
+	 uint32_t fmbm_tpc;	/* Tx Performance Counters*/
+	 uint32_t fmbm_tpcp;	/* Tx Performance Count Parameters*/
+	 uint32_t fmbm_tccn;	/* Tx Cycle Counter*/
+	 uint32_t fmbm_ttuc;	/* Tx Tasks Utilization Counter*/
+	 /* Tx Transmit Confirm Queue Utilization Counter*/
+	 uint32_t fmbm_ttcquc;
+	 uint32_t fmbm_tduc;	/* Tx DMA Utilization Counter*/
+	 uint32_t fmbm_tfuc;	/* Tx FIFO Utilization Counter*/
+	 uint32_t reserved4[16];/* (0x29C-0x2FF) */
+	 uint32_t fmbm_tdcfg[0x3];
+					/* Tx Debug-*/
+	 uint32_t fmbm_tgpr;	/* O/H General Purpose Register */
+	 uint32_t reserved5[0x3a];
+					/* (0x310-0x3FF) */
+} __attribute__((__packed__));
+
+struct fm_port_oh_bmi_regs_t {
+	uint32_t fmbm_ocfg;	/* O/H Configuration  */
+	uint32_t fmbm_ost;	/* O/H Status */
+	uint32_t fmbm_oda;	/* O/H DMA attributes  */
+	uint32_t fmbm_oicp;	/* O/H Internal Context Parameters*/
+	uint32_t fmbm_ofdne;	/* O/H Frame Dequeue Next Engine  */
+	uint32_t fmbm_ofne;	/* O/H Frame Next Engine  */
+	uint32_t fmbm_ofca;	/* O/H Frame Command Attributes.  */
+	uint32_t fmbm_ofpne;	/* O/H Frame Parser Next Engine  */
+	uint32_t fmbm_opso;	/* O/H Parse Start Offset  */
+	uint32_t fmbm_opp;	/* O/H Policer Profile */
+	uint32_t fmbm_occb;	/* O/H Coarse Classification base */
+	uint32_t fmbm_oim;	/* O/H Internal margins*/
+	uint32_t fmbm_ofp;	/* O/H Fifo Parameters*/
+	uint32_t fmbm_ofed;	/* O/H Frame End Data*/
+	uint32_t reserved0[2];	/* (0x038 - 0x03F) */
+	uint32_t fmbm_oprai[FM_PORT_PRS_RESULT_NUM_OF_WORDS];
+				/* O/H Parse Results Array Initialization */
+	uint32_t fmbm_ofqid;	/* O/H Frame Queue ID  */
+	uint32_t fmbm_oefqid;	/* O/H Error Frame Queue ID  */
+	uint32_t fmbm_ofsdm;	/* O/H Frame Status Discard Mask  */
+	uint32_t fmbm_ofsem;	/* O/H Frame Status Error Mask  */
+	uint32_t fmbm_ofene;	/* O/H Frame Enqueue Next Engine  */
+	uint32_t fmbm_orlmts;	/* O/H Rate Limiter Scale  */
+	uint32_t fmbm_orlmt;	/* O/H Rate Limiter  */
+	uint32_t fmbm_ocmne;	/* O/H Continuous Mode Next Engine*/
+	uint32_t reserved1[0x20];
+					/* (0x080 - 0x0FF) */
+	/* Buffer Manager Observed Pool Information */
+	uint32_t fmbm_oebmpi[2];
+	uint32_t reserved2[0x16];
+					/* (0x108 - 0x15F) */
+	uint32_t fmbm_ocgm;	/* Observed Congestion Group Map */
+	uint32_t reserved3[0x7];
+					/* (0x164 - 0x17F) */
+	uint32_t fmbm_ompd;	/* Observed BMan Pool Depletion */
+	uint32_t reserved4[0x1F];
+					/* (0x184 - 0x1FF) */
+	uint32_t fmbm_ostc;	/* O/H Statistics Counters  */
+	uint32_t fmbm_ofrc;	/* O/H Frame Counter  */
+	uint32_t fmbm_ofdc;	/* O/H Frames Discard Counter  */
+	/* O/H Frames Length Error Discard Counter  */
+	uint32_t fmbm_ofledc;
+	/* O/H Frames Unsupported Format Discard Counter  */
+	uint32_t fmbm_ofufdc;
+	uint32_t fmbm_offc;	/* O/H Filter Frames Counter  */
+	uint32_t fmbm_ofwdc;	/* - Rx Frames WRED Discard Counter*/
+	/* O/H Frames List DMA Error Counter */
+	uint32_t fmbm_ofldec;
+	/* O/H Buffers Deallocate Counter */
+	uint32_t fmbm_obdc;
+	/* O/H Out of Buffers Discard Counter */
+	uint32_t fmbm_oodc;
+	/* O/H Prepare to enqueue Counter */
+	uint32_t fmbm_opec;
+	uint32_t reserved5[0x15];
+					/* ( - 0x27F) */
+	uint32_t fmbm_opc;	/* O/H Performance Counters  */
+	uint32_t fmbm_opcp;	/* O/H Performance Count Parameters*/
+	uint32_t fmbm_occn;	/* O/H Cycle Counter  */
+	uint32_t fmbm_otuc;	/* O/H Tasks Utilization Counter  */
+	uint32_t fmbm_oduc;	/* O/H DMA Utilization Counter */
+	uint32_t fmbm_ofuc;	/* O/H FIFO Utilization Counter */
+	uint32_t reserved6[26];/* (0x298-0x2FF) */
+	uint32_t fmbm_odcfg[0x3];
+					/* O/H Debug (only 1 in P1023) */
+	uint32_t fmbm_ogpr;	/* O/H General Purpose Register. */
+	uint32_t reserved7[0x3a];
+					/* (0x310 0x3FF) */
+} __attribute__((__packed__));
+
+union fm_port_bmi_regs_u {
+	struct fm_port_rx_bmi_regs_t rx_port_bmi_regs;
+	struct fm_port_tx_bmi_regs_t tx_port_bmi_regs;
+	struct fm_port_oh_bmi_regs_t oh_port_bmi_regs;
+} __attribute__((__packed__));
+
+struct fm_port_non_rx_qmi_regs_t {
+	/*   0xn024 - 0x02B */
+	uint32_t reserved1[2];
+	/*   PortID n Dequeue NIA Register */
+	uint32_t fmqm_pndn;
+	/*   PortID n Dequeue Config Register */
+	uint32_t fmqm_pndc;
+	/*   PortID n Dequeue Total Frame Counter */
+	uint32_t fmqm_pndtfc;
+	/*   PortID n Dequeue FQID from Default Counter */
+	uint32_t fmqm_pndfdc;
+	/*   PortID n Dequeue Confirm Counter */
+	uint32_t fmqm_pndcc;
+} __attribute__((__packed__));
+
+struct fm_port_qmi_regs_t {
+	/*   PortID n Configuration Register */
+	uint32_t fmqm_pnc;
+	/*   PortID n Status Register */
+	uint32_t fmqm_pns;
+	/*   PortID n Task Status Register */
+	uint32_t fmqm_pnts;
+	/*   0xn00C - 0xn01B */
+	uint32_t reserved0[4];
+	/*   PortID n Enqueue NIA Register */
+	uint32_t fmqm_pnen;
+	/*   PortID n Enqueue Total Frame Counter */
+	uint32_t fmqm_pnetfc;
+	/*   Registers for Tx Hc&Op ports */
+	struct fm_port_non_rx_qmi_regs_t non_rx_qmi_regs;
+} __attribute__((__packed__));
+
+/* BMI defines */
+#define BMI_PORT_RFNE_FRWD_RPD                  0x40000000
+
+#define BMI_STATUS_RX_MASK_UNUSED	\
+(uint32_t)(~(FM_PORT_FRM_ERR_DMA                    | \
+FM_PORT_FRM_ERR_PHYSICAL               | \
+FM_PORT_FRM_ERR_SIZE                   | \
+FM_PORT_FRM_ERR_CLS_DISCARD            | \
+FM_PORT_FRM_ERR_EXTRACTION             | \
+FM_PORT_FRM_ERR_NO_SCHEME              | \
+FM_PORT_FRM_ERR_COLOR_RED              | \
+FM_PORT_FRM_ERR_COLOR_YELLOW           | \
+FM_PORT_FRM_ERR_PRS_TIMEOUT            | \
+FM_PORT_FRM_ERR_PRS_ILL_INSTRUCT       | \
+FM_PORT_FRM_ERR_BLOCK_LIMIT_EXCEEDED   | \
+FM_PORT_FRM_ERR_PRS_HDR_ERR            | \
+FM_PORT_FRM_ERR_IPRE                   | \
+FM_PORT_FRM_ERR_IPR_NCSP               | \
+FM_PORT_FRM_ERR_KEYSIZE_OVERFLOW))
+
+#define BMI_STATUS_OP_MASK_UNUSED			\
+	(uint32_t)(BMI_STATUS_RX_MASK_UNUSED	&	\
+		~(FM_PORT_FRM_ERR_LENGTH	|	\
+		FM_PORT_FRM_ERR_NON_FM		|	\
+		FM_PORT_FRM_ERR_UNSUPPORTED_FORMAT))
+
+#define RX_ERRS_TO_ENQ	\
+(FM_PORT_FRM_ERR_DMA                    | \
+FM_PORT_FRM_ERR_PHYSICAL               | \
+FM_PORT_FRM_ERR_SIZE                   | \
+FM_PORT_FRM_ERR_EXTRACTION             | \
+FM_PORT_FRM_ERR_NO_SCHEME              | \
+FM_PORT_FRM_ERR_PRS_TIMEOUT            | \
+FM_PORT_FRM_ERR_PRS_ILL_INSTRUCT       | \
+FM_PORT_FRM_ERR_BLOCK_LIMIT_EXCEEDED   | \
+FM_PORT_FRM_ERR_PRS_HDR_ERR            | \
+FM_PORT_FRM_ERR_KEYSIZE_OVERFLOW       | \
+FM_PORT_FRM_ERR_IPRE)
+
+#define OP_ERRS_TO_ENQ	\
+(RX_ERRS_TO_ENQ                         | \
+FM_PORT_FRM_ERR_LENGTH                 | \
+FM_PORT_FRM_ERR_NON_FM                 | \
+FM_PORT_FRM_ERR_UNSUPPORTED_FORMAT)
+
+/* sizes */
+#define FRAME_END_DATA_SIZE                     16
+#define MIN_TX_INT_OFFSET                       16
+#define MAX_FIFO_PIPELINE_DEPTH                 8
+#define MAX_NUM_OF_TASKS                        64
+#define MAX_NUM_OF_EXTRA_TASKS                  8
+#define MAX_NUM_OF_DMAS                         16
+#define MAX_NUM_OF_EXTRA_DMAS                   8
+#define MIN_NUM_OF_OP_DMAS                      2
+
+/* QMI defines */
+#define QMI_DEQ_CFG_SUBPORTAL_MASK              0x1f
+
+struct fm_port_drv_param_t {
+	struct fman_port_cfg dflt_cfg;
+	uint32_t dflt_fqid;
+	uint32_t err_fqid;
+	uintptr_t base_addr;
+	uint8_t deq_sub_portal;
+	bool deq_high_priority;
+	enum fm_port_deq_type deq_type;
+	enum fm_port_deq_prefetch_option deq_prefetch_option;
+	uint16_t deq_byte_cnt;
+	uint8_t cheksum_last_bytes_ignore;
+	uint8_t cut_bytes_from_end;
+	struct fm_buf_pool_depletion_t buf_pool_depletion;
+	bool frm_discard_override;
+	bool en_buf_pool_depletion;
+	uint16_t liodn_offset;
+	uint16_t liodn_base;
+	struct fm_ext_pools_t ext_buf_pools;
+	uint32_t tx_fifo_min_fill_level;
+	uint32_t tx_fifo_low_comf_level;
+	uint32_t rx_fifo_pri_elevation_level;
+	uint32_t rx_fifo_threshold;
+	struct fm_sp_buf_margins_t buf_margins;
+	struct fm_sp_int_context_data_copy_t int_context;
+	uint32_t errors_to_discard;
+	bool forward_reuse_int_context;
+	struct fm_buffer_prefix_content_t buffer_prefix_content;
+	struct fm_backup_bm_pools_t *p_backup_bm_pools;
+	bool dont_release_buf;
+	bool set_num_of_tasks;
+	bool set_num_of_open_dmas;
+	bool set_size_of_fifo;
+
+#ifdef FM_HEAVY_TRAFFIC_HANG_ERRATA_FMAN_A005669
+	bool bcb_workaround;
+#endif /* FM_HEAVY_TRAFFIC_HANG_ERRATA_FMAN_A005669 */
+};
+
+struct fm_port_rx_pools_params_t {
+	uint8_t num_of_pools;
+	uint16_t second_largest_buf_size;
+	uint16_t largest_buf_size;
+};
+
+struct fm_port_intg_t {
+	uint32_t max_port_fifo_size;
+	uint32_t max_num_of_ext_pools;
+	uint32_t fm_max_num_of_sub_portals;
+	uint32_t bm_max_num_of_pools;
+};
+
+/* No PCD Engine indicated */
+#define FM_PCD_NONE                                 0
+struct fm_port_t {
+	struct fman_port port;
+	void *h_fm;
+	struct fm_revision_info_t fm_rev_info;
+	uint8_t port_id;
+	enum fm_port_type port_type;
+	enum fm_port_speed port_speed;
+	int enabled;
+	char name[MODULE_NAME_SIZE];
+	struct fm_port_qmi_regs_t __iomem *p_fm_port_qmi_regs;
+
+	union fm_port_bmi_regs_u __iomem *p_fm_port_bmi_regs;
+	/* The optional engines are devined avobe */
+	struct fm_sp_buffer_offsets_t buffer_offsets;
+
+	/* Spinlock for port use */
+	spinlock_t *spinlock;
+	uint8_t internal_buf_offset;
+	struct fm_ext_pools_t ext_buf_pools;
+
+	uint16_t max_frame_length;
+	struct fm_port_rsrc_t open_dmas;
+	struct fm_port_rsrc_t tasks;
+	struct fm_port_rsrc_t fifo_bufs;
+	struct fm_port_rx_pools_params_t rx_pools_params;
+
+	struct fm_port_drv_param_t *p_fm_port_drv_param;
+	struct fm_port_intg_t *port_intg;
+};
+
+#endif /* __FM_PORT_H */
-- 
1.7.11.7
