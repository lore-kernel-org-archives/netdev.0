From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH net 1/2] openvswitch: Fix helper reference leak
Date: Wed, 9 Dec 2015 15:10:21 -0800
Message-ID: <CAPWQB7H5MR-ogQGk0hB=nj3YjxiuPLdoq68xO-KB63U0To-NHQ@mail.gmail.com>
References: <1449698860-20685-1-git-send-email-joe@ovn.org> <CALnjE+q7tXTD9=cywSg8qJY19DPbAb8Tpz8EaBuJRcW8ANZ9ZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:33292 "EHLO
	relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754468AbbLIXKp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 18:10:45 -0500
Received: from mfilter18-d.gandi.net (mfilter18-d.gandi.net [217.70.178.146])
	by relay5-d.mail.gandi.net (Postfix) with ESMTP id 7303D41C091
	for <netdev@vger.kernel.org>; Thu, 10 Dec 2015 00:10:42 +0100 (CET)
Received: from relay5-d.mail.gandi.net ([IPv6:::ffff:217.70.183.197])
	by mfilter18-d.gandi.net (mfilter18-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id kXXZFif4SGka for <netdev@vger.kernel.org>;
	Thu, 10 Dec 2015 00:10:41 +0100 (CET)
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	(Authenticated sender: joe@ovn.org)
	by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id 26E3441C084
	for <netdev@vger.kernel.org>; Thu, 10 Dec 2015 00:10:41 +0100 (CET)
Received: by wmec201 with SMTP id c201so1940945wme.1
        for <netdev@vger.kernel.org>; Wed, 09 Dec 2015 15:10:40 -0800 (PST)
In-Reply-To: <CALnjE+q7tXTD9=cywSg8qJY19DPbAb8Tpz8EaBuJRcW8ANZ9ZQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9 December 2015 at 14:50, Pravin Shelar <pshelar@nicira.com> wrote:
> On Wed, Dec 9, 2015 at 2:07 PM, Joe Stringer <joe@ovn.org> wrote:
>> If the actions (re)allocation fails, or the actions list is larger than the
>> maximum size, and the conntrack action is the last action when these
>> problems are hit, then references to helper modules may be leaked. Fix
>> the issue.
>>
>> Fixes: cae3a2627520 ("openvswitch: Allow attaching helpers to ct action")
>> Signed-off-by: Joe Stringer <joe@ovn.org>
>> ---
>>  net/openvswitch/conntrack.c | 9 ++++++++-
>>  1 file changed, 8 insertions(+), 1 deletion(-)
>>
>> diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
>> index c2cc11168fd5..585a5aa81f89 100644
>> --- a/net/openvswitch/conntrack.c
>> +++ b/net/openvswitch/conntrack.c
>> @@ -53,6 +53,8 @@ struct ovs_conntrack_info {
>>         struct md_labels labels;
>>  };
>>
>> +static void __ovs_ct_free_action(struct ovs_conntrack_info *ct_info);
>> +
>>  static u16 key_to_nfproto(const struct sw_flow_key *key)
>>  {
>>         switch (ntohs(key->eth.type)) {
>> @@ -708,7 +710,7 @@ int ovs_ct_copy_action(struct net *net, const struct nlattr *attr,
>>         nf_conntrack_get(&ct_info.ct->ct_general);
>
> I see another issue here. Updates to ct_info are done after it is
> copied to action list. ct action on the action list and ct_info are
> inconsistent, So it is still leaking nf-conntrack reference.

You're referring to the below?

         __set_bit(IPS_CONFIRMED_BIT, &ct_info.ct->status);
         nf_conntrack_get(&ct_info.ct->ct_general);

ct_info.ct points to the same location as the version that has been
copied into the action list. I agree it's a bit misleading though. If
you're not seeing something else, it seems cosmetic so I can (should?)
follow up on net-next.
