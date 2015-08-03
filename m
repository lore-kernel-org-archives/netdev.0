From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [PATCH net-next 5/9] openvswitch: Add conntrack action
Date: Mon, 3 Aug 2015 15:58:28 -0700
Message-ID: <CANr6G5yt-2jXSms=7Cxdc+90nrJoYkexa9q2GEpC8GudCR4GgA@mail.gmail.com>
References: <1438279963-29563-1-git-send-email-joestringer@nicira.com>
 <1438279963-29563-6-git-send-email-joestringer@nicira.com> <CALnjE+qdMA08zWRj_uDw0BQvQ1Q6H+C9Pz+ey1cM7_xX2EawFg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, pablo <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Justin Pettit <jpettit@nicira.com>,
	Andy Zhou <azhou@nicira.com>, Jesse Gross <jesse@nicira.com>,
	Florian Westphal <fwestpha@redhat.com>,
	Hannes Sowa <hannes@redhat.com>,
	Thomas Graf <tgraf@noironetworks.com>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALnjE+qdMA08zWRj_uDw0BQvQ1Q6H+C9Pz+ey1cM7_xX2EawFg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 31 July 2015 at 19:08, Pravin Shelar <pshelar@nicira.com> wrote:
> On Thu, Jul 30, 2015 at 11:12 AM, Joe Stringer <joestringer@nicira.com> wrote:
>> +static void prepare_frag(struct vport *vport, struct sw_flow_key *key,
>> +                        struct sk_buff *skb)
>> +{
>> +       unsigned int hlen = ETH_HLEN;
>> +       struct ovs_frag_data *data;
>> +
>> +       data = this_cpu_ptr(&ovs_frag_data_storage);
>> +       data->dst = skb_dst(skb);
>> +       data->vport = vport;
>> +       data->key = key;
>> +       data->cb = *OVS_CB(skb);
>> +
>> +       if (key->eth.tci & htons(VLAN_TAG_PRESENT)) {
>> +               if (skb_vlan_tag_present(skb)) {
>> +                       data->vlan_proto = skb->vlan_proto;
>> +               } else {
>> +                       data->vlan_proto = vlan_eth_hdr(skb)->h_vlan_proto;
>> +                       hlen += VLAN_HLEN;
>> +               }
>> +       }
> Not all actions keep flow key uptodate, so here you can access stale values.

Hmm, okay. Perhaps the right thing to handle all of these cases is to
just make a copy of everything up to the network offset, and restore
that after fragmentation.

>>                 if (unlikely(err)) {
>> -                       kfree_skb(skb);
>> +                       /* Hide stolen fragments from user space. */
>> +                       if (err == -EINPROGRESS)
>> +                               err = 0;
> This does not look safe for error returned from all cases, Can you
> check this case specifically for the CT action case.

I'll place it inside the CT action case.

Thanks for the review, will roll the other fixes into the next version.
