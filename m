From: Takashi Hibi <hibi665@oki.com>
Subject: MLD problems (again)
Date: Tue, 06 Jan 2004 21:15:42 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040106211542.4fe9e531%hibi665@oki.com>
Mime-Version: 1.0
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

A Happy new year.

Let me discuss about the problems of MLD again.
As I pointed out, there are two problems in current MLD code.

1. In MLDv1 compatibility mode, Older Version Querier Present timer expires
   prematurely.
2. After join SSM using setsockopt(MCAST_JOIN_SOURCE_GROUP),
   MLDv2 listener report isn't issued immediately.

The cause of 1 is the wrong computation of timeout value.
The cause of 2 is difficult to find. After tracing the code,
I figured out that the mode of ifmcaddr6 isn't correctly set after 
setsockopt.

After join by setsockopt, pmc->mca_sfmode should be MCAST_INCLUDE,
but it remains MCAST_EXCLUDE. Eventually is_in() call returns false,
and MLDv2 packet isn't composed.
I don't know the right way to fix it, since the code is too complicated
by a lot of flags.
At least the following patch(diff from 2.6.0) works for me.

Regards,
Takashi Hibi

--- mcast.c	2003-12-18 11:59:28.000000000 +0900
+++ new/mcast.c	2004-01-06 16:30:05.546174486 +0900
@@ -1050,7 +1050,7 @@ int igmp6_event_query(struct sk_buff *sk
 		/* Translate milliseconds to jiffies */
 		max_delay = (ntohs(hdr->icmp6_maxdelay)*HZ)/1000;
 
-		switchback = (idev->mc_qrv + 1) * max_delay;
+		switchback = MLD_QRV_DEFAULT * 125*HZ + max_delay;
 		idev->mc_v1_seen = jiffies + switchback;
 
 		/* cancel the interface change timer */
@@ -1541,7 +1541,8 @@ static void mld_send_cr(struct inet6_dev
 				type = MLD2_CHANGE_TO_EXCLUDE;
 			else
 				type = MLD2_CHANGE_TO_INCLUDE;
-			skb = add_grec(skb, pmc, type, 0, 0);
+			if (!skb)
+				skb = add_grec(skb, pmc, type, 0, 0);
 		}
 		spin_unlock_bh(&pmc->mca_lock);
 	}
@@ -1745,6 +1746,7 @@ static int ip6_mc_add1_src(struct ifmcad
 			return -ENOBUFS;
 		memset(psf, 0, sizeof(*psf));
 		psf->sf_addr = *psfsrc;
+		psf->sf_crcount = pmc->idev->mc_qrv;
 		if (psf_prev) {
 			psf_prev->sf_next = psf;
 		} else
@@ -1799,6 +1801,7 @@ int ip6_mc_add_src(struct inet6_dev *ide
 	struct ifmcaddr6 *pmc;
 	int	isexclude;
 	int	i, err;
+	int     first_join_src_grp;
 
 	if (!idev)
 		return -ENODEV;
@@ -1816,6 +1819,8 @@ int ip6_mc_add_src(struct inet6_dev *ide
 
 	sf_markstate(pmc);
 	isexclude = pmc->mca_sfmode == MCAST_EXCLUDE;
+	first_join_src_grp = (!pmc->sources && sfmode == MCAST_INCLUDE &&
+		sfcount == 1 && delta);
 	if (!delta)
 		pmc->mca_sfcount[sfmode]++;
 	err = 0;
@@ -1827,10 +1832,19 @@ int ip6_mc_add_src(struct inet6_dev *ide
 	if (err) {
 		int j;
 
-		pmc->mca_sfcount[sfmode]--;
+		if (!delta)
+			pmc->mca_sfcount[sfmode]--;
 		for (j=0; j<i; j++)
 			(void) ip6_mc_del1_src(pmc, sfmode, &psfsrc[i]);
-	} else if (isexclude != (pmc->mca_sfcount[MCAST_EXCLUDE] != 0)) {
+		goto done;
+	}
+	if (first_join_src_grp) {
+		pmc->mca_sfmode = MCAST_INCLUDE;
+		if (sf_setstate(pmc))
+			mld_ifc_event(idev);
+		goto done;
+	}
+	if (isexclude != (pmc->mca_sfcount[MCAST_EXCLUDE] != 0)) {
 		struct inet6_dev *idev = pmc->idev;
 		struct ip6_sf_list *psf;
 
@@ -1848,6 +1862,7 @@ int ip6_mc_add_src(struct inet6_dev *ide
 		mld_ifc_event(idev);
 	} else if (sf_setstate(pmc))
 		mld_ifc_event(idev);
+done:
 	spin_unlock_bh(&pmc->mca_lock);
 	read_unlock_bh(&idev->lock);
 	return err;
