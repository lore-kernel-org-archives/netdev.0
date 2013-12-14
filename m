From: Joe Perches <joe@perches.com>
Subject: Re: bnx2x_sriov.c: Missing switch/case breaks?
Date: Fri, 13 Dec 2013 22:57:47 -0800
Message-ID: <1387004267.2276.7.camel@joe-AO722>
References: <1386975703.2479.48.camel@joe-AO722>
	 <979A8436335E3744ADCD3A9F2A2B68A52AF1A735@SJEXCHMB10.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ariel Elior <ariele@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <979A8436335E3744ADCD3A9F2A2B68A52AF1A735@SJEXCHMB10.corp.ad.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2013-12-14 at 06:16 +0000, Yuval Mintz wrote:
> > Hi Ariel.
> > 
> > I wrote a little checkpatch script to look for missing
> > switch/case breaks.
> > 
> > http://www.kernelhub.org/?msg=379933&p=2
> > 
> > There are _many_ instances of case blocks in sriov.c
> > that could be missing breaks as they use fall-throughs.
> > 
> > It would be good if these are actually intended to be
> > fall-throughs to add a /* fall-through */ comment between
> > each case block.
> > 
> > For instance:
> > 
> > static void bnx2x_vfop_qctor(struct bnx2x *bp, struct bnx2x_virtf *vf)
> > {
> > [...]
> > 	switch (state) {
> > 	case BNX2X_VFOP_QCTOR_INIT:
> > 
> > 		/* has this queue already been opened? */
> > 		if (bnx2x_get_q_logical_state(bp, q_params->q_obj) ==
> > 		    BNX2X_Q_LOGICAL_STATE_ACTIVE) {
> > 			DP(BNX2X_MSG_IOV,
> > 			   "Entered qctor but queue was already up. Aborting
> > gracefully\n");
> > 			goto op_done;
> > 		}
> > 
> > 		/* next state */
> > 		vfop->state = BNX2X_VFOP_QCTOR_SETUP;
> > 
> > 		q_params->cmd = BNX2X_Q_CMD_INIT;
> > 		vfop->rc = bnx2x_queue_state_change(bp, q_params);
> > 
> > 		bnx2x_vfop_finalize(vf, vfop->rc, VFOP_CONT); 
> 
> Hi Joe,

Hi Yuval.

> The `vfop' part of the code contains a lot of usage of the `bnx2x_vfop_finalize()',
> which either goto or return at the end of almost every case.
> "Normal" analysis tools/scripts fail to recognize them as  valid case breaks.
> 
> Adding `fallthrough' comments would make little sense, as this is not the real
> behavior; Perhaps we need some alternative comment? (something in the line
> of `macro case break')

No idea.  It's certainly an ugly macro.

This does have a fallthrough path though when
(rc == 0  && next == VFOP_VERIFY_PEND) so
maybe there should be a break after most all
uses of this macro anyway.  When next is
VFOP_VERIFY_PEND, then a "fall-through" comment
would be appropriate.

cheers, Joe

drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h:#define bnx2x_vfop_finalize(vf, rc, next) do {                                \
drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h-              if ((rc) < 0)                                           \
drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h-                      goto op_err;                                    \
drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h-              else if ((rc) > 0)                                      \
drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h-                      goto op_pending;                                \
drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h-              else if ((next) == VFOP_DONE)                           \
drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h-                      goto op_done;                                   \
drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h-              else if ((next) == VFOP_VERIFY_PEND)                    \
drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h-                      BNX2X_ERR("expected pending\n");                \
drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h-              else {                                                  \
drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h-                      DP(BNX2X_MSG_IOV, "no ramrod. Scheduling\n");   \
drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h-                      atomic_set(&vf->op_in_progress, 1);             \
drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h-                      queue_delayed_work(bnx2x_wq, &bp->sp_task, 0);  \
drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h-                      return;                                         \
drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h-              }                                                       \
drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h-      } while (0)
drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h-
