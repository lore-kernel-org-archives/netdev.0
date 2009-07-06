From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 13467] New: Cannot set larger mtu on vlan
	then on underlying untagged device
Date: Mon, 6 Jul 2009 18:19:50 +0800
Message-ID: <20090706101950.GA18953@gondor.apana.org.au>
References: <20090609143438.87e6bf5d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, tomek@jot23.org,
	"David S. Miller" <davem@davemloft.net>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:48007 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754092AbZGFKTu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2009 06:19:50 -0400
Content-Disposition: inline
In-Reply-To: <20090609143438.87e6bf5d.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton <akpm@linux-foundation.org> wrote:
>
>>            Summary: Cannot set larger mtu on vlan then on underlying
>>                     untagged device

Please try this patch.

vlan: Propagate physical MTU changes

When the physical MTU changes we want to ensure that all existing
VLAN device MTUs do not exceed the new underlying MTU.  This patch
adds that propagation.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index fe64908..6d37b7e 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -468,6 +468,19 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 		}
 		break;
 
+	case NETDEV_CHANGEMTU:
+		for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
+			vlandev = vlan_group_get_device(grp, i);
+			if (!vlandev)
+				continue;
+
+			if (vlandev->mtu <= dev->mtu)
+				continue;
+
+			dev_set_mtu(vlandev, dev->mtu);
+		}
+		break;
+
 	case NETDEV_FEAT_CHANGE:
 		/* Propagate device features to underlying device */
 		for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
