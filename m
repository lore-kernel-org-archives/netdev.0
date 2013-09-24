From: Vincent Li <vincent.mc.li@gmail.com>
Subject: Re: [PATCH] Allow userspace code to use flag IFA_F_SECONDARY to
 specify an ip address to be primary or secondary ip on an interface
Date: Tue, 24 Sep 2013 14:54:29 -0700
Message-ID: <CAK3+h2x_RwCynqwnDHE_fqHhSHrE+LQ6UohxKGpmYxfBBbK_Wg@mail.gmail.com>
References: <1380046281-6012-1-git-send-email-vincent.mc.li@gmail.com>
	<alpine.LFD.2.00.1309242255350.1875@ja.ssi.bg>
	<CAK3+h2y8eAKFC7BbnDwfZLzTw=t-G9qWSqznp4ggwDy7R_O6Ag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org, davem@davemloft.net
To: Julian Anastasov <ja@ssi.bg>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAK3+h2y8eAKFC7BbnDwfZLzTw=t-G9qWSqznp4ggwDy7R_O6Ag@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

sorry Julian to miss your point after reading the __inet_del_ifa and
see the rtmsg_ifa, fib_del_ifaddr/fib_add_ifaddr, I can try another
patch and actually test if the patches changes works as it is
intended, not just checking from ip binary output.

Vincent

On Tue, Sep 24, 2013 at 2:34 PM, Vincent Li <vincent.mc.li@gmail.com> wrote:
> Thanks Julian for the comments, I imagined it would not be so simple
> as it changed old behavior with ip binary and some actions in
> __inet_del_ifa() that I am not fully aware of. my intention is to
> preserve the old behavior and extend the flexibility, I am unable to
> come up with a good patch to achieve the intended behavior.
>
> I had to patch the ip binary to sort of preserve original ip binary
> behavior with the kernel patch I provided., the ip command patch
> below:
>
> diff --git a/ip/ipaddress.c b/ip/ipaddress.c
> index 1c3e4da..9f2802c 100644
> --- a/ip/ipaddress.c
> +++ b/ip/ipaddress.c
> @@ -1259,6 +1259,7 @@ static int ipaddr_modify(int cmd, int flags, int
> argc, char **argv)
>         req.n.nlmsg_flags = NLM_F_REQUEST | flags;
>         req.n.nlmsg_type = cmd;
>         req.ifa.ifa_family = preferred_family;
> +       req.ifa.ifa_flags |= IFA_F_SECONDARY;
>
>         while (argc > 0) {
>                 if (strcmp(*argv, "peer") == 0 ||
> @@ -1307,6 +1308,11 @@ static int ipaddr_modify(int cmd, int flags,
> int argc, char **argv)
>                                 invarg("invalid scope value.", *argv);
>                         req.ifa.ifa_scope = scope;
>                         scoped = 1;
> +                } else if (strcmp(*argv, "secondary") == 0 ||
> +                           strcmp(*argv, "temporary") == 0) {
> +                        req.ifa.ifa_flags |= IFA_F_SECONDARY;
> +                } else if (strcmp(*argv, "primary") == 0) {
> +                        req.ifa.ifa_flags &= ~IFA_F_SECONDARY;
>                 } else if (strcmp(*argv, "dev") == 0) {
>                         NEXT_ARG();
>                         d = *argv;
>
> if someone can point me to the right patch directions or coming up
> with better patches, it is very much appreciated.
>
>
> On Tue, Sep 24, 2013 at 2:13 PM, Julian Anastasov <ja@ssi.bg> wrote:
>>
>>         Hello,
>>
>> On Tue, 24 Sep 2013, Vincent Li wrote:
>>
>>> the current behavior is when an IP is added to an interface, the primary
>>> or secondary attributes is depending on the order of ip added to the interface
>>> the first IP will be primary and second, third,... or alias IP will be secondary
>>> if the IP subnet matches
>>>
>>> this patch add the flexiblity to allow user to specify an argument 'primary' or 'secondary'
>>> (use 'ip addr add ip/mask primary|secondary dev ethX ' from iproute2 for example) to specify
>>> an IP address to be  primary or secondary.
>>>
>>> the reason for this patch is that we have a multi blade cluster platform sharing 'floating management ip'
>>> and also that each blade has its own management ip on the management interface, so whichever blade in the
>>> cluster becomes primary blade, the 'floating mangaement ip' follows it, and we want any of our traffic
>>> originated from the primary blade source from the 'floating management ip' for consistency. but in this
>>> case, since the local blade management ip is always the primary ip on the mangaement interface and 'floating
>>> management ip' is always secondary, kernel always choose the primary ip as source ip address. thus we would
>>> like to add the flexibility in kernel to allow us to specify which ip to be primary or secondary.
>>>
>>> Signed-off-by: Vincent Li <vincent.mc.li@gmail.com>
>>> ---
>>>  net/ipv4/devinet.c |    9 +++++++--
>>>  1 file changed, 7 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
>>> index a1b5bcb..bfc702a 100644
>>> --- a/net/ipv4/devinet.c
>>> +++ b/net/ipv4/devinet.c
>>> @@ -440,9 +440,11 @@ static int __inet_insert_ifa(struct in_ifaddr *ifa, struct nlmsghdr *nlh,
>>>               return 0;
>>>       }
>>>
>>> -     ifa->ifa_flags &= ~IFA_F_SECONDARY;
>>>       last_primary = &in_dev->ifa_list;
>>>
>>> +     if((*last_primary) == NULL)
>>> +             ifa->ifa_flags &= ~IFA_F_SECONDARY;
>>> +
>>>       for (ifap = &in_dev->ifa_list; (ifa1 = *ifap) != NULL;
>>>            ifap = &ifa1->ifa_next) {
>>>               if (!(ifa1->ifa_flags & IFA_F_SECONDARY) &&
>>> @@ -458,7 +460,10 @@ static int __inet_insert_ifa(struct in_ifaddr *ifa, struct nlmsghdr *nlh,
>>>                               inet_free_ifa(ifa);
>>>                               return -EINVAL;
>>>                       }
>>> -                     ifa->ifa_flags |= IFA_F_SECONDARY;
>>
>>         There is some confusion here, when ifa has
>> IFA_F_SECONDARY bit set, in the 'else' we set it again.
>> I guess the 'else' part is not needed.
>>
>>> +                        if (!(ifa->ifa_flags & IFA_F_SECONDARY))
>>> +                                ifa1->ifa_flags |= IFA_F_SECONDARY;
>>> +                        else
>>> +                                ifa->ifa_flags |= IFA_F_SECONDARY;
>>
>>         It should not be so simple. You can not
>> just change the flag of existing address (ifa1) to secondary.
>> See __inet_del_ifa(), there are many more actions that
>> follow:
>>
>> - kernel routes that use this primary address
>> should be deleted and recreated with the new primary
>> address as source. This includes local routes to secondary
>> IPs.
>>
>> - RTM_NEWADDR should be sent, so that user space see
>> the IFA_F_SECONDARY flag
>>
>>         Some questions:
>>
>> - should we allow adding of secondary IPs when no primary
>> address exists for the subnet, it can happen when primary
>> for another subnet already exists
>>
>> - by default, existing 'ip addr' binaries will provide
>> address without IFA_F_SECONDARY flag. Before now we added
>> such addresses as last for the subnet, now the
>> behaviour changes, we start to add addresses in reverse
>> order. Is that true? I.e. before now the operation was
>> APPEND, now we need a way to provide PREPEND operation.
>>
>> Regards
>>
>> --
>> Julian Anastasov <ja@ssi.bg>
