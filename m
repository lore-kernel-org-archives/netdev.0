From: Michal Sojka <sojkam1@fel.cvut.cz>
Subject: error: 'struct net_device' has no member named 'nf_hooks_ingress'
Date: Wed, 05 Oct 2016 22:56:11 +0200
Message-ID: <87wphm1pn8.fsf@steelpick.2x.cz>
References: <20160927164026.741b290b@canb.auug.org.au> <20160927100324.GA466@swordfish> <20161004004801.GA4661@swordfish>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Stephen Rothwell <sfr@canb.auug.org.au>,
        Florian Westphal <fw@strlen.de>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
        Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
        Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
        Aaron Conole <aconole@bytheb.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161004004801.GA4661@swordfish>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Tue, Oct 04 2016, Sergey Senozhatsky wrote:
> On (09/27/16 19:03), Sergey Senozhatsky wrote:
>> Hello,
>> 
>> On (09/27/16 16:40), Stephen Rothwell wrote:
>> > 
>> > Changes since 20160923:
>> > 
>> 
>> seems that commit e3b37f11e6e4e6b6 ("netfilter: replace list_head with
>> single linked list") breaks the build on !CONFIG_NETFILTER_INGRESS systems
>> accessing ->nf_hooks_ingress

this commit is now in mainline as
e3b37f11e6e4e6b6f02cc762f182ce233d2c1c9d and it breaks my build:

    net/netfilter/core.c: In function 'nf_set_hooks_head':
    net/netfilter/core.c:96:3: error: 'struct net_device' has no member named 'nf_hooks_ingress'

Are the fixes (see below) on the way to mainline too?

Thanks.
-Michal



>> 
>> static void nf_set_hooks_head(struct net *net, const struct nf_hook_ops *reg,
>>                              struct nf_hook_entry *entry)
>> {
>>        switch (reg->pf) {
>>        case NFPROTO_NETDEV:
>>                /* We already checked in nf_register_net_hook() that this is
>>                 * used from ingress.
>>                 */
>>                rcu_assign_pointer(reg->dev->nf_hooks_ingress, entry);
>> 					^^^^^^^^^^^^^^^^^^^^
>
>
> so I see two commits in linux-next now that fix the commit in question in
> two patches
>
>  : commit 7816ec564ec40ae20bb7925f733a181cad0cc491 ("netfilter: accommodate
>  : different kconfig in nf_set_hooks_head")
>  :
>  :    When CONFIG_NETFILTER_INGRESS is unset (or no), we need to handle
>  :    the request for registration properly by dropping the hook.  This
>  :    releases the entry during the set.
>  :
>  :    Fixes: e3b37f11e6e4 ("netfilter: replace list_head with single linked list")
>
> and
>
>  : commit 5119e4381a90fabd3442bde02707cbd9e5d7367a ("netfilter: Fix potential
>  : null pointer dereference")
>  :
>  :    It's possible for nf_hook_entry_head to return NULL.  If two
>  :    nf_unregister_net_hook calls happen simultaneously with a single hook
>  :    entry in the list, both will enter the nf_hook_mutex critical section.
>  :    The first will successfully delete the head, but the second will see
>  :    this NULL pointer and attempt to dereference.
>  :
>  :    This fix ensures that no null pointer dereference could occur when such
>  :    a condition happens.
>  :
>  :    Fixes: e3b37f11e6e4 ("netfilter: replace list_head with single linked list")
>
>
> do you guys plan to fold those into "e3b37f11e6e4" (a preferred way)
> or will send it out as 3 separate patches (um, why) ?
>
> 	-ss
