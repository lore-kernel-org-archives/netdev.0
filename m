From: Tom Herbert <tom@herbertland.com>
Subject: Re: [net-next PATCH 01/15] net: Combine GENEVE and VXLAN port offload
 notifiers into single functions
Date: Mon, 13 Jun 2016 15:17:38 -0700
Message-ID: <CALx6S37BgUeaS1mHT+xL=n+Q=VZpWX+R3t+FDfZPLLCtYun1Xw@mail.gmail.com>
References: <20160613173750.15186.24381.stgit@localhost.localdomain>
	<20160613174754.15186.37885.stgit@localhost.localdomain>
	<CALx6S37b9pw4u5O1qm4uhsFuJ708DGLQ-sU4=xkPRbuw=wykGg@mail.gmail.com>
	<CAKgT0Ue+ik+wj2C=o66Va6f5qNSo=0xEkYsD--BV6_zqg16kHA@mail.gmail.com>
	<CALx6S37_vdUwiiYieOxBPRchg-ofOXvM-2erjD3LvRux51oEtQ@mail.gmail.com>
	<CAKgT0Uf4u4r_vk2CBeaf607L0TgKj4mHMocEk9N8acGRT4db6w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <aduyck@mirantis.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Hannes Frederic Sowa <hannes@redhat.com>,
	Jesse Gross <jesse@kernel.org>, Jiri Benc <jbenc@redhat.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Dept-GELinuxNICDev@qlogic.com,
	"David S. Miller" <davem@davemloft.net>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35896 "EHLO
	mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751992AbcFMWRj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 18:17:39 -0400
