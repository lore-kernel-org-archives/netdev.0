From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v2 0/5] bridge: per vlan dst_metadata support
Date: Wed, 1 Feb 2017 23:06:14 -0800
Message-ID: <20170201230614.0b2a2163@xeon-e3>
References: <1485932395-58422-1-git-send-email-roopa@cumulusnetworks.com>
        <20170202012301.GA74213@ast-mbp.thefacebook.com>
        <5892CA81.1020804@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        netdev@vger.kernel.org, davem@davemloft.net,
        nikolay@cumulusnetworks.com, tgraf@suug.ch,
        hannes@stressinduktion.org, jbenc@redhat.com, pshelar@ovn.org,
        dsa@cumulusnetworks.com, hadi@mojatatu.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:33107 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750881AbdBBHGW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 02:06:22 -0500
Received: by mail-pg0-f43.google.com with SMTP id 204so3362565pge.0
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2017 23:06:22 -0800 (PST)
In-Reply-To: <5892CA81.1020804@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 01 Feb 2017 21:58:25 -0800
Roopa Prabhu <roopa@cumulusnetworks.com> wrote:

> On 2/1/17, 5:23 PM, Alexei Starovoitov wrote:
> > On Tue, Jan 31, 2017 at 10:59:50PM -0800, Roopa Prabhu wrote:
> >  
> 
> [snip]
> 
> >> Solution in this patch series:
> >> The Goal is to use a single vxlan device to carry all vnis similar
> >> to the vxlan collect metadata mode but additionally allowing the bridge
> >> and vxlan driver to carry all the forwarding information and also learn.
> >> This implementation uses the existing dst_metadata infrastructure to map
> >> vlan to a tunnel id.  
> > ovs and/or bpf can do the same already, but sounds like the main reason is
> > to keep it integrated with bridge fdb to leverage your offload of bridge
> > fdb into hw asic, right?  
> 
> correct. We already use the bridge driver for vlan filtering and offloading. Having vlan to tunnel map
> elsewhere is not feasible. It is also more than the hw offload asic case, we have routing protocols like bgp looking at bridge driver
> l2 forwarding database for ethernet vpns (https://tools.ietf.org/html/draft-ietf-bess-evpn-overlay-07)
> and they need a single place to look at bridge fdb table, vxlan fdb table, vlan and tunnel info. Also, Bgp might not be the only
> protocol needing this info...we support other controllers too. Hence this info cannot be in a bpf or
> live outside the bridge driver.
> 
> We today have the vlan info, bridge fdb table, vxlan remote dst fdb table. the missing peice is the vlan to vxlan-id mapping
> which this series provides (Well, to be correct, this series helps with scaling this mapping.
> Today we use a vxlan netdev per vlan which does not scale well). And this is a very common configuration in
> data center switches that provide vxlan bridging gateway function.
> [Google for 'vlan to vxlan mapping' should give a couple hits. I did not want to paste a link
> to any specific vendor guide here...but found a generic blog --> http://www.definethecloud.net/vxlan-deep-dive/]
> 
> > If so, I guess, the extra complexity can be justified.
> > The question is how do you program hw ? Is there really 1 to 1 mapping
> > in the asics too? Or is it more flexible ?  
> yes, it is 1-1 mapping in asics too (might be variations on different chips but
> this kind of function is supported by most asics).
> 
> > I think most swith asics can do other tunnels too,
> > so can this vlan->vxlan 1 to 1 be generalized to cover different
> > types of tunnels that can be configured on the switch?  
> 
> 
> yes, it can be. Hence i have kept the tunnel info netlink attribute generic. similar to how LWT provides
> various encaps at the L3 routing layer, this can provide such function at the L2 bridge layer. But, to keep it relatively lite I use the
> already existing dst_metadata infra to bridge vlan to vxlan (Which is already done in the case of vxlan collect metadata mode.
> I simply extend it to cover the bridge case).
> 
> thanks,

I wonder if this is a case for a new driver (with same subset of bridge API). You probably
don't want all the baggage of STP, netfilter, VLAN filtering, etc when doing VXLAN VNI bridging.
