From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 09/12] sfc: Add support for SFC9000 family (1)
Date: Mon, 30 Nov 2009 01:15:25 +0000
Message-ID: <1259543729.3709.95.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:46814 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753080AbZK3BP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 20:15:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds support for the SFC9000 family of 10G Ethernet controllers
and LAN-on-motherboard chips, starting with the SFL9021 'Siena' and
SFC9020 'Bethpage'.

The SFC9000 family is based on the SFC4000 'Falcon' architecture, but
with some significant changes:

- Two ports are associated with two independent PCI functions
  (except SFC9010)
- Integrated 10GBASE-T PHY(s) (SFL9021/9022)
- MAC, PHY and board peripherals are managed by firmware
  - Driver does not require board-specific code
  - Firmware supports wake-on-LAN and lights-out management through NC-SI
- IPv6 checksum offload and RSS
- Filtering by MAC address and VLAN (not included in this code)
- PCI SR-IOV (not included in this code)

Credit for this code is largely due to my colleagues at Solarflare:

   Guido Barzini
   Steve Hodgson
   Kieran Mansley
   Matthew Slattery
   Neil Turton

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/mcdi.c     | 1112 ++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/sfc/mcdi.h     |  130 +++++
 drivers/net/sfc/mcdi_mac.c |  152 ++++++
 drivers/net/sfc/mcdi_phy.c |  597 ++++++++++++++++++++++++
 drivers/net/sfc/siena.c    |  604 ++++++++++++++++++++++++
 5 files changed, 2595 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/sfc/mcdi.c
 create mode 100644 drivers/net/sfc/mcdi.h
 create mode 100644 drivers/net/sfc/mcdi_mac.c
 create mode 100644 drivers/net/sfc/mcdi_phy.c
 create mode 100644 drivers/net/sfc/siena.c

