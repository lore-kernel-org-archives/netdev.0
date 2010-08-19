From: Steve Chen <schen@mvista.com>
Subject: Re: TAHI CN-6-4-1 failed on Linux 2.6.32 kernel
Date: Thu, 19 Aug 2010 13:35:14 -0500
Message-ID: <AANLkTim+1=4VCmY=fO5HTvDwKnveGEPsY1h1O64vnT6L@mail.gmail.com>
References: <AANLkTim-zWhq9aGrvH2PdS3VjfBvmh=qL=1Sy3Z+VPgT@mail.gmail.com>
	<4C646330.6080303@hp.com>
	<AANLkTik5JOupTW97ikf1imsZrkmwgfPNsvBoSZp1S8JV@mail.gmail.com>
	<4C64ACB2.3090600@hp.com>
	<AANLkTi=01koVqt6YR0LQi53Nx0E=7UT1TFVNL44TwAR4@mail.gmail.com>
	<4C65870F.4080307@hp.com>
	<AANLkTik9=TcMWzNyKWYyDu+bbGscPne6++gD42aju9s_@mail.gmail.com>
	<AANLkTi=qP7BO2=Uhx2Xb0XiLbUz0mPutbg0vz6QnMgYb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=0050450160336961be048e31718c
Cc: usagi-users-ctl@ml.linux-ipv6.org, netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:64986 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753164Ab0HSSfP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 14:35:15 -0400
Received: by iwn1 with SMTP id 1so354113iwn.19
        for <netdev@vger.kernel.org>; Thu, 19 Aug 2010 11:35:14 -0700 (PDT)
In-Reply-To: <AANLkTi=qP7BO2=Uhx2Xb0XiLbUz0mPutbg0vz6QnMgYb@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--0050450160336961be048e31718c
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On Mon, Aug 16, 2010 at 9:07 AM, Steve Chen <schen@mvista.com> wrote:
> On Fri, Aug 13, 2010 at 5:25 PM, Steve Chen <schen@mvista.com> wrote:
>> On Fri, Aug 13, 2010 at 12:55 PM, Brian Haley <brian.haley@hp.com> wrote=
:
>>> On 08/13/2010 01:34 PM, Steve Chen wrote:
>>>>>>>> The TAHI correspondent node tests CN-6-4-1 (Processing in upper la=
yer
>>>>>>>> - Echo Checksum) failed for me in the 2.6.32 kernel. =A0It appears=
 that
>>>>>>>> the Linux kernel is replying the ICMP echo request in
>>>>>>>> icmpv6_echo_reply without much checking. =A0Is this an intentional
>>>>>>>> non-conformance to RFC3775 section 9.3.1?
>>> [snip]
>>>
>>>> It appears that skb->ip_summed is always 1 (CHECKSUM_UNNECESSARY).
>>>> I'm using e1000e. =A0Looking at the driver, there is a checksum offloa=
d
>>>> hardware. =A0I think the code is doing frame check on the entire
>>>> Ethernet packet. =A0Since no error was found, it assume everything
>>>> inside is correct.
>>>
>>> # ethtool -K ethX rx off
>>>
>>> Does that help? =A0Does using a different NIC help?
>>>
>>
>> ethtool did not help.
>>
>> I tried to run the test with a different NIC, but I keep getting
>>
>> ...
>>
>> IPSEC_AKEY =A0 =A0 =A0: =A0 =A0 =A0 =A0 =A0 =A0 =A0 --------------------
>> IPSEC_EALGO =A0 =A0 : =A0 =A0 =A0 =A0 =A0 =A0 =A0 ---------
>> IPSEC_EKEY =A0 =A0 =A0: =A0 =A0 =A0 =A0 =A0 =A0 =A0 --------------------=
----
>> IPSEC_SUPPORT =A0 : =A0 =A0 =A0 =A0 =A0 =A0 =A0 OFF
>> RR_TIMEOUT =A0 =A0 =A0: =A0 =A0 =A0 =A0 =A0 =A0 =A0 3
>> TIMEOUT : =A0 =A0 =A0 =A0 =A0 =A0 =A0 2
>> WAIT_RATELIMIT =A0: =A0 =A0 =A0 =A0 =A0 =A0 =A0 1
>> send Ra_R0_AllNd
>> Wait 3 sec.
>> Clear Captured Packets (Link0)
>> Clear Captured Packets (Link0)
>> send Ns_R0_AllNd
>> ######### Packe Name(RH) Field Value(NextHeader) is NULL
>> CNT_SendAndRecv Status=3DUnKnown
>> NG UnKnown
>> =A0-> Initialization Fail
>> ...
>
> Brian,
>
> Oops, set the Link0 in nut.def to the wrong value. =A0However, I'm still
> getting the same failure with different NIC. =A0I'll start looking into
> the code. =A0Please let me know your test results.
>
> Thanks,
>
> Steve
>

