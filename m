From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH iptables 3/3] libxt_hashlimit: iptables-restore does not
 work as expected with xt_hashlimit
Date: Thu, 23 Jun 2016 12:25:11 +0200
Message-ID: <20160623102511.GA10493@salvia>
References: <20160602001759.GF1644@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, kadlec@blackhole.kfki.hu,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	johunt@akamai.com, netdev@vger.kernel.org, pai.vishwain@gmail.com
To: Vishwanath Pai <vpai@akamai.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160602001759.GF1644@akamai.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 01, 2016 at 08:17:59PM -0400, Vishwanath Pai wrote:
> libxt_hashlimit: iptables-restore does not work as expected with xt_hashlimit
> 
> Add the following iptables rule.
> 
> $ iptables -A INPUT -m hashlimit --hashlimit-above 200/sec \
>   --hashlimit-burst 5 --hashlimit-mode srcip --hashlimit-name hashlimit1 \
>   --hashlimit-htable-expire 30000 -j DROP
> 
> $ iptables-save > save.txt
> 
> Edit save.txt and change the value of --hashlimit-above to 300:
> 
> -A INPUT -m hashlimit --hashlimit-above 300/sec --hashlimit-burst 5 \
> --hashlimit-mode srcip --hashlimit-name hashlimit2 \
> --hashlimit-htable-expire 30000 -j DROP
> 
> Now restore save.txt
> 
> $ iptables-restore < save.txt

In this case, we don't end up with two rules, we actually get one
single hashlimit rule, given the sequence you provide.

        $ iptables-save > save.txt
        ... edit save.txt
        $ iptables-restore < save.txt

> Now userspace thinks that the value of --hashlimit-above is 300 but it is
> actually 200 in the kernel. This happens because when we add multiple
> hash-limit rules with the same name they will share the same hashtable
> internally. The kernel module tries to re-use the old hashtable without
> updating the values.
> 
> There are multiple problems here:
> 1) We can add two iptables rules with the same name, but kernel does not
>    handle this well, one procfs file cannot work with two rules
> 2) If the second rule has no effect because the hashtable has values from
>    rule 1
> 3) hashtable-restore does not work (as described above)
> 
> To fix this I have made the following design change:
> 1) If a second rule is added with the same name as an existing rule,
>    append a number when we create the procfs, for example hashlimit_1,
>    hashlimit_2 etc
> 2) Two rules will not share the same hashtable unless they are similar in
>    every possible way
> 3) This behavior has to be forced with a new userspace flag:
>    --hashlimit-ehanced-procfs, if this flag is not passed we default to
>    the old behavior. This is to make sure we do not break existing scripts
>    that rely on the existing behavior.

We discussed this in netdev0.1, and I think we agreed on adding a new
option, something like --hashlimit-update that would force an update
to the existing hashlimit internal state (that is identified by the
hashlimit name).

I think the problem here is that you may want to update the internal
state of an existing hashlimit object, and currently this is not
actually happening.

With the explicit --hashlimit-update flag, from the kernel we really
know that the user wants an update.

Let me know, thanks.
