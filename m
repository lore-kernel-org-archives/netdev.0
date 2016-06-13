From: Ulrich Hecht <ulrich.hecht@gmail.com>
Subject: Re: [PATCH v6 1/2] can: rcar_canfd: Add Renesas R-Car CAN FD driver
Date: Mon, 13 Jun 2016 10:42:41 +0200
Message-ID: <CAO3366xx0e3TVBL+cps6ye81S_vi6oOGugOOu6FWQr-XBcCx6g@mail.gmail.com>
References: <SG2PR06MB1038056F44EFBCB51674B832C35D0@SG2PR06MB1038.apcprd06.prod.outlook.com>
 <1465367896-60207-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com> <1465367896-60207-2-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: mkl@pengutronix.de, wg@grandegger.com, socketcan@hartkopp.net,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	Chris Paterson <chris.paterson2@renesas.com>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>,
	linux-renesas-soc@vger.kernel.org
To: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:34500 "EHLO
	mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964880AbcFMImn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 04:42:43 -0400
In-Reply-To: <1465367896-60207-2-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the patch, this is a lot easier to handle.

On Wed, Jun 8, 2016 at 8:38 AM, Ramesh Shanmugasundaram
<ramesh.shanmugasundaram@bp.renesas.com> wrote:
[...]
> diff --git a/drivers/net/can/rcar/rcar_canfd.c b/drivers/net/can/rcar/rcar_canfd.c
> new file mode 100644
> index 0000000..9f1f513
> --- /dev/null
> +++ b/drivers/net/can/rcar/rcar_canfd.c
> @@ -0,0 +1,1695 @@
> +/* Renesas R-Car CAN FD device driver
> + *
> + * Copyright (C) 2015 Renesas Electronics Corp.
> + *
> + * This program is free software; you can redistribute  it and/or modify it
> + * under  the terms of  the GNU General  Public License as published by the
> + * Free Software Foundation;  either version 2 of the  License, or (at your
> + * option) any later version.
> + */
> +
> +/* The R-Car CAN FD controller can operate in either one of the below two modes
> + *  - CAN FD only mode
> + *  - Classical CAN (CAN 2.0) only mode
> + *
> + * This driver puts the controller in CAN FD only mode by default. In this
> + * mode, the controller acts as a CAN FD node that can also interoperate with
> + * CAN 2.0 nodes.
> + *
> + * As of now, this driver does not support the Classical CAN (CAN 2.0) mode,
> + * which is handled by a different register map compared to CAN FD only mode.
> + *
> + * Note: The h/w manual register naming convention is clumsy and not acceptable
> + * to use as it is in the driver. However, those names are added as comments
> + * wherever it is modified to a readable name.
> + */
> +
> +#include <linux/module.h>
> +#include <linux/moduleparam.h>
> +#include <linux/kernel.h>
> +#include <linux/types.h>
> +#include <linux/interrupt.h>
> +#include <linux/errno.h>
> +#include <linux/netdevice.h>
> +#include <linux/platform_device.h>
> +#include <linux/can/led.h>
> +#include <linux/can/dev.h>
> +#include <linux/clk.h>
> +#include <linux/of.h>
> +#include <linux/of_device.h>
> +#include <linux/bitmap.h>
> +#include <linux/bitops.h>
> +#include <linux/iopoll.h>
> +
> +#define RCANFD_DRV_NAME                        "rcar_canfd"
> +
> +/* Global register bits */
> +
> +/* RSCFDnCFDGRMCFG */
> +#define RCANFD_GRMCFG_RCMC             BIT(0)
> +
> +/* RSCFDnCFDGCFG */
> +#define RCANFD_GCFG_CMPOC              BIT(5)
> +#define RCANFD_GCFG_DCS                        BIT(4)
> +#define RCANFD_GCFG_DCE                        BIT(1)
> +#define RCANFD_GCFG_TPRI               BIT(0)
> +
> +/* RSCFDnCFDGCTR */
> +#define RCANFD_GCTR_TSRST              BIT(16)
> +#define RCANFD_GCTR_CFMPOFIE           BIT(11)
> +#define RCANFD_GCTR_THLEIE             BIT(10)
> +#define RCANFD_GCTR_MEIE               BIT(9)
> +#define RCANFD_GCTR_DEIE               BIT(8)
> +#define RCANFD_GCTR_GSLPR              BIT(2)
> +#define RCANFD_GCTR_GMDC_MASK          (0x3)
> +#define RCANFD_GCTR_GMDC_GOPM          (0x0)
> +#define RCANFD_GCTR_GMDC_GRESET                (0x1)
> +#define RCANFD_GCTR_GMDC_GTEST         (0x2)
> +
> +/* RSCFDnCFDGSTS */
> +#define RCANFD_GSTS_GRAMINIT           BIT(3)
> +#define RCANFD_GSTS_GSLPSTS            BIT(2)
> +#define RCANFD_GSTS_GHLTSTS            BIT(1)
> +#define RCANFD_GSTS_GRSTSTS            BIT(0)
> +/* Non-operational status */
> +#define RCANFD_GSTS_GNOPM              (BIT(0) | BIT(1) | BIT(2) | BIT(3))
> +
> +/* RSCFDnCFDGERFL */
> +#define RCANFD_GERFL_EEF1              BIT(17)
> +#define RCANFD_GERFL_EEF0              BIT(16)
> +#define RCANFD_GERFL_CMPOF             BIT(3)
> +#define RCANFD_GERFL_THLES             BIT(2)
> +#define RCANFD_GERFL_MES               BIT(1)
> +#define RCANFD_GERFL_DEF               BIT(0)
> +
> +#define RCANFD_GERFL_ERR(x)            ((x) & (RCANFD_GERFL_EEF1 |\
> +                                               RCANFD_GERFL_EEF0 |\
> +                                               RCANFD_GERFL_MES |\
> +                                               RCANFD_GERFL_CMPOF))
> +
> +/* AFL Rx rules registers */
> +
> +/* RSCFDnCFDGAFLCFG0 */
> +#define RCANFD_GAFLCFG_SETRNC(n, x)    (((x) & 0xff) << (24 - n * 8))
> +#define RCANFD_GAFLCFG_GETRNC(n, x)    (((x) >> (24 - n * 8)) & 0xff)
> +
> +/* RSCFDnCFDGAFLECTR */
> +#define RCANFD_GAFLECTR_AFLDAE         BIT(8)
> +#define RCANFD_GAFLECTR_AFLPN(x)       ((x) & 0x1f)
> +
> +/* RSCFDnCFDGAFLIDj */
> +#define RCANFD_GAFLID_GAFLLB           BIT(29)
> +
> +/* RSCFDnCFDGAFLP1_j */
> +#define RCANFD_GAFLP1_GAFLFDP(x)       (1 << (x))
> +
> +/* Channel register bits */
> +
> +/* RSCFDnCFDCmNCFG */
> +#define RCANFD_NCFG_NTSEG2(x)          (((x) & 0x1f) << 24)
> +#define RCANFD_NCFG_NTSEG1(x)          (((x) & 0x7f) << 16)
> +#define RCANFD_NCFG_NSJW(x)            (((x) & 0x1f) << 11)
> +#define RCANFD_NCFG_NBRP(x)            (((x) & 0x3ff) << 0)
> +
> +/* RSCFDnCFDCmCTR */
> +#define RCANFD_CCTR_CTME               BIT(24)
> +#define RCANFD_CCTR_ERRD               BIT(23)
> +#define RCANFD_CCTR_BOM_MASK           (0x3 << 21)
> +#define RCANFD_CCTR_BOM_ISO            (0x0 << 21)
> +#define RCANFD_CCTR_BOM_BENTRY         (0x1 << 21)
> +#define RCANFD_CCTR_BOM_BEND           (0x2 << 21)
> +#define RCANFD_CCTR_TDCVFIE            BIT(19)
> +#define RCANFD_CCTR_SOCOIE             BIT(18)
> +#define RCANFD_CCTR_EOCOIE             BIT(17)
> +#define RCANFD_CCTR_TAIE               BIT(16)
> +#define RCANFD_CCTR_ALIE               BIT(15)
> +#define RCANFD_CCTR_BLIE               BIT(14)
> +#define RCANFD_CCTR_OLIE               BIT(13)
> +#define RCANFD_CCTR_BORIE              BIT(12)
> +#define RCANFD_CCTR_BOEIE              BIT(11)
> +#define RCANFD_CCTR_EPIE               BIT(10)
> +#define RCANFD_CCTR_EWIE               BIT(9)
> +#define RCANFD_CCTR_BEIE               BIT(8)
> +#define RCANFD_CCTR_CSLPR              BIT(2)
> +#define RCANFD_CCTR_CHMDC_MASK         (0x3)
> +#define RCANFD_CCTR_CHDMC_COPM         (0x0)
> +#define RCANFD_CCTR_CHDMC_CRESET       (0x1)
> +#define RCANFD_CCTR_CHDMC_CHLT         (0x2)
> +
> +/* RSCFDnCFDCmSTS */
> +#define RCANFD_CSTS_COMSTS             BIT(7)
> +#define RCANFD_CSTS_RECSTS             BIT(6)
> +#define RCANFD_CSTS_TRMSTS             BIT(5)
> +#define RCANFD_CSTS_BOSTS              BIT(4)
> +#define RCANFD_CSTS_EPSTS              BIT(3)
> +#define RCANFD_CSTS_SLPSTS             BIT(2)
> +#define RCANFD_CSTS_HLTSTS             BIT(1)
> +#define RCANFD_CSTS_CRSTSTS            BIT(0)
> +
> +#define RCANFD_CSTS_TECCNT(x)          (((x) >> 24) & 0xff)
> +#define RCANFD_CSTS_RECCNT(x)          (((x) >> 16) & 0xff)
> +
> +/* RSCFDnCFDCmERFL */
> +#define RCANFD_CERFL_ADERR             BIT(14)
> +#define RCANFD_CERFL_B0ERR             BIT(13)
> +#define RCANFD_CERFL_B1ERR             BIT(12)
> +#define RCANFD_CERFL_CERR              BIT(11)
> +#define RCANFD_CERFL_AERR              BIT(10)
> +#define RCANFD_CERFL_FERR              BIT(9)
> +#define RCANFD_CERFL_SERR              BIT(8)
> +#define RCANFD_CERFL_ALF               BIT(7)
> +#define RCANFD_CERFL_BLF               BIT(6)
> +#define RCANFD_CERFL_OVLF              BIT(5)
> +#define RCANFD_CERFL_BORF              BIT(4)
> +#define RCANFD_CERFL_BOEF              BIT(3)
> +#define RCANFD_CERFL_EPF               BIT(2)
> +#define RCANFD_CERFL_EWF               BIT(1)
> +#define RCANFD_CERFL_BEF               BIT(0)
> +
> +#define RCANFD_CERFL_ERR(x)            ((x) & (0x7fff)) /* above bits 14:0 */
> +
> +/* RSCFDnCFDCmDCFG */
> +#define RCANFD_DCFG_DSJW(x)            (((x) & 0x7) << 24)
> +#define RCANFD_DCFG_DTSEG2(x)          (((x) & 0x7) << 20)
> +#define RCANFD_DCFG_DTSEG1(x)          (((x) & 0xf) << 16)
> +#define RCANFD_DCFG_DBRP(x)            (((x) & 0xff) << 0)
> +
> +/* RSCFDnCFDCmFDCFG */
> +#define RCANFD_FDCFG_TDCE              BIT(9)
> +#define RCANFD_FDCFG_TDCOC             BIT(8)
> +#define RCANFD_FDCFG_TDCO(x)           (((x) & 0x7f) >> 16)
> +
> +/* RSCFDnCFDRFCCx */
> +#define RCANFD_RFCC_RFIM               BIT(12)
> +#define RCANFD_RFCC_RFDC(x)            (((x) & 0x7) << 8)
> +#define RCANFD_RFCC_RFPLS(x)           (((x) & 0x7) << 4)
> +#define RCANFD_RFCC_RFIE               BIT(1)
> +#define RCANFD_RFCC_RFE                        BIT(0)
> +
> +/* RSCFDnCFDRFSTSx */
> +#define RCANFD_RFSTS_RFIF              BIT(3)
> +#define RCANFD_RFSTS_RFMLT             BIT(2)
> +#define RCANFD_RFSTS_RFFLL             BIT(1)
> +#define RCANFD_RFSTS_RFEMP             BIT(0)
> +
> +/* RSCFDnCFDRFIDx */
> +#define RCANFD_RFID_RFIDE              BIT(31)
> +#define RCANFD_RFID_RFRTR              BIT(30)
> +
> +/* RSCFDnCFDRFPTRx */
> +#define RCANFD_RFPTR_RFDLC(x)          (((x) >> 28) & 0xf)
> +#define RCANFD_RFPTR_RFPTR(x)          (((x) >> 16) & 0xfff)
> +#define RCANFD_RFPTR_RFTS(x)           (((x) >> 0) & 0xff)

