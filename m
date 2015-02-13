From: Cong Wang <cwang@twopensource.com>
Subject: Re: softlockups when trying to restore an nft set of 1M entries
Date: Fri, 13 Feb 2015 15:21:43 -0800
Message-ID: <CAHA+R7NMD4nUoQoo5o7jQT1w0pGLP4dWhWyjzeYGH6YwXqcjZw@mail.gmail.com>
References: <54DDE717.6090703@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Graf <tgraf@suug.ch>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Josh Hunt <johunt@akamai.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <54DDE717.6090703@akamai.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 13, 2015 at 3:59 AM, Josh Hunt <johunt@akamai.com> wrote:
> In my testing of nftables sets for our netdev bof discussion I came across
> this problem where if I try and do a set restore of 1M entries the machine
> gets into a softlockup state. Once this is triggered the system has to be
> rebooted.
>
> I can trigger the case by generating a simple nft rules file which defines a
> set of type ipv4_addr. Something like this:
>
> flush ruleset
> table ip filter {
>         set blackhole {
>                 type ipv4_addr
>         }
>         chain input {
>                  type filter hook input priority 0;
>         }
>
>         chain forward {
>                  type filter hook forward priority 0;
>         }
>
>         chain output {
>                  type filter hook output priority 0;
>         }
> }
>
> except inside the set definition above I add 1M random ipv4 addresses.
> Running "nft -f <filename>" will reproduce the problem. I also saw this when
> trying to do a restore of 250k entries.
>
> There are a few problems going on from what I can tell. The first is
> the set defaults to 4 buckets and during restores the # of buckets does not
> increase. I'm currently investigating to understand why we don't expand the
> set on restores. However my guess into why we're softlockuping here is that
> we're trying to shove 1M entries into 4 buckets :)
>
> Second, the user has no way to tune the # of initial buckets. My patchset
> "nft hash set expansion fixes" fixes this. If I tune the hash to use a
> reasonable # of buckets for 1M entries. I do not see the softlockup problem.
>
> I ran these tests using the current net-next.
>
> Here's some of the softlockup output. Let me know if you'd like more info,
> etc.

I guess we need a cond_resched() in the loop:

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 199fd0f..c07b334 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -3234,6 +3234,7 @@ static int nf_tables_newsetelem(struct sock
*nlsk, struct sk_buff *skb,
                if (err < 0)
                        break;

+               cond_resched();
                set->nelems++;
        }
        return err;
