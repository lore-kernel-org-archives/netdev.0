From: Casey Leedom <leedom@chelsio.com>
Subject: Re: Updating net-next, infiniband & scsi tree simultaneously
Date: Mon, 14 Jul 2014 14:30:18 -0700
Message-ID: <53C44BEA.1040909@chelsio.com>
References: <1405367731-8908-1-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, michaelc@cs.wisc.edu,
	JBottomley@Parallels.com, kxie@chelsio.com, hariprasad@chelsio.com,
	swise@opengridcomputing.com
To: Anish Bhatt <anish@chelsio.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:33149
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756878AbaGNVcF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 17:32:05 -0400
In-Reply-To: <1405367731-8908-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

   (woof) I was just about to provide a specific diff so people could 
see what the proposed change was but now I see that this has yet again 
been complicated by the symbolic constant renaming which was forced on 
us when cxgb4 was originally submitted.

   The constants in play are like the following from 
drivers/infiniband/hw/cxgb4/t4fw_ri_api.h:

enum {                     /* TCP congestion control algorithms */
         CONG_ALG_RENO,
         CONG_ALG_TAHOE,
         CONG_ALG_NEWRENO,
         CONG_ALG_HIGHSPEED
};

#define S_CONG_CNTRL    14
#define M_CONG_CNTRL    0x3
#define V_CONG_CNTRL(x) ((x) << S_CONG_CNTRL)
#define G_CONG_CNTRL(x) (((x) >> S_CONG_CNTRL) & M_CONG_CNTRL)

#define CONG_CNTRL_VALID   (1 << 18)
#define T5_OPT_2_VALID       (1 << 31)

These would be moved to drivers/net/ethernet/chelsio/cxgb4/t4_msg.h 
which is the core header file defining the format of messages to the 
chip.  However, in that file we have the new symbolic constants like:

struct cpl_pass_accept_rpl {
         WR_HDR;
         union opcode_tid ot;
         __be32 opt2;
#define RSS_QUEUE(x)         ((x) << 0)
#define RSS_QUEUE_VALID      (1 << 10)
#define RX_COALESCE_VALID(x) ((x) << 11)
#define RX_COALESCE(x)       ((x) << 12)
#define PACE(x)       ((x) << 16)
#define TX_QUEUE(x)          ((x) << 23)
#define RX_CHANNEL(x)        ((x) << 26)
#define CCTRL_ECN(x)         ((x) << 27)
#define WND_SCALE_EN(x)      ((x) << 28)
#define TSTAMPS_EN(x)        ((x) << 29)
#define SACK_EN(x)           ((x) << 30)
         __be64 opt0;
};

So simply moving the definitions across would result in a confusing 
style mish-mash. (sigh)  So if we're going to follow the existing 
different style in t4_msg.h, we'd actually need a somewhat more complex 
patch looking something like the following:

diff --git a/drivers/infiniband/hw/cxgb4/cm.c 
b/drivers/infiniband/hw/cxgb4/cm.c
index 5e153f6..5e73afa 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -656,7 +656,7 @@ static int send_connect(struct c4iw_ep *ep)
                 opt2 |= WND_SCALE_EN(1);
         if (is_t5(ep->com.dev->rdev.lldi.adapter_type)) {
                 opt2 |= T5_OPT_2_VALID;
-               opt2 |= V_CONG_CNTRL(CONG_ALG_TAHOE);
+               opt2 |= CONG_CNTRL(CONG_ALG_TAHOE);
         }
         t4_set_arp_err_handler(skb, NULL, act_open_req_arp_failure);

