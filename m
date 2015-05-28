From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v4 for-next 04/12] IB/ipoib: Return IPoIB devices matching
 connection parameters
Date: Thu, 28 May 2015 14:51:51 +0300
Message-ID: <55670157.8090000@mellanox.com>
References: <1431841868-28063-1-git-send-email-haggaie@mellanox.com>
 <1431841868-28063-5-git-send-email-haggaie@mellanox.com>
 <20150519235502.GB26634@obsidianresearch.com> <555D6E41.10606@mellanox.com>
 <20150521174336.GA6771@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150521174336.GA6771-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 21/05/2015 20:43, Jason Gunthorpe wrote:
> On Thu, May 21, 2015 at 08:33:53AM +0300, Haggai Eran wrote:
> 
>> To create a new child interface on the default P_Key, its possible to
>> use iproute:
>> # ip link add link ib0 name ib0.1 type ipoib
> 
> Uh..
> 
> A key invariant of the IP stack is that is it possible to uniquely
> identify the ingress device.
> 
> So the above scheme is fine for IPoIB, because it uses the interface
> unique QPN to uniquely ID the netdevice: (Device,Port,Pkey,QPN)
> is the unique ID tuple. The world is happy.
> 
> But RDMA CM doesn't provide the QPN. So when RDMA CM searches the
> netdevs for an address it cannot *uniquely* map to a IPoIB interface.
This is technically true, but if someone configures their system that
way, they will also have ARP conflicts in addition. I don't see why we
should support such a configuration.

> This is bad, and *completely wrong*, but today, nobody is going to
> really notice or care. The cases where it does something you don't
> want are not very significant.
> 
> But with containers.. Think this through for a minute: 'In some cases
> the RDMA CM selecs the wrong child' - that goes from being a minor
> annoyance to a violation of containment! Worse the criteria for
> 'selects the wrong child' can be triggered by the contained users. Eg
> the contained user adds a IP to their child that duplicates another
> container. Now we've lost control.
No, this is exactly what would happen in the Ethernet world. If you
create a conflicting configuration between two containers on the same
Ethernet segment, then one of them could get the traffic that was
intended for the other.
I don't see this as a violation of containment, because these containers
are assigned net_devs that communicate on the same segment, so they
behave just as two different hosts would, with or without conflicts.

> 
> The very idea of ib_get_net_dev_by_port_pkey_ip is broken.
> 
> So, I don't know what to say here.. Ideas?
> 
> 1) Forbid creating more than one pkey per ipoib interface?
You probably mean more than one IP on the same pkey. The pkey is
actually part of the request, so its not an issue.

> 2) Somehow extend the RDMA CM to send the IPoIB qpn too?
> 3) ??
We can do something crazy in the future like moving all CM requests to
run over UDP as in RoCEv2. But both adding the QPN or moving to UDP
require a wire protocol change and won't be compatible with today's systems.

> 
> Right now the only case that comes to mind is duplicating IPs, that is
> already going to cause an ARP collision, so maybe having the RDMA CM
> randomly select an IP is not the end of the world... But with
> containers and security, who knows? I'm not confident I've
> exhaustively thought of all possibilities here.
> 
> ----------
> 
> Anyhow.. looking again through this series and the existing code, the
> flow is wrong, and really needs to be changed before this starts to
> make sense to anyone, and is no doubt part of how we got here..
> 
> When a REQ arrives RDMA CM needs to run down these steps (this is identical
> to what ip_input.c does)
> 
>  1) Locate the netdev associated with the ingress of the packet,
>     in a sane world this is done by only checking the
>     unique (Device,Port,Pkey,QPN) tuple.
>     If we keep our brokeness, we'd do this based on
>     (Device,Port,Pkey,IP) - if there are IP collisions then randomly
>     select a netdev (similar to how ARP collision is handled).
That's what ib_get_net_dev_by_port_pkey_ip intends to do.

