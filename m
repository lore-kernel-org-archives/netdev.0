From: Patrick McHardy <kaber@trash.net>
Subject: Re: deleting a conntrack record
Date: Thu, 17 Jun 2004 18:42:35 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <40D1C9FB.1070802@trash.net>
References: <876ef97a0406170807663b89e0@mail.gmail.com> <40D1C088.4090307@trash.net> <876ef97a04061709173c8f1a09@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>, linux-net <linux-net@vger.kernel.org>,
	netfilter <netfilter-devel@lists.netfilter.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: Tobias DiPasquale <codeslinger@gmail.com>
In-Reply-To: <876ef97a04061709173c8f1a09@mail.gmail.com>
List-Id: netdev.vger.kernel.org

Tobias DiPasquale wrote:
> On Thu, 17 Jun 2004 18:02:16 +0200, Patrick McHardy <kaber@trash.net> wrote:
> 
>>The function passed to ip_ct_selective_cleanup is supposed to decide
>>if a conntrack should be destroyed by returning 0/1, not to do it
>>itself. ip_ct_selective_cleanup tries to destroy the already destroyed
>>conntrack.
> 
> This results in a memory leak in the conntrack slab cache. If you
> don't call ip_conntrack_put(), the conntrack entry leaves the
> ip_ct_selective_cleanup() function with a value >0 and thus is a
> permanent part of the scenery in RAM. As well, its been removed from
> the conntrack hash table, so it no longer appears in
> /proc/net/ip_conntrack, but you can see the effects by viewing
> /proc/slabinfo.

Now I remember - the reason why ctnetlink called ip_conntrack_put
in ctnetlink_kill is because it uses ip_conntrack_find_get before,
which increments the reference count. This is wrong because the
conntrack is then destroyed immediately after returning 1 to
ip_ct_selective_cleanup, but still used for comparing the tuple.
You (and ctnetlink) need to call ip_conntrack_put after the
call to ip_ct_selective_cleanup. In fact you shouldn't use
ip_ct_selective_cleanup at all but destroy it yourself. You
already have a reference, so there is no need to iterate through
the entire hash.

Regards
Patrick
