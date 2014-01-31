From: astx <astx@aws-it.at>
Subject: Re: OOPS in nf_ct_unlink_expect_report using Polycom RealPresence
 Mobile
Date: Fri, 31 Jan 2014 17:04:02 +0100
Message-ID: <20140131170402.Horde.yIFUeQVjLycuS_8PGQoKmg5@aws-it.at>
References: <20140131120527.Horde.-3YzQu5S8WWBx7vuVVNdBA2@bigboss.aws-it.at>
 <20140131125014.Horde.G2TRlt-60JJ0Nl_3Y8IniQ2@bigboss.aws-it.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed; DelSp=Yes
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140131125014.Horde.G2TRlt-60JJ0Nl_3Y8IniQ2@bigboss.aws-it.at>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Alexey,

seems to help. Thank you for your quick response. Kernel 3.10.28 is  
now stable using h323 / Polycom.

Will test this patch with different kernel versions the next days.

Best Regards,
Toni


Original message from Alexey Dobriyan:
--------------------------------------------------------------------------------------
Date	Fri, 31 Jan 2014 16:29:58 +0300
Subject	Re: OOPS in nf_ct_unlink_expect_report using Polycom  
RealPresence Mobile
From	Alexey Dobriyan <>


> Disabling nf_nat_h323 and nf_conntrack_h323 avoids crash -
> but video conferencing software is no more usable.
>
> BUG: unable to handle kernel paging request at 00100104
> IP: [<f8214f07>] nf_ct_unlink_expect_report

This must be the same bug fixed in SIP module:
commit 3f509c689a07a4aa989b426893d8491a7ffcc410
netfilter: nf_nat_sip: fix incorrect handling of EBUSY for RTCP expectation

Try attached patch (if this is mangled):

--- a/net/ipv4/netfilter/nf_nat_h323.c
+++ b/net/ipv4/netfilter/nf_nat_h323.c
@@ -229,7 +229,10 @@ static int nat_rtp_rtcp(struct sk_buff *skb,
struct nf_conn *ct,
   ret = nf_ct_expect_related(rtcp_exp);
   if (ret == 0)
   break;
- else if (ret != -EBUSY) {
+ else if (ret == -EBUSY) {
+ nf_ct_unexpect_related(rtp_exp);
+ continue;
+ } else if (ret < 0) {
   nf_ct_unexpect_related(rtp_exp);
   nated_port = 0;
   break;--- a/net/ipv4/netfilter/nf_nat_h323.c
+++ b/net/ipv4/netfilter/nf_nat_h323.c
@@ -229,7 +229,10 @@ static int nat_rtp_rtcp(struct sk_buff *skb,  
struct nf_conn *ct,
  			ret = nf_ct_expect_related(rtcp_exp);
  			if (ret == 0)
  				break;
-			else if (ret != -EBUSY) {
+			else if (ret == -EBUSY) {
+				nf_ct_unexpect_related(rtp_exp);
+				continue;
+			} else if (ret < 0) {
  				nf_ct_unexpect_related(rtp_exp);
  				nated_port = 0;
  				break;