Received: by mail-it0-f68.google.com with SMTP id h190so9001891ith.3
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 15:17:39 -0700 (PDT)
In-Reply-To: <CAKgT0Uf4u4r_vk2CBeaf607L0TgKj4mHMocEk9N8acGRT4db6w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 13, 2016 at 2:51 PM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> On Mon, Jun 13, 2016 at 1:36 PM, Tom Herbert <tom@herbertland.com> wrote:
>> On Mon, Jun 13, 2016 at 1:24 PM, Alexander Duyck
>> <alexander.duyck@gmail.com> wrote:
>>> On Mon, Jun 13, 2016 at 12:55 PM, Tom Herbert <tom@herbertland.com> wrote:
>>>> On Mon, Jun 13, 2016 at 10:47 AM, Alexander Duyck <aduyck@mirantis.com> wrote:
>>>>> This patch merges the GENEVE and VXLAN code so that both functions pass
>>>>> through a shared code path.  This way we can start the effort of using a
>>>>> single function on the network device drivers to handle both of these
>>>>> tunnel offload types.
>>>>>
>>>>> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
>>>>> ---
>>>>>  drivers/net/geneve.c     |   48 ++++-------------------------
>>>>>  drivers/net/vxlan.c      |   46 ++++-----------------------
>>>>>  include/net/udp_tunnel.h |   12 +++++++
>>>>>  net/ipv4/udp_tunnel.c    |   77 ++++++++++++++++++++++++++++++++++++++++++++++
>>>>>  4 files changed, 103 insertions(+), 80 deletions(-)
>>>>>
>>>>> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
>>>>> index cadefe4fdaa2..f5ce41532cf4 100644
>>>>> --- a/drivers/net/geneve.c
>>>>> +++ b/drivers/net/geneve.c
>>>>> @@ -399,19 +399,7 @@ static struct socket *geneve_create_sock(struct net *net, bool ipv6,
>>>>>
>>>>>  static void geneve_notify_add_rx_port(struct geneve_sock *gs)
>>>>>  {
>>>>> -       struct net_device *dev;
>>>>> -       struct sock *sk = gs->sock->sk;
>>>>> -       struct net *net = sock_net(sk);
>>>>> -       sa_family_t sa_family = geneve_get_sk_family(gs);
>>>>> -       __be16 port = inet_sk(sk)->inet_sport;
>>>>> -
>>>>> -       rcu_read_lock();
>>>>> -       for_each_netdev_rcu(net, dev) {
>>>>> -               if (dev->netdev_ops->ndo_add_geneve_port)
>>>>> -                       dev->netdev_ops->ndo_add_geneve_port(dev, sa_family,
>>>>> -                                                            port);
>>>>> -       }
>>>>> -       rcu_read_unlock();
>>>>> +       udp_tunnel_notify_add_rx_port(gs->sock, UDP_ENC_OFFLOAD_TYPE_GENEVE);
>>>>>  }
>>>>>
>>>>>  static int geneve_hlen(struct genevehdr *gh)
>>>>> @@ -550,20 +538,7 @@ static struct geneve_sock *geneve_socket_create(struct net *net, __be16 port,
>>>>>
>>>>>  static void geneve_notify_del_rx_port(struct geneve_sock *gs)
>>>>>  {
>>>>> -       struct net_device *dev;
>>>>> -       struct sock *sk = gs->sock->sk;
>>>>> -       struct net *net = sock_net(sk);
>>>>> -       sa_family_t sa_family = geneve_get_sk_family(gs);
>>>>> -       __be16 port = inet_sk(sk)->inet_sport;
>>>>> -
>>>>> -       rcu_read_lock();
>>>>> -       for_each_netdev_rcu(net, dev) {
>>>>> -               if (dev->netdev_ops->ndo_del_geneve_port)
>>>>> -                       dev->netdev_ops->ndo_del_geneve_port(dev, sa_family,
>>>>> -                                                            port);
>>>>> -       }
>>>>> -
>>>>> -       rcu_read_unlock();
>>>>> +       udp_tunnel_notify_add_rx_port(gs->sock, UDP_ENC_OFFLOAD_TYPE_GENEVE);
>>>>>  }
>>>>>
>>>>>  static void __geneve_sock_release(struct geneve_sock *gs)
>>>>> @@ -1165,29 +1140,20 @@ static struct device_type geneve_type = {
>>>>>         .name = "geneve",
>>>>>  };
>>>>>
>>>>> -/* Calls the ndo_add_geneve_port of the caller in order to
>>>>> +/* Calls the ndo_add_udp_enc_port of the caller in order to
>>>>>   * supply the listening GENEVE udp ports. Callers are expected
>>>>> - * to implement the ndo_add_geneve_port.
>>>>> + * to implement the ndo_add_udp_enc_port.
>>>>>   */
>>>>>  static void geneve_push_rx_ports(struct net_device *dev)
>>>>>  {
>>>>>         struct net *net = dev_net(dev);
>>>>>         struct geneve_net *gn = net_generic(net, geneve_net_id);
>>>>>         struct geneve_sock *gs;
>>>>> -       sa_family_t sa_family;
>>>>> -       struct sock *sk;
>>>>> -       __be16 port;
>>>>> -
>>>>> -       if (!dev->netdev_ops->ndo_add_geneve_port)
>>>>> -               return;
>>>>>
>>>>>         rcu_read_lock();
>>>>> -       list_for_each_entry_rcu(gs, &gn->sock_list, list) {
>>>>> -               sk = gs->sock->sk;
>>>>> -               sa_family = sk->sk_family;
>>>>> -               port = inet_sk(sk)->inet_sport;
>>>>> -               dev->netdev_ops->ndo_add_geneve_port(dev, sa_family, port);
>>>>> -       }
>>>>> +       list_for_each_entry_rcu(gs, &gn->sock_list, list)
>>>>> +               udp_tunnel_push_rx_port(dev, gs->sock,
>>>>> +                                       UDP_ENC_OFFLOAD_TYPE_GENEVE);
>>>>>         rcu_read_unlock();
>>>>>  }
>>>>>
>>>>> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
>>>>> index f999db2f97b4..43f634282726 100644
>>>>> --- a/drivers/net/vxlan.c
>>>>> +++ b/drivers/net/vxlan.c
>>>>> @@ -622,37 +622,13 @@ static int vxlan_gro_complete(struct sock *sk, struct sk_buff *skb, int nhoff)
>>>>>  /* Notify netdevs that UDP port started listening */
>>>>>  static void vxlan_notify_add_rx_port(struct vxlan_sock *vs)
>>>>>  {
>>>>> -       struct net_device *dev;
>>>>> -       struct sock *sk = vs->sock->sk;
>>>>> -       struct net *net = sock_net(sk);
>>>>> -       sa_family_t sa_family = vxlan_get_sk_family(vs);
>>>>> -       __be16 port = inet_sk(sk)->inet_sport;
>>>>> -
>>>>> -       rcu_read_lock();
>>>>> -       for_each_netdev_rcu(net, dev) {
>>>>> -               if (dev->netdev_ops->ndo_add_vxlan_port)
>>>>> -                       dev->netdev_ops->ndo_add_vxlan_port(dev, sa_family,
>>>>> -                                                           port);
>>>>> -       }
>>>>> -       rcu_read_unlock();
>>>>> +       udp_tunnel_notify_add_rx_port(vs->sock, UDP_ENC_OFFLOAD_TYPE_VXLAN);
>>>>>  }
>>>>>
>>>>>  /* Notify netdevs that UDP port is no more listening */
>>>>>  static void vxlan_notify_del_rx_port(struct vxlan_sock *vs)
>>>>>  {
>>>>> -       struct net_device *dev;
>>>>> -       struct sock *sk = vs->sock->sk;
>>>>> -       struct net *net = sock_net(sk);
>>>>> -       sa_family_t sa_family = vxlan_get_sk_family(vs);
>>>>> -       __be16 port = inet_sk(sk)->inet_sport;
>>>>> -
>>>>> -       rcu_read_lock();
>>>>> -       for_each_netdev_rcu(net, dev) {
>>>>> -               if (dev->netdev_ops->ndo_del_vxlan_port)
>>>>> -                       dev->netdev_ops->ndo_del_vxlan_port(dev, sa_family,
>>>>> -                                                           port);
>>>>> -       }
>>>>> -       rcu_read_unlock();
>>>>> +       udp_tunnel_notify_del_rx_port(vs->sock, UDP_ENC_OFFLOAD_TYPE_VXLAN);
>>>>>  }
>>>>>
>>>>>  /* Add new entry to forwarding table -- assumes lock held */
>>>>> @@ -2525,30 +2501,22 @@ static struct device_type vxlan_type = {
>>>>>         .name = "vxlan",
>>>>>  };
>>>>>
>>>>> -/* Calls the ndo_add_vxlan_port of the caller in order to
>>>>> +/* Calls the ndo_add_udp_enc_port of the caller in order to
>>>>>   * supply the listening VXLAN udp ports. Callers are expected
>>>>> - * to implement the ndo_add_vxlan_port.
>>>>> + * to implement the ndo_add_udp_enc_port.
>>>>>   */
>>>>>  static void vxlan_push_rx_ports(struct net_device *dev)
>>>>>  {
>>>>>         struct vxlan_sock *vs;
>>>>>         struct net *net = dev_net(dev);
>>>>>         struct vxlan_net *vn = net_generic(net, vxlan_net_id);
>>>>> -       sa_family_t sa_family;
>>>>> -       __be16 port;
>>>>>         unsigned int i;
>>>>>
>>>>> -       if (!dev->netdev_ops->ndo_add_vxlan_port)
>>>>> -               return;
>>>>> -
>>>>>         spin_lock(&vn->sock_lock);
>>>>>         for (i = 0; i < PORT_HASH_SIZE; ++i) {
>>>>> -               hlist_for_each_entry_rcu(vs, &vn->sock_list[i], hlist) {
>>>>> -                       port = inet_sk(vs->sock->sk)->inet_sport;
>>>>> -                       sa_family = vxlan_get_sk_family(vs);
>>>>> -                       dev->netdev_ops->ndo_add_vxlan_port(dev, sa_family,
>>>>> -                                                           port);
>>>>> -               }
>>>>> +               hlist_for_each_entry_rcu(vs, &vn->sock_list[i], hlist)
>>>>> +                       udp_tunnel_push_rx_port(dev, vs->sock,
>>>>> +                                               UDP_ENC_OFFLOAD_TYPE_VXLAN);
>>>>>         }
>>>>>         spin_unlock(&vn->sock_lock);
>>>>>  }
>>>>> diff --git a/include/net/udp_tunnel.h b/include/net/udp_tunnel.h
>>>>> index 9d14f707e534..704f931fd9ad 100644
>>>>> --- a/include/net/udp_tunnel.h
>>>>> +++ b/include/net/udp_tunnel.h
>>>>> @@ -84,6 +84,18 @@ struct udp_tunnel_sock_cfg {
>>>>>  void setup_udp_tunnel_sock(struct net *net, struct socket *sock,
>>>>>                            struct udp_tunnel_sock_cfg *sock_cfg);
>>>>>
>>>>> +/* List of offloadable UDP tunnel types */
>>>>> +enum udp_enc_offloads {
>>>>> +       UDP_ENC_OFFLOAD_TYPE_VXLAN,     /* RFC 7348 */
>>>>> +       UDP_ENC_OFFLOAD_TYPE_GENEVE,    /* draft-ietf-nvo3-geneve */
>>>>> +};
>>>>> +
>>>> We've already had a lot of discussion on this. The clear outcome from
>>>> netdev was that we need to support generic offloads and move away from
>>>> protocol specific offload. Generalizing the interface to allow vendors
>>>> to unnecessarily leak out protocol specific features undermines that
>>>> effort.
>>>
>>> Then in turn we get dirty hacks like what we have right now where
>>> VXLAN-GPE is attempting to reuse the VXLAN offload functions or
>>> drivers that just hard-code GENEVE ports.
>>>
>>> Going full obstructionist on this isn't going to work.  We need to be
>>> able to support these type of offloads because the switch vendors are
>>> going to force the NIC vendors to do so.  We will likely never be able
>>> to convince Cisco to implement an outer transmit checksum on their
>>> switches.  In order to make offloads work without the outer checksum
>>> we will need to be able to parse the frames in order to be able to
>>> validate the inner checksum values.
>>>
>> NIC vendors can support checksum-complete. This works with any form of
>> UDP encapsulation, and IP protocol (like extension headers), and other
>> form of tunneling we can dream up. That was the whole point of Dave's
>> keynote at netdev.
>
> Right.  That covers one tiny piece of the whole problem, but you are
> holding out for hardware that may not be introduced for another 3 to 5
> years.  The fact is trying to getting NIC vendors to support
> checksum-complete is all well and good, but you seem to have forgotten
> that NIC vendors are incredibly slow when it comes to implementing
> anything.  In the meantime we will have the stuff that was already in
> the pipeline coming out over the next several years.
>
> How about the fact that we need to know that there is a tunnel there
> if we want to do anything like try to parse the inner headers of a
> given tunnel on Rx?  How do you propose to solve the RSS problem?

Solved by doing RSS and ECMP hash over 3-tuple of IP addresses and
IPv6 flow label (not ports). Non-zero flow labels will soon be widely
used over the Internet. IOS already is already setting them, Android
should pick up support in the next rebase, and the MS guys have
assured me that they will add support to next version of Windows. Like
a generic checksum offload, flow label works with an IP protocol,
extension header, fragmentation, UDP encapsulation, etc. With this
there is no reason for devices to parse L4 headers just to forward a
packet. HW vendors (both switches and NICs) are strongly encouraged to
support them.

> Enabling hashing on UDP source and destination port is okay-ish but
> runs into the issue that the tunnel can be potentially fragmented.  In
> addition any other fragmented UDP flows end up now being received with
> potential out-of-order issues on the system.
>
> There ends up being a number of reasons why you need to have this.
> You can argue about checksum-complete all you want but in the end it
> doesn't matter because simple things like flow identification and
> steering will always be an issue regardless of how the checksum is
> handled.
>
> - Alex
