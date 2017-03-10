From: Andy Zhou <azhou@ovn.org>
Subject: Re: [RFC net-next sample action optimization 2/3] openvswitch:
 Refactor recirc key allocation.
Date: Fri, 10 Mar 2017 13:44:33 -0800
Message-ID: <CABKoBm2x_hQfGpj7=VOy357nNWGUdMx2xHfT=MbPvmOK4oECbA@mail.gmail.com>
References: <1488932137-120383-1-git-send-email-azhou@ovn.org>
 <1488932137-120383-3-git-send-email-azhou@ovn.org> <CAPWQB7FsjZ7aUXBT+uH_ht6gu5b4URhAirkX2UX95jTzOZ7g5w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, pravin shelar <pshelar@ovn.org>
To: Joe Stringer <joe@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:53170 "EHLO
        relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934115AbdCJVpb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 16:45:31 -0500
Received: from mfilter32-d.gandi.net (mfilter32-d.gandi.net [217.70.178.163])
        by relay6-d.mail.gandi.net (Postfix) with ESMTP id 099C9FB89E
        for <netdev@vger.kernel.org>; Fri, 10 Mar 2017 22:45:19 +0100 (CET)
Received: from relay6-d.mail.gandi.net ([IPv6:::ffff:217.70.183.198])
        by mfilter32-d.gandi.net (mfilter32-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id 5ijipTg_gJC7 for <netdev@vger.kernel.org>;
        Fri, 10 Mar 2017 22:45:17 +0100 (CET)
Received: from mail-pg0-f45.google.com (mail-pg0-f45.google.com [74.125.83.45])
        (Authenticated sender: azhou@ovn.org)
        by relay6-d.mail.gandi.net (Postfix) with ESMTPSA id BDA46FB8A0
        for <netdev@vger.kernel.org>; Fri, 10 Mar 2017 22:45:15 +0100 (CET)
Received: by mail-pg0-f45.google.com with SMTP id 25so43283902pgy.0
        for <netdev@vger.kernel.org>; Fri, 10 Mar 2017 13:45:15 -0800 (PST)
In-Reply-To: <CAPWQB7FsjZ7aUXBT+uH_ht6gu5b4URhAirkX2UX95jTzOZ7g5w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 9, 2017 at 11:11 AM, Joe Stringer <joe@ovn.org> wrote:
> On 7 March 2017 at 16:15, Andy Zhou <azhou@ovn.org> wrote:
>> The logic of allocating and copy key for each 'exec_actions_level'
>> was specific to execute_recirc(). However, future patches will reuse
>> as well.  Refactor the logic into its own function clone_key().
>>
>> Signed-off-by: Andy Zhou <azhou@ovn.org>
>> ---
>
> <snip>
>
>> @@ -83,14 +83,32 @@ struct action_fifo {
>>         struct deferred_action fifo[DEFERRED_ACTION_FIFO_SIZE];
>>  };
>>
>> -struct recirc_keys {
>> -       struct sw_flow_key key[OVS_DEFERRED_ACTION_THRESHOLD];
>> +struct action_flow_keys {
>> +       struct sw_flow_key key[OVS_ACTION_RECURSION_THRESHOLD];
>>  };
>
> I thought the old struct name was clearer on how it would be used -
> for when actions are deferred.

O.K. I will revert it.
>
>>
>>  static struct action_fifo __percpu *action_fifos;
>> -static struct recirc_keys __percpu *recirc_keys;
>> +static struct action_flow_keys __percpu *flow_keys;
>>  static DEFINE_PER_CPU(int, exec_actions_level);
>>
>> +/* Make a clone of the 'key', using the pre-allocated percpu 'flow_keys'
>> + * space. Since the storage is pre-allocated, the caller does not
>> + * need to check for NULL return pointer.
>> + */
>
> Hmm? if level > OVS_ACTION_RECURSION_THRESHOLD, this function returns NULL.
Thanks for catching this. I will update the comment.
