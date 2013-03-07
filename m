From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH net-next 3/3] bridge: Implement IFF_UNICAST_FLT
Date: Wed, 06 Mar 2013 19:10:58 -0800
Message-ID: <51380542.4020601@gmail.com>
References: <1362623485-18209-1-git-send-email-vyasevic@redhat.com> <1362623485-18209-4-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:63559 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751757Ab3CGDMG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 22:12:06 -0500
Received: by mail-ob0-f178.google.com with SMTP id wd20so1091obb.9
        for <netdev@vger.kernel.org>; Wed, 06 Mar 2013 19:12:05 -0800 (PST)
In-Reply-To: <1362623485-18209-4-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/06/2013 06:31 PM, Vlad Yasevich wrote:
> Implement IFF_UNICAST_FLT on the bridge.  Unicast addresses added
> to the bridge device are synched to the uplink devices.  This
> allows for uplink devices to change while preserving mac assignment.
>
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> ---

[...]

> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
> index b0812c9..ef7b51e 100644
> --- a/net/bridge/br_fdb.c
> +++ b/net/bridge/br_fdb.c
> @@ -677,6 +677,9 @@ int br_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
>   	struct net_port_vlans *pv;
>   	unsigned short vid = VLAN_N_VID;
>
> +	if ((ndm->ndm_flags & NTF_SELF) && (dev->priv_flags & IFF_EBRIDGE))
> +		return ndo_dflt_fdb_add(ndm, tb, dev, addr, nlh_flags);
> +
>   	if (!(ndm->ndm_state & (NUD_PERMANENT|NUD_NOARP|NUD_REACHABLE))) {
>   		pr_info("bridge: RTM_NEWNEIGH with invalid state %#x\n", ndm->ndm_state);
>   		return -EINVAL;
> @@ -774,6 +777,9 @@ int br_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
>   	struct net_port_vlans *pv;
>   	unsigned short vid = VLAN_N_VID;
>
> +	if ((ndm->ndm_flags & NTF_SELF) && (dev->priv_flags & IFF_EBRIDGE))
> +		return ndo_dflt_fdb_del(ndm, tb, dev, addr);
> +
>   	if (tb[NDA_VLAN]) {
>   		if (nla_len(tb[NDA_VLAN]) != sizeof(unsigned short)) {
>   			pr_info("bridge: RTM_NEWNEIGH with invalid vlan\n");
>

How is this different then calling the fdb op from rtnetlink.c when the
NTF_SELF bit is set after your previous patch

	net: generic fdb support for drivers without ndo_fdb_<op>

the generic routine gets called if a specific op is not supplied via
ndo ops anyways right?

Also I suspect if the driver supplies a specific ndo_fdb_<op> we should
use it over the generic one.

What am I missing?

Thanks,
John

-- 
John Fastabend         Intel Corporation
