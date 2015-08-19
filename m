From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH ipsec-next] xfrm: Use VRF master index if output device
 is enslaved
Date: Wed, 19 Aug 2015 11:35:55 -0700
Message-ID: <55D4CC8B.1080306@cumulusnetworks.com>
References: <1439913296-6026-1-git-send-email-dsa@cumulusnetworks.com> <0723F8F1-7349-45FF-BE9C-D2667DA28E0A@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33693 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751687AbbHSSf6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 14:35:58 -0400
Received: by padfo6 with SMTP id fo6so2474514pad.0
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 11:35:58 -0700 (PDT)
In-Reply-To: <0723F8F1-7349-45FF-BE9C-D2667DA28E0A@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/19/15 5:47 AM, Nikolay Aleksandrov wrote:
>
>> On Aug 18, 2015, at 6:54 PM, David Ahern <dsa@cumulusnetworks.com> w=
rote:
>>
>> Directs route lookups to VRF table. Compiles out if NET_VRF is not
>> enabled. With this patch able to successfully bring up ipsec tunnels
>> in VRFs, even with duplicate network configuration (IPv4 tested).
>>
>> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
>> ---
>> net/ipv4/xfrm4_policy.c | 7 +++++--
>> net/ipv6/xfrm6_policy.c | 7 +++++--
>> 2 files changed, 10 insertions(+), 4 deletions(-)
>
> I think you should use the new vrf_master_index() helper that acquire=
s rcu because
> it looks possible to call ->decode_session() without rcu read lock, e=
=2Eg. in the hold_timer
> function xfrm_policy_queue_process(), though I haven=E2=80=99t tested=
 it and might be missing
> something. :-)

I was digging into code paths yesterday. Today I added WARN_ON and seem=
s=20
like the rcu_read_lock is held:

         if (skb_dst(skb)) {
WARN_ON(!rcu_read_lock_held() && !rcu_read_lock_bh_held());
                 oif =3D vrf_master_ifindex_rcu(skb_dst(skb)->dev) ?
                         : skb_dst(skb)->dev->ifindex;
pr_info("_decode_session: oif %d skb_dst(skb)->dev->ifindex %d\n", oif,=
=20
skb_dst(skb)->dev->ifindex);
         }

I get the printk, but not the WARN_ON splat.
