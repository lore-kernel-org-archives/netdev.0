From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH WIP RFC 0/3] mpls: support for ler
Date: Mon, 08 Jun 2015 08:17:27 -0700
Message-ID: <5575B207.4040900@cumulusnetworks.com>
References: <1433341306-29288-1-git-send-email-roopa@cumulusnetworks.com> <20150605091441.GA11896@pox.localdomain> <5571AF28.8000009@cumulusnetworks.com> <5571BF90.2070304@brocade.com> <557260E0.9060500@cumulusnetworks.com> <20150608123302.GA3634@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Robert Shearman <rshearma@brocade.com>, ebiederm@xmission.com,
	netdev@vger.kernel.org,
	Vivek Venkatraman <vivek@cumulusnetworks.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f180.google.com ([209.85.216.180]:36522 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932599AbbFHPRc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2015 11:17:32 -0400
Received: by qcxw10 with SMTP id w10so51735098qcx.3
        for <netdev@vger.kernel.org>; Mon, 08 Jun 2015 08:17:31 -0700 (PDT)
In-Reply-To: <20150608123302.GA3634@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/8/15, 5:33 AM, Thomas Graf wrote:
> Yes, the information used to determine the encapsulation and the
> route used to select the outgoing interface might be coming from
> different components. A simple and typical example is if you are
> running quagga to for your underlay which determines which interface
> to use for which tunnel endpoints. On top of that, somebody is
> maintaining your virtual networks which is only aware of the tunnel
> endpoint IP addresses but does not want to manage how to actually
> reach them. So you would have:
>
> ip route add 10.1.1.0/24 via tunnel 20.1.1.1 id 100 [dev vxlan0]
> ip route add 20.1.1.1/24 dev eth0
>
> I've put "dev vxlan0" in brackets for now to indicate that it is
> optional. I'm also using VXLAN as an examples as I think it's
> easier to understand this separation of concern here. The point
> is, whoever is adding the route with the encap information may
> not know what interface to use to reach 20.1.1.1 and we may want
> to rely on existing routes.
>
> I think we want to support three models:
>
> 1. nexthop has encap and outgoing interface
>     ip route add 10.1.1.0/24 via tunnel 20.1.1.1 dev eth0
>     ip route add 20.1.1.1/24 dev eth0
>
> 2. nexthop has endpoint but no dev
>     ip route add 10.1.1.0/24 via tunnel 20.1.1.1
>     ip route add 20.1.1.1/24 dev eth0
>
>     This would indicate to the routing subsystem to perform a
>     fib lookup on 20.1.1.1 to determine the outgoing interface.
>
> 3. virtual tunnel interface to share configuration among routes
>     ip route add 10.1.1.0/24 via tunnel 20.1.1.1 dev vxlan0
>     ip route add 20.1.1.1/24 dev eth0
>
> I think all of them are intuitive and easy to implement. This will
> also allow to incorporate the bridge model.
>
ack, that sounds intuitive.
With RTA_ENCAP and the mpls examples i was using it looks something like 
the below for (1)
ip route add 10.1.1.0/30 encap mpls 200 via 10.1.1.1 dev eth0

The tunnel dst is parsed and understood by the light weight tunnel 
driver, which I think will
end up having to do the lookup (needs more thought)...for (2) and (3).


> Your nexthop implementation seemed more correct based on the chunks
> I went through. Can we combine the two series and make the RTA_OIF
> in the nexthop optional if an RTA_ENCAP was provided and provide a
> route lookup instead?

yes, we can do that.
  Robert can correct me if i misunderstood, both our patches had similar 
code to handle RTA_ENCAP.
Only difference was in the way we stored the encaped data, mine was a 
pointer to tunnel state and his was embedded in fib_nh. His patch today 
assumes there is a tunnel device.
And mine assumes the output device is specified in the ipv4 fib route.

I am trying to get my code on github to collaborate better. Stay tuned 
(hopefully end of day today).

While we are on this conversation, Though the code already supports 
nested attributes (with the example robert showed), I introduced 
explicit nested attributes for mpls in my version,
and it seemed like it is better to introduce two attributes 
RTA_ENCAP_TYPE and RTA_ENCAP and
type determines the nested policy for RTA_ENCAP
RTA_ENCAP_TYPE /* MPLS, VXLAN etc */

RTA_ENCAP {
     MPLS_IPTUNNEL_UNSPEC
     MPLS_IPTUNNEL_DST
}

RTA_ENCAP {  /* this is also similar to the example robert posted for 
vxlan */
       VXLAN_TUN_UNSPEC,
       VXLAN_TUN_ID,
       VXLAN_TUN_DST,
       VXLAN_TUN_SRC,
       VXLAN_TUN_TTL,
       VXLAN_TUN_TOS,
       VXLAN_TUN_SPORT,
       VXLAN_TUN_DPORT,
       VXLAN_TUN_FLAGS,
       VXLAN_TUN_MAX,
}


Thanks,
Roopa
