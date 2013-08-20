From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: ipsec smp scalability and cpu use fairness (softirqs)
Date: Tue, 20 Aug 2013 08:17:28 +0200
Message-ID: <20130820061728.GZ26773@secunet.com>
References: <20130812160142.71737a95@vostro>
 <CAKTPYJTVhvF=215eS0xriEdUyyCLaC+zzja4zPrG668ALzERyw@mail.gmail.com>
 <20130813092312.2493354e@vostro>
 <20130813074614.GM25511@secunet.com>
 <20130813105757.39fb0ab8@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Collins <bsderandrew@gmail.com>, netdev@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:45222 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751926Ab3HTGRb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Aug 2013 02:17:31 -0400
Content-Disposition: inline
In-Reply-To: <20130813105757.39fb0ab8@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 13, 2013 at 10:57:57AM +0300, Timo Teras wrote:
> On Tue, 13 Aug 2013 09:46:14 +0200
> Steffen Klassert <steffen.klassert@secunet.com> wrote:
> 
> > Currently we have only one systemwide workqueue for encryption
> > and one decryption. So all IPsec packets are send to the same
> > workqueue, regardless which state they use.
> > 
> > I have patches that make it possible to configure a separate
> > workqueue for each state or to group some states to a specific
> > workqueue. These patches are still unpublished because they
> > have not much testing yet, but I could send them after some
> > polishing for review or testing if you are interested.
> 
> Yes, I'd be interested.
> 

I've pushed the patches to

git://git.kernel.org/pub/scm/linux/kernel/git/klassert/linux-stk.git net-next-pcrypt

Steffen Klassert (9):
      crypto: api - Add crypto_tfm_has_alg helper
      xfrm: Add a netlink attribute for crypto algorithm drivers
      esp4: Use the crypto algorithm driver name if present
      esp6: Use the crypto algorithm driver name if present
      crypto: Support for multi instance algorithms
      pcrypt: handle errors from crypto_register_template
      crypto: pcrypt - Add support for request backlog
      crypto: pcrypt - Add the padata related informations to the instance context
      crypto: pcrypt - Support for multiple padata instances

 crypto/algapi.c           |    3 +-
 crypto/api.c              |   15 ++
 crypto/pcrypt.c           |  489 +++++++++++++++++++++++++++++++++++----------
 include/linux/crypto.h    |    7 +
 include/net/xfrm.h        |    2 +
 include/uapi/linux/xfrm.h |    5 +
 net/ipv4/esp4.c           |   33 ++-
 net/ipv6/esp6.c           |   33 ++-
 net/xfrm/xfrm_user.c      |    8 +
 9 files changed, 482 insertions(+), 113 deletions(-)


This is a combined patchset of networking and crypto changes.
I merged them and pushed it to a git repo so I don't need to bother
the netdev and the crypto list with this early stage patches.

The networking changes add a posibility to choose the crypto alg driver
on a per SA basis. I've attach the necessary iproute2 patch to this mail.

The crypto changes are a general pcrypt update. It adds a possibility to
build multiple instances of pcrypt such that each SA can have it's own
pcrypt instance. There is one unrelated patch in the patchset:

crypto: pcrypt - Add support for request backlog

It should not interfere with the other patches, it was just to much pain
to rebase without that patch.

Comments to the patchset and test results are very welcome!

The patch below adds an iproute2 option to configure the crypto driver
per SA:

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Tue, 20 Aug 2013 07:13:51 +0200
Subject: [PATCH] iproute2: Add a option to configure the crypto driver on per
 SA basis

---
 include/linux/xfrm.h |    5 +++++
 ip/xfrm_state.c      |    7 +++++++
 2 files changed, 12 insertions(+)

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index 341c3c9..4520008 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -116,6 +116,10 @@ struct xfrm_algo_aead {
 	char		alg_key[0];
 };
 
+struct xfrm_algo_driver{
+	char		driver_name[64];
+};
+
 struct xfrm_stats {
 	__u32	replay_window;
 	__u32	replay;
@@ -298,6 +302,7 @@ enum xfrm_attr_type_t {
 	XFRMA_TFCPAD,		/* __u32 */
 	XFRMA_REPLAY_ESN_VAL,	/* struct xfrm_replay_esn */
 	XFRMA_SA_EXTRA_FLAGS,	/* __u32 */
+	XFRMA_ALG_DRIVER,	/* struct xfrm_algo_driver */
 	__XFRMA_MAX
 
 #define XFRMA_MAX (__XFRMA_MAX - 1)
diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index 389942c..b7d413d 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -274,6 +274,7 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 		char   			buf[RTA_BUF_SIZE];
 	} req;
 	struct xfrm_replay_state replay;
+	struct xfrm_algo_driver driver;
 	char *idp = NULL;
 	char *aeadop = NULL;
 	char *ealgop = NULL;
@@ -290,6 +291,7 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 
 	memset(&req, 0, sizeof(req));
 	memset(&replay, 0, sizeof(replay));
+	memset(&driver, 0, sizeof(driver));
 	memset(&ctx, 0, sizeof(ctx));
 
 	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(req.xsinfo));
@@ -392,6 +394,11 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 			xfrm_sctx_parse((char *)&ctx.str, context, &ctx.sctx);
 			addattr_l(&req.n, sizeof(req.buf), XFRMA_SEC_CTX,
 				  (void *)&ctx, ctx.sctx.len);
+		} else if (strcmp(*argv, "crypto-driver") == 0) {
+			NEXT_ARG();
+			strncpy(driver.driver_name, *argv, sizeof(driver.driver_name));
+			addattr_l(&req.n, sizeof(req.buf), XFRMA_ALG_DRIVER,
+				  (void *)&driver, sizeof(driver));
 		} else {
 			/* try to assume ALGO */
 			int type = xfrm_algotype_getbyname(*argv);
-- 
1.7.9.5
