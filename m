From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Re-submit [PATCH 1/1] ethtool: Expose MDI-X status
Date: Wed, 10 Jun 2009 20:22:15 +0100
Message-ID: <1244661735.2848.21.camel@achroite>
References: <1243353768.3188.2.camel@achroite>
	 <20090610191106.GA5930@clala-laptop>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-2Yd5+5N+QQSzhlhYXN7E"
Cc: jgarzik@redhat.com, jeff@garzik.org, netdev@vger.kernel.org
To: Chaitanya Lala <clala@riverbed.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:41437 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755123AbZFJTW1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 15:22:27 -0400
In-Reply-To: <20090610191106.GA5930@clala-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-2Yd5+5N+QQSzhlhYXN7E
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Wed, 2009-06-10 at 12:11 -0700, Chaitanya Lala wrote:
> The MDI-X status is a useful tool for diagnosing network
> connectivity issues. We expose MDI-X status as a tri-state value
> status which drivers can optionally implement.
> 
> Signed-off-by: Chaitanya Lala <clala@riverbed.com>
> Signed-off-by: Arthur Jones <ajones@riverbed.com>
> ---
>  ethtool-copy.h |    8 +++++++-
>  ethtool.c      |   13 +++++++++++++
>  2 files changed, 20 insertions(+), 1 deletions(-)
> 
> diff --git a/ethtool-copy.h b/ethtool-copy.h
> index 3ca4e2c..48fb1d3 100644
> --- a/ethtool-copy.h
> +++ b/ethtool-copy.h
> @@ -26,7 +26,8 @@ struct ethtool_cmd {
>  	__u32	maxtxpkt;	/* Tx pkts before generating tx int */
>  	__u32	maxrxpkt;	/* Rx pkts before generating rx int */
>  	__u16	speed_hi;
> -	__u16	reserved2;
> +	__u8	is_mdix;
> +	__u8	reserved2;
>  	__u32	reserved[3];
>  };
>  
> @@ -416,6 +417,11 @@ struct ethtool_rxnfc {
>  #define AUTONEG_DISABLE		0x00
>  #define AUTONEG_ENABLE		0x01
>  
> +/* Mode MDI or MDI-X */
> +#define MDI_INVALID 0x00
> +#define MDI         0x01
> +#define MDI_X       0x02
> +
>  /* Wake-On-Lan options. */
>  #define WAKE_PHY		(1 << 0)
>  #define WAKE_UCAST		(1 << 1)
[...]

This doesn't match the changes in <linux/ethtool.h>.  I'm attaching the
patch I applied locally for testing MDI-X reporting in sfc.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--=-2Yd5+5N+QQSzhlhYXN7E
Content-Disposition: attachment; filename=0001-ethtool-Expose-MDI-X-status.patch
Content-Type: application/mbox; name=0001-ethtool-Expose-MDI-X-status.patch
Content-Transfer-Encoding: 7bit

>From 236be78a8c527aa2ce92e19bc3031635304e30e9 Mon Sep 17 00:00:00 2001
From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 10 Jun 2009 16:00:34 +0100
Subject: [PATCH] ethtool: Expose MDI-X status

Based on a patch by Chaitanya Lala <clala@riverbed.com>.

The MDI-X status is a useful tool for diagnosing network
connectivity issues. We expose MDI-X status as a tri-state value
status which drivers can optionally implement.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool-copy.h |    8 +++++++-
 ethtool.c      |   13 +++++++++++++
 2 files changed, 20 insertions(+), 1 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index d9bb957..c2cd082 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -30,7 +30,8 @@ struct ethtool_cmd {
 	__u32	maxtxpkt;	/* Tx pkts before generating tx int */
 	__u32	maxrxpkt;	/* Rx pkts before generating rx int */
 	__u16	speed_hi;
-	__u16	reserved2;
+	__u8	eth_tp_mdix;
+	__u8	reserved2;
 	__u32	lp_advertising;	/* Features the link partner advertises */
 	__u32	reserved[2];
 };
@@ -504,6 +505,11 @@ struct ethtool_rxnfc {
 #define AUTONEG_DISABLE		0x00
 #define AUTONEG_ENABLE		0x01
 
+/* Mode MDI or MDI-X */
+#define ETH_TP_MDI_INVALID	0x00
+#define ETH_TP_MDI		0x01
+#define ETH_TP_MDI_X		0x02
+
 /* Wake-On-Lan options. */
 #define WAKE_PHY		(1 << 0)
 #define WAKE_UCAST		(1 << 1)
diff --git a/ethtool.c b/ethtool.c
index a409e02..60c2371 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -982,6 +982,19 @@ static int dump_ecmd(struct ethtool_cmd *ep)
 	fprintf(stdout, "	Auto-negotiation: %s\n",
 		(ep->autoneg == AUTONEG_DISABLE) ?
 		"off" : "on");
+
+	switch (ep->eth_tp_mdix) {
+	case ETH_TP_MDI:
+		fprintf(stdout, "	MDI-X: off\n");
+		break;
+	case ETH_TP_MDI_X:
+		fprintf(stdout, "	MDI-X: on\n");
+		break;
+	default:
+		fprintf(stdout, "	MDI-X: Unknown\n");
+		break;
+	}
+
 	return 0;
 }
 
-- 
1.5.5


--=-2Yd5+5N+QQSzhlhYXN7E--

