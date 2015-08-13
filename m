From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next 3/6] geneve: Add support to collect tunnel metadata.
Date: Thu, 13 Aug 2015 14:13:21 -0700
Message-ID: <CAEP_g=-APpY2QprRTiRNq1Ptfjut_TeUNuQy=+HDXxm7HX=y4w@mail.gmail.com>
References: <1439356664-21784-1-git-send-email-pshelar@nicira.com>
 <CAEP_g=8_BLeNjxpraZ4zYpJwurXROtxoSSzvanSMupJzVZ6d9Q@mail.gmail.com> <CALnjE+oRojsyuxTsDsahmJCxyK=26PgX9jS+4WJvWbXEmX-4og@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:33653 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751452AbbHMVNm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 17:13:42 -0400
Received: by lbbsx3 with SMTP id sx3so34491322lbb.0
        for <netdev@vger.kernel.org>; Thu, 13 Aug 2015 14:13:40 -0700 (PDT)
In-Reply-To: <CALnjE+oRojsyuxTsDsahmJCxyK=26PgX9jS+4WJvWbXEmX-4og@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 12, 2015 at 4:08 PM, Pravin Shelar <pshelar@nicira.com> wrote:
> On Wed, Aug 12, 2015 at 1:53 PM, Jesse Gross <jesse@nicira.com> wrote:
>> On Tue, Aug 11, 2015 at 10:17 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
>>> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
>>> index 5e9bab8..a463383 100644
>>> --- a/drivers/net/geneve.c
>>> +++ b/drivers/net/geneve.c
>>> +static struct geneve_dev *geneve_lookup(struct geneve_net *gn,
>>> +                                       struct iphdr *iph,
>>> +                                       struct genevehdr *gnvh)
>>>  {
>>> -       struct genevehdr *gnvh = geneve_hdr(skb);
>>> -       struct geneve_dev *dummy, *geneve = NULL;
>>> -       struct geneve_net *gn;
>>> -       struct iphdr *iph = NULL;
>>> -       struct pcpu_sw_netstats *stats;
>>>         struct hlist_head *vni_list_head;
>>> -       int err = 0;
>>> +       struct geneve_dev *geneve;
>>>         __u32 hash;
>>>
>>> -       iph = ip_hdr(skb); /* Still outer IP header... */
>>> -
>>> -       gn = gs->rcv_data;
>>> -
>>>         /* Find the device for this VNI */
>>>         hash = geneve_net_vni_hash(gnvh->vni);
>>>         vni_list_head = &gn->vni_list[hash];
>>> -       hlist_for_each_entry_rcu(dummy, vni_list_head, hlist) {
>>> -               if (!memcmp(gnvh->vni, dummy->vni, sizeof(dummy->vni)) &&
>>> -                   iph->saddr == dummy->remote.sin_addr.s_addr) {
>>> -                       geneve = dummy;
>>> -                       break;
>>> +       hlist_for_each_entry_rcu(geneve, vni_list_head, hlist) {
>>> +               if (!memcmp(gnvh->vni, geneve->vni, sizeof(geneve->vni)) &&
>>> +                   iph->saddr == geneve->remote.sin_addr.s_addr) {
>>> +                       return geneve;
>>>                 }
>>>         }
>>> +
>>> +       return rcu_dereference(gn->collect_md_tun);
>>> +}
>>
>> I think this operates differently from VXLAN (and GRE I believe) where
>> you can't have tunnels based on the VNI overlapping the
>> collect_md_tun. VXLAN is nice because it can go straight from the
>> socket to collecting metadata without having to an additional lookup
>> that doesn't give any additional information and it seems a little
>> simpler because we don't need to keep track of a flow-based device.
>> However, at the very least the behavior should be consistent.
>>
> This is how GRE works. But I can check for flow based device first to
> keep it consistent with vxlan.

Besides the lookup order, VXLAN will also disallow this configuration
at creation time.
