From: Jan Scheurich <jan.scheurich@ericsson.com>
Subject: RE: [PATCH net-next v9] openvswitch: enable NSH support
Date: Fri, 29 Sep 2017 07:10:52 +0000
Message-ID: <CFF8EF42F1132E4CBE2BF0AB6C21C58D7881A337@ESESSMB107.ericsson.se>
References: <1506348969-6233-1-git-send-email-yi.y.yang@intel.com>
 <20170925201439.08460295@griffin>
 <20170926045538.GA5896@localhost.localdomain>
 <20170926124914.60101ca1@griffin>
 <20170927013908.GA33716@localhost.localdomain>
 <CAOrHB_CQyokdTWeoj02RENPP5miq5Arx6goCNQ9ZPbUeTu_MeQ@mail.gmail.com>
 <20170929064058.GA16145@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Jiri Benc <jbenc@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "dev@openvswitch.org" <dev@openvswitch.org>,
        "e@erig.me" <e@erig.me>,
        "davem@davemloft.net" <davem@davemloft.net>
To: "Yang, Yi" <yi.y.yang@intel.com>, Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg22.ericsson.net ([193.180.251.58]:55408 "EHLO
        sessmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750847AbdI2HKy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2017 03:10:54 -0400
In-Reply-To: <20170929064058.GA16145@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Yang, Yi [mailto:yi.y.yang@intel.com]
> Sent: Friday, 29 September, 2017 08:41
> To: Pravin Shelar <pshelar@ovn.org>
> Cc: Jiri Benc <jbenc@redhat.com>; netdev@vger.kernel.org; dev@openvswitch.org; e@erig.me; davem@davemloft.net; Jan Scheurich
> <jan.scheurich@ericsson.com>
> Subject: Re: [PATCH net-next v9] openvswitch: enable NSH support
> 
> On Fri, Sep 29, 2017 at 02:28:38AM +0800, Pravin Shelar wrote:
> > On Tue, Sep 26, 2017 at 6:39 PM, Yang, Yi <yi.y.yang@intel.com> wrote:
> > > On Tue, Sep 26, 2017 at 06:49:14PM +0800, Jiri Benc wrote:
> > >> On Tue, 26 Sep 2017 12:55:39 +0800, Yang, Yi wrote:
> > >> > After push_nsh, the packet won't be recirculated to flow pipeline, so
> > >> > key->eth.type must be set explicitly here, but for pop_nsh, the packet
> > >> > will be recirculated to flow pipeline, it will be reparsed, so
> > >> > key->eth.type will be set in packet parse function, we needn't handle it
> > >> > in pop_nsh.
> > >>
> > >> This seems to be a very different approach than what we currently have.
> > >> Looking at the code, the requirement after "destructive" actions such
> > >> as pushing or popping headers is to recirculate.
> > >
> > > This is optimization proposed by Jan Scheurich, recurculating after push_nsh
> > > will impact on performance, recurculating after pop_nsh is unavoidable, So
> > > also cc jan.scheurich@ericsson.com.
> > >
> > > Actucally all the keys before push_nsh are still there after push_nsh,
> > > push_nsh has updated all the nsh keys, so recirculating remains avoidable.
> > >
> >
> >
> > We should keep existing model for this patch. Later you can submit
> > optimization patch with specific use cases and performance
> > improvement. So that we can evaluate code complexity and benefits.
> 
> Ok, I'll remove the below line in push_nsh and send out v11, thanks.
> 
> 	key->eth.type = htons(ETH_P_NSH);

The optimization Yi refers to only affects the slow path translation. 

OVS 2.8 does not immediately trigger an immediate recirculation after translating 
encap(nsh,...). There is no need to do so as the flow key of the resulting packet 
can be determined from the encap() action and its properties. Translation 
continues with the rewritten flow key and subsequent OpenFlow actions will 
typically set the new fields in the new NSH header. The push_nsh datapath action 
(including all NSH header fields) is only generated at the next commit, e.g. for 
output, cloning, recirculation, encap/decap or another destructive change of 
the flow key.

The implementation of push_nsh in the user-space datapath does not update
the miniflow (key) of the packet, only the packet data and some metadata. 
If the packet needs to be looked up again the slow path triggers recirculation
to re-parse the packet. There should be no need for the datapath push_nsh 
action to try to update the flow key.

BR, Jan
