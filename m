From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [PATCH net-next 5/9] openvswitch: Add conntrack action
Date: Fri, 31 Jul 2015 11:35:20 -0700
Message-ID: <CANr6G5zA7ZdcZtn5sqCJfUzoCWOaBowu6=imeWTt6Oc49WZUeQ@mail.gmail.com>
References: <1438279963-29563-1-git-send-email-joestringer@nicira.com>
 <1438279963-29563-6-git-send-email-joestringer@nicira.com> <1438354361.20479.15.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Justin Pettit <jpettit@nicira.com>,
	Pravin Shelar <pshelar@nicira.com>,
	Andy Zhou <azhou@nicira.com>, Jesse Gross <jesse@nicira.com>,
	Florian Westphal <fwestpha@redhat.com>,
	Thomas Graf <tgraf@noironetworks.com>
To: Hannes Frederic Sowa <hannes@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f171.google.com ([209.85.160.171]:36607 "EHLO
	mail-yk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751210AbbGaSfk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 14:35:40 -0400
Received: by ykay190 with SMTP id y190so66021948yka.3
        for <netdev@vger.kernel.org>; Fri, 31 Jul 2015 11:35:39 -0700 (PDT)
In-Reply-To: <1438354361.20479.15.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for review,

On 31 July 2015 at 07:52, Hannes Frederic Sowa <hannes@redhat.com> wrote:
> On Thu, 2015-07-30 at 11:12 -0700, Joe Stringer wrote:
>> +static void prepare_frag(struct vport *vport, struct sw_flow_key
>> *key,
>> +                      struct sk_buff *skb)
>> +{
>> +     unsigned int hlen = ETH_HLEN;
>> +     struct ovs_frag_data *data;
>> +
>> +     data = this_cpu_ptr(&ovs_frag_data_storage);
>> +     data->dst = skb_dst(skb);
>
>
> If data->dst is unsigned long, we could simply use an assignment:
>
> data->dst = skb->_skb_refdst;
>
> At this point we never leave rcu_read_lock section, so we are safe,
> maybe we can add a comment for that.

OK, it also may be helpful to highlight that prepare_frag() is done
once for an assembled frame, then ovs_vport_output() performs the
inverse for each fragment. I'll do this.

...
>> +             } else if (key->eth.type == htons(ETH_P_IP)) {
>> +                     struct dst_entry ovs_dst;
>> +
>> +                     prepare_frag(vport, key, skb);
>> +                     dst_init(&ovs_dst, &ovs_dst_ops, vport->dev,
>> +                              1, DST_OBSOLETE_NONE, DST_NOCOUNT);
>
> I don't think we should take a ref on the netdev here.
>
> dst_init(&ovs_dst, &ovs_dst_ops, NULL,
>          1, DST_OBSOLETE_NONE, DST_NOCOUNT);
> ovs_dst.dev = vport->dev;

Some of this was me being overly cautious: take a ref on the dev for
as long as the fragment dst exists; take a ref on the original (eg
tunnel_metadata) dst for the length of handling the output of this
frame.

>> +
>> +                     skb_dst_drop(skb);
>> +                     skb_dst_set_noref(skb, &ovs_dst);
>> +                     IPCB(skb)->frag_max_size = mru;
>> +
>> +                     ip_do_fragment(skb->sk, skb,
>> ovs_vport_output);
>> +                     dev_put(ovs_dst.dev);
>
> Can be removed then.
>
> It seems a little strange to leave the skb->dst attached to the skb but
> drop the reference from the netdevice here. Maybe a comment would make
> sense, otherwise it smells fishy.

For each fragment, ovs_vport_output() will revert the changes made
here - restoring the original dst. Either way, if we're not taking a
ref on the netdev then this should be fine.
