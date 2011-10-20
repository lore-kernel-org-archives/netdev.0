From: "Felix Marti" <felix@chelsio.com>
Subject: RE: [PATCH V2 02/10] cxgb4: Common platform specific changes for DB Drop Recovery
Date: Thu, 20 Oct 2011 10:18:44 -0700
Message-ID: <8A71B368A89016469F72CD08050AD3340A3D3120@maui.asicdesigners.com>
References: <1319130620-9240-1-git-send-email-vipul@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <roland@purestorage.com>, <davem@davemloft.net>,
	"Divy Le Ray" <divy@chelsio.com>,
	"Dimitrios Michailidis" <dm@chelsio.com>,
	"Kumar A S" <kumaras@chelsio.com>,
	"Steve Wise" <swise@opengridcomputing.com>,
	"Vipul Pandya" <vipul@chelsio.com>
To: "Vipul Pandya" <vipul@chelsio.com>, <linux-rdma@vger.kernel.org>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:29651 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755177Ab1JTRSt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 13:18:49 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't add stuff to the t4fw_interface.h, that is owned by firmware.

> -----Original Message-----
> From: linux-rdma-owner@vger.kernel.org [mailto:linux-rdma-
> owner@vger.kernel.org] On Behalf Of Vipul Pandya
> Sent: Thursday, October 20, 2011 10:10 AM
> To: linux-rdma@vger.kernel.org; netdev@vger.kernel.org
> Cc: roland@purestorage.com; davem@davemloft.net; Divy Le Ray;
Dimitrios
> Michailidis; Kumar A S; Steve Wise; Vipul Pandya
> Subject: [PATCH V2 02/10] cxgb4: Common platform specific changes for
DB
> Drop Recovery
> 
>     - Add platform-specific callback functions for interrupts.  This
is
>     needed to do a single read-clear of the CAUSE register and then
call
>     out to platform specific functions for DB threshold interrupts and
DB
>     drop interrupts.
> 
>     - Add t4_mem_win_read_len() - mem-window reads for arbitrary
lengths.
>     This is used to read the CIDX/PIDX values from EC contexts during
DB
>     drop recovery.
> 
>     - Add t4_fwaddrspace_write() - sends addrspace write cmds to the
fw.
>     Needed to flush the sge eq context cache.
> 
> Signed-off-by: Vipul Pandya <vipul@chelsio.com>
> Signed-off-by: Steve Wise <swise@opengridcomputing.com>
> ---
> Changes:
> V2: Corrected the subject for patch.
> 
>  drivers/net/ethernet/chelsio/cxgb4/t4_hw.c    |   69
> +++++++++++++++++++++----
>  drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h |    5 ++
>  2 files changed, 63 insertions(+), 11 deletions(-)
> 
> diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
> b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
> index 13609bf..32e1dd5 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
> +++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
> @@ -868,11 +868,14 @@ int t4_restart_aneg(struct adapter *adap,
unsigned
> int mbox, unsigned int port)
>  	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);  }
> 
> +typedef void (*int_handler_t)(struct adapter *adap);
> +
>  struct intr_info {
>  	unsigned int mask;       /* bits to check in interrupt status */
>  	const char *msg;         /* message to print or NULL */
>  	short stat_idx;          /* stat counter to increment or -1 */
>  	unsigned short fatal;    /* whether the condition reported is
fatal */
> +	int_handler_t int_handler; /* platform-specific int handler */
>  };
> 
>  /**
> @@ -905,6 +908,8 @@ static int t4_handle_intr_status(struct adapter
> *adapter, unsigned int reg,
>  		} else if (acts->msg && printk_ratelimit())
>  			dev_warn(adapter->pdev_dev, "%s (0x%x)\n", acts-
> >msg,
>  				 status & acts->mask);
> +		if (acts->int_handler)
> +			acts->int_handler(adapter);
>  		mask |= acts->mask;
>  	}
>  	status &= mask;
> @@ -1013,9 +1018,9 @@ static void sge_intr_handler(struct adapter
> *adapter)
>  		{ ERR_INVALID_CIDX_INC,
>  		  "SGE GTS CIDX increment too large", -1, 0 },
>  		{ ERR_CPL_OPCODE_0, "SGE received 0-length CPL", -1, 0
},
> -		{ F_DBFIFO_LP_INT, NULL, -1, 0 },
> -		{ F_DBFIFO_HP_INT, NULL, -1, 0 },
> -		{ ERR_DROPPED_DB, "SGE doorbell dropped", -1, 0 },
> +		{ F_DBFIFO_LP_INT, NULL, -1, 0, t4_db_full },
> +		{ F_DBFIFO_HP_INT, NULL, -1, 0, t4_db_full },
> +		{ F_ERR_DROPPED_DB, NULL, -1, 0, t4_db_dropped },
>  		{ ERR_DATA_CPL_ON_HIGH_QID1 |
> ERR_DATA_CPL_ON_HIGH_QID0,
>  		  "SGE IQID > 1023 received CPL for FL", -1, 0 },
>  		{ ERR_BAD_DB_PIDX3, "SGE DBP 3 pidx increment too
large",
> -1, @@ -1036,20 +1041,14 @@ static void sge_intr_handler(struct
adapter
> *adapter)
>  	};
> 
>  	v = (u64)t4_read_reg(adapter, SGE_INT_CAUSE1) |
> -	    ((u64)t4_read_reg(adapter, SGE_INT_CAUSE2) << 32);
> +		((u64)t4_read_reg(adapter, SGE_INT_CAUSE2) << 32);
>  	if (v) {
>  		dev_alert(adapter->pdev_dev, "SGE parity error
(%#llx)\n",
> -			 (unsigned long long)v);
> +				(unsigned long long)v);
>  		t4_write_reg(adapter, SGE_INT_CAUSE1, v);
>  		t4_write_reg(adapter, SGE_INT_CAUSE2, v >> 32);
>  	}
> 
> -	err = t4_read_reg(adapter, A_SGE_INT_CAUSE3);
> -	if (err & (F_DBFIFO_HP_INT|F_DBFIFO_LP_INT))
> -		t4_db_full(adapter);
> -	if (err & F_ERR_DROPPED_DB)
> -		t4_db_dropped(adapter);
> -
>  	if (t4_handle_intr_status(adapter, SGE_INT_CAUSE3,
sge_intr_info)
> ||
>  	    v != 0)
>  		t4_fatal_err(adapter);
> @@ -1995,6 +1994,54 @@ int t4_wol_pat_enable(struct adapter *adap,
> unsigned int port, unsigned int map,
>  	(var).retval_len16 = htonl(FW_LEN16(var)); \  } while (0)
> 
> +int t4_fwaddrspace_write(struct adapter *adap, unsigned int mbox,
> +			  u32 addr, u32 val)
> +{
> +	struct fw_ldst_cmd c;
> +
> +	memset(&c, 0, sizeof(c));
> +	c.op_to_addrspace = htonl(V_FW_CMD_OP(FW_LDST_CMD) |
> F_FW_CMD_REQUEST |
> +			    F_FW_CMD_WRITE |
> +
> V_FW_LDST_CMD_ADDRSPACE(FW_LDST_ADDRSPC_FIRMWARE));
> +	c.cycles_to_len16 = htonl(FW_LEN16(c));
> +	c.u.addrval.addr = htonl(addr);
> +	c.u.addrval.val = htonl(val);
> +
> +	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL); }
> +
> +/*
> + *     t4_mem_win_read_len - read memory through PCIE memory window
> + *     @adap: the adapter
> + *     @addr: address of first byte requested aligned on 32b.
> + *     @data: len bytes to hold the data read
> + *     @len: amount of data to read from window.  Must be <=
> + *            MEMWIN0_APERATURE after adjusting for 16B alignment
> + *            requirements of the the memory window.
> + *
> + *     Read len bytes of data from MC starting at @addr.
> + */
> +int t4_mem_win_read_len(struct adapter *adap, u32 addr, __be32 *data,
> +int len) {
> +	int i;
> +	int off;
> +
> +	/*
> +	 * Align on a 16B boundary.
> +	 */
> +	off = addr & 15;
> +	if ((addr & 3) || (len + off) > MEMWIN0_APERTURE)
> +		return -EINVAL;
> +
> +	t4_write_reg(adap, A_PCIE_MEM_ACCESS_OFFSET, addr & ~15);
> +	t4_read_reg(adap, A_PCIE_MEM_ACCESS_OFFSET);
> +
> +	for (i = 0; i < len; i += 4)
> +		*data++ = t4_read_reg(adap, (MEMWIN0_BASE + off + i));
> +
> +	return 0;
> +}
> +
>  /**
>   *	t4_mdio_rd - read a PHY register through MDIO
>   *	@adap: the adapter
> diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
> b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
> index edcfd7e..83ca454 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
> +++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
> @@ -1620,4 +1620,9 @@ struct fw_hdr {
>  #define FW_HDR_FW_VER_MINOR_GET(x) (((x) >> 16) & 0xff)  #define
> FW_HDR_FW_VER_MICRO_GET(x) (((x) >> 8) & 0xff)  #define
> FW_HDR_FW_VER_BUILD_GET(x) (((x) >> 0) & 0xff)
> +
> +int t4_mem_win_read_len(struct adapter *adap, u32 addr, __be32 *data,
> +int len); int t4_fwaddrspace_write(struct adapter *adap, unsigned int
> mbox,
> +			  u32 addr, u32 val);
> +
>  #endif /* _T4FW_INTERFACE_H_ */
> --
> 1.7.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma"
in the
> body of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html
