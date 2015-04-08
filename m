From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 net-next 2/2] tc: make ingress and egress qdiscs consistent
Date: Wed, 08 Apr 2015 12:54:32 +0200
Message-ID: <552508E8.5050203@iogearbox.net>
References: <1428455025-5945-1-git-send-email-ast@plumgrid.com> <1428455025-5945-2-git-send-email-ast@plumgrid.com> <20150407.223549.335906307265617841.davem@davemloft.net> <55249EFA.5040405@plumgrid.com> <5524B339.1070403@plumgrid.com> <5524E878.7070803@iogearbox.net> <20150408090520.GA2057@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	David Miller <davem@davemloft.net>, jhs@mojatatu.com,
	netdev@vger.kernel.org, tgraf@suug.ch
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:50151 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751368AbbDHKyv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 06:54:51 -0400
In-Reply-To: <20150408090520.GA2057@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/08/2015 11:05 AM, Jiri Pirko wrote:
> Wed, Apr 08, 2015 at 10:36:08AM CEST, daniel@iogearbox.net wrote:
>> On 04/08/2015 06:48 AM, Alexei Starovoitov wrote:
>>> On 4/7/15 8:22 PM, Alexei Starovoitov wrote:
>>>> but it seems no one cares about using them with ingress, so I'll go back
>>>> to cls_bpf specific skb_share_check and push.
>>>
>>> that didn't work either :(
>>> we cannot replace skb via skb_share_check() inside cls/act. We cannot do
>>> it inside ingress_enqueue() either. It can only be done at handle_ing()
>>> level. And it's quite ugly to change the signatures of the whole
>>> qdisc->enqueue() call chain just for cls_bpf. May be introducing
>>> bpf-only ingress qdisc to decouple the logic is not such a bad idea?
>>
>> So it seems ingress qdisc is quite broken for various classifier
>> and actions. :/ I wouldn't go that far to have a bpf-only ingress
>> qdisc, but what about introducing l2/l3 ingress qdisc (or, name
>> it "early ingress" and "ingress" qdisc), so at an early point in
>> netif_receive_skb_internal(), we would have an l2_ingress hook,
>> wrapped via static keys to have minimal impact if unused, and could
>> do the push/pull similarly as in the PTP classifier w/o worry that
>> it is referenced by other entities. There, we could at least still
>> benefit from hw flow steering.
>
> How about to just adjust ingress qdisc to do the right thing (of adjust
> egress qdisc so they both behave the same). I don't like the idea of
> having more ingres queue disk. Would be just confusing.

I'm all for it, that's what I've mentioned earlier in this thread
already. ;) The above would be one possibility, but of course I'm
open for other, better suggestions?

I totally agree with Dave that skb_share_check() should be avoided
at all costs. At least on my laptop (maybe not a perfect example),
I've got these as packet socket users present in the background,
so there are packet users running all the time where we would hit
skb_share_check() then:

# ss -0lnp
Netid  State      Recv-Q Send-Q      Local Address:Port    Peer Address:Port
p_raw  UNCONN     0      0                *:wlp2s0b1       *      users:(("dhclient",1290,5))
p_dgr  UNCONN     0      0          [34958]:wlp2s0b1       *      users:(("wpa_supplicant",805,13))
p_dgr  UNCONN     0      0              [0]:*              *      users:(("wpa_supplicant",805,12))

I do not yet see a generic way to push an offset down into various
classifiers and actions that otherwise don't really work with ingress,
it's not just limited to BPF only as Alexei already mentioned. Hm.

Cheers,
Daniel
