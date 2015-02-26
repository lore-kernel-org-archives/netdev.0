From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch -mainline] niu: fix error handling in niu_class_to_ethflow()
Date: Thu, 26 Feb 2015 19:56:56 +0300
Message-ID: <20150226165656.GB6820@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benoit Taine <benoit.taine@lip6.fr>,
	Fabian Frederick <fabf@skynet.be>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is a discrepancy here because the niu_class_to_ethflow() returns
zero on failure and one on success but the caller expected zero on
success and negative on failure.

The problem means that we allow the user to pass classes and flow_types
which we don't want.  I've looked at it a bit and I don't see it as a
very serious bug.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index 4b51f90..0c5842a 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -6989,10 +6989,10 @@ static int niu_class_to_ethflow(u64 class, int *flow_type)
 		*flow_type = IP_USER_FLOW;
 		break;
 	default:
-		return 0;
+		return -EINVAL;
 	}
 
-	return 1;
+	return 0;
 }
 
 static int niu_ethflow_to_class(int flow_type, u64 *class)
@@ -7198,11 +7198,9 @@ static int niu_get_ethtool_tcam_entry(struct niu *np,
 	class = (tp->key[0] & TCAM_V4KEY0_CLASS_CODE) >>
 		TCAM_V4KEY0_CLASS_CODE_SHIFT;
 	ret = niu_class_to_ethflow(class, &fsp->flow_type);
-
 	if (ret < 0) {
 		netdev_info(np->dev, "niu%d: niu_class_to_ethflow failed\n",
 			    parent->index);
-		ret = -EINVAL;
 		goto out;
 	}
 
