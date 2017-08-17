From: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Subject: Re: [PATCH next] neigh: initialize neigh entry correctly during arp processing
Date: Wed, 16 Aug 2017 18:02:33 -0700
Message-ID: <CAF2d9ji7cQ+hYXVChytLyW4Czedx95Myi19NuD5VKOEcvaEqZw@mail.gmail.com>
References: <20170817000251.38469-1-mahesh@bandewar.net> <20170817003215.GQ6984@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Mahesh Bandewar <mahesh@bandewar.net>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        netdev <netdev@vger.kernel.org>,
        Ido Schimmel <idosch@mellanox.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        Kees Cook <keescook@chromium.org>,
        Reshetova Elena <elena.reshetova@intel.com>,
        Florian Westphal <fw@strlen.de>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        Ihar Hrachyshka <ihrachys@redhat.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Zhang Shengju <zhangshengju@cmss.chinamobile.com>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f51.google.com ([209.85.214.51]:33051 "EHLO
        mail-it0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751943AbdHQBCz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 21:02:55 -0400
Received: by mail-it0-f51.google.com with SMTP id f16so458398itb.0
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 18:02:55 -0700 (PDT)
In-Reply-To: <20170817003215.GQ6984@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 16, 2017 at 5:32 PM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> On (08/16/17 17:02), Mahesh Bandewar wrote:
>>
>> From: Mahesh Bandewar <maheshb@google.com>
>>
>> If the ARP processing creates a neigh entry, it's immediately marked
>> as STALE without timer and stays that way in that state as long as
>> host do not send traffic to that neighbour.
>
> Perhaps I dont understand the specific  packet exchange case
> that your patch is trying to fix,  but if the neighbor entry
> is created as a result of an incoming packet (but we have not
> yet sent anything to this neighbor) then it should be marked STALE?
> IOW, STALE means "Ingress path claims this adjacency, but egress
> path has not been verified".  Is the problem that the neigh never
> goes into PROBE?
>
Correct. The entry gets created  (NUD_NONE) and few jiffies later it
gets marked as STALE. It's doesn't even get a chance to get PROBEd.

>> +     if (neigh) {
>> +             if (neigh->nud_state & NUD_VALID)
>> +                     neigh_update(neigh, lladdr, NUD_STALE,
>> +                                  NEIGH_UPDATE_F_OVERRIDE, 0);
>> +             else
>> +                     neigh_event_send(neigh, NULL);
>> +     }
>
> NUD_VALID is already a mask of
>  (NUD_PERMANENT|NUD_NOARP|NUD_REACHABLE|NUD_PROBE|NUD_STALE|NUD_DELAY)
> are you sure you want to force the transition of probe/delay -> stale
> here?
It's not forced and neigh_update() has guards / provision to consider
these type of transition and wont force it. Just that if the state is
not-valid (NUD_INCOMPLETE | NUD_NONE) etc then it marks it STALE and
deletes the timer.

> Maybe it woudl help to describe the exact wire packet
> exchange that is broken today, but fixed by your patch.
>
> --Sowmini
>
>