That should be "(((x) >> 0) & 0xffff)".

> +
> +/* RSCFDnCFDRFFDSTSx */
> +#define RCANFD_RFFDSTS_RFFDF           BIT(2)
> +#define RCANFD_RFFDSTS_RFBRS           BIT(1)
> +#define RCANFD_RFFDSTS_RFESI           BIT(0)
> +
> +/* Common FIFO bits */
> +
> +/* RSCFDnCFDCFCCk */
> +#define RCANFD_CFCC_CFTML(x)           (((x) & 0xf) << 20)
> +#define RCANFD_CFCC_CFM(x)             (((x) & 0x3) << 16)
> +#define RCANFD_CFCC_CFIM               BIT(12)
> +#define RCANFD_CFCC_CFDC(x)            (((x) & 0x7) << 8)
> +#define RCANFD_CFCC_CFPLS(x)           (((x) & 0x7) << 4)
> +#define RCANFD_CFCC_CFTXIE             BIT(2)
> +#define RCANFD_CFCC_CFE                        BIT(0)
> +
> +/* RSCFDnCFDCFSTSk */
> +#define RCANFD_CFSTS_CFMC(x)           (((x) >> 8) & 0xff)
> +#define RCANFD_CFSTS_CFTXIF            BIT(4)
> +#define RCANFD_CFSTS_CFMLT             BIT(2)
> +#define RCANFD_CFSTS_CFFLL             BIT(1)
> +#define RCANFD_CFSTS_CFEMP             BIT(0)
> +
> +/* RSCFDnCFDCFIDk */
> +#define RCANFD_CFID_CFIDE              BIT(31)
> +#define RCANFD_CFID_CFRTR              BIT(30)
> +#define RCANFD_CFID_CFID_MASK(x)       ((x) & 0x1fffffff)
> +
> +/* RSCFDnCFDCFPTRk */
> +#define RCANFD_CFPTR_CFDLC(x)          (((x) & 0xf) << 28)
> +#define RCANFD_CFPTR_CFPTR(x)          (((x) & 0xfff) << 16)
> +#define RCANFD_CFPTR_CFTS(x)           (((x) & 0xff) << 0)
> +
> +/* RSCFDnCFDCFFDCSTSk */
> +#define RCANFD_CFFDCSTS_CFFDF          BIT(2)
> +#define RCANFD_CFFDCSTS_CFBRS          BIT(1)
> +#define RCANFD_CFFDCSTS_CFESI          BIT(0)
> +
> +/* This controller supports classical CAN only mode or CAN FD only mode. These
> + * modes are supported in two separate set of register maps & names. However,
> + * some of the register offsets are common for both modes. Those offsets are
> + * listed below as Common registers.
> + *
> + * The CAN FD only specific registers are listed separately and their names
> + * starts with RCANFD_F_xxx names. When classical CAN only specific registers
> + * are added, those specific registers can be prefixed as RCANFD_C_xxx.
> + */
> +
> +/* Common registers */
> +
> +/* RSCFDnCFDCmNCFG / RSCFDnCmCFG */
> +#define RCANFD_CCFG(m)                 (0x0000 + (0x10 * (m)))
> +/* RSCFDnCFDCmCTR / RSCFDnCmCTR */
> +#define RCANFD_CCTR(m)                 (0x0004 + (0x10 * (m)))
> +/* RSCFDnCFDCmSTS / RSCFDnCmSTS */
> +#define RCANFD_CSTS(m)                 (0x0008 + (0x10 * (m)))
> +/* RSCFDnCFDCmERFL / RSCFDnCmERFL */
> +#define RCANFD_CERFL(m)                        (0x000C + (0x10 * (m)))
> +
> +/* RSCFDnCFDGCFG / RSCFDnGCFG */
> +#define RCANFD_GCFG                    (0x0084)
> +/* RSCFDnCFDGCTR / RSCFDnGCTR */
> +#define RCANFD_GCTR                    (0x0088)
> +/* RSCFDnCFDGCTS / RSCFDnGCTS */
> +#define RCANFD_GSTS                    (0x008c)
> +/* RSCFDnCFDGERFL / RSCFDnGERFL */
> +#define RCANFD_GERFL                   (0x0090)
> +/* RSCFDnCFDGTSC / RSCFDnGTSC */
> +#define RCANFD_GTSC                    (0x0094)
> +/* RSCFDnCFDGAFLECTR / RSCFDnGAFLECTR */
> +#define RCANFD_GAFLECTR                        (0x0098)
> +/* RSCFDnCFDGAFLCFG0 / RSCFDnGAFLCFG0 */
> +#define RCANFD_GAFLCFG0                        (0x009c)
> +/* RSCFDnCFDGAFLCFG1 / RSCFDnGAFLCFG1 */
> +#define RCANFD_GAFLCFG1                        (0x00a0)
> +/* RSCFDnCFDRMNB / RSCFDnRMNB */
> +#define RCANFD_RMNB                    (0x00a4)
> +/* RSCFDnCFDRMND / RSCFDnRMND */
> +#define RCANFD_RMND(y)                 (0x00a8 + (0x04 * (y)))
> +
> +/* RSCFDnCFDRFCCx / RSCFDnRFCCx */
> +#define RCANFD_RFCC(x)                 (0x00b8 + (0x04 * (x)))
> +/* RSCFDnCFDRFSTSx / RSCFDnRFSTSx */
> +#define RCANFD_RFSTS(x)                        (0x00d8 + (0x04 * (x)))
> +/* RSCFDnCFDRFPCTRx / RSCFDnRFPCTRx */
> +#define RCANFD_RFPCTR(x)               (0x00f8 + (0x04 * (x)))
> +
> +/* Common FIFO Control registers */
> +
> +/* RSCFDnCFDCFCCx / RSCFDnCFCCx */
> +#define RCANFD_CFCC(ch, idx)           (0x0118 + (0x0c * (ch)) + \
> +                                        (0x04 * (idx)))
> +/* RSCFDnCFDCFSTSx / RSCFDnCFSTSx */
> +#define RCANFD_CFSTS(ch, idx)          (0x0178 + (0x0c * (ch)) + \
> +                                        (0x04 * (idx)))
> +/* RSCFDnCFDCFPCTRx / RSCFDnCFPCTRx */
> +#define RCANFD_CFPCTR(ch, idx)         (0x01d8 + (0x0c * (ch)) + \
> +                                        (0x04 * (idx)))
> +
> +/* RSCFDnCFDFESTS / RSCFDnFESTS */
> +#define RCANFD_FESTS                   (0x0238)
> +/* RSCFDnCFDFFSTS / RSCFDnFFSTS */
> +#define RCANFD_FFSTS                   (0x023c)
> +/* RSCFDnCFDFMSTS / RSCFDnFMSTS */
> +#define RCANFD_FMSTS                   (0x0240)
> +/* RSCFDnCFDRFISTS / RSCFDnRFISTS */
> +#define RCANFD_RFISTS                  (0x0244)
> +/* RSCFDnCFDCFRISTS / RSCFDnCFRISTS */
> +#define RCANFD_CFRISTS                 (0x0248)
> +/* RSCFDnCFDCFTISTS / RSCFDnCFTISTS */
> +#define RCANFD_CFTISTS                 (0x024c)
> +
> +/* RSCFDnCFDTMCp / RSCFDnTMCp */
> +#define RCANFD_TMC(p)                  (0x0250 + (0x01 * (p)))
> +/* RSCFDnCFDTMSTSp / RSCFDnTMSTSp */
> +#define RCANFD_TMSTS(p)                        (0x02d0 + (0x01 * (p)))
> +
> +/* RSCFDnCFDTMTRSTSp / RSCFDnTMTRSTSp */
> +#define RCANFD_TMTRSTS(y)              (0x0350 + (0x04 * (y)))
> +/* RSCFDnCFDTMTARSTSp / RSCFDnTMTARSTSp */
> +#define RCANFD_TMTARSTS(y)             (0x0360 + (0x04 * (y)))
> +/* RSCFDnCFDTMTCSTSp / RSCFDnTMTCSTSp */
> +#define RCANFD_TMTCSTS(y)              (0x0370 + (0x04 * (y)))
> +/* RSCFDnCFDTMTASTSp / RSCFDnTMTASTSp */
> +#define RCANFD_TMTASTS(y)              (0x0380 + (0x04 * (y)))
> +/* RSCFDnCFDTMIECy / RSCFDnTMIECy */
> +#define RCANFD_TMIEC(y)                        (0x0390 + (0x04 * (y)))
> +
> +/* RSCFDnCFDTXQCCm / RSCFDnTXQCCm */
> +#define RCANFD_TXQCC(m)                        (0x03a0 + (0x04 * (m)))
> +/* RSCFDnCFDTXQSTSm / RSCFDnTXQSTSm */
> +#define RCANFD_TXQSTS(m)               (0x03c0 + (0x04 * (m)))
> +/* RSCFDnCFDTXQPCTRm / RSCFDnTXQPCTRm */
> +#define RCANFD_TXQPCTR(m)              (0x03e0 + (0x04 * (m)))
> +
> +/* RSCFDnCFDTHLCCm / RSCFDnTHLCCm */
> +#define RCANFD_THLCC(m)                        (0x0400 + (0x04 * (m)))
> +/* RSCFDnCFDTHLSTSm / RSCFDnTHLSTSm */
> +#define RCANFD_THLSTS(m)               (0x0420 + (0x04 * (m)))
> +/* RSCFDnCFDTHLPCTRm / RSCFDnTHLPCTRm */
> +#define RCANFD_THLPCTR(m)              (0x0440 + (0x04 * (m)))
> +
> +/* RSCFDnCFDGTINTSTS0 / RSCFDnGTINTSTS0 */
> +#define RCANFD_GTINTSTS0               (0x0460)
> +/* RSCFDnCFDGTINTSTS1 / RSCFDnGTINTSTS1 */
> +#define RCANFD_GTINTSTS1               (0x0464)
> +/* RSCFDnCFDGTSTCFG / RSCFDnGTSTCFG */
> +#define RCANFD_GTSTCFG                 (0x0468)
> +/* RSCFDnCFDGTSTCTR / RSCFDnGTSTCTR */
> +#define RCANFD_GTSTCTR                 (0x046c)
> +/* RSCFDnCFDGLOCKK / RSCFDnGLOCKK */
> +#define RCANFD_GLOCKK                  (0x047c)
> +/* RSCFDnCFDGRMCFG / RSCFDnGRMCFG */
> +#define RCANFD_GRMCFG                  (0x04fc)
> +
> +/* RSCFDnCFDGAFLIDj / RSCFDnGAFLIDj */
> +#define RCANFD_GAFLID(offset, j)       ((offset) + (0x10 * (j)))
> +/* RSCFDnCFDGAFLMj / RSCFDnGAFLMj */
> +#define RCANFD_GAFLM(offset, j)                ((offset) + 0x04 + (0x10 * (j)))
> +/* RSCFDnCFDGAFLP0j / RSCFDnGAFLP0j */
> +#define RCANFD_GAFLP0(offset, j)       ((offset) + 0x08 + (0x10 * (j)))
> +/* RSCFDnCFDGAFLP1j / RSCFDnGAFLP1j */
> +#define RCANFD_GAFLP1(offset, j)       ((offset) + 0x0c + (0x10 * (j)))
> +
> +/* CAN FD mode specific regsiter map */
> +
> +/* RSCFDnCFDCmXXX -> RCANFD_F_XXX(m) */
> +#define RCANFD_F_DCFG(m)               (0x0500 + (0x20 * (m)))
> +#define RCANFD_F_CFDCFG(m)             (0x0504 + (0x20 * (m)))
> +#define RCANFD_F_CFDCTR(m)             (0x0508 + (0x20 * (m)))
> +#define RCANFD_F_CFDSTS(m)             (0x050c + (0x20 * (m)))
> +#define RCANFD_F_CFDCRC(m)             (0x0510 + (0x20 * (m)))
> +
> +/* RSCFDnCFDGAFLXXXj offset */
> +#define RCANFD_F_GAFL_OFFSET           (0x1000)
> +
> +/* RSCFDnCFDRMXXXq -> RCANFD_F_RMXXX(q) */
> +#define RCANFD_F_RMID(q)               (0x2000 + (0x10 * (q)))
> +#define RCANFD_F_RMPTR(q)              (0x2004 + (0x10 * (q)))
> +#define RCANFD_F_RMFDSTS(q)            (0x2008 + (0x10 * (q)))

