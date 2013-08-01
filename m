From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next v5 2/7] vxlan: Restructure vxlan receive for
 multiple protocols.
Date: Wed, 31 Jul 2013 20:01:04 -0700
Message-ID: <CALnjE+ogr7PYnEMtAyMmZUzLhTtAdqS3FBOQ1BCvkhjEvCgHqQ@mail.gmail.com>
References: <1375312469-18623-1-git-send-email-pshelar@nicira.com>
	<20130731164749.58b6ee1b@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog134.obsmtp.com ([74.125.149.83]:54421 "HELO
	na3sys009aog134.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752222Ab3HADBG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 23:01:06 -0400
Received: by mail-qc0-f177.google.com with SMTP id e11so806803qcx.36
        for <netdev@vger.kernel.org>; Wed, 31 Jul 2013 20:01:04 -0700 (PDT)
In-Reply-To: <20130731164749.58b6ee1b@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 31, 2013 at 4:47 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Wed, 31 Jul 2013 16:14:29 -0700
> Pravin B Shelar <pshelar@nicira.com> wrote:
>
>> -- a/drivers/net/vxlan.c
>> +++ b/drivers/net/vxlan.c
>> @@ -57,6 +57,7 @@
>>  #define VXLAN_VID_MASK       (VXLAN_N_VID - 1)
>>  /* IP header + UDP + VXLAN + Ethernet header */
>>  #define VXLAN_HEADROOM (20 + 8 + 8 + 14)
>> +#define VXLAN_HLEN (sizeof(struct udphdr) + sizeof(struct vxlanhdr))
>>
>>  #define VXLAN_FLAGS 0x08000000       /* struct vxlanhdr.vx_flags required value. */
>>
>> @@ -82,8 +83,12 @@ static int vxlan_net_id;
>>
>>  static const u8 all_zeros_mac[ETH_ALEN];
>>
>> +struct vxlan_sock;
>> +typedef void (vxlan_rcv_t)(struct vxlan_sock *vh, struct sk_buff *skb, __be32 key);
>> +
>>  /* per UDP socket information */
>>  struct vxlan_sock {
>> +     vxlan_rcv_t      *rcv;
>>       struct hlist_node hlist;
>>       struct rcu_head   rcu;
>>       struct work_struct del_work;
>> @@ -211,6 +216,18 @@ static struct vxlan_dev *vxlan_find_vni(struct net *net, u32 id, __be16 port)
>>       return NULL;
>>  }
>>
>> +static struct vxlan_dev *vxlan_find_vni_port(struct vxlan_sock *vs, u32 id)
>> +{
>> +     struct vxlan_dev *vxlan;
>> +
>> +     hlist_for_each_entry_rcu(vxlan, vni_head(vs, id), hlist) {
>> +             if (vxlan->default_dst.remote_vni == id)
>> +                     return vxlan;
>> +     }
>> +
>> +     return NULL;
>> +}
>> +
>>  /* Fill in neighbour message in skbuff. */
>>  static int vxlan_fdb_info(struct sk_buff *skb, struct vxlan_dev *vxlan,
>>                         const struct vxlan_fdb *fdb,
>> @@ -836,23 +853,16 @@ static void vxlan_igmp_work(struct work_struct *work)
>>  /* Callback from net/ipv4/udp.c to receive packets */
>>  static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
>>  {
>> -     struct iphdr *oip;
>> +     struct vxlan_sock *vs;
>>       struct vxlanhdr *vxh;
>> -     struct vxlan_dev *vxlan;
>> -     struct pcpu_tstats *stats;
>>       __be16 port;
>> -     __u32 vni;
>> -     int err;
>> -
>> -     /* pop off outer UDP header */
>> -     __skb_pull(skb, sizeof(struct udphdr));
>>
>>       /* Need Vxlan and inner Ethernet header to be present */
>> -     if (!pskb_may_pull(skb, sizeof(struct vxlanhdr)))
>> +     if (!pskb_may_pull(skb, VXLAN_HLEN))
>>               goto error;
>
> This patch would be clearer if split into two parts.
> One for the parsing changes (like VXLAN_HLEN) and other for the receive
> callback.

ok, I will send updated patch.