>  2) Then we do the ip_route_input_noref step, this will set skb_dst to
>     the netdev that will handle the packet, or tell us to drop it.
>     This is not always the same as the netdev that accepts the
>     packet!!!
> 
>     NOTE: This route step is missing today, it does critical things
>     like check that the node is actually listening on the dest IP!

Isn't this a little over-engineered? If all you want is to make sure the
net dev is up, can't we use something like netif_running()?

Also, this sounds like a major change in behavior even for applications
that do not use containers. I think today RDMA CM will accept
connections even if the ipoib interface is down.

> 
>  3) Now we can use skb_dst to iterate over the set of all RDMA CM listens:
>      1) Bound to the skb_dst netdev
>      2) Unbound in the same namespace as skb_dst netdev
>     The first to match the dst IP + port is the listen that will accept the
>     connection, now we go into the cma_new_conn_id path, and we don't
>     need rdma_translate_ip because we already have the handling netdev.
You shouldn't be able to bind one listener to a netdev in a namespace
and also have a different listener listening for any netdev on that same
namespace. (That is what cma_check_port verifies, right?) So when
looking for a listener in a namespace there should be only one match.

It is true we no longer need the rdma_translate_ip call.

> 
> The backwards operation of the current code is part of why this is all
> so strange looking, and I think is strongly connected to the private
> data compare issues Sean is talking about. It is very much the wrong
> flow to look for the RDMA CM listen first, and then try to work
> backwards to the netdev.
That's not what the code does. It first finds the netdev and decides on
the namespace based on that. It then finds the RDMA CM listener in that
namespace.

> 
> The above 3 steps hard require that the ib_cm and rdma_cm
> maintain different listening lists, because we need the 2nd search in
> #3. So this gets the ib_cm completely out of looking at the private
> data. [And now we can think carefully about the best way to refcount
> the listens in RDMA CM]

The current patch-set already makes sure that rdma_cm doesn't rely on
ib_cm's private_data matching.

> 
> Once the above is cleaned up dropping in namespaces should just
> happen naturally.
> 
> So.. I'm going to suggest you make a cleanup series to fix this:
>  - Introduce the ib_get_net_dev_by_port_pkey_ip and document the
>    breakage it represents
>  - Rework rdma_cm to do steps 1,2,3 above, using
>    ib_get_net_dev_by_port_pkey_ip to drive #1, your patch set is
>    already doing about 50% of this change.
>  - Fix the collateral damage
> 
> As I said to Matan, clean up series like this should not introduce
> major functional changes, so stack the few remaining net namespace
> things in another series after it.

I think I can refactor the series this way, but I don't think we need
step 2. It seems like an overly complicated way of checking whether a
netdev is up or not. It doesn't seem to provide any new information over
what ib_get_net_dev_by_port_pkey_ip does.

As for fixing the collateral damage, I assume you mean cleaning the
interfaces of ib_cm now that private data matching is not used? I don't
see why this should be part of the series.

> 
> ** The same comments apply to RoCE too, but for RoCE step #1 works
>    properly based on the (Device,Port,VLAN) unique tuple

For RoCE, you could still have multiple macvlan interfaces using the
same VLAN, with different IP address. So the unique tuple is
(Device,Port,VLAN,IP). With Matan adding a netdev to each GID entry in
the RoCE GID table, I think it would be simpler to find the netdev in RoCE.

>    Ditto for iWarp **
Yes, if iWarp CM can provide the netdev on which a request arrives, I
think it would be simple to use it with this design.

> 
> I think this also moves to address Sean's concern about generality, at
> least for listen. All three protocols will run down the same common
> code to locate the netdev and find the correct RDMA CM listen. The
> only difference is the 'ib_get_net_dev_by_port_pkey_ip' call varies.

Right.

> 
> .. I also wouldn't mind seeing the giant cma.c split, if it makes
>    sense to have a cma_listen.c, for instance, wouldn't that be nice?

It would be nice, but this patchset is becoming large already, and I
don't want to add unnecessary noise.

Regards,
Haggai
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
