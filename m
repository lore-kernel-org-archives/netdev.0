From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next-2.6 PATCH 02/10] ethtool: add ntuple flow specifier to
 network flow classifier
Date: Fri, 25 Feb 2011 21:30:17 -0800
Message-ID: <AANLkTi=P0v1+h=TjC2j5k0zM-2BF22tbaoGpKBAjNd7-@mail.gmail.com>
References: <20110225232357.7920.58559.stgit@gitlad.jf.intel.com>
	<20110225233249.7920.70334.stgit@gitlad.jf.intel.com>
	<1298682048.3555.18.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Duyck <alexander.h.duyck@intel.com>, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:51670 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751300Ab1BZFaT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Feb 2011 00:30:19 -0500
Received: by wyg36 with SMTP id 36so2249862wyg.19
        for <netdev@vger.kernel.org>; Fri, 25 Feb 2011 21:30:17 -0800 (PST)
In-Reply-To: <1298682048.3555.18.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 25, 2011 at 5:00 PM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Fri, 2011-02-25 at 15:32 -0800, Alexander Duyck wrote:
>> This change is meant to add an ntuple define type to the rx network =
flow
>> classification specifiers. =A0The idea is to allow ntuple to be disp=
layed and
>> possibly configured via the network flow classification interface. =A0=
To do
>> this I added a ntuple_flow_spec_ext to the lsit of supported filters=
, and
>> added a flow_type_ext value to the structure in an unused hole withi=
n the
>> ethtool_rx_flow_spec structure.
>
> There's a hole there on 64-bit architectures. =A0Unfortunately, on i3=
86
> and other architectures where u64 is not 64-bit-aligned, there isn't.
> We actually need to add compat handling for the commands that use it.
>
> Also, we don't want these flags to be ignored by older kernel version=
s
> and drivers - they should reject specs that they don't understand. =A0=
So
> any extension flags need to be added to flow_type.
>
>> Due to the fact that the flow specifier structures are only 4 byte a=
ligned
>> instead of 8 I had to break the user data field into 2 sections. =A0=
In
>> addition I added the vlan ethertype field since this is what ixgbe w=
as
>> using the user-data for currently and it allows for the fields to st=
ay 4
>> byte aligned while occupying space at the end of the flow_spec.
>>
>> In order to guarantee byte ordering I also thought it best to keep a=
ll
>> fields in the flow_spec area a big endian value, as such I added vla=
n, vlan
>> ethertype, and data as big endian values.
>
> It's not important that byte order is consistent across architectures=
=2E
>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>> ---
>>
>> =A0include/linux/ethtool.h | =A0 20 ++++++++++++++++++++
>> =A01 files changed, 20 insertions(+), 0 deletions(-)
>>
>> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
>> index aac3e2e..3d1f8e0 100644
>> --- a/include/linux/ethtool.h
>> +++ b/include/linux/ethtool.h
>> @@ -378,10 +378,25 @@ struct ethtool_usrip4_spec {
>> =A0};
>>
>> =A0/**
>> + * struct ethtool_ntuple_spec_ext - flow spec extension for ntuple =
in nfc
>> + * @unused: space unused by extension
>> + * @vlan_etype: EtherType for vlan tagged packet to match
>> + * @vlan_tci: VLAN tag to match
>> + * @data: Driver-dependent data to match
>> + */
>> +struct ethtool_ntuple_spec_ext {
>> + =A0 =A0 __be32 =A0unused[15];
>> + =A0 =A0 __be16 =A0vlan_etype;
>> + =A0 =A0 __be16 =A0vlan_tci;
>> + =A0 =A0 __be32 =A0data[2];
>> +};
> [...]
>
> This is a really nasty way to reclaim space in the union.
>
> Let's name the union, shrink it and insert the extra fields that way:
>
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -377,27 +377,43 @@ struct ethtool_usrip4_spec {
> =A0 =A0 =A0 =A0__u8 =A0 =A0proto;
> =A0};
>
> +union ethtool_flow_union {
> + =A0 =A0 =A0 struct ethtool_tcpip4_spec =A0 =A0 =A0 =A0 =A0 =A0 =A0t=
cp_ip4_spec;
> + =A0 =A0 =A0 struct ethtool_tcpip4_spec =A0 =A0 =A0 =A0 =A0 =A0 =A0u=
dp_ip4_spec;
> + =A0 =A0 =A0 struct ethtool_tcpip4_spec =A0 =A0 =A0 =A0 =A0 =A0 =A0s=
ctp_ip4_spec;
> + =A0 =A0 =A0 struct ethtool_ah_espip4_spec =A0 =A0 =A0 =A0 =A0 ah_ip=
4_spec;
> + =A0 =A0 =A0 struct ethtool_ah_espip4_spec =A0 =A0 =A0 =A0 =A0 esp_i=
p4_spec;
> + =A0 =A0 =A0 struct ethtool_usrip4_spec =A0 =A0 =A0 =A0 =A0 =A0 =A0u=
sr_ip4_spec;
> + =A0 =A0 =A0 struct ethhdr =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 ether_spec;
> + =A0 =A0 =A0 __u8 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0hdata[52];
> +};
> +
> +struct ethtool_flow_ext {
> + =A0 =A0 =A0 __be16 =A0vlan_etype;
> + =A0 =A0 =A0 __be16 =A0vlan_tci;
> + =A0 =A0 =A0 __be32 =A0data[2];
> + =A0 =A0 =A0 __u32 =A0 reserved[2];
> +};
> +

