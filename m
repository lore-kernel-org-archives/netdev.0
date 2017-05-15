From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] kmod: don't load module unless req process has CAP_SYS_MODULE
Date: Mon, 15 May 2017 13:20:29 -0500
Message-ID: <87r2zqj82a.fsf@xmission.com>
References: <20170514104537.GA29323@kroah.com> <87d1bbo81d.fsf@xmission.com>
        <20170515061059.GB28741@kroah.com>
        <20170515.095228.1483686375235860235.davem@davemloft.net>
        <CAF2d9jjdouSQYVk3kbWyOUEUe5b8S_Q6_Zx2WE_EBZB1cVeEvA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>, gregkh@linuxfoundation.org,
        mahesh@bandewar.net, mingo@kernel.org,
        linux-kernel@vger.kernel.org,
        linux-netdev <netdev@vger.kernel.org>, keescook@chromium.org,
        Eric Dumazet <edumazet@google.com>
To: =?utf-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS1?=
         =?utf-8?B?4KS+4KSwKQ==?= <maheshb@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAF2d9jjdouSQYVk3kbWyOUEUe5b8S_Q6_Zx2WE_EBZB1cVeEvA@mail.gmail.com>
        (Mahesh Bandewar's message of "Mon, 15 May 2017 10:59:55 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Mahesh Bandewar (महेश बंडेवार)" <maheshb@google.com> writes:

> On Mon, May 15, 2017 at 6:52 AM, David Miller <davem@davemloft.net> wrote:
>> From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
>> Date: Mon, 15 May 2017 08:10:59 +0200
>>
>>> On Sun, May 14, 2017 at 08:57:34AM -0500, Eric W. Biederman wrote:
>>>> Greg Kroah-Hartman <gregkh@linuxfoundation.org> writes:
>>>>
>>>> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
>>>> index bcb0f610ee42..6b72528a4636 100644
>>>> --- a/net/core/rtnetlink.c
>>>> +++ b/net/core/rtnetlink.c
>>>> @@ -2595,7 +2595,7 @@ static int rtnl_newlink(struct sk_buff *skb, struct nlmsghdr *nlh,
>>>>
>>>>                 if (!ops) {
>>>>  #ifdef CONFIG_MODULES
>>>> -                       if (kind[0]) {
>>>> +                       if (kind[0] && capable(CAP_NET_ADMIN)) {
>>>>                                 __rtnl_unlock();
>>>>                                 request_module("rtnl-link-%s", kind);
>>>>                                 rtnl_lock();
>>>
>>> I don't object to this if the networking developers don't mind the
>>> change in functionality.  They can handle the fallout :)
>>
>> As I've said in another email, I am pretty sure this can break things.
>
> The current behavior is already breaking things. e.g. unprivileged
> process can be root inside it's own user-ns. This will allow it to
> create IPtable rules causing contracking module to be loaded in
> default-ns affecting every flow on the server (not just the namespace
> that user or an unprivileged process is attached to). Cases that I
> mentioned above are just the tip of an iceberg.

If loading the conntrack module changes the semantics of packet
processing when nothing is configured that is a bug in the conntrack
module.

> In a non-namespace world this wouldn't happen as capability checks are
> performed correctly but the moment an unprivileged user can create
> it's own user-ns and becomes root inside, it could make use of these
> things and perform privileged operations in default-ns. So to protect
> "global namespace" from making such things happen, we have to protect
> using global capability check.
>
> Alternatively we can preserve the existing behavior by adding this
> check for non-default-user-ns only. e.g.

I believe last time this was discussed the compromise was that a prefix
would be prepended to request_module calls so that what each call
allows to be loaded would be limited in scope to what is sensible
in that location.

I don't think anyone made any arguments about increasing the
attack surface at that time.  So there may be reason to go back
and reexamine the decision on security grounds, but it needs
to be a clearly made argument.  Explaining to people the pros and cons
of the reason to perform the work.

> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 6e67315ec368..263f0d175091 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -2595,7 +2595,9 @@ static int rtnl_newlink(struct sk_buff *skb,
> struct nlmsghdr *nlh,
>
>                 if (!ops) {
>  #ifdef CONFIG_MODULES
> -                       if (kind[0]) {
> +                       if (kind[0] &&
> +                           ((net->user_ns == &init_user_ns) ||
> +                            capable(CAP_SYS_MODULE))) {
>                                 __rtnl_unlock();
>                                 request_module("rtnl-link-%s", kind);
>                                 rtnl_lock();

This patch is definitely wrong.  CAP_NET_ADMIN had always guarded this
request_module call.  CAP_SYS_MODULE means you can request any module
you like dropping does not mean you can't request modules.

Adding a capable(CAP_NET_ADMIN) at this call site would be the least
breaking solution available, as it would only break things for callers
in non-initial network namespaces.  Your change would definitely things
for ordinary network administration tools with capabilities.

> if we have to do this in net-subsystem then it's not just this call
> site and there are lot more. But if this is an acceptable alternative,
> I can think of better implementation for all those sites.

Eric
