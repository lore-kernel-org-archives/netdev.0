From: Simon Xiao <sixiao@microsoft.com>
Subject: [PATCH net-next,1/1] tools: hv: ignore a NIC if it has been configured
Date: Fri, 14 Jul 2017 10:47:20 -0700
Message-ID: <1500054440-11228-1-git-send-email-sixiao@microsoft.com>
Cc: Simon Xiao <sixiao@microsoft.com>
To: netdev@vger.kernel.org, davem@davemloft.net, kys@microsoft.com,
        haiyangz@microsoft.com, sthemmin@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from a2nlsmtp01-04.prod.iad2.secureserver.net ([198.71.225.38]:48012
        "EHLO a2nlsmtp01-04.prod.iad2.secureserver.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750860AbdGNSAS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2017 14:00:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Let bondvf.sh ignore this NIC if it has been configured, to prevent
user configuration from being overwritten unexpectly.

Signed-off-by: Simon Xiao <sixiao@microsoft.com>
---
 tools/hv/bondvf.sh | 27 +++++++++++++++++++++++++--
 1 file changed, 25 insertions(+), 2 deletions(-)

diff --git a/tools/hv/bondvf.sh b/tools/hv/bondvf.sh
index 89b2506..80f1028 100755
--- a/tools/hv/bondvf.sh
+++ b/tools/hv/bondvf.sh
@@ -211,6 +211,30 @@ function create_bond {
 
 	echo $'\nBond name:' $bondname
 
+	if [ $distro == ubuntu ]
+	then
+		local mainfn=$cfgdir/interfaces
+		local s="^[ \t]*(auto|iface|mapping|allow-.*)[ \t]+${bondname}"
+
+		grep -E "$s" $mainfn
+		if [ $? -eq 0 ]
+		then
+			echo "WARNING: ${bondname} has been configured already"
+			return
+		fi
+	elif [ $distro == redhat ] || [ $distro == suse ]
+	then
+		local fn=$cfgdir/ifcfg-$bondname
+		if [ -f $fn ]
+		then
+			echo "WARNING: ${bondname} has been configured already"
+			return
+		fi
+	else
+		echo "Unsupported Distro: ${distro}"
+		return
+	fi
+
 	echo configuring $primary
 	create_eth_cfg_pri_$distro $primary $bondname
 
@@ -219,8 +243,6 @@ function create_bond {
 
 	echo creating: $bondname with primary slave: $primary
 	create_bond_cfg_$distro $bondname $primary $secondary
-
-	let bondcnt=bondcnt+1
 }
 
 for (( i=0; i < $eth_cnt-1; i++ ))
@@ -228,5 +250,6 @@ do
         if [ -n "${list_match[$i]}" ]
         then
 		create_bond ${list_eth[$i]} ${list_match[$i]}
+		let bondcnt=bondcnt+1
         fi
 done
-- 
2.7.4
