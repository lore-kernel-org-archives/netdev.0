From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/5] act_bpf: remove spinlock in fast path
Date: Wed, 26 Aug 2015 11:02:00 -0700 (PDT)
Message-ID: <20150826.110200.2304613258350642186.davem@davemloft.net>
References: <1440558395-7765-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, daniel@iogearbox.net, netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36887 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751919AbbHZSCB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 14:02:01 -0400
In-Reply-To: <1440558395-7765-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Tue, 25 Aug 2015 20:06:30 -0700

> v1 version had a race condition in cleanup path of bpf_prog.
> I tried to fix it by adding new callback 'cleanup_rcu' to 'struct tcf_common'
> and call it out of act_api cleanup path, but Daniel noticed
> (thanks for the idea!) that most of the classifiers already do action cleanup
> out of rcu callback.
> So instead this set of patches converts tcindex and rsvp classifiers to call
> tcf_exts_destroy() after rcu grace period and since action cleanup logic
> in __tcf_hash_release() is only called when bind and refcnt goes to zero,
> it's guaranteed that cleanup() callback is called from rcu callback.
> More specifically:
> patches 1 and 2 - simple fixes
> patches 2 and 3 - convert tcf_exts_destroy in tcindex and rsvp to call_rcu
> patch 5 - removes spin_lock from act_bpf
> 
> The cleanup of actions is now universally done after rcu grace period
> and in the future we can drop (now unnecessary) call_rcu from tcf_hash_destroy()
> patch 5 is using synchronize_rcu() in act_bpf replacement path, since it's
> very rare and alternative of dynamically allocating 'struct tcf_bpf_cfg' just
> to pass it to call_rcu looks even less appealing.

Series applied, thanks Alexei.
