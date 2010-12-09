From: Joy Latten <latten@austin.ibm.com>
Subject: Re: IPsecv6  tunnel mode fragmentation
Date: Wed, 08 Dec 2010 20:20:42 -0600
Message-ID: <1291861242.11224.265.camel@faith.austin.ibm.com>
References: <20101208071109.GA14537@gondor.apana.org.au>
Reply-To: latten@austin.ibm.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, samudrala@us.ibm.com, rashmin@us.ibm.com,
	davem@davemloft.net, dlstevens@us.ibm.com
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:51945 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753862Ab0LICrp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 21:47:45 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e39.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id oB92a3nB013836
	for <netdev@vger.kernel.org>; Wed, 8 Dec 2010 19:36:03 -0700
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oB92lcVb157226
	for <netdev@vger.kernel.org>; Wed, 8 Dec 2010 19:47:38 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oB92lcUb022276
	for <netdev@vger.kernel.org>; Wed, 8 Dec 2010 19:47:38 -0700
In-Reply-To: <20101208071109.GA14537@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Herbert,

On Wed, 2010-12-08 at 15:11 +0800, Herbert Xu wrote:
> Joy Latten <latten@austin.ibm.com> wrote:
> > 
> > We have come across an ipsec problem that I think was
> > noted a while back in the following link.
> > http://www.mail-archive.com/netdev@vger.kernel.org/msg61659.html
> 
> Looks like a configuration issue to me.  One end is using the
> same IP address (*::1234) both within and outside the tunnel.
> Thus when the ICMP error message is sent it ends up outside the
> tunnel causing it to be discarded by the other side.
> 
> So if you're using tunnel mode you really should use distinct
> IP addresses.
> 

Do you mean the tunnel mode packet has (*::1234) for both the 
inner and outer headers?

I was actually attempting testcase 5.3.11 from
http://w3.antd.nist.gov/usgv6/TSTs/tests/Phase2_IPsec_Interoperability_v1.1.pdf

My net config varied a little though...

2001:db8:1:1::1234       2001:db8:1:1::56    2033:1:...:35  2033:1:...95
TARGET(eth0) <--ipsectnl--> (eth1)SecurityGateway(eth0) <---> (eth0)HOST
       1500                     1500                 1280        1280

To me the test seems a host-to-securitygateway tunnel mode scenario.

In the 5.3.11 testcase, the tunnel endpoint (eth0 of TARGET) is also
endpoint for the pkt.

i.e. SPD entry from 5.3.11 testcase using above config:

Security Policy Database (SPD) for HOST1_SA-1
tunnel source address           SGW_eth1
tunnel destination address      TGT_eth0
source address                  HOST_eth0
destination address             TGT_eth0
upperspec                       any
direction                       in
protocol                        ESP
mode                            tunnel 

We did attempt to debug in kernel to see whether the pkt-too-big 
was being discarded... from what we saw, it did not seem to be. 
Also, an "ip -6  r l c" on TARGET showed the adjusted mtu for the route 
to HOST, which the pkt-too-big was for. tunnel's mtu is untouched.

2001:db8:1:1::56 via 2001:db8:1:1::56 dev eth0  metric 0 
    cache  mtu 1500 advmss 1440 hoplimit 4294967295
2033:1:2:3:209:6bf:fe6:95 via 2001:db8:1:1::56 dev eth0  metric 0 
    cache  expires 592sec mtu 1280 advmss 1440 hoplimit 4294967295

Thus why I reached my original conclusion, that perhaps 
esp/ah disregard inner hdr mtu since does not fragment.
Thus inner pkt will be too big when it reaches link for 
inner/original pkt to be sent on.

If I have misunderstood your response, my apologies. 
Please let me know.

regards,
Joy 



