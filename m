From: Vishwanath Pai <vpai@akamai.com>
Subject: Re: [PATCH iptables 3/3] libxt_hashlimit: iptables-restore does not
 work as expected with xt_hashlimit
Date: Tue, 5 Jul 2016 16:13:06 -0400
Message-ID: <577C14D2.3020005@akamai.com>
References: <20160602001759.GF1644@akamai.com> <20160623102511.GA10493@salvia>
 <576D7AD2.6050107@akamai.com> <20160625093924.GC1289@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, kadlec@blackhole.kfki.hu,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	johunt@akamai.com, netdev@vger.kernel.org, pai.vishwain@gmail.com
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay07.akamai.com ([23.79.238.175]:9712 "EHLO
	prod-mail-xrelay07.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751986AbcGEUN3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 16:13:29 -0400
In-Reply-To: <20160625093924.GC1289@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/25/2016 05:39 AM, Pablo Neira Ayuso wrote:
> I see, but I'm not convinced about this /proc rename feature.
> 
> I think the main point of this, as well as other entries in bugzilla
> related to this, is ability to update an existing hashlimit state.
> 
> So, I'm not proposing to rename --enhanced-procfs to something else,
> I think that a different approach consisting on adding a new option
> like --hashlimit-update that will update the internal state of an
> existing hashlimit object is just fine for your usecase, right?
> 
>> > Other than that, we are doing exactly what you said, but creating a new
>> > entry in the hashtable instead of updating it. The previous entry will
>> > automatically be removed when the old rule is flushed/deleted.
> What I'm missing is why we need this /proc rename at all.

The reason we need the procfs rename feature is because it is broken at
the moment. Let us assume someone adds two rules with the same name
(intentionally or otherwise). We cannot prevent them from doing this or
error out when someone does this because all of this is done in
hashlimit_mt_check which is called for every iptables rule change, even
an entirely different rule. I'll demonstrate two scenarios here. I have
put debug printk statements which prints everytime hashlimit_mt_check is
called.

1) Add two rules with the same name but in different chains

$ iptables -A chain1 -m hashlimit --hashlimit-above 200/sec \
  --hashlimit-mode srcip --hashlimit-name hashlimit1 -j DROP

$ dmesg -c
[  103.965578] hashlimit_mt_check for rule hashlimit1


$ iptables -A chain2 -m hashlimit --hashlimit-above 300/sec \
   --hashlimit-mode srcip --hashlimit-name hashlimit1 -j DROP

$ dmesg -c
[  114.613758] hashlimit_mt_check for rule hashlimit1
[  114.621360] hashlimit_mt_check for rule hashlimit1
[  114.627411] hashlimit_mt_destroy on hashlimit1

2) Replace an iptables rule with iptables-restore

$ iptables -A chain1 -m hashlimit --hashlimit-above 200/sec \
  --hashlimit-mode srcip --hashlimit-name hashlimit1 -j DROP

$ iptables-save > /tmp/hashlimit

$ vi /tmp/hashlimit (edit 200/s to 300/s)

$ iptables-restore < /tmp/hashlimit

$ dmesg -c
[ 1585.411093] hashlimit_mt_check for rule hashlimit1
[ 1585.418948] hashlimit_mt_destroy on hashlimit1

In case 1 there exists two rules with the same name but we cannot have
procfs files for both of the rules since they have to exist in the same
directory. In case 2 there will be only one rule but there is a small
window where two rules with same name exist. We cannot differentiate
this from case 1. In both the cases we get the call for
hashlimit_mt_check for the new rule before the old rule is deleted.

Without the rename feature I do not know how to correctly handle the
scenario where two rules with different parameters but the same name exist.

I believe the rest of the patch handles the --hashlimit-update feature
you mentioned, but instead of updating an existing object it creates a
new one and the old object is deleted by the call to destroy. The
hashtable match function is modified to include all parameters of the
object and not just the name so that we can reuse objects that have the
exact same features.