@@ -2156,7 +2156,7 @@ static void accept_cr(struct c4iw_ep *ep, struct 
sk_buff *skb,
         if (is_t5(ep->com.dev->rdev.lldi.adapter_type)) {
                 u32 isn = (prandom_u32() & ~7UL) - 1;
                 opt2 |= T5_OPT_2_VALID;
-               opt2 |= V_CONG_CNTRL(CONG_ALG_TAHOE);
+               opt2 |= CONG_CNTRL(CONG_ALG_TAHOE);
                 opt2 |= CONG_CNTRL_VALID; /* OPT_2_ISS for T5 */
                 rpl5 = (void *)rpl;
                 memset(&rpl5->iss, 0, 
roundup(sizeof(*rpl5)-sizeof(*rpl), 16));
diff --git a/drivers/infiniband/hw/cxgb4/t4fw_ri_api.h 
b/drivers/infiniband/hw/cxgb4/t4fw_ri_api.h
index 91289a0..dc193c2 100644
--- a/drivers/infiniband/hw/cxgb4/t4fw_ri_api.h
+++ b/drivers/infiniband/hw/cxgb4/t4fw_ri_api.h
@@ -836,19 +836,4 @@ struct ulptx_idata {
  #define V_RX_DACK_CHANGE(x) ((x) << S_RX_DACK_CHANGE)
  #define F_RX_DACK_CHANGE    V_RX_DACK_CHANGE(1U)

-enum {                     /* TCP congestion control algorithms */
-       CONG_ALG_RENO,
-       CONG_ALG_TAHOE,
-       CONG_ALG_NEWRENO,
-       CONG_ALG_HIGHSPEED
-};
-
-#define S_CONG_CNTRL    14
-#define M_CONG_CNTRL    0x3
-#define V_CONG_CNTRL(x) ((x) << S_CONG_CNTRL)
-#define G_CONG_CNTRL(x) (((x) >> S_CONG_CNTRL) & M_CONG_CNTRL)
-
-#define CONG_CNTRL_VALID   (1 << 18)
-#define T5_OPT_2_VALID       (1 << 31)
-
  #endif /* _T4FW_RI_API_H_ */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h 
b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
index 973eb11..6cf9d92 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
@@ -261,6 +261,13 @@ struct cpl_pass_open_rpl {
         u8 status;
  };

+enum {                     /* TCP congestion control algorithms */
+       CONG_ALG_RENO,
+       CONG_ALG_TAHOE,
+       CONG_ALG_NEWRENO,
+       CONG_ALG_HIGHSPEED
+};
+
  struct cpl_pass_accept_rpl {
         WR_HDR;
         union opcode_tid ot;
@@ -269,13 +276,16 @@ struct cpl_pass_accept_rpl {
  #define RSS_QUEUE_VALID      (1 << 10)
  #define RX_COALESCE_VALID(x) ((x) << 11)
  #define RX_COALESCE(x)       ((x) << 12)
+#define CONG_CNTRL(x)        ((x) << 14)
  #define PACE(x)              ((x) << 16)
+#define CONG_CNTRL_VALID     (1 << 18)
  #define TX_QUEUE(x)          ((x) << 23)
  #define RX_CHANNEL(x)        ((x) << 26)
  #define CCTRL_ECN(x)         ((x) << 27)
  #define WND_SCALE_EN(x)      ((x) << 28)
  #define TSTAMPS_EN(x)        ((x) << 29)
  #define SACK_EN(x)           ((x) << 30)
+#define T5_OPT_2_VALID       (1 << 31)
         __be64 opt0;
  };

And note that there are other constants in t4fw_ri_api.h which should 
have been checked into t4_msg.h.

   However, the only one which Anish needs immediately is T5_OPT_2_VALID 
and that _could_ be moved over without any other change.  So maybe the 
most conservative line of attack would be to move that and figure out 
what we're going to do with the rest later. (double sigh)

Casey


On 07/14/14 12:55, Anish Bhatt wrote:
> Hi Dave/Roland/Mike/James,
>        I have an update to the cxgb4i(iscsi) driver that needs a change in the cxgb4 driver as well. To prevent code duplication, I'll be moving a few defines from the inifiniband(iw_cxgb4) driver to the cxgb4 which both cxgb4i & iw_cxgb4 rely on. What is the correct way to submit this changeset ? Submitting separate changesets to separate trees might break compilation in respective trees.
> Thanks,
> Anish
>
