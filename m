From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [PATCHv3 net-next 06/10] openvswitch: Allow matching on conntrack mark
Date: Wed, 12 Aug 2015 16:41:45 -0700
Message-ID: <CANr6G5yozw+sBAtKJp6+P2v_m2YhxiDiEK1HoUwM9_LHc45xSA@mail.gmail.com>
References: <1439333961-24474-1-git-send-email-joestringer@nicira.com>
 <1439333961-24474-7-git-send-email-joestringer@nicira.com> <CALnjE+rzFhJf67wd3NceKAmu1_vTw_NFeztNc=T2Fo1kRRsKaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Justin Pettit <jpettit@nicira.com>,
	LKML <linux-kernel@vger.kernel.org>, pablo <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Andy Zhou <azhou@nicira.com>, Jesse Gross <jesse@nicira.com>,
	Florian Westphal <fwestpha@redhat.com>,
	Hannes Sowa <hannes@redhat.com>,
	Thomas Graf <tgraf@noironetworks.com>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f174.google.com ([209.85.160.174]:33172 "EHLO
	mail-yk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751169AbbHLXmF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 19:42:05 -0400
Received: by ykaz130 with SMTP id z130so28118404yka.0
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 16:42:04 -0700 (PDT)
In-Reply-To: <CALnjE+rzFhJf67wd3NceKAmu1_vTw_NFeztNc=T2Fo1kRRsKaQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12 August 2015 at 16:00, Pravin Shelar <pshelar@nicira.com> wrote:
> On Tue, Aug 11, 2015 at 3:59 PM, Joe Stringer <joestringer@nicira.com> wrote:
>> From: Justin Pettit <jpettit@nicira.com>
>>
>> Allow matching and setting the conntrack mark field. As with conntrack
>> state and zone, these are populated by executing the ct() action. Unlike
>> these, the ct_mark is also a writable field. The set_field() action may
>> be used to modify the mark, which will take effect on the most recent
>> conntrack entry.
>>
>> E.g.: actions:ct(zone=0),ct(zone=1),set_field(1->ct_mark)
>>
>> This will perform conntrack lookup in zone 0, then lookup in zone 1,
>> then modify the mark for the entry in zone 1. The mark for the entry in
>> zone 0 is unchanged. The conntrack entry itself must be committed using
>> the "commit" flag in the conntrack action flags for this change to persist.
>>
>> Signed-off-by: Justin Pettit <jpettit@nicira.com>
>> Signed-off-by: Joe Stringer <joestringer@nicira.com>
>> ---
> ...
>
>>
>> +int ovs_ct_set_mark(struct sk_buff *skb, struct sw_flow_key *key,
>> +                   u32 ct_mark, u32 mask)
>> +{
>> +#ifdef CONFIG_NF_CONNTRACK_MARK
>> +       enum ip_conntrack_info ctinfo;
>> +       struct nf_conn *ct;
>> +       u32 new_mark;
>> +
>> +       /* This must happen directly after lookup/commit. */
>> +       ct = nf_ct_get(skb, &ctinfo);
>> +       if (!ct)
>> +               return -EINVAL;
>> +
>> +       new_mark = ct_mark | (ct->mark & ~(mask));
>> +       if (ct->mark != new_mark) {
>> +               ct->mark = new_mark;
>> +               nf_conntrack_event_cache(IPCT_MARK, ct);
>> +               key->ct.mark = ct_mark;
>> +       }
>> +
>
> Is it fine to set just set mark and not initialize reset of key->ct members?

I don't quite follow. This action acts upon the current connection,
and modifies its metadata. key->ct should already be populated with
the existing connection info.
