From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] qed: fix qed_fill_link() error handling
Date: Wed, 01 Jun 2016 00:34:20 +0200
Message-ID: <5288285.fZuaAytaxX@wuerfel>
References: <1464623197-2084229-1-git-send-email-arnd@arndb.de> <CO2PR11MB00881A57063B9AB617359A9097450@CO2PR11MB0088.namprd11.prod.outlook.com> <20160531.142046.2026659803711147043.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Yuval.Mintz@qlogic.com, manish.chopra@qlogic.com,
	Sudarsana.Kalluru@qlogic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Ariel.Elior@qlogic.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160531.142046.2026659803711147043.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday, May 31, 2016 2:20:46 PM CEST David Miller wrote:
> From: Yuval Mintz <Yuval.Mintz@qlogic.com>
> Date: Mon, 30 May 2016 16:24:07 +0000
> 
> >> +    if (IS_ENABLED(CONFIG_QED_SRIOV) && !IS_PF(hwfn->cdev)) {
> >> +            qed_vf_get_link_params(hwfn, params);
> >> +            qed_vf_get_link_state(hwfn, link);
> >> +            qed_vf_get_link_caps(hwfn, link_caps);
> >> +
> >> +            return 0;
> >> +    }
> > 
> > The IS_ENABLED here seems a bit wasteful to me - we have empty implementation
> > under qed_vf.h just for this case [I.e., that SRIOV isn't enabled for qed].
> > If all we're trying achieve is removing these gcc warnings, I think we can simply
> > memset the structs in the currently-empty qed_vf_get_link_* functions.

Adding a memset() to those functions would add a bit of overhead in code size
because that ends up being unused in practice without a way for the compiler
to know, I added the IS_ENABLED() check to reduce the object code size here
by also eliminating the check for IS_PF().

> I think both solutions are equally valid/elegant.
> 
> Arnd?

I think we can just remove the IS_ENABLED() check there and define the
IS_PF() macro conditionally to become 'true' if CONFIG_QED_SRIOV is not
set, like some other drivers do

diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index 287f61c20c19..756176525cf9 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -1110,7 +1110,7 @@ static int qed_get_link_data(struct qed_hwfn *hwfn,
 {
 	void *p;
 
-	if (IS_ENABLED(CONFIG_QED_SRIOV) && !IS_PF(hwfn->cdev)) {
+	if (!IS_PF(hwfn->cdev)) {
 		qed_vf_get_link_params(hwfn, params);
 		qed_vf_get_link_state(hwfn, link);
 		qed_vf_get_link_caps(hwfn, link_caps);
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.h b/drivers/net/ethernet/qlogic/qed/qed_sriov.h
index c8667c65e685..c90b2b6ad969 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.h
@@ -12,11 +12,13 @@
 #include "qed_vf.h"
 #define QED_VF_ARRAY_LENGTH (3)
 
+#ifdef CONFIG_QED_SRIOV
 #define IS_VF(cdev)             ((cdev)->b_is_vf)
 #define IS_PF(cdev)             (!((cdev)->b_is_vf))
-#ifdef CONFIG_QED_SRIOV
 #define IS_PF_SRIOV(p_hwfn)     (!!((p_hwfn)->cdev->p_iov_info))
 #else
+#define IS_VF(cdev)             (0)
+#define IS_PF(cdev)             (1)
 #define IS_PF_SRIOV(p_hwfn)     (0)
 #endif
 #define IS_PF_SRIOV_ALLOC(p_hwfn)       (!!((p_hwfn)->pf_iov_info))

I don't see why that isn't already the case actually. If this is ok, I'll
send an updated patch.

For the PF case, we still need to fix the qed_mcp_get_link_params() failure
case, so the rest of my patch is needed anyway, regardless of how we
address the warning.

	Arnd
