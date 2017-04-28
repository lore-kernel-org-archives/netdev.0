From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 10/10] net: sched: extend gact to allow jumping
 to another filter chain
Date: Fri, 28 Apr 2017 15:47:29 +0200
Message-ID: <20170428134729.GF1886@nanopsycho.orion>
References: <1493291540-2119-1-git-send-email-jiri@resnulli.us>
 <1493291540-2119-11-git-send-email-jiri@resnulli.us>
 <bedf1246-4900-ebba-cf78-936989029db9@mojatatu.com>
 <20170428065209.GA1886@nanopsycho.orion>
 <a129147c-8992-9de4-e67c-379236b1f012@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        xiyou.wangcong@gmail.com, dsa@cumulusnetworks.com,
        edumazet@google.com, stephen@networkplumber.org,
        daniel@iogearbox.net, alexander.h.duyck@intel.com,
        mlxsw@mellanox.com, simon.horman@netronome.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:33370 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034350AbdD1Nrb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 09:47:31 -0400
Received: by mail-wr0-f194.google.com with SMTP id w50so7172053wrc.0
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2017 06:47:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <a129147c-8992-9de4-e67c-379236b1f012@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Apr 28, 2017 at 02:23:34PM CEST, jhs@mojatatu.com wrote:
>On 17-04-28 02:52 AM, Jiri Pirko wrote:
>> Fri, Apr 28, 2017 at 03:41:08AM CEST, jhs@mojatatu.com wrote:
>> > 
>> > Jiri,
>> > 
>> > Good stuff!
>> > Thanks for the effort.
>> > 
>> > I didnt review the details - will do. I wanted to raise one issue.
>> > This should work for all actions, not just gact (refer to the
>> > recent commit i made on the action jumping).
>> > 
>> > Example policy for policer:
>> > 
>> > #if packets destined for mac address 52:54:00:3d:c7:6d
>> > #exceed 90kbps with burst of 90K then jump to chain 11
>> > #for further classification, otherwise set their skb mark to 11
>> > # and proceed.
>> > 
>> > tc filter add dev eth0 parent ffff: protocol ip pref 33 \
>> > flower dst_mac 52:54:00:3d:c7:6d \
>> > action police rate 1kbit burst 90k conform-exceed pipe/goto chain 11 \
>> > action skbedit mark 11
>> > 
>> > But i should also be able to do this for any other action, etc.
>> 
>
>[..]
>
>> You can have multiple actions in list and gact goto as the last one. Why
>> to do this ugliness?
>
>To be able to do what I described above ;-> Policer is always a good
>example because it can branch depending on whether a rate is exceeded
>or not.
>
>Another example:
>If you had two tables, one for flows that dont exceed their
>rate and another for flows exceed their rate.
>"match X
>	action police
>	    if exceed
>                goto chain 12
>            else did not exceed
>               tag packet, goto chain 11
>"
>
>But it is not just the policer, other actions as well would benefit.
>
>I am not sure you can achieve that with just gact.

Got it. Sigh, every day I find new oddities in net/sched :)

I will try to figure out how to extend GOTO_CHAIN action for other
actions.

So basically, you suggest to encode chain number into the action opcode,
like you do it in jump, right? For example:
#define TC_ACT_GOTO_CHAIN       0x20000000

And then I will have chainlimit 0x10000000-1

Thanks.
