From: Joe Perches <joe@perches.com>
Subject: qla3xxx: Odd likely incorrect use of test_bit in qla3xxx.c
Date: Tue, 12 May 2015 11:42:25 -0700
Message-ID: <1431456145.2884.75.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Dan Carpenter <dan.carpenter@oracle.com>
To: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Ron Mercer <ron.mercer@qlogic.com>, linux-driver@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0132.hostedemail.com ([216.40.44.132]:49376 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932870AbbELSm2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 14:42:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In ql_reset_work (line 3620)

The ql_reset_work function uses an "or" of 2 enum values.

enum { QL_RESET_DONE = 1,	/* Reset finished. */
	QL_RESET_ACTIVE = 2,	/* Waiting for reset to finish. */
	QL_RESET_START = 3,	/* Please reset the chip. */
	QL_RESET_PER_SCSI = 4,	/* SCSI driver requests reset. */
	QL_TX_TIMEOUT = 5,	/* Timeout in progress. */
	QL_LINK_MASTER = 6,	/* This driver controls the link. */
	QL_ADAPTER_UP = 7,	/* Adapter has been brought up. */

The values (3 and 4) or'd (added) together are
QL_ADAPTER_UP

If that's really what's desired, it'd be better to use
QL_ADAPTER_UP directly, though I'd expect this should
test both bits independently instead.

---

static void ql_reset_work(struct work_struct *work)
{
	struct ql3_adapter *qdev =
		container_of(work, struct ql3_adapter, reset_work.work);
	struct net_device *ndev = qdev->ndev;
	u32 value;
	struct ql_tx_buf_cb *tx_cb;
	int max_wait_time, i;
	struct ql3xxx_port_registers __iomem *port_regs =
		qdev->mem_map_registers;
	unsigned long hw_flags;

	if (test_bit((QL_RESET_PER_SCSI | QL_RESET_START), &qdev->flags)) {
		clear_bit(QL_LINK_MASTER, &qdev->flags);
