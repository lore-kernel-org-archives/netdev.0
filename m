From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v4 2/8] netdevice: add IPv4 fib add/del ops
Date: Fri, 6 Mar 2015 11:59:10 -0800
Message-ID: <CAE4R7bAcfJ8M0eQMdZdS3aDgPVWSQznABZymGq+PU34vJx1suA@mail.gmail.com>
References: <1425619280-27492-1-git-send-email-sfeldma@gmail.com>
	<1425619280-27492-3-git-send-email-sfeldma@gmail.com>
	<54F9BFCB.5030100@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	"alexander.h.duyck@redhat.com" <alexander.h.duyck@redhat.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:41451 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752368AbbCFT7L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 14:59:11 -0500
Received: by qgea108 with SMTP id a108so15291122qge.8
        for <netdev@vger.kernel.org>; Fri, 06 Mar 2015 11:59:10 -0800 (PST)
In-Reply-To: <54F9BFCB.5030100@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 6, 2015 at 6:55 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 03/06/15 00:21, sfeldma@gmail.com wrote:
>>
>> From: Scott Feldman <sfeldma@gmail.com>
>>
>> Add two new ndo ops for IPv4 fib offload support, add and del.  Add uses
>> modifiy semantics if fib entry already offloaded.
>
>
>
> The above semantic will not express correctly the intent that the tools
> like iproute2 expose and user space expects.
> I think you need to pass the netlink flags to do it correctly at
> the driver level.
> i.e classical table operations per netlink flags (NLM_F_CREATE,
> NLM_F_REPLACE, NLM_F_EXCL, NLM_F_APPEND)
>
> 1) Create: NLM_F_CREATE
> 2) Create exclusively i.e reject if already created
> (NLM_F_CREATE|NLM_F_EXCL)
> 3) Create or modify (which is the semantic you are refering to)
> NLM_F_CREATE|NLM_F_REPLACE
> 4) Append - which means "I dont care if it exists, just append it"
> NLM_F_CREATE|NLM_F_APPEND

I considered passing netlink flags in to driver, but the kernel logic
in fib_table_insert() already takes care of the checks required by the
flags, and from the driver's perspective, only three ops are needed:
add, del, and mod.  And I've combined add and mod into the same op,
with the assumption the driver can know if an entry exists or not.

Can it work?

Let's try the various user cmds and see what happens:

ip route add ...             CREATE|EXCL

    if kernel FIB entry exists
        return -EEXIST to user
    else
        call driver add op
        add kernel FIB entry

ip route change ...        REPLACE

    if kernel FIB entry exists
        call driver add op             // driver treats this as a mod
        modify kernel FIB entry
    else
        return -ENOENT

ip route replace ...         CREATE|REPLACE

    if kernel FIB entry exists
         call driver add op             // driver treats this as a mod
         modify kernel FIB entry
    else
        call driver add op
        add kernel FIB entry

ip route prepend ...        CREATE

    if kernel FIB entry exists
         call driver add op             // driver treats this as a mod
         prepend kernel FIB entry
    else
        call driver add op
        add kernel FIB entry

ip route append ...          CREATE|APPEND

    if kernel FIB entry exists
         call driver add op             // driver treats this as a mod
         append kernel FIB entry
    else
        call driver add op
        add kernel FIB entry


I'm not 100% on the prepend/append cases.  Maybe don't try to offload
prepend/append cases?
