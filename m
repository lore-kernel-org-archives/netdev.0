From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH v2 net-next] VXLAN: Precompute vin for VXLAN header.
Date: Tue, 26 Mar 2013 16:57:12 -0700
Message-ID: <CALnjE+pDezZ26=1kPOPAC4GNuaarsgFnp16NeT=JM=Ag__f84Q@mail.gmail.com>
References: <1364333594-8809-1-git-send-email-pshelar@nicira.com>
	<OF76F7D73D.E7992933-ON85257B3A.0077FC53-85257B3A.007CE48E@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, jesse@nicira.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog125.obsmtp.com ([74.125.149.153]:33835 "HELO
	na3sys009aog125.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752573Ab3CZX5O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 19:57:14 -0400
Received: by mail-qa0-f69.google.com with SMTP id o13so1647384qaj.0
        for <netdev@vger.kernel.org>; Tue, 26 Mar 2013 16:57:12 -0700 (PDT)
In-Reply-To: <OF76F7D73D.E7992933-ON85257B3A.0077FC53-85257B3A.007CE48E@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 26, 2013 at 3:44 PM, David Stevens <dlstevens@us.ibm.com> wrote:
> netdev-owner@vger.kernel.org wrote on 03/26/2013 05:33:14 PM:
>
>>
>> Compute VXLAN vin at time of device create so that there is no need
>> to translate it on packet send and receive.
>> This patch do not change userspace interface.
>
>         The name of the field is "VNI" (Virtual Network Identifier), not
> "vin")
>
>> -static inline struct hlist_head *vni_head(struct net *net, u32 id)
>> +static u32 vni_to_vid(__be32 vni)
>> +{
>> +   return ntohl(vni) >> 8;
>> +}
>> +
>> +static __be32 vid_to_vni(u32 id)
>> +{
>> +   return htonl(id << 8);
>> +}
>
>         What's a "vid"? I know what you're trying to do here, but like
> "vin",
> it is not proper VXLAN terminology. I don't think these need to be
> functions at all, but rather simply in-line code. I think renaming
> this as a "vid" just obscures what it is.
>         Changing it to a bitfield of the right size and place might
> be more proper, but probably not worth the complexity.
>         But if you want them to be functions (or, I'd prefer macros),
> I'd suggest something like hton_vni() and ntoh_vni() -- transforming
> between the host and packet (network) formats -- and adding "inline".
>
>> +
>> +static inline struct hlist_head *vni_head(struct net *net, __be32 id)
>>  {
>>     struct vxlan_net *vn = net_generic(net, vxlan_net_id);
>>
>> -   return &vn->vni_list[hash_32(id, VNI_HASH_BITS)];
>> +   return &vn->vni_list[hash_32((__force u32)id, VNI_HASH_BITS)];
>>  }
>>
>>  /* Look up VNI in a per net namespace table */
>> -static struct vxlan_dev *vxlan_find_vni(struct net *net, u32 id)
>> +static struct vxlan_dev *vxlan_find_vni(struct net *net, __be32 id)
>>  {
>>     struct vxlan_dev *vxlan;
>>
>> @@ -195,7 +205,7 @@ static int vxlan_fdb_info(struct sk_buff *skb,
>> struct vxlan_dev *vxlan,
>>         nla_put_be16(skb, NDA_PORT, rdst->remote_port))
>>        goto nla_put_failure;
>>     if (rdst->remote_vni != vxlan->vni &&
>> -       nla_put_be32(skb, NDA_VNI, rdst->remote_vni))
>> +       nla_put_be32(skb, NDA_VNI, vni_to_vid(rdst->remote_vni)))
>>        goto nla_put_failure;
>>     if (rdst->remote_ifindex &&
>>         nla_put_u32(skb, NDA_IFINDEX, rdst->remote_ifindex))
>> @@ -261,7 +271,7 @@ static void vxlan_ip_miss(struct net_device
>> *dev, __be32 ipa)
>>     memset(&f, 0, sizeof f);
>>     f.state = NUD_STALE;
>>     f.remote.remote_ip = ipa; /* goes to NDA_DST */
>> -   f.remote.remote_vni = VXLAN_N_VID;
>> +   f.remote.remote_vni = vid_to_vni(VXLAN_N_VID);
>
>         This is not correct -- VXLAN_N_VID is an invalid VNI with
> value 1<<24. Applying vid_to_vni() makes it 1<<32 (==0 since it's 32
> bits wide). To do the same thing correctly here, you'd either need to
> make it 64 bits, or now set a bit in the low-order byte and then have
> that transform to 1<<24 in host representation.
>
> So, perhaps [again, ought to have a name changes], so:
>
> static u32 ntoh_vni(__be32 vni)
> {
>         if (vni & 0xff)
>                 return VXLAN_N_VID;
>         return ntohl(vni) >> 8;
> }
>
> static __be32 hton_vni(u32 id)
> {
>         if (vni >= VXLAN_N_VID)
>                 return 1;
>         return htonl(id << 8);
> }
>
>         Or, instead of "1", you could use a define of VXLAN_N_VID_NET or
> some such.
>         Of course, that'll work internally only as long as the reserved
> bits in the packet are 0; if they're used for something else, you need
> to mask them before calling this.
>
>         All in all, I'm not sure it's worth the trouble for a few
> byte-swaps.
>

right, there is no simple solution to avoid byte swaps here, I will
drop this patch for now.
