From: Yann Droneaud <ydroneaud@opteya.com>
Subject: Re: [PATCH v4 for-next 00/12] Add network namespace support in the
 RDMA-CM
Date: Tue, 19 May 2015 16:30:26 +0200
Message-ID: <1432045826.5304.6.camel@opteya.com>
References: <1431841868-28063-1-git-send-email-haggaie@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Doug Ledford <dledford@redhat.com>, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>
To: Haggai Eran <haggaie@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ou.quest-ce.net ([195.154.187.82]:49019 "EHLO ou.quest-ce.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932929AbbESOam (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2015 10:30:42 -0400
In-Reply-To: <1431841868-28063-1-git-send-email-haggaie@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Le dimanche 17 mai 2015 =C3=A0 08:50 +0300, Haggai Eran a =C3=A9crit :
> Thanks again everyone for the review comments. I've updated the patch=
=20
> set
> accordingly. The main changes are in the first patch to use a read
> -write
> semaphore instead of an SRCU, and with the reference counting of=20
> shared
> ib_cm_ids.
> Please let me know if I missed anything, or if there are other issues=
=20
> with
> the series.
>=20
> Regards,
> Haggai
>=20
> Changes from v3:
> - Patch 1 and 3: use read-write semaphore instead of an SRCU.
> - Patch 5:
>   * Use a direct reference count instead of a kref.
>   * Instead of adding get/put pair for ib_cm_ids, just avoid=20
> destroying an
>     id when it is still in use.
>   * Squashes these two patches together, since the first one became=20
> too
>     short:
>       IB/cm: Reference count ib_cm_ids
>       IB/cm: API to retrieve existing listening CM IDs
> - Rebase to Doug's to-be-rebased/for-4.2 branch.
>=20
> Changes from v2:
> - Add patch 1 to change device_mutex to an RCU.
> - Remove patch that fixed IPv4 connections to an IPv4/IPv6 listener.
> - Limit namespace related changes to RDMA CM and InfiniBand only.
> - Rebase on dledford/for-v4.2, with David Ahern's unaligned access=20
> patch.
>   * Use Michael Wang's capability functions where needed.
> - Move the struct net argument to be the first in all functions, to=20
> match the
>   networking core scheme.
> - Patch 2:
>   * Remove unwanted braces.
> - Patch 4: check the return value of ib_find_cached_pkey.
> - Patch 8: verify the address family before calling cm_save_ib_info.
> - Patch 10: use generic_net instead of a custom radix tree for having=
=20
> per
>   network namespace data.
> - Minor changes.
>=20
> Changes from v1:
> - Include patch 1 in this series.
> - Rebase for v4.1.
>=20
> Changes from v0:
> - Fix code review comments by Yann
> - Rebase on top of linux-3.19
>=20
> RDMA-CM uses IP based addressing and routing to setup RDMA=20
> connections between
> hosts. Currently, all of the IP interfaces and addresses used by the=20
> RDMA-CM
> must reside in the init_net namespace. This restricts the usage of=20
> containers
> with RDMA to only work with host network namespace (aka the kernel=20
> init_net NS
> instance).
>=20
> This patchset allows using network namespaces with the RDMA-CM.
>=20
> Each RDMA-CM id keeps a reference to a network namespace.
>=20
> This reference is based on the process network namespace at the time=20
> of the
> creation of the object or inherited from the listener.
>=20
> This network namespace is used to perform all IP and network related
> operations. Specifically, the local device lookup, as well as the=20
> remote GID
> address resolution are done in the context of the RDMA-CM object's=20
> namespace.
> This allows outgoing connections to reach the right target, even if=20
> the same
> IP address exists in multiple network namespaces. This can happen if=20
> each
> network namespace resides on a different P_Key.
>=20
> Additionally, the network namespace is used to split the listener=20
> service ID
> table. From the user point of view, each network namespace has a=20
> unique,
> completely independent table of service IDs. This allows running=20
> multiple
> instances of a single service on the same machine, using containers.=20
> To
> implement this, multiple RDMA CM IDs, belonging to different=20
> namespaces may
> now share their CM ID. When a request on such a CM ID arrives, the=20
> RDMA CM
> module finds out the correct namespaces and looks for the RDMA CM ID
> matching the request's parameters.
>=20
> The functionality introduced by this series would come into play when=
=20
> the
> transport is InfiniBand and IPoIB interfaces are assigned to each=20
> namespace.
> Multiple IPoIB interfaces can be created and assigned to different=20
> RDMA-CM
> capable containers, for example using pipework [1].
>=20
> Full support for RoCE will be introduced in a later stage.
>=20

How does this play with iWarp: as iWarp HCA are aware of IP addresses /
UDP/TCP ports, AFAIK, are those tied to namespace with this patchset or
will it be possible to use the iWarp HCA to access to address/port
resources tied to a different namespace ?


> The patches apply against Doug's tree for v4.2.
>=20
> The patchset is structured as follows:
>=20
> Patch 1 adds a read-write semaphore in addition to the device mutex=20
> in
> ib_core to allow traversing the client list without a deadlock in=20
> Patch 3.
>=20
> Patch 2 is a relatively trivial API extension, requiring the callers
> of certain ib_addr functions to provide a network namespace, as=20
> needed.
>=20
> Patches 3 and 4 adds the ability to lookup a network namespace=20
> according to
> the IP address, device and P_Key. It finds the matching IPoIB=20
> interfaces, and
> safely takes a reference on the network namespace before returning to=
=20
> the
> caller.
>=20
> Patches 5-6 make necessary changes to the CM layer, to allow sharing=20
> of a
> single CM ID between multiple RDMA CM IDs. This includes adding a=20
> reference
> count to ib_cm_id structs, add an API to either create a new CM ID or=
=20
> use
> an existing one, and expose the service ID to ib_cm clients.
>=20
> Patches 7-8 do some preliminary refactoring to the rdma_cm module.=20
> Patch 7
> refactors the logic that extracts the IP address from a connect=20
> request to
> allow reuse by the namespace lookup code further on.  Patch 8 changes=
=20
> the
> way RDMA CM module creates CM IDs, to avoid relying on the=20
> compare_data
> feature of ib_cm. This feature associate a single compare_data struct=
=20
> per
> ib_cm_id, so it cannot be used when sharing CM IDs.
>=20
> Patches 9-12 add proper namespace support to the RDMA-CM module. This
> includes adding multiple port space tables, sharing ib_cm_ids between
> rdma_cm_ids, adding a network namespace parameter, and finally=20
> retrieving
> the namespace from the creating process.
>=20

Regards.

--=20
Yann Droneaud
OPTEYA