I trace through the code.  It appears that the network driver (e1000e
for my setup) always set ip_summed to CHECKSUM_UNNECESSARY.  I have
been unsuccessful to get the driver to take the other branch where
ip_summed is set to CHECKSUM_COMPLETE.  Even when I hard code
ip_summed to CHECKSUM_COMPLETE, __skb_checksum_complete_head set
ip_summed to CHECKSUM_UNNECESSARY after recomputing the checksum.

So far the only way I'm able to get ICMP to recompute checksum is
through the attached hack.  Even though I can get all the tests to
pass, but it just seem wrong.

Steve

--0050450160336961be048e31718c
Content-Type: text/x-patch; charset=US-ASCII; name="force_icmp6_checksum_for_mip6.patch"
Content-Disposition: attachment;
	filename="force_icmp6_checksum_for_mip6.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gd1ygoem0

TVI6IDM5Nzc0ClR5cGU6IERlZmVjdCBGaXgKRGlzcG9zaXRpb246IE5lZWRzIHN1Ym1pdHRpbmcg
dG8gbWlwdjYKRGVzY3JpcHRpb246CkZpeCBmYWlsdXJlIGluIFRBSEkgY29uZm9ybWFuY2UgdGVz
dCBDTi02LTQtMSAtIFByb2Nlc3NpbmcgaW4gdXBwZXIgbGF5ZXIgLQpFY2hvIENoZWNrc3VtLiAg
SXQgYXBwZWFycyB0aGUga2VybmVsIGRvZXMgbm90IHBlcmZvcm0gSUNNUCBjaGVja3N1bSBpZgpu
byBlcnJvciB3YXMgZGV0ZWN0ZWQgYXQgdGhlIGxpbmsgbGF5ZXIuICBUaGlzIHBhdGNoIGZvcmNl
cyBhbiBJQ01QIGNoZWNrc3VtCnJlY2FsY3VsYXRpb24gZm9yIE1JUDYuCgpkaWZmIC0tZ2l0IGEv
bmV0L2lwdjYvaWNtcC5jIGIvbmV0L2lwdjYvaWNtcC5jCmluZGV4IGYyM2ViYmUuLjU0YTc3Y2Eg
MTAwNjQ0Ci0tLSBhL25ldC9pcHY2L2ljbXAuYworKysgYi9uZXQvaXB2Ni9pY21wLmMKQEAgLTY2
Myw2ICs2NjMsOSBAQCBzdGF0aWMgaW50IGljbXB2Nl9yY3Yoc3RydWN0IHNrX2J1ZmYgKnNrYikK
IAogCS8qIFBlcmZvcm0gY2hlY2tzdW0uICovCiAJc3dpdGNoIChza2ItPmlwX3N1bW1lZCkgewor
I2lmIGRlZmluZWQoQ09ORklHX0lQVjZfTUlQNikgfHwgZGVmaW5lZChDT05GSUdfSVBWNl9NSVA2
X01PRFVMRSkKKwljYXNlIENIRUNLU1VNX1VOTkVDRVNTQVJZOgorI2VuZGlmCiAJY2FzZSBDSEVD
S1NVTV9DT01QTEVURToKIAkJaWYgKCFjc3VtX2lwdjZfbWFnaWMoc2FkZHIsIGRhZGRyLCBza2It
PmxlbiwgSVBQUk9UT19JQ01QVjYsCiAJCQkJICAgICBza2ItPmNzdW0pKQo=
--0050450160336961be048e31718c--
