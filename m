From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next] bpf: fix double free from dev_map_notification()
Date: Sun, 20 Aug 2017 17:42:45 -0700
Message-ID: <52f70537-afcf-e384-cb96-2a5b8c032c51@fb.com>
References: <22ff5f74079470a06e11940f40e05b2db74ca21f.1503272633.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <john.fastabend@gmail.com>, <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:47565 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753440AbdHUAnL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Aug 2017 20:43:11 -0400
In-Reply-To: <22ff5f74079470a06e11940f40e05b2db74ca21f.1503272633.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/20/17 4:48 PM, Daniel Borkmann wrote:
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

makes sense to me
Acked-by: Alexei Starovoitov <ast@kernel.org>
I wonder why it was done the other way around in the first place then?
dev_map_list is there only for notifier and since the map is freed
with all the devices totally makes sense to isolate it from notifier
as a first step.
