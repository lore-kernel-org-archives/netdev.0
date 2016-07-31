From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: problem with MPLS and TSO/GSO
Date: Sun, 31 Jul 2016 00:07:10 -0700
Message-ID: <579DA39E.3070703@cumulusnetworks.com>
References: <20160725163915.GE10080@wantstofly.org> <CAD=hENdOy-d0v9BskuvfqF3qdbrWCy2b-Dc-LSSUcZBmHy-X1A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Lennert Buytenhek <buytenh@wantstofly.org>,
	David Ahern <dsa@cumulusnetworks.com>,
	Robert Shearman <rshearma@brocade.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	netdev <netdev@vger.kernel.org>,
	Simon Horman <simon.horman@netronome.com>
To: zhuyj <zyjzyj2000@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:34103 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750911AbcGaHHM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jul 2016 03:07:12 -0400
Received: by mail-pf0-f179.google.com with SMTP id p64so45210966pfb.1
        for <netdev@vger.kernel.org>; Sun, 31 Jul 2016 00:07:12 -0700 (PDT)
In-Reply-To: <CAD=hENdOy-d0v9BskuvfqF3qdbrWCy2b-Dc-LSSUcZBmHy-X1A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/27/16, 12:02 AM, zhuyj wrote:
> On ubuntu16.04 server 64 bit
> The attached script is run, the following will appear.
>
> Error: either "to" is duplicate, or "encap" is a garbage.

This maybe just because the iproute2 version on ubuntu does not
support the route encap attributes yet.

[snip]

>
> On Tue, Jul 26, 2016 at 12:39 AM, Lennert Buytenhek <buytenh@wantstofly.org>
> wrote:
>
>> Hi!
>>
>> I am seeing pretty horrible TCP transmit performance (anywhere between
>> 1 and 10 Mb/s, on a 10 Gb/s interface) when traffic is sent out over a
>> route that involves MPLS labeling, and this seems to be due to an
>> interaction between MPLS and TSO/GSO that causes all segmentable TCP
>> frames that are MPLS-labeled to be dropped on egress.
>>
>> I initially ran into this issue with the ixgbe driver, but it is easily
>> reproduced with veth interfaces, and the script attached below this
>> email reproduces the issue.  The script configures three network
>> namespaces: one that transmits TCP data (netperf) with MPLS labels,
>> one that takes the MPLS traffic and pops the labels and forwards the
>> traffic on, and one that receives the traffic (netserver).  When not
>> using MPLS labeling, I get ~30000 Mb/s single-stream TCP performance
>> in this setup on my test box, and with MPLS labeling, I get ~2 Mb/s.
>>
>> Some investigating shows that egress TCP frames that need to be
>> segmented are being dropped in validate_xmit_skb(), which calls
>> skb_gso_segment() which calls skb_mac_gso_segment() which returns
>> -EPROTONOSUPPORT because we apparently didn't have the right kernel
>> module (mpls_gso) loaded.
>>
>> (It's somewhat poor design, IMHO, to degrade network performance by
>> 15000x if someone didn't load a kernel module they didn't know they
>> should have loaded, and in a way that doesn't log any warnings or
>> errors and can only be diagnosed by adding printk calls to net/core/
>> and recompiling your kernel.)

Its possible that the right way to do this is to always auto select MPLS_GSO
if MPLS_IPTUNNEL is selected. I am guessing this by looking at the
openvswitch mpls Kconfig entries and comparing with MPLS_IPTUNNEL.
will look some more.

>>
>> (Also, I'm not sure why mpls_gso is needed when ixgbe seems to be
>> able to natively do TSO on MPLS-labeled traffic, maybe because ixgbe
>> doesn't advertise the necessary features in ->mpls_features?  But
>> adding those bits doesn't seem to change much.)
>>
>> But, loading mpls_gso doesn't change much -- skb_gso_segment() then
>> starts return -EINVAL instead, which is due to the
>> skb_network_protocol() call in skb_mac_gso_segment() returning zero.
>> And looking at skb_network_protocol(), I don't see how this is
>> supposed to work -- skb->protocol is 0 at this point, and there is no
>> way to figure out that what we are encapsulating is IP traffic, because
>> unlike what is the case with VLAN tags, MPLS labels aren't followed by
>> an inner ethertype that says what kind of traffic is in here, you have
>> to have explicit knowledge of the payload type for MPLS.
>>
>> Any ideas?
I was looking at the history of net/mpls/mpls_gso.c and the initial git log comment
says that the driver expects the mpls tunnel driver to do a few things which I think
might be the problem. I do see mpls_iptunnel.c setting the skb->protocol but not the
skb->inner_protocol. wonder if fixing anything there will help ?.

thanks,
Roopa