Any chance of getting the reserved fields moved to the top of the
structure?  My only concern is that we might end up with a flow spec
larger than 52 bytes at some point and moving the reserved fields to
the front might give us a little more wiggle room future
compatibility.

> =A0/**
> =A0* struct ethtool_rx_flow_spec - specification for RX flow filter
> =A0* @flow_type: Type of match to perform, e.g. %TCP_V4_FLOW
> =A0* @h_u: Flow fields to match (dependent on @flow_type)
> + * @h_ext: Additional fields to match
> =A0* @m_u: Masks for flow field bits to be ignored
> + * @m_ext: Masks for additional field bits to be ignored.
> + * =A0 =A0 Note, all additional fields must be ignored unless @flow_=
type
> + * =A0 =A0 includes the %FLOW_EXT flag.
> =A0* @ring_cookie: RX ring/queue index to deliver to, or %RX_CLS_FLOW=
_DISC
> =A0* =A0 =A0 if packets should be discarded
> =A0* @location: Index of filter in hardware table
> =A0*/
> =A0struct ethtool_rx_flow_spec {
> =A0 =A0 =A0 =A0__u32 =A0 =A0 =A0 =A0 =A0 flow_type;
> - =A0 =A0 =A0 union {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct ethtool_tcpip4_spec =A0 =A0 =A0 =
=A0 =A0 =A0 =A0tcp_ip4_spec;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct ethtool_tcpip4_spec =A0 =A0 =A0 =
=A0 =A0 =A0 =A0udp_ip4_spec;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct ethtool_tcpip4_spec =A0 =A0 =A0 =
=A0 =A0 =A0 =A0sctp_ip4_spec;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct ethtool_ah_espip4_spec =A0 =A0 =A0=
 =A0 =A0 ah_ip4_spec;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct ethtool_ah_espip4_spec =A0 =A0 =A0=
 =A0 =A0 esp_ip4_spec;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct ethtool_usrip4_spec =A0 =A0 =A0 =
=A0 =A0 =A0 =A0usr_ip4_spec;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct ethhdr =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 ether_spec;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 __u8 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0hdata[72];
> - =A0 =A0 =A0 } h_u, m_u;
> + =A0 =A0 =A0 union ethtool_flow_union h_u;
> + =A0 =A0 =A0 struct ethtool_flow_ext h_ext;
> + =A0 =A0 =A0 union ethtool_flow_union m_u;
> + =A0 =A0 =A0 struct ethtool_flow_ext m_ext;
> =A0 =A0 =A0 =A0__u64 =A0 =A0 =A0 =A0 =A0 ring_cookie;
> =A0 =A0 =A0 =A0__u32 =A0 =A0 =A0 =A0 =A0 location;
> =A0};
> @@ -954,6 +970,8 @@ struct ethtool_ops {
> =A0#define =A0 =A0 =A0 =A0IPV4_FLOW =A0 =A0 =A0 0x10 =A0 =A0/* hash o=
nly */
> =A0#define =A0 =A0 =A0 =A0IPV6_FLOW =A0 =A0 =A0 0x11 =A0 =A0/* hash o=
nly */
> =A0#define =A0 =A0 =A0 =A0ETHER_FLOW =A0 =A0 =A00x12 =A0 =A0/* spec o=
nly (ether_spec) */
> +/* Flag to enable additional fields in struct ethtool_rx_flow_spec *=
/
> +#define =A0 =A0 =A0 =A0FLOW_EXT =A0 =A0 =A0 =A00x80000000
>
> =A0/* L3-L4 network traffic flow hash options */
> =A0#define =A0 =A0 =A0 =A0RXH_L2DA =A0 =A0 =A0 =A0(1 << 1)
> ---
>
> Ben.

This works for my purposes other than the one comment above.  However
if you are fine with it I am good with it since I can't think of any
filters that we might need in the near future that would require more
than 52 bytes.

Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
