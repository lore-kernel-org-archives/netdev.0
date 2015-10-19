From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [PATCHv2 net 2/3] openvswitch: Treat IP_CT_RELATED as new
Date: Mon, 19 Oct 2015 00:07:09 -0700
Message-ID: <CANr6G5xmO6D0Yu0VXeaJLbO1aK2tQ5_vHUNRkawK1zNFMJz=aw@mail.gmail.com>
References: <1445018901-18839-1-git-send-email-joestringer@nicira.com>
 <1445018901-18839-3-git-send-email-joestringer@nicira.com> <20151017075233.GC13981@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Pravin Shelar <pshelar@nicira.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f182.google.com ([209.85.160.182]:34465 "EHLO
	mail-yk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751209AbbJSHH3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 03:07:29 -0400
Received: by ykfy204 with SMTP id y204so134290344ykf.1
        for <netdev@vger.kernel.org>; Mon, 19 Oct 2015 00:07:28 -0700 (PDT)
In-Reply-To: <20151017075233.GC13981@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17 October 2015 at 00:52, Thomas Graf <tgraf@suug.ch> wrote:
> On 10/16/15 at 11:08am, Joe Stringer wrote:
>> New, related connections are marked as such as part of ovs_ct_lookup(),
>> but they are not marked as "new" if the commit flag is used. Make this
>> consistent by treating IP_CT_RELATED as new as well.
>>
>> Reported-by: Jarno Rajahalme <jrajahalme@nicira.com>
>> Signed-off-by: Joe Stringer <joestringer@nicira.com>
>> Acked-by: Pravin B Shelar <pshelar@nicira.com>
>> ---
>> v2: Acked.
>> ---
>>  net/openvswitch/conntrack.c | 2 ++
>>  1 file changed, 2 insertions(+)
>>
>> diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
>> index 80bf702715bb..480dbb9095b7 100644
>> --- a/net/openvswitch/conntrack.c
>> +++ b/net/openvswitch/conntrack.c
>> @@ -86,6 +86,8 @@ static u8 ovs_ct_get_state(enum ip_conntrack_info ctinfo)
>>               ct_state |= OVS_CS_F_ESTABLISHED;
>>               break;
>>       case IP_CT_RELATED:
>> +             ct_state |= OVS_CS_F_NEW;
>> +             /* Fall through */
>>       case IP_CT_RELATED_REPLY:
>>               ct_state |= OVS_CS_F_RELATED;
>>               break;
>
> I'm probably missing something obvious. Why is the reply direction
> not considered NEW? Wouldn't this consider an ICMPv6 as related+new
> depending on simply the direction?

My thoughts were along the lines "If something is a reply, that
implies that state is held, and therefore it cannot be NEW (where NEW
means no state is available)". However, if you consider that the
'related' connection is an independent connection with its own state,
but the 'reply' bit refers to the original connection, my original
premise breaks. Furthermore, looking at how it's used in netfilter
core and the ICMP proto handler, it looks like both of these cases
should be considered NEW. I can respin.

Do you have a specific case in mind here? It would be useful for
extending the OVS testsuite.
