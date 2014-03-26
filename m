From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: [PATCH net] net: vxlan: fix crash when interface is created with
 no group
Date: Wed, 26 Mar 2014 19:50:18 +0200
Message-ID: <20140326175018.GA24065@zed>
References: <20140326094754.GA19337@zed>
 <OFD0C40ED9.015A05DD-ON87257CA2.003E72F3-87257CA2.003E7300@us.ibm.com>
 <CAF1J0HOd9D1t4hxjMe7Muad71o_pgKQsn3jLxqR5ZFPpj2_Nrw@mail.gmail.com>
 <CAJZOPZL9h0q3iiN7Q2jJWW+uEs0EpNaWqVMqQMyL+-5QGxGWPg@mail.gmail.com>
 <20140325.205324.1845346581147557473.davem@davemloft.net>
 <OF687EFECB.536163E6-ON87257CA7.00513C78-87257CA7.00513C81@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Or Gerlitz <or.gerlitz@gmail.com>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:38771 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751217AbaCZRuX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 13:50:23 -0400
Received: by mail-ee0-f48.google.com with SMTP id b57so1921677eek.21
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 10:50:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <OF687EFECB.536163E6-ON87257CA7.00513C78-87257CA7.00513C81@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 26, 2014 at 08:47:19AM -0600, David Stevens wrote:
> Mike Rapoport <mike.rapoport@ravellosystems.com> wrote on 03/26/2014 05:47:54 AM:
> 
> > 
> > It fixes the instant crashes occurring when vxlan interface goes up, but
> > I have other crashes with custom vxlan configuration, e.g. in the
> > following scenario:
> > 
> > Node A:
> > $ ip link add vxlan1 type vxlan id 1 dev ethA
> > $ ip addr add dev vxlan1 10.0.0.1/24
> > $ ip link set up dev vxlan1
> > $ bridge fdb append 00:00:00:00:00:00 dev vxlan1 dst <ethB IPv4 address>
> 
> I thought this MAC address would be an error, but I just noticed that you
> submitted a patch adding interpretation of the all zeroes MAC address as
> a default FDB.
> 
> That patch, IMO, should've either not gone in, or should've replaced (entirely)
> the existing default_dst. I think the problems you are seeing are due to having
> two "defaults".
> 
> Since the existing default_dst could be either a multicast group or a specific
> destination, I don't understand the point of your patch:
>     afbd8bae9c798c5cdbe4439d3a50536b5438247c
> 
> except possibly to support it as a list. In that case, at least that patch should've
> removed default_dst and used the all-zeroes fdb entry instead, including group
> joins and leaves when it is a multicast IP address.
> 
> I certainly don't see the point of having both.
 
The idea was to have a list of multiple destinations allow a weird form
of multicast when infrastructure does not support it.

I don't remember now why I didn't follow your advice about removing
default_dst then (1). Maybe I had some thoughts that seemed smart and
maybe it was just lazines.
And now I definitely regret :)

The problem is not only duplication of default destinations, but also
the mis^Wuse of default_dst to distinguish whether IPv4 or IPv6 path
should be taken because there is no explicit specification of the
protocol if neither IFLA_VXLAN_GROUP or IFLA_VXLAN_LOCAL defined at
vxlan_newlink. Moreover, if neither of these attributes is present, the
custom configuration will always use v4 socket regardles of use of
default_dst or fdb entry.

>                                                     +-DLS
> 

--
[1] http://thread.gmane.org/gmane.linux.network/270969/focus=271830

--
Sincerely yours,
Mike.
