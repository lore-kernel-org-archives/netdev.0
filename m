From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH -next] qlcnic: use vzalloc() instead of
 vmalloc()/memset(0)
Date: Tue, 07 Jan 2014 11:14:39 -0800
Message-ID: <1389122079.32137.20.camel@joe-AO722>
References: <CAPgLHd9kdVxAPmxcyZeRpJC7_s8HGyefA+CoYkhhz9pEM2xGKg@mail.gmail.com>
	 <BECD8E8A1B550B48A1BF97C13991F60E46CF1A67@avmb2.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyj.lk@gmail.com>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>,
	"yongjun_wei@trendmicro.com.cn" <yongjun_wei@trendmicro.com.cn>,
	Dept-Eng Linux Driver <Linux-Driver@qlogic.com>,
	netdev <netdev@vger.kernel.org>
To: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0186.hostedemail.com ([216.40.44.186]:42616 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751577AbaAGTOn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 14:14:43 -0500
In-Reply-To: <BECD8E8A1B550B48A1BF97C13991F60E46CF1A67@avmb2.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-01-07 at 18:22 +0000, Jitendra Kalsaria wrote:
> On 1/7/14 5:48 AM, "Wei Yongjun" <weiyj.lk@gmail.com> wrote:
> >From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> >Use vzalloc() instead of vmalloc() and memset(0).
[]
> >diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c

> >@@ -935,11 +935,10 @@ static ssize_t qlcnic_sysfs_read_pci_config(struct
> >file *file,
> > 		return QL_STATUS_INVALID_PARAM;
> > 
> > 	pci_info_sz = pci_func_count * sizeof(*pci_info);
> >-	pci_info = vmalloc(pci_info_sz);
> >+	pci_info = vzalloc(pci_info_sz);

Maybe this is a bit more comprehensive?

pci_info_sz is now used once and might as well be eliminated.
Use ETH_ALEN for 6
Remove memset to 0 of buf, add set to 0 of only unset member.

---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h       |  2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c | 11 ++++-------
 2 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 35d4876..8d7aa4c 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -1267,7 +1267,7 @@ struct qlcnic_pci_func_cfg {
 	u16	port_num;
 	u8	pci_func;
 	u8	func_state;
-	u8	def_mac_addr[6];
+	u8	def_mac_addr[ETH_ALEN];
 };
 
 struct qlcnic_npar_func_cfg {
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
index b529667..4ac8b20 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
@@ -927,31 +927,28 @@ static ssize_t qlcnic_sysfs_read_pci_config(struct file *file,
 	u32 pci_func_count = qlcnic_get_pci_func_count(adapter);
 	struct qlcnic_pci_func_cfg *pci_cfg;
 	struct qlcnic_pci_info *pci_info;
-	size_t pci_info_sz, pci_cfg_sz;
+	size_t pci_cfg_sz;
 	int i, ret;
 
 	pci_cfg_sz = pci_func_count * sizeof(*pci_cfg);
 	if (size != pci_cfg_sz)
 		return QL_STATUS_INVALID_PARAM;
 
-	pci_info_sz = pci_func_count * sizeof(*pci_info);
-	pci_info = vmalloc(pci_info_sz);
+	pci_info = vzalloc(pci_func_count * sizeof(*pci_info));
 	if (!pci_info)
 		return -ENOMEM;
 
-	memset(pci_info, 0, pci_info_sz);
-	memset(buf, 0, pci_cfg_sz);
-	pci_cfg = (struct qlcnic_pci_func_cfg *)buf;
-
 	ret = qlcnic_get_pci_info(adapter, pci_info);
 	if (ret) {
 		vfree(pci_info);
 		return ret;
 	}
 
+	pci_cfg = (struct qlcnic_pci_func_cfg *)buf;
 	for (i = 0; i < pci_func_count; i++) {
 		pci_cfg[i].pci_func = pci_info[i].id;
 		pci_cfg[i].func_type = pci_info[i].type;
+		pci_cfg[i].func_state = 0;
 		pci_cfg[i].port_num = pci_info[i].default_port;
 		pci_cfg[i].min_bw = pci_info[i].tx_min_bw;
 		pci_cfg[i].max_bw = pci_info[i].tx_max_bw;
