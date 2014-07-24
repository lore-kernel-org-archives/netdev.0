From: Jesse Gross <jesse@nicira.com>
Subject: Re: [net-next 10/10] openvswitch: Add support for Geneve tunneling.
Date: Thu, 24 Jul 2014 00:10:41 -0400
Message-ID: <CAEP_g=_1q3ACX5NTHxLDnysL+dTMUVzdLpgw1apLKEdDSWPztw@mail.gmail.com>
References: <1406024393-6778-1-git-send-email-azhou@nicira.com>
 <1406024393-6778-11-git-send-email-azhou@nicira.com> <CA+mtBx8UWoQhgGoXtyh=hHkhbodZyC8JSxnCfZFM5CpUT1ZZ9A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Zhou <azhou@nicira.com>, David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog137.obsmtp.com ([74.125.149.18]:41217 "HELO
	na3sys009aog137.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750720AbaGXELD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2014 00:11:03 -0400
Received: by mail-qa0-f43.google.com with SMTP id w8so2366604qac.30
        for <netdev@vger.kernel.org>; Wed, 23 Jul 2014 21:11:01 -0700 (PDT)
In-Reply-To: <CA+mtBx8UWoQhgGoXtyh=hHkhbodZyC8JSxnCfZFM5CpUT1ZZ9A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 23, 2014 at 4:29 PM, Tom Herbert <therbert@google.com> wrote:
> On Tue, Jul 22, 2014 at 3:19 AM, Andy Zhou <azhou@nicira.com> wrote:
>> diff --git a/net/openvswitch/vport-geneve.c b/net/openvswitch/vport-geneve.c
>> new file mode 100644
>> index 0000000..b1b0a3b
>> --- /dev/null
>> +++ b/net/openvswitch/vport-geneve.c
>> +static void geneve_rcv(struct geneve_sock *gs, struct sk_buff *skb)
>> +{
>> +       struct vport *vport = gs->uts.data;
>> +       struct genevehdr *geneveh;
>> +       int opts_len;
>> +       struct ovs_tunnel_info tun_info;
>> +       __be64 key;
>> +       __be16 flags;
>> +
>> +       if (unlikely(!pskb_may_pull(skb, GENEVE_BASE_HLEN)))
>> +               goto error;
>> +
>> +       geneveh = geneve_hdr(skb);
>> +
>> +       if (unlikely(geneveh->ver != GENEVE_VER))
>> +               goto error;
>
>> +
>> +       if (unlikely(geneveh->proto_type != htons(ETH_P_TEB)))
>
> Why? I thought the point of geneve carrying protocol field was to
> allow protocols other than Ethernet... is this temporary maybe?

Yes, it is temporary. Currently OVS only handles Ethernet packets but
this restriction can be lifted once we have a consumer that is capable
of handling other protocols.

> This check also applies in the OAM case where there is no data packet
> but we still enforce the protocol field to be Ethernert (meaning of
> prot_type when OAM bit is set is ambiguous in the draft). As I
> mentioned on the nvo3 list, this OAM bit is really a 1-bit packet
> type. If this bit is donated to version field (make it a type version
> field) then we can switch on ver_type above and create another
> processing path for OAM so that the prot_type is at least not
> unnecessarily verified in that case and the bits could even be reused
> for some OAM specific purpose.

I think the draft is clear :) The value of the OAM bit does not change
the interpretation of the protocol field. This is true in the other
drafts as well.

OAM packets are essentially just high priority packets (presumably
with some kind of control semantics but that depends on the control
plane). That means that they might be BFD or some other heartbeat,
header fragments for tracing, or really anything else that should be
treated as control. In all of these cases, the protocol type still
needs to indicate the format of the data.

>> +               goto error;
>> +
>> +       opts_len = geneveh->opt_len * 4;
>> +
>> +       flags = TUNNEL_KEY |
>> +               (udp_hdr(skb)->check != 0 ? TUNNEL_CSUM : 0) |
>> +               (geneveh->oam ? TUNNEL_OAM : 0) |
>> +               (geneveh->critical ? TUNNEL_CRIT_OPT : 0);
>
> Three conditionals in critical data path just extract the flags and
> not even do anything with them :-(. Also why should OVS care about
> checksum, it has already been validated at this point?

These flags are included in the flow structure, so they are consumed
by userspace.

OVS isn't validating the checksum, it's just marking which packets
have a checksum so that policy can be enforced. (I think you have
talked about something similar in the past - "I only want to accept
packets with a checksum even if no checksum is allowed by the
protocol.")

>> +static int geneve_send(struct vport *vport, struct sk_buff *skb)
>> +{
>> +       struct ovs_key_ipv4_tunnel *tun_key;
>> +       struct ovs_tunnel_info *tun_info = OVS_CB(skb)->tun_info;
>> +       struct net *net = ovs_dp_get_net(vport->dp);
>> +       struct geneve_port *geneve_port = geneve_vport(vport);
>> +       __be16 dport = inet_sk(geneve_port->gs->uts.sock->sk)->inet_sport;
>> +       __be16 sport;
>> +       struct rtable *rt;
>> +       struct flowi4 fl;
>> +       u8 vni[3];
>> +       __be16 df;
>> +       int err;
>> +       int sent;
>> +
>> +       if (unlikely(!tun_info))
>> +               return -EINVAL;
>> +
>> +       tun_key = &tun_info->tunnel;
>> +
>> +       /* Route lookup */
>> +       memset(&fl, 0, sizeof(fl));
>> +       fl.daddr = tun_key->ipv4_dst;
>> +       fl.saddr = tun_key->ipv4_src;
>> +       fl.flowi4_tos = RT_TOS(tun_key->ipv4_tos);
>> +       fl.flowi4_mark = skb->mark;
>> +       fl.flowi4_proto = IPPROTO_UDP;
>> +
>> +       rt = ip_route_output_key(net, &fl);
>
> Route lookup on every packet? No route cached in the flow structs?

This is a possible future optimization.
