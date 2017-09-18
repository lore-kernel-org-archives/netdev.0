From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [RFC] endianness issues in drivers/net/ethernet/qlogic/qed
Date: Mon, 18 Sep 2017 18:49:40 +0100
Message-ID: <20170918174940.GB32076@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>,
        David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:47670 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756341AbdIRRtp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 13:49:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	"qed: Utilize FW 8.10.3.0" has attempted some endianness
annotations in that driver; unfortunately, either annotations are
BS or the driver is genuinely broken on big-endian hosts.

	For example, struct init_qm_vport_params is claimed to have
->vport_wfq little-endian 16bit.  However, *all* uses are host-endian -
the things like
                vport_params[i].vport_wfq = (wfq_speed * QED_WFQ_UNIT) /
                                                min_pf_rate;
and it's not even "... and at some point we convert it to little-endian
in place, or when copying to another instance".  It is consistently
host-endian.  If that's how it should be, that __le16 is BS; otherwise,
the driver's broken on big-endian.

	Another example:
struct qm_rf_pq_map {
        __le32 reg;
#define QM_RF_PQ_MAP_PQ_VALID_MASK              0x1
#define QM_RF_PQ_MAP_PQ_VALID_SHIFT             0
#define QM_RF_PQ_MAP_RL_ID_MASK                 0xFF
#define QM_RF_PQ_MAP_RL_ID_SHIFT                1
#define QM_RF_PQ_MAP_VP_PQ_ID_MASK              0x1FF
#define QM_RF_PQ_MAP_VP_PQ_ID_SHIFT             9
#define QM_RF_PQ_MAP_VOQ_MASK                   0x1F
#define QM_RF_PQ_MAP_VOQ_SHIFT                  18
#define QM_RF_PQ_MAP_WRR_WEIGHT_GROUP_MASK      0x3
#define QM_RF_PQ_MAP_WRR_WEIGHT_GROUP_SHIFT     23
#define QM_RF_PQ_MAP_RL_VALID_MASK              0x1
#define QM_RF_PQ_MAP_RL_VALID_SHIFT             25
#define QM_RF_PQ_MAP_RESERVED_MASK              0x3F
#define QM_RF_PQ_MAP_RESERVED_SHIFT             26
};
with instances of that manipulated with
                memset(&tx_pq_map, 0, sizeof(tx_pq_map));
                SET_FIELD(tx_pq_map.reg, QM_RF_PQ_MAP_PQ_VALID, 1);
                SET_FIELD(tx_pq_map.reg,
                          QM_RF_PQ_MAP_RL_VALID, rl_valid ? 1 : 0);
                SET_FIELD(tx_pq_map.reg, QM_RF_PQ_MAP_VP_PQ_ID, first_tx_pq_id);
                SET_FIELD(tx_pq_map.reg, QM_RF_PQ_MAP_RL_ID,
                          rl_valid ?
                          p_params->pq_params[i].vport_id : 0);
                SET_FIELD(tx_pq_map.reg, QM_RF_PQ_MAP_VOQ, voq);
                SET_FIELD(tx_pq_map.reg, QM_RF_PQ_MAP_WRR_WEIGHT_GROUP,
                          p_params->pq_params[i].wrr_group);
                /* Write PQ map entry to CAM */
                STORE_RT_REG(p_hwfn, QM_REG_TXPQMAP_RT_OFFSET + pq_id,
                             *((u32 *)&tx_pq_map));
SET_FIELD manipulates the damn thing as *host-endian* - e.g.
                SET_FIELD(v, QM_RF_PQ_MAP_RL_ID, n)
would expand to v = (v & ~0x1fe) | ((n & 0xff) << 1).  Then we proceed to
pass tx_pq_map.reg (fetched in a bloody convoluted way) to
qed_init_store_rt_reg(), which stores it into p_hwfn->rt_data.init_val[...],
which is apparently host-endian.

So what is this __le32 about?

The really worrying case is this:

/* Binary buffer header */
struct bin_buffer_hdr {
        __le32 offset;
        __le32 length;
};

int qed_init_fw_data(struct qed_dev *cdev, const u8 *data)
{
        struct qed_fw_data *fw = cdev->fw_data;
        struct bin_buffer_hdr *buf_hdr;
        u32 offset, len;

        if (!data) {
                DP_NOTICE(cdev, "Invalid fw data\n");
                return -EINVAL;
        }

        /* First Dword contains metadata and should be skipped */
        buf_hdr = (struct bin_buffer_hdr *)data;

        offset = buf_hdr[BIN_BUF_INIT_FW_VER_INFO].offset;
        fw->fw_ver_info = (struct fw_ver_info *)(data + offset);

        offset = buf_hdr[BIN_BUF_INIT_CMD].offset;
        fw->init_ops = (union init_op *)(data + offset);

We are clearly using those as host-endian here.  Yet in _that_
case fixed-endian would appear to make sense, unless we want
separate firmware images for e.g. amd64 and sparc64 hosts...

Another fun one is struct regpair:
        p_ramrod->qp_handle_for_cqe.hi = cpu_to_le32(qp->qp_handle.hi);
        p_ramrod->qp_handle_for_cqe.lo = cpu_to_le32(qp->qp_handle.lo);
Both sides are struct regpair and by the look of helper macros it *is*
meant to be little-endian.  Here, however, one of those (and not
necessary p_ramrod->qp_handle_for_cqe) is host-endian.

Is that driver intended to be used on big-endian hosts at all?
