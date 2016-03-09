From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH v3 0/8] arm64: rockchip: Initial GeekBox enablement
Date: Wed, 9 Mar 2016 11:27:42 +0100
Message-ID: <56DFFA9E.7060602@st.com>
References: <1457294038-14243-1-git-send-email-afaerber@suse.de> <56DD7172.4000707@suse.de> <2714888.1DdqvJZ8cb@diego> <56DD7593.5060003@suse.de> <56DD8176.2080603@st.com> <56DD8FBE.9010200@suse.de> <56DD99A4.5030004@st.com> <56DDA26C.3050301@suse.de> <56DDA3D5.3090209@st.com> <56DDB749.1020808@suse.de> <CADhT+wfO8x4En78g5ixnnwbpaeXJGDo+Q1sOABYsbXzNZy0CPw@mail.gmail.com> <56DE7E1D.5070508@st.com> <CADhT+weKf+F98uxCQhRa2RfMm8+4p=rrNZc-Vf=w_HPycXto=A@mail.gmail.com> <CAAObsKD9HoEbtV_JMz_R=bcrQseDmhncRAWP9k8djksL-LMQqw@mail.gmail.com> <56DFE55B.2090806@st.com> <56DFE64B.8060606@st.com> <CAAObsKBr9SXg1-wr9O-ypR8JozdGpeAwfDLMeUKi8ozxkKyTXg@mail.gmail.com> <56DFF253.9050208@st.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="------------080902020606030807080607"
Cc: Dinh Nguyen <dinh.linux@gmail.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	=?UTF-8?B?SGVpa28gU3TDvGJuZXI=?= <heiko@sntech.de>,
	<netdev@vger.kernel.org>,
	"open list:ARM/Rockchip SoC..." <linux-rockchip@lists.infradead.org>,
	LAKML <linux-arm-kernel@lists.infradead.org>,
	=?UTF-8?B?QW5kcmVhcyBGw6Ry?= =?UTF-8?B?YmVy?= <afaerber@suse.de>,
	Gabriel Fernandez <gabriel.fernandez@linaro.org>,
	Alexandre TORGUE <alexandre.torgue@st.com>,
	=?UTF-8?B?RnJhbmsgU2Now6RmZXI=?= <fschaefer.oss@googlemail.com>,
	LKML <linux-kernel@vger.kernel.org>
To: Tomeu Vizoso <tomeu@tomeuvizoso.net>,
	Fabrice GASNIER <fabrice.gasnier@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:44049 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932144AbcCIK20 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 05:28:26 -0500
In-Reply-To: <56DFF253.9050208@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--------------080902020606030807080607
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit

Hello Tomeu, Andreas,

On 3/9/2016 10:52 AM, Giuseppe CAVALLARO wrote:
>> * today's linux-next: probe failed
>>
>> * today's linux-next + revert of 88f8b1bb41c6 stmmac: Fix 'eth0: No
>> PHY found' regression: probe succeeded but no network at all
>>
>> * today's linux-next + revert of 88f8b1bb41c6 (stmmac: Fix 'eth0: No
>> PHY found' regression) + revert of 0e80bdc9a72d (stmmac: first frame
>> prep at the end of xmit routine): probe succeeded, dhcp succeeds and
>> nfsroot works for a few seconds before timing out
>
> ok, I was looking at this problem now that seems to related
> the "stmmac: first frame prep at the end of xmit routine"
> that, at first glance, is breaking the gmac 3.50 with normal descriptor.

I have no Hw where to test this use case. So, I wonder if may I ask you 
to test some patch.

This first patch adds a missing barrier to the normal routine that inits 
the descriptor. Barrier was needed to well manage the OWN
descriptor and it was not added in case of normal desc case after
the xmit rework.

Then I will check the algo behind the new xmit and in case of problems,
if you agree, we will decide to revert it because it aimed to add an
optimization.

Let me know if you agree.

Regards
Peppe

--------------080902020606030807080607
Content-Type: text/x-patch; name="normal_tmp.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="normal_tmp.patch"

diff --git a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
index e13228f..4392610 100644
--- a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
@@ -210,7 +210,7 @@ static void ndesc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
 		tdes1 &= ~TDES1_FIRST_SEGMENT;
 
 	if (likely(csum_flag))
-		tdes1 |= (TX_CIC_FULL) << TDES1_CHECKSUM_INSERTION_SHIFT;
+		tdes1 |= (TX_CIC_FULL << TDES1_CHECKSUM_INSERTION_SHIFT);
 	else
 		tdes1 &= ~(TX_CIC_FULL << TDES1_CHECKSUM_INSERTION_SHIFT);
 
@@ -220,6 +220,13 @@ static void ndesc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
 	if (tx_own)
 		tdes1 |= TDES0_OWN;
 
+	if (is_fs & tx_own)
+		/* When the own bit, for the first frame, has to be set, all
+		 * descriptors for the same frame has to be set before, to
+		 * avoid race condition.
+		 */
+		wmb();
+
 	p->des1 = tdes1;
 }
 

--------------080902020606030807080607--
