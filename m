From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: 2.6.25-rc2-mm1 - several bugs and a crash
Date: Thu, 21 Feb 2008 08:32:48 -0800
Message-ID: <20080221083248.5b76b496@extreme>
References: <20080216002522.9c4bd0fb.akpm@linux-foundation.org>
	<47BC982C.7050402@imap.cc>
	<47BD6072.4000407@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Tilman Schmidt <tilman@imap.cc>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <47BD6072.4000407@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 21 Feb 2008 12:28:50 +0100
Patrick McHardy <kaber@trash.net> wrote:

> Tilman Schmidt wrote:
> > Still, X came up fine, I could log in (Gnome feeling subjectively
> > a bit sluggish), call up a web page from the Internet in Firefox,
> > and start perusing the logs, when the whole system froze: neither
> > mouse nor keyboard would react anymore, and only the Wind^Wreset
> > button would put me back in control. After rebooting into the
> > previous, non-mm kernel I found this in the syslog:
> > 
> > Feb 20 17:22:40 xenon kernel: [   48.180297] BUG: using smp_processor_id() in preemptible [00000000] code: ntpdate/3562
> > Feb 20 17:22:40 xenon kernel: [   48.180297] caller is __nf_conntrack_find+0x9b/0xeb [nf_conntrack]
> > Feb 20 17:22:40 xenon kernel: [   48.180297] Pid: 3562, comm: ntpdate Not tainted 2.6.25-rc2-mm1-testing #1
> > Feb 20 17:22:40 xenon kernel: [   48.180297]  [<c02015b9>] debug_smp_processor_id+0x99/0xb0
> 
> 
> Could you test whether this patch fixes the netfilter
> warnings please?
> 

> diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
> index 327e847..b77eb56 100644
> --- a/net/netfilter/nf_conntrack_core.c
> +++ b/net/netfilter/nf_conntrack_core.c
> @@ -256,13 +256,19 @@ __nf_conntrack_find(const struct nf_conntrack_tuple *tuple)
>  	struct hlist_node *n;
>  	unsigned int hash = hash_conntrack(tuple);
>  
> +	/* Disable BHs the entire time since we normally need to disable them
> +	 * at least once for the stats anyway.
> +	 */
> +	local_bh_disable();

Use rcu_read_lock instead. local_bh_disable() won't work with some of the other forms
of RCU alternatives.