These should all be "+ (0x20 * (q))".

> +#define RCANFD_F_RMDF(q, b)            (0x200c + (0x04 * (b)) + (0x20 * (q)))
> +
> +/* RSCFDnCFDRFXXx -> RCANFD_F_RFXX(x) */
> +#define RCANFD_F_RFOFFSET              (0x3000)
> +#define RCANFD_F_RFID(x)               (RCANFD_F_RFOFFSET + (0x80 * (x)))
> +#define RCANFD_F_RFPTR(x)              (RCANFD_F_RFOFFSET + 0x04 + \
> +                                        (0x80 * (x)))
> +#define RCANFD_F_RFFDSTS(x)            (RCANFD_F_RFOFFSET + 0x08 + \
> +                                        (0x80 * (x)))
> +#define RCANFD_F_RFDF(x, df)           (RCANFD_F_RFOFFSET + 0x0c + \
> +                                        (0x80 * (x)) + (0x04 * (df)))
> +
> +/* RSCFDnCFDCFXXk -> RCANFD_F_CFXX(ch, k) */
> +#define RCANFD_F_CFOFFSET              (0x3400)
> +#define RCANFD_F_CFID(ch, idx)         (RCANFD_F_CFOFFSET + (0x180 * (ch)) + \
> +                                        (0x80 * (idx)))
> +#define RCANFD_F_CFPTR(ch, idx)                (RCANFD_F_CFOFFSET + 0x04 + \
> +                                        (0x180 * (ch)) + (0x80 * (idx)))
> +#define RCANFD_F_CFFDCSTS(ch, idx)     (RCANFD_F_CFOFFSET + 0x08 + \
> +                                        (0x180 * (ch)) + (0x80 * (idx)))
> +#define RCANFD_F_CFDF(ch, idx, df)     (RCANFD_F_CFOFFSET + 0x0c + \
> +                                        (0x180 * (ch)) + (0x80 * (idx)) + \
> +                                        (0x04 * (df)))
> +
> +/* RSCFDnCFDTMXXp -> RCANFD_F_TMXX(p) */
> +#define RCANFD_F_TMID(p)               (0x4000 + (0x20 * (p)))
> +#define RCANFD_F_TMPTR(p)              (0x4004 + (0x20 * (p)))
> +#define RCANFD_F_TMFDCTR(p)            (0x4008 + (0x20 * (p)))
> +#define RCANFD_F_TMDF(p, b)            (0x400c + (0x20 * (p)) + (0x04 * (b)))
> +
> +/* RSCFDnCFDTHLACCm */
> +#define RCANFD_F_THLACC(m)             (0x6000 + (0x04 * (m)))
> +/* RSCFDnCFDRPGACCr */
> +#define RCANFD_F_RPGACC(r)             (0x6400 + (0x04 * (r)))
[...]

Apart from that, all register addresses, offsets, bit positions and
masks check out. With the two issues fixed:

Reviewed-by: Ulrich Hecht <ulrich.hecht+renesas@gmail.com>

CU
Uli
