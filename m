From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [RFC PATCH net-next 3/3] bridge: Implement IFF_UNICAST_FLT
Date: Thu, 07 Mar 2013 10:08:34 -0500
Message-ID: <5138AD72.8080104@redhat.com>
References: <1362623485-18209-1-git-send-email-vyasevic@redhat.com> <1362623485-18209-4-git-send-email-vyasevic@redhat.com> <51380542.4020601@gmail.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2452 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752543Ab3CGPIj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Mar 2013 10:08:39 -0500
In-Reply-To: <51380542.4020601@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/06/2013 10:10 PM, John Fastabend wrote:
> On 03/06/2013 06:31 PM, Vlad Yasevich wrote:
>> Implement IFF_UNICAST_FLT on the bridge.  Unicast addresses added
>> to the bridge device are synched to the uplink devices.  This
>> allows for uplink devices to change while preserving mac assignment.
>>
>> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>> ---
>
> [...]
>
>> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
>> index b0812c9..ef7b51e 100644
>> --- a/net/bridge/br_fdb.c
>> +++ b/net/bridge/br_fdb.c
>> @@ -677,6 +677,9 @@ int br_fdb_add(struct ndmsg *ndm, struct nlattr
>> *tb[],
>>       struct net_port_vlans *pv;
>>       unsigned short vid = VLAN_N_VID;
>>
>> +    if ((ndm->ndm_flags & NTF_SELF) && (dev->priv_flags & IFF_EBRIDGE))
>> +        return ndo_dflt_fdb_add(ndm, tb, dev, addr, nlh_flags);
>> +
>>       if (!(ndm->ndm_state & (NUD_PERMANENT|NUD_NOARP|NUD_REACHABLE))) {
>>           pr_info("bridge: RTM_NEWNEIGH with invalid state %#x\n",
>> ndm->ndm_state);
>>           return -EINVAL;
>> @@ -774,6 +777,9 @@ int br_fdb_delete(struct ndmsg *ndm, struct nlattr
>> *tb[],
>>       struct net_port_vlans *pv;
>>       unsigned short vid = VLAN_N_VID;
>>
>> +    if ((ndm->ndm_flags & NTF_SELF) && (dev->priv_flags & IFF_EBRIDGE))
>> +        return ndo_dflt_fdb_del(ndm, tb, dev, addr);
>> +
>>       if (tb[NDA_VLAN]) {
>>           if (nla_len(tb[NDA_VLAN]) != sizeof(unsigned short)) {
>>               pr_info("bridge: RTM_NEWNEIGH with invalid vlan\n");
>>
>
> How is this different then calling the fdb op from rtnetlink.c when the
> NTF_SELF bit is set after your previous patch
>
>      net: generic fdb support for drivers without ndo_fdb_<op>
>
> the generic routine gets called if a specific op is not supplied via
> ndo ops anyways right?
>
> Also I suspect if the driver supplies a specific ndo_fdb_<op> we should
> use it over the generic one.
>
> What am I missing?

The bridge provides the ndo_fdb_<add|del>, so it will be used.  The 
bridge op assumes that the dev passed to it is a port.  This code adds
support for when dev is the bridge.

In fact this patch is counting that rtnetlink will call into the bridge
and lets bridge do the work.

-vlad
>
> Thanks,
> John
>
