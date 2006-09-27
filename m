From: "Or Gerlitz" <or.gerlitz@gmail.com>
Subject: Re: [RFC][PATCH 1/3] enable bonding to enslave non ARPHRD_ETHER netdevices
Date: Wed, 27 Sep 2006 21:59:05 +0200
Message-ID: <15ddcffd0609271259o31cd0d20r9bfea4cf2ec979b4@mail.gmail.com>
References: <Pine.LNX.4.64.0609261309540.24189@zuben>
	 <Pine.LNX.4.64.0609261316420.24189@zuben>
	 <200609261923.k8QJNLZt021182@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Or Gerlitz" <ogerlitz@voltaire.com>, netdev@vger.kernel.org,
	"Roland Dreier" <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.176]:13669 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S1030731AbWI0T7H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 15:59:07 -0400
Received: by py-out-1112.google.com with SMTP id n25so417618pyg
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2006 12:59:05 -0700 (PDT)
To: "Jay Vosburgh" <fubar@us.ibm.com>
In-Reply-To: <200609261923.k8QJNLZt021182@death.nxdomain.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/26/06, Jay Vosburgh <fubar@us.ibm.com> wrote:
> Or Gerlitz <ogerlitz@voltaire.com> wrote:
> [...]
> +       bond->dev->mtu              = new_active->dev->mtu;
>
>         This won't generate a NETDEV_CHANGEMTU notifier event.

What is actually the trigger for the event with the current impl? is
the code that actually calls dev_set_mtu() on the bonding device or
dev_set_mtu() itself?

>
> [...]
> >+              /* bonding netdevices are created with ether_setup, so when the
> >+               * slave type is not ARPHRD_ETHER there is a need to override
> >+               * some of the type dependent attributes/functions
> >+               */
> >+              if (new_active && new_active->dev->type != ARPHRD_ETHER)
> >+                      bond_setup_by_slave(bond, new_active);
> >+

>         In this case, if the bond has one slave that's ARPHRD_ETHER and
> one that's not, when the active changes from the non-ARPHRD_ETHER slave
> to the ARPHRD_ETHER slave, it won't call bond_setup_by_slave() to switch
> the hard_header, rebuild_header, et al, back to the ARPHRD_ETHER
> settings.

OK. First, under the assumption that one may enslave ARPHRD_ETHER and
non-ARPHRD_ETHER devices in the same bond, you are correct and the
patch is not complete here.

However, putting devices from different types in the same bond
requires a switch that **both** HW NICs/ports associated with the each
of the netdevices can talk to. If there is no such switch, then the
only possible config is two isolated networks/switches where each
NIC/type is connected to a switch supporting this type so  a local
failure/failover on some node requires the whole subset of nodes
talking to this one to do failover. So if the relation (i,j) which
holds if node i talks to node j does not impose a disjoint partition
on the set of all N nodes, you just can't do this bonding scheme.

Practically, talking on IPoIB vs. "IPoETH" (ie slave devices of type
ARPHRD_INFINIBAND vs slaves of type ARPHRD_ETHER) to have an IPoIB
slave talk to "IPoETH" slave you need an IB to Ethernet IP router
(actually IPoIB to IPoETH "bridge") in the middle where the IB switch
should be connected to the IB ports of the bridge and the Ethernet
switch to the Ethernet ports of the bridge. All in all, it is a
configuration i think we can avoid supporting.

So at the bottom line, i would go on enhancing my patch not to allow
bonding together devices of different types or at least if you don't
mind, not to allow putting ARPHRD_INFINIBAND with
non-ARPHRD_INFINIBAND devices in the same bond.

Or.
