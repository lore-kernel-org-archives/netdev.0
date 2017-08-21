From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: fix double free from
 dev_map_notification()
Date: Sun, 20 Aug 2017 19:46:23 -0700 (PDT)
Message-ID: <20170820.194623.2155561200186936212.davem@davemloft.net>
References: <22ff5f74079470a06e11940f40e05b2db74ca21f.1503272633.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.fastabend@gmail.com, ast@fb.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48842 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753470AbdHUCqY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Aug 2017 22:46:24 -0400
In-Reply-To: <22ff5f74079470a06e11940f40e05b2db74ca21f.1503272633.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Mon, 21 Aug 2017 01:48:12 +0200

> In the current code, dev_map_free() can still race with dev_map_notification().
> In dev_map_free(), we remove dtab from the list of dtabs after we purged
> all entries from it. However, we don't do xchg() with NULL or the like,
> so the entry at that point is still pointing to the device. If a unregister
> notification comes in at the same time, we therefore risk a double-free,
> since the pointer is still present in the map, and then pushed again to
> __dev_map_entry_free().
> 
> All this is completely unnecessary. Just remove the dtab from the list
> right before the synchronize_rcu(), so all outstanding readers from the
> notifier list have finished by then, thus we don't need to deal with this
> corner case anymore and also wouldn't need to nullify dev entires. This is
> fine because we iterate over the map releasing all entries and therefore
> dev references anyway.
> 
> Fixes: 4cc7b9544b9a ("bpf: devmap fix mutex in rcu critical section")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks Daniel.
