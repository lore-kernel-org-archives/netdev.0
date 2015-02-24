From: "Rosen, Rami" <rami.rosen@intel.com>
Subject: RE: [PATCH net-next RFC] ipv4 neigh: match add/del dev lookup
 behaviour to SIOCSARP/SIOCDARP
Date: Tue, 24 Feb 2015 14:01:30 +0000
Message-ID: <9B0331B6EBBD0E4684FBFAEDA55776F9189654A5@HASMSX110.ger.corp.intel.com>
References: <1424756572-29379-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"hannes@stressinduktion.org" <hannes@stressinduktion.org>
To: "roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"hadi@mojatatu.com" <hadi@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:10360 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750748AbbBXOBi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 09:01:38 -0500
In-Reply-To: <1424756572-29379-1-git-send-email-roopa@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

@@ -1692,24 +1703,31 @@ static int neigh_add(struct sk_buff *skb, struct nlmsghdr *nlh)
 		goto out;
 
 	ndm = nlmsg_data(nlh);
+	tbl = neigh_find_table(ndm->ndm_family);
+	if (tbl == NULL)
+		return -EAFNOSUPPORT;
+
+	if (nla_len(tb[NDA_DST]) < tbl->key_len)
+		goto out;
+
+	dst = nla_data(tb[NDA_DST]);
 	if (ndm->ndm_ifindex) {
 		dev = __dev_get_by_index(net, ndm->ndm_ifindex);
 		if (dev == NULL) {
 			err = -ENODEV;
 			goto out;
 		}

If ip_route_output() fails, then the neigh_add() method will return -EINVAL (as it was initialized thus); or, in cases when the NTF_PROXY flag is set, it can return 0 or ENOBUFS, according to the result of the pneigh_lookup(), which is called immediately subsequently in this path. But in fact __ip_route_output_key(), which is invoked by ip_route_output(), can return different error codes, like -EINVAL,-ENODEV, -ENETUNREACH and more, via ERR_PTR. 

 So maybe better is (in order to reflect the cause of the error):
+		if (!IS_ERR(rt)) {
+			dev = rt->dst.dev;
+			ip_rt_put(rt);
+		} else
                                               return PTR_ERR(rt);

We can exit the method at this point with "return PTR_ERR(rt)" because we are assured at this point that dev is NULL.

Error handling in neigh_delete() method maybe also be better changed accordingly.

Regards,
Rami Rosen
Intel Corporation