diff --git a/drivers/net/sfc/mcdi.c b/drivers/net/sfc/mcdi.c
new file mode 100644
index 0000000..683353b
--- /dev/null
+++ b/drivers/net/sfc/mcdi.c
@@ -0,0 +1,1112 @@
+/****************************************************************************
+ * Driver for Solarflare Solarstorm network controllers and boards
+ * Copyright 2008-2009 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#include <linux/delay.h>
+#include "net_driver.h"
+#include "nic.h"
+#include "io.h"
+#include "regs.h"
+#include "mcdi_pcol.h"
+#include "phy.h"
+
+/**************************************************************************
+ *
+ * Management-Controller-to-Driver Interface
+ *
+ **************************************************************************
+ */
+
+/* Software-defined structure to the shared-memory */
+#define CMD_NOTIFY_PORT0 0
+#define CMD_NOTIFY_PORT1 4
+#define CMD_PDU_PORT0    0x008
+#define CMD_PDU_PORT1    0x108
+#define REBOOT_FLAG_PORT0 0x3f8
+#define REBOOT_FLAG_PORT1 0x3fc
+
+#define MCDI_RPC_TIMEOUT       10 /*seconds */
+
+#define MCDI_PDU(efx)							\
+	(efx_port_num(efx) ? CMD_PDU_PORT1 : CMD_PDU_PORT0)
+#define MCDI_DOORBELL(efx)						\
+	(efx_port_num(efx) ? CMD_NOTIFY_PORT1 : CMD_NOTIFY_PORT0)
+#define MCDI_REBOOT_FLAG(efx)						\
+	(efx_port_num(efx) ? REBOOT_FLAG_PORT1 : REBOOT_FLAG_PORT0)
+
+#define SEQ_MASK							\
+	EFX_MASK32(EFX_WIDTH(MCDI_HEADER_SEQ))
+
+static inline struct efx_mcdi_iface *efx_mcdi(struct efx_nic *efx)
+{
+	struct siena_nic_data *nic_data;
+	EFX_BUG_ON_PARANOID(efx_nic_rev(efx) < EFX_REV_SIENA_A0);
+	nic_data = efx->nic_data;
+	return &nic_data->mcdi;
+}
+
+void efx_mcdi_init(struct efx_nic *efx)
+{
+	struct efx_mcdi_iface *mcdi;
+
+	if (efx_nic_rev(efx) < EFX_REV_SIENA_A0)
+		return;
+
+	mcdi = efx_mcdi(efx);
+	init_waitqueue_head(&mcdi->wq);
+	spin_lock_init(&mcdi->iface_lock);
+	atomic_set(&mcdi->state, MCDI_STATE_QUIESCENT);
+	mcdi->mode = MCDI_MODE_POLL;
+
+	(void) efx_mcdi_poll_reboot(efx);
+}
+
+static void efx_mcdi_copyin(struct efx_nic *efx, unsigned cmd,
+			    const u8 *inbuf, size_t inlen)
+{
+	struct efx_mcdi_iface *mcdi = efx_mcdi(efx);
+	unsigned pdu = FR_CZ_MC_TREG_SMEM + MCDI_PDU(efx);
+	unsigned doorbell = FR_CZ_MC_TREG_SMEM + MCDI_DOORBELL(efx);
+	unsigned int i;
+	efx_dword_t hdr;
+	u32 xflags, seqno;
+
+	BUG_ON(atomic_read(&mcdi->state) == MCDI_STATE_QUIESCENT);
+	BUG_ON(inlen & 3 || inlen >= 0x100);
+
+	seqno = mcdi->seqno & SEQ_MASK;
+	xflags = 0;
+	if (mcdi->mode == MCDI_MODE_EVENTS)
+		xflags |= MCDI_HEADER_XFLAGS_EVREQ;
+
+	EFX_POPULATE_DWORD_6(hdr,
+			     MCDI_HEADER_RESPONSE, 0,
+			     MCDI_HEADER_RESYNC, 1,
+			     MCDI_HEADER_CODE, cmd,
+			     MCDI_HEADER_DATALEN, inlen,
+			     MCDI_HEADER_SEQ, seqno,
+			     MCDI_HEADER_XFLAGS, xflags);
+
+	efx_writed(efx, &hdr, pdu);
+
+	for (i = 0; i < inlen; i += 4)
+		_efx_writed(efx, *((__le32 *)(inbuf + i)), pdu + 4 + i);
+
+	/* Ensure the payload is written out before the header */
+	wmb();
+
+	/* ring the doorbell with a distinctive value */
+	_efx_writed(efx, (__force __le32) 0x45789abc, doorbell);
+}
+
+static void efx_mcdi_copyout(struct efx_nic *efx, u8 *outbuf, size_t outlen)
+{
+	struct efx_mcdi_iface *mcdi = efx_mcdi(efx);
+	unsigned int pdu = FR_CZ_MC_TREG_SMEM + MCDI_PDU(efx);
+	int i;
+
+	BUG_ON(atomic_read(&mcdi->state) == MCDI_STATE_QUIESCENT);
+	BUG_ON(outlen & 3 || outlen >= 0x100);
+
+	for (i = 0; i < outlen; i += 4)
+		*((__le32 *)(outbuf + i)) = _efx_readd(efx, pdu + 4 + i);
+}
+
+static int efx_mcdi_poll(struct efx_nic *efx)
+{
+	struct efx_mcdi_iface *mcdi = efx_mcdi(efx);
+	unsigned int time, finish;
+	unsigned int respseq, respcmd, error;
+	unsigned int pdu = FR_CZ_MC_TREG_SMEM + MCDI_PDU(efx);
+	unsigned int rc, spins;
+	efx_dword_t reg;
+
+	/* Check for a reboot atomically with respect to efx_mcdi_copyout() */
+	rc = efx_mcdi_poll_reboot(efx);
+	if (rc)
+		goto out;
+
+	/* Poll for completion. Poll quickly (once a us) for the 1st jiffy,
+	 * because generally mcdi responses are fast. After that, back off
+	 * and poll once a jiffy (approximately)
+	 */
+	spins = TICK_USEC;
+	finish = get_seconds() + MCDI_RPC_TIMEOUT;
+
+	while (1) {
+		if (spins != 0) {
+			--spins;
+			udelay(1);
+		} else
+			schedule();
+
+		time = get_seconds();
+
+		rmb();
+		efx_readd(efx, &reg, pdu);
+
+		/* All 1's indicates that shared memory is in reset (and is
+		 * not a valid header). Wait for it to come out reset before
+		 * completing the command */
+		if (EFX_DWORD_FIELD(reg, EFX_DWORD_0) != 0xffffffff &&
+		    EFX_DWORD_FIELD(reg, MCDI_HEADER_RESPONSE))
+			break;
+
+		if (time >= finish)
+			return -ETIMEDOUT;
+	}
+
+	mcdi->resplen = EFX_DWORD_FIELD(reg, MCDI_HEADER_DATALEN);
+	respseq = EFX_DWORD_FIELD(reg, MCDI_HEADER_SEQ);
+	respcmd = EFX_DWORD_FIELD(reg, MCDI_HEADER_CODE);
+	error = EFX_DWORD_FIELD(reg, MCDI_HEADER_ERROR);
+
+	if (error && mcdi->resplen == 0) {
+		EFX_ERR(efx, "MC rebooted\n");
+		rc = EIO;
+	} else if ((respseq ^ mcdi->seqno) & SEQ_MASK) {
+		EFX_ERR(efx, "MC response mismatch tx seq 0x%x rx seq 0x%x\n",
+			respseq, mcdi->seqno);
+		rc = EIO;
+	} else if (error) {
+		efx_readd(efx, &reg, pdu + 4);
+		switch (EFX_DWORD_FIELD(reg, EFX_DWORD_0)) {
+#define TRANSLATE_ERROR(name)					\
+		case MC_CMD_ERR_ ## name:			\
+			rc = name;				\
+			break
+			TRANSLATE_ERROR(ENOENT);
+			TRANSLATE_ERROR(EINTR);
+			TRANSLATE_ERROR(EACCES);
+			TRANSLATE_ERROR(EBUSY);
+			TRANSLATE_ERROR(EINVAL);
+			TRANSLATE_ERROR(EDEADLK);
+			TRANSLATE_ERROR(ENOSYS);
+			TRANSLATE_ERROR(ETIME);
+#undef TRANSLATE_ERROR
+		default:
+			rc = EIO;
+			break;
+		}
+	} else
+		rc = 0;
+
+out:
+	mcdi->resprc = rc;
+	if (rc)
+		mcdi->resplen = 0;
+
+	/* Return rc=0 like wait_event_timeout() */
+	return 0;
+}
+
+/* Test and clear MC-rebooted flag for this port/function */
+int efx_mcdi_poll_reboot(struct efx_nic *efx)
+{
+	unsigned int addr = FR_CZ_MC_TREG_SMEM + MCDI_REBOOT_FLAG(efx);
+	efx_dword_t reg;
+	uint32_t value;
+
+	if (efx_nic_rev(efx) < EFX_REV_SIENA_A0)
+		return false;
+
+	efx_readd(efx, &reg, addr);
+	value = EFX_DWORD_FIELD(reg, EFX_DWORD_0);
+
+	if (value == 0)
+		return 0;
+
+	EFX_ZERO_DWORD(reg);
+	efx_writed(efx, &reg, addr);
+
+	if (value == MC_STATUS_DWORD_ASSERT)
+		return -EINTR;
+	else
+		return -EIO;
+}
+
+static void efx_mcdi_acquire(struct efx_mcdi_iface *mcdi)
+{
+	/* Wait until the interface becomes QUIESCENT and we win the race
+	 * to mark it RUNNING. */
+	wait_event(mcdi->wq,
+		   atomic_cmpxchg(&mcdi->state,
+				  MCDI_STATE_QUIESCENT,
+				  MCDI_STATE_RUNNING)
+		   == MCDI_STATE_QUIESCENT);
+}
+
+static int efx_mcdi_await_completion(struct efx_nic *efx)
+{
+	struct efx_mcdi_iface *mcdi = efx_mcdi(efx);
+
+	if (wait_event_timeout(
+		    mcdi->wq,
+		    atomic_read(&mcdi->state) == MCDI_STATE_COMPLETED,
+		    msecs_to_jiffies(MCDI_RPC_TIMEOUT * 1000)) == 0)
+		return -ETIMEDOUT;
+
+	/* Check if efx_mcdi_set_mode() switched us back to polled completions.
+	 * In which case, poll for completions directly. If efx_mcdi_ev_cpl()
+	 * completed the request first, then we'll just end up completing the
+	 * request again, which is safe.
+	 *
+	 * We need an smp_rmb() to synchronise with efx_mcdi_mode_poll(), which
+	 * wait_event_timeout() implicitly provides.
+	 */
+	if (mcdi->mode == MCDI_MODE_POLL)
+		return efx_mcdi_poll(efx);
+
+	return 0;
+}
+
+static bool efx_mcdi_complete(struct efx_mcdi_iface *mcdi)
+{
+	/* If the interface is RUNNING, then move to COMPLETED and wake any
+	 * waiters. If the interface isn't in RUNNING then we've received a
+	 * duplicate completion after we've already transitioned back to
+	 * QUIESCENT. [A subsequent invocation would increment seqno, so would
+	 * have failed the seqno check].
+	 */
+	if (atomic_cmpxchg(&mcdi->state,
+			   MCDI_STATE_RUNNING,
+			   MCDI_STATE_COMPLETED) == MCDI_STATE_RUNNING) {
+		wake_up(&mcdi->wq);
+		return true;
+	}
+
+	return false;
+}
+
+static void efx_mcdi_release(struct efx_mcdi_iface *mcdi)
+{
+	atomic_set(&mcdi->state, MCDI_STATE_QUIESCENT);
+	wake_up(&mcdi->wq);
+}
+
+static void efx_mcdi_ev_cpl(struct efx_nic *efx, unsigned int seqno,
+			    unsigned int datalen, unsigned int errno)
+{
+	struct efx_mcdi_iface *mcdi = efx_mcdi(efx);
+	bool wake = false;
+
+	spin_lock(&mcdi->iface_lock);
+
+	if ((seqno ^ mcdi->seqno) & SEQ_MASK) {
+		if (mcdi->credits)
+			/* The request has been cancelled */
+			--mcdi->credits;
+		else
+			EFX_ERR(efx, "MC response mismatch tx seq 0x%x rx "
+				"seq 0x%x\n", seqno, mcdi->seqno);
+	} else {
+		mcdi->resprc = errno;
+		mcdi->resplen = datalen;
+
+		wake = true;
+	}
+
+	spin_unlock(&mcdi->iface_lock);
+
+	if (wake)
+		efx_mcdi_complete(mcdi);
+}
+
+/* Issue the given command by writing the data into the shared memory PDU,
+ * ring the doorbell and wait for completion. Copyout the result. */
+int efx_mcdi_rpc(struct efx_nic *efx, unsigned cmd,
+		 const u8 *inbuf, size_t inlen, u8 *outbuf, size_t outlen,
+		 size_t *outlen_actual)
+{
+	struct efx_mcdi_iface *mcdi = efx_mcdi(efx);
+	int rc;
+	BUG_ON(efx_nic_rev(efx) < EFX_REV_SIENA_A0);
+
+	efx_mcdi_acquire(mcdi);
+
+	/* Serialise with efx_mcdi_ev_cpl() and efx_mcdi_ev_death() */
+	spin_lock_bh(&mcdi->iface_lock);
+	++mcdi->seqno;
+	spin_unlock_bh(&mcdi->iface_lock);
+
+	efx_mcdi_copyin(efx, cmd, inbuf, inlen);
+
+	if (mcdi->mode == MCDI_MODE_POLL)
+		rc = efx_mcdi_poll(efx);
+	else
+		rc = efx_mcdi_await_completion(efx);
+
+	if (rc != 0) {
+		/* Close the race with efx_mcdi_ev_cpl() executing just too late
+		 * and completing a request we've just cancelled, by ensuring
+		 * that the seqno check therein fails.
+		 */
+		spin_lock_bh(&mcdi->iface_lock);
+		++mcdi->seqno;
+		++mcdi->credits;
+		spin_unlock_bh(&mcdi->iface_lock);
+
+		EFX_ERR(efx, "MC command 0x%x inlen %d mode %d timed out\n",
+			cmd, (int)inlen, mcdi->mode);
+	} else {
+		size_t resplen;
+
+		/* At the very least we need a memory barrier here to ensure
+		 * we pick up changes from efx_mcdi_ev_cpl(). Protect against
+		 * a spurious efx_mcdi_ev_cpl() running concurrently by
+		 * acquiring the iface_lock. */
+		spin_lock_bh(&mcdi->iface_lock);
+		rc = -mcdi->resprc;
+		resplen = mcdi->resplen;
+		spin_unlock_bh(&mcdi->iface_lock);
+
+		if (rc == 0) {
+			efx_mcdi_copyout(efx, outbuf,
+					 min(outlen, mcdi->resplen + 3) & ~0x3);
+			if (outlen_actual != NULL)
+				*outlen_actual = resplen;
+		} else if (cmd == MC_CMD_REBOOT && rc == -EIO)
+			; /* Don't reset if MC_CMD_REBOOT returns EIO */
+		else if (rc == -EIO || rc == -EINTR) {
+			EFX_ERR(efx, "MC fatal error %d\n", -rc);
+			efx_schedule_reset(efx, RESET_TYPE_MC_FAILURE);
+		} else
+			EFX_ERR(efx, "MC command 0x%x inlen %d failed rc=%d\n",
+				cmd, (int)inlen, -rc);
+	}
+
+	efx_mcdi_release(mcdi);
+	return rc;
+}
+
+void efx_mcdi_mode_poll(struct efx_nic *efx)
+{
+	struct efx_mcdi_iface *mcdi;
+
+	if (efx_nic_rev(efx) < EFX_REV_SIENA_A0)
+		return;
+
+	mcdi = efx_mcdi(efx);
+	if (mcdi->mode == MCDI_MODE_POLL)
+		return;
+
+	/* We can switch from event completion to polled completion, because
+	 * mcdi requests are always completed in shared memory. We do this by
+	 * switching the mode to POLL'd then completing the request.
+	 * efx_mcdi_await_completion() will then call efx_mcdi_poll().
+	 *
+	 * We need an smp_wmb() to synchronise with efx_mcdi_await_completion(),
+	 * which efx_mcdi_complete() provides for us.
+	 */
+	mcdi->mode = MCDI_MODE_POLL;
+
+	efx_mcdi_complete(mcdi);
+}
+
+void efx_mcdi_mode_event(struct efx_nic *efx)
+{
+	struct efx_mcdi_iface *mcdi;
+
+	if (efx_nic_rev(efx) < EFX_REV_SIENA_A0)
+		return;
+
+	mcdi = efx_mcdi(efx);
+
+	if (mcdi->mode == MCDI_MODE_EVENTS)
+		return;
+
+	/* We can't switch from polled to event completion in the middle of a
+	 * request, because the completion method is specified in the request.
+	 * So acquire the interface to serialise the requestors. We don't need
+	 * to acquire the iface_lock to change the mode here, but we do need a
+	 * write memory barrier ensure that efx_mcdi_rpc() sees it, which
+	 * efx_mcdi_acquire() provides.
+	 */
+	efx_mcdi_acquire(mcdi);
+	mcdi->mode = MCDI_MODE_EVENTS;
+	efx_mcdi_release(mcdi);
+}
+
+static void efx_mcdi_ev_death(struct efx_nic *efx, int rc)
+{
+	struct efx_mcdi_iface *mcdi = efx_mcdi(efx);
+
+	/* If there is an outstanding MCDI request, it has been terminated
+	 * either by a BADASSERT or REBOOT event. If the mcdi interface is
+	 * in polled mode, then do nothing because the MC reboot handler will
+	 * set the header correctly. However, if the mcdi interface is waiting
+	 * for a CMDDONE event it won't receive it [and since all MCDI events
+	 * are sent to the same queue, we can't be racing with
+	 * efx_mcdi_ev_cpl()]
+	 *
+	 * There's a race here with efx_mcdi_rpc(), because we might receive
+	 * a REBOOT event *before* the request has been copied out. In polled
+	 * mode (during startup) this is irrelevent, because efx_mcdi_complete()
+	 * is ignored. In event mode, this condition is just an edge-case of
+	 * receiving a REBOOT event after posting the MCDI request. Did the mc
+	 * reboot before or after the copyout? The best we can do always is
+	 * just return failure.
+	 */
+	spin_lock(&mcdi->iface_lock);
+	if (efx_mcdi_complete(mcdi)) {
+		if (mcdi->mode == MCDI_MODE_EVENTS) {
+			mcdi->resprc = rc;
+			mcdi->resplen = 0;
+		}
+	} else
+		/* Nobody was waiting for an MCDI request, so trigger a reset */
+		efx_schedule_reset(efx, RESET_TYPE_MC_FAILURE);
+
+	spin_unlock(&mcdi->iface_lock);
+}
+
+static unsigned int efx_mcdi_event_link_speed[] = {
+	[MCDI_EVENT_LINKCHANGE_SPEED_100M] = 100,
+	[MCDI_EVENT_LINKCHANGE_SPEED_1G] = 1000,
+	[MCDI_EVENT_LINKCHANGE_SPEED_10G] = 10000,
+};
+
+
+static void efx_mcdi_process_link_change(struct efx_nic *efx, efx_qword_t *ev)
+{
+	u32 flags, fcntl, speed, lpa;
+
+	speed = EFX_QWORD_FIELD(*ev, MCDI_EVENT_LINKCHANGE_SPEED);
+	EFX_BUG_ON_PARANOID(speed >= ARRAY_SIZE(efx_mcdi_event_link_speed));
+	speed = efx_mcdi_event_link_speed[speed];
+
+	flags = EFX_QWORD_FIELD(*ev, MCDI_EVENT_LINKCHANGE_LINK_FLAGS);
+	fcntl = EFX_QWORD_FIELD(*ev, MCDI_EVENT_LINKCHANGE_FCNTL);
+	lpa = EFX_QWORD_FIELD(*ev, MCDI_EVENT_LINKCHANGE_LP_CAP);
+
+	/* efx->link_state is only modified by efx_mcdi_phy_get_link(),
+	 * which is only run after flushing the event queues. Therefore, it
+	 * is safe to modify the link state outside of the mac_lock here.
+	 */
+	efx_mcdi_phy_decode_link(efx, &efx->link_state, speed, flags, fcntl);
+
+	efx_mcdi_phy_check_fcntl(efx, lpa);
+
+	efx_link_status_changed(efx);
+}
+
+static const char *sensor_names[] = {
+	[MC_CMD_SENSOR_CONTROLLER_TEMP] = "Controller temp. sensor",
+	[MC_CMD_SENSOR_PHY_COMMON_TEMP] = "PHY shared temp. sensor",
+	[MC_CMD_SENSOR_CONTROLLER_COOLING] = "Controller cooling",
+	[MC_CMD_SENSOR_PHY0_TEMP] = "PHY 0 temp. sensor",
+	[MC_CMD_SENSOR_PHY0_COOLING] = "PHY 0 cooling",
+	[MC_CMD_SENSOR_PHY1_TEMP] = "PHY 1 temp. sensor",
+	[MC_CMD_SENSOR_PHY1_COOLING] = "PHY 1 cooling",
+	[MC_CMD_SENSOR_IN_1V0] = "1.0V supply sensor",
+	[MC_CMD_SENSOR_IN_1V2] = "1.2V supply sensor",
+	[MC_CMD_SENSOR_IN_1V8] = "1.8V supply sensor",
+	[MC_CMD_SENSOR_IN_2V5] = "2.5V supply sensor",
+	[MC_CMD_SENSOR_IN_3V3] = "3.3V supply sensor",
+	[MC_CMD_SENSOR_IN_12V0] = "12V supply sensor"
+};
+
+static const char *sensor_status_names[] = {
+	[MC_CMD_SENSOR_STATE_OK] = "OK",
+	[MC_CMD_SENSOR_STATE_WARNING] = "Warning",
+	[MC_CMD_SENSOR_STATE_FATAL] = "Fatal",
+	[MC_CMD_SENSOR_STATE_BROKEN] = "Device failure",
+};
+
+static void efx_mcdi_sensor_event(struct efx_nic *efx, efx_qword_t *ev)
+{
+	unsigned int monitor, state, value;
+	const char *name, *state_txt;
+	monitor = EFX_QWORD_FIELD(*ev, MCDI_EVENT_SENSOREVT_MONITOR);
+	state = EFX_QWORD_FIELD(*ev, MCDI_EVENT_SENSOREVT_STATE);
+	value = EFX_QWORD_FIELD(*ev, MCDI_EVENT_SENSOREVT_VALUE);
+	/* Deal gracefully with the board having more drivers than we
+	 * know about, but do not expect new sensor states. */
+	name = (monitor >= ARRAY_SIZE(sensor_names))
+				    ? "No sensor name available" :
+				    sensor_names[monitor];
+	EFX_BUG_ON_PARANOID(state >= ARRAY_SIZE(sensor_status_names));
+	state_txt = sensor_status_names[state];
+
+	EFX_ERR(efx, "Sensor %d (%s) reports condition '%s' for raw value %d\n",
+		monitor, name, state_txt, value);
+}
+
+/* Called from  falcon_process_eventq for MCDI events */
+void efx_mcdi_process_event(struct efx_channel *channel,
+			    efx_qword_t *event)
+{
+	struct efx_nic *efx = channel->efx;
+	int code = EFX_QWORD_FIELD(*event, MCDI_EVENT_CODE);
+	u32 data = EFX_QWORD_FIELD(*event, MCDI_EVENT_DATA);
+
+	switch (code) {
+	case MCDI_EVENT_CODE_BADSSERT:
+		EFX_ERR(efx, "MC watchdog or assertion failure at 0x%x\n", data);
+		efx_mcdi_ev_death(efx, EINTR);
+		break;
+
+	case MCDI_EVENT_CODE_PMNOTICE:
+		EFX_INFO(efx, "MCDI PM event.\n");
+		break;
+
+	case MCDI_EVENT_CODE_CMDDONE:
+		efx_mcdi_ev_cpl(efx,
+				MCDI_EVENT_FIELD(*event, CMDDONE_SEQ),
+				MCDI_EVENT_FIELD(*event, CMDDONE_DATALEN),
+				MCDI_EVENT_FIELD(*event, CMDDONE_ERRNO));
+		break;
+
+	case MCDI_EVENT_CODE_LINKCHANGE:
+		efx_mcdi_process_link_change(efx, event);
+		break;
+	case MCDI_EVENT_CODE_SENSOREVT:
+		efx_mcdi_sensor_event(efx, event);
+		break;
+	case MCDI_EVENT_CODE_SCHEDERR:
+		EFX_INFO(efx, "MC Scheduler error address=0x%x\n", data);
+		break;
+	case MCDI_EVENT_CODE_REBOOT:
+		EFX_INFO(efx, "MC Reboot\n");
+		efx_mcdi_ev_death(efx, EIO);
+		break;
+	case MCDI_EVENT_CODE_MAC_STATS_DMA:
+		/* MAC stats are gather lazily.  We can ignore this. */
+		break;
+
+	default:
+		EFX_ERR(efx, "Unknown MCDI event 0x%x\n", code);
+	}
+}
+
+/**************************************************************************
+ *
+ * Specific request functions
+ *
+ **************************************************************************
+ */
+
+int efx_mcdi_fwver(struct efx_nic *efx, u64 *version, u32 *build)
+{
+	u8 outbuf[ALIGN(MC_CMD_GET_VERSION_V1_OUT_LEN, 4)];
+	size_t outlength;
+	const __le16 *ver_words;
+	int rc;
+
+	BUILD_BUG_ON(MC_CMD_GET_VERSION_IN_LEN != 0);
+
+	rc = efx_mcdi_rpc(efx, MC_CMD_GET_VERSION, NULL, 0,
+			  outbuf, sizeof(outbuf), &outlength);
+	if (rc)
+		goto fail;
+
+	if (outlength == MC_CMD_GET_VERSION_V0_OUT_LEN) {
+		*version = 0;
+		*build = MCDI_DWORD(outbuf, GET_VERSION_OUT_FIRMWARE);
+		return 0;
+	}
+
+	if (outlength < MC_CMD_GET_VERSION_V1_OUT_LEN) {
+		rc = -EMSGSIZE;
+		goto fail;
+	}
+
+	ver_words = (__le16 *)MCDI_PTR(outbuf, GET_VERSION_OUT_VERSION);
+	*version = (((u64)le16_to_cpu(ver_words[0]) << 48) |
+		    ((u64)le16_to_cpu(ver_words[1]) << 32) |
+		    ((u64)le16_to_cpu(ver_words[2]) << 16) |
+		    le16_to_cpu(ver_words[3]));
+	*build = MCDI_DWORD(outbuf, GET_VERSION_OUT_FIRMWARE);
+
+	return 0;
+
+fail:
+	EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+	return rc;
+}
+
+int efx_mcdi_drv_attach(struct efx_nic *efx, bool driver_operating,
+			bool *was_attached)
+{
+	u8 inbuf[MC_CMD_DRV_ATTACH_IN_LEN];
+	u8 outbuf[MC_CMD_DRV_ATTACH_OUT_LEN];
+	size_t outlen;
+	int rc;
+
+	MCDI_SET_DWORD(inbuf, DRV_ATTACH_IN_NEW_STATE,
+		       driver_operating ? 1 : 0);
+	MCDI_SET_DWORD(inbuf, DRV_ATTACH_IN_UPDATE, 1);
+
+	rc = efx_mcdi_rpc(efx, MC_CMD_DRV_ATTACH, inbuf, sizeof(inbuf),
+			  outbuf, sizeof(outbuf), &outlen);
+	if (rc)
+		goto fail;
+	if (outlen < MC_CMD_DRV_ATTACH_OUT_LEN)
+		goto fail;
+
+	if (was_attached != NULL)
+		*was_attached = MCDI_DWORD(outbuf, DRV_ATTACH_OUT_OLD_STATE);
+	return 0;
+
+fail:
+	EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+	return rc;
+}
+
+int efx_mcdi_get_board_cfg(struct efx_nic *efx, u8 *mac_address,
+			   u16 *fw_subtype_list)
+{
+	uint8_t outbuf[MC_CMD_GET_BOARD_CFG_OUT_LEN];
+	size_t outlen;
+	int port_num = efx_port_num(efx);
+	int offset;
+	int rc;
+
+	BUILD_BUG_ON(MC_CMD_GET_BOARD_CFG_IN_LEN != 0);
+
+	rc = efx_mcdi_rpc(efx, MC_CMD_GET_BOARD_CFG, NULL, 0,
+			  outbuf, sizeof(outbuf), &outlen);
+	if (rc)
+		goto fail;
+
+	if (outlen < MC_CMD_GET_BOARD_CFG_OUT_LEN) {
+		rc = -EMSGSIZE;
+		goto fail;
+	}
+
+	offset = (port_num)
+		? MC_CMD_GET_BOARD_CFG_OUT_MAC_ADDR_BASE_PORT1_OFST
+		: MC_CMD_GET_BOARD_CFG_OUT_MAC_ADDR_BASE_PORT0_OFST;
+	if (mac_address)
+		memcpy(mac_address, outbuf + offset, ETH_ALEN);
+	if (fw_subtype_list)
+		memcpy(fw_subtype_list,
+		       outbuf + MC_CMD_GET_BOARD_CFG_OUT_FW_SUBTYPE_LIST_OFST,
+		       MC_CMD_GET_BOARD_CFG_OUT_FW_SUBTYPE_LIST_LEN);
+
+	return 0;
+
+fail:
+	EFX_ERR(efx, "%s: failed rc=%d len=%d\n", __func__, rc, (int)outlen);
+
+	return rc;
+}
+
+int efx_mcdi_log_ctrl(struct efx_nic *efx, bool evq, bool uart, u32 dest_evq)
+{
+	u8 inbuf[MC_CMD_LOG_CTRL_IN_LEN];
+	u32 dest = 0;
+	int rc;
+
+	if (uart)
+		dest |= MC_CMD_LOG_CTRL_IN_LOG_DEST_UART;
+	if (evq)
+		dest |= MC_CMD_LOG_CTRL_IN_LOG_DEST_EVQ;
+
+	MCDI_SET_DWORD(inbuf, LOG_CTRL_IN_LOG_DEST, dest);
+	MCDI_SET_DWORD(inbuf, LOG_CTRL_IN_LOG_DEST_EVQ, dest_evq);
+
+	BUILD_BUG_ON(MC_CMD_LOG_CTRL_OUT_LEN != 0);
+
+	rc = efx_mcdi_rpc(efx, MC_CMD_LOG_CTRL, inbuf, sizeof(inbuf),
+			  NULL, 0, NULL);
+	if (rc)
+		goto fail;
+
+	return 0;
+
+fail:
+	EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+	return rc;
+}
+
+int efx_mcdi_nvram_types(struct efx_nic *efx, u32 *nvram_types_out)
+{
+	u8 outbuf[MC_CMD_NVRAM_TYPES_OUT_LEN];
+	size_t outlen;
+	int rc;
+
+	BUILD_BUG_ON(MC_CMD_NVRAM_TYPES_IN_LEN != 0);
+
+	rc = efx_mcdi_rpc(efx, MC_CMD_NVRAM_TYPES, NULL, 0,
+			  outbuf, sizeof(outbuf), &outlen);
+	if (rc)
+		goto fail;
+	if (outlen < MC_CMD_NVRAM_TYPES_OUT_LEN)
+		goto fail;
+
+	*nvram_types_out = MCDI_DWORD(outbuf, NVRAM_TYPES_OUT_TYPES);
+	return 0;
+
+fail:
+	EFX_ERR(efx, "%s: failed rc=%d\n",
+		__func__, rc);
+	return rc;
+}
+
+int efx_mcdi_nvram_info(struct efx_nic *efx, unsigned int type,
+			size_t *size_out, size_t *erase_size_out,
+			bool *protected_out)
+{
+	u8 inbuf[MC_CMD_NVRAM_INFO_IN_LEN];
+	u8 outbuf[MC_CMD_NVRAM_INFO_OUT_LEN];
+	size_t outlen;
+	int rc;
+
+	MCDI_SET_DWORD(inbuf, NVRAM_INFO_IN_TYPE, type);
+
+	rc = efx_mcdi_rpc(efx, MC_CMD_NVRAM_INFO, inbuf, sizeof(inbuf),
+			  outbuf, sizeof(outbuf), &outlen);
+	if (rc)
+		goto fail;
+	if (outlen < MC_CMD_NVRAM_INFO_OUT_LEN)
+		goto fail;
+
+	*size_out = MCDI_DWORD(outbuf, NVRAM_INFO_OUT_SIZE);
+	*erase_size_out = MCDI_DWORD(outbuf, NVRAM_INFO_OUT_ERASESIZE);
+	*protected_out = !!(MCDI_DWORD(outbuf, NVRAM_INFO_OUT_FLAGS) &
+				(1 << MC_CMD_NVRAM_PROTECTED_LBN));
+	return 0;
+
+fail:
+	EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+	return rc;
+}
+
+int efx_mcdi_nvram_update_start(struct efx_nic *efx, unsigned int type)
+{
+	u8 inbuf[MC_CMD_NVRAM_UPDATE_START_IN_LEN];
+	int rc;
+
+	MCDI_SET_DWORD(inbuf, NVRAM_UPDATE_START_IN_TYPE, type);
+
+	BUILD_BUG_ON(MC_CMD_NVRAM_UPDATE_START_OUT_LEN != 0);
+
+	rc = efx_mcdi_rpc(efx, MC_CMD_NVRAM_UPDATE_START, inbuf, sizeof(inbuf),
+			  NULL, 0, NULL);
+	if (rc)
+		goto fail;
+
+	return 0;
+
+fail:
+	EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+	return rc;
+}
+
+int efx_mcdi_nvram_read(struct efx_nic *efx, unsigned int type,
+			loff_t offset, u8 *buffer, size_t length)
+{
+	u8 inbuf[MC_CMD_NVRAM_READ_IN_LEN];
+	u8 outbuf[MC_CMD_NVRAM_READ_OUT_LEN(length)];
+	size_t outlen;
+	int rc;
+
+	MCDI_SET_DWORD(inbuf, NVRAM_READ_IN_TYPE, type);
+	MCDI_SET_DWORD(inbuf, NVRAM_READ_IN_OFFSET, offset);
+	MCDI_SET_DWORD(inbuf, NVRAM_READ_IN_LENGTH, length);
+
+	rc = efx_mcdi_rpc(efx, MC_CMD_NVRAM_READ, inbuf, sizeof(inbuf),
+			  outbuf, sizeof(outbuf), &outlen);
+	if (rc)
+		goto fail;
+
+	memcpy(buffer, MCDI_PTR(outbuf, NVRAM_READ_OUT_READ_BUFFER), length);
+	return 0;
+
+fail:
+	EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+	return rc;
+}
+
+int efx_mcdi_nvram_write(struct efx_nic *efx, unsigned int type,
+			   loff_t offset, const u8 *buffer, size_t length)
+{
+	u8 inbuf[MC_CMD_NVRAM_WRITE_IN_LEN(length)];
+	int rc;
+
+	MCDI_SET_DWORD(inbuf, NVRAM_WRITE_IN_TYPE, type);
+	MCDI_SET_DWORD(inbuf, NVRAM_WRITE_IN_OFFSET, offset);
+	MCDI_SET_DWORD(inbuf, NVRAM_WRITE_IN_LENGTH, length);
+	memcpy(MCDI_PTR(inbuf, NVRAM_WRITE_IN_WRITE_BUFFER), buffer, length);
+
+	BUILD_BUG_ON(MC_CMD_NVRAM_WRITE_OUT_LEN != 0);
+
+	rc = efx_mcdi_rpc(efx, MC_CMD_NVRAM_WRITE, inbuf, sizeof(inbuf),
+			  NULL, 0, NULL);
+	if (rc)
+		goto fail;
+
+	return 0;
+
+fail:
+	EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+	return rc;
+}
+
+int efx_mcdi_nvram_erase(struct efx_nic *efx, unsigned int type,
+			 loff_t offset, size_t length)
+{
+	u8 inbuf[MC_CMD_NVRAM_ERASE_IN_LEN];
+	int rc;
+
+	MCDI_SET_DWORD(inbuf, NVRAM_ERASE_IN_TYPE, type);
+	MCDI_SET_DWORD(inbuf, NVRAM_ERASE_IN_OFFSET, offset);
+	MCDI_SET_DWORD(inbuf, NVRAM_ERASE_IN_LENGTH, length);
+
+	BUILD_BUG_ON(MC_CMD_NVRAM_ERASE_OUT_LEN != 0);
+
+	rc = efx_mcdi_rpc(efx, MC_CMD_NVRAM_ERASE, inbuf, sizeof(inbuf),
+			  NULL, 0, NULL);
+	if (rc)
+		goto fail;
+
+	return 0;
+
+fail:
+	EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+	return rc;
+}
+
+int efx_mcdi_nvram_update_finish(struct efx_nic *efx, unsigned int type)
+{
+	u8 inbuf[MC_CMD_NVRAM_UPDATE_FINISH_IN_LEN];
+	int rc;
+
+	MCDI_SET_DWORD(inbuf, NVRAM_UPDATE_FINISH_IN_TYPE, type);
+
+	BUILD_BUG_ON(MC_CMD_NVRAM_UPDATE_FINISH_OUT_LEN != 0);
+
+	rc = efx_mcdi_rpc(efx, MC_CMD_NVRAM_UPDATE_FINISH, inbuf, sizeof(inbuf),
+			  NULL, 0, NULL);
+	if (rc)
+		goto fail;
+
+	return 0;
+
+fail:
+	EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+	return rc;
+}
+
+int efx_mcdi_handle_assertion(struct efx_nic *efx)
+{
+	union {
+		u8 asserts[MC_CMD_GET_ASSERTS_IN_LEN];
+		u8 reboot[MC_CMD_REBOOT_IN_LEN];
+	} inbuf;
+	u8 assertion[MC_CMD_GET_ASSERTS_OUT_LEN];
+	unsigned int flags, index, ofst;
+	const char *reason;
+	size_t outlen;
+	int retry;
+	int rc;
+
+	/* Check if the MC is in the assertion handler, retrying twice. Once
+	 * because a boot-time assertion might cause this command to fail
+	 * with EINTR. And once again because GET_ASSERTS can race with
+	 * MC_CMD_REBOOT running on the other port. */
+	retry = 2;
+	do {
+		MCDI_SET_DWORD(inbuf.asserts, GET_ASSERTS_IN_CLEAR, 0);
+		rc = efx_mcdi_rpc(efx, MC_CMD_GET_ASSERTS,
+				  inbuf.asserts, MC_CMD_GET_ASSERTS_IN_LEN,
+				  assertion, sizeof(assertion), &outlen);
+	} while ((rc == -EINTR || rc == -EIO) && retry-- > 0);
+
+	if (rc)
+		return rc;
+	if (outlen < MC_CMD_GET_ASSERTS_OUT_LEN)
+		return -EINVAL;
+
+	flags = MCDI_DWORD(assertion, GET_ASSERTS_OUT_GLOBAL_FLAGS);
+	if (flags == MC_CMD_GET_ASSERTS_FLAGS_NO_FAILS)
+		return 0;
+
+	/* Reset the hardware atomically such that only one port with succeed.
+	 * This command will succeed if a reboot is no longer required (because
+	 * the other port did it first), but fail with EIO if it succeeds.
+	 */
+	BUILD_BUG_ON(MC_CMD_REBOOT_OUT_LEN != 0);
+	MCDI_SET_DWORD(inbuf.reboot, REBOOT_IN_FLAGS,
+		       MC_CMD_REBOOT_FLAGS_AFTER_ASSERTION);
+	efx_mcdi_rpc(efx, MC_CMD_REBOOT, inbuf.reboot, MC_CMD_REBOOT_IN_LEN,
+		     NULL, 0, NULL);
+
+	/* Print out the assertion */
+	reason = (flags == MC_CMD_GET_ASSERTS_FLAGS_SYS_FAIL)
+		? "system-level assertion"
+		: (flags == MC_CMD_GET_ASSERTS_FLAGS_THR_FAIL)
+		? "thread-level assertion"
+		: (flags == MC_CMD_GET_ASSERTS_FLAGS_WDOG_FIRED)
+		? "watchdog reset"
+		: "unknown assertion";
+	EFX_ERR(efx, "MCPU %s at PC = 0x%.8x in thread 0x%.8x\n", reason,
+		MCDI_DWORD(assertion, GET_ASSERTS_OUT_SAVED_PC_OFFS),
+		MCDI_DWORD(assertion, GET_ASSERTS_OUT_THREAD_OFFS));
+
+	/* Print out the registers */
+	ofst = MC_CMD_GET_ASSERTS_OUT_GP_REGS_OFFS_OFST;
+	for (index = 1; index < 32; index++) {
+		EFX_ERR(efx, "R%.2d (?): 0x%.8x\n", index,
+			MCDI_DWORD2(assertion, ofst));
+		ofst += sizeof(efx_dword_t);
+	}
+
+	return 0;
+}
+
+void efx_mcdi_set_id_led(struct efx_nic *efx, enum efx_led_mode mode)
+{
+	u8 inbuf[MC_CMD_SET_ID_LED_IN_LEN];
+	int rc;
+
+	BUILD_BUG_ON(EFX_LED_OFF != MC_CMD_LED_OFF);
+	BUILD_BUG_ON(EFX_LED_ON != MC_CMD_LED_ON);
+	BUILD_BUG_ON(EFX_LED_DEFAULT != MC_CMD_LED_DEFAULT);
+
+	BUILD_BUG_ON(MC_CMD_SET_ID_LED_OUT_LEN != 0);
+
+	MCDI_SET_DWORD(inbuf, SET_ID_LED_IN_STATE, mode);
+
+	rc = efx_mcdi_rpc(efx, MC_CMD_SET_ID_LED, inbuf, sizeof(inbuf),
+			  NULL, 0, NULL);
+	if (rc)
+		EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+}
+
+int efx_mcdi_reset_port(struct efx_nic *efx)
+{
+	int rc = efx_mcdi_rpc(efx, MC_CMD_PORT_RESET, NULL, 0, NULL, 0, NULL);
+	if (rc)
+		EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+	return rc;
+}
+
+int efx_mcdi_reset_mc(struct efx_nic *efx)
+{
+	u8 inbuf[MC_CMD_REBOOT_IN_LEN];
+	int rc;
+
+	BUILD_BUG_ON(MC_CMD_REBOOT_OUT_LEN != 0);
+	MCDI_SET_DWORD(inbuf, REBOOT_IN_FLAGS, 0);
+	rc = efx_mcdi_rpc(efx, MC_CMD_REBOOT, inbuf, sizeof(inbuf),
+			  NULL, 0, NULL);
+	/* White is black, and up is down */
+	if (rc == -EIO)
+		return 0;
+	if (rc == 0)
+		rc = -EIO;
+	EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+	return rc;
+}
+
+int efx_mcdi_wol_filter_set(struct efx_nic *efx, u32 type,
+			    const u8 *mac, int *id_out)
+{
+	u8 inbuf[MC_CMD_WOL_FILTER_SET_IN_LEN];
+	u8 outbuf[MC_CMD_WOL_FILTER_SET_OUT_LEN];
+	size_t outlen;
+	int rc;
+
+	MCDI_SET_DWORD(inbuf, WOL_FILTER_SET_IN_WOL_TYPE, type);
+	MCDI_SET_DWORD(inbuf, WOL_FILTER_SET_IN_FILTER_MODE,
+		       MC_CMD_FILTER_MODE_SIMPLE);
+	memcpy(MCDI_PTR(inbuf, WOL_FILTER_SET_IN_MAGIC_MAC), mac, ETH_ALEN);
+
+	rc = efx_mcdi_rpc(efx, MC_CMD_WOL_FILTER_SET, inbuf, sizeof(inbuf),
+			  outbuf, sizeof(outbuf), &outlen);
+	if (rc)
+		goto fail;
+
+	if (outlen < MC_CMD_WOL_FILTER_SET_OUT_LEN) {
+		rc = -EMSGSIZE;
+		goto fail;
+	}
+
+	*id_out = (int)MCDI_DWORD(outbuf, WOL_FILTER_SET_OUT_FILTER_ID);
+
+	return 0;
+
+fail:
+	*id_out = -1;
+	EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+	return rc;
+
+}
+
+
+int
+efx_mcdi_wol_filter_set_magic(struct efx_nic *efx,  const u8 *mac, int *id_out)
+{
+	return efx_mcdi_wol_filter_set(efx, MC_CMD_WOL_TYPE_MAGIC, mac, id_out);
+}
+
+
+int efx_mcdi_wol_filter_get_magic(struct efx_nic *efx, int *id_out)
+{
+	u8 outbuf[MC_CMD_WOL_FILTER_GET_OUT_LEN];
+	size_t outlen;
+	int rc;
+
+	rc = efx_mcdi_rpc(efx, MC_CMD_WOL_FILTER_GET, NULL, 0,
+			  outbuf, sizeof(outbuf), &outlen);
+	if (rc)
+		goto fail;
+
+	if (outlen < MC_CMD_WOL_FILTER_GET_OUT_LEN) {
+		rc = -EMSGSIZE;
+		goto fail;
+	}
+
+	*id_out = (int)MCDI_DWORD(outbuf, WOL_FILTER_GET_OUT_FILTER_ID);
+
+	return 0;
+
+fail:
+	*id_out = -1;
+	EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+	return rc;
+}
+
+
+int efx_mcdi_wol_filter_remove(struct efx_nic *efx, int id)
+{
+	u8 inbuf[MC_CMD_WOL_FILTER_REMOVE_IN_LEN];
+	int rc;
+
+	MCDI_SET_DWORD(inbuf, WOL_FILTER_REMOVE_IN_FILTER_ID, (u32)id);
+
+	rc = efx_mcdi_rpc(efx, MC_CMD_WOL_FILTER_REMOVE, inbuf, sizeof(inbuf),
+			  NULL, 0, NULL);
+	if (rc)
+		goto fail;
+
+	return 0;
+
+fail:
+	EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+	return rc;
+}
+
+
+int efx_mcdi_wol_filter_reset(struct efx_nic *efx)
+{
+	int rc;
+
+	rc = efx_mcdi_rpc(efx, MC_CMD_WOL_FILTER_RESET, NULL, 0, NULL, 0, NULL);
+	if (rc)
+		goto fail;
+
+	return 0;
+
+fail:
+	EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+	return rc;
+}
+
diff --git a/drivers/net/sfc/mcdi.h b/drivers/net/sfc/mcdi.h
new file mode 100644
index 0000000..de91672
--- /dev/null
+++ b/drivers/net/sfc/mcdi.h
@@ -0,0 +1,130 @@
+/****************************************************************************
+ * Driver for Solarflare Solarstorm network controllers and boards
+ * Copyright 2008-2009 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#ifndef EFX_MCDI_H
+#define EFX_MCDI_H
+
+/**
+ * enum efx_mcdi_state
+ * @MCDI_STATE_QUIESCENT: No pending MCDI requests. If the caller holds the
+ *	mcdi_lock then they are able to move to MCDI_STATE_RUNNING
+ * @MCDI_STATE_RUNNING: There is an MCDI request pending. Only the thread that
+ *	moved into this state is allowed to move out of it.
+ * @MCDI_STATE_COMPLETED: An MCDI request has completed, but the owning thread
+ *	has not yet consumed the result. For all other threads, equivalent to
+ *	MCDI_STATE_RUNNING.
+ */
+enum efx_mcdi_state {
+	MCDI_STATE_QUIESCENT,
+	MCDI_STATE_RUNNING,
+	MCDI_STATE_COMPLETED,
+};
+
+enum efx_mcdi_mode {
+	MCDI_MODE_POLL,
+	MCDI_MODE_EVENTS,
+};
+
+/**
+ * struct efx_mcdi_iface
+ * @state: Interface state. Waited for by mcdi_wq.
+ * @wq: Wait queue for threads waiting for state != STATE_RUNNING
+ * @iface_lock: Protects @credits, @seqno, @resprc, @resplen
+ * @mode: Poll for mcdi completion, or wait for an mcdi_event.
+ *	Serialised by @lock
+ * @seqno: The next sequence number to use for mcdi requests.
+ *	Serialised by @lock
+ * @credits: Number of spurious MCDI completion events allowed before we
+ *	trigger a fatal error. Protected by @lock
+ * @resprc: Returned MCDI completion
+ * @resplen: Returned payload length
+ */
+struct efx_mcdi_iface {
+	atomic_t state;
+	wait_queue_head_t wq;
+	spinlock_t iface_lock;
+	enum efx_mcdi_mode mode;
+	unsigned int credits;
+	unsigned int seqno;
+	unsigned int resprc;
+	size_t resplen;
+};
+
+extern void efx_mcdi_init(struct efx_nic *efx);
+
+extern int efx_mcdi_rpc(struct efx_nic *efx, unsigned cmd, const u8 *inbuf,
+			size_t inlen, u8 *outbuf, size_t outlen,
+			size_t *outlen_actual);
+
+extern int efx_mcdi_poll_reboot(struct efx_nic *efx);
+extern void efx_mcdi_mode_poll(struct efx_nic *efx);
+extern void efx_mcdi_mode_event(struct efx_nic *efx);
+
+extern void efx_mcdi_process_event(struct efx_channel *channel,
+				   efx_qword_t *event);
+
+#define MCDI_PTR2(_buf, _ofst)						\
+	(((u8 *)_buf) + _ofst)
+#define MCDI_SET_DWORD2(_buf, _ofst, _value)				\
+	EFX_POPULATE_DWORD_1(*((efx_dword_t *)MCDI_PTR2(_buf, _ofst)),	\
+			     EFX_DWORD_0, _value)
+#define MCDI_DWORD2(_buf, _ofst)					\
+	EFX_DWORD_FIELD(*((efx_dword_t *)MCDI_PTR2(_buf, _ofst)),	\
+			EFX_DWORD_0)
+#define MCDI_QWORD2(_buf, _ofst)					\
+	EFX_QWORD_FIELD64(*((efx_qword_t *)MCDI_PTR2(_buf, _ofst)),	\
+			  EFX_QWORD_0)
+
+#define MCDI_PTR(_buf, _ofst)						\
+	MCDI_PTR2(_buf, MC_CMD_ ## _ofst ## _OFST)
+#define MCDI_SET_DWORD(_buf, _ofst, _value)				\
+	MCDI_SET_DWORD2(_buf, MC_CMD_ ## _ofst ## _OFST, _value)
+#define MCDI_DWORD(_buf, _ofst)						\
+	MCDI_DWORD2(_buf, MC_CMD_ ## _ofst ## _OFST)
+#define MCDI_QWORD(_buf, _ofst)						\
+	MCDI_QWORD2(_buf, MC_CMD_ ## _ofst ## _OFST)
+
+#define MCDI_EVENT_FIELD(_ev, _field)			\
+	EFX_QWORD_FIELD(_ev, MCDI_EVENT_ ## _field)
+
+extern int efx_mcdi_fwver(struct efx_nic *efx, u64 *version, u32 *build);
+extern int efx_mcdi_drv_attach(struct efx_nic *efx, bool driver_operating,
+			       bool *was_attached_out);
+extern int efx_mcdi_get_board_cfg(struct efx_nic *efx, u8 *mac_address,
+				  u16 *fw_subtype_list);
+extern int efx_mcdi_log_ctrl(struct efx_nic *efx, bool evq, bool uart,
+			     u32 dest_evq);
+extern int efx_mcdi_nvram_types(struct efx_nic *efx, u32 *nvram_types_out);
+extern int efx_mcdi_nvram_info(struct efx_nic *efx, unsigned int type,
+			       size_t *size_out, size_t *erase_size_out,
+			       bool *protected_out);
+extern int efx_mcdi_nvram_update_start(struct efx_nic *efx,
+				       unsigned int type);
+extern int efx_mcdi_nvram_read(struct efx_nic *efx, unsigned int type,
+			       loff_t offset, u8 *buffer, size_t length);
+extern int efx_mcdi_nvram_write(struct efx_nic *efx, unsigned int type,
+				loff_t offset, const u8 *buffer,
+				size_t length);
+extern int efx_mcdi_nvram_erase(struct efx_nic *efx, unsigned int type,
+				loff_t offset, size_t length);
+extern int efx_mcdi_nvram_update_finish(struct efx_nic *efx,
+					unsigned int type);
+extern int efx_mcdi_handle_assertion(struct efx_nic *efx);
+extern void efx_mcdi_set_id_led(struct efx_nic *efx, enum efx_led_mode mode);
+extern int efx_mcdi_reset_port(struct efx_nic *efx);
+extern int efx_mcdi_reset_mc(struct efx_nic *efx);
+extern int efx_mcdi_wol_filter_set(struct efx_nic *efx, u32 type,
+				   const u8 *mac, int *id_out);
+extern int efx_mcdi_wol_filter_set_magic(struct efx_nic *efx,
+					 const u8 *mac, int *id_out);
+extern int efx_mcdi_wol_filter_get_magic(struct efx_nic *efx, int *id_out);
+extern int efx_mcdi_wol_filter_remove(struct efx_nic *efx, int id);
+extern int efx_mcdi_wol_filter_reset(struct efx_nic *efx);
+
+#endif /* EFX_MCDI_H */
diff --git a/drivers/net/sfc/mcdi_mac.c b/drivers/net/sfc/mcdi_mac.c
new file mode 100644
index 0000000..06d24a1
--- /dev/null
+++ b/drivers/net/sfc/mcdi_mac.c
@@ -0,0 +1,152 @@
+/****************************************************************************
+ * Driver for Solarflare Solarstorm network controllers and boards
+ * Copyright 2009 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#include "net_driver.h"
+#include "efx.h"
+#include "mac.h"
+#include "mcdi.h"
+#include "mcdi_pcol.h"
+
+static int efx_mcdi_set_mac(struct efx_nic *efx)
+{
+	u32 reject, fcntl;
+	u8 cmdbytes[MC_CMD_SET_MAC_IN_LEN];
+
+	memcpy(cmdbytes + MC_CMD_SET_MAC_IN_ADDR_OFST,
+	       efx->net_dev->dev_addr, ETH_ALEN);
+
+	MCDI_SET_DWORD(cmdbytes, SET_MAC_IN_MTU,
+			EFX_MAX_FRAME_LEN(efx->net_dev->mtu));
+	MCDI_SET_DWORD(cmdbytes, SET_MAC_IN_DRAIN, 0);
+
+	/* The MCDI command provides for controlling accept/reject
+	 * of broadcast packets too, but the driver doesn't currently
+	 * expose this. */
+	reject = (efx->promiscuous) ? 0 :
+		(1 << MC_CMD_SET_MAC_IN_REJECT_UNCST_LBN);
+	MCDI_SET_DWORD(cmdbytes, SET_MAC_IN_REJECT, reject);
+
+	switch (efx->wanted_fc) {
+	case EFX_FC_RX | EFX_FC_TX:
+		fcntl = MC_CMD_FCNTL_BIDIR;
+		break;
+	case EFX_FC_RX:
+		fcntl = MC_CMD_FCNTL_RESPOND;
+		break;
+	default:
+		fcntl = MC_CMD_FCNTL_OFF;
+		break;
+	}
+	if (efx->wanted_fc & EFX_FC_AUTO)
+		fcntl = MC_CMD_FCNTL_AUTO;
+
+	MCDI_SET_DWORD(cmdbytes, SET_MAC_IN_FCNTL, fcntl);
+
+	return efx_mcdi_rpc(efx, MC_CMD_SET_MAC, cmdbytes, sizeof(cmdbytes),
+			    NULL, 0, NULL);
+}
+
+static int efx_mcdi_get_mac_faults(struct efx_nic *efx, u32 *faults)
+{
+	u8 outbuf[MC_CMD_GET_LINK_OUT_LEN];
+	size_t outlength;
+	int rc;
+
+	BUILD_BUG_ON(MC_CMD_GET_LINK_IN_LEN != 0);
+
+	rc = efx_mcdi_rpc(efx, MC_CMD_GET_LINK, NULL, 0,
+			  outbuf, sizeof(outbuf), &outlength);
+	if (rc)
+		goto fail;
+
+	*faults = MCDI_DWORD(outbuf, GET_LINK_OUT_MAC_FAULT);
+	return 0;
+
+fail:
+	EFX_ERR(efx, "%s: failed rc=%d\n",
+		__func__, rc);
+	return rc;
+}
+
+int efx_mcdi_mac_stats(struct efx_nic *efx, dma_addr_t dma_addr,
+		       u32 dma_len, int enable, int clear)
+{
+	u8 inbuf[MC_CMD_MAC_STATS_IN_LEN];
+	int rc;
+	efx_dword_t *cmd_ptr;
+	int period = 1000;
+	u32 addr_hi;
+	u32 addr_lo;
+
+	BUILD_BUG_ON(MC_CMD_MAC_STATS_OUT_LEN != 0);
+
+	addr_lo = ((u64)dma_addr) >> 0;
+	addr_hi = ((u64)dma_addr) >> 32;
+
+	MCDI_SET_DWORD(inbuf, MAC_STATS_IN_DMA_ADDR_LO, addr_lo);
+	MCDI_SET_DWORD(inbuf, MAC_STATS_IN_DMA_ADDR_HI, addr_hi);
+	cmd_ptr = (efx_dword_t *)MCDI_PTR(inbuf, MAC_STATS_IN_CMD);
+	if (enable)
+		EFX_POPULATE_DWORD_6(*cmd_ptr,
+				     MC_CMD_MAC_STATS_CMD_DMA, 1,
+				     MC_CMD_MAC_STATS_CMD_CLEAR, clear,
+				     MC_CMD_MAC_STATS_CMD_PERIODIC_CHANGE, 1,
+				     MC_CMD_MAC_STATS_CMD_PERIODIC_ENABLE, 1,
+				     MC_CMD_MAC_STATS_CMD_PERIODIC_CLEAR, 0,
+				     MC_CMD_MAC_STATS_CMD_PERIOD_MS, period);
+	else
+		EFX_POPULATE_DWORD_5(*cmd_ptr,
+				     MC_CMD_MAC_STATS_CMD_DMA, 0,
+				     MC_CMD_MAC_STATS_CMD_CLEAR, clear,
+				     MC_CMD_MAC_STATS_CMD_PERIODIC_CHANGE, 1,
+				     MC_CMD_MAC_STATS_CMD_PERIODIC_ENABLE, 0,
+				     MC_CMD_MAC_STATS_CMD_PERIODIC_CLEAR, 0);
+	MCDI_SET_DWORD(inbuf, MAC_STATS_IN_DMA_LEN, dma_len);
+
+	rc = efx_mcdi_rpc(efx, MC_CMD_MAC_STATS, inbuf, sizeof(inbuf),
+			  NULL, 0, NULL);
+	if (rc)
+		goto fail;
+
+	return 0;
+
+fail:
+	EFX_ERR(efx, "%s: %s failed rc=%d\n",
+		__func__, enable ? "enable" : "disable", rc);
+	return rc;
+}
+
+static int efx_mcdi_mac_reconfigure(struct efx_nic *efx)
+{
+	int rc;
+
+	rc = efx_mcdi_set_mac(efx);
+	if (rc != 0)
+		return rc;
+
+	/* Restore the multicast hash registers. */
+	efx->type->push_multicast_hash(efx);
+
+	return 0;
+}
+
+
+static bool efx_mcdi_mac_check_fault(struct efx_nic *efx)
+{
+	u32 faults;
+	int rc = efx_mcdi_get_mac_faults(efx, &faults);
+	return (rc != 0) || (faults != 0);
+}
+
+
+struct efx_mac_operations efx_mcdi_mac_operations = {
+	.reconfigure	= efx_mcdi_mac_reconfigure,
+	.update_stats	= efx_port_dummy_op_void,
+	.check_fault 	= efx_mcdi_mac_check_fault,
+};
diff --git a/drivers/net/sfc/mcdi_phy.c b/drivers/net/sfc/mcdi_phy.c
new file mode 100644
index 0000000..0e1bcc5
--- /dev/null
+++ b/drivers/net/sfc/mcdi_phy.c
@@ -0,0 +1,597 @@
+/****************************************************************************
+ * Driver for Solarflare Solarstorm network controllers and boards
+ * Copyright 2009 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+/*
+ * Driver for PHY related operations via MCDI.
+ */
+
+#include "efx.h"
+#include "phy.h"
+#include "mcdi.h"
+#include "mcdi_pcol.h"
+#include "mdio_10g.h"
+
+struct efx_mcdi_phy_cfg {
+	u32 flags;
+	u32 type;
+	u32 supported_cap;
+	u32 channel;
+	u32 port;
+	u32 stats_mask;
+	u8 name[20];
+	u32 media;
+	u32 mmd_mask;
+	u8 revision[20];
+	u32 forced_cap;
+};
+
+static int
+efx_mcdi_get_phy_cfg(struct efx_nic *efx, struct efx_mcdi_phy_cfg *cfg)
+{
+	u8 outbuf[MC_CMD_GET_PHY_CFG_OUT_LEN];
+	size_t outlen;
+	int rc;
+
+	BUILD_BUG_ON(MC_CMD_GET_PHY_CFG_IN_LEN != 0);
+	BUILD_BUG_ON(MC_CMD_GET_PHY_CFG_OUT_NAME_LEN != sizeof(cfg->name));
+
+	rc = efx_mcdi_rpc(efx, MC_CMD_GET_PHY_CFG, NULL, 0,
+			  outbuf, sizeof(outbuf), &outlen);
+	if (rc)
+		goto fail;
+
+	if (outlen < MC_CMD_GET_PHY_CFG_OUT_LEN) {
+		rc = -EMSGSIZE;
+		goto fail;
+	}
+
+	cfg->flags = MCDI_DWORD(outbuf, GET_PHY_CFG_OUT_FLAGS);
+	cfg->type = MCDI_DWORD(outbuf, GET_PHY_CFG_OUT_TYPE);
+	cfg->supported_cap =
+		MCDI_DWORD(outbuf, GET_PHY_CFG_OUT_SUPPORTED_CAP);
+	cfg->channel = MCDI_DWORD(outbuf, GET_PHY_CFG_OUT_CHANNEL);
+	cfg->port = MCDI_DWORD(outbuf, GET_PHY_CFG_OUT_PRT);
+	cfg->stats_mask = MCDI_DWORD(outbuf, GET_PHY_CFG_OUT_STATS_MASK);
+	memcpy(cfg->name, MCDI_PTR(outbuf, GET_PHY_CFG_OUT_NAME),
+	       sizeof(cfg->name));
+	cfg->media = MCDI_DWORD(outbuf, GET_PHY_CFG_OUT_MEDIA_TYPE);
+	cfg->mmd_mask = MCDI_DWORD(outbuf, GET_PHY_CFG_OUT_MMD_MASK);
+	memcpy(cfg->revision, MCDI_PTR(outbuf, GET_PHY_CFG_OUT_REVISION),
+	       sizeof(cfg->revision));
+
+	return 0;
+
+fail:
+	EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+	return rc;
+}
+
+static int efx_mcdi_set_link(struct efx_nic *efx, u32 capabilities,
+			     u32 flags, u32 loopback_mode,
+			     u32 loopback_speed)
+{
+	u8 inbuf[MC_CMD_SET_LINK_IN_LEN];
+	int rc;
+
+	BUILD_BUG_ON(MC_CMD_SET_LINK_OUT_LEN != 0);
+
+	MCDI_SET_DWORD(inbuf, SET_LINK_IN_CAP, capabilities);
+	MCDI_SET_DWORD(inbuf, SET_LINK_IN_FLAGS, flags);
+	MCDI_SET_DWORD(inbuf, SET_LINK_IN_LOOPBACK_MODE, loopback_mode);
+	MCDI_SET_DWORD(inbuf, SET_LINK_IN_LOOPBACK_SPEED, loopback_speed);
+
+	rc = efx_mcdi_rpc(efx, MC_CMD_SET_LINK, inbuf, sizeof(inbuf),
+			  NULL, 0, NULL);
+	if (rc)
+		goto fail;
+
+	return 0;
+
+fail:
+	EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+	return rc;
+}
+
+static int efx_mcdi_loopback_modes(struct efx_nic *efx, u64 *loopback_modes)
+{
+	u8 outbuf[MC_CMD_GET_LOOPBACK_MODES_OUT_LEN];
+	size_t outlen;
+	int rc;
+
+	rc = efx_mcdi_rpc(efx, MC_CMD_GET_LOOPBACK_MODES, NULL, 0,
+			  outbuf, sizeof(outbuf), &outlen);
+	if (rc)
+		goto fail;
+
+	if (outlen < MC_CMD_GET_LOOPBACK_MODES_OUT_LEN) {
+		rc = -EMSGSIZE;
+		goto fail;
+	}
+
+	*loopback_modes = MCDI_QWORD(outbuf, GET_LOOPBACK_MODES_SUGGESTED);
+
+	return 0;
+
+fail:
+	EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+	return rc;
+}
+
+int efx_mcdi_mdio_read(struct efx_nic *efx, unsigned int bus,
+			 unsigned int prtad, unsigned int devad, u16 addr,
+			 u16 *value_out, u32 *status_out)
+{
+	u8 inbuf[MC_CMD_MDIO_READ_IN_LEN];
+	u8 outbuf[MC_CMD_MDIO_READ_OUT_LEN];
+	size_t outlen;
+	int rc;
+
+	MCDI_SET_DWORD(inbuf, MDIO_READ_IN_BUS, bus);
+	MCDI_SET_DWORD(inbuf, MDIO_READ_IN_PRTAD, prtad);
+	MCDI_SET_DWORD(inbuf, MDIO_READ_IN_DEVAD, devad);
+	MCDI_SET_DWORD(inbuf, MDIO_READ_IN_ADDR, addr);
+
+	rc = efx_mcdi_rpc(efx, MC_CMD_MDIO_READ, inbuf, sizeof(inbuf),
+			  outbuf, sizeof(outbuf), &outlen);
+	if (rc)
+		goto fail;
+
+	*value_out = (u16)MCDI_DWORD(outbuf, MDIO_READ_OUT_VALUE);
+	*status_out = MCDI_DWORD(outbuf, MDIO_READ_OUT_STATUS);
+	return 0;
+
+fail:
+	EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+	return rc;
+}
+
+int efx_mcdi_mdio_write(struct efx_nic *efx, unsigned int bus,
+			  unsigned int prtad, unsigned int devad, u16 addr,
+			  u16 value, u32 *status_out)
+{
+	u8 inbuf[MC_CMD_MDIO_WRITE_IN_LEN];
+	u8 outbuf[MC_CMD_MDIO_WRITE_OUT_LEN];
+	size_t outlen;
+	int rc;
+
+	MCDI_SET_DWORD(inbuf, MDIO_WRITE_IN_BUS, bus);
+	MCDI_SET_DWORD(inbuf, MDIO_WRITE_IN_PRTAD, prtad);
+	MCDI_SET_DWORD(inbuf, MDIO_WRITE_IN_DEVAD, devad);
+	MCDI_SET_DWORD(inbuf, MDIO_WRITE_IN_ADDR, addr);
+	MCDI_SET_DWORD(inbuf, MDIO_WRITE_IN_VALUE, value);
+
+	rc = efx_mcdi_rpc(efx, MC_CMD_MDIO_WRITE, inbuf, sizeof(inbuf),
+			  outbuf, sizeof(outbuf), &outlen);
+	if (rc)
+		goto fail;
+
+	*status_out = MCDI_DWORD(outbuf, MDIO_WRITE_OUT_STATUS);
+	return 0;
+
+fail:
+	EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+	return rc;
+}
+
+static u32 mcdi_to_ethtool_cap(u32 media, u32 cap)
+{
+	u32 result = 0;
+
+	switch (media) {
+	case MC_CMD_MEDIA_KX4:
+		result |= SUPPORTED_Backplane;
+		if (cap & (1 << MC_CMD_PHY_CAP_1000FDX_LBN))
+			result |= SUPPORTED_1000baseKX_Full;
+		if (cap & (1 << MC_CMD_PHY_CAP_10000FDX_LBN))
+			result |= SUPPORTED_10000baseKX4_Full;
+		break;
+
+	case MC_CMD_MEDIA_XFP:
+	case MC_CMD_MEDIA_SFP_PLUS:
+		result |= SUPPORTED_FIBRE;
+		break;
+
+	case MC_CMD_MEDIA_BASE_T:
+		result |= SUPPORTED_TP;
+		if (cap & (1 << MC_CMD_PHY_CAP_10HDX_LBN))
+			result |= SUPPORTED_10baseT_Half;
+		if (cap & (1 << MC_CMD_PHY_CAP_10FDX_LBN))
+			result |= SUPPORTED_10baseT_Full;
+		if (cap & (1 << MC_CMD_PHY_CAP_100HDX_LBN))
+			result |= SUPPORTED_100baseT_Half;
+		if (cap & (1 << MC_CMD_PHY_CAP_100FDX_LBN))
+			result |= SUPPORTED_100baseT_Full;
+		if (cap & (1 << MC_CMD_PHY_CAP_1000HDX_LBN))
+			result |= SUPPORTED_1000baseT_Half;
+		if (cap & (1 << MC_CMD_PHY_CAP_1000FDX_LBN))
+			result |= SUPPORTED_1000baseT_Full;
+		if (cap & (1 << MC_CMD_PHY_CAP_10000FDX_LBN))
+			result |= SUPPORTED_10000baseT_Full;
+		break;
+	}
+
+	if (cap & (1 << MC_CMD_PHY_CAP_PAUSE_LBN))
+		result |= SUPPORTED_Pause;
+	if (cap & (1 << MC_CMD_PHY_CAP_ASYM_LBN))
+		result |= SUPPORTED_Asym_Pause;
+	if (cap & (1 << MC_CMD_PHY_CAP_AN_LBN))
+		result |= SUPPORTED_Autoneg;
+
+	return result;
+}
+
+static u32 ethtool_to_mcdi_cap(u32 cap)
+{
+	u32 result = 0;
+
+	if (cap & SUPPORTED_10baseT_Half)
+		result |= (1 << MC_CMD_PHY_CAP_10HDX_LBN);
+	if (cap & SUPPORTED_10baseT_Full)
+		result |= (1 << MC_CMD_PHY_CAP_10FDX_LBN);
+	if (cap & SUPPORTED_100baseT_Half)
+		result |= (1 << MC_CMD_PHY_CAP_100HDX_LBN);
+	if (cap & SUPPORTED_100baseT_Full)
+		result |= (1 << MC_CMD_PHY_CAP_100FDX_LBN);
+	if (cap & SUPPORTED_1000baseT_Half)
+		result |= (1 << MC_CMD_PHY_CAP_1000HDX_LBN);
+	if (cap & (SUPPORTED_1000baseT_Full | SUPPORTED_1000baseKX_Full))
+		result |= (1 << MC_CMD_PHY_CAP_1000FDX_LBN);
+	if (cap & (SUPPORTED_10000baseT_Full | SUPPORTED_10000baseKX4_Full))
+		result |= (1 << MC_CMD_PHY_CAP_10000FDX_LBN);
+	if (cap & SUPPORTED_Pause)
+		result |= (1 << MC_CMD_PHY_CAP_PAUSE_LBN);
+	if (cap & SUPPORTED_Asym_Pause)
+		result |= (1 << MC_CMD_PHY_CAP_ASYM_LBN);
+	if (cap & SUPPORTED_Autoneg)
+		result |= (1 << MC_CMD_PHY_CAP_AN_LBN);
+
+	return result;
+}
+
+static u32 efx_get_mcdi_phy_flags(struct efx_nic *efx)
+{
+	struct efx_mcdi_phy_cfg *phy_cfg = efx->phy_data;
+	enum efx_phy_mode mode, supported;
+	u32 flags;
+
+	/* TODO: Advertise the capabilities supported by this PHY */
+	supported = 0;
+	if (phy_cfg->flags & (1 << MC_CMD_GET_PHY_CFG_TXDIS_LBN))
+		supported |= PHY_MODE_TX_DISABLED;
+	if (phy_cfg->flags & (1 << MC_CMD_GET_PHY_CFG_LOWPOWER_LBN))
+		supported |= PHY_MODE_LOW_POWER;
+	if (phy_cfg->flags & (1 << MC_CMD_GET_PHY_CFG_POWEROFF_LBN))
+		supported |= PHY_MODE_OFF;
+
+	mode = efx->phy_mode & supported;
+
+	flags = 0;
+	if (mode & PHY_MODE_TX_DISABLED)
+		flags |= (1 << MC_CMD_SET_LINK_TXDIS_LBN);
+	if (mode & PHY_MODE_LOW_POWER)
+		flags |= (1 << MC_CMD_SET_LINK_LOWPOWER_LBN);
+	if (mode & PHY_MODE_OFF)
+		flags |= (1 << MC_CMD_SET_LINK_POWEROFF_LBN);
+
+	return flags;
+}
+
+static u32 mcdi_to_ethtool_media(u32 media)
+{
+	switch (media) {
+	case MC_CMD_MEDIA_XAUI:
+	case MC_CMD_MEDIA_CX4:
+	case MC_CMD_MEDIA_KX4:
+		return PORT_OTHER;
+
+	case MC_CMD_MEDIA_XFP:
+	case MC_CMD_MEDIA_SFP_PLUS:
+		return PORT_FIBRE;
+
+	case MC_CMD_MEDIA_BASE_T:
+		return PORT_TP;
+
+	default:
+		return PORT_OTHER;
+	}
+}
+
+static int efx_mcdi_phy_probe(struct efx_nic *efx)
+{
+	struct efx_mcdi_phy_cfg *phy_cfg;
+	int rc;
+
+	/* TODO: Move phy_data initialisation to
+	 * phy_op->probe/remove, rather than init/fini */
+	phy_cfg = kzalloc(sizeof(*phy_cfg), GFP_KERNEL);
+	if (phy_cfg == NULL) {
+		rc = -ENOMEM;
+		goto fail_alloc;
+	}
+	rc = efx_mcdi_get_phy_cfg(efx, phy_cfg);
+	if (rc != 0)
+		goto fail;
+
+	efx->phy_type = phy_cfg->type;
+
+	efx->mdio_bus = phy_cfg->channel;
+	efx->mdio.prtad = phy_cfg->port;
+	efx->mdio.mmds = phy_cfg->mmd_mask & ~(1 << MC_CMD_MMD_CLAUSE22);
+	efx->mdio.mode_support = 0;
+	if (phy_cfg->mmd_mask & (1 << MC_CMD_MMD_CLAUSE22))
+		efx->mdio.mode_support |= MDIO_SUPPORTS_C22;
+	if (phy_cfg->mmd_mask & ~(1 << MC_CMD_MMD_CLAUSE22))
+		efx->mdio.mode_support |= MDIO_SUPPORTS_C45 | MDIO_EMULATE_C22;
+
+	/* Assert that we can map efx -> mcdi loopback modes */
+	BUILD_BUG_ON(LOOPBACK_NONE != MC_CMD_LOOPBACK_NONE);
+	BUILD_BUG_ON(LOOPBACK_DATA != MC_CMD_LOOPBACK_DATA);
+	BUILD_BUG_ON(LOOPBACK_GMAC != MC_CMD_LOOPBACK_GMAC);
+	BUILD_BUG_ON(LOOPBACK_XGMII != MC_CMD_LOOPBACK_XGMII);
+	BUILD_BUG_ON(LOOPBACK_XGXS != MC_CMD_LOOPBACK_XGXS);
+	BUILD_BUG_ON(LOOPBACK_XAUI != MC_CMD_LOOPBACK_XAUI);
+	BUILD_BUG_ON(LOOPBACK_GMII != MC_CMD_LOOPBACK_GMII);
+	BUILD_BUG_ON(LOOPBACK_SGMII != MC_CMD_LOOPBACK_SGMII);
+	BUILD_BUG_ON(LOOPBACK_XGBR != MC_CMD_LOOPBACK_XGBR);
+	BUILD_BUG_ON(LOOPBACK_XFI != MC_CMD_LOOPBACK_XFI);
+	BUILD_BUG_ON(LOOPBACK_XAUI_FAR != MC_CMD_LOOPBACK_XAUI_FAR);
+	BUILD_BUG_ON(LOOPBACK_GMII_FAR != MC_CMD_LOOPBACK_GMII_FAR);
+	BUILD_BUG_ON(LOOPBACK_SGMII_FAR != MC_CMD_LOOPBACK_SGMII_FAR);
+	BUILD_BUG_ON(LOOPBACK_XFI_FAR != MC_CMD_LOOPBACK_XFI_FAR);
+	BUILD_BUG_ON(LOOPBACK_GPHY != MC_CMD_LOOPBACK_GPHY);
+	BUILD_BUG_ON(LOOPBACK_PHYXS != MC_CMD_LOOPBACK_PHYXS);
+	BUILD_BUG_ON(LOOPBACK_PCS != MC_CMD_LOOPBACK_PCS);
+	BUILD_BUG_ON(LOOPBACK_PMAPMD != MC_CMD_LOOPBACK_PMAPMD);
+	BUILD_BUG_ON(LOOPBACK_XPORT != MC_CMD_LOOPBACK_XPORT);
+	BUILD_BUG_ON(LOOPBACK_XGMII_WS != MC_CMD_LOOPBACK_XGMII_WS);
+	BUILD_BUG_ON(LOOPBACK_XAUI_WS != MC_CMD_LOOPBACK_XAUI_WS);
+	BUILD_BUG_ON(LOOPBACK_XAUI_WS_FAR != MC_CMD_LOOPBACK_XAUI_WS_FAR);
+	BUILD_BUG_ON(LOOPBACK_XAUI_WS_NEAR != MC_CMD_LOOPBACK_XAUI_WS_NEAR);
+	BUILD_BUG_ON(LOOPBACK_GMII_WS != MC_CMD_LOOPBACK_GMII_WS);
+	BUILD_BUG_ON(LOOPBACK_XFI_WS != MC_CMD_LOOPBACK_XFI_WS);
+	BUILD_BUG_ON(LOOPBACK_XFI_WS_FAR != MC_CMD_LOOPBACK_XFI_WS_FAR);
+	BUILD_BUG_ON(LOOPBACK_PHYXS_WS != MC_CMD_LOOPBACK_PHYXS_WS);
+
+	rc = efx_mcdi_loopback_modes(efx, &efx->loopback_modes);
+	if (rc != 0)
+		goto fail;
+	/* The MC indicates that LOOPBACK_NONE is a valid loopback mode,
+	 * but by convention we don't */
+	efx->loopback_modes &= ~(1 << LOOPBACK_NONE);
+
+	kfree(phy_cfg);
+
+	return 0;
+
+fail:
+	kfree(phy_cfg);
+fail_alloc:
+	return rc;
+}
+
+static int efx_mcdi_phy_init(struct efx_nic *efx)
+{
+	struct efx_mcdi_phy_cfg *phy_data;
+	u8 outbuf[MC_CMD_GET_LINK_OUT_LEN];
+	u32 caps;
+	int rc;
+
+	phy_data = kzalloc(sizeof(*phy_data), GFP_KERNEL);
+	if (phy_data == NULL)
+		return -ENOMEM;
+
+	rc = efx_mcdi_get_phy_cfg(efx, phy_data);
+	if (rc != 0)
+		goto fail;
+
+	efx->phy_data = phy_data;
+
+	BUILD_BUG_ON(MC_CMD_GET_LINK_IN_LEN != 0);
+	rc = efx_mcdi_rpc(efx, MC_CMD_GET_LINK, NULL, 0,
+			  outbuf, sizeof(outbuf), NULL);
+	if (rc)
+		goto fail;
+
+	caps = MCDI_DWORD(outbuf, GET_LINK_OUT_CAP);
+	if (caps & (1 << MC_CMD_PHY_CAP_AN_LBN))
+		efx->link_advertising =
+			mcdi_to_ethtool_cap(phy_data->media, caps);
+	else
+		phy_data->forced_cap = caps;
+
+	return 0;
+
+fail:
+	kfree(phy_data);
+	return rc;
+}
+
+int efx_mcdi_phy_reconfigure(struct efx_nic *efx)
+{
+	struct efx_mcdi_phy_cfg *phy_cfg = efx->phy_data;
+	u32 caps = (efx->link_advertising ?
+		    ethtool_to_mcdi_cap(efx->link_advertising) :
+		    phy_cfg->forced_cap);
+
+	return efx_mcdi_set_link(efx, caps, efx_get_mcdi_phy_flags(efx),
+				 efx->loopback_mode, 0);
+}
+
+void efx_mcdi_phy_decode_link(struct efx_nic *efx,
+			      struct efx_link_state *link_state,
+			      u32 speed, u32 flags, u32 fcntl)
+{
+	switch (fcntl) {
+	case MC_CMD_FCNTL_AUTO:
+		WARN_ON(1);	/* This is not a link mode */
+		link_state->fc = EFX_FC_AUTO | EFX_FC_TX | EFX_FC_RX;
+		break;
+	case MC_CMD_FCNTL_BIDIR:
+		link_state->fc = EFX_FC_TX | EFX_FC_RX;
+		break;
+	case MC_CMD_FCNTL_RESPOND:
+		link_state->fc = EFX_FC_RX;
+		break;
+	default:
+		WARN_ON(1);
+	case MC_CMD_FCNTL_OFF:
+		link_state->fc = 0;
+		break;
+	}
+
+	link_state->up = !!(flags & (1 << MC_CMD_GET_LINK_LINK_UP_LBN));
+	link_state->fd = !!(flags & (1 << MC_CMD_GET_LINK_FULL_DUPLEX_LBN));
+	link_state->speed = speed;
+}
+
+/* Verify that the forced flow control settings (!EFX_FC_AUTO) are
+ * supported by the link partner. Warn the user if this isn't the case
+ */
+void efx_mcdi_phy_check_fcntl(struct efx_nic *efx, u32 lpa)
+{
+	struct efx_mcdi_phy_cfg *phy_cfg = efx->phy_data;
+	u32 rmtadv;
+
+	/* The link partner capabilities are only relevent if the
+	 * link supports flow control autonegotiation */
+	if (~phy_cfg->supported_cap & (1 << MC_CMD_PHY_CAP_ASYM_LBN))
+		return;
+
+	/* If flow control autoneg is supported and enabled, then fine */
+	if (efx->wanted_fc & EFX_FC_AUTO)
+		return;
+
+	rmtadv = 0;
+	if (lpa & (1 << MC_CMD_PHY_CAP_PAUSE_LBN))
+		rmtadv |= ADVERTISED_Pause;
+	if (lpa & (1 << MC_CMD_PHY_CAP_ASYM_LBN))
+		rmtadv |=  ADVERTISED_Asym_Pause;
+
+	if ((efx->wanted_fc & EFX_FC_TX) && rmtadv == ADVERTISED_Asym_Pause)
+		EFX_ERR(efx, "warning: link partner doesn't support "
+			"pause frames");
+}
+
+static bool efx_mcdi_phy_poll(struct efx_nic *efx)
+{
+	struct efx_link_state old_state = efx->link_state;
+	u8 outbuf[MC_CMD_GET_LINK_OUT_LEN];
+	int rc;
+
+	WARN_ON(!mutex_is_locked(&efx->mac_lock));
+
+	BUILD_BUG_ON(MC_CMD_GET_LINK_IN_LEN != 0);
+
+	rc = efx_mcdi_rpc(efx, MC_CMD_GET_LINK, NULL, 0,
+			  outbuf, sizeof(outbuf), NULL);
+	if (rc) {
+		EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+		efx->link_state.up = false;
+	} else {
+		efx_mcdi_phy_decode_link(
+			efx, &efx->link_state,
+			MCDI_DWORD(outbuf, GET_LINK_OUT_LINK_SPEED),
+			MCDI_DWORD(outbuf, GET_LINK_OUT_FLAGS),
+			MCDI_DWORD(outbuf, GET_LINK_OUT_FCNTL));
+	}
+
+	return !efx_link_state_equal(&efx->link_state, &old_state);
+}
+
+static void efx_mcdi_phy_fini(struct efx_nic *efx)
+{
+	struct efx_mcdi_phy_data *phy_data = efx->phy_data;
+
+	efx->phy_data = NULL;
+	kfree(phy_data);
+}
+
+static void efx_mcdi_phy_get_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
+{
+	struct efx_mcdi_phy_cfg *phy_cfg = efx->phy_data;
+	u8 outbuf[MC_CMD_GET_LINK_OUT_LEN];
+	int rc;
+
+	ecmd->supported =
+		mcdi_to_ethtool_cap(phy_cfg->media, phy_cfg->supported_cap);
+	ecmd->advertising = efx->link_advertising;
+	ecmd->speed = efx->link_state.speed;
+	ecmd->duplex = efx->link_state.fd;
+	ecmd->port = mcdi_to_ethtool_media(phy_cfg->media);
+	ecmd->phy_address = phy_cfg->port;
+	ecmd->transceiver = XCVR_INTERNAL;
+	ecmd->autoneg = !!(efx->link_advertising & ADVERTISED_Autoneg);
+	ecmd->mdio_support = (efx->mdio.mode_support &
+			      (MDIO_SUPPORTS_C45 | MDIO_SUPPORTS_C22));
+
+	BUILD_BUG_ON(MC_CMD_GET_LINK_IN_LEN != 0);
+	rc = efx_mcdi_rpc(efx, MC_CMD_GET_LINK, NULL, 0,
+			  outbuf, sizeof(outbuf), NULL);
+	if (rc) {
+		EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+		return;
+	}
+	ecmd->lp_advertising =
+		mcdi_to_ethtool_cap(phy_cfg->media,
+				    MCDI_DWORD(outbuf, GET_LINK_OUT_LP_CAP));
+}
+
+static int efx_mcdi_phy_set_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
+{
+	struct efx_mcdi_phy_cfg *phy_cfg = efx->phy_data;
+	u32 caps;
+	int rc;
+
+	if (ecmd->autoneg) {
+		caps = (ethtool_to_mcdi_cap(ecmd->advertising) |
+			 1 << MC_CMD_PHY_CAP_AN_LBN);
+	} else if (ecmd->duplex) {
+		switch (ecmd->speed) {
+		case 10:    caps = 1 << MC_CMD_PHY_CAP_10FDX_LBN;    break;
+		case 100:   caps = 1 << MC_CMD_PHY_CAP_100FDX_LBN;   break;
+		case 1000:  caps = 1 << MC_CMD_PHY_CAP_1000FDX_LBN;  break;
+		case 10000: caps = 1 << MC_CMD_PHY_CAP_10000FDX_LBN; break;
+		default:    return -EINVAL;
+		}
+	} else {
+		switch (ecmd->speed) {
+		case 10:    caps = 1 << MC_CMD_PHY_CAP_10HDX_LBN;    break;
+		case 100:   caps = 1 << MC_CMD_PHY_CAP_100HDX_LBN;   break;
+		case 1000:  caps = 1 << MC_CMD_PHY_CAP_1000HDX_LBN;  break;
+		default:    return -EINVAL;
+		}
+	}
+
+	rc = efx_mcdi_set_link(efx, caps, efx_get_mcdi_phy_flags(efx),
+			       efx->loopback_mode, 0);
+	if (rc)
+		return rc;
+
+	if (ecmd->autoneg) {
+		efx_link_set_advertising(
+			efx, ecmd->advertising | ADVERTISED_Autoneg);
+		phy_cfg->forced_cap = 0;
+	} else {
+		efx_link_set_advertising(efx, 0);
+		phy_cfg->forced_cap = caps;
+	}
+	return 0;
+}
+
+struct efx_phy_operations efx_mcdi_phy_ops = {
+	.probe		= efx_mcdi_phy_probe,
+	.init 	 	= efx_mcdi_phy_init,
+	.reconfigure	= efx_mcdi_phy_reconfigure,
+	.poll		= efx_mcdi_phy_poll,
+	.fini		= efx_mcdi_phy_fini,
+	.get_settings	= efx_mcdi_phy_get_settings,
+	.set_settings	= efx_mcdi_phy_set_settings,
+	.run_tests	= NULL,
+	.test_name	= NULL,
+};
diff --git a/drivers/net/sfc/siena.c b/drivers/net/sfc/siena.c
new file mode 100644
index 0000000..de07a4f
--- /dev/null
+++ b/drivers/net/sfc/siena.c
@@ -0,0 +1,604 @@
+/****************************************************************************
+ * Driver for Solarflare Solarstorm network controllers and boards
+ * Copyright 2005-2006 Fen Systems Ltd.
+ * Copyright 2006-2009 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#include <linux/bitops.h>
+#include <linux/delay.h>
+#include <linux/pci.h>
+#include <linux/module.h>
+#include "net_driver.h"
+#include "bitfield.h"
+#include "efx.h"
+#include "nic.h"
+#include "mac.h"
+#include "spi.h"
+#include "regs.h"
+#include "io.h"
+#include "phy.h"
+#include "workarounds.h"
+#include "mcdi.h"
+#include "mcdi_pcol.h"
+
+/* Hardware control for SFC9000 family including SFL9021 (aka Siena). */
+
+static void siena_init_wol(struct efx_nic *efx);
+
+
+static void siena_push_irq_moderation(struct efx_channel *channel)
+{
+	efx_dword_t timer_cmd;
+
+	if (channel->irq_moderation)
+		EFX_POPULATE_DWORD_2(timer_cmd,
+				     FRF_CZ_TC_TIMER_MODE,
+				     FFE_CZ_TIMER_MODE_INT_HLDOFF,
+				     FRF_CZ_TC_TIMER_VAL,
+				     channel->irq_moderation - 1);
+	else
+		EFX_POPULATE_DWORD_2(timer_cmd,
+				     FRF_CZ_TC_TIMER_MODE,
+				     FFE_CZ_TIMER_MODE_DIS,
+				     FRF_CZ_TC_TIMER_VAL, 0);
+	efx_writed_page_locked(channel->efx, &timer_cmd, FR_BZ_TIMER_COMMAND_P0,
+			       channel->channel);
+}
+
+static void siena_push_multicast_hash(struct efx_nic *efx)
+{
+	WARN_ON(!mutex_is_locked(&efx->mac_lock));
+
+	efx_mcdi_rpc(efx, MC_CMD_SET_MCAST_HASH,
+		     efx->multicast_hash.byte, sizeof(efx->multicast_hash),
+		     NULL, 0, NULL);
+}
+
+static int siena_mdio_write(struct net_device *net_dev,
+			    int prtad, int devad, u16 addr, u16 value)
+{
+	struct efx_nic *efx = netdev_priv(net_dev);
+	uint32_t status;
+	int rc;
+
+	rc = efx_mcdi_mdio_write(efx, efx->mdio_bus, prtad, devad,
+				 addr, value, &status);
+	if (rc)
+		return rc;
+	if (status != MC_CMD_MDIO_STATUS_GOOD)
+		return -EIO;
+
+	return 0;
+}
+
+static int siena_mdio_read(struct net_device *net_dev,
+			   int prtad, int devad, u16 addr)
+{
+	struct efx_nic *efx = netdev_priv(net_dev);
+	uint16_t value;
+	uint32_t status;
+	int rc;
+
+	rc = efx_mcdi_mdio_read(efx, efx->mdio_bus, prtad, devad,
+				addr, &value, &status);
+	if (rc)
+		return rc;
+	if (status != MC_CMD_MDIO_STATUS_GOOD)
+		return -EIO;
+
+	return (int)value;
+}
+
+/* This call is responsible for hooking in the MAC and PHY operations */
+static int siena_probe_port(struct efx_nic *efx)
+{
+	int rc;
+
+	/* Hook in PHY operations table */
+	efx->phy_op = &efx_mcdi_phy_ops;
+
+	/* Set up MDIO structure for PHY */
+	efx->mdio.mode_support = MDIO_SUPPORTS_C45 | MDIO_EMULATE_C22;
+	efx->mdio.mdio_read = siena_mdio_read;
+	efx->mdio.mdio_write = siena_mdio_write;
+
+	/* Fill out MDIO structure and loopback modes */
+	rc = efx->phy_op->probe(efx);
+	if (rc != 0)
+		return rc;
+
+	/* Initial assumption */
+	efx->link_state.speed = 10000;
+	efx->link_state.fd = true;
+	efx->wanted_fc = EFX_FC_RX | EFX_FC_TX;
+
+	/* Allocate buffer for stats */
+	rc = efx_nic_alloc_buffer(efx, &efx->stats_buffer,
+				  MC_CMD_MAC_NSTATS * sizeof(u64));
+	if (rc)
+		return rc;
+	EFX_LOG(efx, "stats buffer at %llx (virt %p phys %llx)\n",
+		(u64)efx->stats_buffer.dma_addr,
+		efx->stats_buffer.addr,
+		(u64)virt_to_phys(efx->stats_buffer.addr));
+
+	efx_mcdi_mac_stats(efx, efx->stats_buffer.dma_addr, 0, 0, 1);
+
+	return 0;
+}
+
+void siena_remove_port(struct efx_nic *efx)
+{
+	efx_nic_free_buffer(efx, &efx->stats_buffer);
+}
+
+static const struct efx_nic_register_test siena_register_tests[] = {
+	{ FR_AZ_ADR_REGION,
+	  EFX_OWORD32(0x0001FFFF, 0x0001FFFF, 0x0001FFFF, 0x0001FFFF) },
+	{ FR_CZ_USR_EV_CFG,
+	  EFX_OWORD32(0x000103FF, 0x00000000, 0x00000000, 0x00000000) },
+	{ FR_AZ_RX_CFG,
+	  EFX_OWORD32(0xFFFFFFFE, 0xFFFFFFFF, 0x0003FFFF, 0x00000000) },
+	{ FR_AZ_TX_CFG,
+	  EFX_OWORD32(0x7FFF0037, 0xFFFF8000, 0xFFFFFFFF, 0x03FFFFFF) },
+	{ FR_AZ_TX_RESERVED,
+	  EFX_OWORD32(0xFFFEFE80, 0x1FFFFFFF, 0x020000FE, 0x007FFFFF) },
+	{ FR_AZ_SRM_TX_DC_CFG,
+	  EFX_OWORD32(0x001FFFFF, 0x00000000, 0x00000000, 0x00000000) },
+	{ FR_AZ_RX_DC_CFG,
+	  EFX_OWORD32(0x00000003, 0x00000000, 0x00000000, 0x00000000) },
+	{ FR_AZ_RX_DC_PF_WM,
+	  EFX_OWORD32(0x000003FF, 0x00000000, 0x00000000, 0x00000000) },
+	{ FR_BZ_DP_CTRL,
+	  EFX_OWORD32(0x00000FFF, 0x00000000, 0x00000000, 0x00000000) },
+	{ FR_BZ_RX_RSS_TKEY,
+	  EFX_OWORD32(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF) },
+	{ FR_CZ_RX_RSS_IPV6_REG1,
+	  EFX_OWORD32(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF) },
+	{ FR_CZ_RX_RSS_IPV6_REG2,
+	  EFX_OWORD32(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF) },
+	{ FR_CZ_RX_RSS_IPV6_REG3,
+	  EFX_OWORD32(0xFFFFFFFF, 0xFFFFFFFF, 0x00000007, 0x00000000) },
+};
+
+static int siena_test_registers(struct efx_nic *efx)
+{
+	return efx_nic_test_registers(efx, siena_register_tests,
+				      ARRAY_SIZE(siena_register_tests));
+}
+
+/**************************************************************************
+ *
+ * Device reset
+ *
+ **************************************************************************
+ */
+
+static int siena_reset_hw(struct efx_nic *efx, enum reset_type method)
+{
+
+	if (method == RESET_TYPE_WORLD)
+		return efx_mcdi_reset_mc(efx);
+	else
+		return efx_mcdi_reset_port(efx);
+}
+
+static int siena_probe_nvconfig(struct efx_nic *efx)
+{
+	int rc;
+
+	rc = efx_mcdi_get_board_cfg(efx, efx->mac_address, NULL);
+	if (rc)
+		return rc;
+
+	return 0;
+}
+
+static int siena_probe_nic(struct efx_nic *efx)
+{
+	struct siena_nic_data *nic_data;
+	bool already_attached = 0;
+	int rc;
+
+	/* Allocate storage for hardware specific data */
+	nic_data = kzalloc(sizeof(struct siena_nic_data), GFP_KERNEL);
+	if (!nic_data)
+		return -ENOMEM;
+	efx->nic_data = nic_data;
+
+	if (efx_nic_fpga_ver(efx) != 0) {
+		EFX_ERR(efx, "Siena FPGA not supported\n");
+		rc = -ENODEV;
+		goto fail1;
+	}
+
+	efx_mcdi_init(efx);
+
+	/* Recover from a failed assertion before probing */
+	rc = efx_mcdi_handle_assertion(efx);
+	if (rc)
+		goto fail1;
+
+	rc = efx_mcdi_fwver(efx, &nic_data->fw_version, &nic_data->fw_build);
+	if (rc) {
+		EFX_ERR(efx, "Failed to read MCPU firmware version - "
+			"rc %d\n", rc);
+		goto fail1; /* MCPU absent? */
+	}
+
+	/* Let the BMC know that the driver is now in charge of link and
+	 * filter settings. We must do this before we reset the NIC */
+	rc = efx_mcdi_drv_attach(efx, true, &already_attached);
+	if (rc) {
+		EFX_ERR(efx, "Unable to register driver with MCPU\n");
+		goto fail2;
+	}
+	if (already_attached)
+		/* Not a fatal error */
+		EFX_ERR(efx, "Host already registered with MCPU\n");
+
+	/* Now we can reset the NIC */
+	rc = siena_reset_hw(efx, RESET_TYPE_ALL);
+	if (rc) {
+		EFX_ERR(efx, "failed to reset NIC\n");
+		goto fail3;
+	}
+
+	siena_init_wol(efx);
+
+	/* Allocate memory for INT_KER */
+	rc = efx_nic_alloc_buffer(efx, &efx->irq_status, sizeof(efx_oword_t));
+	if (rc)
+		goto fail4;
+	BUG_ON(efx->irq_status.dma_addr & 0x0f);
+
+	EFX_LOG(efx, "INT_KER at %llx (virt %p phys %llx)\n",
+		(unsigned long long)efx->irq_status.dma_addr,
+		efx->irq_status.addr,
+		(unsigned long long)virt_to_phys(efx->irq_status.addr));
+
+	/* Read in the non-volatile configuration */
+	rc = siena_probe_nvconfig(efx);
+	if (rc == -EINVAL) {
+		EFX_ERR(efx, "NVRAM is invalid therefore using defaults\n");
+		efx->phy_type = PHY_TYPE_NONE;
+		efx->mdio.prtad = MDIO_PRTAD_NONE;
+	} else if (rc) {
+		goto fail5;
+	}
+
+	return 0;
+
+fail5:
+	efx_nic_free_buffer(efx, &efx->irq_status);
+fail4:
+fail3:
+	efx_mcdi_drv_attach(efx, false, NULL);
+fail2:
+fail1:
+	kfree(efx->nic_data);
+	return rc;
+}
+
+/* This call performs hardware-specific global initialisation, such as
+ * defining the descriptor cache sizes and number of RSS channels.
+ * It does not set up any buffers, descriptor rings or event queues.
+ */
+static int siena_init_nic(struct efx_nic *efx)
+{
+	efx_oword_t temp;
+	int rc;
+
+	/* Recover from a failed assertion post-reset */
+	rc = efx_mcdi_handle_assertion(efx);
+	if (rc)
+		return rc;
+
+	/* Squash TX of packets of 16 bytes or less */
+	efx_reado(efx, &temp, FR_AZ_TX_RESERVED);
+	EFX_SET_OWORD_FIELD(temp, FRF_BZ_TX_FLUSH_MIN_LEN_EN, 1);
+	efx_writeo(efx, &temp, FR_AZ_TX_RESERVED);
+
+	/* Do not enable TX_NO_EOP_DISC_EN, since it limits packets to 16
+	 * descriptors (which is bad).
+	 */
+	efx_reado(efx, &temp, FR_AZ_TX_CFG);
+	EFX_SET_OWORD_FIELD(temp, FRF_AZ_TX_NO_EOP_DISC_EN, 0);
+	EFX_SET_OWORD_FIELD(temp, FRF_CZ_TX_FILTER_EN_BIT, 1);
+	efx_writeo(efx, &temp, FR_AZ_TX_CFG);
+
+	efx_reado(efx, &temp, FR_AZ_RX_CFG);
+	EFX_SET_OWORD_FIELD(temp, FRF_BZ_RX_DESC_PUSH_EN, 0);
+	EFX_SET_OWORD_FIELD(temp, FRF_BZ_RX_INGR_EN, 1);
+	efx_writeo(efx, &temp, FR_AZ_RX_CFG);
+
+	if (efx_nic_rx_xoff_thresh >= 0 || efx_nic_rx_xon_thresh >= 0)
+		/* No MCDI operation has been defined to set thresholds */
+		EFX_ERR(efx, "ignoring RX flow control thresholds\n");
+
+	/* Enable event logging */
+	rc = efx_mcdi_log_ctrl(efx, true, false, 0);
+	if (rc)
+		return rc;
+
+	/* Set destination of both TX and RX Flush events */
+	EFX_POPULATE_OWORD_1(temp, FRF_BZ_FLS_EVQ_ID, 0);
+	efx_writeo(efx, &temp, FR_BZ_DP_CTRL);
+
+	EFX_POPULATE_OWORD_1(temp, FRF_CZ_USREV_DIS, 1);
+	efx_writeo(efx, &temp, FR_CZ_USR_EV_CFG);
+
+	efx_nic_init_common(efx);
+	return 0;
+}
+
+static void siena_remove_nic(struct efx_nic *efx)
+{
+	efx_nic_free_buffer(efx, &efx->irq_status);
+
+	siena_reset_hw(efx, RESET_TYPE_ALL);
+
+	/* Relinquish the device back to the BMC */
+	if (efx_nic_has_mc(efx))
+		efx_mcdi_drv_attach(efx, false, NULL);
+
+	/* Tear down the private nic state */
+	kfree(efx->nic_data);
+	efx->nic_data = NULL;
+}
+
+#define STATS_GENERATION_INVALID ((u64)(-1))
+
+static int siena_try_update_nic_stats(struct efx_nic *efx)
+{
+	u64 *dma_stats;
+	struct efx_mac_stats *mac_stats;
+	u64 generation_start;
+	u64 generation_end;
+
+	mac_stats = &efx->mac_stats;
+	dma_stats = (u64 *)efx->stats_buffer.addr;
+
+	generation_end = dma_stats[MC_CMD_MAC_GENERATION_END];
+	if (generation_end == STATS_GENERATION_INVALID)
+		return 0;
+	rmb();
+
+#define MAC_STAT(M, D) \
+	mac_stats->M = dma_stats[MC_CMD_MAC_ ## D]
+
+	MAC_STAT(tx_bytes, TX_BYTES);
+	MAC_STAT(tx_bad_bytes, TX_BAD_BYTES);
+	mac_stats->tx_good_bytes = (mac_stats->tx_bytes -
+				    mac_stats->tx_bad_bytes);
+	MAC_STAT(tx_packets, TX_PKTS);
+	MAC_STAT(tx_bad, TX_BAD_FCS_PKTS);
+	MAC_STAT(tx_pause, TX_PAUSE_PKTS);
+	MAC_STAT(tx_control, TX_CONTROL_PKTS);
+	MAC_STAT(tx_unicast, TX_UNICAST_PKTS);
+	MAC_STAT(tx_multicast, TX_MULTICAST_PKTS);
+	MAC_STAT(tx_broadcast, TX_BROADCAST_PKTS);
+	MAC_STAT(tx_lt64, TX_LT64_PKTS);
+	MAC_STAT(tx_64, TX_64_PKTS);
+	MAC_STAT(tx_65_to_127, TX_65_TO_127_PKTS);
+	MAC_STAT(tx_128_to_255, TX_128_TO_255_PKTS);
+	MAC_STAT(tx_256_to_511, TX_256_TO_511_PKTS);
+	MAC_STAT(tx_512_to_1023, TX_512_TO_1023_PKTS);
+	MAC_STAT(tx_1024_to_15xx, TX_1024_TO_15XX_PKTS);
+	MAC_STAT(tx_15xx_to_jumbo, TX_15XX_TO_JUMBO_PKTS);
+	MAC_STAT(tx_gtjumbo, TX_GTJUMBO_PKTS);
+	mac_stats->tx_collision = 0;
+	MAC_STAT(tx_single_collision, TX_SINGLE_COLLISION_PKTS);
+	MAC_STAT(tx_multiple_collision, TX_MULTIPLE_COLLISION_PKTS);
+	MAC_STAT(tx_excessive_collision, TX_EXCESSIVE_COLLISION_PKTS);
+	MAC_STAT(tx_deferred, TX_DEFERRED_PKTS);
+	MAC_STAT(tx_late_collision, TX_LATE_COLLISION_PKTS);
+	mac_stats->tx_collision = (mac_stats->tx_single_collision +
+				   mac_stats->tx_multiple_collision +
+				   mac_stats->tx_excessive_collision +
+				   mac_stats->tx_late_collision);
+	MAC_STAT(tx_excessive_deferred, TX_EXCESSIVE_DEFERRED_PKTS);
+	MAC_STAT(tx_non_tcpudp, TX_NON_TCPUDP_PKTS);
+	MAC_STAT(tx_mac_src_error, TX_MAC_SRC_ERR_PKTS);
+	MAC_STAT(tx_ip_src_error, TX_IP_SRC_ERR_PKTS);
+	MAC_STAT(rx_bytes, RX_BYTES);
+	MAC_STAT(rx_bad_bytes, RX_BAD_BYTES);
+	mac_stats->rx_good_bytes = (mac_stats->rx_bytes -
+				    mac_stats->rx_bad_bytes);
+	MAC_STAT(rx_packets, RX_PKTS);
+	MAC_STAT(rx_good, RX_GOOD_PKTS);
+	mac_stats->rx_bad = mac_stats->rx_packets - mac_stats->rx_good;
+	MAC_STAT(rx_pause, RX_PAUSE_PKTS);
+	MAC_STAT(rx_control, RX_CONTROL_PKTS);
+	MAC_STAT(rx_unicast, RX_UNICAST_PKTS);
+	MAC_STAT(rx_multicast, RX_MULTICAST_PKTS);
+	MAC_STAT(rx_broadcast, RX_BROADCAST_PKTS);
+	MAC_STAT(rx_lt64, RX_UNDERSIZE_PKTS);
+	MAC_STAT(rx_64, RX_64_PKTS);
+	MAC_STAT(rx_65_to_127, RX_65_TO_127_PKTS);
+	MAC_STAT(rx_128_to_255, RX_128_TO_255_PKTS);
+	MAC_STAT(rx_256_to_511, RX_256_TO_511_PKTS);
+	MAC_STAT(rx_512_to_1023, RX_512_TO_1023_PKTS);
+	MAC_STAT(rx_1024_to_15xx, RX_1024_TO_15XX_PKTS);
+	MAC_STAT(rx_15xx_to_jumbo, RX_15XX_TO_JUMBO_PKTS);
+	MAC_STAT(rx_gtjumbo, RX_GTJUMBO_PKTS);
+	mac_stats->rx_bad_lt64 = 0;
+	mac_stats->rx_bad_64_to_15xx = 0;
+	mac_stats->rx_bad_15xx_to_jumbo = 0;
+	MAC_STAT(rx_bad_gtjumbo, RX_JABBER_PKTS);
+	MAC_STAT(rx_overflow, RX_OVERFLOW_PKTS);
+	mac_stats->rx_missed = 0;
+	MAC_STAT(rx_false_carrier, RX_FALSE_CARRIER_PKTS);
+	MAC_STAT(rx_symbol_error, RX_SYMBOL_ERROR_PKTS);
+	MAC_STAT(rx_align_error, RX_ALIGN_ERROR_PKTS);
+	MAC_STAT(rx_length_error, RX_LENGTH_ERROR_PKTS);
+	MAC_STAT(rx_internal_error, RX_INTERNAL_ERROR_PKTS);
+	mac_stats->rx_good_lt64 = 0;
+
+	efx->n_rx_nodesc_drop_cnt = dma_stats[MC_CMD_MAC_RX_NODESC_DROPS];
+
+#undef MAC_STAT
+
+	rmb();
+	generation_start = dma_stats[MC_CMD_MAC_GENERATION_START];
+	if (generation_end != generation_start)
+		return -EAGAIN;
+
+	return 0;
+}
+
+static void siena_update_nic_stats(struct efx_nic *efx)
+{
+	while (siena_try_update_nic_stats(efx) == -EAGAIN)
+		cpu_relax();
+}
+
+static void siena_start_nic_stats(struct efx_nic *efx)
+{
+	u64 *dma_stats = (u64 *)efx->stats_buffer.addr;
+
+	dma_stats[MC_CMD_MAC_GENERATION_END] = STATS_GENERATION_INVALID;
+
+	efx_mcdi_mac_stats(efx, efx->stats_buffer.dma_addr,
+			   MC_CMD_MAC_NSTATS * sizeof(u64), 1, 0);
+}
+
+static void siena_stop_nic_stats(struct efx_nic *efx)
+{
+	efx_mcdi_mac_stats(efx, efx->stats_buffer.dma_addr, 0, 0, 0);
+}
+
+void siena_print_fwver(struct efx_nic *efx, char *buf, size_t len)
+{
+	struct siena_nic_data *nic_data = efx->nic_data;
+	snprintf(buf, len, "%u.%u.%u.%u",
+		 (unsigned int)(nic_data->fw_version >> 48),
+		 (unsigned int)(nic_data->fw_version >> 32 & 0xffff),
+		 (unsigned int)(nic_data->fw_version >> 16 & 0xffff),
+		 (unsigned int)(nic_data->fw_version & 0xffff));
+}
+
+/**************************************************************************
+ *
+ * Wake on LAN
+ *
+ **************************************************************************
+ */
+
+static void siena_get_wol(struct efx_nic *efx, struct ethtool_wolinfo *wol)
+{
+	struct siena_nic_data *nic_data = efx->nic_data;
+
+	wol->supported = WAKE_MAGIC;
+	if (nic_data->wol_filter_id != -1)
+		wol->wolopts = WAKE_MAGIC;
+	else
+		wol->wolopts = 0;
+	memset(&wol->sopass, 0, sizeof(wol->sopass));
+}
+
+
+static int siena_set_wol(struct efx_nic *efx, u32 type)
+{
+	struct siena_nic_data *nic_data = efx->nic_data;
+	int rc;
+
+	if (type & ~WAKE_MAGIC)
+		return -EINVAL;
+
+	if (type & WAKE_MAGIC) {
+		if (nic_data->wol_filter_id != -1)
+			efx_mcdi_wol_filter_remove(efx,
+						   nic_data->wol_filter_id);
+		rc = efx_mcdi_wol_filter_set_magic(efx, efx->mac_address,
+						   &nic_data->wol_filter_id);
+		if (rc)
+			goto fail;
+
+		pci_wake_from_d3(efx->pci_dev, true);
+	} else {
+		rc = efx_mcdi_wol_filter_reset(efx);
+		nic_data->wol_filter_id = -1;
+		pci_wake_from_d3(efx->pci_dev, false);
+		if (rc)
+			goto fail;
+	}
+
+	return 0;
+ fail:
+	EFX_ERR(efx, "%s failed: type=%d rc=%d\n", __func__, type, rc);
+	return rc;
+}
+
+
+static void siena_init_wol(struct efx_nic *efx)
+{
+	struct siena_nic_data *nic_data = efx->nic_data;
+	int rc;
+
+	rc = efx_mcdi_wol_filter_get_magic(efx, &nic_data->wol_filter_id);
+
+	if (rc != 0) {
+		/* If it failed, attempt to get into a synchronised
+		 * state with MC by resetting any set WoL filters */
+		efx_mcdi_wol_filter_reset(efx);
+		nic_data->wol_filter_id = -1;
+	} else if (nic_data->wol_filter_id != -1) {
+		pci_wake_from_d3(efx->pci_dev, true);
+	}
+}
+
+
+/**************************************************************************
+ *
+ * Revision-dependent attributes used by efx.c and nic.c
+ *
+ **************************************************************************
+ */
+
+struct efx_nic_type siena_a0_nic_type = {
+	.probe = siena_probe_nic,
+	.remove = siena_remove_nic,
+	.init = siena_init_nic,
+	.fini = efx_port_dummy_op_void,
+	.monitor = NULL,
+	.reset = siena_reset_hw,
+	.probe_port = siena_probe_port,
+	.remove_port = siena_remove_port,
+	.prepare_flush = efx_port_dummy_op_void,
+	.update_stats = siena_update_nic_stats,
+	.start_stats = siena_start_nic_stats,
+	.stop_stats = siena_stop_nic_stats,
+	.set_id_led = efx_mcdi_set_id_led,
+	.push_irq_moderation = siena_push_irq_moderation,
+	.push_multicast_hash = siena_push_multicast_hash,
+	.reconfigure_port = efx_mcdi_phy_reconfigure,
+	.get_wol = siena_get_wol,
+	.set_wol = siena_set_wol,
+	.resume_wol = siena_init_wol,
+	.test_registers = siena_test_registers,
+	.default_mac_ops = &efx_mcdi_mac_operations,
+
+	.revision = EFX_REV_SIENA_A0,
+	.mem_map_size = (FR_CZ_MC_TREG_SMEM +
+			 FR_CZ_MC_TREG_SMEM_STEP * FR_CZ_MC_TREG_SMEM_ROWS),
+	.txd_ptr_tbl_base = FR_BZ_TX_DESC_PTR_TBL,
+	.rxd_ptr_tbl_base = FR_BZ_RX_DESC_PTR_TBL,
+	.buf_tbl_base = FR_BZ_BUF_FULL_TBL,
+	.evq_ptr_tbl_base = FR_BZ_EVQ_PTR_TBL,
+	.evq_rptr_tbl_base = FR_BZ_EVQ_RPTR,
+	.max_dma_mask = DMA_BIT_MASK(FSF_AZ_TX_KER_BUF_ADDR_WIDTH),
+	.rx_buffer_padding = 0,
+	.max_interrupt_mode = EFX_INT_MODE_MSIX,
+	.phys_addr_channels = 32, /* Hardware limit is 64, but the legacy
+				   * interrupt handler only supports 32
+				   * channels */
+	.tx_dc_base = 0x88000,
+	.rx_dc_base = 0x68000,
+	.offload_features = NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM,
+	.reset_world_flags = ETH_RESET_MGMT << ETH_RESET_SHARED_SHIFT,
+};
-- 
1.6.5.3




-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

