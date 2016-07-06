From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: Network hang after c3f1010b30f7fc611139cfb702a8685741aa6827 with
 CIPSO & Smack
Date: Wed, 6 Jul 2016 07:15:34 -0700
Message-ID: <822cf1e1-7a76-5b79-d277-f151e66b3693@schaufler-ca.com>
References: <e5ba1ba9-acf6-c36c-03e4-4cdc81e81648@schaufler-ca.com>
 <CAHC9VhQsJoA3856MZgaJaHwGAcnXCoe0hn2AtEikcCTZx46Jsg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, dsa@cumulusnetworks.com,
	Linux-Netdev <netdev@vger.kernel.org>
To: Paul Moore <paul@paul-moore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm13-vm0.bullet.mail.bf1.yahoo.com ([98.139.213.79]:38493 "EHLO
	nm13-vm0.bullet.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932225AbcGFOW1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2016 10:22:27 -0400
In-Reply-To: <CAHC9VhQsJoA3856MZgaJaHwGAcnXCoe0hn2AtEikcCTZx46Jsg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/6/2016 5:50 AM, Paul Moore wrote:
> On Tue, Jul 5, 2016 at 8:38 PM, Casey Schaufler <casey@schaufler-ca.com> wrote:
>> I have encountered a system hang with my Smack
>> networking tests that bisects to the change below.
>> I can't say that I have any idea why the change
>> would impact the Smack processing, but there appears
>> to be some serious packet processing going on. The
>> Smack code is using CIPSO on the loopback interface.
>> The test is supposed to verify that labels can be
>> set on the packets using CIPSO. Unlabeled packets
>> do not appear to be impacted. I do not know if SELinux
>> is affected, and if not, why not. Smack and SELinux
>> use CIPSO differently.
> For the past several months I've been running the SELinux testsuite on
> a weekly basis against Linus' kernel plus the SELinux and audit
> development trees and I haven't noticed any problems that haven't
> already been reported.  While not exhaustive, the testsuite does
> exercise the NetLabel/CIPSO code.  I'll see if I can take a closer
> look at the Smack code, but do you rely on the inet_skb_param values
> in Smack?  We did have a similar problem in the NetLabel core code
> that we fixed with 04f81f0154e4bf002be6f4d85668ce1257efa4d9; it's
> possible there is a similar problem in code that we just aren't
> exercising with SELinux at the moment.

I reported that problem, and that problem was fixed.

I'm looking at the Linus tree and see no structure inet_skb_param.

> * https://github.com/SELinuxProject/selinux-testsuite
> * https://copr.fedorainfracloud.org/coprs/pcmoore/kernel-secnext
>
>> commit c3f1010b30f7fc611139cfb702a8685741aa6827
>> Merge: ca4aa97 0b922b7
>> Author: David S. Miller <davem@davemloft.net>
>> Date:   Wed May 11 19:31:40 2016 -0400
>>
>>     Merge branch 'vrf-pktinfo'
>>
>>     David Ahern says:
>>
>>     ====================
>>     net: vrf: Fixup PKTINFO to return enslaved device index
>>
>>     Applications such as OSPF and BFD need the original ingress device not
>>     the VRF device; the latter can be derived from the former. To that end
>>     move the packet intercept from an rx handler that is invoked by
>>     __netif_receive_skb_core to the ipv4 and ipv6 receive processing.
>>
>>     IPv6 already saves the skb_iif to the control buffer in ipv6_rcv. Since
>>     the skb->dev has not been switched the cb has the enslaved device. Make
>>     the same happen for IPv4 by adding the skb_iif to inet_skb_parm and set
>>     it in ipv4 code after clearing the skb control buffer similar to IPv6.
>>     From there the pktinfo can just pull it from cb with the PKTINFO_SKB_CB
>>     cast.
>>     ====================
>>
>>     Signed-off-by: David S. Miller <davem@davemloft.net>
