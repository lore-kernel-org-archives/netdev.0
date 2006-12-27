From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2/2] [IPV6] RAW: Add checksum default defines for
 mobility header.
Date: Wed, 27 Dec 2006 11:14:29 +0900 (JST)
Message-ID: <20061227.111429.51867516.yoshfuji@linux-ipv6.org>
References: <11653130071739-git-send-email-nakam@linux-ipv6.org>
	<20061205.200242.01826773.yoshfuji@linux-ipv6.org>
	<20061210.225055.45514229.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nakam@linux-ipv6.org, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:41311 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932888AbWL0CN4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Dec 2006 21:13:56 -0500
To: davem@davemloft.net
In-Reply-To: <20061210.225055.45514229.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Happy Holidays!

In article <20061210.225055.45514229.davem@davemloft.net> (at Sun, 10 Dec 2006 22:50:55 -0800 (PST)), David Miller <davem@davemloft.net> says:

> From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Date: Tue, 05 Dec 2006 20:02:42 +0900 (JST)
> 
> > In article <11653130071739-git-send-email-nakam@linux-ipv6.org> (at Tue,  5 Dec 2006 19:03:27 +0900), Masahide NAKAMURA <nakam@linux-ipv6.org> says:
> > 
> > > Add checksum default defines for mobility header(MH).
> > > As the result kernel's behavior is to handle MH checksum
> > > as default.
> > 
> > I'd like to hold this on.  I need to check RFC.
> 
> Is there any resolution about this?

Sorry to have kept you waiting.


According to RFC4584 (Extension to Sockets API for Mobile IPv6) Section 6.1
(Receiving and Sending Mobility Header Messages), an implementation that
supports the Mobile IPv6 API must implement Mobility Header API checksum
calculations by default at the kernel.  This is true in our kernel so far
because we always performs it in net/ipv6/raw.c:mip6_mh_filter().
However, the default value for IPV6_CHECKSUM socket option was not 4
but -1, which is inconsistent.

So, the proposed patch tried changing the default for IPV6_CHECKSUM.

But, wait... currently, we cannot disable checksumming by IPV6_CHECKSUM
for IPPROTO_MH sockets while we can do it for IPPROTO_ICMPV6 sockets.
This is still not good.


RFC3775 Section 9.2 (Processing Mobility Headers) says that
Mobile IPv6 implementation must observe the following items:

	- Checksum (-> silently discard)
		Note: calculated by the common IPv6 checksum algorithm and
		its offset in MH is 4.
	- MH Type (-> Binding Error)
	- Payload protocol (-> ICMPv6 Parameter Problem)
	- Length (-> ICMPv6 Parameter Problem)

	Note: The order of these checks is not specified.

In Linux, mip6_mh_filter() performs basic checks for Mobile Header,
which corresponds to RFC3775 Section 9.2:
	- Length (depends on MH type)
	- Checksum
	- Payload protocol

	Note: MH is checked in user-space daemon, to send BE.

If it is okay to defer the checksumming after checking the next header
protocol, we can omit the checksumming in mip6_mh_filter(), and
leave it to rawv6_rcv() and rawv6_recvmsg().


Anyway, we have 4 options.

1. IPV6_CHECKSUM default for IPPROTO_MH == 4
   omit checksumming in mip6_mh_filter()
2. IPV6_CHECKSUM default for IPPROTO_MH == -1
   omit checksumming in mip6_mh_filter()
3. IPV6_CHECKSUM for IPPROTO_MH == 4
   always perform checksumming in mip6_mh_filter()
4. IPV6_CHECKSUM default for IPPROTO_MH == -1
   always perform checksumming in mip6_mh_filter()

Current behavior is 4, but it is not appropriate.
I guess 1 is the way to go.

Another question may arise; is it okay to change the default if the
raw socket for Mobility Header is NOT for user-space daemon? or,
is it okay to have two different default value depending on CONFIG_IPV6_MIP6?
If we take these question seriously, we should take 2.

Note: in any case, all IPPROTO_MH raw socket users should explicitly set
IPV6_CHECKSUM socket option.


Opinions? Objections?

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
