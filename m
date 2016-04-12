From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [RFC PATCH 0/2] selinux: avoid nf hooks overhead when not needed
Date: Tue, 12 Apr 2016 06:57:14 -0700
Message-ID: <570CFEBA.7090001@schaufler-ca.com>
References: <cover.1459934322.git.pabeni@redhat.com>
 <CAHC9VhSZP1QxT-pQeHAW9m1xmyDsbFeA=9b8SdeWgS0RiDTOBA@mail.gmail.com>
 <20160406234532.GA731@breakpoint.cc> <2239567.jkCk1gtQAE@sifl>
 <1460451162.5965.16.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>,
	linux-security-module@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	James Morris <james.l.morris@oracle.com>,
	Andreas Gruenbacher <agruenba@redhat.com>,
	Stephen Smalley <sds@tycho.nsa.gov>, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov, Casey Schaufler <casey@schaufler-ca.com>
To: Paolo Abeni <pabeni@redhat.com>, Paul Moore <paul@paul-moore.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1460451162.5965.16.camel@redhat.com>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/12/2016 1:52 AM, Paolo Abeni wrote:
> On Thu, 2016-04-07 at 14:55 -0400, Paul Moore wrote:
>> On Thursday, April 07, 2016 01:45:32 AM Florian Westphal wrote:
>>> Paul Moore <paul@paul-moore.com> wrote:
>>>> On Wed, Apr 6, 2016 at 6:14 PM, Florian Westphal <fw@strlen.de> wrote:
>>>>> netfilter hooks are per namespace -- so there is hook unregister when
>>>>> netns is destroyed.
>>>> Looking around, I see the global and per-namespace registration
>>>> functions (nf_register_hook and nf_register_net_hook, respectively),
>>>> but I'm looking to see if/how newly created namespace inherit
>>>> netfilter hooks from the init network namespace ... if you can create
>>>> a network namespace and dodge the SELinux hooks, that isn't a good
>>>> thing from a SELinux point of view, although it might be a plus
>>>> depending on where you view Paolo's original patches ;)
>>> Heh :-)
>>>
>>> If you use nf_register_net_hook, the hook is only registered in the
>>> namespace.
>>>
>>> If you use nf_register_hook, the hook is put on a global list and
>>> registed in all existing namespaces.
>>>
>>> New namespaces will have the hook added as well (see
>>> netfilter_net_init -> nf_register_hook_list in netfilter/core.c )
>>>
>>> Since nf_register_hook is used it should be impossible to get a netns
>>> that doesn't call these hooks.
>> Great, thanks.
>>  
>>>>> Do you think it makes sense to rework the patch to delay registering
>>>>> of the netfiler hooks until the system is in a state where they're
>>>>> needed, without the 'unregister' aspect?
>>>> I would need to see the patch to say for certain, but in principle
>>>> that seems perfectly reasonable and I think would satisfy both the
>>>> netdev and SELinux camps - good suggestion.  My main goal is to drop
>>>> the selinux_nf_ip_init() entirely so it can't be used as a ROP gadget.
>>>>
>>>> We might even be able to trim the secmark_active and peerlbl_active
>>>> checks in the SELinux netfilter hooks (an earlier attempt at
>>>> optimization; contrary to popular belief, I do care about SELinux
>>>> performance), although that would mean that enabling the network
>>>> access controls would be one way ... I guess you can disregard that
>>>> last bit, I'm thinking aloud again.
>>> One way is fine I think.
>> Yes, just disregard my second paragraph above.
>>  
>>>>> Ideally this would even be per netns -- in perfect world we would
>>>>> be able to make it so that a new netns are created with an empty
>>>>> hook list.
>>>> In general SELinux doesn't care about namespaces, for reasons that are
>>>> sorta beyond the scope of this conversation, so I would like to stick
>>>> to a all or nothing approach to enabling the SELinux netfilter hooks
>>>> across namespaces.  Perhaps we can revisit this at a later time, but
>>>> let's keep it simple right now.
>>> Okay, I'd prefer to stick to your recommendation anyway wrt. to selinux
>>> (Casey, I read your comment regarding smack. Noted, we don't want to
>>> break smack either...)
>>>
>>> I think that in this case the entire question is:
>>>
>>> In your experience, how likely is a config where selinux is enabled BUT the
>>> hooks are not needed (i.e., where we hit the
>>>
>>> if (!selinux_policycap_netpeer)
>>>     return NF_ACCEPT;
>>>
>>> if (!secmark_active && !peerlbl_active)
>>>    return NF_ACCEPT;
>>>
>>> tests inside the hooks)?  If such setups are uncommon we should just
>>> drop this idea or at least put it on the back burner until the more
>>> expensive netfilter hooks (conntrack, cough) are out of the way.
>> A few years ago I would have said that it is relatively uncommon for admins to 
>> enable the SELinux network access controls; it was typically just 
>> government/intelligence agencies who had very strict access control 
>> requirements and represented a small portion of SELinux users.  However, over 
>> the past few years I've been fielding more and more questions from admins/devs 
>> in the virtualization space who are interested in some of these capabilities; 
>> it isn't clear to me how many of these people are switching it on, but there 
>> is definitely more interest than I have seen in the past and the interested is 
>> centered around some rather common use cases.
>>
>> So, to summarize, I don't know ;)
>>
>> If you've got bigger sources of overhead, my opinion would be to go tackle 
>> those first.  Perhaps I can even find the time to work on the 
>> SELinux/netfilter stuff while you are off slaying the bigger dragons, no 
>> promises at the moment.
> Double checking if I got the above correctly.
>
> Will be ok if we post a v2 version of this series, removing the hooks
> de-registration bits, but preserving the selinux nf-hooks and
> socket_sock_rcv_skb() on-demand/delayed registration ?

Imagine that I have two security modules that control sockets.
The work I'm knee deep in will allow this. If adding hooks after
the init phase is allowed you have to face the possibility that
blob sizes (in this case sock->sk_security) may change. That
requires checking on every hook that uses blobs to determine
whether the blob has data for all the modules using it. I know
that that is a simple matter of arithmetic, but it's additional
overhead on every hook call. It also makes creating kmem caches
for security blobs much more difficult. Another performance
optimization that becomes unavailable.

We know of a number of ways we can improve networking performance
in the face of security modules. Many would make the code a whole
lot cleaner. Your proposed change is clever, but targets one case
at the expense of the general case. If there really is concern
about the performance of networking in the presence of security
modules I would suggest that we revisit some of the changes that
have already been proposed.

>  Will that fit
> with the post-init read only memory usage that you are planning ?
>
> Regards,
>
> Paolo
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-security-module" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

