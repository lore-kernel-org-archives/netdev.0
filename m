From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [RFC PATCH net-next 5/5] bridge: vlan lwt dst_metadata hooks
 in ingress and egress paths
Date: Sun, 22 Jan 2017 07:27:33 -0800
Message-ID: <5884CF65.3030705@cumulusnetworks.com>
References: <1484977616-1541-1-git-send-email-roopa@cumulusnetworks.com> <1484977616-1541-6-git-send-email-roopa@cumulusnetworks.com> <b0977994-907d-6868-197f-b9fe25a5632b@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        stephen@networkplumber.org, tgraf@suug.ch,
        hannes@stressinduktion.org, jbenc@redhat.com, pshelar@ovn.org,
        dsa@cumulusnetworks.com, hadi@mojatatu.com
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:36521 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751099AbdAVP1g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2017 10:27:36 -0500
Received: by mail-pg0-f43.google.com with SMTP id t6so37465198pgt.3
        for <netdev@vger.kernel.org>; Sun, 22 Jan 2017 07:27:35 -0800 (PST)
In-Reply-To: <b0977994-907d-6868-197f-b9fe25a5632b@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/22/17, 4:15 AM, Nikolay Aleksandrov wrote:
> On 21/01/17 06:46, Roopa Prabhu wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> - ingress hook:
>>     - if port is a lwt tunnel port, use tunnel info in
>>       attached dst_metadata to map it to a local vlan
>> - egress hook:
>>     - if port is a lwt tunnel port, use tunnel info attached to
>>       vlan to set dst_metadata on the skb
>>
>> CC: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>> ---
>> CC'ing Nikolay for some more eyes as he has been trying to keep the
>> bridge driver fast path lite.
>>
>>  net/bridge/br_input.c   |    4 ++++
>>  net/bridge/br_private.h |    4 ++++
>>  net/bridge/br_vlan.c    |   55 +++++++++++++++++++++++++++++++++++++++++++++++
>>  3 files changed, 63 insertions(+)
>>
>> diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
>> index 83f356f..96602a1 100644
>> --- a/net/bridge/br_input.c
>> +++ b/net/bridge/br_input.c
>> @@ -262,6 +262,10 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
>>  		return RX_HANDLER_CONSUMED;
>>  
>>  	p = br_port_get_rcu(skb->dev);
>> +	if (p->flags & BR_LWT_VLAN) {
>> +		if (br_handle_ingress_vlan_tunnel(skb, p, nbp_vlan_group_rcu(p)))
>> +			goto drop;
>> +	}
> Is there any reason to do this so early (perhaps netfilter?) ? If not, you can push it to the vlan __allowed_ingress
> (and rename that function to something else, it does a hundred additional things)
> and avoid this check for all packets if vlans are disabled, thus people using non-vlan filtering
> bridge won't have an additional test in their fast path
>
>
yes, forgot to mention it in the commit log. I had it close to __allowed_ingress in my first version...had to move it up here
because br_nf_pre_routing/br_nf_pre_routing_finish reset the dst...and hence already late..
